import 'dart:math' as math;

import 'package:common/datamodel/location.dart' show Coordinates;
import 'package:sweph/sweph.dart' hide Coordinates;
import 'package:timezone/timezone.dart' as tz;

/// 单个天体的升/落/中天时刻（均为 UTC）
class CelestialRiseSetResult {
  /// 天体升起时刻 (UTC)，极圈内可能为 null
  final DateTime? rise;

  /// 天体落下时刻 (UTC)，极圈内可能为 null
  final DateTime? set_;

  /// 天体上中天时刻 (UTC)
  final DateTime? transit;

  const CelestialRiseSetResult({this.rise, this.set_, this.transit});

  @override
  String toString() =>
      'CelestialRiseSetResult(rise: $rise, set: $set_, transit: $transit)';
}

/// 晨昏蒙影时刻
class TwilightInfo {
  /// 民用晨光始 / 民用昏影终 (太阳中心低于地平线 6°)
  final DateTime? civilDawn;
  final DateTime? civilDusk;

  /// 航海晨光始 / 航海昏影终 (太阳中心低于地平线 12°)
  final DateTime? nauticalDawn;
  final DateTime? nauticalDusk;

  /// 天文晨光始 / 天文昏影终 (太阳中心低于地平线 18°)
  final DateTime? astronomicalDawn;
  final DateTime? astronomicalDusk;

  const TwilightInfo({
    this.civilDawn,
    this.civilDusk,
    this.nauticalDawn,
    this.nauticalDusk,
    this.astronomicalDawn,
    this.astronomicalDusk,
  });

  @override
  String toString() =>
      'TwilightInfo(civilDawn: $civilDawn, civilDusk: $civilDusk, '
      'nauticalDawn: $nauticalDawn, nauticalDusk: $nauticalDusk, '
      'astronomicalDawn: $astronomicalDawn, astronomicalDusk: $astronomicalDusk)';
}

/// 一天的日月出没 + 晨昏蒙影汇总
class DailyRiseSetInfo {
  final CelestialRiseSetResult sun;
  final CelestialRiseSetResult moon;
  final TwilightInfo? twilight;

  const DailyRiseSetInfo({
    required this.sun,
    required this.moon,
    this.twilight,
  });

  @override
  String toString() =>
      'DailyRiseSetInfo(sun: $sun, moon: $moon, twilight: $twilight)';
}

/// 天体出没计算器
///
/// 封装 sweph 的 `swe_rise_trans` API，提供日出日落、月出月落、
/// 晨昏蒙影及昼夜判断功能。
class CelestialRiseSetCalculator {
  /// 标准大气压 (hPa)
  static const double _defaultPressure = 1013.25;

  /// 标准温度 (°C)
  static const double _defaultTemperature = 15.0;

  /// 计算单个天体的升/落/中天时刻
  ///
  /// [utcDateTime] 观测日期时间 (UTC)
  /// [longitude] 观测点经度 (东正西负)
  /// [latitude] 观测点纬度 (北正南负)
  /// [body] 天体类型
  /// [altitude] 海拔高度 (米)，默认 0
  /// [pressure] 大气压 (hPa)，默认标准大气压
  /// [temperature] 温度 (°C)，默认 15°C
  static CelestialRiseSetResult calculate({
    required DateTime utcDateTime,
    required double longitude,
    required double latitude,
    required HeavenlyBody body,
    double altitude = 0,
    double pressure = _defaultPressure,
    double temperature = _defaultTemperature,
  }) {
    final jd = _utcToJulianDay(utcDateTime);
    final geoPos = _buildGeoPosition(longitude, latitude, altitude);

    final rise = _computeEvent(
      jd,
      body,
      RiseSetTransitFlag.SE_CALC_RISE,
      geoPos,
      pressure,
      temperature,
    );
    final set_ = _computeEvent(
      jd,
      body,
      RiseSetTransitFlag.SE_CALC_SET,
      geoPos,
      pressure,
      temperature,
    );
    final transit = _computeEvent(
      jd,
      body,
      RiseSetTransitFlag.SE_CALC_MTRANSIT,
      geoPos,
      pressure,
      temperature,
    );

    return CelestialRiseSetResult(
      rise: rise != null ? _julianDayToUtc(rise) : null,
      set_: set_ != null ? _julianDayToUtc(set_) : null,
      transit: transit != null ? _julianDayToUtc(transit) : null,
    );
  }

  /// 一次返回日月出没 + 可选晨昏蒙影
  ///
  /// [utcDateTime] 观测日期时间 (UTC)
  /// [longitude] 观测点经度
  /// [latitude] 观测点纬度
  /// [altitude] 海拔高度 (米)
  /// [includeTwilight] 是否计算晨昏蒙影，默认 false
  static DailyRiseSetInfo calculateDaily({
    required DateTime utcDateTime,
    required double longitude,
    required double latitude,
    double altitude = 0,
    bool includeTwilight = false,
  }) {
    final sun = calculate(
      utcDateTime: utcDateTime,
      longitude: longitude,
      latitude: latitude,
      body: HeavenlyBody.SE_SUN,
      altitude: altitude,
    );

    final moon = calculate(
      utcDateTime: utcDateTime,
      longitude: longitude,
      latitude: latitude,
      body: HeavenlyBody.SE_MOON,
      altitude: altitude,
    );

    TwilightInfo? twilight;
    if (includeTwilight) {
      twilight = calculateTwilight(
        utcDateTime: utcDateTime,
        longitude: longitude,
        latitude: latitude,
        altitude: altitude,
      );
    }

    return DailyRiseSetInfo(sun: sun, moon: moon, twilight: twilight);
  }

  /// 计算民用/航海/天文晨昏蒙影
  static TwilightInfo calculateTwilight({
    required DateTime utcDateTime,
    required double longitude,
    required double latitude,
    double altitude = 0,
    double pressure = _defaultPressure,
    double temperature = _defaultTemperature,
  }) {
    final jd = _utcToJulianDay(utcDateTime);
    final geoPos = _buildGeoPosition(longitude, latitude, altitude);

    DateTime? computeTwilightEvent(
        RiseSetTransitFlag twilightFlag, RiseSetTransitFlag riseOrSet) {
      final flag = riseOrSet | twilightFlag;
      final result = _computeEvent(
          jd, HeavenlyBody.SE_SUN, flag, geoPos, pressure, temperature);
      return result != null ? _julianDayToUtc(result) : null;
    }

    return TwilightInfo(
      civilDawn: computeTwilightEvent(
        RiseSetTransitFlag.SE_BIT_CIVIL_TWILIGHT,
        RiseSetTransitFlag.SE_CALC_RISE,
      ),
      civilDusk: computeTwilightEvent(
        RiseSetTransitFlag.SE_BIT_CIVIL_TWILIGHT,
        RiseSetTransitFlag.SE_CALC_SET,
      ),
      nauticalDawn: computeTwilightEvent(
        RiseSetTransitFlag.SE_BIT_NAUTIC_TWILIGHT,
        RiseSetTransitFlag.SE_CALC_RISE,
      ),
      nauticalDusk: computeTwilightEvent(
        RiseSetTransitFlag.SE_BIT_NAUTIC_TWILIGHT,
        RiseSetTransitFlag.SE_CALC_SET,
      ),
      astronomicalDawn: computeTwilightEvent(
        RiseSetTransitFlag.SE_BIT_ASTRO_TWILIGHT,
        RiseSetTransitFlag.SE_CALC_RISE,
      ),
      astronomicalDusk: computeTwilightEvent(
        RiseSetTransitFlag.SE_BIT_ASTRO_TWILIGHT,
        RiseSetTransitFlag.SE_CALC_SET,
      ),
    );
  }

  /// 基于实际日出日落判断是否昼生
  ///
  /// [utcDateTime] 出生时间 (UTC)
  /// [longitude] 出生地经度
  /// [latitude] 出生地纬度
  /// [altitude] 海拔高度 (米)
  ///
  /// 返回 true 表示昼生，false 表示夜生。
  /// 极圈内日不落/日不出时，通过太阳高度角判断。
  static bool isDayTime({
    required DateTime utcDateTime,
    required double longitude,
    required double latitude,
    double altitude = 0,
  }) {
    final sunResult = calculate(
      utcDateTime: utcDateTime,
      longitude: longitude,
      latitude: latitude,
      body: HeavenlyBody.SE_SUN,
      altitude: altitude,
    );

    final rise = sunResult.rise;
    final set_ = sunResult.set_;

    // 正常情况：有日出日落
    if (rise != null && set_ != null) {
      if (rise.isBefore(set_)) {
        // 日出在日落之前：昼时 = rise <= t < set
        return !utcDateTime.isBefore(rise) && utcDateTime.isBefore(set_);
      } else {
        // 日出在日落之后（跨午夜）：昼时 = t >= rise || t < set
        return !utcDateTime.isBefore(rise) || utcDateTime.isBefore(set_);
      }
    }

    // 极地情况：无日出日落，用太阳高度角判断
    return _isSunAboveHorizon(utcDateTime, longitude, latitude);
  }

  /// 接受 xuan-common 的 Coordinates 类
  static CelestialRiseSetResult calculateFromCoordinates({
    required DateTime utcDateTime,
    required Coordinates coordinates,
    required HeavenlyBody body,
    double altitude = 0,
  }) {
    return calculate(
      utcDateTime: utcDateTime,
      longitude: coordinates.longitude,
      latitude: coordinates.latitude,
      body: body,
      altitude: altitude,
    );
  }

  /// 接受本地时间 + timezone 字符串
  static CelestialRiseSetResult calculateFromLocalTime({
    required DateTime localDateTime,
    required String timezone,
    required double longitude,
    required double latitude,
    required HeavenlyBody body,
    double altitude = 0,
  }) {
    final utcDateTime = _localToUtc(localDateTime, timezone);
    return calculate(
      utcDateTime: utcDateTime,
      longitude: longitude,
      latitude: latitude,
      body: body,
      altitude: altitude,
    );
  }

  // ─── 内部辅助方法 ───

  /// 本地时间转 UTC
  static DateTime _localToUtc(DateTime localDateTime, String timezone) {
    final tzDateTime = tz.TZDateTime(
      tz.getLocation(timezone),
      localDateTime.year,
      localDateTime.month,
      localDateTime.day,
      localDateTime.hour,
      localDateTime.minute,
      localDateTime.second,
    );
    return tzDateTime.toUtc();
  }

  /// UTC DateTime 转 Julian Day (UT1)，精确到秒
  static double _utcToJulianDay(DateTime utc) {
    final jds = Sweph.swe_utc_to_jd(
      utc.year,
      utc.month,
      utc.day,
      utc.hour,
      utc.minute,
      utc.second.toDouble(),
      CalendarType.SE_GREG_CAL,
    );
    // [0] = JD ET, [1] = JD UT1
    return jds[1];
  }

  /// Julian Day (UT1) 转 UTC DateTime
  static DateTime _julianDayToUtc(double jd) {
    return Sweph.swe_jdut1_to_utc(jd, CalendarType.SE_GREG_CAL);
  }

  /// 构建 GeoPosition (sweph: longitude, latitude, altitude)
  static GeoPosition _buildGeoPosition(
    double longitude,
    double latitude,
    double altitude,
  ) {
    return GeoPosition(longitude, latitude, altitude);
  }

  /// 封装单次 swe_rise_trans 调用
  ///
  /// 返回事件的 Julian Day，极圈内无此事件时返回 null。
  static double? _computeEvent(
    double julianDay,
    HeavenlyBody body,
    RiseSetTransitFlag flag,
    GeoPosition geoPos,
    double pressure,
    double temperature,
  ) {
    return Sweph.swe_rise_trans(
      julianDay,
      body,
      SwephFlag.SEFLG_SWIEPH,
      flag,
      geoPos,
      pressure,
      temperature,
    );
  }

  /// 极地 fallback：通过太阳高度角判断是否在地平线以上
  ///
  /// 使用 swe_calc_ut 计算太阳位置，结合观测者纬度估算太阳高度。
  /// 简化方法：计算太阳赤纬，与观测者纬度比较。
  static bool _isSunAboveHorizon(
    DateTime utcDateTime,
    double longitude,
    double latitude,
  ) {
    final jd = _utcToJulianDay(utcDateTime);

    // 计算太阳位置（黄道坐标）
    final sunPos = Sweph.swe_calc_ut(
      jd,
      HeavenlyBody.SE_SUN,
      SwephFlag.SEFLG_SWIEPH | SwephFlag.SEFLG_EQUATORIAL,
    );

    // sunPos.latitude = 赤纬 (declination) when using SEFLG_EQUATORIAL
    final declination = sunPos.latitude;

    // 计算太阳高度角近似值
    // h = arcsin(sin(lat)*sin(dec) + cos(lat)*cos(dec)*cos(H))
    // 其中 H 为时角，需要从恒星时计算
    final siderealTime = Sweph.swe_sidtime(jd); // 格林尼治恒星时（小时）
    final localSiderealTime = siderealTime + longitude / 15.0; // 本地恒星时
    final rightAscension = sunPos.longitude; // RA in degrees when EQUATORIAL
    final hourAngle =
        (localSiderealTime * 15.0 - rightAscension) * math.pi / 180.0;

    final latRad = latitude * math.pi / 180.0;
    final decRad = declination * math.pi / 180.0;

    final sinAltitude = math.sin(latRad) * math.sin(decRad) +
        math.cos(latRad) * math.cos(decRad) * math.cos(hourAngle);

    // 太阳高度角 > 0 即在地平线以上
    return sinAltitude > 0;
  }
}

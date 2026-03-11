import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:common/widgets/yun_liu_list_tile_card/yun_liu_list_tile_card_widget.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:tyme/tyme.dart' hide Gender;
import 'package:common/features/da_yun/da_yun_calculator.dart';
import 'package:common/models/chinese_date_info.dart';
import 'package:common/enums/enum_gender.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/enums/enum_tian_gan.dart';
import 'package:common/enums/enum_di_zhi.dart';

class YunLiuDemoDataHelper {
  // Original dummy formulas moved here to serve the demo page without putting logic in the UI Widget.
  // ===========================================================================
  // === REAL CALCULATION ENGINE INTEGRATION
  // ===========================================================================

  static ChineseDateInfo? _cachedDateInfo;
  static JiaZi? _cachedDayMasterPillar;
  static TianGan get _dayMaster => _cachedDayMasterPillar!.tianGan;

  /// Initializes a mock person's real Bazi data for the demo
  static void initMockPerson(DateTime birthDate) {
    if (_cachedDateInfo != null) return;

    _cachedDateInfo = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
      birthDate,
      ZiShiStrategy.noDistinguishAt23,
    );
    _cachedDayMasterPillar = _cachedDateInfo!.dayGanZhi;
  }

  /// Builds the top-level DaYun list dynamically
  static List<DaYunDisplayData> buildRealDaYunData() {
    // 1. Ensure initialized
    final birthDate = DateTime(1990, 6, 15, 12, 0); // Mock birth date
    initMockPerson(birthDate);

    // 2. Calculate real DaYun
    final calculator = DaYunCalculator();
    final realDaYun = calculator.calculate(
      dateInfo: _cachedDateInfo!,
      birthDateTime: birthDate,
      gender: Gender.male,
      stepDuration: 10,
      pillarCount: 8,
    );

    // 3. Map to UI Display Data
    final result = <DaYunDisplayData>[];
    for (var i = 0; i < realDaYun.length; i++) {
      final pillar = realDaYun[i];
      final currPillarJiaZi = pillar.pillar;

      // Calculate DaYun pillar's relationship with Day Master
      final ganGod = currPillarJiaZi.tianGan.getTenGods(_dayMaster);
      final zhiGods = currPillarJiaZi.zhi.cangGan
          .map((h) => (gan: h, hiddenGods: h.getTenGods(_dayMaster)))
          .toList();

      result.add((
        pillar: currPillarJiaZi,
        ganGod: ganGod,
        hiddenGans: zhiGods,
        startYear: birthDate.year + pillar.startAge,
        startAge: pillar.startAge,
        yearsCount: 10,
        liunian: _buildLiuNianForDaYun(
          startYear: birthDate.year + pillar.startAge,
          startAge: pillar.startAge,
        ),
      ));
    }

    return result;
  }

  /// Generates the LiuNian (Year) list for a specific DaYun decade
  static List<LiuNianDisplayData> _buildLiuNianForDaYun({
    required int startYear,
    required int startAge,
  }) {
    final result = <LiuNianDisplayData>[];

    for (int i = 0; i < 10; i++) {
      final year = startYear + i;
      // Formula for Year GanZhi: The 4th year CE is Jia Zi (1)
      final offset = (year - 4) % 60;
      final number = offset < 0 ? offset + 60 + 1 : offset + 1;
      final yearPillar = JiaZi.getByNumber(number);

      // Relationship with Day Master
      final ganGod = yearPillar.tianGan.getTenGods(_dayMaster);
      final zhiGods = yearPillar.zhi.cangGan
          .map((h) => (gan: h, hiddenGods: h.getTenGods(_dayMaster)))
          .toList();

      result.add((
        pillar: yearPillar,
        ganGod: ganGod,
        hiddenGans: zhiGods,
        year: year,
        age: startAge + i,
        liuyue: _buildLiuYueForYear(yearPillar),
      ));
    }

    return result;
  }

  /// Generates real LiuYue (Month) list for a given LiuNian pillar
  static List<LiuYueDisplayData> _buildLiuYueForYear(JiaZi yearPillar) {
    final liuyue = <LiuYueDisplayData>[];

    // Wu Hu Dun (Yin Month Start Stem based on Year Stem)
    final yearGan = yearPillar.tianGan;
    // Calculation: 甲己之年丙作首，乙庚之岁戊为头... etc.
    final List<TianGan> wuHuDunStart = [
      TianGan.BING, // 甲
      TianGan.WU, // 乙
      TianGan.GENG, // 丙
      TianGan.REN, // 丁
      TianGan.JIA, // 戊
      TianGan.BING, // 己
      TianGan.WU, // 庚
      TianGan.GENG, // 辛
      TianGan.REN, // 壬
      TianGan.JIA, // 癸
    ];
    final startStem = wuHuDunStart[yearGan.index];

    // The first month of the Chinese year is Yin (寅)
    JiaZi monthPillar = JiaZi.getFromGanZhiEnum(startStem, DiZhi.YIN);

    for (int i = 1; i <= 12; i++) {
      final ganGod = monthPillar.tianGan.getTenGods(_dayMaster);
      final zhiGods = monthPillar.zhi.cangGan
          .map((h) => (gan: h.name, tenGod: h.getTenGods(_dayMaster).name))
          .toList();

      liuyue.add(LiuYueDisplayData(
        monthName: '$i月',
        gregorianMonth: i, // Note: Gregorian month mapping is approximate in this simple UI demo
        ganZhi: monthPillar.name,
        tenGodName: ganGod.name,
        hidden: zhiGods,
      ));

      monthPillar = monthPillar.getNext();
    }
    return liuyue;
  }

  /// Fetches real LiuRi (Day) and relationships for the specified year and month.
  static List<LiuRiDisplayData> fetchLiuRiData(int year, int month) {
    final next = DateTime(year, month + 1, 1);
    final days = next.subtract(const Duration(days: 1)).day;

    final results = <LiuRiDisplayData>[];

    for (int d = 1; d <= days; d++) {
      final dt = DateTime(year, month, d);
      final info = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
        dt,
        ZiShiStrategy.noDistinguishAt23,
      );

      final dayPillar = info.dayGanZhi;

      // Check JieQi definition
      final jieQiInfo = info.jieQiInfo;
      String? jieQiName;
      if (jieQiInfo.startAt.year == dt.year &&
          jieQiInfo.startAt.month == dt.month &&
          jieQiInfo.startAt.day == dt.day) {
        jieQiName = jieQiInfo.jieQi.name;
      }

      // Calculate Day relationship against User's Day Master
      final ganGod = dayPillar.tianGan.getTenGods(_dayMaster);
      final zhiGods = dayPillar.zhi.cangGan
          .map((h) => (gan: h.name, tenGod: h.getTenGods(_dayMaster).name))
          .toList();

      final today = DateTime.now();
      final isToday = dt.year == today.year &&
          dt.month == today.month &&
          dt.day == today.day;

      final lunarDayObj = SolarDay.fromYmd(year, month, d).getLunarDay();
      final lunarMonthName = lunarDayObj.getLunarMonth().getName();
      final lunarDayName = lunarDayObj.getName();
      final lunarText = '农历 $lunarMonthName$lunarDayName';

      results.add(LiuRiDisplayData(
        gregorianYear: year,
        gregorianMonth: month,
        gregorianDay: d,
        ganZhi: dayPillar.name,
        tenGodName: ganGod.name,
        jieQiName: jieQiName,
        hidden: zhiGods,
        lunarText: lunarText,
        isToday: isToday,
      ));
    }

    return results;
  }

  static List<LiuShiDisplayData> fetchLiuShiData(int year, int month, int day) {
    final dt = DateTime(year, month, day);
    final infoDay = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
      dt,
      ZiShiStrategy.noDistinguishAt23,
    );
    final dayGanZhi = infoDay.dayGanZhi.name;
    final dayGan = dayGanZhi.isNotEmpty ? dayGanZhi[0] : '甲';

    const zhiTime = [
      '23-01', '01-03', '03-05', '05-07', '07-09', '09-11',
      '11-13', '13-15', '15-17', '17-19', '19-21', '21-23'
    ];

    final results = <LiuShiDisplayData>[];
    for (int h = 0; h < 12; h++) {
      // Real Wu Shu Dun (Five Rats Calculation for Hour Stem)
      final dGan = TianGan.getFromValue(dayGan) ?? TianGan.JIA;
      final List<TianGan> wuShuDunStart = [
        TianGan.JIA,  // 甲己还加甲
        TianGan.BING, // 乙庚丙作初
        TianGan.WU,   // 丙辛从戊起
        TianGan.GENG, // 丁壬庚子居
        TianGan.REN,  // 戊癸何方发，壬子是真途
        TianGan.JIA,
        TianGan.BING,
        TianGan.WU,
        TianGan.GENG,
        TianGan.REN,
      ];
      final startingHourStem = wuShuDunStart[dGan.index];

      JiaZi hourPillar = JiaZi.getFromGanZhiEnum(startingHourStem, DiZhi.ZI);
      for (int i = 0; i < h; i++) {
        hourPillar = hourPillar.getNext();
      }

      final ganGod = hourPillar.tianGan.getTenGods(_dayMaster);
      final zhiGods = hourPillar.zhi.cangGan
          .map((hx) => (gan: hx.name, tenGod: hx.getTenGods(_dayMaster).name))
          .toList();

      String? jieQiName;

      results.add(LiuShiDisplayData(
        shiIdx: h,
        zhiTime: zhiTime[h],
        ganZhi: hourPillar.name,
        tenGodName: ganGod.name,
        hidden: zhiGods,
        jieQiName: jieQiName,
      ));
    }

    return results;
  }
}

import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:common/models/yun_liu_display_models.dart';
import 'package:common/features/da_yun/da_yun_calculator.dart';
import 'package:common/models/chinese_date_info.dart';
import 'package:common/enums.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:tyme/tyme.dart' hide Gender;

class YunLiuService {
  /// Base logic for calculating DaYun list for a user.
  List<DaYunDisplayData> calculateDaYunList({
    required DateTime birthDateTime,
    required Gender gender,
    required ChineseDateInfo birthDateInfo,
  }) {
    final dayMaster = birthDateInfo.dayGanZhi.tianGan;

    final calculator = DaYunCalculator();
    final realDaYun = calculator.calculate(
      dateInfo: birthDateInfo,
      birthDateTime: birthDateTime,
      gender: gender,
      stepDuration: 10,
      pillarCount: 8,
    );

    final result = <DaYunDisplayData>[];
    for (var i = 0; i < realDaYun.length; i++) {
      final pillar = realDaYun[i];
      final currPillarJiaZi = pillar.pillar;

      final ganGod = currPillarJiaZi.tianGan.getTenGods(dayMaster);
      final zhiGods = currPillarJiaZi.zhi.cangGan
          .map((h) => (gan: h, hiddenGods: h.getTenGods(dayMaster)))
          .toList();

      result.add((
        pillar: currPillarJiaZi,
        ganGod: ganGod,
        hiddenGans: zhiGods,
        startYear: birthDateTime.year + pillar.startAge,
        startAge: pillar.startAge,
        yearsCount: 10,
        liunian: calculateLiuNianList(
          startYear: birthDateTime.year + pillar.startAge,
          startAge: pillar.startAge,
          dayMaster: dayMaster,
        ),
      ));
    }

    return result;
  }

  /// Generates the LiuNian (Year) list for a specific DaYun decade
  List<LiuNianDisplayData> calculateLiuNianList({
    required int startYear,
    required int startAge,
    required TianGan dayMaster,
  }) {
    final result = <LiuNianDisplayData>[];

    for (int i = 0; i < 10; i++) {
      final year = startYear + i;
      // Formula for Year GanZhi: The 4th year CE is Jia Zi (1)
      final offset = (year - 4) % 60;
      final number = offset < 0 ? offset + 60 + 1 : offset + 1;
      final yearPillar = JiaZi.getByNumber(number);

      final ganGod = yearPillar.tianGan.getTenGods(dayMaster);
      final zhiGods = yearPillar.zhi.cangGan
          .map((h) => (gan: h, hiddenGods: h.getTenGods(dayMaster)))
          .toList();

      result.add((
        pillar: yearPillar,
        ganGod: ganGod,
        hiddenGans: zhiGods,
        year: year,
        age: startAge + i,
        liuyue: calculateLiuYueList(yearPillar, dayMaster),
      ));
    }

    return result;
  }

  /// Generates real LiuYue (Month) list for a given LiuNian pillar
  List<LiuYueDisplayData> calculateLiuYueList(JiaZi yearPillar, TianGan dayMaster) {
    final liuyue = <LiuYueDisplayData>[];

    // Wu Hu Dun (Yin Month Start Stem based on Year Stem)
    final yearGan = yearPillar.tianGan;
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

    JiaZi monthPillar = JiaZi.getFromGanZhiEnum(startStem, DiZhi.YIN);

    for (int i = 1; i <= 12; i++) {
      final ganGod = monthPillar.tianGan.getTenGods(dayMaster);
      final zhiGods = monthPillar.zhi.cangGan
          .map((h) => (gan: h.name, tenGod: h.getTenGods(dayMaster).name))
          .toList();

      liuyue.add(LiuYueDisplayData(
        monthName: '$i月',
        gregorianMonth: i,
        ganZhi: monthPillar.ganZhiStr,
        tenGodName: ganGod.name,
        hidden: zhiGods,
      ));

      monthPillar = monthPillar.getNext();
    }
    return liuyue;
  }

  /// Fetches real LiuRi (Day) and relationships for the specified year and month.
  List<LiuRiDisplayData> fetchLiuRiData(int year, int month, TianGan dayMaster) {
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
      final jieQiInfo = info.jieQiInfo;
      String? jieQiName;
      if (jieQiInfo.startAt.year == dt.year &&
          jieQiInfo.startAt.month == dt.month &&
          jieQiInfo.startAt.day == dt.day) {
        jieQiName = jieQiInfo.jieQi.name;
      }

      final ganGod = dayPillar.tianGan.getTenGods(dayMaster);
      final zhiGods = dayPillar.zhi.cangGan
          .map((h) => (gan: h.name, tenGod: h.getTenGods(dayMaster).name))
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
        ganZhi: dayPillar.ganZhiStr,
        tenGodName: ganGod.name,
        jieQiName: jieQiName,
        hidden: zhiGods,
        lunarText: lunarText,
        isToday: isToday,
      ));
    }

    return results;
  }

  /// Fetches real LiuShi (Hour) and relationships for the specified year, month, and day.
  List<LiuShiDisplayData> fetchLiuShiData(int year, int month, int day, TianGan dayMaster) {
    final dt = DateTime(year, month, day);
    final infoDay = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
      dt,
      ZiShiStrategy.noDistinguishAt23,
    );
    final dayGanPillar = infoDay.dayGanZhi;
    final dGan = dayGanPillar.tianGan;

    const zhiTime = [
      '23-01', '01-03', '03-05', '05-07', '07-09', '09-11',
      '11-13', '13-15', '15-17', '17-19', '19-21', '21-23'
    ];

    final results = <LiuShiDisplayData>[];
    
    // Wu Shu Dun (Five Rats Calculation for Hour Stem)
    final List<TianGan> wuShuDunStart = [
      TianGan.JIA,  // 甲己还加甲
      TianGan.BING, // 乙庚丙作初
      TianGan.WU,   // 丙辛从戊起
      TianGan.GENG, // 丁壬庚子居
      TianGan.REN,  // 戊癸何方发，壬子是真途
      TianGan.JIA,  // 己
      TianGan.BING, // 庚
      TianGan.WU,   // 辛
      TianGan.GENG, // 壬
      TianGan.REN,  // 癸
    ];
    final startingHourStem = wuShuDunStart[dGan.index];

    JiaZi hourPillar = JiaZi.getFromGanZhiEnum(startingHourStem, DiZhi.ZI);

    for (int h = 0; h < 12; h++) {
      final ganGod = hourPillar.tianGan.getTenGods(dayMaster);
      final zhiGods = hourPillar.zhi.cangGan
          .map((hx) => (gan: hx.name, tenGod: hx.getTenGods(dayMaster).name))
          .toList();

      results.add(LiuShiDisplayData(
        shiIdx: h,
        zhiTime: zhiTime[h],
        ganZhi: hourPillar.ganZhiStr,
        tenGodName: ganGod.name,
        hidden: zhiGods,
        jieQiName: null, // Hour level solar terms are rare in basic display
      ));
      
      hourPillar = hourPillar.getNext();
    }

    return results;
  }
}

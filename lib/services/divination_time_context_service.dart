import 'package:common/enums/enum_di_zhi.dart';
import 'package:common/enums/enum_tian_gan.dart';
import 'package:tyme/tyme.dart';
import '../enums/enum_jia_zi.dart';
import '../interfaces/i_divination_time_context_service.dart';

/// 高性能大运/流年计算服务实现
///
/// 【核心设计思想：锚点计算 + 数学极速推演】
/// 1. 绝不跨十年/十二月批量调用天文级历法计算（耗时且容易引发掉帧）。
/// 2. 仅在 [getYearsInDaYun] 中调用 `tyme` 计算起步年份的干支（锚点）。
/// 3. 后续流年、流月、流时全都基于天干地支 60 甲子环形队列的数学规律 O(1) 推演。
/// 4. 【稳定与异常处理】：流月交节日（当且仅当需要精确流日时），采用安全的按月历法步进计算。
class DivinationTimeContextService implements IDivinationTimeContextService {
  // 单例模式，该服务无内部状态，可在全应用程序共享极速执行。
  static final DivinationTimeContextService _instance =
      DivinationTimeContextService._internal();

  factory DivinationTimeContextService() => _instance;

  DivinationTimeContextService._internal();

  @override
  List<JiaZi> getYearsInDaYun({
    required DateTime seekerBirthTime,
    required int daYunStartYear,
    required int durationYears,
  }) {
    if (durationYears <= 0) return [];

    // [极速锚点策]：我们仅且只算一次这十年开头这一年的天干地支
    // 这里依赖 tyme 库将公历转为干支
    // 随便取公历 7 月 1 日，此时绝对已经穿过了该年的立春
    final safeDayInYear = SolarDay.fromYmd(daYunStartYear, 7, 1);

    // 因为 getEightChar() 只能在时辰对象上调用，把 SolarDay 转为 SolarTime 即可获取时辰
    final solarTime = SolarTime.fromYmdHms(safeDayInYear.getYear(),
        safeDayInYear.getMonth(), safeDayInYear.getDay(), 1, 0, 0);

    // 我们手动将 Tyme 的干支模型，转译为我们自已的高性能业务对象 JiaZi
    final firstYearJiaZiStr =
        solarTime.getLunarHour().getEightChar().getYear().getName();
    JiaZi currentYearPillar = JiaZi.getFromGanZhiValue(firstYearJiaZiStr)!;

    List<JiaZi> years = [currentYearPillar];

    // 后面的 N-1 年，我们不需要再调 tyme 库去反复创建类了，纯靠数学循环。
    for (int i = 1; i < durationYears; i++) {
      currentYearPillar = currentYearPillar.getNext(); // 瞬间计算 O(1)
      years.add(currentYearPillar);
    }

    return years;
  }

  @override
  List<JiaZi> getMonthsInYear({required JiaZi yearPillar}) {
    // 【五虎遁极速起月】：甲己之年丙作首...
    // 无论闰几月，一年严格只有 12 个命理月，正月必定是寅月。
    final firstMonthStem = _getWuHuDunStem(yearPillar.gan);
    JiaZi currentMonthPillar =
        JiaZi.getFromGanZhiEnum(firstMonthStem, DiZhi.YIN);

    List<JiaZi> months = [currentMonthPillar];

    for (int i = 1; i < 12; i++) {
      currentMonthPillar = currentMonthPillar.getNext();
      months.add(currentMonthPillar);
    }

    return months;
  }

  @override
  List<JiaZi> getDaysInMonth({
    required JiaZi monthPillar,
    required int solarYear,
    required int solarMonth,
  }) {
    // 【稳定性警告】：天干地支纪日法不可随意推演！
    // 因为历史大小月、闰年原因，每天连着走是正确的，但 "某年某月" 里包含哪几天的干支
    // 无法通过简单公式得知，必须依托于历法库查询这一个月的客观数据。

    final solarMonthObj = SolarMonth.fromYm(solarYear, solarMonth);
    final daysInThisMonth = solarMonthObj.getDays();

    List<JiaZi> dailyPillars = [];

    // 这里虽然有 30 次循环，但好在 SolarDay 获取日柱不涉及节气和太阳黄经运算，
    // 它仅是公元与儒略日的换算，性能非常快。
    for (var solarDay in daysInThisMonth) {
      final solarTime = SolarTime.fromYmdHms(
          solarDay.getYear(), solarDay.getMonth(), solarDay.getDay(), 1, 0, 0);
      // 拿到干支字符串后转为业务对象
      final ganZhiStr =
          solarTime.getLunarHour().getEightChar().getDay().getName();
      dailyPillars.add(JiaZi.getFromGanZhiValue(ganZhiStr)!);
    }

    return dailyPillars;
  }

  @override
  List<JiaZi> getHoursInDay({required JiaZi dayPillar}) {
    // 【五鼠遁极速起时】：甲己还加甲，乙庚丙作初...
    // 只要知道了是什么日，当天的子时一定能通过固定公式推出来。
    final firstHourStem = _getWuShuDunStem(dayPillar.gan);
    JiaZi currentHourPillar = JiaZi.getFromGanZhiEnum(firstHourStem, DiZhi.ZI);

    List<JiaZi> hours = [currentHourPillar];

    // 每天严格只有 12 个时辰
    for (int i = 1; i < 12; i++) {
      currentHourPillar = currentHourPillar.getNext();
      hours.add(currentHourPillar);
    }

    return hours;
  }

  // ================= 内部数学辅助函数 =================

  /// 五虎遁法（年上起月）
  /// [yearStem] 为流年的天干
  /// 计算公式：((年干序数 % 5) * 2 + 1) -> 可得出正月天干序数
  TianGan _getWuHuDunStem(TianGan yearStem) {
    // TianGan 中甲的 index=0。
    // 逻辑：甲,己(0,5)->丙(2) | 乙,庚(1,6)->戊(4) | 丙,辛(2,7)->庚(6) | 丁,壬(3,8)->壬(8) | 戊,癸(4,9)->甲(0)
    int yearIdx = yearStem.index;
    int baseGroup = yearIdx % 5;

    // 甲己: 丙(2); 乙庚: 戊(4); 丙辛: 庚(6); 丁壬: 壬(8); 戊癸: 甲(10->0)
    int targetMonthStemIdx = ((baseGroup + 1) * 2) % 10;

    return TianGan.values[targetMonthStemIdx];
  }

  /// 五鼠遁法（日上起时）
  /// [dayStem] 为流日的天干
  /// 计算公式：((日干序数 % 5) * 2) -> 可得出子时天干序数
  TianGan _getWuShuDunStem(TianGan dayStem) {
    // 逻辑：甲,己(0,5)->甲(0) | 乙,庚(1,6)->丙(2) | 丙,辛(2,7)->戊(4) | 丁,壬(3,8)->庚(6) | 戊,癸(4,9)->壬(8)
    int dayIdx = dayStem.index;
    int baseGroup = dayIdx % 5;

    int targetHourStemIdx = (baseGroup * 2) % 10;

    return TianGan.values[targetHourStemIdx];
  }
}

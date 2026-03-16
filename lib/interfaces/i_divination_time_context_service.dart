import 'package:common/models/chinese_date_info.dart';

import '../enums/enum_jia_zi.dart';

/// 命理排盘的基础时空流逝接口定义
///
/// 该接口用于为各大命理推演插件（八字引擎、铁板神数等）提供统一的、流派无关的
/// 流年、流月、流日、流时查询底座。
/// 核心思想是在给定有限的历法基底（如出生日期）前提下，大量复用“五虎遁”、“五鼠遁”等
/// 口诀极速推演干支时间序序列，而无需次次调用厚重的天文历算公式。
abstract interface class IDivinationTimeContextService {
  /// 提供出生时间（[seekerBirthTime]）与某大运的起始公历年份（[daYunStartYear]），
  /// 一次性拉取该柱大运中所有 **十年流年** 的基础干支组合。
  ///
  /// * `durationYears`: 该大运持续的年数，默认通常为 10 年
  ///
  /// 返回：十个流年按序排列的 JiaZi（干支）列表。
  List<JiaZi> getYearsInDaYun({
    required DateTime seekerBirthTime,
    required int daYunStartYear,
    required int durationYears, // 动态指定该大运的年数（通常为 10 年，部分派别为 9 年）
  });

  /// 传入特定一年的 **流年干支** ([yearPillar])，
  /// 根据“五虎遁（年上起月）”口诀，极速返回该年所有 **十二个月** 的基础流月干支。
  ///
  /// * 无论闰月与否，按传统干支历（节气历），一年严格有 12 个干支月。
  ///   （正月必为寅月，二月必为卯月，依次类推）。
  ///
  /// 参考口诀：甲己之年丙作首...
  ///
  /// 返回：十二个流月按序排列的 JiaZi 列表。
  List<JiaZi> getMonthsInYear({required JiaZi yearPillar});

  /// 传入特定一个月的 **流月干支** ([monthPillar]) 以及该月在公历（或农历）
  /// 中的起始与大概持续天数（通常在 29~31 之间），
  /// 返回该月内 **每一天** 的流日干支。
  ///
  /// * `solarYear`: 公历年份
  /// * `solarMonth`: 公历月份 (辅助如果底层需要查表或算节气截断的话)
  ///
  /// 返回：该月所有日子的 JiaZi 列表。
  List<JiaZi> getDaysInMonth({
    required JiaZi monthPillar,
    required int solarYear,
    required int solarMonth,
  });

  /// 传入特定一天的 **流日干支** ([dayPillar])，
  /// 根据“五鼠遁（日上起时）”口诀，极速返回该日所有 **十二个时辰** 的流时干支。
  ///
  /// * 传统十二时辰：子时到亥时。
  ///
  /// 参考口诀：甲己还加甲，乙庚丙作初...
  ///
  /// 返回：十二个时辰按序排列的 JiaZi 列表。
  List<JiaZi> getHoursInDay({required JiaZi dayPillar});
}

import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/enums/enum_tian_gan.dart';
import 'package:common/enums/enum_ten_gods.dart';

/// Display data for a single Liu-Yue (Monthly Luck) entry.
class LiuYueDisplayData {
  final String monthName; // e.g., '1月'
  final int gregorianMonth; // e.g. 2 for February
  final String ganZhi;
  final String tenGodName;
  final List<({String gan, String tenGod})> hidden;

  const LiuYueDisplayData({
    required this.monthName,
    required this.gregorianMonth,
    required this.ganZhi,
    required this.tenGodName,
    required this.hidden,
  });
}

/// Display data for a single Liu-Nian (Annual Luck) entry.
typedef LiuNianDisplayData = ({
  JiaZi pillar,
  EnumTenGods ganGod,
  List<({TianGan gan, EnumTenGods hiddenGods})> hiddenGans,
  int year,
  int age,
  List<LiuYueDisplayData> liuyue,
});

/// Display data for a single Da-Yun (Great Luck) period.
typedef DaYunDisplayData = ({
  JiaZi pillar,
  EnumTenGods ganGod,
  List<({TianGan gan, EnumTenGods hiddenGods})> hiddenGans,
  int startYear,
  int startAge,
  int yearsCount,
  List<LiuNianDisplayData> liunian,
});

class LiuRiDisplayData {
  final int gregorianYear;
  final int gregorianMonth;
  final int gregorianDay;
  final String ganZhi;
  final String tenGodName;
  final List<({String gan, String tenGod})> hidden;
  final String? jieQiName;
  final String lunarText;
  final bool isToday;

  const LiuRiDisplayData({
    required this.gregorianYear,
    required this.gregorianMonth,
    required this.gregorianDay,
    required this.ganZhi,
    required this.tenGodName,
    required this.hidden,
    this.jieQiName,
    required this.lunarText,
    required this.isToday,
  });
}

class LiuShiDisplayData {
  final int shiIdx;
  final String zhiTime;
  final String ganZhi;
  final String tenGodName;
  final List<({String gan, String tenGod})> hidden;
  final String? jieQiName;

  const LiuShiDisplayData({
    required this.shiIdx,
    required this.zhiTime,
    required this.ganZhi,
    required this.tenGodName,
    required this.hidden,
    this.jieQiName,
  });
}

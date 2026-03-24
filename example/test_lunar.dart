import 'package:tyme/tyme.dart';
void main() {
  final lunarDay = SolarDay.fromYmd(2023, 3, 23).getLunarDay();
  print("YEAR: " + lunarDay.getLunarMonth().getLunarYear().getName());
  print("MONTH: " + lunarDay.getLunarMonth().getName());
  print("DAY: " + lunarDay.getName());
}

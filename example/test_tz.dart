import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz.initializeTimeZones();
  try {
    var loc = tz.getLocation('Asia/Shanghai');
    print("Success: ${loc.name}");
  } catch (e) {
    print("Error: $e");
  }
}

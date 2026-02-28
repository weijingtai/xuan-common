import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tables.dart';

part 'divination_calendars_dao.g.dart';

@DriftAccessor(tables: [DivinationCalendars])
class DivinationCalendarsDao extends DatabaseAccessor<AppDatabase>
    with _$DivinationCalendarsDaoMixin {
  DivinationCalendarsDao(super.db);

  Future<int> insertCalendar(Insertable<DivinationCalendar> calendar) {
    return into(divinationCalendars).insert(calendar);
  }

  Future<List<DivinationCalendar>> getBySource(String sourceUuid) {
    return (select(divinationCalendars)
          ..where((t) => t.sourceUuid.equals(sourceUuid)))
        .get();
  }
}

import 'package:common/database/app_database.dart';
import 'package:drift/drift.dart';

class DivinationCalendarRepository {
  final AppDatabase db;

  DivinationCalendarRepository(this.db);

  Future<int> insert(Insertable<DivinationCalendar> calendar) {
    return db.divinationCalendarsDao.insertCalendar(calendar);
  }

  Future<List<DivinationCalendar>> queryBySourceUuid(String sourceUuid) {
    return db.divinationCalendarsDao.getBySource(sourceUuid);
  }

  Future<void> switchCurrentCalendar(
      String sourceUuid, String newCalendarUuid, String sourceType) async {
    // Needs transaction on db
    await db.transaction(() async {
      if (sourceType == 'seeker') {
        await (db.update(db.seekers)..where((t) => t.uuid.equals(sourceUuid)))
            .write(
                SeekersCompanion(currentCalendarUuid: Value(newCalendarUuid)));
      } else if (sourceType == 'timing_divination') {
        await (db.update(db.timingDivinations)
              ..where((t) => t.uuid.equals(sourceUuid)))
            .write(TimingDivinationsCompanion(
                currentCalendarUuid: Value(newCalendarUuid)));
      }
    });
  }
}

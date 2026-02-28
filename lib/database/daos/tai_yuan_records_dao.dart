import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tables.dart';

part 'tai_yuan_records_dao.g.dart';

@DriftAccessor(tables: [TaiYuanRecords])
class TaiYuanRecordsDao extends DatabaseAccessor<AppDatabase>
    with _$TaiYuanRecordsDaoMixin {
  TaiYuanRecordsDao(super.db);

  Future<int> insertRecord(Insertable<TaiYuanRecord> record) {
    return into(taiYuanRecords).insert(record);
  }

  Future<List<TaiYuanRecord>> getByCalendar(String calendarUuid) {
    return (select(taiYuanRecords)
          ..where((t) => t.calendarUuid.equals(calendarUuid)))
        .get();
  }
}

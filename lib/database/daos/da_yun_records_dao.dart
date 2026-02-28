import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tables.dart';

part 'da_yun_records_dao.g.dart';

@DriftAccessor(tables: [DaYunRecords])
class DaYunRecordsDao extends DatabaseAccessor<AppDatabase>
    with _$DaYunRecordsDaoMixin {
  DaYunRecordsDao(super.db);

  Future<int> insertRecord(Insertable<DaYunRecord> record) {
    return into(daYunRecords).insert(record);
  }

  Future<List<DaYunRecord>> getBySource(String sourceUuid) {
    return (select(daYunRecords)..where((t) => t.sourceUuid.equals(sourceUuid)))
        .get();
  }
}

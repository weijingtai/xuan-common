// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'divinations_dao.dart';

// ignore_for_file: type=lint
mixin _$DivinationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $DivinationTypesTable get divinationTypes => attachedDatabase.divinationTypes;
  $SeekersTable get seekers => attachedDatabase.seekers;
  $DivinationsTable get divinations => attachedDatabase.divinations;
  DivinationsDaoManager get managers => DivinationsDaoManager(this);
}

class DivinationsDaoManager {
  final _$DivinationsDaoMixin _db;
  DivinationsDaoManager(this._db);
  $$DivinationTypesTableTableManager get divinationTypes =>
      $$DivinationTypesTableTableManager(
          _db.attachedDatabase, _db.divinationTypes);
  $$SeekersTableTableManager get seekers =>
      $$SeekersTableTableManager(_db.attachedDatabase, _db.seekers);
  $$DivinationsTableTableManager get divinations =>
      $$DivinationsTableTableManager(_db.attachedDatabase, _db.divinations);
}

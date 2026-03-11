// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'region_dao.dart';

// ignore_for_file: type=lint
mixin _$RegionDaoMixin on DatabaseAccessor<WorldInfoDatabase> {
  $RegionsTable get regions => attachedDatabase.regions;
  RegionDaoManager get managers => RegionDaoManager(this);
}

class RegionDaoManager {
  final _$RegionDaoMixin _db;
  RegionDaoManager(this._db);
  $$RegionsTableTableManager get regions =>
      $$RegionsTableTableManager(_db.attachedDatabase, _db.regions);
}

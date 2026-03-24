// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subregion_dao.dart';

// ignore_for_file: type=lint
mixin _$SubregionDaoMixin on DatabaseAccessor<WorldInfoDatabase> {
  $RegionsTable get regions => attachedDatabase.regions;
  $SubregionsTable get subregions => attachedDatabase.subregions;
  SubregionDaoManager get managers => SubregionDaoManager(this);
}

class SubregionDaoManager {
  final _$SubregionDaoMixin _db;
  SubregionDaoManager(this._db);
  $$RegionsTableTableManager get regions =>
      $$RegionsTableTableManager(_db.attachedDatabase, _db.regions);
  $$SubregionsTableTableManager get subregions =>
      $$SubregionsTableTableManager(_db.attachedDatabase, _db.subregions);
}

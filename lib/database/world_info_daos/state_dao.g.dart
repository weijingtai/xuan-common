// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'state_dao.dart';

// ignore_for_file: type=lint
mixin _$StateDaoMixin on DatabaseAccessor<WorldInfoDatabase> {
  $RegionsTable get regions => attachedDatabase.regions;
  $SubregionsTable get subregions => attachedDatabase.subregions;
  $CountriesTable get countries => attachedDatabase.countries;
  $StatesTable get states => attachedDatabase.states;
  StateDaoManager get managers => StateDaoManager(this);
}

class StateDaoManager {
  final _$StateDaoMixin _db;
  StateDaoManager(this._db);
  $$RegionsTableTableManager get regions =>
      $$RegionsTableTableManager(_db.attachedDatabase, _db.regions);
  $$SubregionsTableTableManager get subregions =>
      $$SubregionsTableTableManager(_db.attachedDatabase, _db.subregions);
  $$CountriesTableTableManager get countries =>
      $$CountriesTableTableManager(_db.attachedDatabase, _db.countries);
  $$StatesTableTableManager get states =>
      $$StatesTableTableManager(_db.attachedDatabase, _db.states);
}

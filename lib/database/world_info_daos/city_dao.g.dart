// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_dao.dart';

// ignore_for_file: type=lint
mixin _$CityDaoMixin on DatabaseAccessor<WorldInfoDatabase> {
  $RegionsTable get regions => attachedDatabase.regions;
  $SubregionsTable get subregions => attachedDatabase.subregions;
  $CountriesTable get countries => attachedDatabase.countries;
  $StatesTable get states => attachedDatabase.states;
  $CitiesTable get cities => attachedDatabase.cities;
  CityDaoManager get managers => CityDaoManager(this);
}

class CityDaoManager {
  final _$CityDaoMixin _db;
  CityDaoManager(this._db);
  $$RegionsTableTableManager get regions =>
      $$RegionsTableTableManager(_db.attachedDatabase, _db.regions);
  $$SubregionsTableTableManager get subregions =>
      $$SubregionsTableTableManager(_db.attachedDatabase, _db.subregions);
  $$CountriesTableTableManager get countries =>
      $$CountriesTableTableManager(_db.attachedDatabase, _db.countries);
  $$StatesTableTableManager get states =>
      $$StatesTableTableManager(_db.attachedDatabase, _db.states);
  $$CitiesTableTableManager get cities =>
      $$CitiesTableTableManager(_db.attachedDatabase, _db.cities);
}

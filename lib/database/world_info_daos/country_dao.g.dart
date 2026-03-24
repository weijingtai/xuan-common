// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_dao.dart';

// ignore_for_file: type=lint
mixin _$CountryDaoMixin on DatabaseAccessor<WorldInfoDatabase> {
  $RegionsTable get regions => attachedDatabase.regions;
  $SubregionsTable get subregions => attachedDatabase.subregions;
  $CountriesTable get countries => attachedDatabase.countries;
  CountryDaoManager get managers => CountryDaoManager(this);
}

class CountryDaoManager {
  final _$CountryDaoMixin _db;
  CountryDaoManager(this._db);
  $$RegionsTableTableManager get regions =>
      $$RegionsTableTableManager(_db.attachedDatabase, _db.regions);
  $$SubregionsTableTableManager get subregions =>
      $$SubregionsTableTableManager(_db.attachedDatabase, _db.subregions);
  $$CountriesTableTableManager get countries =>
      $$CountriesTableTableManager(_db.attachedDatabase, _db.countries);
}

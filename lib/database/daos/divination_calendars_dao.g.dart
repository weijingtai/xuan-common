// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'divination_calendars_dao.dart';

// ignore_for_file: type=lint
mixin _$DivinationCalendarsDaoMixin on DatabaseAccessor<AppDatabase> {
  $DivinationCalendarsTable get divinationCalendars =>
      attachedDatabase.divinationCalendars;
  DivinationCalendarsDaoManager get managers =>
      DivinationCalendarsDaoManager(this);
}

class DivinationCalendarsDaoManager {
  final _$DivinationCalendarsDaoMixin _db;
  DivinationCalendarsDaoManager(this._db);
  $$DivinationCalendarsTableTableManager get divinationCalendars =>
      $$DivinationCalendarsTableTableManager(
          _db.attachedDatabase, _db.divinationCalendars);
}

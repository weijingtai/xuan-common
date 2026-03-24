// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skills_dao.dart';

// ignore_for_file: type=lint
mixin _$SkillsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SkillsTable get skills => attachedDatabase.skills;
  SkillsDaoManager get managers => SkillsDaoManager(this);
}

class SkillsDaoManager {
  final _$SkillsDaoMixin _db;
  SkillsDaoManager(this._db);
  $$SkillsTableTableManager get skills =>
      $$SkillsTableTableManager(_db.attachedDatabase, _db.skills);
}

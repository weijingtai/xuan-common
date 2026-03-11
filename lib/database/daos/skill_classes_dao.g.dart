// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_classes_dao.dart';

// ignore_for_file: type=lint
mixin _$SkillClassesDaoMixin on DatabaseAccessor<AppDatabase> {
  $SkillsTable get skills => attachedDatabase.skills;
  $SkillClassesTable get skillClasses => attachedDatabase.skillClasses;
  SkillClassesDaoManager get managers => SkillClassesDaoManager(this);
}

class SkillClassesDaoManager {
  final _$SkillClassesDaoMixin _db;
  SkillClassesDaoManager(this._db);
  $$SkillsTableTableManager get skills =>
      $$SkillsTableTableManager(_db.attachedDatabase, _db.skills);
  $$SkillClassesTableTableManager get skillClasses =>
      $$SkillClassesTableTableManager(_db.attachedDatabase, _db.skillClasses);
}

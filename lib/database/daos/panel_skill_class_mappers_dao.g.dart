// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panel_skill_class_mappers_dao.dart';

// ignore_for_file: type=lint
mixin _$PanelSkillClassMappersDaoMixin on DatabaseAccessor<AppDatabase> {
  $SkillsTable get skills => attachedDatabase.skills;
  $PanelsTable get panels => attachedDatabase.panels;
  $SkillClassesTable get skillClasses => attachedDatabase.skillClasses;
  $PanelSkillClassMappersTable get panelSkillClassMappers =>
      attachedDatabase.panelSkillClassMappers;
  PanelSkillClassMappersDaoManager get managers =>
      PanelSkillClassMappersDaoManager(this);
}

class PanelSkillClassMappersDaoManager {
  final _$PanelSkillClassMappersDaoMixin _db;
  PanelSkillClassMappersDaoManager(this._db);
  $$SkillsTableTableManager get skills =>
      $$SkillsTableTableManager(_db.attachedDatabase, _db.skills);
  $$PanelsTableTableManager get panels =>
      $$PanelsTableTableManager(_db.attachedDatabase, _db.panels);
  $$SkillClassesTableTableManager get skillClasses =>
      $$SkillClassesTableTableManager(_db.attachedDatabase, _db.skillClasses);
  $$PanelSkillClassMappersTableTableManager get panelSkillClassMappers =>
      $$PanelSkillClassMappersTableTableManager(
          _db.attachedDatabase, _db.panelSkillClassMappers);
}

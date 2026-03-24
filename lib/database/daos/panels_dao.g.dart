// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panels_dao.dart';

// ignore_for_file: type=lint
mixin _$PanelsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SkillsTable get skills => attachedDatabase.skills;
  $PanelsTable get panels => attachedDatabase.panels;
  PanelsDaoManager get managers => PanelsDaoManager(this);
}

class PanelsDaoManager {
  final _$PanelsDaoMixin _db;
  PanelsDaoManager(this._db);
  $$SkillsTableTableManager get skills =>
      $$SkillsTableTableManager(_db.attachedDatabase, _db.skills);
  $$PanelsTableTableManager get panels =>
      $$PanelsTableTableManager(_db.attachedDatabase, _db.panels);
}

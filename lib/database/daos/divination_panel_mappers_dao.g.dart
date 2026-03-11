// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'divination_panel_mappers_dao.dart';

// ignore_for_file: type=lint
mixin _$DivinationPanelMappersDaoMixin on DatabaseAccessor<AppDatabase> {
  $DivinationTypesTable get divinationTypes => attachedDatabase.divinationTypes;
  $SeekersTable get seekers => attachedDatabase.seekers;
  $DivinationsTable get divinations => attachedDatabase.divinations;
  $SkillsTable get skills => attachedDatabase.skills;
  $PanelsTable get panels => attachedDatabase.panels;
  $DivinationPanelMappersTable get divinationPanelMappers =>
      attachedDatabase.divinationPanelMappers;
  DivinationPanelMappersDaoManager get managers =>
      DivinationPanelMappersDaoManager(this);
}

class DivinationPanelMappersDaoManager {
  final _$DivinationPanelMappersDaoMixin _db;
  DivinationPanelMappersDaoManager(this._db);
  $$DivinationTypesTableTableManager get divinationTypes =>
      $$DivinationTypesTableTableManager(
          _db.attachedDatabase, _db.divinationTypes);
  $$SeekersTableTableManager get seekers =>
      $$SeekersTableTableManager(_db.attachedDatabase, _db.seekers);
  $$DivinationsTableTableManager get divinations =>
      $$DivinationsTableTableManager(_db.attachedDatabase, _db.divinations);
  $$SkillsTableTableManager get skills =>
      $$SkillsTableTableManager(_db.attachedDatabase, _db.skills);
  $$PanelsTableTableManager get panels =>
      $$PanelsTableTableManager(_db.attachedDatabase, _db.panels);
  $$DivinationPanelMappersTableTableManager get divinationPanelMappers =>
      $$DivinationPanelMappersTableTableManager(
          _db.attachedDatabase, _db.divinationPanelMappers);
}

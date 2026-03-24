import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../enums/enum_gender.dart';
import '../../enums/enum_jia_zi.dart';
import '../../enums/layout_template_enums.dart';
import '../../models/drag_payloads.dart';
import '../../models/eight_chars.dart';
import '../../models/layout_template.dart';
import '../../models/pillar_content.dart';
import '../../models/text_style_config.dart';
import '../../themes/editable_four_zhu_card_theme.dart';
import '../four_zhu_card/widgets/editable_fourzhu_card/models/base_style_config.dart';

class FourZhuCardThemeOption {
  const FourZhuCardThemeOption({required this.templateId, required this.label});

  final String templateId;
  final String label;
}

class FourZhuCardResolvedState {
  const FourZhuCardResolvedState({
    required this.theme,
    required this.padding,
    required this.payload,
    required this.toggleableRows,
  });

  final EditableFourZhuCardTheme theme;
  final EdgeInsets padding;
  final CardPayload payload;
  final Set<RowType> toggleableRows;
}

class FourZhuCardHostResolver {
  FourZhuCardHostResolver._();

  static const Set<RowType> _structuralRows = <RowType>{
    RowType.columnHeaderRow,
    RowType.heavenlyStem,
    RowType.earthlyBranch,
    RowType.separator,
  };

  static final Uuid _uuid = const Uuid();

  static List<FourZhuCardThemeOption> buildThemeOptions(
    List<LayoutTemplate> templates,
  ) {
    return templates
        .map(
          (template) => FourZhuCardThemeOption(
            templateId: template.id,
            label: template.name,
          ),
        )
        .toList(growable: false);
  }

  static Set<RowType> collectToggleableRows(LayoutTemplate template) {
    return template.rowConfigs
        .where((config) => config.isVisible && isRuntimeToggleable(config.type))
        .map((config) => config.type)
        .toSet();
  }

  static bool isRuntimeToggleable(RowType type) =>
      !_structuralRows.contains(type);

  static String rowLabelFor(RowType type) => _rowLabel(type);

  static FourZhuCardResolvedState resolve({
    required LayoutTemplate template,
    required EightChars eightChars,
    required Gender gender,
    Set<RowType>? visibleRowsOverride,
  }) {
    final toggleableRows = collectToggleableRows(template);
    final effectiveVisibleRows =
        visibleRowsOverride == null || visibleRowsOverride.isEmpty
        ? toggleableRows
        : visibleRowsOverride.intersection(toggleableRows);

    final payload = _applyTemplateToPayload(
      template: template,
      payload: _buildDefaultCardPayload(eightChars: eightChars, gender: gender),
      effectiveVisibleRows: effectiveVisibleRows,
    );
    final theme = _resolveTheme(template);
    return FourZhuCardResolvedState(
      theme: theme,
      padding: theme.card.padding,
      payload: payload,
      toggleableRows: toggleableRows,
    );
  }

  static EditableFourZhuCardTheme _resolveTheme(LayoutTemplate template) {
    final rawTheme = template.editableTheme;
    var nextTheme = EditableCardThemeBuilder.createDefaultTheme();

    if (rawTheme != null) {
      try {
        nextTheme = EditableFourZhuCardTheme.fromJson(rawTheme);
      } catch (_) {}
    }

    final cardStyle = template.cardStyle;
    if (nextTheme.card.padding != cardStyle.contentPadding) {
      nextTheme = nextTheme.copyWith(
        card: nextTheme.card.copyWith(padding: cardStyle.contentPadding),
      );
    }

    final currentBorder = nextTheme.card.border;
    final targetColor = _parseColor(cardStyle.dividerColorHex);
    final targetEnabled = cardStyle.dividerType != BorderType.none;
    if (currentBorder == null ||
        currentBorder.width != cardStyle.dividerThickness ||
        currentBorder.lightColor != targetColor ||
        currentBorder.enabled != targetEnabled) {
      nextTheme = nextTheme.copyWith(
        card: nextTheme.card.copyWith(
          border:
              (currentBorder ??
                      BoxBorderStyle(
                        enabled: true,
                        width: 1,
                        lightColor: Colors.black,
                        darkColor: Colors.white,
                        radius: 0,
                      ))
                  .copyWith(
                    width: cardStyle.dividerThickness,
                    lightColor: targetColor,
                    enabled: targetEnabled,
                  ),
        ),
      );
    }

    final family = cardStyle.globalFontFamily.trim().isEmpty
        ? 'System'
        : cardStyle.globalFontFamily;
    final size = cardStyle.globalFontSize;
    var typography = nextTheme.typography;
    final currentFont = typography.globalContent.fontStyleDataModel;
    if (currentFont.fontFamily != family || currentFont.fontSize != size) {
      typography = typography.copyWith(
        globalContent: typography.globalContent.copyWith(
          fontStyleDataModel: currentFont.copyWith(
            fontFamily: family,
            fontSize: size,
          ),
        ),
      );
    }

    final mapper = Map<RowType, TextStyleConfig>.of(
      typography.cellContentMapper,
    );
    var mapperChanged = false;
    for (final config in template.rowConfigs) {
      if (mapper[config.type] != config.textStyleConfig) {
        mapper[config.type] = config.textStyleConfig;
        mapperChanged = true;
      }
    }
    if (mapperChanged) {
      typography = typography.copyWith(cellContentMapper: mapper);
    }

    return nextTheme.copyWith(typography: typography);
  }

  static CardPayload _applyTemplateToPayload({
    required LayoutTemplate template,
    required CardPayload payload,
    required Set<RowType> effectiveVisibleRows,
  }) {
    final typeToUuidMap = <RowType, String>{};
    payload.rowMap.forEach((uuid, rowPayload) {
      if (rowPayload is TextRowPayload) {
        typeToUuidMap[rowPayload.rowType] = uuid;
      }
    });

    final newRowMap = Map<String, RowPayload>.from(payload.rowMap);
    final newRowOrder = <String>[];
    for (final config in template.rowConfigs) {
      if (!config.isVisible) continue;
      if (isRuntimeToggleable(config.type) &&
          !effectiveVisibleRows.contains(config.type)) {
        continue;
      }

      final type = config.type;
      if (type == RowType.separator) {
        final uuid = _uuid.v4();
        newRowMap[uuid] = RowSeparatorPayload(uuid: uuid);
        newRowOrder.add(uuid);
        continue;
      }

      final existingUuid = typeToUuidMap[type];
      if (existingUuid != null) {
        newRowOrder.add(existingUuid);
        final existing = newRowMap[existingUuid];
        if (existing is TextRowPayload) {
          newRowMap[existingUuid] = existing.copyWith(
            titleInCell: !config.isTitleVisible,
            tenGodLabelType: config.tenGodLabelType,
          );
        }
        continue;
      }

      final uuid = _uuid.v4();
      if (type == RowType.columnHeaderRow) {
        newRowMap[uuid] = ColumnHeaderRowPayload(
          gender: payload.gender,
          uuid: uuid,
        );
      } else {
        newRowMap[uuid] = TextRowPayload(
          rowType: type,
          rowLabel: _rowLabel(type),
          uuid: uuid,
          titleInCell: !config.isTitleVisible,
          tenGodLabelType: config.tenGodLabelType,
        );
      }
      newRowOrder.add(uuid);
    }

    final pillarTypeToUuidMap = <PillarType, String>{};
    payload.pillarMap.forEach((uuid, pillarPayload) {
      pillarTypeToUuidMap[pillarPayload.pillarType] = uuid;
    });
    final newPillarMap = Map<String, PillarPayload>.from(payload.pillarMap);
    final newPillarOrder = <String>[];
    for (final group in template.chartGroups) {
      for (final type in group.pillarOrder) {
        var uuid = pillarTypeToUuidMap[type];
        if (uuid == null) {
          uuid = _uuid.v4();
          newPillarMap[uuid] = _createPillarPayload(type, uuid);
        }
        newPillarOrder.add(uuid);
      }
    }

    return payload.copyWith(
      rowMap: newRowMap,
      rowOrderUuid: newRowOrder,
      pillarMap: newPillarMap,
      pillarOrderUuid: newPillarOrder,
    );
  }

  static CardPayload _buildDefaultCardPayload({
    required EightChars eightChars,
    required Gender gender,
  }) {
    final yearUuid = _uuid.v4();
    final monthUuid = _uuid.v4();
    final dayUuid = _uuid.v4();
    final hourUuid = _uuid.v4();
    final heavenlyStemUuid = _uuid.v4();
    final earthlyBranchUuid = _uuid.v4();
    final naYinUuid = _uuid.v4();
    final kongWangUuid = _uuid.v4();
    final tenGodUuid = _uuid.v4();

    return CardPayload(
      gender: gender,
      pillarMap: {
        yearUuid: _contentPillar(
          uuid: yearUuid,
          pillarType: PillarType.year,
          label: '年',
          jiaZi: eightChars.year,
        ),
        monthUuid: _contentPillar(
          uuid: monthUuid,
          pillarType: PillarType.month,
          label: '月',
          jiaZi: eightChars.month,
        ),
        dayUuid: _contentPillar(
          uuid: dayUuid,
          pillarType: PillarType.day,
          label: '日',
          jiaZi: eightChars.day,
        ),
        hourUuid: _contentPillar(
          uuid: hourUuid,
          pillarType: PillarType.hour,
          label: '时',
          jiaZi: eightChars.time,
        ),
      },
      pillarOrderUuid: [yearUuid, monthUuid, dayUuid, hourUuid],
      rowMap: {
        tenGodUuid: TextRowPayload(
          rowType: RowType.tenGod,
          rowLabel: '十神',
          uuid: tenGodUuid,
          titleInCell: false,
        ),
        heavenlyStemUuid: TextRowPayload(
          rowType: RowType.heavenlyStem,
          rowLabel: '天干',
          uuid: heavenlyStemUuid,
          titleInCell: false,
        ),
        earthlyBranchUuid: TextRowPayload(
          rowType: RowType.earthlyBranch,
          rowLabel: '地支',
          uuid: earthlyBranchUuid,
          titleInCell: false,
        ),
        naYinUuid: TextRowPayload(
          rowType: RowType.naYin,
          rowLabel: '纳音',
          uuid: naYinUuid,
          titleInCell: false,
        ),
        kongWangUuid: TextRowPayload(
          rowType: RowType.kongWang,
          rowLabel: '空亡',
          uuid: kongWangUuid,
          titleInCell: false,
        ),
      },
      rowOrderUuid: [
        tenGodUuid,
        heavenlyStemUuid,
        earthlyBranchUuid,
        naYinUuid,
        kongWangUuid,
      ],
    );
  }

  static ContentPillarPayload _contentPillar({
    required String uuid,
    required PillarType pillarType,
    required String label,
    required JiaZi jiaZi,
  }) {
    return ContentPillarPayload(
      uuid: uuid,
      pillarLabel: label,
      pillarType: pillarType,
      pillarContent: PillarContent(
        id: 'pillar-$uuid',
        pillarType: pillarType,
        label: label,
        jiaZi: jiaZi,
        description: '四柱宿主柱',
        version: '1',
        sourceKind: PillarSourceKind.userInput,
      ),
    );
  }

  static PillarPayload _createPillarPayload(PillarType type, String uuid) {
    if (type == PillarType.rowTitleColumn) {
      return RowTitleColumnPayload(uuid: uuid);
    }
    if (type == PillarType.separator) {
      return SeparatorPillarPayload(uuid: uuid);
    }
    return ContentPillarPayload(
      uuid: uuid,
      pillarLabel: _pillarLabel(type),
      pillarType: type,
      pillarContent: PillarContent(
        id: 'pillar-$uuid',
        pillarType: type,
        label: _pillarLabel(type),
        jiaZi: JiaZi.JIA_ZI,
        description: '占位柱',
        version: '1',
        sourceKind: PillarSourceKind.userInput,
      ),
    );
  }

  static Color _parseColor(String hex) {
    var value = hex.trim().toUpperCase();
    if (value.startsWith('0X')) value = value.substring(2);
    if (value.startsWith('#')) value = value.substring(1);
    if (value.length == 6) value = 'FF$value';
    return Color(int.tryParse(value, radix: 16) ?? 0xFF000000);
  }

  static String _pillarLabel(PillarType type) {
    switch (type) {
      case PillarType.year:
        return '年';
      case PillarType.month:
        return '月';
      case PillarType.day:
        return '日';
      case PillarType.hour:
        return '时';
      default:
        return type.name;
    }
  }

  static String _rowLabel(RowType type) {
    switch (type) {
      case RowType.tenGod:
        return '十神';
      case RowType.heavenlyStem:
        return '天干';
      case RowType.earthlyBranch:
        return '地支';
      case RowType.naYin:
        return '纳音';
      case RowType.kongWang:
        return '空亡';
      case RowType.gu:
        return '孤';
      case RowType.xu:
        return '虚';
      case RowType.xunShou:
        return '旬首';
      case RowType.yiMa:
        return '驿马';
      case RowType.hiddenStems:
        return '藏干';
      case RowType.hiddenStemsTenGod:
        return '藏干十神';
      case RowType.hiddenStemsPrimary:
        return '藏干(主)';
      case RowType.hiddenStemsSecondary:
        return '藏干(中)';
      case RowType.hiddenStemsTertiary:
        return '藏干(余)';
      case RowType.hiddenStemsPrimaryGods:
        return '藏干十神(主)';
      case RowType.hiddenStemsSecondaryGods:
        return '藏干十神(中)';
      case RowType.hiddenStemsTertiaryGods:
        return '藏干十神(余)';
      case RowType.starYun:
        return '星运';
      case RowType.selfSiting:
        return '自坐';
      case RowType.columnHeaderRow:
        return '表头';
      case RowType.separator:
        return '分隔';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:xuan_four_zhu_card/enums/enum_gender.dart' as card_pkg;
import 'package:xuan_four_zhu_card/enums/layout_template_enums.dart'
    as card_layout;
import 'package:xuan_four_zhu_card/models/eight_chars.dart' as card_models;
import 'package:xuan_four_zhu_host/xuan_four_zhu_host.dart' as host_pkg;

import '../../enums/enum_gender.dart';
import '../../enums/layout_template_enums.dart';
import '../../models/drag_payloads.dart';
import '../../models/eight_chars.dart';
import '../../models/layout_template.dart';
import '../../themes/editable_four_zhu_card_theme.dart';

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

  static List<FourZhuCardThemeOption> buildThemeOptions(
    List<LayoutTemplate> templates,
  ) {
    return host_pkg.FourZhuCardHostResolver.buildThemeOptions(templates)
        .map(
          (item) =>
              FourZhuCardThemeOption(templateId: item.templateId, label: item.label),
        )
        .toList(growable: false);
  }

  static Set<RowType> collectToggleableRows(LayoutTemplate template) {
    return host_pkg.FourZhuCardHostResolver.collectToggleableRows(template)
        .map(_rowTypeFromCard)
        .toSet();
  }

  static bool isRuntimeToggleable(RowType type) =>
      host_pkg.FourZhuCardHostResolver.isRuntimeToggleable(_rowTypeToCard(type));

  static String rowLabelFor(RowType type) =>
      host_pkg.FourZhuCardHostResolver.rowLabelFor(_rowTypeToCard(type));

  static FourZhuCardResolvedState resolve({
    required LayoutTemplate template,
    required EightChars eightChars,
    required Gender gender,
    Set<RowType>? visibleRowsOverride,
  }) {
    final resolved = host_pkg.FourZhuCardHostResolver.resolve(
      template: template,
      eightChars: card_models.EightChars.fromJson(eightChars.toJson()),
      gender: _genderToCard(gender),
      visibleRowsOverride: visibleRowsOverride
          ?.map(_rowTypeToCard)
          .toSet(),
    );

    return FourZhuCardResolvedState(
      theme: EditableFourZhuCardTheme.fromJson(resolved.theme.toJson()),
      padding: resolved.padding,
      payload: CardPayload.fromJson(resolved.payload.toJson()),
      toggleableRows: resolved.toggleableRows.map(_rowTypeFromCard).toSet(),
    );
  }

  static card_pkg.Gender _genderToCard(Gender value) =>
      card_pkg.Gender.values.byName(value.name);

  static card_layout.RowType _rowTypeToCard(RowType value) =>
      card_layout.RowType.values.byName(value.name);

  static RowType _rowTypeFromCard(card_layout.RowType value) =>
      RowType.values.byName(value.name);
}

import 'package:common/enums/enum_gender.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/features/four_zhu_card_host/four_zhu_card_host_resolver.dart';
import 'package:common/models/eight_chars.dart';
import 'package:common/models/layout_template.dart';
import 'package:common/models/text_style_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  LayoutTemplate buildTemplate() {
    return LayoutTemplate(
      id: 'theme-a',
      name: '墨色',
      collectionId: 'four_zhu_templates',
      cardStyle: const CardStyle(
        dividerType: BorderType.solid,
        dividerColorHex: '#FF112233',
        dividerThickness: 2,
        globalFontFamily: 'NotoSansSC-Regular',
        globalFontSize: 16,
        globalFontColorHex: '#FF000000',
        contentPadding: EdgeInsets.all(18),
      ),
      chartGroups: [
        ChartGroup(
          id: 'g1',
          title: '四柱',
          pillarOrder: const [
            PillarType.rowTitleColumn,
            PillarType.year,
            PillarType.month,
            PillarType.day,
            PillarType.hour,
          ],
        ),
      ],
      rowConfigs: [
        RowConfig(
          type: RowType.columnHeaderRow,
          isVisible: true,
          isTitleVisible: false,
          textStyleConfig: TextStyleConfig.defaultConfig,
        ),
        RowConfig(
          type: RowType.heavenlyStem,
          isVisible: true,
          isTitleVisible: true,
          textStyleConfig: TextStyleConfig.defaultGanConfig,
        ),
        RowConfig(
          type: RowType.earthlyBranch,
          isVisible: true,
          isTitleVisible: true,
          textStyleConfig: TextStyleConfig.defaultZhiConfig,
        ),
        RowConfig(
          type: RowType.naYin,
          isVisible: true,
          isTitleVisible: true,
          textStyleConfig: TextStyleConfig.defaultConfig,
        ),
        RowConfig(
          type: RowType.kongWang,
          isVisible: true,
          isTitleVisible: true,
          textStyleConfig: TextStyleConfig.defaultConfig,
        ),
        RowConfig(
          type: RowType.separator,
          isVisible: true,
          isTitleVisible: false,
          textStyleConfig: TextStyleConfig.defaultConfig,
        ),
        RowConfig(
          type: RowType.xunShou,
          isVisible: true,
          isTitleVisible: true,
          textStyleConfig: TextStyleConfig.defaultConfig,
        ),
      ],
      updatedAt: DateTime.utc(2026, 1, 1),
    );
  }

  final eightChars = EightChars(
    year: JiaZi.JIA_ZI,
    month: JiaZi.YI_CHOU,
    day: JiaZi.BING_YIN,
    time: JiaZi.DING_MAO,
  );

  test('collects only runtime-toggleable visible rows', () {
    final rows = FourZhuCardHostResolver.collectToggleableRows(buildTemplate());
    expect(rows, contains(RowType.naYin));
    expect(rows, contains(RowType.kongWang));
    expect(rows, contains(RowType.xunShou));
    expect(rows, isNot(contains(RowType.heavenlyStem)));
    expect(rows, isNot(contains(RowType.columnHeaderRow)));
    expect(rows, isNot(contains(RowType.separator)));
  });

  test(
    'applies runtime visible-row override without removing structural rows',
    () {
      final resolved = FourZhuCardHostResolver.resolve(
        template: buildTemplate(),
        eightChars: eightChars,
        gender: Gender.male,
        visibleRowsOverride: const {RowType.kongWang},
      );

      final rowTypes = resolved.payload.rowOrderUuid
          .map((uuid) => resolved.payload.rowMap[uuid]!.rowType)
          .toList();

      expect(rowTypes, contains(RowType.columnHeaderRow));
      expect(rowTypes, contains(RowType.heavenlyStem));
      expect(rowTypes, contains(RowType.earthlyBranch));
      expect(rowTypes, contains(RowType.kongWang));
      expect(rowTypes, isNot(contains(RowType.naYin)));
      expect(rowTypes, isNot(contains(RowType.xunShou)));
    },
  );

  test('builds theme options from template collection', () {
    final options = FourZhuCardHostResolver.buildThemeOptions([
      buildTemplate(),
      buildTemplate().copyWith(id: 'theme-b', name: '朱砂'),
    ]);
    expect(options.map((item) => item.templateId), ['theme-a', 'theme-b']);
    expect(options.map((item) => item.label), ['墨色', '朱砂']);
  });
}

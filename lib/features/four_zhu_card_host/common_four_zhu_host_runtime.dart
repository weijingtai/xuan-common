import 'package:xuan_four_zhu_card/enums/enum_gender.dart' as card_gender;
import 'package:xuan_four_zhu_card/enums/enum_jia_zi.dart' as card_jiazi;
import 'package:xuan_four_zhu_card/enums.dart' as card_enums;
import 'package:xuan_four_zhu_card/models/pillar_content.dart' as card_pillar;
import 'package:xuan_four_zhu_card/models/row_strategy.dart' as card_strategy;
import 'package:xuan_four_zhu_host/xuan_four_zhu_host.dart' as host_pkg;
import 'package:xuan_four_zhu_templates/models/layout_template.dart';

import '../../enums/enum_gender.dart';
import '../../enums/enum_jia_zi.dart';
import '../../enums/layout_template_enums.dart';
import '../../models/pillar_content.dart';
import '../../models/row_strategy.dart';
import '../../viewmodels/four_zhu_editor_view_model.dart';

class CommonFourZhuHostRuntime implements host_pkg.FourZhuHostRuntime {
  CommonFourZhuHostRuntime(this.viewModel);

  final FourZhuEditorViewModel viewModel;

  @override
  List<LayoutTemplate> get templates => viewModel.templates;

  @override
  LayoutTemplate? get currentTemplate => viewModel.currentTemplate;

  @override
  Map<card_enums.RowType, card_strategy.RowComputationStrategy>
      get rowStrategyMapper => _adaptRowStrategyMapper(viewModel.rowStrategyMapper);

  @override
  Map<card_enums.PillarType, card_strategy.PillarComputationStrategy>
      get pillarStrategyMapper =>
          _adaptPillarStrategyMapper(viewModel.pillarStrategyMapper);

  @override
  Future<void> initialize({
    required String collectionId,
    String? initialTemplateId,
  }) {
    return viewModel.initialize(
      collectionId: collectionId,
      initialTemplateId: initialTemplateId,
    );
  }

  @override
  Future<void> refresh() => viewModel.refreshTemplates();

  @override
  Future<void> selectTemplate(
    String templateId, {
    String? source,
  }) {
    return viewModel.selectTemplate(templateId, source: source ?? 'host_runtime');
  }

  @override
  void addListener(void Function() listener) => viewModel.addListener(listener);

  @override
  void removeListener(void Function() listener) =>
      viewModel.removeListener(listener);

  @override
  void dispose() => viewModel.dispose();
}

Map<card_enums.RowType, card_strategy.RowComputationStrategy>
    _adaptRowStrategyMapper(
  Map<RowType, RowComputationStrategy> source,
) {
  return source.map(
    (key, value) => MapEntry(
      card_enums.RowType.values.byName(key.name),
      _CommonToCardRowStrategyAdapter(value),
    ),
  );
}

Map<card_enums.PillarType, card_strategy.PillarComputationStrategy>
    _adaptPillarStrategyMapper(
  Map<PillarType, PillarComputationStrategy> source,
) {
  return source.map(
    (key, value) => MapEntry(
      card_enums.PillarType.values.byName(key.name),
      _CommonToCardPillarStrategyAdapter(value),
    ),
  );
}

class _CommonToCardRowStrategyAdapter
    implements card_strategy.RowComputationStrategy {
  const _CommonToCardRowStrategyAdapter(this.delegate);

  final RowComputationStrategy delegate;

  @override
  card_enums.RowType get rowType =>
      card_enums.RowType.values.byName(delegate.rowType.name);

  @override
  String get defaultLabel => delegate.defaultLabel;

  @override
  card_strategy.RowComputationResult compute(
    card_strategy.RowComputationInput input,
  ) {
    final result = delegate.compute(
      RowComputationInput(
        pillars: input.pillars.map(_pillarToCommon).toList(growable: false),
        dayJiaZi: _jiaZiToCommon(input.dayJiaZi),
        gender: _genderToCommon(input.gender),
        isShortName: input.isShortName,
        referenceDateTime: input.referenceDateTime,
        context: input.context,
      ),
    );
    return card_strategy.RowComputationResult(
      rowType: card_enums.RowType.values.byName(result.rowType.name),
      rowLabel: result.rowLabel,
      perPillarValues: result.perPillarValues,
    );
  }

  @override
  String computeSingleValue(
    card_jiazi.JiaZi pillarJiaZi,
    card_jiazi.JiaZi dayJiaZi,
    card_gender.Gender gender,
  ) {
    return delegate.computeSingleValue(
      _jiaZiToCommon(pillarJiaZi),
      _jiaZiToCommon(dayJiaZi),
      _genderToCommon(gender),
    );
  }
}

class _CommonToCardPillarStrategyAdapter
    implements card_strategy.PillarComputationStrategy {
  const _CommonToCardPillarStrategyAdapter(this.delegate);

  final PillarComputationStrategy delegate;

  @override
  card_enums.PillarType get pillarType =>
      card_enums.PillarType.values.byName(delegate.pillarType.name);

  @override
  String get defaultLabel => delegate.defaultLabel;

  @override
  card_strategy.PillarComputationResult compute(
    card_strategy.PillarComputationInput input,
  ) {
    final result = delegate.compute(
      PillarComputationInput(
        pillar: _pillarToCommon(input.pillar),
        pillars: input.pillars.map(_pillarToCommon).toList(growable: false),
        dayJiaZi: _jiaZiToCommon(input.dayJiaZi),
        gender: _genderToCommon(input.gender),
        isShortName: input.isShortName,
        referenceDateTime: input.referenceDateTime,
        context: input.context,
      ),
    );
    return card_strategy.PillarComputationResult(
      pillarType: card_enums.PillarType.values.byName(result.pillarType.name),
      pillarLabel: result.pillarLabel,
      perRowValues: result.perRowValues.map(
        (key, value) => MapEntry(
          card_enums.RowType.values.byName(key.name),
          value,
        ),
      ),
    );
  }

  @override
  String? computeSingleValue(
    card_enums.RowType rowType,
    card_jiazi.JiaZi pillarJiaZi,
    card_jiazi.JiaZi dayJiaZi,
    card_gender.Gender gender, {
    List<card_pillar.PillarContent>? pillars,
    DateTime? referenceDateTime,
    Map<String, dynamic> context = const {},
  }) {
    return delegate.computeSingleValue(
      RowType.values.byName(rowType.name),
      _jiaZiToCommon(pillarJiaZi),
      _jiaZiToCommon(dayJiaZi),
      _genderToCommon(gender),
      pillars: pillars?.map(_pillarToCommon).toList(growable: false),
      referenceDateTime: referenceDateTime,
      context: context,
    );
  }
}

PillarContent _pillarToCommon(card_pillar.PillarContent value) =>
    PillarContent.fromJson(value.toJson());

JiaZi _jiaZiToCommon(card_jiazi.JiaZi value) => JiaZi.values.byName(value.name);

Gender _genderToCommon(card_gender.Gender value) =>
    Gender.values.byName(value.name);

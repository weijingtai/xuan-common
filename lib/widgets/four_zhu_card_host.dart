import 'dart:async';

import 'package:flutter/material.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:provider/provider.dart';

import '../database/app_database.dart';
import '../database/daos/card_template_meta_dao.dart';
import '../database/daos/card_template_setting_dao.dart';
import '../database/daos/card_template_skill_usage_dao.dart';
import '../database/daos/market_template_installs_dao.dart';
import '../datasource/layout_template_local_data_source.dart';
import '../domain/usecases/layout_templates/delete_template_use_case.dart';
import '../domain/usecases/layout_templates/get_all_templates_use_case.dart';
import '../domain/usecases/layout_templates/get_template_by_id_use_case.dart';
import '../domain/usecases/layout_templates/save_template_use_case.dart';
import '../enums/enum_gender.dart';
import '../enums/layout_template_enums.dart';
import '../features/four_zhu_card/widgets/editable_fourzhu_card/editable_fourzhu_card_impl.dart';
import '../features/four_zhu_card_host/four_zhu_card_host_resolver.dart';
import '../features/shared_card_template/market/market_gateway.dart';
import '../features/shared_card_template/usecase/install_market_template_usecase.dart';
import '../models/eight_chars.dart';
import '../models/drag_payloads.dart';
import '../models/layout_template.dart';
import '../models/row_strategy.dart';
import '../models/text_style_config.dart';
import '../pages/four_zhu_edit_page.dart';
import '../repositories/layout_template_repository_impl.dart';
import '../themes/editable_four_zhu_card_theme.dart';
import '../viewmodels/four_zhu_editor_view_model.dart';

class FourZhuCardHost extends StatefulWidget {
  const FourZhuCardHost({
    super.key,
    required this.eightChars,
    this.gender = Gender.male,
    this.collectionId = 'four_zhu_templates',
    this.initialTemplateId,
    this.showSettingsButton = true,
    this.showThemeSwitcher = true,
    this.showFieldSwitcher = true,
  });

  final EightChars eightChars;
  final Gender gender;
  final String collectionId;
  final String? initialTemplateId;
  final bool showSettingsButton;
  final bool showThemeSwitcher;
  final bool showFieldSwitcher;

  @override
  State<FourZhuCardHost> createState() => _FourZhuCardHostState();
}

class _FourZhuCardHostState extends State<FourZhuCardHost> {
  FourZhuEditorViewModel? _editorViewModel;
  late final ValueNotifier<EditableFourZhuCardTheme> _themeNotifier;
  late final ValueNotifier<CardPayload> _cardPayloadNotifier;
  late final ValueNotifier<EdgeInsets> _paddingNotifier;
  late final ValueNotifier<Brightness> _brightnessNotifier;
  late final ValueNotifier<ColorPreviewMode> _colorPreviewModeNotifier;

  LayoutTemplate? _currentTemplate;
  List<LayoutTemplate> _templates = const [];
  Set<RowType> _toggleableRows = const <RowType>{};
  Set<RowType> _visibleRows = const <RowType>{};
  bool _isInitialized = false;
  bool _isBusy = false;
  Object? _lastTemplateSyncToken;

  @override
  void initState() {
    super.initState();
    _themeNotifier = ValueNotifier(
      EditableCardThemeBuilder.createDefaultTheme(),
    );
    _cardPayloadNotifier = ValueNotifier(
      FourZhuCardHostResolver.resolve(
        template: LayoutTemplate(
          id: '__bootstrap__',
          name: 'bootstrap',
          collectionId: widget.collectionId,
          cardStyle: const CardStyle(
            dividerType: BorderType.none,
            dividerColorHex: '#FF000000',
            dividerThickness: 1,
            globalFontFamily: 'System',
            globalFontSize: 14,
            globalFontColorHex: '#FF000000',
            contentPadding: EdgeInsets.all(12),
          ),
          chartGroups: [
            ChartGroup(
              id: '__bootstrap__',
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
              type: RowType.tenGod,
              isVisible: true,
              isTitleVisible: true,
              textStyleConfig: TextStyleConfig.defaultTenGodsConfig,
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
          ],
          updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
        ),
        eightChars: widget.eightChars,
        gender: widget.gender,
      ).payload,
    );
    _paddingNotifier = ValueNotifier(const EdgeInsets.all(12));
    _brightnessNotifier = ValueNotifier(Brightness.light);
    _colorPreviewModeNotifier = ValueNotifier(ColorPreviewMode.colorful);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _brightnessNotifier.value = Theme.of(context).brightness;
    _ensureEditorViewModel();
  }

  @override
  void didUpdateWidget(covariant FourZhuCardHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collectionId != widget.collectionId ||
        oldWidget.initialTemplateId != widget.initialTemplateId) {
      unawaited(_reloadEditorState(reinitialize: true));
      return;
    }

    if (oldWidget.eightChars != widget.eightChars ||
        oldWidget.gender != widget.gender) {
      _syncResolvedState(forceResetVisibleRows: false);
    }
  }

  void _ensureEditorViewModel() {
    if (_editorViewModel != null) return;
    final localDataSource = LayoutTemplateLocalDataSource(
      context.read<AppDatabase>(),
      outboxStore: _tryRead<OutboxStore>(),
      logger: _tryRead<SyncLogger>(),
    );
    final repository = LayoutTemplateRepositoryImpl(
      localDataSource,
      authScopeProvider: context.read<AuthScopeProvider>(),
    );
    final marketGateway = _tryRead<MarketGateway>();
    final installMarketTemplateUseCase = marketGateway == null
        ? null
        : InstallMarketTemplateUseCase(
            marketGateway: marketGateway,
            localDataSource: localDataSource,
            marketTemplateInstallsDao: MarketTemplateInstallsDao(
              context.read<AppDatabase>(),
            ),
            authScopeProvider: context.read<AuthScopeProvider>(),
          );

    final vm = FourZhuEditorViewModel(
      getAllTemplatesUseCase: GetAllTemplatesUseCase(repository),
      getTemplateByIdUseCase: GetTemplateByIdUseCase(repository),
      saveTemplateUseCase: SaveTemplateUseCase(repository),
      deleteTemplateUseCase: DeleteTemplateUseCase(repository),
      installMarketTemplateUseCase: installMarketTemplateUseCase,
      cardTemplateMetaDao: CardTemplateMetaDao(context.read<AppDatabase>()),
      cardTemplateSettingDao: CardTemplateSettingDao(
        context.read<AppDatabase>(),
      ),
      cardTemplateSkillUsageDao: CardTemplateSkillUsageDao(
        context.read<AppDatabase>(),
      ),
    );
    vm.addListener(_handleEditorVmChanged);
    _editorViewModel = vm;
    unawaited(_reloadEditorState(reinitialize: true));
  }

  T? _tryRead<T>() {
    try {
      return context.read<T>();
    } catch (_) {
      return null;
    }
  }

  Future<void> _reloadEditorState({required bool reinitialize}) async {
    final vm = _editorViewModel;
    if (vm == null || _isBusy) return;
    _isBusy = true;
    try {
      if (reinitialize) {
        await vm.initialize(
          collectionId: widget.collectionId,
          initialTemplateId: widget.initialTemplateId,
        );
      } else {
        await vm.refreshTemplates();
        if (widget.initialTemplateId != null &&
            vm.currentTemplate?.id != widget.initialTemplateId &&
            vm.templates.any((item) => item.id == widget.initialTemplateId)) {
          await vm.selectTemplate(
            widget.initialTemplateId!,
            source: 'host_refresh',
          );
        }
      }
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
      _syncResolvedState(forceResetVisibleRows: true);
    } finally {
      _isBusy = false;
    }
  }

  void _handleEditorVmChanged() {
    if (!mounted) return;
    _syncResolvedState(forceResetVisibleRows: false);
  }

  void _syncResolvedState({required bool forceResetVisibleRows}) {
    final vm = _editorViewModel;
    if (vm == null) return;

    final template = vm.currentTemplate;
    final syncToken = Object.hash(
      template?.id,
      widget.eightChars,
      widget.gender,
      vm.templates.length,
      forceResetVisibleRows,
    );
    if (!forceResetVisibleRows && _lastTemplateSyncToken == syncToken) {
      return;
    }
    _lastTemplateSyncToken = syncToken;

    _templates = vm.templates;
    _currentTemplate = template;
    if (template == null) {
      setState(() {});
      return;
    }

    final toggleableRows = FourZhuCardHostResolver.collectToggleableRows(
      template,
    );
    final nextVisibleRows = forceResetVisibleRows || _visibleRows.isEmpty
        ? toggleableRows
        : _visibleRows.intersection(toggleableRows);
    _toggleableRows = toggleableRows;
    _visibleRows = nextVisibleRows.isEmpty && toggleableRows.isNotEmpty
        ? toggleableRows
        : nextVisibleRows;

    final resolved = FourZhuCardHostResolver.resolve(
      template: template,
      eightChars: widget.eightChars,
      gender: widget.gender,
      visibleRowsOverride: _visibleRows,
    );

    _themeNotifier.value = resolved.theme;
    _paddingNotifier.value = resolved.padding;
    _cardPayloadNotifier.value = resolved.payload;
    _toggleableRows = resolved.toggleableRows;
    setState(() {});
  }

  Future<void> _openSettings() async {
    final templateId = _currentTemplate?.id;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FourZhuEditPage(
          collectionId: widget.collectionId,
          initialTemplateId: templateId,
        ),
      ),
    );
    await _reloadEditorState(reinitialize: false);
  }

  Future<void> _switchTheme(String templateId) async {
    final vm = _editorViewModel;
    if (vm == null || _currentTemplate?.id == templateId) return;
    await vm.selectTemplate(templateId, source: 'host_theme_switcher');
  }

  void _toggleRow(RowType rowType, bool isSelected) {
    final nextRows = Set<RowType>.from(_visibleRows);
    if (isSelected) {
      nextRows.add(rowType);
    } else {
      nextRows.remove(rowType);
    }
    _visibleRows = nextRows;
    _syncResolvedState(forceResetVisibleRows: false);
  }

  @override
  void dispose() {
    _editorViewModel?.removeListener(_handleEditorVmChanged);
    _editorViewModel?.dispose();
    _themeNotifier.dispose();
    _cardPayloadNotifier.dispose();
    _paddingNotifier.dispose();
    _brightnessNotifier.dispose();
    _colorPreviewModeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized && _currentTemplate == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final template = _currentTemplate;
    if (template == null) {
      return const SizedBox.shrink();
    }

    final themeOptions = FourZhuCardHostResolver.buildThemeOptions(_templates);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: EditableFourZhuCardV3(
            dayGanZhi: widget.eightChars.day,
            brightnessNotifier: _brightnessNotifier,
            colorPreviewModeNotifier: _colorPreviewModeNotifier,
            themeNotifier: _themeNotifier,
            cardPayloadNotifier: _cardPayloadNotifier,
            paddingNotifier: _paddingNotifier,
            rowStrategyMapper:
                _editorViewModel?.rowStrategyMapper ??
                const <RowType, RowComputationStrategy>{},
            pillarStrategyMapper:
                _editorViewModel?.pillarStrategyMapper ??
                const <PillarType, PillarComputationStrategy>{},
            gender: widget.gender,
            showGrip: false,
          ),
        ),
        if ((widget.showFieldSwitcher && _toggleableRows.isNotEmpty) ||
            (widget.showThemeSwitcher && themeOptions.length > 1))
          Positioned(
            top: -10,
            left: 20,
            right: 48,
            child: _HostControlsBar(
              currentTemplateId: template.id,
              themeOptions: widget.showThemeSwitcher ? themeOptions : const [],
              toggleableRows: widget.showFieldSwitcher
                  ? _toggleableRows.toList()
                  : const [],
              visibleRows: _visibleRows,
              onThemeSelected: _switchTheme,
              onRowToggled: _toggleRow,
            ),
          ),
        if (widget.showSettingsButton)
          Positioned(
            right: -4,
            bottom: -4,
            child: FloatingActionButton.small(
              heroTag: '${widget.collectionId}:${template.id}:settings',
              onPressed: _openSettings,
              child: const Icon(Icons.settings),
            ),
          ),
      ],
    );
  }
}

class _HostControlsBar extends StatelessWidget {
  const _HostControlsBar({
    required this.currentTemplateId,
    required this.themeOptions,
    required this.toggleableRows,
    required this.visibleRows,
    required this.onThemeSelected,
    required this.onRowToggled,
  });

  final String currentTemplateId;
  final List<FourZhuCardThemeOption> themeOptions;
  final List<RowType> toggleableRows;
  final Set<RowType> visibleRows;
  final ValueChanged<String> onThemeSelected;
  final void Function(RowType rowType, bool isSelected) onRowToggled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(18),
      color: theme.colorScheme.surface.withValues(alpha: 0.96),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final option in themeOptions)
              ChoiceChip(
                label: Text(option.label),
                selected: option.templateId == currentTemplateId,
                onSelected: (_) => onThemeSelected(option.templateId),
              ),
            for (final rowType in toggleableRows)
              FilterChip(
                label: Text(FourZhuCardHostResolver.rowLabelFor(rowType)),
                selected: visibleRows.contains(rowType),
                onSelected: (value) => onRowToggled(rowType, value),
              ),
          ],
        ),
      ),
    );
  }
}

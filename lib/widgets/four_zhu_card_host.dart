import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:provider/provider.dart';
import 'package:xuan_four_zhu_card/widgets/editable_fourzhu_card.dart';
import 'package:xuan_four_zhu_card/models/drag_payloads.dart'
    as card_payloads;
import 'package:xuan_four_zhu_card/features/four_zhu_card/widgets/editable_fourzhu_card/models/theme_color_mode.dart'
    as card_color_mode;
import 'package:xuan_four_zhu_card/themes/editable_four_zhu_card_theme.dart'
    as card_theme;
import 'package:xuan_four_zhu_host/xuan_four_zhu_host.dart' as host_pkg;
import 'package:xuan_four_zhu_templates/xuan_four_zhu_templates.dart'
    as template_pkg;

import '../database/app_database.dart';
import '../database/daos/card_template_meta_dao.dart';
import '../database/daos/card_template_setting_dao.dart';
import '../database/daos/card_template_skill_usage_dao.dart';
import '../enums/enum_gender.dart';
import '../enums/layout_template_enums.dart' as common_layout;
import '../features/four_zhu_card_host/four_zhu_card_compat.dart';
import '../features/four_zhu_card_host/common_four_zhu_host_editor_launcher.dart';
import '../features/four_zhu_card_host/common_four_zhu_host_runtime.dart';
import '../features/four_zhu_card_host/four_zhu_card_host_resolver.dart';
import '../features/shared_card_template/market/market_gateway.dart';
import '../models/eight_chars.dart';
import '../models/drag_payloads.dart';
import '../models/layout_template.dart';
import '../themes/editable_four_zhu_card_theme.dart';
import 'four_zhu_card_host_capsule_adapters.dart';
import 'four_zhu_card_host_components.dart';

enum FourZhuHostDeviceClass { phone, tablet, desktop }

enum FourZhuHostControlsSurface { anchoredPopup, dialog, bottomSheet }

typedef FourZhuHostDeviceClassifier = FourZhuHostDeviceClass Function(
    BuildContext context);

typedef FourZhuHostControlsSurfaceResolver = FourZhuHostControlsSurface
    Function(
  BuildContext context,
  FourZhuHostDeviceClass deviceClass,
);

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
    this.deviceClassifier,
    this.controlsSurfaceResolver,
  });

  final EightChars eightChars;
  final Gender gender;
  final String collectionId;
  final String? initialTemplateId;
  final bool showSettingsButton;
  final bool showThemeSwitcher;
  final bool showFieldSwitcher;
  final FourZhuHostDeviceClassifier? deviceClassifier;
  final FourZhuHostControlsSurfaceResolver? controlsSurfaceResolver;

  @override
  State<FourZhuCardHost> createState() => _FourZhuCardHostState();
}

class _FourZhuCardHostState extends State<FourZhuCardHost> {
  static const double _phoneBreakpoint = 600;
  static const double _tabletBreakpoint = 1024;
  static const FourZhuHostColorScheme _capsuleColors = FourZhuHostColorScheme(
    woodDark: Color(0xFF2A1B15),
    goldLeaf: Color(0xFFD4AF37),
    paperLight: Color(0xFFFDFAF2),
    vermilion: Color(0xFFA62C2B),
    inkText: Color(0xFF333333),
  );

  CommonFourZhuHostRuntime? _hostRuntime;
  host_pkg.FourZhuHostEditorLauncher? _editorLauncher;
  AppDatabase? _ownedDatabase;
  AuthScopeProvider? _authScopeProvider;
  late final ValueNotifier<EditableFourZhuCardTheme> _themeNotifier;
  late final ValueNotifier<CardPayload> _cardPayloadNotifier;
  late final ValueNotifier<card_theme.EditableFourZhuCardTheme>
      _cardThemeNotifier;
  late final ValueNotifier<card_payloads.CardPayload>
      _cardPayloadBridgeNotifier;
  late final ValueNotifier<EdgeInsets> _paddingNotifier;
  late final ValueNotifier<Brightness> _brightnessNotifier;
  late final ValueNotifier<card_color_mode.TextColorMode>
      _cardColorPreviewModeNotifier;

  LayoutTemplate? _currentTemplate;
  List<LayoutTemplate> _templates = const [];
  Set<common_layout.RowType> _toggleableRows =
      const <common_layout.RowType>{};
  Set<common_layout.RowType> _visibleRows =
      const <common_layout.RowType>{};
  bool _hasInitializedVisibleRows = false;
  bool _showColumnHeaderRow = true;
  bool _showRowTitleColumn = true;
  bool _hasInitializedTitleVisibility = false;
  bool _isInitialized = false;
  bool _isBusy = false;
  bool _isDesktopControlsExpanded = false;
  bool _isHovered = false;
  Object? _lastTemplateSyncToken;
  final OverlayPortalController _desktopControlsOverlayController =
      OverlayPortalController();
  final GlobalKey _desktopControlsAnchorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _themeNotifier = ValueNotifier(
      EditableCardThemeBuilder.createDefaultTheme(),
    );
    _cardThemeNotifier = ValueNotifier(
      FourZhuCardCompat.toCardTheme(_themeNotifier.value),
    );
    _themeNotifier.addListener(_syncCardThemeBridge);
    _cardPayloadNotifier = ValueNotifier(
      FourZhuCardHostResolver.resolve(
        template: LayoutTemplate(
          id: '__bootstrap__',
          name: 'bootstrap',
          collectionId: widget.collectionId,
          cardStyle: const template_pkg.CardStyle(
            dividerType: template_pkg.BorderType.none,
            dividerColorHex: '#FF000000',
            dividerThickness: 1,
            globalFontFamily: 'System',
            globalFontSize: 14,
            globalFontColorHex: '#FF000000',
            contentPadding: EdgeInsets.all(12),
          ),
          chartGroups: [
            template_pkg.ChartGroup(
              id: '__bootstrap__',
              title: '四柱',
              pillarOrder: const [
                template_pkg.PillarType.rowTitleColumn,
                template_pkg.PillarType.year,
                template_pkg.PillarType.month,
                template_pkg.PillarType.day,
                template_pkg.PillarType.hour,
              ],
            ),
          ],
          rowConfigs: [
            template_pkg.RowConfig(
              type: template_pkg.RowType.columnHeaderRow,
              isVisible: true,
              isTitleVisible: false,
              textStyleConfig: template_pkg.TextStyleConfig.defaultConfig,
            ),
            template_pkg.RowConfig(
              type: template_pkg.RowType.tenGod,
              isVisible: true,
              isTitleVisible: true,
              textStyleConfig:
                  template_pkg.TextStyleConfig.defaultTenGodsConfig,
            ),
            template_pkg.RowConfig(
              type: template_pkg.RowType.heavenlyStem,
              isVisible: true,
              isTitleVisible: true,
              textStyleConfig: template_pkg.TextStyleConfig.defaultGanConfig,
            ),
            template_pkg.RowConfig(
              type: template_pkg.RowType.earthlyBranch,
              isVisible: true,
              isTitleVisible: true,
              textStyleConfig: template_pkg.TextStyleConfig.defaultZhiConfig,
            ),
          ],
          updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
        ),
        eightChars: widget.eightChars,
        gender: widget.gender,
      ).payload,
    );
    _cardPayloadBridgeNotifier = ValueNotifier(
      FourZhuCardCompat.toCardPayload(_cardPayloadNotifier.value),
    );
    _cardPayloadNotifier.addListener(_syncCardPayloadBridge);
    _paddingNotifier = ValueNotifier(const EdgeInsets.all(12));
    _brightnessNotifier = ValueNotifier(Brightness.light);
    _cardColorPreviewModeNotifier = ValueNotifier(
      card_color_mode.TextColorMode.colorful,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _brightnessNotifier.value = Theme.of(context).brightness;
    _ensureHostRuntime();
  }

  void _syncCardThemeBridge() {
    _cardThemeNotifier.value = FourZhuCardCompat.toCardTheme(
      _themeNotifier.value,
    );
  }

  void _syncCardPayloadBridge() {
    _cardPayloadBridgeNotifier.value = FourZhuCardCompat.toCardPayload(
      _cardPayloadNotifier.value,
    );
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

  void _ensureHostRuntime() {
    if (_hostRuntime != null) {
      _editorLauncher ??= CommonFourZhuHostEditorLauncher(context);
      return;
    }
    final database = _resolveDatabase();
    _authScopeProvider ??=
        _tryRead<AuthScopeProvider>() ?? const _FallbackAuthScopeProvider();
    final runtime = CommonFourZhuHostRuntime.create(
      database: database,
      authScopeProvider: _authScopeProvider!,
      cardTemplateMetaDao: CardTemplateMetaDao(database),
      cardTemplateSettingDao: CardTemplateSettingDao(database),
      cardTemplateSkillUsageDao: CardTemplateSkillUsageDao(database),
      marketGateway: _tryRead<MarketGateway>(),
      outboxStore: _tryRead<OutboxStore>(),
      logger: _tryRead<SyncLogger>(),
    );
    runtime.addListener(_handleEditorVmChanged);
    _hostRuntime = runtime;
    _editorLauncher ??= CommonFourZhuHostEditorLauncher(context);
    unawaited(_reloadEditorState(reinitialize: true));
  }

  AppDatabase _resolveDatabase() {
    final injected = _tryRead<AppDatabase>();
    if (injected != null) {
      return injected;
    }
    return _ownedDatabase ??= AppDatabase();
  }

  T? _tryRead<T>() {
    try {
      return context.read<T>();
    } catch (_) {
      return null;
    }
  }

  Future<void> _reloadEditorState({required bool reinitialize}) async {
    final runtime = _hostRuntime;
    if (runtime == null || _isBusy) return;
    _isBusy = true;
    try {
      if (reinitialize) {
        await runtime.initialize(
          collectionId: widget.collectionId,
          initialTemplateId: widget.initialTemplateId,
        );
      } else {
        await runtime.refresh();
        if (widget.initialTemplateId != null &&
            runtime.currentTemplate?.id != widget.initialTemplateId &&
            runtime.templates.any((item) => item.id == widget.initialTemplateId)) {
          await runtime.selectTemplate(
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
    final runtime = _hostRuntime;
    if (runtime == null) return;

    final template = runtime.currentTemplate;
    final visibleRowsToken = _visibleRows.map((row) => row.name).toList()
      ..sort();
    final syncToken = Object.hash(
      template?.id,
      widget.eightChars,
      widget.gender,
      runtime.templates.length,
      Object.hashAll(visibleRowsToken),
      _showColumnHeaderRow,
      _showRowTitleColumn,
      forceResetVisibleRows,
    );
    if (!forceResetVisibleRows && _lastTemplateSyncToken == syncToken) {
      return;
    }
    _lastTemplateSyncToken = syncToken;

    _templates = runtime.templates;
    _currentTemplate = template;
    if (template == null) {
      setState(() {});
      return;
    }

    final toggleableRows = FourZhuCardHostResolver.collectToggleableRows(
      template,
    );
    final nextVisibleRows = forceResetVisibleRows || !_hasInitializedVisibleRows
        ? toggleableRows
        : _visibleRows.intersection(toggleableRows);
    _toggleableRows = toggleableRows;
    _visibleRows = nextVisibleRows;
    _hasInitializedVisibleRows = true;

    final resolved = FourZhuCardHostResolver.resolve(
      template: template,
      eightChars: widget.eightChars,
      gender: widget.gender,
      visibleRowsOverride: _visibleRows,
    );

    if (forceResetVisibleRows || !_hasInitializedTitleVisibility) {
      _showColumnHeaderRow = resolved.theme.displayHeaderRow;
      _showRowTitleColumn = resolved.theme.displayRowTitleColumn;
      _hasInitializedTitleVisibility = true;
    }

    _themeNotifier.value = resolved.theme.copyWith(
      displayHeaderRow: _showColumnHeaderRow,
      displayRowTitleColumn: _showRowTitleColumn,
    );
    _paddingNotifier.value = resolved.padding;
    _cardPayloadNotifier.value = resolved.payload;
    _toggleableRows = resolved.toggleableRows;
    setState(() {});
  }

  Future<void> _openSettings() async {
    _setDesktopControlsExpanded(false);
    final templateId = _currentTemplate?.id;
    await _editorLauncher?.openEditor(
      collectionId: widget.collectionId,
      initialTemplateId: templateId,
    );
    await _reloadEditorState(reinitialize: false);
  }

  Future<void> _switchTheme(String templateId) async {
    final runtime = _hostRuntime;
    if (runtime == null || _currentTemplate?.id == templateId) return;
    await runtime.selectTemplate(
      templateId,
      source: 'host_theme_switcher',
    );
  }

  FourZhuHostDeviceClass _classifyDevice(BuildContext context) {
    final classifier = widget.deviceClassifier;
    if (classifier != null) {
      return classifier(context);
    }

    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final shortestSide = mediaQuery.size.shortestSide;

    if (shortestSide < _phoneBreakpoint || width < _phoneBreakpoint) {
      return FourZhuHostDeviceClass.phone;
    }

    // Default classification is size-first so web tablets and narrow
    // desktop-like canvases do not accidentally fall back to desktop popup UX.
    if (width < _tabletBreakpoint || shortestSide < _tabletBreakpoint) {
      return FourZhuHostDeviceClass.tablet;
    }

    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return FourZhuHostDeviceClass.tablet;
    }

    return FourZhuHostDeviceClass.desktop;
  }

  FourZhuHostControlsSurface _resolveControlsSurface(BuildContext context) {
    final deviceClass = _classifyDevice(context);
    final resolver = widget.controlsSurfaceResolver;
    if (resolver != null) {
      return resolver(context, deviceClass);
    }

    switch (deviceClass) {
      case FourZhuHostDeviceClass.phone:
        return FourZhuHostControlsSurface.bottomSheet;
      case FourZhuHostDeviceClass.tablet:
        return FourZhuHostControlsSurface.dialog;
      case FourZhuHostDeviceClass.desktop:
        return FourZhuHostControlsSurface.anchoredPopup;
    }
  }

  Future<void> _showControlsSurface() async {
    final surface = _resolveControlsSurface(context);
    switch (surface) {
      case FourZhuHostControlsSurface.anchoredPopup:
        return;
      case FourZhuHostControlsSurface.dialog:
        await _showControlsDialog();
        return;
      case FourZhuHostControlsSurface.bottomSheet:
        await _showControlsBottomSheet();
        return;
    }
  }

  _HostControlsPanel _buildControlsPanel({
    required String currentTemplateId,
    VoidCallback? onRequestClose,
  }) {
    final themeOptions = FourZhuCardHostResolver.buildThemeOptions(_templates);
    return _HostControlsPanel(
      currentTemplateId: currentTemplateId,
      themeOptions: widget.showThemeSwitcher ? themeOptions : const [],
      toggleableRows:
          widget.showFieldSwitcher ? _toggleableRows.toList() : const [],
      visibleRows: _visibleRows,
      showColumnHeaderRow: _showColumnHeaderRow,
      showRowTitleColumn: _showRowTitleColumn,
      onThemeSelected: (templateId) {
        onRequestClose?.call();
        unawaited(_switchTheme(templateId));
      },
      onRowToggled: _toggleRow,
      onToggleHeaderRow: _toggleHeaderRow,
      onToggleRowTitleColumn: _toggleRowTitleColumn,
    );
  }

  void _handleControlsTriggerTap() {
    final surface = _resolveControlsSurface(context);
    switch (surface) {
      case FourZhuHostControlsSurface.anchoredPopup:
        _setDesktopControlsExpanded(!_isDesktopControlsExpanded);
        return;
      case FourZhuHostControlsSurface.dialog:
      case FourZhuHostControlsSurface.bottomSheet:
        unawaited(_showControlsSurface());
        return;
    }
  }

  void _setDesktopControlsExpanded(bool isExpanded) {
    if (_isDesktopControlsExpanded == isExpanded) return;
    setState(() {
      _isDesktopControlsExpanded = isExpanded;
    });
    if (isExpanded) {
      _desktopControlsOverlayController.show();
    } else {
      _desktopControlsOverlayController.hide();
    }
  }

  Future<void> _showControlsDialog() async {
    final template = _currentTemplate;
    if (template == null) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: _HostControlsSurface(
            child: _buildControlsPanel(
              currentTemplateId: template.id,
              onRequestClose: () => Navigator.of(dialogContext).pop(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showControlsBottomSheet() async {
    final template = _currentTemplate;
    if (template == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, bottomInset + 12),
          child: _HostControlsSurface(
            borderRadius: BorderRadius.circular(28),
            child: _buildControlsPanel(
              currentTemplateId: template.id,
              onRequestClose: () => Navigator.of(sheetContext).pop(),
            ),
          ),
        );
      },
    );
  }

  void _toggleRow(common_layout.RowType rowType, bool isSelected) {
    final nextRows = Set<common_layout.RowType>.from(_visibleRows);
    if (isSelected) {
      nextRows.add(rowType);
    } else {
      nextRows.remove(rowType);
    }
    setState(() {
      _visibleRows = nextRows;
      _hasInitializedVisibleRows = true;
    });
    _syncResolvedState(forceResetVisibleRows: false);
  }

  void _toggleHeaderRow(bool isSelected) {
    _themeNotifier.value = _themeNotifier.value.copyWith(
      displayHeaderRow: isSelected,
    );
    setState(() {
      _showColumnHeaderRow = isSelected;
      _hasInitializedTitleVisibility = true;
    });
    _syncResolvedState(forceResetVisibleRows: false);
  }

  void _toggleRowTitleColumn(bool isSelected) {
    _themeNotifier.value = _themeNotifier.value.copyWith(
      displayRowTitleColumn: isSelected,
    );
    setState(() {
      _showRowTitleColumn = isSelected;
      _hasInitializedTitleVisibility = true;
    });
    _syncResolvedState(forceResetVisibleRows: false);
  }

  @override
  void dispose() {
    _hostRuntime?.removeListener(_handleEditorVmChanged);
    _hostRuntime?.dispose();
    _ownedDatabase?.close();
    _themeNotifier.removeListener(_syncCardThemeBridge);
    _cardPayloadNotifier.removeListener(_syncCardPayloadBridge);
    _themeNotifier.dispose();
    _cardPayloadNotifier.dispose();
    _cardThemeNotifier.dispose();
    _cardPayloadBridgeNotifier.dispose();
    _paddingNotifier.dispose();
    _brightnessNotifier.dispose();
    _cardColorPreviewModeNotifier.dispose();
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
    final showControls =
        (widget.showFieldSwitcher && _toggleableRows.isNotEmpty) ||
            (widget.showThemeSwitcher && themeOptions.length > 1);
    final controlsSurface = _resolveControlsSurface(context);
    final useAnchoredDesktopControls = showControls &&
        controlsSurface == FourZhuHostControlsSurface.anchoredPopup;
    if (!useAnchoredDesktopControls && _isDesktopControlsExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _setDesktopControlsExpanded(false);
        }
      });
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        decoration: BoxDecoration(
          color: _isHovered
              ? (_brightnessNotifier.value == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.03)
                  : const Color(0xFFF8FAFC).withValues(alpha: 0.8))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered
                ? (_brightnessNotifier.value == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.08)
                    : const Color(0xFFE2E8F0))
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EditableFourZhuCardV3(
                dayGanZhi: FourZhuCardCompat.toCardJiaZi(widget.eightChars.day),
                brightnessNotifier: _brightnessNotifier,
                colorPreviewModeNotifier: _cardColorPreviewModeNotifier,
                themeNotifier: _cardThemeNotifier,
                cardPayloadNotifier: _cardPayloadBridgeNotifier,
                paddingNotifier: _paddingNotifier,
                rowStrategyMapper:
                    _hostRuntime?.rowStrategyMapper ?? const {},
                pillarStrategyMapper:
                    _hostRuntime?.pillarStrategyMapper ?? const {},
                gender: FourZhuCardCompat.toCardGender(widget.gender),
                showGrip: false,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FourZhuHostZiStrategyTinyCapsule(),
                      const SizedBox(width: 8),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final double panelWidth = math
                              .min(
                                math.max(
                                  constraints.hasBoundedWidth
                                      ? constraints.maxWidth
                                      : MediaQuery.of(context).size.width,
                                  0,
                                ),
                                420.0,
                              )
                              .toDouble();
                          return SizedBox(
                            height: 32,
                            child: OverlayPortal(
                              controller: _desktopControlsOverlayController,
                              overlayChildBuilder: (overlayContext) {
                                final renderBox = _desktopControlsAnchorKey
                                    .currentContext
                                    ?.findRenderObject() as RenderBox?;
                                if (renderBox == null) {
                                  return const SizedBox.shrink();
                                }

                                final overlaySize =
                                    MediaQuery.of(overlayContext).size;
                                final anchorOffset =
                                    renderBox.localToGlobal(Offset.zero);
                                final anchorSize = renderBox.size;
                                const horizontalMargin = 12.0;
                                final maxLeft = math.max(
                                  horizontalMargin,
                                  overlaySize.width -
                                      panelWidth -
                                      horizontalMargin,
                                );
                                final left = (anchorOffset.dx +
                                        (anchorSize.width - panelWidth) / 2)
                                    .clamp(horizontalMargin, maxLeft)
                                    .toDouble();
                                final top =
                                    anchorOffset.dy + anchorSize.height + 12;

                                return SizedBox.expand(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () =>
                                            _setDesktopControlsExpanded(false),
                                        child: const SizedBox.expand(),
                                      ),
                                      Positioned(
                                        left: left,
                                        top: top,
                                        child: Material(
                                          type: MaterialType.transparency,
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 320),
                                            switchInCurve: Curves.easeOutCubic,
                                            switchOutCurve: Curves.easeInCubic,
                                            transitionBuilder:
                                                (child, animation) {
                                              final curved = CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeInOutCubic,
                                              );
                                              return FadeTransition(
                                                opacity: curved,
                                                child: SizeTransition(
                                                  sizeFactor: curved,
                                                  axisAlignment: -1,
                                                  child: child,
                                                ),
                                              );
                                            },
                                            child: useAnchoredDesktopControls &&
                                                    _isDesktopControlsExpanded
                                                ? _HostControlsSurface(
                                                    key: ValueKey<String>(
                                                      'host-panel-${template.id}',
                                                    ),
                                                    width: panelWidth,
                                                    child: _buildControlsPanel(
                                                      currentTemplateId:
                                                          template.id,
                                                      onRequestClose: () =>
                                                          _setDesktopControlsExpanded(
                                                        false,
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox.shrink(
                                                    key: ValueKey<String>(
                                                      'host-panel-hidden',
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: KeyedSubtree(
                                key: _desktopControlsAnchorKey,
                                child: _ThemeDock(
                                  title: template.name,
                                  colors: _capsuleColors,
                                  showSettingsIcon: showControls,
                                  onTap: showControls
                                      ? _handleControlsTriggerTap
                                      : null,
                                  onSettingsTap: showControls
                                      ? _handleControlsTriggerTap
                                      : null,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (widget.showSettingsButton)
                    _HostSettingsButton(
                      onTap: _openSettings,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FallbackAuthScopeProvider implements AuthScopeProvider {
  const _FallbackAuthScopeProvider();

  @override
  Future<String> getScopeUid() async => 'four_zhu_card_host_local';
}

class _ThemeDock extends StatelessWidget {
  static const double _inlineActionSize = 20;

  const _ThemeDock({
    required this.title,
    required this.colors,
    required this.showSettingsIcon,
    this.onTap,
    this.onSettingsTap,
  });

  final String title;
  final FourZhuHostColorScheme colors;
  final bool showSettingsIcon;
  final VoidCallback? onTap;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.92),
            const Color(0xFFF0F1F5).withValues(alpha: 0.88),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFD5D7DE).withValues(alpha: 0.9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.65),
            blurRadius: 0,
            offset: const Offset(0, 1),
            spreadRadius: -0.2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Removed empty SizedBox that was causing asymmetry
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(
                      title,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF3B3D45),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ),
                if (showSettingsIcon) ...[
                  const SizedBox(width: 6),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFF7F7FA).withValues(alpha: 0.92),
                      border: Border.all(
                        color: const Color(0xFFDADCE3).withValues(alpha: 0.9),
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onSettingsTap,
                      child: const SizedBox(
                        width: _inlineActionSize,
                        height: _inlineActionSize,
                        child: Icon(
                          Icons.tune_rounded,
                          color: Color(0xFF616574),
                          size: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HostSettingsButton extends StatelessWidget {
  const _HostSettingsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            const Color(0xFFEDEEF3).withValues(alpha: 0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFD5D7DE).withValues(alpha: 0.9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.settings_rounded,
              color: Color(0xFF4A4D57),
              size: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _HostControlsSurface extends StatelessWidget {
  const _HostControlsSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.width,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      color: _FourZhuCardHostState._capsuleColors.paperLight,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: _FourZhuCardHostState._capsuleColors.woodDark,
          width: 2,
        ),
      ),
      child: SizedBox(
        width: width,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 520,
            maxHeight: 560,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _HostControlsPanel extends StatelessWidget {
  const _HostControlsPanel({
    required this.currentTemplateId,
    required this.themeOptions,
    required this.toggleableRows,
    required this.visibleRows,
    required this.showColumnHeaderRow,
    required this.showRowTitleColumn,
    required this.onThemeSelected,
    required this.onRowToggled,
    required this.onToggleHeaderRow,
    required this.onToggleRowTitleColumn,
  });

  final String currentTemplateId;
  final List<FourZhuCardThemeOption> themeOptions;
  final List<common_layout.RowType> toggleableRows;
  final Set<common_layout.RowType> visibleRows;
  final bool showColumnHeaderRow;
  final bool showRowTitleColumn;
  final ValueChanged<String> onThemeSelected;
  final void Function(common_layout.RowType rowType, bool isSelected)
      onRowToggled;
  final ValueChanged<bool> onToggleHeaderRow;
  final ValueChanged<bool> onToggleRowTitleColumn;

  @override
  Widget build(BuildContext context) {
    final hasThemeChoices = themeOptions.length > 1;
    final hasFieldControls = toggleableRows.isNotEmpty;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HostControlsSectionHeader(
            title: '主题',
            summary: themeOptions
                    .any((option) => option.templateId == currentTemplateId)
                ? themeOptions
                    .firstWhere(
                      (option) => option.templateId == currentTemplateId,
                    )
                    .label
                : null,
          ),
          if (hasThemeChoices) ...[
            const SizedBox(height: 14),
            for (final option in themeOptions)
              _ThemeOptionCard(
                title: option.label,
                selected: option.templateId == currentTemplateId,
                showLeadingIndicator: false,
                onTap: () => onThemeSelected(option.templateId),
              ),
          ],
          const SizedBox(height: 10),
          Divider(
            height: 1,
            thickness: 1,
            color: _FourZhuCardHostState._capsuleColors.woodDark.withValues(
              alpha: 0.16,
            ),
          ),
          const SizedBox(height: 16),
          _HostControlsSectionHeader(
            title: '标题',
            summary:
                '${(showColumnHeaderRow ? 1 : 0) + (showRowTitleColumn ? 1 : 0)}/2',
          ),
          const SizedBox(height: 14),
          _ThemeOptionCard(
            title: '列标题',
            selected: showColumnHeaderRow,
            onTap: () => onToggleHeaderRow(!showColumnHeaderRow),
          ),
          _ThemeOptionCard(
            title: '行标题',
            selected: showRowTitleColumn,
            onTap: () => onToggleRowTitleColumn(!showRowTitleColumn),
          ),
          if (hasFieldControls) ...[
            const SizedBox(height: 10),
            Divider(
              height: 1,
              thickness: 1,
              color: _FourZhuCardHostState._capsuleColors.woodDark.withValues(
                alpha: 0.16,
              ),
            ),
            const SizedBox(height: 16),
            _HostControlsSectionHeader(
              title: '显示',
              summary: '${visibleRows.length}/${toggleableRows.length}',
            ),
            const SizedBox(height: 14),
            for (final rowType in toggleableRows)
              _ThemeOptionCard(
                title: FourZhuCardHostResolver.rowLabelFor(rowType),
                selected: visibleRows.contains(rowType),
                onTap: () =>
                    onRowToggled(rowType, !visibleRows.contains(rowType)),
              ),
          ],
        ],
      ),
    );
  }
}

class _HostControlsSectionHeader extends StatelessWidget {
  const _HostControlsSectionHeader({
    required this.title,
    this.summary,
  });

  final String title;
  final String? summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _FourZhuCardHostState._capsuleColors.woodDark,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        if (summary != null && summary!.isNotEmpty) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FourZhuHostSummaryTag(
                label: summary!,
                tagColor: _FourZhuCardHostState._capsuleColors.woodDark,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  const _ThemeOptionCard({
    required this.title,
    required this.selected,
    required this.onTap,
    this.showLeadingIndicator = true,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;
  final bool showLeadingIndicator;

  @override
  Widget build(BuildContext context) {
    return FourZhuHostOptionCard(
      title: title,
      selected: selected,
      onTap: onTap,
      colors: _FourZhuCardHostState._capsuleColors,
      showLeadingIndicator: showLeadingIndicator,
    );
  }
}

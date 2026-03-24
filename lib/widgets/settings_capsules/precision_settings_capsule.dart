import 'dart:async';

import 'package:flutter/material.dart';

import 'shared_settings_components.dart';

// ─────────────────────────────────────────────────────────────
//  数据模型
// ─────────────────────────────────────────────────────────────

/// 胶囊内单个选项的描述
class CapsuleOption<T> {
  final T value;
  final String title;
  final String subtitle;
  final bool isRecommended;

  const CapsuleOption({
    required this.value,
    required this.title,
    this.subtitle = '',
    this.isRecommended = false,
  });
}

/// 胶囊颜色方案
class CapsuleColorScheme {
  final Color woodDark;
  final Color goldLeaf;
  final Color paperLight;
  final Color vermilion;
  final Color inkText;

  const CapsuleColorScheme({
    required this.woodDark,
    required this.goldLeaf,
    required this.paperLight,
    required this.vermilion,
    required this.inkText,
  });

  static const CapsuleColorScheme defaultWood = CapsuleColorScheme(
    woodDark: Color(0xFF2A1B15),
    goldLeaf: Color(0xFFD4AF37),
    paperLight: Color(0xFFFDFAF2),
    vermilion: Color(0xFFA62C2B),
    inkText: Color(0xFF333333),
  );
}

enum CapsuleViewMode { normal, tiny }

// ─────────────────────────────────────────────────────────────
//  PrecisionSettingsCapsule<T>
// ─────────────────────────────────────────────────────────────

/// 通用精度设置胶囊。
///
/// **整体悬浮架构**：
/// - 布局流中只留一个透明占位 SizedBox（保留位置/尺寸）
/// - 触发器药丸和展开面板均渲染在 OverlayPortal 层
/// - 鼠标进入触发器 → 展开面板；离开 → 120ms 后收起
class PrecisionSettingsCapsule<T> extends StatefulWidget {
  final String headTitle;
  final String subTitle;
  final String Function(T value) labelBuilder;
  final List<CapsuleOption<T>> options;
  final T current;
  final void Function(T value) onSelect;
  final Future<void> Function(T value) onConfirm;
  final List<Widget> extraActions;
  final List<Widget> leftActions;
  final CapsuleColorScheme colorScheme;
  final CapsuleViewMode viewMode;
  final double expandedWidth;
  final double collapsedWidth;
  final double tinyCollapsedWidth;

  const PrecisionSettingsCapsule({
    super.key,
    required this.headTitle,
    required this.subTitle,
    required this.labelBuilder,
    required this.options,
    required this.current,
    required this.onSelect,
    required this.onConfirm,
    this.extraActions = const [],
    this.leftActions = const [],
    this.colorScheme = CapsuleColorScheme.defaultWood,
    this.viewMode = CapsuleViewMode.normal,
    this.expandedWidth = 380,
    this.collapsedWidth = 125,
    this.tinyCollapsedWidth = 64,
  });

  @override
  State<PrecisionSettingsCapsule<T>> createState() =>
      _PrecisionSettingsCapsuleState<T>();
}

// ─────────────────────────────────────────────────────────────
//  State
// ─────────────────────────────────────────────────────────────

class _PrecisionSettingsCapsuleState<T>
    extends State<PrecisionSettingsCapsule<T>> {
  // ── Overlay（触发器 + 面板都在这层）────────────────────────────
  final OverlayPortalController _overlayCtrl = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();
  Timer? _hideTimer;

  // ── 状态 ────────────────────────────────────────────────────
  bool _isHovered = false;
  bool _isPanelOpen = false;

  // 预缓存布局变量
  Widget? _cachedPanelContent;
  double _cachedPanelHeight = 0.0;

  bool get _isTiny => widget.viewMode == CapsuleViewMode.tiny;
  bool get _isTinyCollapsed => _isTiny && !_isHovered;

  double get _triggerRadius => _isTinyCollapsed ? 14 : 25;
  double get _triggerWidth => widget.tinyCollapsedWidth;
  // double get _triggerWidth =>
  // _isTinyCollapsed ? widget.tinyCollapsedWidth : widget.collapsedWidth;

  // 布局占位高度（近似值，与触发器实际渲染高度匹配）
  double get _placeholderWidth =>
      _isTinyCollapsed ? widget.tinyCollapsedWidth : widget.collapsedWidth;

  CapsuleColorScheme get cs => widget.colorScheme;

  // ── Lifecycle ────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // 触发器在 overlay 中常驻显示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _overlayCtrl.show();
    });

    // 初始化时预缓存布局
    _updateLayoutCache();
  }

  @override
  void didUpdateWidget(covariant PrecisionSettingsCapsule<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果影响布局的项目变更，重新计算缓存
    if (oldWidget.current != widget.current ||
        oldWidget.options != widget.options ||
        oldWidget.expandedWidth != widget.expandedWidth) {
      _updateLayoutCache();
    }
  }

  void _updateLayoutCache() {
    // 1. 各区块固定高度锁定：
    // Header(48) + Divider(26) + Footer(44) + ContainerPadding(16) + Border(2) * 2 = 138.0
    const double kFixedTotalHeight = 138.0;

    // 2. 动态计算所有选项高度
    double optionsHeightSum = 0.0;
    // 宽度计算：expandedWidth - 20(父容器 Padding) - 16(卡片水平 Margin) = 36
    final double cardPhysicalWidth = widget.expandedWidth - 36;

    for (var opt in widget.options) {
      optionsHeightSum += SettingsOptionCard.computeHeight(
        title: opt.title,
        subtitle: opt.subtitle,
        cardWidth: cardPhysicalWidth,
      );
    }

    // 由于选项列表中 100% 存在一个“选中项”，其边框（1.5 * 2）比基准预估（1.0 * 2）多出 1px
    _cachedPanelHeight = (kFixedTotalHeight + optionsHeightSum + 1.0);

    // 3. 预构建完整的面板 UI
    _cachedPanelContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPanelHeader(),
        _buildPanelContent(),
      ],
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  // ── Hover logic ──────────────────────────────────────────────

  void _onEnter(PointerEvent _) {
    _hideTimer?.cancel();
    if (!_isHovered) {
      setState(() {
        _isHovered = true;
        _isPanelOpen = true;
      });
    }
  }

  void _scheduleHide([PointerEvent? _]) {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() {
        _isHovered = false;
        _isPanelOpen = false;
      });
    });
  }

  void _forceHide() {
    _hideTimer?.cancel();
    setState(() {
      _isHovered = false;
      _isPanelOpen = false;
    });
  }

  Future<void> _onConfirm() async {
    await widget.onConfirm(widget.current);
    if (mounted) _forceHide();
  }

  // ── Root build（布局占位）────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: OverlayPortal(
        controller: _overlayCtrl,
        overlayChildBuilder: _buildOverlay,
        // 透明占位，保留布局空间；触发器视觉由 overlay 层渲染
        child: IgnorePointer(
          child: SizedBox(
            width: _placeholderWidth,
            height: _isTinyCollapsed ? 28 : 50,
            child: Opacity(
              opacity: 0,
              child: _buildAnimatedCapsule(forceCollapsed: true),
            ),
          ),
        ),
      ),
    );
  }

  // ── Overlay 内容（触发器 + 全屏遮罩 + 面板）────────────────────

  Widget _buildOverlay(BuildContext overlayCtx) {
    return Stack(
      children: [
        // 全屏遮罩（面板展开时才显示）
        if (_isPanelOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _forceHide,
              child: Container(
                color: Colors.black.withValues(alpha: 0.20),
              ),
            ),
          ),
        // 触发器 + 展开面板，锚定在占位位置
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.topLeft,
          followerAnchor: Alignment.topLeft,
          child: Material(
            type: MaterialType.transparency,
            child: MouseRegion(
              onEnter: _onEnter,
              onExit: _scheduleHide,
              child: _buildAnimatedCapsule(),
            ),
          ),
        ),
      ],
    );
  }

  // ── 统一的动画胶囊/面板 ───────────────────────────────────────

  Widget _buildAnimatedCapsule({bool forceCollapsed = false}) {
    final bool isExpanded = _isPanelOpen && !forceCollapsed;

    // ── 预缓存驱动方案：零延迟响应 ──────
    const double borderWidth = 2;
    final double targetExpandedHeight = _cachedPanelHeight;

    final double currentHeight =
        isExpanded ? targetExpandedHeight : (_isTinyCollapsed ? 28 : 50);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutQuart,
      width: isExpanded ? widget.expandedWidth : _triggerWidth,
      height: currentHeight,
      alignment: isExpanded ? Alignment.center : Alignment.topLeft,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isExpanded ? cs.paperLight : cs.woodDark,
        // color: Colors.black,
        borderRadius: BorderRadius.circular(isExpanded ? 20 : _triggerRadius),
        border: Border.all(color: cs.woodDark, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isExpanded ? 0.25 : 0.18),
            blurRadius: isExpanded ? 32 : 12,
            offset: Offset(0, isExpanded ? 12 : 4),
          ),
        ],
      ),
      child: OverflowBox(
        alignment: isExpanded ? Alignment.topLeft : Alignment.center,
        // alignment: Alignment.center,
        minWidth: isExpanded ? widget.expandedWidth : _triggerWidth,
        maxWidth: isExpanded ? widget.expandedWidth : _triggerWidth,
        minHeight:
            isExpanded ? targetExpandedHeight : (_isTinyCollapsed ? 28 : 50),
        maxHeight:
            isExpanded ? targetExpandedHeight : (_isTinyCollapsed ? 28 : 50),
        child: Stack(
          children: [
            // 折叠态：药丸内容
            Positioned(
              left: 0,
              top: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isExpanded ? 0.0 : 1.0,
                curve: Curves.easeInOut,
                child: Container(
                  width: _triggerWidth,
                  // height: _isTinyCollapsed ? 28 : 50,
                  height: 28,
                  alignment: Alignment.center,
                  child: _buildTriggerContent(),
                ),
              ),
            ),
            // 展开态：面板内容 (消费预缓存件)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 350),
              opacity: isExpanded ? 1.0 : 0.0,
              curve: Curves.easeInOut,
              child: SizedBox(
                width: widget.expandedWidth,
                height: targetExpandedHeight,
                child: _cachedPanelContent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 药丸内容 ─────────────────────────────────────────────────

  Widget _buildTriggerContent() {
    final double fixedHeight = _isTinyCollapsed ? 28 : 50;
    return SizedBox(
      height: fixedHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _isTinyCollapsed ? 0 : 14,
          vertical: _isTinyCollapsed ? 4 : 12,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!_isTinyCollapsed) ...[
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  widget.headTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cs.goldLeaf.withValues(alpha: 0.75),
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text('·',
                    style: TextStyle(
                        color: cs.goldLeaf,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ),
            ],
            SettingsPrecisionTag(
              label: widget.labelBuilder(widget.current),
              tagColor: cs.goldLeaf,
              isPillar: true,
              isTinyCollapsed: _isTinyCollapsed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelHeader() {
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                widget.headTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: cs.woodDark,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                widget.subTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: cs.woodDark,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text('·',
                  style: TextStyle(
                      color: cs.woodDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
            SettingsPrecisionTag(
              label: widget.labelBuilder(widget.current),
              tagColor: cs.woodDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelContent() {
    return Container(
      width: widget.expandedWidth,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.options.map((opt) => SettingsOptionCard(
                title: opt.title,
                subtitle: opt.subtitle,
                selected: opt.value == widget.current,
                onTap: () => widget.onSelect(opt.value),
                isRecommended: opt.isRecommended,
                vermilion: cs.vermilion,
                inkText: cs.inkText,
                paperLight: cs.paperLight,
                woodDark: cs.woodDark,
                goldLeaf: cs.goldLeaf,
              )),
          SizedBox(
            height: 26,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: List.generate(
                    20,
                    (i) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 1,
                        color: const Color(0xFFDDDDDD),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildActionRow(),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          ...widget.leftActions
              .expand((btn) => [btn, const SizedBox(width: 8)]),
          ...widget.extraActions.map((btn) => Expanded(flex: 1, child: btn)),
          if (widget.extraActions.isNotEmpty) const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: SettingsActionButton(
              label: '确定',
              isPrimary: true,
              woodDark: cs.woodDark,
              goldLeaf: cs.goldLeaf,
              onPressed: _onConfirm,
            ),
          ),
        ],
      ),
    );
  }
}

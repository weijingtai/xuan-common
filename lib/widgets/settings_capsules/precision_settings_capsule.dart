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

  bool get _isTiny => widget.viewMode == CapsuleViewMode.tiny;
  bool get _isTinyCollapsed => _isTiny && !_isHovered;

  double get _triggerRadius => _isTinyCollapsed ? 14 : 25;
  double get _triggerWidth =>
      _isTinyCollapsed ? widget.tinyCollapsedWidth : widget.collapsedWidth;

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
        child: SizedBox(
          width: _placeholderWidth,
          // 我们只需要宽度占位即可。
          // 真正的药丸内容会被外面的 Stack/Row 居中对齐处理
          child: Opacity(
            opacity: 0,
            child: _buildTrigger(), // 渲染一个不可见的药丸来撑开高度
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
              // 触发器 + 面板作为一个整体，MouseRegion 统一覆盖两者
              // 鼠标在任意部分都不会触发 onExit；离开整体才触发
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start, // 关键：确保按左对齐（不使用 Stack 的默认强制居中）
                children: [
                  _buildTrigger(),
                  if (_isPanelOpen) ...[
                    const SizedBox(height: 8),
                    _buildPanel(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 触发器药丸 ───────────────────────────────────────────────

  Widget _buildTrigger() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: _triggerWidth,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.woodDark,
        borderRadius: BorderRadius.circular(_triggerRadius),
        border: Border.all(color: cs.woodDark, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_triggerRadius),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _isTinyCollapsed ? 0 : 14,
            vertical: _isTinyCollapsed ? 4 : 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.ideographic,
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.centerLeft,
                child: _isTinyCollapsed
                    ? const SizedBox(width: 0)
                    : Text(
                        widget.headTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: cs.goldLeaf.withValues(alpha: 0.75),
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: _isTinyCollapsed
                    ? const SizedBox(width: 0)
                    : Row(children: [
                        const SizedBox(width: 4),
                        Text('·',
                            style: TextStyle(
                                color: cs.goldLeaf,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                      ]),
              ),
              SettingsPrecisionTag(
                label: widget.labelBuilder(widget.current),
                tagColor: cs.goldLeaf,
                isPillar: true,
                isTinyCollapsed: _isTinyCollapsed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 展开面板 ─────────────────────────────────────────────────

  Widget _buildPanel() {
    return Container(
      width: widget.expandedWidth,
      decoration: BoxDecoration(
        color: cs.paperLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.woodDark, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPanelHeader(),
            _buildPanelContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.ideographic,
        children: [
          Text(
            widget.headTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: cs.woodDark,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            widget.subTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: cs.woodDark,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Text('·',
              style: TextStyle(
                  color: cs.woodDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          SettingsPrecisionTag(
            label: widget.labelBuilder(widget.current),
            tagColor: cs.woodDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPanelContent() {
    return Container(
      width: widget.expandedWidth,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
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
          const SizedBox(height: 12),
          Padding(
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
          const SizedBox(height: 12),
          _buildActionRow(),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        ...widget.leftActions.expand((btn) => [btn, const SizedBox(width: 8)]),
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
    );
  }
}

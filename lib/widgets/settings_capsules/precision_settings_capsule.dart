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
  /// 主色（胶囊底色、折叠时文字）
  final Color woodDark;

  /// 金色（折叠态 Tag、选中边框）
  final Color goldLeaf;

  /// 浅背景（展开态胶囊底色）
  final Color paperLight;

  /// 推荐标签色
  final Color vermilion;

  /// 正文颜色
  final Color inkText;

  const CapsuleColorScheme({
    required this.woodDark,
    required this.goldLeaf,
    required this.paperLight,
    required this.vermilion,
    required this.inkText,
  });

  /// 默认深色木质配色（与 JieQiEntry 一致）
  static const CapsuleColorScheme defaultWood = CapsuleColorScheme(
    woodDark: Color(0xFF2A1B15),
    goldLeaf: Color(0xFFD4AF37),
    paperLight: Color(0xFFFDFAF2),
    vermilion: Color(0xFFA62C2B),
    inkText: Color(0xFF333333),
  );
}

/// 胶囊的显示模式
enum CapsuleViewMode { normal, tiny }

// ─────────────────────────────────────────────────────────────
//  PrecisionSettingsCapsule<T>
// ─────────────────────────────────────────────────────────────

/// 通用精度设置胶囊。
///
/// 封装了与 [JieQiEntrySettingsCapsule] 完全相同的动画体验：
/// - Normal / Tiny / TinyCollapsed 三态
/// - Hover 放大、点击展开/折叠
/// - Header：[headTitle] + "·" + [labelBuilder] Tag
/// - Content：[AnimatedSize] 展开区域，渲染 [options]
///
/// 典型用法：
/// ```dart
/// PrecisionSettingsCapsule<MyEnum>(
///   headTitle: '交節',
///   subTitle: '方案',
///   options: [...],
///   current: _current,
///   labelBuilder: (v) => '分鐘',
///   onSelect: (v) { setState(() => _current = v); },
///   extraActions: [...],        // 可选：预览/对比等按钮
///   onConfirm: (v) async { ... },
/// )
/// ```
class PrecisionSettingsCapsule<T> extends StatefulWidget {
  /// Header 第一个词，如"交節"、"子時"
  final String headTitle;

  /// Header 第二个词（展开时与 headTitle 合并显示），如"方案"、"策略"
  final String subTitle;

  /// 从当前值生成 Header Tag 短标签，如 (v) => '分鐘'
  final String Function(T value) labelBuilder;

  /// 选项列表
  final List<CapsuleOption<T>> options;

  /// 当前选中值
  final T current;

  /// 用户点选选项时的回调（立即触发，不等点确定）
  final void Function(T value) onSelect;

  /// 点"确定"按钮触发的异步回调（用于持久化）
  final Future<void> Function(T value) onConfirm;

  /// 在底部按钮行"确定"左侧插入的额外按钮（如"预览"、"对比"）
  final List<Widget> extraActions;

  /// 按钮区左侧额外按钮（如"重置"、"设为默认"）
  final List<Widget> leftActions;

  /// 颜色方案
  final CapsuleColorScheme colorScheme;

  /// 显示模式
  final CapsuleViewMode viewMode;

  /// 展开后宽度（默认 380）
  final double expandedWidth;

  /// 折叠宽度（normal 模式，默认 125；label 较长时请适当调大）
  final double collapsedWidth;

  /// Tiny 极度折叠时的宽度（默认 64）
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

class _PrecisionSettingsCapsuleState<T>
    extends State<PrecisionSettingsCapsule<T>> {
  bool _isCollapsed = true;
  bool _isHovered = false;

  bool get _isTiny => widget.viewMode == CapsuleViewMode.tiny;
  bool get _isTinyCollapsed => _isTiny && _isCollapsed && !_isHovered;

  // 消除重复：圆角值集中在一处计算
  double get _borderRadius {
    if (!_isCollapsed) return 40;
    return _isTinyCollapsed ? 14 : 25;
  }

  // 折叠宽度（使用外部传入的参数，避免硬编码）
  double get _collapsedWidth =>
      _isTinyCollapsed ? widget.tinyCollapsedWidth : widget.collapsedWidth;

  void _toggle() => setState(() => _isCollapsed = !_isCollapsed);

  void _onHoverEnter(PointerEvent _) {
    if (_isTiny && !_isHovered) setState(() => _isHovered = true);
  }

  void _onHoverExit(PointerEvent _) {
    if (_isTiny && _isHovered) setState(() => _isHovered = false);
  }

  CapsuleColorScheme get cs => widget.colorScheme;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onHoverEnter,
      onExit: _onHoverExit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: const Cubic(0.34, 1.56, 0.64, 1),
        width: _isCollapsed ? _collapsedWidth : widget.expandedWidth,
        decoration: BoxDecoration(
          color: _isCollapsed ? cs.woodDark : cs.paperLight,
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(color: cs.woodDark, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_borderRadius),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildContentArea(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────

  Widget _buildHeader() {
    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _isCollapsed ? (_isTinyCollapsed ? 0 : 14) : 18,
          vertical: _isCollapsed
              ? (_isTinyCollapsed || (_isTiny && _isHovered) ? 4 : 12)
              : 12,
        ),
        child: Row(
          children: [
            Expanded(child: _buildHeaderLabel()),
            _buildChevron(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderLabel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      alignment:
          _isTiny && _isCollapsed ? Alignment.center : Alignment.centerLeft,
      child: SingleChildScrollView(
        // 防止展开过渡时内容溢出报 RenderFlex 错误
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.ideographic,
          children: [
            // ① headTitle（如"交節"）— 颜色/大小动画
            _buildHeadTitle(),
            // ② subTitle（如"方案"）— 宽度滑入动画
            _buildSubTitle(),
            // ③ 展开态：· Tag + 空间
            if (!_isCollapsed) ..._buildExpandedTag(),
            // ④ 折叠态：· Tag
            if (_isCollapsed) ..._buildCollapsedTag(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadTitle() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment:
          _isTiny && _isCollapsed ? Alignment.center : Alignment.centerLeft,
      child: _isTinyCollapsed
          ? const SizedBox(width: 0)
          : AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 600),
              curve: const Cubic(0.34, 1.56, 0.64, 1),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _isCollapsed
                    ? cs.goldLeaf.withValues(alpha: 0.75)
                    : cs.woodDark,
                fontSize: _isCollapsed ? 14 : 16,
                letterSpacing: 0.5,
              ),
              child: Text(widget.headTitle, softWrap: false),
            ),
    );
  }

  Widget _buildSubTitle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: _isCollapsed ? 0 : _subTitleWidth,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: _isCollapsed ? 0 : 1,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 600),
          curve: const Cubic(0.34, 1.56, 0.64, 1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: cs.woodDark,
            fontSize: _isCollapsed ? 14 : 16,
            letterSpacing: 0.5,
            height: 1.0,
          ),
          child: Text(widget.subTitle, softWrap: false),
        ),
      ),
    );
  }

  // subTitle 宽度：每个汉字约 17px @ fontSize 16
  double get _subTitleWidth => widget.subTitle.length * 17.0 + 2;

  List<Widget> _buildExpandedTag() {
    return [
      const SizedBox(width: 6),
      Text('·',
          style: TextStyle(
              color: cs.woodDark,
              fontSize: 16,
              height: 1.0,
              fontWeight: FontWeight.bold)),
      const SizedBox(width: 6),
      SettingsPrecisionTag(
        label: widget.labelBuilder(widget.current),
        tagColor: cs.woodDark,
      ),
    ];
  }

  List<Widget> _buildCollapsedTag() {
    return [
      // · 分隔符（tiny collapse 时隐藏）
      AnimatedSize(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: Alignment.centerLeft,
        child: _isTinyCollapsed
            ? const SizedBox(width: 0)
            : Row(
                children: [
                  const SizedBox(width: 4),
                  Text('·',
                      style: TextStyle(
                          color: cs.goldLeaf,
                          fontSize: 14,
                          height: 1.0,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                ],
              ),
      ),
      SettingsPrecisionTag(
        label: widget.labelBuilder(widget.current),
        tagColor: cs.goldLeaf,
        isPillar: true,
        isTinyCollapsed: _isTinyCollapsed,
      ),
    ];
  }

  Widget _buildChevron() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: _isCollapsed ? 0 : 22,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      child: AnimatedRotation(
        turns: _isCollapsed ? 0 : 0.5,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        child: Icon(Icons.expand_more, color: cs.woodDark, size: 18),
      ),
    );
  }

  // ── Content ─────────────────────────────────────────────────

  Widget _buildContentArea() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 600),
      curve: const Cubic(0.34, 1.56, 0.64, 1),
      alignment: Alignment.topCenter,
      child: _isCollapsed
          ? const SizedBox(width: double.infinity, height: 0)
          : SingleChildScrollView(
              // 防止展开过渡时内容溢出
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Container(
                width: widget.expandedWidth,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 选项列表
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
                    _buildDivider(),
                    const SizedBox(height: 12),
                    _buildActionRow(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDivider() {
    return Padding(
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
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        // 左侧额外按钮（重置、设为默认等）
        ...widget.leftActions.expand((btn) => [btn, const SizedBox(width: 8)]),
        // 右侧：额外按钮 + 确定
        ...widget.extraActions.map(
          (btn) => Expanded(flex: 1, child: btn),
        ),
        if (widget.extraActions.isNotEmpty) const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: SettingsActionButton(
            label: '确定',
            isPrimary: true,
            woodDark: cs.woodDark,
            goldLeaf: cs.goldLeaf,
            onPressed: () async {
              await widget.onConfirm(widget.current);
              _toggle();
            },
          ),
        ),
      ],
    );
  }
}

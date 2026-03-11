import 'dart:ui' show lerpDouble;
import 'package:common/enums.dart';
import 'package:common/features/liu_yun/themes/ink_theme.dart';
import 'package:common/models/yun_liu_display_models.dart';
import 'package:common/viewmodels/yun_liu_view_model.dart';
import 'package:flutter/material.dart';
import 'package:tyme/tyme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data types
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Theme Configuration
// ─────────────────────────────────────────────────────────────────────────────

/// Centralized style parameters for the YunLiu card component.
class YunLiuCardThemeData {
  /// The active/selected brand color (defaults to a dark green).
  final Color activeColor;

  /// The active marker brand color specifically for 'Today' (defaults to cinnabar red).
  final Color todayColor;

  /// Fallback fonts for traditional Chinese & GanZhi (Serif).
  final List<String> serifFonts;

  /// Fallback fonts for generic numbers & modern typography (Sans-serif).
  final List<String> sansFonts;

  /// Width of the large top-level DaYun horizontal cards.
  final double daYunCardWidth;

  /// Fixed height of the List containing DaYun cards.
  final double daYunListHeight;

  const YunLiuCardThemeData({
    required this.activeColor,
    required this.todayColor,
    required this.serifFonts,
    required this.sansFonts,
    required this.daYunCardWidth,
    required this.daYunListHeight,
  });

  /// The standard authentic theme used in the application.
  factory YunLiuCardThemeData.fallback() {
    return const YunLiuCardThemeData(
      activeColor: Color(0xFF2E5A3C),
      todayColor: InkTheme.cinnabar,
      serifFonts: [
        'STKaiti',
        'KaiTi',
        'Noto Serif SC',
        'Source Han Serif SC',
        'serif',
      ],
      sansFonts: ['sans-serif'],
      daYunCardWidth: 420.0,
      daYunListHeight: 220.0,
    );
  }
}

/// An [InheritedWidget] to inject [YunLiuCardThemeData] seamlessly down the tree.
class YunLiuCardTheme extends InheritedWidget {
  final YunLiuCardThemeData data;

  const YunLiuCardTheme({
    super.key,
    required this.data,
    required super.child,
  });

  static YunLiuCardThemeData of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<YunLiuCardTheme>();
    return widget?.data ?? YunLiuCardThemeData.fallback();
  }

  @override
  bool updateShouldNotify(YunLiuCardTheme oldWidget) => data != oldWidget.data;
}

// ─────────────────────────────────────────────────────────────────────────────
// Main Widget
// ─────────────────────────────────────────────────────────────────────────────

/// A three-tier cascading card widget showing DaYun → LiuNian → LiuYue.
///
/// The first tier is a horizontal list of DaYun tiles.
/// Selecting a LiuNian chip inside a DaYun tile opens the second tier,
/// showing the LiuNian detail with LiuYue index chips.
/// Selecting a LiuYue chip opens the third tier with the LiuYue detail.
class YunLiuListTileCardWidget extends StatefulWidget {
  final YunLiuViewModel viewModel;

  const YunLiuListTileCardWidget({
    super.key,
    required this.viewModel,
  });

  @override
  State<YunLiuListTileCardWidget> createState() =>
      _YunLiuListTileCardWidgetState();
}

class _YunLiuListTileCardWidgetState extends State<YunLiuListTileCardWidget> {
  final ScrollController _daYunScrollCtrl = ScrollController();
  final ScrollController _liuNianScrollCtrl = ScrollController();
  final ScrollController _liuYueScrollCtrl = ScrollController();
  final ScrollController _liuRiScrollCtrl = ScrollController();
  final ScrollController _liuShiScrollCtrl = ScrollController();

  YunLiuViewModel get vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    vm.addListener(_onViewModelChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handlePreciseScroll();
    });
  }

  @override
  void dispose() {
    vm.removeListener(_onViewModelChanged);
    _daYunScrollCtrl.dispose();
    _liuNianScrollCtrl.dispose();
    _liuYueScrollCtrl.dispose();
    _liuRiScrollCtrl.dispose();
    _liuShiScrollCtrl.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
      _handlePreciseScroll();
    }
  }

  void _handlePreciseScroll() {
    final theme = YunLiuCardTheme.of(context);
    final viewportWidth = MediaQuery.of(context).size.width;

    if (vm.selectedDaYunIdx != null) {
      _scrollToCenterExact(_daYunScrollCtrl, vm.selectedDaYunIdx!,
          theme.daYunCardWidth, viewportWidth);
    }
    // ... repeat for others as needed or based on tier transitions
  }

  void _scrollToCenterExact(ScrollController ctrl, int index, double itemWidth,
      double viewportWidth) {
    if (!ctrl.hasClients) return;

    // Exact formula for centering:
    // Offset = (index * (itemWidth + spacing)) + listPadding - (viewportWidth / 2) + (itemWidth / 2)
    // Here spacing is 14.0, listPadding is 25.0
    final spacing = 14.0;
    final listPadding = 25.0;
    final targetWidth = vm.isMiniMode ? (itemWidth * 0.75) : itemWidth;

    final offset = (index * (targetWidth + spacing)) +
        listPadding -
        (viewportWidth / 2) +
        (targetWidth / 2);

    ctrl.animateTo(
      offset.clamp(0.0, ctrl.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  // ── Tier label ──
  Widget _buildTierLabel(String text, YunLiuCardThemeData theme) {
    return Container(
      width: vm.isHorizontal ? (theme.daYunCardWidth + 50) : double.infinity,
      padding: EdgeInsets.only(
          left: vm.isHorizontal ? 25 : 20,
          right: vm.isHorizontal ? 25 : 20,
          top: 12,
          bottom: 6),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: InkTheme.textMuted,
              letterSpacing: 2,
              fontFamilyFallback: theme.sansFonts,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(height: 1, color: InkTheme.borderLight),
          ),
        ],
      ),
    );
  }

  // Global controls row
  Widget _buildGlobalControls(YunLiuCardThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: vm.isAllCollapsed ? vm.expandAll : vm.collapseAll,
            icon: Icon(
              vm.isAllCollapsed ? Icons.unfold_more : Icons.unfold_less,
              size: 16,
              color: InkTheme.inkMuted,
            ),
            label: Text(
              vm.isAllCollapsed ? '全部展开' : '全部收起',
              style: const TextStyle(fontSize: 12, color: InkTheme.inkMuted),
            ),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: vm.toggleOrientation,
            icon: Icon(
              vm.isHorizontal
                  ? Icons.view_agenda_outlined
                  : Icons.view_carousel_outlined,
              size: 16,
              color: InkTheme.inkMuted,
            ),
            label: Text(
              vm.isHorizontal ? '切换竖向' : '切换横向',
              style: TextStyle(fontSize: 12, color: InkTheme.inkMuted),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: vm.toggleMiniMode,
            icon: Icon(
              vm.isMiniMode ? Icons.zoom_in : Icons.zoom_out_map,
              size: 16,
              color: InkTheme.inkMuted,
            ),
            label: Text(
              vm.isMiniMode ? '全展大' : '全缩小',
              style: TextStyle(fontSize: 12, color: InkTheme.inkMuted),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => vm.backToTargetDate(DateTime.now()),
            icon: const Icon(
              Icons.today,
              size: 16,
              color: InkTheme.cinnabar,
            ),
            label: const Text(
              '回到今天',
              style: TextStyle(fontSize: 12, color: InkTheme.cinnabar),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierRow({
    required String title,
    double? horizontalHeight,
    required Widget child,
    required YunLiuCardThemeData theme,
    required Axis scrollDirection,
    required int itemCount,
    required Widget Function(BuildContext, int) builder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTierLabel(title, theme),
        if (scrollDirection == Axis.horizontal)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: horizontalHeight,
            child: ListView.separated(
              controller: child is ListView ? child.controller : null,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              itemCount: itemCount,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: builder,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: builder,
            ),
          ),
      ],
    );
  }

  // Helper to determine horizontal height for a tier row
  double _getTierHeight(int tier) {
    bool hasExpanded = false;
    if (tier == 1) {
      hasExpanded = vm.daYunList.asMap().keys.any(vm.isDaYunExpanded);
    } else if (tier == 2 && vm.selectedDaYunIdx != null) {
      hasExpanded = vm.liuNianExpanded.values.any((e) => e);
    } else if (tier == 3 && vm.selectedLiuNianIdx != null) {
      hasExpanded = vm.liuYueExpanded.values.any((e) => e) ||
          vm.selectedLiuYueIdx != null;
    } else if (tier == 4) {
      hasExpanded = true; // LiuRi cards are always expanded
    }

    if (vm.isMiniMode) {
      if (tier == 5) return 120;
      if (tier == 3) return hasExpanded ? 480 : 120;
      return hasExpanded ? 280 : 120;
    } else {
      if (tier == 5) return 240;
      if (tier == 3) return hasExpanded ? 560 : 240;
      return hasExpanded ? 380 : 240;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        final daYunList = vm.daYunList;
        if (daYunList.isEmpty) return const SizedBox.shrink();

        final selectedDaYun = vm.selectedDaYunIdx != null
            ? daYunList[vm.selectedDaYunIdx!]
            : null;
        final selectedLiuNian =
            (selectedDaYun != null && vm.selectedLiuNianIdx != null)
                ? selectedDaYun.liunian[vm.selectedLiuNianIdx!]
                : null;
        final selectedLiuYue =
            (selectedLiuNian != null && vm.selectedLiuYueIdx != null)
                ? selectedLiuNian.liuyue[vm.selectedLiuYueIdx!]
                : null;

        final theme = YunLiuCardTheme.of(context);

        return SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildGlobalControls(theme),
              // ── Tier 1: DaYun ──
              _buildTierRow(
                title: '大运',
                horizontalHeight: _getTierHeight(1),
                theme: theme,
                scrollDirection:
                    vm.isHorizontal ? Axis.horizontal : Axis.vertical,
                itemCount: daYunList.length,
                child: ListView(controller: _daYunScrollCtrl),
                builder: (context, idx) {
                  final dy = daYunList[idx];
                  final isSelected = idx == vm.selectedDaYunIdx;
                  return _DaYunTile(
                    data: dy,
                    index: idx,
                    isSelected: isSelected,
                    selectedLiuNianIdx:
                        isSelected ? vm.selectedLiuNianIdx : null,
                    isMini: vm.isMiniMode,
                    isExpanded: vm.isDaYunExpanded(idx),
                    onToggleExpand: () => vm.toggleDaYunExpand(idx),
                    onTileTap: () => vm.selectDaYun(idx),
                    onLiuNianTap: (lnIdx) {
                      vm.selectDaYun(idx);
                      vm.selectLiuNian(lnIdx);
                    },
                  );
                },
              ),

              // ── Tier 2: LiuNian Detail ──
              if (selectedDaYun != null && vm.selectedLiuNianIdx != null)
                _buildTierRow(
                  title: '流年 · ${selectedDaYun.pillar.name}大运',
                  horizontalHeight: _getTierHeight(2),
                  theme: theme,
                  scrollDirection:
                      vm.isHorizontal ? Axis.horizontal : Axis.vertical,
                  itemCount: selectedDaYun.liunian.length,
                  child: ListView(controller: _liuNianScrollCtrl),
                  builder: (context, lnIdx) {
                    final ln = selectedDaYun.liunian[lnIdx];
                    final isSelected = lnIdx == vm.selectedLiuNianIdx;
                    return _LiuNianDetailTile(
                      data: ln,
                      isSelected: isSelected,
                      selectedLiuYueIdx:
                          isSelected ? vm.selectedLiuYueIdx : null,
                      isMini: vm.isMiniMode,
                      isExpanded: vm.isLiuNianExpanded(lnIdx),
                      onToggleExpand: () => vm.toggleLiuNianExpand(lnIdx),
                      onTileTap: () => vm.selectLiuNian(lnIdx),
                      onLiuYueTap: (lyIdx) {
                        vm.selectLiuNian(lnIdx);
                        vm.selectLiuYue(lyIdx);
                      },
                    );
                  },
                ),

              // ── Tier 3: LiuYue Detail ──
              if (selectedLiuYue != null && selectedLiuNian != null)
                _buildTierRow(
                  title: '流月 · ${selectedLiuNian.year}年',
                  horizontalHeight: _getTierHeight(3),
                  theme: theme,
                  scrollDirection:
                      vm.isHorizontal ? Axis.horizontal : Axis.vertical,
                  itemCount: selectedLiuNian.liuyue.length,
                  child: ListView(controller: _liuYueScrollCtrl),
                  builder: (context, lyIdx) {
                    final ly = selectedLiuNian.liuyue[lyIdx];
                    final isSelected = lyIdx == vm.selectedLiuYueIdx;
                    return _LiuYueDetailTile(
                      data: ly,
                      year: selectedLiuNian.year,
                      isSelected: isSelected,
                      selectedDay: isSelected ? vm.selectedLiuRiDay : null,
                      isMini: vm.isMiniMode,
                      fetchLiuRiData: vm.fetchLiuRiData,
                      fetchLiuShiData: vm.fetchLiuShiData,
                      isExpanded: isSelected || vm.isLiuYueExpanded(lyIdx),
                      onToggleExpand: () => vm.toggleLiuYueExpand(lyIdx),
                      onTileTap: () => vm.selectLiuYue(lyIdx),
                      onDaySelected: (day) {
                        vm.selectLiuYue(lyIdx);
                        vm.selectLiuRi(day);
                      },
                    );
                  },
                ),

              // ── Tier 4: LiuRi Detail ──
              if (vm.selectedLiuRiDay != null &&
                  selectedLiuYue != null &&
                  selectedLiuNian != null)
                Builder(builder: (context) {
                  final dt = DateTime(selectedLiuNian.year,
                      selectedLiuYue.gregorianMonth + 1, 0);
                  final daysInMonth = dt.day;
                  return _buildTierRow(
                    title:
                        '流日 · ${selectedLiuNian.year}年${selectedLiuYue.gregorianMonth}月',
                    horizontalHeight: _getTierHeight(4),
                    theme: theme,
                    scrollDirection:
                        vm.isHorizontal ? Axis.horizontal : Axis.vertical,
                    itemCount: daysInMonth,
                    child: ListView(controller: _liuRiScrollCtrl),
                    builder: (context, idx) {
                      final day = idx + 1;
                      final isSelected = day == vm.selectedLiuRiDay;
                      return _LiuRiDetailTile(
                        year: selectedLiuNian.year,
                        month: selectedLiuYue.gregorianMonth,
                        day: day,
                        isSelected: isSelected,
                        selectedLiuShiIdx:
                            isSelected ? vm.selectedLiuShiIdx : null,
                        isExpanded: true,
                        isMini: vm.isMiniMode,
                        fetchLiuRiData: vm.fetchLiuRiData,
                        fetchLiuShiData: vm.fetchLiuShiData,
                        onToggleExpand: () {},
                        onTileTap: () => vm.selectLiuRi(day),
                        onLiuShiTap: (shiIdx) {
                          vm.selectLiuRi(day);
                          vm.selectLiuShi(shiIdx);
                        },
                      );
                    },
                  );
                }),

              // ── Tier 5: LiuShi Detail ──
              if (vm.selectedLiuShiIdx != null &&
                  vm.selectedLiuRiDay != null &&
                  selectedLiuYue != null &&
                  selectedLiuNian != null)
                Builder(builder: (context) {
                  return _buildTierRow(
                    title:
                        '流时 · ${selectedLiuNian.year}年${selectedLiuYue.gregorianMonth}月${vm.selectedLiuRiDay}日',
                    horizontalHeight: _getTierHeight(5),
                    theme: theme,
                    scrollDirection:
                        vm.isHorizontal ? Axis.horizontal : Axis.vertical,
                    itemCount: 12, // 12 Chinese hours
                    child: ListView(controller: _liuShiScrollCtrl),
                    builder: (context, shiIdx) {
                      final isSelected = shiIdx == vm.selectedLiuShiIdx;
                      return GestureDetector(
                        onTap: () => vm.selectLiuShi(shiIdx),
                        child: _LiuShiDetailTile(
                          year: selectedLiuNian.year,
                          month: selectedLiuYue.gregorianMonth,
                          day: vm.selectedLiuRiDay!,
                          shiIdx: shiIdx,
                          isSelected: isSelected,
                          isMini: vm.isMiniMode,
                          fetchLiuShiData: vm.fetchLiuShiData,
                        ),
                      );
                    },
                  );
                }),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DaYun Tile (Tier 1 card)
// ─────────────────────────────────────────────────────────────────────────────

class _YunLiuPillarCard extends StatelessWidget {
  final String gan;
  final String zhi;
  final String tenGod;
  final List<({String gan, String hiddenGod})> hiddenGans;
  final String bottomText;
  final String topCornerTag;
  final bool isSelected;
  final Widget? content;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;
  final bool isMini;
  final String? jieQiTag;

  const _YunLiuPillarCard({
    required this.gan,
    required this.zhi,
    required this.tenGod,
    required this.hiddenGans,
    required this.bottomText,
    required this.topCornerTag,
    this.isSelected = true,
    this.content,
    this.isExpanded = true,
    this.onToggleExpand,
    this.isMini = false,
    this.jieQiTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = YunLiuCardTheme.of(context);
    // t=0 → full size, t=1 → mini — animated by TweenAnimationBuilder
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: isMini ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, t, _) {
        final ganZhiSize = lerpDouble(44, 26, t)!;
        final tenGodSize = lerpDouble(18, 11, t)!;
        final hiddenStemSize = lerpDouble(14, 10, t)!;
        final vertPad = lerpDouble(12, 5, t)!;
        final separatorH = lerpDouble(80, 44, t)!;
        final bottomFontSize = lerpDouble(12, 10, t)!;
        final iconSize = lerpDouble(20, 16, t)!;
        final cardWidth =
            lerpDouble(theme.daYunCardWidth, theme.daYunCardWidth * 0.75, t)!;
        return Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: cardWidth,
              clipBehavior: Clip.hardEdge,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: vertPad),
              decoration: BoxDecoration(
                color: InkTheme.paperSoft,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? InkTheme.cinnabar : InkTheme.borderLight,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: InkTheme.cinnabar.withAlpha(25),
                          blurRadius: 24,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header: Pillar + Info ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left: GanZhi pillar (Huge)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            gan,
                            style: TextStyle(
                              fontSize: ganZhiSize,
                              fontWeight: FontWeight.w900,
                              color: InkTheme.ink,
                              height: 1.05,
                              fontFamilyFallback: theme.serifFonts,
                            ),
                          ),
                          Text(
                            zhi,
                            style: TextStyle(
                              fontSize: ganZhiSize,
                              fontWeight: FontWeight.w900,
                              color: InkTheme.ink,
                              height: 1.05,
                              fontFamilyFallback: theme.serifFonts,
                            ),
                          ),
                        ],
                      ),
                      // Separator
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 2,
                        height: separatorH,
                        color: InkTheme.cinnabar,
                      ),
                      // Right: Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Row 1: TenGod + expand toggle
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  tenGod,
                                  style: TextStyle(
                                    fontSize: tenGodSize,
                                    fontWeight: FontWeight.w600,
                                    color: InkTheme.inkMuted,
                                    fontFamilyFallback: theme.serifFonts,
                                  ),
                                ),
                                const Spacer(),
                                if (content != null && onToggleExpand != null)
                                  GestureDetector(
                                    onTap: onToggleExpand,
                                    child: AnimatedRotation(
                                      turns: isExpanded ? 0.0 : 0.5,
                                      duration:
                                          const Duration(milliseconds: 250),
                                      curve: Curves.easeInOut,
                                      child: Icon(
                                        Icons.keyboard_arrow_up,
                                        size: iconSize,
                                        color: InkTheme.inkMuted,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            // Row 2: Hidden stems
                            if (hiddenGans.isNotEmpty)
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: hiddenGans.map((h) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: InkTheme.paperAlt,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: hiddenStemSize,
                                          fontFamilyFallback: theme.serifFonts,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: h.gan,
                                            style: TextStyle(
                                              color: InkTheme.gold,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const TextSpan(text: " "),
                                          TextSpan(
                                            text: h.hiddenGod,
                                            style: TextStyle(
                                              color: InkTheme.inkDeep,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 4),
                            // Row 3: Year / age
                            Text(
                              bottomText,
                              style: TextStyle(
                                fontSize: bottomFontSize,
                                color: InkTheme.textMuted,
                                fontFamilyFallback: const ['sans-serif'],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Expandable content with smooth AnimatedSize
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: content != null && isExpanded
                        ? ClipRect(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: content!,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (jieQiTag != null)
                    Container(
                      margin: const EdgeInsets.only(top: 4, right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E5A3C),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        jieQiTag!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? InkTheme.cinnabar : InkTheme.paperSoft,
                      border: Border.all(
                        color: InkTheme.cinnabar,
                        width: 0.5,
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      topCornerTag,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : InkTheme.cinnabar,
                        fontFamilyFallback: const ['sans-serif'],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DaYunTile extends StatelessWidget {
  final DaYunDisplayData data;
  final int index;
  final bool isSelected;
  final int? selectedLiuNianIdx;
  final VoidCallback onTileTap;
  final ValueChanged<int> onLiuNianTap;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final bool isMini;

  static const _chineseOrdinals = [
    '一',
    '二',
    '三',
    '四',
    '五',
    '六',
    '七',
    '八',
    '九',
    '十'
  ];

  const _DaYunTile({
    required this.data,
    required this.index,
    required this.isSelected,
    required this.selectedLiuNianIdx,
    required this.onTileTap,
    required this.onLiuNianTap,
    required this.isExpanded,
    required this.onToggleExpand,
    this.isMini = false,
  });

  @override
  Widget build(BuildContext context) {
    final badgeLabel = index < _chineseOrdinals.length
        ? '大运·${_chineseOrdinals[index]}'
        : '大运·${index + 1}';

    return GestureDetector(
      onTap: onTileTap,
      child: _YunLiuPillarCard(
        gan: data.pillar.gan.name,
        zhi: data.pillar.zhi.name,
        tenGod: data.ganGod.name,
        hiddenGans: data.hiddenGans
            .map((h) => (gan: h.gan.name, hiddenGod: h.hiddenGods.name))
            .toList(),
        bottomText:
            '${data.startYear} — ${data.startYear + data.yearsCount - 1} · '
            '${data.startAge}~${data.startAge + data.yearsCount}岁',
        topCornerTag: badgeLabel,
        isSelected: isSelected,
        isExpanded: isExpanded,
        onToggleExpand: onToggleExpand,
        isMini: isMini,
        content: _buildLiuNianGrid(),
      ),
    );
  }

  Widget _buildLiuNianGrid() {
    final items = data.liunian;
    return GridView.builder(
      padding: const EdgeInsets.all(6),
      clipBehavior: Clip.none,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.7,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final ln = items[i];
        final isActive = selectedLiuNianIdx == i;
        return _IndexChip(
          gz: ln.pillar.name,
          ganGodShort: ln.ganGod.shortName,
          firstHiddenGodShort: ln.hiddenGans.isNotEmpty
              ? ln.hiddenGans.first.hiddenGods.shortName
              : '',
          label: '${ln.year}',
          isActive: isActive,
          isToday: ln.year == DateTime.now().year,
          activeBorderColor: const Color(0xFF2E5A3C),
          activeBackgroundColor: const Color(0xFF2E5A3C).withAlpha(13),
          ganGodColor: const Color(0xFF2E5A3C),
          hiddenGodColor: InkTheme.gold,
          isMini: isMini,
          onTap: () => onLiuNianTap(i),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LiuNian Detail Tile (Tier 2 card)
// ─────────────────────────────────────────────────────────────────────────────

class _LiuNianDetailTile extends StatelessWidget {
  final LiuNianDisplayData data;
  final bool isSelected;
  final int? selectedLiuYueIdx;
  final VoidCallback onTileTap;
  final ValueChanged<int> onLiuYueTap;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final bool isMini;

  const _LiuNianDetailTile({
    required this.data,
    required this.isSelected,
    required this.selectedLiuYueIdx,
    required this.onTileTap,
    required this.onLiuYueTap,
    required this.isExpanded,
    required this.onToggleExpand,
    this.isMini = false,
  });

  @override
  Widget build(BuildContext context) {
    final badgeLabel = '流年 · ${data.pillar.name}';

    return GestureDetector(
      onTap: onTileTap,
      child: _YunLiuPillarCard(
        gan: data.pillar.gan.name,
        zhi: data.pillar.zhi.name,
        tenGod: data.ganGod.name,
        hiddenGans: data.hiddenGans
            .map((h) => (gan: h.gan.name, hiddenGod: h.hiddenGods.name))
            .toList(),
        bottomText: '${data.year}年 · ${data.age}岁',
        topCornerTag: badgeLabel,
        isSelected: isSelected,
        isExpanded: isExpanded,
        onToggleExpand: onToggleExpand,
        isMini: isMini,
        content: _buildLiuYueGrid(),
      ),
    );
  }

  Widget _buildLiuYueGrid() {
    final items = data.liuyue;
    return GridView.builder(
      padding: const EdgeInsets.all(6),
      clipBehavior: Clip.none,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.3,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final ly = items[i];
        final isActive = selectedLiuYueIdx == i;

        return _IndexChip(
          gz: ly.ganZhi,
          ganGodShort: EnumTenGods.values
              .firstWhere((e) => e.name == ly.tenGodName,
                  orElse: () => EnumTenGods.ZhengYin)
              .shortName,
          firstHiddenGodShort: ly.hidden.isNotEmpty
              ? EnumTenGods.values
                  .firstWhere((e) => e.name == ly.hidden.first.tenGod,
                      orElse: () => EnumTenGods.ZhengYin)
                  .shortName
              : '',
          label: ly.monthName,
          isActive: isActive,
          isToday: ly.gregorianMonth == DateTime.now().month,
          activeBorderColor: const Color(0xFF2E5A3C),
          activeBackgroundColor: const Color(0xFF2E5A3C).withAlpha(13),
          ganGodColor: const Color(0xFF2E5A3C),
          hiddenGodColor: InkTheme.textMuted,
          isMini: isMini,
          onTap: () => onLiuYueTap(i),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LiuYue Detail Tile (Tier 3 card)
// ─────────────────────────────────────────────────────────────────────────────

class _LiuYueDetailTile extends StatelessWidget {
  final LiuYueDisplayData data;
  final int year;
  final bool isSelected;
  final int? selectedDay;
  final VoidCallback onTileTap;
  final ValueChanged<int> onDaySelected;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final bool isMini;
  final List<LiuRiDisplayData> Function(int year, int month)? fetchLiuRiData;
  final List<LiuShiDisplayData> Function(int year, int month, int day)?
      fetchLiuShiData;

  const _LiuYueDetailTile({
    required this.data,
    required this.year,
    required this.isSelected,
    required this.selectedDay,
    required this.onTileTap,
    required this.onDaySelected,
    required this.isExpanded,
    required this.onToggleExpand,
    this.isMini = false,
    this.fetchLiuRiData,
    this.fetchLiuShiData,
  });

  @override
  Widget build(BuildContext context) {
    final badgeLabel = '流月 · ${data.monthName}';
    final String gz = data.ganZhi;
    final gan = gz.isNotEmpty ? gz[0] : '';
    final zhi = gz.length > 1 ? gz[1] : '';

    final lunarDay =
        SolarDay.fromYmd(year, data.gregorianMonth, 15).getLunarDay();
    final lunarYearName = lunarDay.getLunarMonth().getLunarYear().getName();
    final lunarMonthName = lunarDay.getLunarMonth().getName();
    final lunarText = lunarYearName.replaceFirst('农历', '农历 ') + lunarMonthName;

    return GestureDetector(
      onTap: onTileTap,
      child: _YunLiuPillarCard(
        gan: gan,
        zhi: zhi,
        tenGod: data.tenGodName,
        hiddenGans:
            data.hidden.map((h) => (gan: h.gan, hiddenGod: h.tenGod)).toList(),
        bottomText: '$year年 · ${data.monthName} · $lunarText',
        topCornerTag: badgeLabel,
        isSelected: isSelected,
        isExpanded: isExpanded,
        onToggleExpand: onToggleExpand,
        isMini: isMini,
        content: _LiuRiCalendarGrid(
          year: year,
          month: data.gregorianMonth,
          selectedDay: selectedDay,
          onDaySelected: onDaySelected,
          fetchLiuRiData: fetchLiuRiData,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LiuRi Detail Tile (Tier 4 card)
// ─────────────────────────────────────────────────────────────────────────────

class _LiuRiDetailTile extends StatelessWidget {
  final int year;
  final int month;
  final int day;
  final bool isSelected;
  final int? selectedLiuShiIdx;
  final VoidCallback onTileTap;
  final ValueChanged<int> onLiuShiTap;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final bool isMini;
  final List<LiuRiDisplayData> Function(int year, int month)? fetchLiuRiData;
  final List<LiuShiDisplayData> Function(int year, int month, int day)?
      fetchLiuShiData;

  const _LiuRiDetailTile({
    required this.year,
    required this.month,
    required this.day,
    required this.isSelected,
    required this.selectedLiuShiIdx,
    required this.onTileTap,
    required this.onLiuShiTap,
    required this.isExpanded,
    required this.onToggleExpand,
    this.isMini = false,
    this.fetchLiuRiData,
    this.fetchLiuShiData,
  });

  @override
  Widget build(BuildContext context) {
    if (fetchLiuRiData == null) return const SizedBox.shrink();
    final dataList = fetchLiuRiData!(year, month);
    final data = dataList.firstWhere((e) => e.gregorianDay == day,
        orElse: () => dataList.first);

    final String gz = data.ganZhi;
    final gan = gz.isNotEmpty ? gz[0] : '';
    final zhi = gz.length > 1 ? gz[1] : '';

    return GestureDetector(
      onTap: onTileTap,
      child: _YunLiuPillarCard(
        gan: gan,
        zhi: zhi,
        tenGod: data.tenGodName,
        hiddenGans:
            data.hidden.map((h) => (gan: h.gan, hiddenGod: h.tenGod)).toList(),
        bottomText: '$year年$month月$day日 · ${data.lunarText}',
        topCornerTag: data.isToday ? '流日 · 今日' : '流日',
        jieQiTag: data.jieQiName,
        isSelected: data.isToday || isSelected,
        isExpanded: isExpanded,
        onToggleExpand: onToggleExpand,
        isMini: isMini,
        content: _buildLiuShiGrid(gan),
      ),
    );
  }

  Widget _buildLiuShiGrid(String dayGan) {
    if (fetchLiuShiData == null) return const SizedBox.shrink();
    final dataList = fetchLiuShiData!(year, month, day);

    return GridView.builder(
      padding: const EdgeInsets.all(6),
      clipBehavior: Clip.none,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.3,
      ),
      itemCount: 12,
      itemBuilder: (context, i) {
        final isActive = selectedLiuShiIdx == i;
        final data = dataList[i];

        final shortNames = {
          '正财': '财',
          '偏财': '才',
          '正印': '印',
          '偏印': '枭',
          '食神': '食',
          '伤官': '伤',
          '正官': '官',
          '偏官': '杀',
          '比肩': '比',
          '劫财': '劫'
        };
        final shortFakeGod = shortNames[data.tenGodName] ?? data.tenGodName;
        final shortFakeHiddenGod = data.hidden.isNotEmpty
            ? (shortNames[data.hidden.first.tenGod] ?? data.hidden.first.tenGod)
            : '';

        return _IndexChip(
          gz: data.ganZhi,
          ganGodShort: shortFakeGod,
          firstHiddenGodShort: shortFakeHiddenGod,
          label: data.zhiTime,
          isActive: isActive,
          activeBorderColor: const Color(0xFF2E5A3C),
          activeBackgroundColor: const Color(0xFF2E5A3C).withAlpha(13),
          ganGodColor: const Color(0xFF2E5A3C),
          hiddenGodColor: InkTheme.gold,
          isMini: isMini,
          topCornerTag: data.jieQiName,
          onTap: () => onLiuShiTap(i),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LiuShi Detail Tile (Tier 5 card)
// ─────────────────────────────────────────────────────────────────────────────

class _LiuShiDetailTile extends StatelessWidget {
  final int year;
  final int month;
  final int day;
  final int shiIdx;
  final bool isSelected;
  final bool isMini;
  final List<LiuShiDisplayData> Function(int year, int month, int day)?
      fetchLiuShiData;

  const _LiuShiDetailTile({
    required this.year,
    required this.month,
    required this.day,
    required this.shiIdx,
    required this.isSelected,
    this.isMini = false,
    this.fetchLiuShiData,
  });

  @override
  Widget build(BuildContext context) {
    if (fetchLiuShiData == null) return const SizedBox.shrink();
    final dataList = fetchLiuShiData!(year, month, day);
    final data = dataList.firstWhere((e) => e.shiIdx == shiIdx,
        orElse: () => dataList.first);

    final gan = data.ganZhi.isNotEmpty ? data.ganZhi[0] : '';
    final shiZhi = data.ganZhi.length > 1 ? data.ganZhi[1] : '';

    return _YunLiuPillarCard(
      gan: gan,
      zhi: shiZhi,
      tenGod: data.tenGodName,
      hiddenGans:
          data.hidden.map((h) => (gan: h.gan, hiddenGod: h.tenGod)).toList(),
      bottomText: '$year年$month月$day日 ${data.zhiTime}时',
      topCornerTag: '流时',
      jieQiTag: data.jieQiName,
      isSelected: isSelected,
      isMini: isMini,
      content: null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Index Chip (2×2 Grid layout: GanZhi left, Gods right, Label below)
// ─────────────────────────────────────────────────────────────────────────────

class _IndexChip extends StatelessWidget {
  final String gz;
  final String ganGodShort;
  final String firstHiddenGodShort;
  final String label;
  final bool isActive;
  final Color activeBorderColor;
  final Color activeBackgroundColor;
  final Color ganGodColor;
  final Color hiddenGodColor;
  final VoidCallback onTap;

  /// "今" tag — indicates this chip is "today".
  final bool isToday;

  /// Optional explicit tag, e.g., a JieQi name like '惊蛰'. Takes precedence or merges with '今'/'选'.
  final String? topCornerTag;

  const _IndexChip({
    required this.gz,
    required this.ganGodShort,
    required this.firstHiddenGodShort,
    required this.label,
    required this.isActive,
    required this.activeBorderColor,
    required this.activeBackgroundColor,
    required this.ganGodColor,
    required this.hiddenGodColor,
    required this.onTap,
    this.isToday = false,
    this.isMini = false,
    this.topCornerTag,
  });

  final bool isMini;

  @override
  Widget build(BuildContext context) {
    final theme = YunLiuCardTheme.of(context);

    final fontSizeGz = isMini ? 11.0 : 15.0;
    final fontSizeLabel = isMini ? 6.0 : 8.0;
    final fontSizeGods = isMini ? 7.0 : 10.0;
    final tagSize = isMini ? 12.0 : 16.0;
    final tagFontSize = isMini ? 6.0 : 8.0;
    final spacingMain = isMini ? 2.0 : 6.0;
    final padVert = isMini ? 2.0 : 4.0;
    final padHoriz = isMini ? 1.0 : 3.0;

    // Determine tag text & color
    String? finalTagText;
    Color tagColor;

    if (topCornerTag != null && topCornerTag!.isNotEmpty) {
      finalTagText = topCornerTag;
      if (isToday) {
        tagColor = InkTheme.cinnabar;
      } else if (isActive) {
        tagColor = const Color(0xFF2E5A3C);
      } else {
        tagColor = const Color(0xFF2E5A3C); // Default JieQi color
      }
    } else if (isToday) {
      finalTagText = '今';
      tagColor = InkTheme.cinnabar;
    } else if (isActive) {
      finalTagText = '选';
      tagColor = const Color(0xFF2E5A3C); // 墨绿色
    } else {
      finalTagText = null;
      tagColor = Colors.transparent;
    }

    // Adaptive tag sizing based on text length
    double effectiveTagWidth = tagSize;
    if (finalTagText != null && finalTagText.length > 1) {
      effectiveTagWidth =
          tagSize + (finalTagText.length - 1) * (tagFontSize * 1.5) + 4;
    }

    // Determine active styling
    final showActive = isActive || isToday;
    Color currentBorderColor = activeBorderColor;
    Color currentBgColor = activeBackgroundColor;

    if (isToday) {
      currentBorderColor = InkTheme.cinnabar;
      currentBgColor = InkTheme.cinnabar.withAlpha(13);
    } else if (isActive) {
      // Ensure active selection uses the dark green color mapping
      currentBorderColor = const Color(0xFF2E5A3C);
      currentBgColor = const Color(0xFF2E5A3C).withAlpha(13);
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(clipBehavior: Clip.none, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              EdgeInsets.symmetric(horizontal: padHoriz, vertical: padVert),
          decoration: BoxDecoration(
            color: showActive ? currentBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: showActive ? currentBorderColor : Colors.transparent,
              width: 1,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: spacingMain),
                // Left: GanZhi + label
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      gz,
                      style: TextStyle(
                        fontSize: fontSizeGz,
                        fontWeight: FontWeight.w800,
                        color: InkTheme.ink,
                        height: 1.0,
                        fontFamilyFallback: theme.serifFonts,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: fontSizeLabel,
                        color: InkTheme.textMuted,
                        fontFamilyFallback: const ['sans-serif'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 2),
                // Right: stacked gods
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ganGodShort,
                      style: TextStyle(
                        fontSize: fontSizeGods,
                        fontWeight: FontWeight.w600,
                        color: ganGodColor,
                        height: 1.0,
                        fontFamilyFallback: theme.serifFonts,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      firstHiddenGodShort,
                      style: TextStyle(
                        fontSize: fontSizeGods,
                        fontWeight: FontWeight.w600,
                        color: hiddenGodColor,
                        height: 1.0,
                        fontFamilyFallback: theme.serifFonts,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Floating tag (top-left corner)
        if (finalTagText != null)
          Positioned(
            top: -6,
            left: -6,
            child: Container(
              width: effectiveTagWidth,
              height: tagSize,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: tagColor,
                borderRadius:
                    (finalTagText.length > 1 || finalTagText.length > 2)
                        ? BorderRadius.circular(10)
                        : null,
                shape: (finalTagText.length > 1 || finalTagText.length > 2)
                    ? BoxShape.rectangle
                    : BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                finalTagText,
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize:
                      finalTagText.length > 1 ? tagFontSize - 1 : tagFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                  fontFamilyFallback: const ['sans-serif'],
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

class _LiuRiCalendarGrid extends StatelessWidget {
  final int year;
  final int month;
  final int? selectedDay;
  final ValueChanged<int> onDaySelected;
  final List<LiuRiDisplayData> Function(int year, int month)? fetchLiuRiData;

  const _LiuRiCalendarGrid({
    required this.year,
    required this.month,
    required this.selectedDay,
    required this.onDaySelected,
    this.fetchLiuRiData,
  });

  @override
  Widget build(BuildContext context) {
    final first = DateTime(year, month, 1);
    final next = DateTime(year, month + 1, 1);
    final days = next.subtract(const Duration(days: 1)).day;
    final leading = (first.weekday - DateTime.monday) % 7;

    final items = <DateTime?>[];
    for (var i = 0; i < leading; i++) {
      items.add(null);
    }
    for (var d = 1; d <= days; d++) {
      items.add(DateTime(year, month, d));
    }
    while (items.length % 7 != 0) {
      items.add(null);
    }

    final today = DateTime.now();
    final rows = items.isEmpty ? 0 : (items.length ~/ 7);
    final cellMargin = 1.0;

    final dataList = fetchLiuRiData != null
        ? fetchLiuRiData!(year, month)
        : <LiuRiDisplayData>[];
    final dataMap = {for (var e in dataList) e.gregorianDay: e};

    return LayoutBuilder(builder: (context, constraints) {
      final availableWidth = constraints.maxWidth;
      final rowH =
          (availableWidth / 7) * 1; // Standard portrait aspect ratio for cells

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week header
          SizedBox(
            height: 20,
            child: Row(
              children: const ['一', '二', '三', '四', '五', '六', '日']
                  .map(
                    (e) => Expanded(
                      child: Center(
                        child: Text(
                          e,
                          style: TextStyle(
                            fontSize: 11,
                            color: InkTheme.inkMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 6),
          // Days Grid
          for (var r = 0; r < rows; r++)
            SizedBox(
              height: rowH,
              child: Row(
                children: [
                  for (var c = 0; c < 7; c++)
                    Expanded(
                      child: _buildCell(
                        items[r * 7 + c],
                        today,
                        cellMargin,
                        dataMap,
                      ),
                    ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _buildCell(DateTime? dt, DateTime today, double cellMargin,
      Map<int, LiuRiDisplayData> dataMap) {
    if (dt == null) {
      return Padding(
        padding: EdgeInsets.all(cellMargin),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(40),
            border: Border.all(
                color: InkTheme.borderStone.withAlpha(100), width: 0.6),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    final data = dataMap[dt.day];
    if (data == null) return const SizedBox.shrink();

    final ganText = data.ganZhi.isNotEmpty ? data.ganZhi[0] : '';
    final zhiText = data.ganZhi.length > 1 ? data.ganZhi[1] : '';

    return Padding(
      padding: EdgeInsets.all(cellMargin),
      child: _LiuDayMiniCell(
        day: dt.day,
        ganText: ganText,
        zhiText: zhiText,
        tenGodName: data.tenGodName,
        jieQiName: data.jieQiName,
        hidden: data.hidden,
        isToday: data.isToday,
        isSelected: selectedDay == dt.day,
        onTap: () => onDaySelected(dt.day),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mini Day Cell — Professional UI for 7×5 calendar grid
//
// Design canvas: 100 × 130 (portrait, matches grid aspect ratio ~1:1.28)
// Visual hierarchy:  Day# (subtle) → GanZhi (hero) → TenGod (accent) → Hidden (muted)
// ─────────────────────────────────────────────────────────────────────────────

class _LiuDayMiniCell extends StatelessWidget {
  final int day;
  final String ganText;
  final String zhiText;
  final String tenGodName;
  final String? jieQiName;
  final List<({String gan, String tenGod})> hidden;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  const _LiuDayMiniCell({
    required this.day,
    required this.ganText,
    required this.zhiText,
    required this.tenGodName,
    this.jieQiName,
    required this.hidden,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = YunLiuCardTheme.of(context);

    final showActive = isToday || isSelected;
    final accent = isToday ? theme.todayColor : theme.activeColor;

    // ── Colors ──────────────────────────────────────────
    final borderColor = showActive ? accent : InkTheme.ink.withAlpha(40);
    final bgColor = showActive ? accent.withAlpha(10) : InkTheme.paperCell;
    final dayNumColor = showActive ? accent : InkTheme.inkMuted;
    final gzColor = showActive ? accent : InkTheme.inkDeep;
    final godColor = showActive ? accent : InkTheme.cinnabar;

    // ── Design canvas ──────────────────────────────────
    const w = 130.0;
    const h = 130.0;

    return GestureDetector(
      onTap: onTap,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.noScaling,
        ),
        child: SizedBox(
          width: w,
          height: h,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            clipBehavior: Clip.none,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(
                color: borderColor,
                width: showActive ? 2.0 : 1.0,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  offset: const Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // ── Layer 1: Left GanZhi (Tightly kerned vertically) ──
                Positioned(
                  left: 8,
                  top: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ganText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: gzColor,
                          height: 1.0,
                          fontFamilyFallback: theme.serifFonts,
                        ),
                      ),
                      Text(
                        zhiText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: gzColor,
                          height: 1.0,
                          fontFamilyFallback: theme.serifFonts,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Layer 2: Right TenGod + Hidden (Main Qi only) ──
                Positioned(
                  right: 8,
                  top: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TenGod — main label
                      Text(
                        _shortGod(tenGodName),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: godColor,
                          height: 1.0,
                          fontFamilyFallback: theme.serifFonts,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Hidden gods — Main Qi only
                      if (hidden.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.ideographic,
                          children: [
                            Text(
                              _shortGod(hidden.first.tenGod),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: godColor,
                                height: 1,
                                fontFamilyFallback: theme.serifFonts,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // ── Layer 2.5: JieQi Tag (top-right) ──
                if (jieQiName != null)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: showActive
                            ? Theme.of(context).primaryColor
                            : const Color(0xFF2E5A3C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        jieQiName!,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.1,
                          fontFamilyFallback: theme.serifFonts,
                        ),
                      ),
                    ),
                  ),

                // ── Layer 3: Day number / Floating Corner Tag (top-left) ──
                AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: 18,
                    height: 14,
                    decoration: BoxDecoration(
                        color: showActive
                            ? (isToday ? theme.todayColor : theme.activeColor)
                            : Colors.transparent,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            bottomRight: Radius.circular(6))),
                    alignment: Alignment.center),
                Positioned(
                  top: 3,
                  left: 4,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          showActive ? FontWeight.w800 : FontWeight.w700,
                      color: showActive ? Colors.white : dayNumColor,
                      height: 1.0,
                      fontFamilyFallback: const ['sans-serif'],
                    ),
                    child: Text('$day'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shorten a two-char god name to one char for compact display.
  /// e.g. '正印' → '印', '偏财' → '才', '比肩' → '比'
  static String _shortGod(String tenGod) {
    if (tenGod.length >= 2) return tenGod[1];
    return tenGod;
  }
}

import 'dart:ui' show lerpDouble;
import 'package:common/enums.dart';
import 'package:common/features/liu_yun/themes/ink_theme.dart';
import 'package:flutter/material.dart';
import 'package:tyme/tyme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data types
// ─────────────────────────────────────────────────────────────────────────────

/// Display data for a single Liu-Yue (Monthly Luck) entry.
class LiuYueDisplayData {
  final String monthName; // e.g., '正月'
  final int gregorianMonth; // e.g. 2 for February (used for calendar layout)
  final String ganZhi;
  final String tenGodName;
  final List<({String gan, String tenGod})> hidden;

  const LiuYueDisplayData({
    required this.monthName,
    required this.gregorianMonth,
    required this.ganZhi,
    required this.tenGodName,
    required this.hidden,
  });
}

/// Display data for a single Liu-Nian (Annual Luck) entry.
typedef LiuNianDisplayData = ({
  JiaZi pillar,
  EnumTenGods ganGod,
  List<({TianGan gan, EnumTenGods hiddenGods})> hiddenGans,
  int year,
  int age,
  List<LiuYueDisplayData> liuyue,
});

/// Display data for a single Da-Yun (Great Luck) period.
typedef DaYunDisplayData = ({
  JiaZi pillar,
  EnumTenGods ganGod,
  List<({TianGan gan, EnumTenGods hiddenGods})> hiddenGans,
  int startYear,
  int startAge,
  int yearsCount,
  List<LiuNianDisplayData> liunian,
});

class LiuRiDisplayData {
  final int gregorianYear;
  final int gregorianMonth;
  final int gregorianDay;
  final String ganZhi;
  final String tenGodName;
  final List<({String gan, String tenGod})> hidden;
  final String? jieQiName;
  final String lunarText;
  final bool isToday;

  const LiuRiDisplayData({
    required this.gregorianYear,
    required this.gregorianMonth,
    required this.gregorianDay,
    required this.ganZhi,
    required this.tenGodName,
    required this.hidden,
    this.jieQiName,
    required this.lunarText,
    required this.isToday,
  });
}

class LiuShiDisplayData {
  final int shiIdx;
  final String zhiTime;
  final String ganZhi;
  final String tenGodName;
  final List<({String gan, String tenGod})> hidden;
  final String? jieQiName;

  const LiuShiDisplayData({
    required this.shiIdx,
    required this.zhiTime,
    required this.ganZhi,
    required this.tenGodName,
    required this.hidden,
    this.jieQiName,
  });
}

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
  final List<DaYunDisplayData> daYunList;

  // Initial selection indices (0-indexed)
  final int initialSelectedDaYunIndex;
  final int initialSelectedLiuNianIndex;
  final int initialSelectedLiuYueIndex;

  // External delegates for fetching deep data
  final List<LiuRiDisplayData> Function(int year, int month) fetchLiuRiData;
  final List<LiuShiDisplayData> Function(int year, int month, int day)
      fetchLiuShiData;

  const YunLiuListTileCardWidget({
    super.key,
    required this.daYunList,
    this.initialSelectedDaYunIndex = 0,
    this.initialSelectedLiuNianIndex = 0,
    this.initialSelectedLiuYueIndex = 0,
    required this.fetchLiuRiData,
    required this.fetchLiuShiData,
  });

  @override
  State<YunLiuListTileCardWidget> createState() =>
      _YunLiuListTileCardWidgetState();
}

class _YunLiuListTileCardWidgetState extends State<YunLiuListTileCardWidget> {
  int _selectedDaYunIdx = 0;
  int? _selectedLiuNianIdx;
  int? _selectedLiuYueIdx;
  int? _selectedLiuRiDay;
  int? _selectedLiuShiIdx;

  // View settings
  bool _isGlobalExpanded = true;
  bool _isHorizontalView = true;
  bool _isMiniMode = false;

  // Local expand states: key is tier, value is set of expanded indices
  // For simplicity, we just use a bool for the whole widget or we could track per card.
  // The global toggle will force all these to true/false.
  // We will pass the global state down as default unless overridden locally.
  final Map<int, bool> _localDaYunExpanded = {};
  final Map<int, bool> _localLiuNianExpanded = {};
  final Map<int, bool> _localLiuYueExpanded = {};
  final Map<int, bool> _localLiuRiExpanded = {};

  final ScrollController _daYunScrollCtrl = ScrollController();
  final ScrollController _liuNianScrollCtrl = ScrollController();
  final ScrollController _liuYueScrollCtrl = ScrollController();
  final ScrollController _liuRiScrollCtrl = ScrollController();
  final ScrollController _liuShiScrollCtrl = ScrollController();

  void _toggleGlobalExpanded() {
    setState(() {
      _isGlobalExpanded = !_isGlobalExpanded;
      _localDaYunExpanded.clear();
      _localLiuNianExpanded.clear();
      _localLiuYueExpanded.clear();
      _localLiuRiExpanded.clear();
    });
  }

  void _toggleViewDirection() {
    setState(() {
      _isHorizontalView = !_isHorizontalView;
    });
  }

  void _toggleMiniMode() {
    setState(() {
      _isMiniMode = !_isMiniMode;
    });
  }

  bool _isDaYunExpanded(int idx) =>
      _localDaYunExpanded[idx] ?? _isGlobalExpanded;
  bool _isLiuNianExpanded(int idx) =>
      _localLiuNianExpanded[idx] ?? _isGlobalExpanded;
  bool _isLiuYueExpanded(int idx) =>
      _localLiuYueExpanded[idx] ?? _isGlobalExpanded;
  bool _isLiuRiExpanded(int idx) =>
      _localLiuRiExpanded[idx] ?? _isGlobalExpanded;

  @override
  void initState() {
    super.initState();
    _syncWithSelectedDate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final theme = YunLiuCardTheme.of(context); // Get theme from context
      _scrollToCenter(
          _daYunScrollCtrl, _selectedDaYunIdx, theme.daYunCardWidth);
      if (_selectedLiuNianIdx != null) {
        _scrollToCenter(
            _liuNianScrollCtrl, _selectedLiuNianIdx!, theme.daYunCardWidth);
      }
      if (_selectedLiuYueIdx != null) {
        _scrollToCenter(
            _liuYueScrollCtrl, _selectedLiuYueIdx!, theme.daYunCardWidth);
      }
      if (_selectedLiuRiDay != null) {
        _scrollToCenter(
            _liuRiScrollCtrl, _selectedLiuRiDay! - 1, theme.daYunCardWidth);
      }
      if (_selectedLiuShiIdx != null) {
        _scrollToCenter(
            _liuShiScrollCtrl, _selectedLiuShiIdx!, theme.daYunCardWidth);
      }
    });
  }

  @override
  void dispose() {
    _daYunScrollCtrl.dispose();
    _liuNianScrollCtrl.dispose();
    _liuYueScrollCtrl.dispose();
    _liuRiScrollCtrl.dispose();
    _liuShiScrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToCenter(ScrollController ctrl, int index, double itemWidth) {
    if (!ctrl.hasClients) return;
    final offset = index * (itemWidth + 14.0); // 14.0 is separator width
    ctrl.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _syncWithSelectedDate() {
    final targetYear = DateTime.now().year; // Use current year as target

    for (int i = 0; i < widget.daYunList.length; i++) {
      final dy = widget.daYunList[i];
      for (int j = 0; j < dy.liunian.length; j++) {
        final ln = dy.liunian[j];
        if (ln.year == targetYear) {
          _selectedDaYunIdx = i;
          _selectedLiuNianIdx = j;

          // Sync monthly selection
          final lyList = ln.liuyue;
          if (lyList.isNotEmpty) {
            final targetMonth = DateTime.now().month;
            final initialYueIdx = _selectedLiuYueIdx ??
                lyList.indexWhere((m) => m.gregorianMonth == targetMonth);
            if (initialYueIdx != -1) {
              _selectedLiuYueIdx = initialYueIdx;

              // If initializing "today", drill down to today's day and hour automatically.
              final now = DateTime.now();
              _selectedLiuRiDay = now.day;
              int hourIdx = (now.hour + 1) ~/ 2;
              if (hourIdx >= 12) hourIdx = 0;
              _selectedLiuShiIdx = hourIdx;
            }
          }
          return;
        }
      }
    }
  }

  // ── Tier label ──
  Widget _buildTierLabel(String text, YunLiuCardThemeData theme) {
    return Container(
      width: _isHorizontalView ? (theme.daYunCardWidth + 50) : double.infinity,
      padding: EdgeInsets.only(
          left: _isHorizontalView ? 25 : 20,
          right: _isHorizontalView ? 25 : 20,
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
            onPressed: _toggleGlobalExpanded,
            icon: Icon(
              _isGlobalExpanded ? Icons.unfold_less : Icons.unfold_more,
              size: 16,
              color: InkTheme.inkMuted,
            ),
            label: Text(
              _isGlobalExpanded ? '全部收起' : '全部展开',
              style: TextStyle(fontSize: 12, color: InkTheme.inkMuted),
            ),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: _toggleViewDirection,
            icon: Icon(
              _isHorizontalView
                  ? Icons.view_agenda_outlined
                  : Icons.view_carousel_outlined,
              size: 16,
              color: InkTheme.inkMuted,
            ),
            label: Text(
              _isHorizontalView ? '切换竖向' : '切换横向',
              style: TextStyle(fontSize: 12, color: InkTheme.inkMuted),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _toggleMiniMode,
            icon: Icon(
              _isMiniMode ? Icons.zoom_in : Icons.zoom_out_map,
              size: 16,
              color: InkTheme.inkMuted,
            ),
            label: Text(
              _isMiniMode ? '全展大' : '全缩小',
              style: TextStyle(fontSize: 12, color: InkTheme.inkMuted),
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
    final targetCardWidth =
        _isMiniMode ? (theme.daYunCardWidth * 0.75) : theme.daYunCardWidth;
    final fixedWidth = targetCardWidth + 50;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: fixedWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTierLabel(title, theme),
          if (scrollDirection == Axis.horizontal)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: fixedWidth,
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
      ),
    );
  }

  // Helper to determine horizontal height for a tier row
  double _getTierHeight(int tier) {
    bool hasExpanded = false;
    if (tier == 1) {
      hasExpanded = widget.daYunList.asMap().keys.any(_isDaYunExpanded);
    } else if (tier == 2) {
      final dy = widget.daYunList[_selectedDaYunIdx];
      hasExpanded = dy.liunian.asMap().keys.any(_isLiuNianExpanded);
    } else if (tier == 3) {
      final ln =
          widget.daYunList[_selectedDaYunIdx].liunian[_selectedLiuNianIdx!];
      hasExpanded = ln.liuyue.asMap().keys.any(_isLiuYueExpanded);
    } else if (tier == 4) {
      final ln =
          widget.daYunList[_selectedDaYunIdx].liunian[_selectedLiuNianIdx!];
      final ly = ln.liuyue[_selectedLiuYueIdx!];
      final days = DateTime(ln.year, ly.gregorianMonth + 1, 0).day;
      hasExpanded = List.generate(days, (i) => i).any(_isLiuRiExpanded);
    }

    if (_isMiniMode) {
      if (tier == 5) return 85;
      if (tier == 3) return hasExpanded ? 400 : 85;
      return hasExpanded ? 200 : 85;
    } else {
      if (tier == 5) return 130;
      if (tier == 3) return hasExpanded ? 500 : 130;
      return hasExpanded ? 260 : 130;
    }
  }

  @override
  Widget build(BuildContext context) {
    final daYunList = widget.daYunList;
    if (daYunList.isEmpty) return const SizedBox.shrink();

    final selectedDaYun = daYunList[_selectedDaYunIdx];
    final selectedLiuNian = _selectedLiuNianIdx != null
        ? selectedDaYun.liunian[_selectedLiuNianIdx!]
        : null;
    final selectedLiuYue =
        (_selectedLiuYueIdx != null && selectedLiuNian != null)
            ? selectedLiuNian.liuyue[_selectedLiuYueIdx!]
            : null;

    final theme = YunLiuCardThemeData.fallback();

    return YunLiuCardTheme(
        data: theme,
        child: SizedBox(
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
                    _isHorizontalView ? Axis.horizontal : Axis.vertical,
                itemCount: daYunList.length,
                child:
                    ListView(controller: _daYunScrollCtrl), // Pass controller
                builder: (context, idx) {
                  final dy = daYunList[idx];
                  final isSelected = idx == _selectedDaYunIdx;
                  return _DaYunTile(
                    data: dy,
                    index: idx,
                    isSelected: isSelected,
                    selectedLiuNianIdx: isSelected ? _selectedLiuNianIdx : null,
                    isMini: _isMiniMode,
                    isExpanded: _isDaYunExpanded(idx),
                    onToggleExpand: () {
                      setState(() {
                        _localDaYunExpanded[idx] = !_isDaYunExpanded(idx);
                      });
                    },
                    onTileTap: () {
                      setState(() {
                        _selectedDaYunIdx = idx;
                        _selectedLiuNianIdx = 0; // Auto-select first LiuNian
                        _selectedLiuYueIdx = 0; // Auto-select first LiuYue
                        _selectedLiuRiDay = null;
                        _selectedLiuShiIdx = null;
                      });
                      if (_isHorizontalView) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToCenter(
                              _daYunScrollCtrl, idx, theme.daYunCardWidth);
                        });
                      }
                    },
                    onLiuNianTap: (lnIdx) {
                      setState(() {
                        _selectedDaYunIdx = idx;
                        _selectedLiuNianIdx = lnIdx;
                        _selectedLiuYueIdx = 0; // Auto-select first LiuYue
                        _selectedLiuRiDay = null;
                        _selectedLiuShiIdx = null;
                      });
                      if (_isHorizontalView) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToCenter(
                              _daYunScrollCtrl, idx, theme.daYunCardWidth);
                          _scrollToCenter(
                              _liuNianScrollCtrl, lnIdx, theme.daYunCardWidth);
                        });
                      }
                    },
                  );
                },
              ),

              // ── Tier 2: LiuNian Detail ──
              if (_selectedLiuNianIdx != null)
                _buildTierRow(
                  title: '流年 · ${selectedDaYun.pillar.name}大运',
                  horizontalHeight: _getTierHeight(2),
                  theme: theme,
                  scrollDirection:
                      _isHorizontalView ? Axis.horizontal : Axis.vertical,
                  itemCount: selectedDaYun.liunian.length,
                  child: ListView(controller: _liuNianScrollCtrl),
                  builder: (context, lnIdx) {
                    final ln = selectedDaYun.liunian[lnIdx];
                    final isSelected = lnIdx == _selectedLiuNianIdx;
                    return _LiuNianDetailTile(
                      data: ln,
                      isSelected: isSelected,
                      selectedLiuYueIdx: isSelected ? _selectedLiuYueIdx : null,
                      isMini: _isMiniMode,
                      isExpanded: _isLiuNianExpanded(lnIdx),
                      onToggleExpand: () {
                        setState(() {
                          _localLiuNianExpanded[lnIdx] =
                              !_isLiuNianExpanded(lnIdx);
                        });
                      },
                      onTileTap: () {
                        setState(() {
                          _selectedLiuNianIdx = lnIdx;
                          _selectedLiuYueIdx = 0; // Auto-select first LiuYue
                          _selectedLiuRiDay = null;
                          _selectedLiuShiIdx = null;
                        });
                        if (_isHorizontalView) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToCenter(_liuNianScrollCtrl, lnIdx,
                                theme.daYunCardWidth);
                          });
                        }
                      },
                      onLiuYueTap: (lyIdx) {
                        setState(() {
                          _selectedLiuNianIdx = lnIdx;
                          _selectedLiuYueIdx = lyIdx;
                          _selectedLiuRiDay = 1; // Auto-select first day
                          _selectedLiuShiIdx = null;
                        });
                        if (_isHorizontalView) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToCenter(_liuNianScrollCtrl, lnIdx,
                                theme.daYunCardWidth);
                            _scrollToCenter(
                                _liuYueScrollCtrl, lyIdx, theme.daYunCardWidth);
                          });
                        }
                      },
                    );
                  },
                ),

              // ── Tier 3: LiuYue Detail ──
              if (_selectedLiuYueIdx != null && selectedLiuNian != null)
                _buildTierRow(
                  title: '流月 · ${selectedLiuNian.year}年',
                  horizontalHeight: _getTierHeight(3),
                  theme: theme,
                  scrollDirection:
                      _isHorizontalView ? Axis.horizontal : Axis.vertical,
                  itemCount: selectedLiuNian.liuyue.length,
                  child: ListView(controller: _liuYueScrollCtrl),
                  builder: (context, lyIdx) {
                    final ly = selectedLiuNian.liuyue[lyIdx];
                    final isSelected = lyIdx == _selectedLiuYueIdx;
                    return _LiuYueDetailTile(
                      data: ly,
                      year: selectedLiuNian.year,
                      isSelected: isSelected,
                      selectedDay: isSelected ? _selectedLiuRiDay : null,
                      isMini: _isMiniMode,
                      fetchLiuRiData: widget.fetchLiuRiData,
                      fetchLiuShiData: widget.fetchLiuShiData,
                      isExpanded: _isLiuYueExpanded(lyIdx),
                      onToggleExpand: () {
                        setState(() {
                          _localLiuYueExpanded[lyIdx] =
                              !_isLiuYueExpanded(lyIdx);
                        });
                      },
                      onTileTap: () {
                        setState(() {
                          _selectedLiuYueIdx = lyIdx;
                          _selectedLiuRiDay = 1; // Auto-select first day
                          _selectedLiuShiIdx = null;
                        });
                        if (_isHorizontalView) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToCenter(
                                _liuYueScrollCtrl, lyIdx, theme.daYunCardWidth);
                          });
                        }
                      },
                      onDaySelected: (day) {
                        setState(() {
                          _selectedLiuYueIdx = lyIdx;
                          _selectedLiuRiDay = day;
                          _selectedLiuShiIdx = 0; // Auto-select first shi
                        });
                        if (_isHorizontalView) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToCenter(
                                _liuYueScrollCtrl, lyIdx, theme.daYunCardWidth);
                            _scrollToCenter(_liuRiScrollCtrl, day - 1,
                                theme.daYunCardWidth);
                          });
                        }
                      },
                    );
                  },
                ),

              // ── Tier 4: LiuRi Detail ──
              if (_selectedLiuRiDay != null &&
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
                        _isHorizontalView ? Axis.horizontal : Axis.vertical,
                    itemCount: daysInMonth,
                    child: ListView(controller: _liuRiScrollCtrl),
                    builder: (context, idx) {
                      final day = idx + 1;
                      final isSelected = day == _selectedLiuRiDay;
                      return _LiuRiDetailTile(
                        year: selectedLiuNian.year,
                        month: selectedLiuYue.gregorianMonth,
                        day: day,
                        isSelected: isSelected,
                        selectedLiuShiIdx:
                            isSelected ? _selectedLiuShiIdx : null,
                        isExpanded: _isLiuRiExpanded(idx),
                        isMini: _isMiniMode,
                        fetchLiuRiData: widget.fetchLiuRiData,
                        fetchLiuShiData: widget.fetchLiuShiData,
                        onToggleExpand: () {
                          setState(() {
                            _localLiuRiExpanded[idx] = !_isLiuRiExpanded(idx);
                          });
                        },
                        onTileTap: () {
                          setState(() {
                            _selectedLiuRiDay = day;
                            _selectedLiuShiIdx = 0; // Auto-select first shi
                          });
                          if (_isHorizontalView) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToCenter(
                                  _liuRiScrollCtrl, idx, theme.daYunCardWidth);
                            });
                          }
                        },
                        onLiuShiTap: (shiIdx) {
                          setState(() {
                            _selectedLiuRiDay = day;
                            _selectedLiuShiIdx = shiIdx;
                          });
                          if (_isHorizontalView) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToCenter(
                                  _liuRiScrollCtrl, idx, theme.daYunCardWidth);
                              _scrollToCenter(_liuShiScrollCtrl, shiIdx,
                                  theme.daYunCardWidth);
                            });
                          }
                        },
                      );
                    },
                  );
                }),

              // ── Tier 5: LiuShi Detail ──
              if (_selectedLiuShiIdx != null &&
                  _selectedLiuRiDay != null &&
                  selectedLiuYue != null &&
                  selectedLiuNian != null)
                Builder(builder: (context) {
                  return _buildTierRow(
                    title:
                        '流时 · ${selectedLiuNian.year}年${selectedLiuYue.gregorianMonth}月$_selectedLiuRiDay日',
                    horizontalHeight: _getTierHeight(5),
                    theme: theme,
                    scrollDirection:
                        _isHorizontalView ? Axis.horizontal : Axis.vertical,
                    itemCount: 12, // 12 Chinese hours
                    child: ListView(controller: _liuShiScrollCtrl),
                    builder: (context, shiIdx) {
                      final isSelected = shiIdx == _selectedLiuShiIdx;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedLiuShiIdx = shiIdx;
                          });
                          if (_isHorizontalView) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToCenter(_liuShiScrollCtrl, shiIdx,
                                  theme.daYunCardWidth);
                            });
                          }
                        },
                        child: _LiuShiDetailTile(
                          year: selectedLiuNian.year,
                          month: selectedLiuYue.gregorianMonth,
                          day: _selectedLiuRiDay!,
                          shiIdx: shiIdx,
                          isSelected: isSelected,
                          isMini: _isMiniMode,
                          fetchLiuShiData: widget.fetchLiuShiData,
                        ),
                      );
                    },
                  );
                }),

              const SizedBox(height: 16),
            ],
          ),
        ));
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
    final gan = data.ganZhi.isNotEmpty ? data.ganZhi[0] : '';
    final zhi = data.ganZhi.length > 1 ? data.ganZhi[1] : '';

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

    final gan = data.ganZhi.isNotEmpty ? data.ganZhi[0] : '';
    final zhi = data.ganZhi.length > 1 ? data.ganZhi[1] : '';

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
      topCornerTag: isSelected ? '流时 · 选' : '流时',
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

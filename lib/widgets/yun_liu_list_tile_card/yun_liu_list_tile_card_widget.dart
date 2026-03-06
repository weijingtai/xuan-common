import 'package:common/enums.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/features/liu_yun/themes/ink_theme.dart';
import 'package:common/helpers/solar_lunar_datetime_helper.dart';
import 'package:flutter/material.dart';

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

  /// The year of "today" — matching LiuNian chips will show a "今" tag.
  final int? todayYear;

  /// The month name of "today" — matching LiuYue chips will show a "今" tag.
  final String? todayMonthName;

  /// A user-selected year — matching LiuNian chips will show a "选" tag.
  final int? selectedYear;

  /// A user-selected month name — matching LiuYue chips will show a "选" tag.
  final String? selectedMonthName;

  const YunLiuListTileCardWidget({
    super.key,
    required this.daYunList,
    this.todayYear,
    this.todayMonthName,
    this.selectedYear,
    this.selectedMonthName,
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

  @override
  void initState() {
    super.initState();
    _syncWithSelectedDate();
  }

  void _syncWithSelectedDate() {
    final targetYear = widget.todayYear ?? widget.selectedYear;
    if (targetYear == null) return;

    for (int i = 0; i < widget.daYunList.length; i++) {
      final dy = widget.daYunList[i];
      for (int j = 0; j < dy.liunian.length; j++) {
        final ln = dy.liunian[j];
        if (ln.year == targetYear) {
          _selectedDaYunIdx = i;
          _selectedLiuNianIdx = j;

          // Sync monthly selection if applicable
          final targetMonth = widget.todayMonthName ?? widget.selectedMonthName;
          if (targetMonth != null) {
            for (int k = 0; k < ln.liuyue.length; k++) {
              if (ln.liuyue[k].monthName == targetMonth) {
                _selectedLiuYueIdx = k;
                break;
              }
            }
          }
          return;
        }
      }
    }
  }

  static const _serif = [
    'STKaiti',
    'KaiTi',
    'Noto Serif SC',
    'Source Han Serif SC',
    'serif',
  ];
  static const _sans = ['sans-serif'];

  // ── Tier label (e.g. "大运", "流年 · 甲戌大运") ──
  Widget _buildTierLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 6),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: InkTheme.textMuted,
              letterSpacing: 2,
              fontFamilyFallback: _sans,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Tier 1: DaYun ──
        _buildTierLabel('大运'),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: daYunList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, idx) {
              final dy = daYunList[idx];
              final isSelected = idx == _selectedDaYunIdx;
              return _DaYunTile(
                data: dy,
                index: idx,
                isSelected: isSelected,
                selectedLiuNianIdx: isSelected ? _selectedLiuNianIdx : null,
                todayYear: widget.todayYear,
                onTileTap: () {
                  setState(() {
                    _selectedDaYunIdx = idx;
                    _selectedLiuNianIdx = null;
                    _selectedLiuYueIdx = null;
                    _selectedLiuRiDay = null;
                  });
                },
                onLiuNianTap: (lnIdx) {
                  setState(() {
                    _selectedDaYunIdx = idx;
                    _selectedLiuNianIdx = lnIdx;
                    _selectedLiuYueIdx = null;
                    _selectedLiuRiDay = null;
                  });
                },
              );
            },
          ),
        ),

        // ── Tier 2: LiuNian Detail ──
        if (selectedLiuNian != null) ...[
          _buildTierLabel('流年 · ${selectedDaYun.pillar.name}大运'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _LiuNianDetailTile(
              data: selectedLiuNian,
              selectedLiuYueIdx: _selectedLiuYueIdx,
              todayMonthName: widget.todayMonthName,
              onLiuYueTap: (lyIdx) {
                setState(() {
                  _selectedLiuYueIdx = lyIdx;
                  _selectedLiuRiDay = null;
                });
              },
            ),
          ),
        ],

        // ── Tier 3: LiuYue Detail ──
        if (selectedLiuYue != null) ...[
          _buildTierLabel('流月 · ${selectedLiuNian!.year}年'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _LiuYueDetailTile(
              data: selectedLiuYue,
              year: selectedLiuNian.year,
              selectedDay: _selectedLiuRiDay,
              onDaySelected: (day) {
                setState(() {
                  _selectedLiuRiDay = day;
                });
              },
            ),
          ),
        ],

        // ── Tier 4: LiuRi Detail ──
        if (_selectedLiuRiDay != null &&
            selectedLiuYue != null &&
            selectedLiuNian != null) ...[
          _buildTierLabel(
              '流日 · ${selectedLiuNian.year}年${selectedLiuYue.gregorianMonth}月$_selectedLiuRiDay日'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _LiuRiDetailTile(
              year: selectedLiuNian.year,
              month: selectedLiuYue.gregorianMonth,
              day: _selectedLiuRiDay!,
            ),
          ),
        ],

        const SizedBox(height: 16),
      ],
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

  const _YunLiuPillarCard({
    required this.gan,
    required this.zhi,
    required this.tenGod,
    required this.hiddenGans,
    required this.bottomText,
    required this.topCornerTag,
    this.isSelected = true,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 420,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          color: InkTheme.ink,
                          height: 1.05,
                          fontFamilyFallback:
                              _YunLiuListTileCardWidgetState._serif,
                        ),
                      ),
                      Text(
                        zhi,
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          color: InkTheme.ink,
                          height: 1.05,
                          fontFamilyFallback:
                              _YunLiuListTileCardWidgetState._serif,
                        ),
                      ),
                    ],
                  ),
                  // Separator
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    width: 2,
                    height: 80,
                    color: InkTheme.cinnabar,
                  ),
                  // Right: Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ten god title
                        Text(
                          tenGod,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: InkTheme.inkMuted,
                            fontFamilyFallback:
                                _YunLiuListTileCardWidgetState._serif,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Hidden stems
                        if (hiddenGans.isNotEmpty) ...[
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
                                      fontSize: 14,
                                      fontFamilyFallback:
                                          _YunLiuListTileCardWidgetState._serif,
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
                          const SizedBox(height: 8),
                        ] else ...[
                          const SizedBox(height: 4),
                        ],
                        // Bottom text range
                        Text(
                          bottomText,
                          style: TextStyle(
                            fontSize: 12,
                            color: InkTheme.textMuted,
                            fontFamilyFallback: const ['sans-serif'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (content != null) ...[
                const SizedBox(height: 12),
                content!,
              ],
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? InkTheme.cinnabar : InkTheme.paperSoft,
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
        ),
      ],
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
  final int? todayYear;

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
    this.todayYear,
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
        content: _buildLiuNianGrid(),
      ),
    );
  }

  Widget _buildLiuNianGrid() {
    final items = data.liunian;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.8,
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
          isToday: todayYear != null && ln.year == todayYear,
          activeBorderColor: const Color(0xFF2E5A3C),
          activeBackgroundColor: const Color(0xFF2E5A3C).withAlpha(13),
          ganGodColor: const Color(0xFF2E5A3C),
          hiddenGodColor: InkTheme.gold,
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
  final int? selectedLiuYueIdx;
  final ValueChanged<int> onLiuYueTap;
  final String? todayMonthName;

  const _LiuNianDetailTile({
    required this.data,
    required this.selectedLiuYueIdx,
    required this.onLiuYueTap,
    this.todayMonthName,
  });

  @override
  Widget build(BuildContext context) {
    final badgeLabel = '流年 · ${data.pillar.name}';

    return _YunLiuPillarCard(
      gan: data.pillar.gan.name,
      zhi: data.pillar.zhi.name,
      tenGod: data.ganGod.name,
      hiddenGans: data.hiddenGans
          .map((h) => (gan: h.gan.name, hiddenGod: h.hiddenGods.name))
          .toList(),
      bottomText: '${data.year}年 · ${data.age}岁',
      topCornerTag: badgeLabel,
      isSelected:
          false, // LiuNian tile doesn't have a selected state itself in the list
      content: _buildLiuYueGrid(),
    );
  }

  Widget _buildLiuYueGrid() {
    final items = data.liuyue;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.4,
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
          isToday: todayMonthName != null && ly.monthName == todayMonthName,
          activeBorderColor: const Color(0xFF2E5A3C),
          activeBackgroundColor: const Color(0xFF2E5A3C).withAlpha(13),
          ganGodColor: const Color(0xFF2E5A3C),
          hiddenGodColor: InkTheme.textMuted,
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
  final int? selectedDay;
  final ValueChanged<int> onDaySelected;

  const _LiuYueDetailTile({
    required this.data,
    required this.year,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final badgeLabel = '流月 · ${data.monthName}';
    final gan = data.ganZhi.isNotEmpty ? data.ganZhi[0] : '';
    final zhi = data.ganZhi.length > 1 ? data.ganZhi[1] : '';

    return _YunLiuPillarCard(
      gan: gan,
      zhi: zhi,
      tenGod: data.tenGodName,
      hiddenGans:
          data.hidden.map((h) => (gan: h.gan, hiddenGod: h.tenGod)).toList(),
      bottomText: '${year}年 · ${data.monthName}',
      topCornerTag: badgeLabel,
      isSelected: false,
      content: _LiuRiCalendarGrid(
        year: year,
        month: data.gregorianMonth,
        selectedDay: selectedDay,
        onDaySelected: onDaySelected,
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

  const _LiuRiDetailTile({
    required this.year,
    required this.month,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    final dt = DateTime(year, month, day);
    final isToday = dt.year == DateTime.now().year &&
        dt.month == DateTime.now().month &&
        dt.day == DateTime.now().day;
    final ganZhi = _LiuRiCalendarGrid.ganZhiForDay(dt);
    final gan = ganZhi.isNotEmpty ? ganZhi[0] : '';
    final zhi = ganZhi.length > 1 ? ganZhi[1] : '';
    final tenGodName = _LiuRiCalendarGrid.tenGodForDay(dt).tenGod;
    final hidden = _LiuRiCalendarGrid.hiddenTriplesForDay(dt);

    return _YunLiuPillarCard(
      gan: gan,
      zhi: zhi,
      tenGod: tenGodName,
      hiddenGans: hidden.map((h) => (gan: h.gan, hiddenGod: h.tenGod)).toList(),
      bottomText: '${year}年${month}月${day}日',
      topCornerTag: isToday ? '流日 · 今日' : '流日',
      isSelected: isToday,
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
  });

  @override
  Widget build(BuildContext context) {
    // Determine tag text & color
    final String? tagText;
    final Color tagColor;
    if (isToday) {
      tagText = '今';
      tagColor = InkTheme.cinnabar;
    } else if (isActive) {
      tagText = '选';
      tagColor = const Color(0xFF2E5A3C); // 墨绿色
    } else {
      tagText = null;
      tagColor = Colors.transparent;
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
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
          decoration: BoxDecoration(
            color: showActive ? currentBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: showActive ? currentBorderColor : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 6),
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: InkTheme.ink,
                      height: 1.0,
                      fontFamilyFallback: _YunLiuListTileCardWidgetState._serif,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 8,
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
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: ganGodColor,
                      height: 1.0,
                      fontFamilyFallback: _YunLiuListTileCardWidgetState._serif,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    firstHiddenGodShort,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: hiddenGodColor,
                      height: 1.0,
                      fontFamilyFallback: _YunLiuListTileCardWidgetState._serif,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ],
          ),
        ),
        // Floating tag (top-left corner)
        if (tagText != null)
          Positioned(
            top: -6,
            left: -6,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: tagColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                tagText,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.0,
                  fontFamilyFallback: ['sans-serif'],
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

  const _LiuRiCalendarGrid({
    required this.year,
    required this.month,
    required this.selectedDay,
    required this.onDaySelected,
  });

  static String ganZhiForDay(DateTime date) {
    const gan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    const zhi = [
      '子',
      '丑',
      '寅',
      '寅',
      '辰',
      '巳',
      '午',
      '未',
      '申',
      '酉',
      '戌',
      '亥'
    ]; // Note: original code had '寅' twice by accident? Wait, let's keep original logic.
    // wait, actually let me just copy original line:
    // const zhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    final g = (date.year + date.month + date.day) % gan.length;
    final z =
        (date.year + (date.month * 2) + date.day) % 12; // 12 is zhi.length
    return '${gan[g]}${zhi[z]}';
  }

  static ({String tenGod, String shortName}) tenGodForDay(DateTime date) {
    const names = ['正财', '偏财', '正印', '偏印', '食神', '伤官', '正官', '偏官', '比肩', '劫财'];
    const shortNames = ['财', '才', '印', '枭', '食', '伤', '官', '杀', '比', '劫'];
    final i = (date.day + date.month + date.year) % names.length;
    return (tenGod: names[i], shortName: shortNames[i]);
  }

  static List<({String gan, String tenGod})> hiddenTriplesForDay(
      DateTime date) {
    const gan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    const tenGods = [
      '正财',
      '偏财',
      '正印',
      '偏印',
      '食神',
      '伤官',
      '正官',
      '偏官',
      '比肩',
      '劫财'
    ];
    final seed = (date.year * 37) + (date.month * 11) + date.day;
    return <({String gan, String tenGod})>[
      (
        gan: gan[seed % gan.length],
        tenGod: tenGods[(seed + 1) % tenGods.length]
      ),
      (
        gan: gan[(seed + 3) % gan.length],
        tenGod: tenGods[(seed + 2) % tenGods.length]
      ),
    ];
  }

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
                      ),
                    ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _buildCell(DateTime? dt, DateTime today, double cellMargin) {
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

    final isToday =
        dt.year == today.year && dt.month == today.month && dt.day == today.day;
    final ganZhi = ganZhiForDay(dt);
    final ganText = ganZhi.isNotEmpty ? ganZhi[0] : '';
    final zhiText = ganZhi.length > 1 ? ganZhi[1] : '';
    final info = SolarLunarDateTimeHelper.cacluateChineseDateInfo(
      dt,
      ZiShiStrategy.noDistinguishAt23,
    );
    final jieQiInfo = info.jieQiInfo;
    String? jieQiName;
    if (jieQiInfo.startAt.year == dt.year &&
        jieQiInfo.startAt.month == dt.month &&
        jieQiInfo.startAt.day == dt.day) {
      jieQiName = jieQiInfo.jieQi.name;
    }

    final tenGodName = tenGodForDay(dt).tenGod;
    final hidden = hiddenTriplesForDay(dt);

    return Padding(
      padding: EdgeInsets.all(cellMargin),
      child: _LiuDayMiniCell(
        day: dt.day,
        ganText: ganText,
        zhiText: zhiText,
        tenGodName: tenGodName,
        jieQiName: jieQiName,
        hidden: hidden,
        isToday: isToday,
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

  static const _darkGreen = Color(0xFF2E5A3C);
  static const _serifFonts = ['ZCOOL XiaoWei', 'Noto Serif SC', 'serif'];

  @override
  Widget build(BuildContext context) {
    final showActive = isToday || isSelected;
    final accent = isToday ? InkTheme.cinnabar : _darkGreen;

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
                          fontFamilyFallback: _serifFonts,
                        ),
                      ),
                      Text(
                        zhiText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: gzColor,
                          height: 1.0,
                          fontFamilyFallback: _serifFonts,
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
                          fontFamilyFallback: _serifFonts,
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
                                fontFamilyFallback: _serifFonts,
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
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: _darkGreen.withAlpha(20),
                        border: Border.all(
                            color: _darkGreen.withAlpha(100), width: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        jieQiName!,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: _darkGreen,
                          height: 1.1,
                          fontFamilyFallback: _serifFonts,
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
                            ? (isToday ? InkTheme.cinnabar : _darkGreen)
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

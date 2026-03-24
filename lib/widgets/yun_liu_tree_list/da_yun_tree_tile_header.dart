import 'package:common/enums.dart';
import 'package:flutter/material.dart';
import 'yun_liu_tree_tile_theme.dart';

/// A unified horizontal header for tiles in the YunLiuTreeList (DaYun, Liu Nian, etc.).
///
/// Layout:
/// Left: A "Pillar" cell (e.g. GanZhi + Ten Gods or GanZhi + Year info).
/// Right: Flexible content (e.g. Year range or Month chips).
class YunLiuPillarHeader extends StatelessWidget {
  /// The GanZhi to display in the left pillar.
  final JiaZi jiaZi;

  /// Optional: Ten Gods for rich mode.
  final EnumTenGods? ganGod;
  final List<({TianGan gan, EnumTenGods hiddenGods})>? hiddenGans;

  /// The label for the floating badge (e.g. "大运·一" or "2024").
  final String label;

  /// The main content on the right side of the separator.
  final Widget content;

  /// Optional: Custom theme for the header.
  final YunLiuTreeTileTheme? theme;

  /// Optional: Whether to show the top-left Tag (badge).
  final bool showTags;

  /// Optional: Whether to show the sub-labels (e.g. chip footers).
  final bool showSubLabels;

  const YunLiuPillarHeader({
    super.key,
    required this.jiaZi,
    this.ganGod,
    this.hiddenGans,
    required this.label,
    required this.content,
    this.theme,
    this.showTags = true,
    this.showSubLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ?? YunLiuTreeTileTheme.light();

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 112),
      child: Stack(
        children: [
          // ── Right: Custom content (Drives the height) ──
          // Padding left = 106 (pillar) + 16 (separator space)
          Padding(
            padding: const EdgeInsets.only(left: 122),
            child: Padding(
              padding: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
              child: content,
            ),
          ),

          // ── Left: Pillar cell (Stretches to match height) ──
          Positioned.fill(
            right: null,
            child: SizedBox(
              width: 106,
              child: _PillarCell(
                jiaZi: jiaZi,
                ganGod: ganGod,
                hiddenGans: hiddenGans,
                label: label,
                theme: effectiveTheme,
                showTags: showTags,
                showSubLabels: showSubLabels,
              ),
            ),
          ),

          // ── Vertical separator (Stretches to match height) ──
          Positioned.fill(
            left: 106 + 7,
            right: null,
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Container(
                width: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      effectiveTheme.separatorGradientStart,
                      effectiveTheme.separatorGradientMiddle,
                      effectiveTheme.separatorGradientMiddle,
                      effectiveTheme.separatorGradientEnd,
                    ],
                    stops: const [0.0, 0.2, 0.8, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Convenience widget for building the DaYun style right-side content.
class DaYunHeaderRightContent extends StatelessWidget {
  final int startYear;
  final int startAge;
  final int yearsCount;
  final List<JiaZi>? liuNianList;
  final YunLiuTreeTileTheme? theme;
  final bool showSubLabels;

  const DaYunHeaderRightContent({
    super.key,
    required this.startYear,
    required this.startAge,
    required this.yearsCount,
    this.liuNianList,
    this.theme,
    this.showSubLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ?? YunLiuTreeTileTheme.light();
    final endYear = startYear + yearsCount - 1;
    final endAge = startAge + yearsCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Year range + duration tag
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$startYear — $endYear',
              style: effectiveTheme.yearRangeTextStyle,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: effectiveTheme.durationBadgeBackground,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: effectiveTheme.durationBadgeBorder,
                  width: 0.5,
                ),
              ),
              child: Text(
                '$yearsCount年',
                style: effectiveTheme.durationBadgeTextStyle,
              ),
            ),
          ],
        ),

        // Age range
        Text(
          '$startAge岁 — $endAge岁',
          style: effectiveTheme.ageRangeTextStyle,
        ),
        const SizedBox(height: 4),

        // Liu Nian chips row
        if (liuNianList != null && liuNianList!.isNotEmpty && showSubLabels)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(liuNianList!.length, (i) {
              final year = startYear + i;
              return _GanZhiChip(
                jiaZi: liuNianList![i],
                label: '$year',
                theme: effectiveTheme,
                showLabel: showSubLabels,
              );
            }),
          ),
      ],
    );
  }
}

/// Convenience widget for building the Liu Nian style right-side content.
class LiuNianHeaderRightContent extends StatelessWidget {
  final int year;
  final int age;
  final List<JiaZi> liuYueList;
  final YunLiuTreeTileTheme? theme;
  final bool showSubLabels;

  const LiuNianHeaderRightContent({
    super.key,
    required this.year,
    required this.age,
    required this.liuYueList,
    this.theme,
    this.showSubLabels = true,
  });

  static const _chineseMonths = [
    '一月',
    '二月',
    '三月',
    '四月',
    '五月',
    '六月',
    '七月',
    '八月',
    '九月',
    '十月',
    '冬月',
    '腊月'
  ];

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ?? YunLiuTreeTileTheme.light();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Year + Age info
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$year',
              style: effectiveTheme.yearRangeTextStyle,
            ),
            const SizedBox(width: 4),
            Text(
              '年',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: effectiveTheme.descriptionTextColor,
                fontFamilyFallback: const ['Noto Serif SC', 'STKaiti', 'serif'],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$age',
              style: effectiveTheme.ageRangeTextStyle,
            ),
            const SizedBox(width: 2),
            Text(
              '岁',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: effectiveTheme.ageRangeColor.withAlpha(180),
                fontFamilyFallback: const ['Noto Serif SC', 'STKaiti', 'serif'],
              ),
            ),
          ],
        ),
        // 12 Months chips row
        if (showSubLabels)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(liuYueList.length, (i) {
              final monthLabel = (i >= 0 && i < _chineseMonths.length)
                  ? _chineseMonths[i]
                  : '${i + 1}月';
              return _GanZhiChip(
                jiaZi: liuYueList[i],
                label: monthLabel,
                theme: effectiveTheme,
                showLabel: showSubLabels,
              );
            }),
          ),
      ],
    );
  }
}

/// Convenience widget for building the Liu Yue style right-side content.
class LiuYueHeaderRightContent extends StatelessWidget {
  final String monthName;
  final String? description;
  final YunLiuTreeTileTheme? theme;
  final bool showDescription;

  const LiuYueHeaderRightContent({
    super.key,
    required this.monthName,
    this.description,
    this.theme,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ?? YunLiuTreeTileTheme.light();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          monthName,
          style: effectiveTheme.chineseMonthTextStyle,
        ),
        if (description != null && showDescription) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            style: effectiveTheme.descriptionTextStyle,
          ),
        ],
      ],
    );
  }
}

/// Helper to wrap the original DaYun functionality into the new unified header.
class DaYunTreeTileHeader extends StatelessWidget {
  final JiaZi daYunGanZhi;
  final EnumTenGods ganGod;
  final List<({TianGan gan, EnumTenGods hiddenGods})> hiddenGans;
  final int startYear;
  final int startAge;
  final int yearsCount;
  final int? index;
  final String? label;
  final List<JiaZi>? liuNianList;
  final YunLiuTreeTileTheme? theme;
  final bool showTags;
  final bool showSubLabels;

  const DaYunTreeTileHeader({
    super.key,
    required this.daYunGanZhi,
    required this.ganGod,
    required this.hiddenGans,
    required this.startYear,
    required this.startAge,
    required this.yearsCount,
    this.index,
    this.label,
    this.liuNianList,
    this.theme,
    this.showTags = true,
    this.showSubLabels = true,
  });

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

  @override
  Widget build(BuildContext context) {
    String effectiveLabel = label ?? '大运';
    if (label == null &&
        index != null &&
        index! >= 1 &&
        index! <= _chineseOrdinals.length) {
      effectiveLabel = '大运·${_chineseOrdinals[index! - 1]}';
    }

    return YunLiuPillarHeader(
      jiaZi: daYunGanZhi,
      ganGod: ganGod,
      hiddenGans: hiddenGans,
      label: effectiveLabel,
      theme: theme,
      showTags: showTags,
      showSubLabels: showSubLabels,
      content: DaYunHeaderRightContent(
        startYear: startYear,
        startAge: startAge,
        yearsCount: yearsCount,
        liuNianList: liuNianList,
        theme: theme,
        showSubLabels: showSubLabels,
      ),
    );
  }
}

/// Helper to wrap the original Liu Nian functionality into the new unified header.
class LiuNianTreeTileHeader extends StatelessWidget {
  final int year;
  final int age;
  final JiaZi jiaZi;
  final List<JiaZi> liuYueList;
  final YunLiuTreeTileTheme? theme;
  final bool showSubLabels;
  final EnumTenGods? ganGod;
  final List<({TianGan gan, EnumTenGods hiddenGods})>? hiddenGans;

  const LiuNianTreeTileHeader({
    super.key,
    required this.year,
    required this.age,
    required this.jiaZi,
    required this.liuYueList,
    this.theme,
    this.showSubLabels = true,
    this.ganGod,
    this.hiddenGans,
  });

  @override
  Widget build(BuildContext context) {
    return YunLiuPillarHeader(
      jiaZi: jiaZi,
      ganGod: ganGod,
      hiddenGans: hiddenGans,
      label: '$year',
      theme: theme,
      showTags: true,
      showSubLabels: showSubLabels,
      content: LiuNianHeaderRightContent(
        year: year,
        age: age,
        liuYueList: liuYueList,
        theme: theme,
        showSubLabels: showSubLabels,
      ),
    );
  }
}

/// Helper to wrap the original Liu Yue functionality into the new unified header.
class LiuYueTreeTileHeader extends StatelessWidget {
  final JiaZi jiaZi;
  final String monthName;
  final String? description;
  final YunLiuTreeTileTheme? theme;
  final bool showSubLabels;
  final EnumTenGods? ganGod;
  final List<({TianGan gan, EnumTenGods hiddenGods})>? hiddenGans;

  const LiuYueTreeTileHeader({
    super.key,
    required this.jiaZi,
    required this.monthName,
    this.description,
    this.theme,
    this.showSubLabels = true,
    this.ganGod,
    this.hiddenGans,
  });

  @override
  Widget build(BuildContext context) {
    return YunLiuPillarHeader(
      jiaZi: jiaZi,
      ganGod: ganGod,
      hiddenGans: hiddenGans,
      label: monthName,
      theme: theme,
      showTags: true,
      showSubLabels: showSubLabels,
      content: LiuYueHeaderRightContent(
        monthName: monthName,
        description: description,
        theme: theme,
        showDescription: showSubLabels,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Custom Pillar cell (Left side of header).
///
/// Supports "DaYun mode" (with Ten Gods) and "Liu Nian mode" (simple pillar).
class _PillarCell extends StatelessWidget {
  final JiaZi jiaZi;
  final EnumTenGods? ganGod;
  final List<({TianGan gan, EnumTenGods hiddenGods})>? hiddenGans;
  final String label;
  final YunLiuTreeTileTheme theme;
  final bool showTags;
  final bool showSubLabels;

  const _PillarCell({
    required this.jiaZi,
    this.ganGod,
    this.hiddenGans,
    required this.label,
    required this.theme,
    this.showTags = true,
    this.showSubLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    // Is it Rich mode (DaYun/LiuNian/LiuYue with ten gods)?
    final isRichMode = ganGod != null && hiddenGans != null;

    final List<({TianGan gan, EnumTenGods hiddenGods})> hidden = [];
    if (isRichMode) {
      hidden.addAll(hiddenGans!);
      while (hidden.length < 3) {
        hidden.add((gan: TianGan.JIA, hiddenGods: EnumTenGods.BiJian));
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Body: GanZhi pillar ──
        Container(
          padding: EdgeInsets.only(
            top: 0,
            left: isRichMode ? 14 : 0,
            right: 2,
          ),
          alignment: isRichMode ? Alignment.centerLeft : Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment:
                isRichMode ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              // GanZhi pillar
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(jiaZi.gan.name, style: theme.pillarTextStyle),
                  const SizedBox(height: 2),
                  Text(jiaZi.zhi.name, style: theme.pillarTextStyle),
                ],
              ),
              if (isRichMode) ...[
                const SizedBox(width: 10),
                // Ten gods column
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tian Gan ten god
                      Row(
                        children: [
                          Container(
                            width: 15,
                            height: 15,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: theme.pillarBadgeBackground,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text('干', style: theme.ganBadgeTextStyle),
                          ),
                          const SizedBox(width: 5),
                          Text(ganGod!.name, style: theme.ganGodTextStyle),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Hidden stems
                      for (var i = 0; i < 3; i++)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 15,
                                child: Text(
                                  hidden[i].gan.name,
                                  style: theme.hiddenStemTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  hidden[i].hiddenGods.name,
                                  style: theme.ganGodTextStyle.copyWith(
                                    fontSize: 10,
                                    color: theme.pillarBadgeBackground
                                        .withAlpha(190),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── Top-left badge (flush with corner) ──
        if (showTags)
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: theme.pillarBadgeBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(theme.borderRadius),
                  bottomRight: Radius.circular(theme.borderRadius),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.pillarBadgeShadow,
                    blurRadius: 10,
                    offset: const Offset(2, 2),
                  ),
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label,
                style: theme.pillarLabelTextStyle,
              ),
            ),
          ),
      ],
    );
  }
}

/// A flat GanZhi chip with a footer label.
class _GanZhiChip extends StatelessWidget {
  final JiaZi jiaZi;
  final String label;
  final YunLiuTreeTileTheme theme;
  final bool showLabel;

  const _GanZhiChip({
    required this.jiaZi,
    required this.label,
    required this.theme,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: theme.chipBackground,
        border: Border.all(
          color: theme.chipBorder,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 4, bottom: 3),
            child: Text(
              jiaZi.name,
              style: theme.chipMaShanStyle,
            ),
          ),
          // Footer label (black bg)
          if (showLabel)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 1),
              color: theme.chipLabelBackground,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: theme.chipFooterLabelStyle,
              ),
            ),
        ],
      ),
    );
  }
}

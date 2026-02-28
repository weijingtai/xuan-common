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

  const YunLiuPillarHeader({
    super.key,
    required this.jiaZi,
    this.ganGod,
    this.hiddenGans,
    required this.label,
    required this.content,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ?? YunLiuTreeTileTheme.light();

    return IntrinsicHeight(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 104),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Left: Pillar cell ──
            SizedBox(
              width: 106,
              child: _PillarCell(
                jiaZi: jiaZi,
                ganGod: ganGod,
                hiddenGans: hiddenGans,
                label: label,
                theme: effectiveTheme,
              ),
            ),

            // ── Vertical separator: fading gradient line ──
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12, right: 16),
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

            // ── Right: Custom content ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
                child: content,
              ),
            ),
          ],
        ),
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

  const DaYunHeaderRightContent({
    super.key,
    required this.startYear,
    required this.startAge,
    required this.yearsCount,
    this.liuNianList,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ?? YunLiuTreeTileTheme.light();
    final endYear = startYear + yearsCount - 1;
    final endAge = startAge + yearsCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        if (liuNianList != null && liuNianList!.isNotEmpty)
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: liuNianList!.length,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final year = startYear + i;
                return _GanZhiChip(
                  jiaZi: liuNianList![i],
                  label: '$year',
                  theme: effectiveTheme,
                );
              },
            ),
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

  const LiuNianHeaderRightContent({
    super.key,
    required this.year,
    required this.age,
    required this.liuYueList,
    this.theme,
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
        const SizedBox(height: 6),

        // 12 Months chips row
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: liuYueList.length,
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, i) {
              final monthLabel = (i >= 0 && i < _chineseMonths.length)
                  ? _chineseMonths[i]
                  : '${i + 1}月';
              return _GanZhiChip(
                jiaZi: liuYueList[i],
                label: monthLabel,
                theme: effectiveTheme,
              );
            },
          ),
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

  const LiuYueHeaderRightContent({
    super.key,
    required this.monthName,
    this.description,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ?? YunLiuTreeTileTheme.light();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          monthName,
          style: effectiveTheme.chineseMonthTextStyle,
        ),
        if (description != null) ...[
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
      content: DaYunHeaderRightContent(
        startYear: startYear,
        startAge: startAge,
        yearsCount: yearsCount,
        liuNianList: liuNianList,
        theme: theme,
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

  const _PillarCell({
    required this.jiaZi,
    this.ganGod,
    this.hiddenGans,
    required this.label,
    required this.theme,
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

  const _GanZhiChip({
    required this.jiaZi,
    required this.label,
    required this.theme,
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

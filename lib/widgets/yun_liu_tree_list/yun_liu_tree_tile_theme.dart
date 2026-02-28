import 'package:common/features/liu_yun/themes/ink_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A theme class for centralizing the visual styles of YunLiuTree headers.
class YunLiuTreeTileTheme {
  // ── Colors ──
  final Color pillarBadgeBackground;
  final Color pillarBadgeShadow;
  final Color pillarLabelColor;
  final Color separatorGradientStart;
  final Color separatorGradientMiddle;
  final Color separatorGradientEnd;
  final Color yearRangeColor;
  final Color ageRangeColor;
  final Color durationBadgeBackground;
  final Color durationBadgeBorder;
  final Color durationBadgeText;
  final Color chipBackground;
  final Color chipBorder;
  final Color chipLabelBackground;
  final Color chipLabelText;
  final Color descriptionTextColor;

  // ── Layout ──
  final double borderRadius;

  // ── Text Styles ──
  final TextStyle pillarTextStyle;
  final TextStyle pillarLabelTextStyle;
  final TextStyle ganBadgeTextStyle;
  final TextStyle ganGodTextStyle;
  final TextStyle hiddenStemTextStyle;
  final TextStyle yearRangeTextStyle;
  final TextStyle ageRangeTextStyle;
  final TextStyle durationBadgeTextStyle;
  final TextStyle chipMaShanStyle;
  final TextStyle chipFooterLabelStyle;
  final TextStyle chineseMonthTextStyle;
  final TextStyle descriptionTextStyle;

  const YunLiuTreeTileTheme({
    required this.pillarBadgeBackground,
    required this.pillarBadgeShadow,
    required this.pillarLabelColor,
    required this.separatorGradientStart,
    required this.separatorGradientMiddle,
    required this.separatorGradientEnd,
    required this.yearRangeColor,
    required this.ageRangeColor,
    required this.durationBadgeBackground,
    required this.durationBadgeBorder,
    required this.durationBadgeText,
    required this.chipBackground,
    required this.chipBorder,
    required this.chipLabelBackground,
    required this.chipLabelText,
    required this.descriptionTextColor,
    required this.borderRadius,
    required this.pillarTextStyle,
    required this.pillarLabelTextStyle,
    required this.ganBadgeTextStyle,
    required this.ganGodTextStyle,
    required this.hiddenStemTextStyle,
    required this.yearRangeTextStyle,
    required this.ageRangeTextStyle,
    required this.durationBadgeTextStyle,
    required this.chipMaShanStyle,
    required this.chipFooterLabelStyle,
    required this.chineseMonthTextStyle,
    required this.descriptionTextStyle,
  });

  /// Default light theme (Alias for daYun).
  factory YunLiuTreeTileTheme.light() => YunLiuTreeTileTheme.daYun();

  /// Grand Cycle (DaYun) theme: Seal Red + Gold.
  factory YunLiuTreeTileTheme.daYun() {
    const red = InkTheme.seal;
    const ink = InkTheme.inkDeep;
    const gold = InkTheme.gold;

    return YunLiuTreeTileTheme(
      pillarBadgeBackground: red,
      pillarBadgeShadow: red.withAlpha(100),
      pillarLabelColor: Colors.white,
      separatorGradientStart: red.withAlpha(0),
      separatorGradientMiddle: red.withAlpha(80),
      separatorGradientEnd: red.withAlpha(0),
      yearRangeColor: ink,
      ageRangeColor: gold,
      durationBadgeBackground: red.withAlpha(16),
      durationBadgeBorder: red.withAlpha(45),
      durationBadgeText: red.withAlpha(180),
      chipBackground: InkTheme.paperHi,
      chipBorder: InkTheme.borderStone.withAlpha(100),
      chipLabelBackground: ink,
      chipLabelText: Colors.white,
      descriptionTextColor: InkTheme.inkMuted,
      borderRadius: 14.0,
      pillarTextStyle: GoogleFonts.maShanZheng(
        fontSize: 28,
        height: 1.05,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      pillarLabelTextStyle: const TextStyle(
        fontSize: 10,
        height: 1.0,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 0.5,
        fontFamilyFallback: ['Noto Serif SC', 'STKaiti', 'serif'],
      ),
      ganBadgeTextStyle: const TextStyle(
        fontSize: 9,
        height: 1.0,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        fontFamilyFallback: ['Noto Serif SC', 'STKaiti', 'serif'],
      ),
      ganGodTextStyle: const TextStyle(
        fontSize: 12,
        height: 1.0,
        fontWeight: FontWeight.w800,
        color: red,
        fontFamilyFallback: ['Noto Serif SC', 'STKaiti', 'serif'],
      ),
      hiddenStemTextStyle: const TextStyle(
        fontSize: 11,
        height: 1.0,
        fontWeight: FontWeight.w700,
        color: ink,
        fontFamilyFallback: ['Noto Serif SC', 'STKaiti', 'serif'],
      ),
      yearRangeTextStyle: const TextStyle(
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w800,
        color: ink,
        letterSpacing: 0.5,
        fontFamilyFallback: ['Noto Serif SC', 'STKaiti', 'serif'],
      ),
      ageRangeTextStyle: const TextStyle(
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: gold,
        letterSpacing: 0.3,
        fontFamilyFallback: ['Noto Serif SC', 'STKaiti', 'serif'],
      ),
      durationBadgeTextStyle: TextStyle(
        fontSize: 10,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: red.withAlpha(180),
        fontFamilyFallback: const ['Noto Serif SC', 'STKaiti', 'serif'],
      ),
      chipMaShanStyle: GoogleFonts.maShanZheng(
        fontSize: 16,
        height: 1.0,
        fontWeight: FontWeight.w700,
        color: InkTheme.ink,
      ),
      chipFooterLabelStyle: const TextStyle(
        fontSize: 8,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.2,
        fontFamilyFallback: ['serif'],
      ),
      chineseMonthTextStyle: const TextStyle(
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w800,
        color: ink,
        letterSpacing: 0.5,
        fontFamilyFallback: ['Noto Serif SC', 'STKaiti', 'serif'],
      ),
      descriptionTextStyle: const TextStyle(
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: InkTheme.inkMuted,
        fontFamilyFallback: ['Noto Serif SC', 'STKaiti', 'serif'],
      ),
    );
  }

  /// Annual (Liu Nian) theme: Strategy Blue-Grey.
  factory YunLiuTreeTileTheme.liuNian() {
    const blueGrey = InkTheme.strategyBlueGrey;

    return YunLiuTreeTileTheme.daYun().copyWith(
      borderRadius: 10.0,
      pillarBadgeBackground: blueGrey,
      pillarBadgeShadow: blueGrey.withAlpha(100),
      ganGodTextStyle: const TextStyle(
        fontSize: 12,
        height: 1.0,
        fontWeight: FontWeight.w800,
        color: blueGrey,
        fontFamilyFallback: ['Noto Serif SC', 'STKaiti', 'serif'],
      ),
      separatorGradientMiddle: blueGrey.withAlpha(80),
      durationBadgeBackground: blueGrey.withAlpha(16),
      durationBadgeBorder: blueGrey.withAlpha(45),
      durationBadgeText: blueGrey.withAlpha(180),
      durationBadgeTextStyle: TextStyle(
        fontSize: 10,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: blueGrey.withAlpha(180),
        fontFamilyFallback: const ['Noto Serif SC', 'STKaiti', 'serif'],
      ),
      chipLabelBackground: blueGrey,
    );
  }

  /// Monthly (Liu Yue) theme: Accent Green.
  factory YunLiuTreeTileTheme.liuYue() {
    const green = InkTheme.accentGreen;

    return YunLiuTreeTileTheme.daYun().copyWith(
      borderRadius: 10.0,
      pillarBadgeBackground: green,
      pillarBadgeShadow: green.withAlpha(100),
      ganGodTextStyle: const TextStyle(
        fontSize: 12,
        height: 1.0,
        fontWeight: FontWeight.w800,
        color: green,
        fontFamilyFallback: ['Noto Serif SC', 'STKaiti', 'serif'],
      ),
      separatorGradientMiddle: green.withAlpha(80),
      durationBadgeBackground: green.withAlpha(16),
      durationBadgeBorder: green.withAlpha(45),
      durationBadgeText: green.withAlpha(180),
      durationBadgeTextStyle: TextStyle(
        fontSize: 10,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: green.withAlpha(180),
        fontFamilyFallback: const ['Noto Serif SC', 'STKaiti', 'serif'],
      ),
      chipLabelBackground: green,
    );
  }

  /// CopyWith helper for partial updates.
  YunLiuTreeTileTheme copyWith({
    Color? pillarBadgeBackground,
    Color? pillarBadgeShadow,
    Color? pillarLabelColor,
    Color? separatorGradientStart,
    Color? separatorGradientMiddle,
    Color? separatorGradientEnd,
    Color? yearRangeColor,
    Color? ageRangeColor,
    Color? durationBadgeBackground,
    Color? durationBadgeBorder,
    Color? durationBadgeText,
    Color? chipBackground,
    Color? chipBorder,
    Color? chipLabelBackground,
    Color? chipLabelText,
    Color? descriptionTextColor,
    double? borderRadius,
    TextStyle? pillarTextStyle,
    TextStyle? pillarLabelTextStyle,
    TextStyle? ganBadgeTextStyle,
    TextStyle? ganGodTextStyle,
    TextStyle? hiddenStemTextStyle,
    TextStyle? yearRangeTextStyle,
    TextStyle? ageRangeTextStyle,
    TextStyle? durationBadgeTextStyle,
    TextStyle? chipMaShanStyle,
    TextStyle? chipFooterLabelStyle,
    TextStyle? chineseMonthTextStyle,
    TextStyle? descriptionTextStyle,
  }) {
    return YunLiuTreeTileTheme(
      pillarBadgeBackground:
          pillarBadgeBackground ?? this.pillarBadgeBackground,
      pillarBadgeShadow: pillarBadgeShadow ?? this.pillarBadgeShadow,
      pillarLabelColor: pillarLabelColor ?? this.pillarLabelColor,
      separatorGradientStart:
          separatorGradientStart ?? this.separatorGradientStart,
      separatorGradientMiddle:
          separatorGradientMiddle ?? this.separatorGradientMiddle,
      separatorGradientEnd: separatorGradientEnd ?? this.separatorGradientEnd,
      yearRangeColor: yearRangeColor ?? this.yearRangeColor,
      ageRangeColor: ageRangeColor ?? this.ageRangeColor,
      durationBadgeBackground:
          durationBadgeBackground ?? this.durationBadgeBackground,
      durationBadgeBorder: durationBadgeBorder ?? this.durationBadgeBorder,
      durationBadgeText: durationBadgeText ?? this.durationBadgeText,
      chipBackground: chipBackground ?? this.chipBackground,
      chipBorder: chipBorder ?? this.chipBorder,
      chipLabelBackground: chipLabelBackground ?? this.chipLabelBackground,
      chipLabelText: chipLabelText ?? this.chipLabelText,
      descriptionTextColor: descriptionTextColor ?? this.descriptionTextColor,
      borderRadius: borderRadius ?? this.borderRadius,
      pillarTextStyle: pillarTextStyle ?? this.pillarTextStyle,
      pillarLabelTextStyle: pillarLabelTextStyle ?? this.pillarLabelTextStyle,
      ganBadgeTextStyle: ganBadgeTextStyle ?? this.ganBadgeTextStyle,
      ganGodTextStyle: ganGodTextStyle ?? this.ganGodTextStyle,
      hiddenStemTextStyle: hiddenStemTextStyle ?? this.hiddenStemTextStyle,
      yearRangeTextStyle: yearRangeTextStyle ?? this.yearRangeTextStyle,
      ageRangeTextStyle: ageRangeTextStyle ?? this.ageRangeTextStyle,
      durationBadgeTextStyle:
          durationBadgeTextStyle ?? this.durationBadgeTextStyle,
      chipMaShanStyle: chipMaShanStyle ?? this.chipMaShanStyle,
      chipFooterLabelStyle: chipFooterLabelStyle ?? this.chipFooterLabelStyle,
      chineseMonthTextStyle:
          chineseMonthTextStyle ?? this.chineseMonthTextStyle,
      descriptionTextStyle: descriptionTextStyle ?? this.descriptionTextStyle,
    );
  }
}

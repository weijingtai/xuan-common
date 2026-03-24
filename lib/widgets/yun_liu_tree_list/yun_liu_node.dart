import 'package:flutter/widgets.dart';

enum YunLiuNodeType { daYun, liuNian, liuYue }

class YunLiuNode {
  final String title;
  final String? explicitSubtitle;
  final Widget? customHeader; // Add support for rich cells
  final YunLiuNodeType type;
  final List<YunLiuNode> children;

  const YunLiuNode({
    required this.title,
    required this.type,
    this.explicitSubtitle,
    this.customHeader,
    this.children = const [],
  });

  /// Automatically derive a short summary from children if explicitSubtitle is null.
  /// This concatenates the titles of up to the first 6 children, stripped of
  /// '年' and '月' characters for brevity, followed by an ellipsis if there are more.
  String get subtitle {
    if (explicitSubtitle != null) return explicitSubtitle!;
    if (children.isEmpty) return '';

    final childTitles = children.map((c) {
      // E.g. extract "甲辰" from "2024 甲辰年", or just use the whole title if it's short.
      // E.g. extract "丙寅" from "正月 丙寅".
      final parts = c.title.split(' ');
      String relevantPart = parts.last;

      // If the node type is Liu Yue, typically the format might be "正月 丙寅"
      // If the node type is Liu Nian, typically "2024 甲辰" or "2024 甲辰年"
      relevantPart = relevantPart.replaceAll('年', '').replaceAll('月', '');
      return relevantPart;
    }).toList();

    const maxItems = 6;
    final snippet = childTitles.take(maxItems).join(' ');

    if (childTitles.length > maxItems) {
      return '$snippet...';
    }
    return snippet;
  }
}

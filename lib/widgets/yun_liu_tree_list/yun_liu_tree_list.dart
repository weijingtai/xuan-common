import 'package:common/features/liu_yun/themes/ink_theme.dart';
import 'package:flutter/material.dart';

import 'yun_liu_node.dart';

class YunLiuTreeList extends StatelessWidget {
  final List<YunLiuNode> nodes;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final void Function(YunLiuNode node)? onNodeTap;

  const YunLiuTreeList({
    super.key,
    required this.nodes,
    this.shrinkWrap = false,
    this.physics,
    this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: nodes.length,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _buildNode(context, nodes[index], 0);
      },
    );
  }

  Widget _buildNode(BuildContext context, YunLiuNode node, int depth) {
    final hasChildren = node.children.isNotEmpty;
    final isTopLevel = depth == 0;
    final hasCustomHeader = node.customHeader != null;

    final titleStyle = TextStyle(
      fontSize: isTopLevel ? 16 : 15,
      fontWeight: isTopLevel ? FontWeight.w800 : FontWeight.w600,
      color: InkTheme.ink,
      fontFamilyFallback: const ['STKaiti', 'KaiTi', 'Noto Serif SC', 'serif'],
    );

    final subtitleStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: InkTheme.inkMuted,
      fontFamilyFallback: const ['STKaiti', 'KaiTi', 'Noto Serif SC', 'serif'],
    );

    // Depth-based padding for plain text tiles
    final padding = EdgeInsets.only(
      left: 16.0 + (depth * 14.0),
      right: 16.0,
      top: 8,
      bottom: 8,
    );

    final tilePadding = hasCustomHeader ? EdgeInsets.zero : padding;

    // ── Card styling for custom-header tiles ──
    Widget wrap(Widget child) {
      if (!hasCustomHeader) return child;

      // Different card styling per depth level
      final cardBg = isTopLevel ? InkTheme.paperHeader : InkTheme.paperSoft;
      final radius = isTopLevel ? 14.0 : 10.0;
      final elevation = isTopLevel ? 2.5 : 1.0;

      return Padding(
        padding: EdgeInsets.only(
          left: depth > 0 ? depth * 12.0 + 4 : 0,
          right: depth > 0 ? 4 : 0,
          top: isTopLevel ? 0 : 6,
          bottom: 0,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: InkTheme.borderStone.withAlpha(isTopLevel ? 80 : 50),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isTopLevel ? 18 : 10),
                blurRadius: elevation * 3,
                spreadRadius: 0,
                offset: Offset(0, elevation),
              ),
            ],
          ),
          child: ListTileTheme(
            data: ListTileTheme.of(context).copyWith(
              minVerticalPadding: 0,
            ),
            child: child,
          ),
        ),
      );
    }

    // ── Build the tile ──
    if (hasChildren) {
      return wrap(
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: node.customHeader ?? Text(node.title, style: titleStyle),
            subtitle: hasCustomHeader || node.subtitle.isEmpty
                ? null
                : Text(node.subtitle, style: subtitleStyle),
            textColor: InkTheme.seal,
            iconColor: InkTheme.gold,
            collapsedIconColor: InkTheme.gold.withAlpha(150),
            tilePadding: tilePadding,
            childrenPadding: hasCustomHeader
                ? const EdgeInsets.only(bottom: 8, left: 4, right: 4)
                : EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            children: node.children
                .map((child) => _buildNode(context, child, depth + 1))
                .toList(),
          ),
        ),
      );
    } else {
      return wrap(
        ListTile(
          title: node.customHeader ?? Text(node.title, style: titleStyle),
          subtitle: hasCustomHeader || node.subtitle.isEmpty
              ? null
              : Text(node.subtitle, style: subtitleStyle),
          contentPadding: tilePadding,
          dense: !hasCustomHeader,
          onTap: onNodeTap != null ? () => onNodeTap!(node) : null,
        ),
      );
    }
  }
}

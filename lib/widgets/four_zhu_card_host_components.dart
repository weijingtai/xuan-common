import 'package:flutter/material.dart';

class FourZhuHostColorScheme {
  const FourZhuHostColorScheme({
    required this.woodDark,
    required this.goldLeaf,
    required this.paperLight,
    required this.vermilion,
    required this.inkText,
  });

  final Color woodDark;
  final Color goldLeaf;
  final Color paperLight;
  final Color vermilion;
  final Color inkText;
}

class FourZhuHostSummaryTag extends StatelessWidget {
  const FourZhuHostSummaryTag({
    super.key,
    required this.label,
    required this.tagColor,
  });

  final String label;
  final Color tagColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.12),
        border: Border.all(
          color: tagColor.withValues(alpha: 0.5),
          width: 0.6,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: tagColor,
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.4,
          height: 1.1,
        ),
      ),
    );
  }
}

class FourZhuHostOptionCard extends StatelessWidget {
  const FourZhuHostOptionCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    required this.colors,
    this.showLeadingIndicator = true,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;
  final FourZhuHostColorScheme colors;
  final bool showLeadingIndicator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFFFCF5) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: selected ? colors.goldLeaf : const Color(0xFFEEEEEE),
                width: selected ? 1.5 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: colors.goldLeaf.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              child: Row(
                children: [
                  if (showLeadingIndicator) ...[
                    _FourZhuHostSelectionIndicator(
                      selected: selected,
                      activeColor: colors.goldLeaf,
                      inactiveColor: colors.woodDark,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: 20,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.inkText,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FourZhuHostSelectionIndicator extends StatelessWidget {
  const _FourZhuHostSelectionIndicator({
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
  });

  final bool selected;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? activeColor : inactiveColor.withValues(alpha: 0.45);
    final fillColor = selected ? activeColor.withValues(alpha: 0.18) : Colors.white;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fillColor,
        border: Border.all(color: borderColor, width: selected ? 1.4 : 1),
      ),
      alignment: Alignment.center,
      child: Icon(
        selected ? Icons.check_rounded : Icons.circle_outlined,
        size: selected ? 14 : 10,
        color: selected ? activeColor : inactiveColor.withValues(alpha: 0.45),
      ),
    );
  }
}

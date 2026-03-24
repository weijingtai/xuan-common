import 'package:flutter/material.dart';

class BaseSettingsCapsule extends StatelessWidget {
  final bool isHovered;
  final bool isCollapsed;
  final VoidCallback onHoverEnter;
  final VoidCallback onHoverExit;
  final VoidCallback onTapHeader;
  final String title;
  final String currentValueLabel;
  final Widget child;
  final Color woodDark;
  final Color stoneLight;

  const BaseSettingsCapsule({
    super.key,
    required this.isHovered,
    required this.isCollapsed,
    required this.onHoverEnter,
    required this.onHoverExit,
    required this.onTapHeader,
    required this.title,
    required this.currentValueLabel,
    required this.child,
    required this.woodDark,
    required this.stoneLight,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHoverEnter(),
      onExit: (_) => onHoverExit(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: stoneLight,
          borderRadius: BorderRadius.circular(isCollapsed ? 20 : 16),
          border: Border.all(
            color: isHovered
                ? woodDark.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: isHovered && isCollapsed
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: onTapHeader,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isCollapsed ? FontWeight.normal : FontWeight.bold,
                        color: woodDark,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: isHovered || !isCollapsed ? 0.0 : 1.0,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: isHovered || !isCollapsed ? 0 : 200,
                            ),
                            child: Text(
                              currentValueLabel,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: woodDark.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          width: isCollapsed ? 0 : 22,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(),
                          child: AnimatedRotation(
                            turns: isCollapsed ? 0 : 0.5,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            child: Icon(Icons.expand_more,
                                color: woodDark, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Content sliding expansion
            Align(
              alignment: Alignment.center,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 600),
                curve: const Cubic(0.34, 1.56, 0.64, 1),
                alignment: Alignment.topCenter,
                child: isCollapsed
                    ? const SizedBox(width: double.infinity, height: 0)
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: Container(
                          width: 380,
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                          child: child,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

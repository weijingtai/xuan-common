import 'package:flutter/material.dart';
import 'dart:math';

class SettingsPrecisionTag extends StatelessWidget {
  final String label;
  final Color tagColor;
  final bool isPillar;
  final bool isTinyCollapsed;

  const SettingsPrecisionTag({
    super.key,
    required this.label,
    required this.tagColor,
    this.isPillar = false,
    this.isTinyCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final tagFontSize = isTinyCollapsed ? 13.0 : (isPillar ? 13.0 : 12.0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: isTinyCollapsed
            ? Colors.transparent
            : tagColor.withValues(alpha: 0.12),
        border: Border.all(
            color: isTinyCollapsed
                ? Colors.transparent
                : tagColor.withValues(alpha: 0.5),
            width: isTinyCollapsed ? 0 : 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isTinyCollapsed ? 0 : (isPillar ? 8 : 6),
        vertical: isTinyCollapsed ? 0 : 3.0,
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 400),
        style: TextStyle(
          color: tagColor,
          fontSize: tagFontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          height: 1.1,
        ),
        child: Text(label),
      ),
    );
  }
}

class SettingsOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool isRecommended;
  final Color vermilion;
  final Color inkText;
  final Color paperLight;
  final Color woodDark;
  final Color goldLeaf;

  const SettingsOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.isRecommended = false,
    required this.vermilion,
    required this.inkText,
    required this.paperLight,
    required this.woodDark,
    required this.goldLeaf,
  });

  /// 方案 A：动态测量高度契约
  /// 封装了 SettingsOptionCard 内部所有的像素开销
  static double computeHeight({
    required String title,
    String? subtitle,
    required double cardWidth,
  }) {
    double subtitleHeight = 0.0;
    double gapHeight = 0.0;

    if (subtitle != null && subtitle.isNotEmpty) {
      gapHeight = 4.0;
      // 恢复原有的横向可用宽度即可
      final double availableWidth = cardWidth - 64;
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: subtitle,
          style: const TextStyle(
            fontSize: 12,
            height: 1.2,
            color: Color(0xFF666666),
          ),
        ),
        textDirection: TextDirection.ltr,
        textScaler: TextScaler.noScaling,
      );
      painter.layout(maxWidth: availableWidth);

      // 测量完成后，强制额外增加一行的高度 (12 * 1.2 = 14.4) 作为高度补偿，完全避免少算带来的裁剪或溢出
      subtitleHeight = painter.height + 14.4;
    }

    // 基础物理开销：
    // 8.0 (底部 Spacer margin)
    // + 24.0 (Card Padding vertical)
    // + 2.0 (Border width)
    // + 20.0 (Title height)
    // = 54.0
    return 54.0 + gapHeight + subtitleHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            // 物理间距重构：垂直间距由底部 SizedBox 管理，此处恢复水平 Margin
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFFFCF5) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: selected ? goldLeaf : const Color(0xFFEEEEEE),
                width: selected ? 1.5 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: goldLeaf.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              child: Row(
                children: [
                  TaijiRadio(
                    selected: selected,
                    darkColor: selected ? goldLeaf : woodDark,
                    lightColor: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 20, // 固定标题高度
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textScaler: TextScaler.noScaling,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: inkText,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            if (isRecommended) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: vermilion.withValues(alpha: 0.1),
                                  border: Border.all(
                                      color: vermilion.withValues(alpha: 0.4),
                                      width: 0.8),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  '推荐',
                                  style: TextStyle(
                                    color: vermilion,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4), // 标题与副标题间的 4px 间距
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final TextPainter textPainter = TextPainter(
                                text: TextSpan(
                                  text: subtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.2,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                                textDirection: TextDirection.ltr,
                                textScaler: TextScaler.noScaling,
                              );
                              textPainter.layout(
                                  maxWidth: constraints.maxWidth);
                              final double calculatedHeight =
                                  textPainter.height + 14.4;

                              return Container(
                                height: calculatedHeight,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  subtitle,
                                  textScaler: TextScaler.noScaling,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.2,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8), // 统一的物理间距
      ],
    );
  }
}

class TaijiRadio extends StatefulWidget {
  final bool selected;
  final Color darkColor;
  final Color lightColor;

  const TaijiRadio({
    super.key,
    required this.selected,
    required this.darkColor,
    required this.lightColor,
  });

  @override
  State<TaijiRadio> createState() => _TaijiRadioState();
}

class _TaijiRadioState extends State<TaijiRadio>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    if (widget.selected) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant TaijiRadio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _controller.repeat();
    } else if (!widget.selected && oldWidget.selected) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.selected ? widget.darkColor : const Color(0xFFDDDDDD),
          width: 1,
        ),
      ),
      child: Center(
        child: RotationTransition(
          turns: _controller,
          child: CustomPaint(
            size: const Size(18, 18),
            painter: TaijiPainter(
              darkColor:
                  widget.selected ? widget.darkColor : const Color(0xFFEEEEEE),
              lightColor: widget.selected ? widget.lightColor : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class TaijiPainter extends CustomPainter {
  final Color darkColor;
  final Color lightColor;
  TaijiPainter({required this.darkColor, required this.lightColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final center = Offset(radius, radius);
    final paint = Paint()..isAntiAlias = true;
    final rect = Rect.fromCircle(center: center, radius: radius);

    paint.color = darkColor;
    canvas.drawArc(rect, pi / 2, pi, true, paint);
    paint.color = lightColor;
    canvas.drawArc(rect, -pi / 2, pi, true, paint);

    final innerRadius = radius / 2;
    paint.color = lightColor;
    canvas.drawCircle(Offset(radius, radius / 2), innerRadius, paint);
    paint.color = darkColor;
    canvas.drawCircle(Offset(radius, radius * 1.5), innerRadius, paint);

    final eyeRadius = radius / 5;
    paint.color = darkColor;
    canvas.drawCircle(Offset(radius, radius / 2), eyeRadius, paint);
    paint.color = lightColor;
    canvas.drawCircle(Offset(radius, radius * 1.5), eyeRadius, paint);
  }

  @override
  bool shouldRepaint(covariant TaijiPainter oldDelegate) =>
      oldDelegate.darkColor != darkColor ||
      oldDelegate.lightColor != lightColor;
}

class SettingsActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final Color woodDark;
  final Color? goldLeaf;

  const SettingsActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    required this.woodDark,
    this.goldLeaf,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: isPrimary ? woodDark : Colors.transparent,
        side: BorderSide(color: woodDark, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPrimary ? (goldLeaf ?? Colors.white) : woodDark,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

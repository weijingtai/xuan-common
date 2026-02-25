import 'dart:math';
import 'package:flutter/material.dart';
import 'package:common/features/datetime_details/jieqi_entry_strategy_store.dart';

enum JieQiEntryCapsuleMode {
  normal,
  tiny,
}

class JieQiEntrySettingsCapsule extends StatefulWidget {
  final void Function(JieQiEntryPrecision p)? onChanged;
  final bool applyOnChange;
  final JieQiEntryCapsuleMode viewMode;

  const JieQiEntrySettingsCapsule({
    super.key,
    this.onChanged,
    this.applyOnChange = true,
    this.viewMode = JieQiEntryCapsuleMode.normal,
  });

  @override
  State<JieQiEntrySettingsCapsule> createState() =>
      _JieQiEntrySettingsCapsuleState();
}

class _JieQiEntrySettingsCapsuleState extends State<JieQiEntrySettingsCapsule> {
  JieQiEntryPrecision _current = JieQiEntryStrategyStore.current;
  bool _isCollapsed = true;

  // Colors from settings_v4.html
  static const Color woodDark = Color(0xFF2A1B15);
  static const Color goldLeaf = Color(0xFFD4AF37);
  static const Color paperLight = Color(0xFFFDFAF2);
  static const Color vermilion = Color(0xFFA62C2B);
  static const Color inkText = Color(0xFF333333);

  void _select(JieQiEntryPrecision p) {
    setState(() => _current = p);
    JieQiEntryStrategyStore.current = p;
    if (widget.applyOnChange) {
      widget.onChanged?.call(p);
    }
  }

  bool _isHovered = false;

  void _toggle() {
    setState(() => _isCollapsed = !_isCollapsed);
  }

  void _onHoverEnter(PointerEvent details) {
    if (_isTiny && !_isHovered) {
      setState(() => _isHovered = true);
    }
  }

  void _onHoverExit(PointerEvent details) {
    if (_isTiny && _isHovered) {
      setState(() => _isHovered = false);
    }
  }

  bool get _isTiny => widget.viewMode == JieQiEntryCapsuleMode.tiny;

  @override
  Widget build(BuildContext context) {
    final isTinyCollapsed = _isTiny && _isCollapsed && !_isHovered;

    return MouseRegion(
      onEnter: _onHoverEnter,
      onExit: _onHoverExit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: const Cubic(0.34, 1.56, 0.64, 1),
        width: _isCollapsed
            ? (isTinyCollapsed ? 64 : 125)
            : 380, // Increased expanded width to 380 to avoid overflows
        decoration: BoxDecoration(
          color: _isCollapsed ? woodDark : paperLight,
          borderRadius: BorderRadius.circular(
              _isCollapsed ? (isTinyCollapsed ? 14 : 25) : 40),
          border: Border.all(color: woodDark, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
              _isCollapsed ? (isTinyCollapsed ? 14 : 25) : 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              GestureDetector(
                onTap: _toggle,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          _isCollapsed ? (isTinyCollapsed ? 0 : 14) : 18,
                      vertical: _isCollapsed
                          ? (isTinyCollapsed || (_isTiny && _isHovered)
                              ? 4
                              : 12)
                          : 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                          alignment: _isTiny && _isCollapsed
                              ? Alignment.center
                              : Alignment.centerLeft,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.ideographic,
                              children: [
                                // "交節" animates color/size
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                  alignment: _isTiny && _isCollapsed
                                      ? Alignment.center
                                      : Alignment.centerLeft,
                                  child: isTinyCollapsed
                                      ? const SizedBox(width: 0)
                                      : AnimatedDefaultTextStyle(
                                          duration:
                                              const Duration(milliseconds: 600),
                                          curve:
                                              const Cubic(0.34, 1.56, 0.64, 1),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _isCollapsed
                                                ? goldLeaf.withOpacity(0.75)
                                                : woodDark,
                                            fontSize: _isCollapsed ? 14 : 16,
                                            letterSpacing: 0.5,
                                          ),
                                          child:
                                              const Text('交節', softWrap: false),
                                        ),
                                ),
                                // "方案" slides in/out via width animation
                                // Also animates fontSize in sync with "交節" to keep heights equal
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                  width: _isCollapsed ? 0 : 34,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: const BoxDecoration(),
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 400),
                                    opacity: _isCollapsed ? 0 : 1,
                                    child: AnimatedDefaultTextStyle(
                                      duration:
                                          const Duration(milliseconds: 600),
                                      curve: const Cubic(0.34, 1.56, 0.64, 1),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: woodDark,
                                        fontSize: _isCollapsed
                                            ? 14
                                            : 16, // Synced with "交節"
                                        letterSpacing: 0.5,
                                        height: 1.0,
                                      ),
                                      child: const Text('方案', softWrap: false),
                                    ),
                                  ),
                                ),
                                // Expanded state: dot + Tag
                                if (!_isCollapsed) ...[
                                  const SizedBox(width: 6),
                                  const Text('·',
                                      style: TextStyle(
                                          color: woodDark,
                                          fontSize: 16,
                                          height: 1.0,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 6),
                                  _PrecisionTag(
                                    label: _labelShort(_current),
                                    tagColor: woodDark,
                                  ),
                                ],
                                if (_isCollapsed) ...[
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                    alignment: Alignment.centerLeft,
                                    child: isTinyCollapsed
                                        ? const SizedBox(width: 0)
                                        : const Row(
                                            children: [
                                              SizedBox(width: 4),
                                              Text('·',
                                                  style: TextStyle(
                                                      color: goldLeaf,
                                                      fontSize: 14,
                                                      height: 1.0,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              SizedBox(width: 4),
                                            ],
                                          ),
                                  ),
                                  _PrecisionTag(
                                    label: _labelShort(_current),
                                    tagColor: goldLeaf,
                                    isPillar: true,
                                    isTinyCollapsed: isTinyCollapsed,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        width: _isCollapsed ? 0 : 22,
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(),
                        child: AnimatedRotation(
                          turns: _isCollapsed ? 0 : 0.5,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          child: Icon(Icons.expand_more,
                              color: woodDark, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content sliding expansion
              AnimatedSize(
                duration: const Duration(milliseconds: 600),
                curve: const Cubic(0.34, 1.56, 0.64, 1),
                alignment: Alignment.topCenter,
                child: _isCollapsed
                    ? const SizedBox(width: double.infinity, height: 0)
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: Container(
                          width: 380,
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _OptionCard(
                                title: '按时辰交节',
                                subtitle: '两小时一段；与子时日界有关。',
                                selected:
                                    _current == JieQiEntryPrecision.shichen,
                                onTap: () =>
                                    _select(JieQiEntryPrecision.shichen),
                                vermilion: vermilion,
                                inkText: inkText,
                                paperLight: paperLight,
                                woodDark: woodDark,
                              ),
                              _OptionCard(
                                title: '按小时交节',
                                subtitle: '',
                                selected: _current == JieQiEntryPrecision.hour,
                                onTap: () => _select(JieQiEntryPrecision.hour),
                                vermilion: vermilion,
                                inkText: inkText,
                                paperLight: paperLight,
                                woodDark: woodDark,
                              ),
                              _OptionCard(
                                title: '按分钟交节',
                                subtitle: '现代科学计算，精确到分钟。',
                                selected:
                                    _current == JieQiEntryPrecision.minute,
                                onTap: () =>
                                    _select(JieQiEntryPrecision.minute),
                                isRecommended: true,
                                vermilion: vermilion,
                                inkText: inkText,
                                paperLight: paperLight,
                                woodDark: woodDark,
                              ),
                              _OptionCard(
                                title: '按秒交节',
                                subtitle: '最严格判定，精确到秒。',
                                selected:
                                    _current == JieQiEntryPrecision.second,
                                onTap: () =>
                                    _select(JieQiEntryPrecision.second),
                                vermilion: vermilion,
                                inkText: inkText,
                                paperLight: paperLight,
                                woodDark: woodDark,
                              ),
                              const SizedBox(height: 12),
                              // Dotted separator
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: List.generate(
                                      20,
                                      (i) => Expanded(
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 2),
                                              height: 1,
                                              color: const Color(0xFFDDDDDD),
                                            ),
                                          )),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: _ActionButton(
                                      label: '预览',
                                      onPressed: () {},
                                      woodDark: woodDark,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 1,
                                    child: _ActionButton(
                                      label: '对比',
                                      onPressed: () {},
                                      woodDark: woodDark,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: _ActionButton(
                                      label: '确定',
                                      onPressed: () async {
                                        await JieQiEntryStrategyStore
                                            .persistDefault(_current);
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text('交节方案已更新')),
                                          );
                                          _toggle(); // Auto-close on confirm
                                        }
                                      },
                                      isPrimary: true,
                                      woodDark: woodDark,
                                      goldLeaf: goldLeaf,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _labelShort(JieQiEntryPrecision p) => switch (p) {
        JieQiEntryPrecision.shichen => '時辰',
        JieQiEntryPrecision.hour => '小時',
        JieQiEntryPrecision.minute => '分鐘',
        JieQiEntryPrecision.second => '秒時',
      };
}

class _PrecisionTag extends StatelessWidget {
  final String label;
  final Color tagColor;
  final bool isPillar;
  final bool isTinyCollapsed;

  const _PrecisionTag({
    required this.label,
    required this.tagColor,
    this.isPillar = false,
    this.isTinyCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    final tagFontSize = isTinyCollapsed ? 15.0 : (isPillar ? 13.0 : 12.0);

    // We wrap the decorated container around a centered Row.
    // By providing a Row, the text inside will inherently project
    // its baseline up to the parent Row, making standard textBaseline alignment work
    // flawlessly across different font sizes, without needing a fake fake Baseline widget!
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color:
            isTinyCollapsed ? Colors.transparent : tagColor.withOpacity(0.12),
        border: Border.all(
            color: isTinyCollapsed
                ? Colors.transparent
                : tagColor.withOpacity(0.5),
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
          letterSpacing: isTinyCollapsed ? 1.0 : 0.5,
          height: 1.0,
        ),
        child: Text(label),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool isRecommended;
  final Color vermilion;
  final Color inkText;
  final Color paperLight;
  final Color woodDark;

  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.isRecommended = false,
    required this.vermilion,
    required this.inkText,
    required this.paperLight,
    required this.woodDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFFCF5) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? woodDark : const Color(0xFFEEEEEE),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: woodDark.withOpacity(0.08),
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
              // Taiji Icon (Radio Mark)
              _TaijiRadio(
                selected: selected,
                darkColor: woodDark,
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
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: inkText,
                          ),
                        ),
                        if (isRecommended) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: vermilion.withOpacity(0.1),
                              border: Border.all(
                                  color: vermilion.withOpacity(0.4),
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
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaijiRadio extends StatefulWidget {
  final bool selected;
  final Color darkColor;
  final Color lightColor;

  const _TaijiRadio({
    required this.selected,
    required this.darkColor,
    required this.lightColor,
  });

  @override
  State<_TaijiRadio> createState() => _TaijiRadioState();
}

class _TaijiRadioState extends State<_TaijiRadio>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.selected) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _TaijiRadio oldWidget) {
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

    // 1. Draw base semi-circles
    paint.color = darkColor;
    canvas.drawArc(rect, pi / 2, pi, true, paint);

    paint.color = lightColor;
    canvas.drawArc(rect, -pi / 2, pi, true, paint);

    // 2. Draw inner circles for S-curve
    final innerRadius = radius / 2;

    paint.color = lightColor;
    canvas.drawCircle(Offset(radius, radius / 2), innerRadius, paint);

    paint.color = darkColor;
    canvas.drawCircle(Offset(radius, radius * 1.5), innerRadius, paint);

    // 3. Draw small eyes
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

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final Color woodDark;
  final Color? goldLeaf;

  const _ActionButton({
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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

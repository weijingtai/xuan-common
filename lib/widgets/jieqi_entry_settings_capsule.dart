import 'package:flutter/material.dart';
import 'package:common/features/datetime_details/jieqi_entry_strategy_store.dart';

import 'settings_capsules/precision_settings_capsule.dart';

export 'package:common/features/datetime_details/jieqi_entry_strategy_store.dart'
    show JieQiEntryPrecision;

enum JieQiEntryCapsuleMode { normal, tiny }

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

  static const CapsuleColorScheme _colors = CapsuleColorScheme(
    woodDark: Color(0xFF2A1B15),
    goldLeaf: Color(0xFFD4AF37),
    paperLight: Color(0xFFFDFAF2),
    vermilion: Color(0xFFA62C2B),
    inkText: Color(0xFF333333),
  );

  static const List<CapsuleOption<JieQiEntryPrecision>> _options = [
    CapsuleOption(
      value: JieQiEntryPrecision.shichen,
      title: '按时辰交节',
      subtitle: '两小时一段；与子时日界有关。',
    ),
    CapsuleOption(
      value: JieQiEntryPrecision.hour,
      title: '按小时交节',
    ),
    CapsuleOption(
      value: JieQiEntryPrecision.minute,
      title: '按分钟交节',
      subtitle: '现代科学计算，精确到分钟。',
      isRecommended: true,
    ),
    CapsuleOption(
      value: JieQiEntryPrecision.second,
      title: '按秒交节',
      subtitle: '最严格判定，精确到秒。',
    ),
  ];

  void _onSelect(JieQiEntryPrecision p) {
    setState(() => _current = p);
    JieQiEntryStrategyStore.current = p;
    if (widget.applyOnChange) {
      widget.onChanged?.call(p);
    }
  }

  Future<void> _onConfirm(JieQiEntryPrecision p) async {
    await JieQiEntryStrategyStore.persistDefault(p);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('交节方案已更新')),
      );
    }
  }

  String _labelShort(JieQiEntryPrecision p) => switch (p) {
        JieQiEntryPrecision.shichen => '時辰',
        JieQiEntryPrecision.hour => '小時',
        JieQiEntryPrecision.minute => '分鐘',
        JieQiEntryPrecision.second => '秒時',
      };

  @override
  Widget build(BuildContext context) {
    return PrecisionSettingsCapsule<JieQiEntryPrecision>(
      headTitle: '交節',
      subTitle: '方案',
      labelBuilder: _labelShort,
      options: _options,
      current: _current,
      onSelect: _onSelect,
      onConfirm: _onConfirm,
      colorScheme: _colors,
      viewMode: widget.viewMode == JieQiEntryCapsuleMode.tiny
          ? CapsuleViewMode.tiny
          : CapsuleViewMode.normal,
    );
  }
}

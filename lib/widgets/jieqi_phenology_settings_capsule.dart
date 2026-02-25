import 'package:flutter/material.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/features/datetime_details/jieqi_phenology_store.dart';
import 'package:common/widgets/jieqi_entry_settings_capsule.dart'; // JieQiEntryCapsuleMode

import 'settings_capsules/precision_settings_capsule.dart';
import 'settings_capsules/shared_settings_components.dart';

// 联动组选项：平气法+固定物候、定气法+精准物候
enum _CombinedOption { levelingFixed, stabilizingDynamic }

class JieQiPhenologySettingsCapsule extends StatefulWidget {
  final bool applyOnChange;
  final void Function(JieQiType, PhenologyStrategy)? onChanged;
  final JieQiEntryCapsuleMode viewMode;

  const JieQiPhenologySettingsCapsule({
    super.key,
    this.applyOnChange = true,
    this.onChanged,
    this.viewMode = JieQiEntryCapsuleMode.normal,
  });

  @override
  State<JieQiPhenologySettingsCapsule> createState() =>
      _JieQiPhenologySettingsCapsuleState();
}

class _JieQiPhenologySettingsCapsuleState
    extends State<JieQiPhenologySettingsCapsule> {
  late _CombinedOption _current;
  late JieQiType _jieQiType;
  late PhenologyStrategy _phenologyStrategy;

  static const CapsuleColorScheme _colors = CapsuleColorScheme(
    woodDark: Color(0xFF4A4138),
    goldLeaf: Color(0xFFB59A5A),
    paperLight: Color(0xFFFBFBF9),
    vermilion: Color(0xFFD64F44),
    inkText: Color(0xFF2C2825),
  );

  static const List<CapsuleOption<_CombinedOption>> _options = [
    CapsuleOption(
      value: _CombinedOption.levelingFixed,
      title: '平气法 + 传统固定物候',
      subtitle: '节气恒定间隔；物候以节气起点按 n×5 天固定划分。',
    ),
    CapsuleOption(
      value: _CombinedOption.stabilizingDynamic,
      title: '定气法 + 现代精准物候',
      subtitle: '节气依黄经；物候以交节起点按 n×5 天动态划分。',
      isRecommended: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (JieQiPhenologyStore.jieQiType == JieQiType.leveling) {
      _current = _CombinedOption.levelingFixed;
      _jieQiType = JieQiType.leveling;
      _phenologyStrategy = PhenologyStrategy.levelingBased;
    } else {
      _current = _CombinedOption.stabilizingDynamic;
      _jieQiType = JieQiType.stabilizing;
      _phenologyStrategy = PhenologyStrategy.stabilizingBased;
    }
  }

  void _onSelect(_CombinedOption v) {
    setState(() {
      _current = v;
      if (v == _CombinedOption.levelingFixed) {
        _jieQiType = JieQiType.leveling;
        _phenologyStrategy = PhenologyStrategy.levelingBased;
      } else {
        _jieQiType = JieQiType.stabilizing;
        _phenologyStrategy = PhenologyStrategy.stabilizingBased;
      }
    });
    if (widget.applyOnChange) {
      JieQiPhenologyStore.jieQiType = _jieQiType;
      JieQiPhenologyStore.phenologyStrategy = _phenologyStrategy;
      widget.onChanged?.call(_jieQiType, _phenologyStrategy);
    }
  }

  Future<void> _onConfirm(_CombinedOption v) async {
    JieQiPhenologyStore.jieQiType = _jieQiType;
    JieQiPhenologyStore.phenologyStrategy = _phenologyStrategy;
    await JieQiPhenologyStore.persistDefaults(
        jq: _jieQiType, ph: _phenologyStrategy);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已设为默认：节气/物候联动策略')),
      );
    }
  }

  /// Header Tag 短标签（需简短，适配折叠胶囊宽度）
  String _labelShort(_CombinedOption o) =>
      o == _CombinedOption.levelingFixed ? '平气法' : '定气法';

  Widget _buildSetDefaultButton() {
    return Expanded(
      flex: 1,
      child: SettingsActionButton(
        label: '设为默认',
        woodDark: _colors.woodDark,
        onPressed: () async {
          JieQiPhenologyStore.jieQiType = _jieQiType;
          JieQiPhenologyStore.phenologyStrategy = _phenologyStrategy;
          await JieQiPhenologyStore.persistDefaults(
              jq: _jieQiType, ph: _phenologyStrategy);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已设为默认：节气/物候联动策略')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PrecisionSettingsCapsule<_CombinedOption>(
      headTitle: '節氣',
      subTitle: '物候',
      labelBuilder: _labelShort,
      options: _options,
      current: _current,
      onSelect: _onSelect,
      onConfirm: _onConfirm,
      colorScheme: _colors,
      collapsedWidth: 150,
      viewMode: widget.viewMode == JieQiEntryCapsuleMode.tiny
          ? CapsuleViewMode.tiny
          : CapsuleViewMode.normal,
      leftActions: [_buildSetDefaultButton(), const SizedBox(width: 8)],
    );
  }
}

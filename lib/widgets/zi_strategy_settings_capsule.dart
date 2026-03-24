import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:common/features/datetime_details/calculation_strategy_config.dart';
import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/widgets/jieqi_entry_settings_capsule.dart'; // Reusing JieQiEntryCapsuleMode

import 'settings_capsules/precision_settings_capsule.dart';
import 'settings_capsules/shared_settings_components.dart';

class ZiStrategySettingsCapsule extends StatefulWidget {
  final void Function(ZiShiStrategy strategy)? onStrategyChanged;
  final bool applyOnChange;
  final JieQiEntryCapsuleMode viewMode;

  const ZiStrategySettingsCapsule({
    super.key,
    this.onStrategyChanged,
    this.applyOnChange = true,
    this.viewMode = JieQiEntryCapsuleMode.normal,
  });

  @override
  State<ZiStrategySettingsCapsule> createState() =>
      _ZiStrategySettingsCapsuleState();
}

class _ZiStrategySettingsCapsuleState extends State<ZiStrategySettingsCapsule> {
  static const String _spKey = 'calc_zi_strategy';
  static const String _spDefaultKey = 'calc_zi_strategy_default';

  ZiShiStrategy _current = CalculationStrategyConfig.defaultConfig.ziStrategy;
  bool _loading = true;

  static const CapsuleColorScheme _colors = CapsuleColorScheme(
    woodDark: Color(0xFF2C3E2D),
    goldLeaf: Color(0xFFB59A5A),
    paperLight: Color(0xFFFBFBF9),
    vermilion: Color(0xFFD64F44),
    inkText: Color(0xFF2C2825),
  );

  // 当前 UI 中的有效选项（清除了旧版遗留枚举 startFrom23/0/splitedZi）
  static const List<CapsuleOption<ZiShiStrategy>> _options = [
    CapsuleOption(
      value: ZiShiStrategy.noDistinguishAt23,
      title: '不区分早晚（23:00 统一次日）',
      subtitle: '23:00–1:00 日柱与时柱均按次日；适合简化排盘。',
    ),
    CapsuleOption(
      value: ZiShiStrategy.distinguishAt0FiveMouse,
      title: '区分早晚（0:00 为界，五鼠遁）',
      subtitle: '23:00–0:00 日柱当日，时柱按次日；0:00–1:00 日柱与时柱均次日。',
    ),
    CapsuleOption(
      value: ZiShiStrategy.distinguishAt0Fixed,
      title: '区分早晚（0:00 为界，固定子时）',
      subtitle: '子时段固定地支为子/丑，天干顺序相续：N子 → (N+1)丑。',
    ),
    CapsuleOption(
      value: ZiShiStrategy.bandsStartAt0,
      title: '全天两小时一支（子从0点起）',
      subtitle: '子(0:00–1:59)、丑(2:00–3:59)…亥(22:00–23:59)；时柱起干。',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final saved = sp.getString(_spKey);
    final fallbackDefault = sp.getString(_spDefaultKey);
    setState(() {
      _current = _parse(saved) ??
          _parse(fallbackDefault) ??
          CalculationStrategyConfig.defaultConfig.ziStrategy;
      _loading = false;
    });
  }

  Future<void> _save(ZiShiStrategy s) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_spKey, _toString(s));
  }

  String _toString(ZiShiStrategy s) => switch (s) {
        ZiShiStrategy.noDistinguishAt23 => 'noDistinguishAt23',
        ZiShiStrategy.distinguishAt0FiveMouse => 'distinguishAt0FiveMouse',
        ZiShiStrategy.distinguishAt0Fixed => 'distinguishAt0Fixed',
        ZiShiStrategy.bandsStartAt0 => 'bandsStartAt0',
        // 将旧枚举值序列化为对应新值，保持向后兼容
        ZiShiStrategy.startFrom23 => 'noDistinguishAt23',
        ZiShiStrategy.startFrom0 => 'distinguishAt0FiveMouse',
        ZiShiStrategy.splitedZi => 'distinguishAt0FiveMouse',
      };

  ZiShiStrategy? _parse(String? s) => switch (s) {
        'noDistinguishAt23' => ZiShiStrategy.noDistinguishAt23,
        'distinguishAt0FiveMouse' => ZiShiStrategy.distinguishAt0FiveMouse,
        'distinguishAt0Fixed' => ZiShiStrategy.distinguishAt0Fixed,
        'bandsStartAt0' => ZiShiStrategy.bandsStartAt0,
        // 兼容旧存储字符串，静默迁移到新枚举
        'startFrom23' => ZiShiStrategy.noDistinguishAt23,
        'startFrom0' => ZiShiStrategy.distinguishAt0FiveMouse,
        'splitedZi' => ZiShiStrategy.distinguishAt0FiveMouse,
        _ => null,
      };

  void _onSelect(ZiShiStrategy s) {
    setState(() => _current = s);
    _save(s);
    if (widget.applyOnChange) {
      widget.onStrategyChanged?.call(s);
    }
  }

  Future<void> _onConfirm(ZiShiStrategy s) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_spDefaultKey, _toString(s));
    widget.onStrategyChanged?.call(s);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已应用策略：${_labelShort(s)}')),
      );
    }
  }

  /// Header Tag 短标签（需简短，适配折叠胶囊宽度）
  String _labelShort(ZiShiStrategy s) => switch (s) {
        ZiShiStrategy.noDistinguishAt23 => '23次日',
        ZiShiStrategy.distinguishAt0FiveMouse => '五鼠遁',
        ZiShiStrategy.distinguishAt0Fixed => '固定子',
        ZiShiStrategy.bandsStartAt0 => '整点起',
        // 旧枚举兜底（exhaustive switch 要求，理论上不触达）
        ZiShiStrategy.startFrom23 => '23次日',
        ZiShiStrategy.startFrom0 => '五鼠遁',
        ZiShiStrategy.splitedZi => '五鼠遁',
      };

  Widget _buildResetButton() {
    return Expanded(
      flex: 1,
      child: SettingsActionButton(
        label: '重置',
        woodDark: _colors.woodDark,
        onPressed: () async {
          final def = CalculationStrategyConfig.defaultConfig.ziStrategy;
          await _save(def);
          setState(() => _current = def);
        },
      ),
    );
  }

  Widget _buildSetDefaultButton() {
    return Expanded(
      flex: 1,
      child: SettingsActionButton(
        label: '设为默认',
        woodDark: _colors.woodDark,
        onPressed: () async {
          final sp = await SharedPreferences.getInstance();
          await sp.setString(_spDefaultKey, _toString(_current));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('已设为默认：${_labelShort(_current)}')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
          width: 64, height: 64, child: CircularProgressIndicator());
    }

    return PrecisionSettingsCapsule<ZiShiStrategy>(
      headTitle: '子時',
      subTitle: '策略',
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
      leftActions: [
        _buildResetButton(),
        const SizedBox(width: 8),
        _buildSetDefaultButton(),
        const SizedBox(width: 8),
      ],
    );
  }
}

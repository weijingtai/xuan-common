import 'package:flutter/material.dart';
import 'package:common/widgets/jieqi_entry_settings_capsule.dart';
import 'package:common/widgets/jieqi_phenology_settings_capsule.dart';
import 'package:common/widgets/zi_strategy_settings_capsule.dart';
import 'package:common/features/datetime_details/jieqi_entry_strategy_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JieQiEntryStrategyStore.initFromPrefs();
  runApp(const MaterialApp(home: SettingsCapsuleDemo()));
}

class SettingsCapsuleDemo extends StatelessWidget {
  const SettingsCapsuleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EDE5),
      appBar: AppBar(
        title: const Text('Settings Capsule Demo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2A1B15),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ──── Normal Mode（点击展开完整面板） ────
            const Text(
              'Normal Mode (click to expand):',
              style: TextStyle(color: Color(0xFF888888), fontSize: 12),
            ),
            const SizedBox(height: 8),
            const JieQiEntrySettingsCapsule(
              viewMode: JieQiEntryCapsuleMode.normal,
            ),
            const SizedBox(height: 40),

            // ──── Tiny Mode（三个胶囊统一风格） ────
            const Text(
              'Tiny Mode (hover → expand):',
              style: TextStyle(color: Color(0xFF888888), fontSize: 12),
            ),
            const SizedBox(height: 16),

            // 交节精度
            JieQiEntrySettingsCapsule(
              viewMode: JieQiEntryCapsuleMode.tiny,
              onChanged: (val) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('交节: $val')));
              },
            ),
            const SizedBox(height: 12),

            // 节气物候
            JieQiPhenologySettingsCapsule(
              viewMode: JieQiEntryCapsuleMode.tiny,
              onChanged: (type, strategy) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('物候: $type')));
              },
            ),
            const SizedBox(height: 12),

            // 子时策略
            ZiStrategySettingsCapsule(
              viewMode: JieQiEntryCapsuleMode.tiny,
              onStrategyChanged: (strategy) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('子时: $strategy')));
              },
            ),
          ],
        ),
      ),
    );
  }
}

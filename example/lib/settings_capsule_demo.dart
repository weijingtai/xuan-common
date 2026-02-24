import 'package:flutter/material.dart';
import 'package:common/widgets/jieqi_entry_settings_capsule.dart';
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
      backgroundColor: const Color(0xFFF0EDE5), // body background from HTML
      appBar: AppBar(
        title: const Text('Settings Capsule Demo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2A1B15),
      ),
      body: const Center(child: JieQiEntrySettingsCapsule()),
    );
  }
}

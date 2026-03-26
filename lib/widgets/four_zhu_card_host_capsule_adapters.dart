import 'package:flutter/widgets.dart';

import 'jieqi_entry_settings_capsule.dart';
import 'zi_strategy_settings_capsule.dart';

class FourZhuHostZiStrategyTinyCapsule extends StatelessWidget {
  const FourZhuHostZiStrategyTinyCapsule({super.key});

  @override
  Widget build(BuildContext context) {
    return const ZiStrategySettingsCapsule(
      viewMode: JieQiEntryCapsuleMode.tiny,
    );
  }
}

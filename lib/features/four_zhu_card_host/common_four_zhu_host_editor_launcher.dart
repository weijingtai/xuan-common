import 'package:flutter/material.dart';
import 'package:xuan_four_zhu_host/xuan_four_zhu_host.dart' as host_pkg;

import '../../pages/four_zhu_edit_page.dart';

class CommonFourZhuHostEditorLauncher
    implements host_pkg.FourZhuHostEditorLauncher {
  CommonFourZhuHostEditorLauncher(this.context);

  final BuildContext context;

  @override
  Future<void> openEditor({
    required String collectionId,
    String? initialTemplateId,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FourZhuEditPage(
          collectionId: collectionId,
          initialTemplateId: initialTemplateId,
        ),
      ),
    );
  }
}

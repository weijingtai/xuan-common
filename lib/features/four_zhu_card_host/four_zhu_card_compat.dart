import 'package:xuan_four_zhu_card/enums/enum_gender.dart' as card_gender;
import 'package:xuan_four_zhu_card/enums/enum_jia_zi.dart' as card_jiazi;
import 'package:xuan_four_zhu_card/models/drag_payloads.dart' as card_payloads;
import 'package:xuan_four_zhu_card/features/four_zhu_card/widgets/editable_fourzhu_card/models/theme_color_mode.dart'
    as card_color_mode;
import 'package:xuan_four_zhu_card/themes/editable_four_zhu_card_theme.dart'
    as card_theme;

import '../../enums/enum_gender.dart';
import '../../enums/enum_jia_zi.dart';
import '../../models/drag_payloads.dart';
import '../../models/text_style_config.dart';
import '../../themes/editable_four_zhu_card_theme.dart';

class FourZhuCardCompat {
  const FourZhuCardCompat._();

  static card_gender.Gender toCardGender(Gender value) =>
      card_gender.Gender.values.byName(value.name);

  static card_jiazi.JiaZi toCardJiaZi(JiaZi value) =>
      card_jiazi.JiaZi.values.byName(value.name);

  static card_color_mode.TextColorMode toCardColorPreviewMode(
    ColorPreviewMode value,
  ) =>
      card_color_mode.TextColorMode.values.byName(value.name);

  static card_theme.EditableFourZhuCardTheme toCardTheme(
    EditableFourZhuCardTheme value,
  ) =>
      card_theme.EditableFourZhuCardTheme.fromJson(value.toJson());

  static card_payloads.CardPayload toCardPayload(CardPayload value) =>
      card_payloads.CardPayload.fromJson(value.toJson());
}

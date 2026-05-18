import 'package:xuan_four_zhu_card/enums/enum_di_zhi.dart' as card_di_zhi;
import 'package:xuan_four_zhu_card/enums/enum_jia_zi.dart' as card_jia_zi;
import 'package:xuan_four_zhu_card/enums/enum_tian_gan.dart' as card_tian_gan;
import 'package:xuan_four_zhu_card/enums/layout_template_enums.dart' as card_enums;
import 'package:xuan_four_zhu_card/models/pillar_content.dart' as card_pillar;
import 'package:xuan_four_zhu_card/models/row_strategy.dart' as card_strategy;
import 'package:tuple/tuple.dart';

import '../../enums/enum_di_zhi.dart';
import '../../enums/enum_jia_zi.dart';
import '../../enums/enum_tian_gan.dart';
import '../../enums/layout_template_enums.dart';
import '../../features/four_zhu/four_zhu_engine.dart';
import '../../models/eight_chars.dart';
import '../../models/pillar_content.dart';

class CommonHouseCalculator implements card_strategy.HouseCalculator {
  const CommonHouseCalculator();

  @override
  Tuple2<card_tian_gan.TianGan, card_di_zhi.DiZhi>? calculateLifeHouse({
    required List<card_pillar.PillarContent> pillars,
    required DateTime? referenceDateTime,
  }) {
    return _calculateHouse(
      pillars: pillars,
      referenceDateTime: referenceDateTime,
      isLifeHouse: true,
    );
  }

  @override
  Tuple2<card_tian_gan.TianGan, card_di_zhi.DiZhi>? calculateBodyHouse({
    required List<card_pillar.PillarContent> pillars,
    required DateTime? referenceDateTime,
  }) {
    return _calculateHouse(
      pillars: pillars,
      referenceDateTime: referenceDateTime,
      isLifeHouse: false,
    );
  }

  Tuple2<card_tian_gan.TianGan, card_di_zhi.DiZhi>? _calculateHouse({
    required List<card_pillar.PillarContent> pillars,
    required DateTime? referenceDateTime,
    required bool isLifeHouse,
  }) {
    if (referenceDateTime == null) return null;

    JiaZi? year;
    JiaZi? month;
    JiaZi? day;
    JiaZi? hour;

    for (final p in pillars) {
      final type = card_enums.PillarType.values.byName(p.pillarType.name);
      if (type == PillarType.year) year ??= _toCommonJiaZi(p.jiaZi);
      if (type == PillarType.month) month ??= _toCommonJiaZi(p.jiaZi);
      if (type == PillarType.day) day ??= _toCommonJiaZi(p.jiaZi);
      if (type == PillarType.hour) hour ??= _toCommonJiaZi(p.jiaZi);
    }

    if (year == null || month == null || day == null || hour == null) {
      return null;
    }

    final eightChars = EightChars(
      year: year,
      month: month,
      day: day,
      time: hour,
    );

    final house = isLifeHouse
        ? LifeBodyHouseCalculator.calculateLifeHouse(
            birthDateTime: referenceDateTime,
            eightChars: eightChars,
          )
        : LifeBodyHouseCalculator.calculateBodyHouse(
            birthDateTime: referenceDateTime,
            eightChars: eightChars,
          );

    return Tuple2(
      _fromCommonTianGan(house.item1),
      _fromCommonDiZhi(house.item2),
    );
  }

  JiaZi _toCommonJiaZi(card_jia_zi.JiaZi value) {
    return JiaZi.values.byName(value.name);
  }

  card_tian_gan.TianGan _fromCommonTianGan(TianGan value) {
    return card_tian_gan.TianGan.values.firstWhere(
      (element) => element.name == value.name,
      orElse: () => card_tian_gan.TianGan.JIA,
    );
  }

  card_di_zhi.DiZhi _fromCommonDiZhi(DiZhi value) {
    return card_di_zhi.DiZhi.values.firstWhere(
      (element) => element.name == value.name,
      orElse: () => card_di_zhi.DiZhi.ZI,
    );
  }
}

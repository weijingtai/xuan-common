import 'package:common/features/datetime_details/input_info_params.dart';
import 'package:common/models/chinese_date_info.dart';
import 'package:common/models/divination_datetime.dart';
import 'package:common/themes/gan_zhi_gua_colors.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lunar_date_info_v2_data.g.dart';

/// [LunarDateInfoCardV2] 小部件的数据模型。
///
/// 此类封装了渲染 V2 版农历日期信息卡所需的所有必要信息和预计算值。
/// 它使用 [Equatable] 进行高效比较，并使用 [JsonSerializable] 进行数据持久化。
@JsonSerializable()
class LunarDateInfoV2Data extends Equatable {
  /// 包含详细日期和时间信息的捆绑包。
  final DateTimeDetailsBundle bundle;

  /// 当前使用的日期时间类型（标准、真太阳时等）。
  final EnumDatetimeType inUsed;

  /// UI 中是否隐藏日期时间类型标签。
  final bool isHiddenDatetimeType;

  /// 显示在卡片上的可选标签字符串（Chip）。
  final String? cardChipTagStr;

  /// 创建 [LunarDateInfoV2Data] 实例。
  const LunarDateInfoV2Data({
    required this.bundle,
    required this.inUsed,
    this.isHiddenDatetimeType = false,
    this.cardChipTagStr,
  });

  /// 根据 [inUsed] 类型解析正确的 [ChineseDateInfo]。
  ChineseDateInfo? get chineseDateInfo {
    switch (inUsed) {
      case EnumDatetimeType.standard:
        return bundle.standeredChineseInfo;
      case EnumDatetimeType.removeDST:
        return bundle.removeDSTChineseInfo;
      case EnumDatetimeType.meanSolar:
        return bundle.meanSolarChineseInfo;
      case EnumDatetimeType.trueSolar:
        return bundle.trueSolarChineseInfo;
    }
  }

  /// 根据 [inUsed] 类型解析正确的 [DateTime]。
  DateTime? get dateTime {
    switch (inUsed) {
      case EnumDatetimeType.standard:
        return bundle.standeredDatetime;
      case EnumDatetimeType.removeDST:
        return bundle.removeDSTDatetime;
      case EnumDatetimeType.meanSolar:
        return bundle.meanSolarDatetime;
      case EnumDatetimeType.trueSolar:
        return bundle.trueSolarDatetime;
    }
  }

  /// 根据月份地支派生的主文本主题颜色。
  Color get mainlyTextThemeColor =>
      AppColors.zodiacZhiColors[chineseDateInfo!.eightChars.month.diZhi]!;

  /// 根据时辰地支派生的时间主题颜色。
  Color get timingTextThemeColor =>
      AppColors.zodiacZhiColors[chineseDateInfo!.eightChars.hourDiZhi]!;

  @override
  List<Object?> get props => [
        bundle,
        inUsed,
        isHiddenDatetimeType,
        cardChipTagStr,
      ];

  factory LunarDateInfoV2Data.fromJson(Map<String, dynamic> json) =>
      _$LunarDateInfoV2DataFromJson(json);

  Map<String, dynamic> toJson() => _$LunarDateInfoV2DataToJson(this);
}

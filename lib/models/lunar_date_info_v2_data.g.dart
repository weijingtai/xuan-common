// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lunar_date_info_v2_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LunarDateInfoV2Data _$LunarDateInfoV2DataFromJson(Map<String, dynamic> json) =>
    LunarDateInfoV2Data(
      bundle: DateTimeDetailsBundle.fromJson(
          json['bundle'] as Map<String, dynamic>),
      inUsed: $enumDecode(_$EnumDatetimeTypeEnumMap, json['inUsed']),
      isHiddenDatetimeType: json['isHiddenDatetimeType'] as bool? ?? false,
      cardChipTagStr: json['cardChipTagStr'] as String?,
    );

Map<String, dynamic> _$LunarDateInfoV2DataToJson(
        LunarDateInfoV2Data instance) =>
    <String, dynamic>{
      'bundle': instance.bundle,
      'inUsed': _$EnumDatetimeTypeEnumMap[instance.inUsed]!,
      'isHiddenDatetimeType': instance.isHiddenDatetimeType,
      'cardChipTagStr': instance.cardChipTagStr,
    };

const _$EnumDatetimeTypeEnumMap = {
  EnumDatetimeType.standard: '标准时间',
  EnumDatetimeType.removeDST: '移除夏令时',
  EnumDatetimeType.meanSolar: '平太阳时',
  EnumDatetimeType.trueSolar: '真太阳时',
};

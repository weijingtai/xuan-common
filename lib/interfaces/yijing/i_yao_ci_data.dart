/// 爻辞数据模型接口
abstract interface class IYaoCiData {
  /// 爻ID
  int get id;

  /// 爻在卦中的序号（1-6）
  int get seqInGua;

  /// 爻名（如"初九"、"六二"）
  String get yaoName;

  /// 卦爻名（如"乾·初九"）
  String get guaYaoName;

  /// 爻辞内容
  String? get yaoCi;

  /// 爻象辞
  String? get xiangCi;
}

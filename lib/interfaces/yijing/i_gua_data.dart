/// 易经卦象数据模型接口
/// 定义卦象的基本数据结构
abstract interface class IGuaData {
  /// 卦的二进制编码（6位，如"111111"代表乾卦）
  String get binary;

  /// 卦序号（1-64）
  int get seq;

  /// 卦名（简称，如"乾"）
  String get name;

  /// 卦全名（如"乾为天"）
  String get fullname;

  /// 卦辞
  String? get guaCi;

  /// 彖辞
  String? get tuanCi;

  /// 象辞
  String? get xiangCi;

  /// 内卦名称
  String? get innerBaguaName;

  /// 外卦名称
  String? get outerBaguaName;
}

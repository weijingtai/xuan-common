import 'i_gua_data.dart';
import 'i_yao_ci_data.dart';

/// 易经服务接口
///
/// 定义易经相关的核心业务逻辑接口
/// 由 xuan-yijing 项目提供具体实现
abstract interface class IYijingService {
  // ==================== 卦象查询 ====================

  /// 获取所有卦象列表
  Future<List<IGuaData>> getAllGua();

  /// 根据二进制编码获取卦象
  /// [binary] 6位二进制字符串，如"111111"代表乾卦
  Future<IGuaData?> getGuaByBinary(String binary);

  /// 根据名称搜索卦象
  /// [name] 卦名（支持简称如"乾"或全名如"乾为天"）
  Future<List<IGuaData>> searchGuaByName(String name);

  /// 根据序号获取卦象
  /// [seq] 卦序号（1-64）
  Future<IGuaData?> getGuaBySeq(int seq);

  // ==================== 爻辞/彖辞/象辞 ====================

  /// 获取卦的所有爻辞
  /// [guaBinary] 卦的二进制编码
  Future<List<IYaoCiData>> getYaoCi(String guaBinary);

  /// 获取卦的彖辞
  /// [guaBinary] 卦的二进制编码
  Future<String?> getTuanCi(String guaBinary);

  /// 获取卦的象辞
  /// [guaBinary] 卦的二进制编码
  Future<String?> getXiangCi(String guaBinary);

  /// 获取卦的卦辞
  /// [guaBinary] 卦的二进制编码
  Future<String?> getGuaCi(String guaBinary);

  // ==================== 工具方法 ====================

  /// 验证二进制编码是否有效
  /// [binary] 6位二进制字符串
  Future<bool> isValidBinary(String binary);

  /// 获取卦象数量
  Future<int> getGuaCount();
}

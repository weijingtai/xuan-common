import 'ai_entity.dart';

/// AI 上下文容器：包含一次交互的所有背景信息。
///
/// 当子模块（如 xuan-qimendunjia）需要调用 AI 服务时，
/// 它将业务数据封装为 [AiContext]，传递给 [AiService]。
class AiContext {
  /// 用户意图描述，如 "请分析这个奇门局的财运"。
  final String intention;

  /// 附带的实体列表。一个上下文可以包含多个不同类型的实体。
  final List<AiEntity> entities;

  /// 可选：覆盖系统提示词（慎用）。
  ///
  /// 通常由 AI 服务自行管理系统提示词，
  /// 但某些特殊场景下模块可能需要定制化的指令。
  final String? systemPromptOverride;

  const AiContext({
    required this.intention,
    this.entities = const [],
    this.systemPromptOverride,
  });

  /// 从 JSON 创建 [AiContext]。
  factory AiContext.fromJson(Map<String, dynamic> json) {
    return AiContext(
      intention: json['intention'] as String,
      entities: (json['entities'] as List<dynamic>?)
              ?.map((e) => AiEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      systemPromptOverride: json['systemPromptOverride'] as String?,
    );
  }

  /// 将 [AiContext] 转换为 JSON。
  Map<String, dynamic> toJson() {
    return {
      'intention': intention,
      'entities': entities.map((e) => e.toJson()).toList(),
      if (systemPromptOverride != null)
        'systemPromptOverride': systemPromptOverride,
    };
  }

  /// 获取上下文中特定类型的所有实体。
  List<AiEntity> entitiesOfType(String type) {
    return entities.where((e) => e.type == type).toList();
  }

  /// 检查上下文中是否包含特定类型的实体。
  bool hasEntityOfType(String type) {
    return entities.any((e) => e.type == type);
  }

  @override
  String toString() =>
      'AiContext(intention: "$intention", entities: ${entities.length})';
}

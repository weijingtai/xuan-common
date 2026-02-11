import 'package:flutter/widgets.dart';

import '../domain/ai/ai_persona.dart';
import '../domain/ai/ai_action.dart';
import '../domain/ai/ai_config_summary.dart';
import '../domain/ai/ai_context.dart';
import '../domain/ai/agent_tool.dart';

/// AI 服务接口：定义 AI 模块对外提供的所有能力。
///
/// 此接口在 `xuan-common` 中定义，由 `xuan-ai` 实现。
/// 子模块通过依赖注入获取 [AiService] 实例，
/// 无需直接依赖 `xuan-ai` 模块。
///
/// ## 核心能力
///
/// ### 聊天 & 分析
/// - [openChat]: 打开 AI 聊天窗口，可携带业务上下文。
/// - [analyze]: 后台分析（不打开 UI）。
/// - [showPersonaSelector]: 弹出 AI 人设选择器。
///
/// ### 数据持久化
/// - [getSummary] / [watchSummary]: 获取/监听 AI 生成的摘要。
///
/// ### 配置管理
/// - [showConfigSheet]: 唤起通用配置面板。
/// - [activeConfig]: 监听当前 AI 配置。
///
/// ### 扩展注册
/// - [registerAction] / [getAvailableActions]: Link A 动态动作。
/// - [registerTool] / [getAvailableTools]: Link B 工具能力。
abstract class AiService {
  // ============================================================
  // 聊天 & 分析
  // ============================================================

  /// 打开 AI 聊天窗口。
  ///
  /// [context]: Flutter BuildContext，用于导航。
  /// [initialContext]: 初始上下文数据。如果非空，AI 会在开启时自动加载这些数据。
  Future<void> openChat({
    required BuildContext context,
    AiContext? initialContext,
  });

  /// 构建聊天视图 Widget (用于嵌入 Drawer 或其他容器)。
  ///
  /// [persona]: 可选，指定聊天使用的人设。
  Widget buildChatView(
    BuildContext context, {
    AiContext? initialContext,
    AiPersona? persona,
  });

  /// 弹出 AI 人设选择器。
  ///
  /// [context]: Flutter BuildContext，用于显示 Dialog/BottomSheet。
  /// [requiredSkills]: 可选，仅展示具备指定 Skill ID 的人设。
  ///
  /// 返回用户选择的 [AiPersona]，如果取消则返回 null。
  /// 此操作可能允许用户在界面上新增人设。
  Future<AiPersona?> showPersonaSelector({
    required BuildContext context,
    List<int>? requiredSkills,
  });

  /// 仅发送数据给 AI 进行后台分析，不打开界面。
  ///
  /// 返回 AI 的文本响应。
  Future<String> analyze({
    required AiContext context,
  });

  // ============================================================
  // 数据持久化（AI 生成的摘要/断语）
  // ============================================================

  /// 根据实体 ID 获取最新的 AI 总结/断语。
  ///
  /// 返回 null 表示该实体尚无 AI 总结。
  Future<String?> getSummary({required String entityId});

  /// 监听指定实体的 AI 总结更新。
  ///
  /// 当新的总结生成时，流会发出新值。
  Stream<String?> watchSummary({required String entityId});

  // ============================================================
  // 配置管理
  // ============================================================

  /// 唤起 AI 配置面板（如选择卦师/模型）。
  ///
  /// 返回 true 表示用户确认了修改。
  Future<bool> showConfigSheet({
    required BuildContext context,
  });

  /// 获取当前激活的 AI 配置摘要。
  ///
  /// 子模块监听此流，实时更新界面上的配置文本。
  Stream<AiConfigSummary> get activeConfig;

  // ============================================================
  // Link A: 动态动作注册 (AiAction)
  // ============================================================

  /// 注册一个新的 [AiAction]。
  ///
  /// 通常在模块初始化时调用。
  void registerAction(AiAction action);

  /// 获取适用于当前上下文的所有动作。
  ///
  /// Chat UI 使用此方法动态渲染 Action 按钮栏。
  List<AiAction> getAvailableActions(AiContext context);

  // ============================================================
  // Link B: 工具注册 (AgentTool)
  // ============================================================

  /// 注册一个新的 [AgentTool]。
  ///
  /// 通常在模块初始化时调用。
  void registerTool(AgentTool tool);

  /// 获取当前所有已注册的工具。
  ///
  /// AgentRunner 在构造 LLM 请求时使用此方法。
  List<AgentTool> getAvailableTools();
}

# not_only_common：四柱 Card 首批 package 化任务清单

## 0. 文档冻结

- [x] 冻结四柱 Card 首批 package 边界
- [x] 冻结 `common` 在过渡期只做 facade 的原则
- [x] 记录当前已知的边界污染点

---

## 1. 代码盘点

- [x] 盘点四柱 Card 相关源码入口
- [x] 盘点四柱 Card 当前对 `common` 数据库/模板/同步层的依赖
- [x] 盘点当前真实业务接入点（至少 `qizhengsiyu`）
- [x] 标记哪些 import 属于非四柱专属泄漏依赖

交付物：

- 四柱 Card 代码归属清单
- 暂不迁移清单

---

## 2. Package Scaffold

### 2.1 新建 package 目录

- [x] `xuan-four-zhu-card`
- [x] `xuan-four-zhu-host`
- [x] `xuan-four-zhu-templates`
- [x] `xuan-four-zhu-editor`

### 2.2 每个 package 建立最小结构

- [x] `xuan-four-zhu-card`：`pubspec.yaml`
- [x] `xuan-four-zhu-card`：`lib/`
- [x] `xuan-four-zhu-card`：package 主导出文件
- [x] `xuan-four-zhu-card`：说明 package 依赖方向
- [x] `xuan-four-zhu-host`：`pubspec.yaml`
- [x] `xuan-four-zhu-host`：`lib/`
- [x] `xuan-four-zhu-host`：package 主导出文件
- [x] `xuan-four-zhu-host`：说明 package 依赖方向
- [x] `xuan-four-zhu-templates`：`pubspec.yaml`
- [x] `xuan-four-zhu-templates`：`lib/`
- [x] `xuan-four-zhu-templates`：package 主导出文件
- [x] `xuan-four-zhu-templates`：说明 package 依赖方向
- [x] `xuan-four-zhu-editor`：最小结构

---

## 2.5 打断循环依赖

当前已确认的阻塞：

- [x] 已识别 `xuan_four_zhu_card` 对 `xuan-common` 的残余依赖面
- [x] 已避免在 `common` 中直接反向 re-export 新 package 形成循环依赖

需要完成：

- [ ] 识别第一批可脱离 `common` 的四柱专属基础类型
- [ ] 优先迁移 theme/style/model 最小子集
- [x] 确保新 package 对 `common` 的依赖逐步缩窄
- [x] 为后续 `common` facade 预留无环依赖路径
- [ ] 将 `xuan_four_zhu_card` root export 收窄为 style/theme 子集
- [ ] 将 render/widget bridge 保持在 subpath，避免 root API 语义混乱

第一批优先候选：

- [ ] `editable_four_zhu_card_theme.dart`
- [ ] `base_style_config.dart`
- [ ] `card_style_config.dart`
- [ ] `cell_style_config.dart`
- [ ] `pillar_style_config.dart`
- [ ] `theme_color_mode.dart`

已完成的第一轮结果：

- [x] `xuan_four_zhu_card` root 收窄为 style/theme 公共面
- [x] `EditableFourZhuCardTheme` 本地化
- [x] `base/card/cell/pillar` style models 本地化
- [x] 四柱 layout enum 子集本地化
- [x] `RowData` / `PillarData` / `PillarContent` / `CardLayoutModel` / `FourZhuText` 本地化
- [x] `FourZhuAddPalette` 本地化
- [x] render/widget bridge 下沉到 subpath，不再进入 root export
- [x] 主渲染 widget 目录树已机械本地化
- [x] `widgets/editable_fourzhu_card.dart` 已切换为本地入口
- [x] `TextStyleConfig` 已本地化

## 2.6 机械迁移主渲染模型闭包

- [x] 迁移 `drag_payloads.dart`
- [x] 迁移 `row_data.dart`
- [x] 迁移 `pillar_content.dart`
- [x] 迁移 `pillar_data.dart`
- [x] 迁移 `row_strategy.dart`
- [x] 迁移 `constant_values_utils.dart`
- [x] 迁移 `card_layout_model.dart`
- [x] 添加 `four_zhu_card_models.dart`
- [x] 添加 `four_zhu_card_domain.dart`
- [x] 添加最小 `enums` 门面
- [x] 机械迁移 `style_resolver.dart`
- [x] 解开 `style_resolver.dart` 对 `common` 的直接依赖
- [x] 继续收拢 `editable_fourzhu_card_impl.dart` 的残余 `common` 依赖
- [x] 当前仅允许机械迁移，不改业务逻辑

---

## 3. UI 迁移

- [x] 迁移 `EditableFourZhuCardV3` 相关实现到 `xuan-four-zhu-card`
- [x] 迁移 card theme 与相关 style model
- [x] 迁移 card 内部 cells / decorators / size calculator
- [ ] 在 `common` 中保留旧导出兼容入口

迁移前必须额外检查：

- [x] `EditableFourZhuCardV3` 中直接引用的 `package:common/...` 类型清单
- [x] 哪些依赖属于四柱专属，哪些属于更底层基础类型
- [x] 是否会因为反向 facade 形成循环依赖

验收：

- [ ] 旧导入路径仍可编译
- [x] 新 package 导入路径可编译
- [x] card 展示无回归

---

## 4. Host 迁移

- [ ] 迁移 `FourZhuCardHost`
- [x] 迁移 `FourZhuCardHostResolver`
- [ ] 清理 host 中非四柱专属 capsule/settings 依赖
- [x] 固定 host 对 editor 的边界
- [x] 固定 host 对平台模板能力的临时依赖方式

验收：

- [x] 运行时主题切换正常
- [x] 标题显隐正常
- [x] 字段显隐正常
- [x] desktop/tablet/phone 展示策略无回归

---

## 5. Editor 迁移

- [x] 建立 `xuan-four-zhu-editor` 的 pages / viewmodels / widgets 公开入口
- [x] `FourZhuEditPage` 已有本地 facade widget
- [x] `FourZhuEditorViewModel` 已有精简公共导出
- [x] editor workspace 已有本地 facade widget
- [x] editor sidebar 已有本地 facade 入口
- [x] style editor 主面板已具备本地 facade 入口
- [ ] 保留平台模板能力的临时接入

验收：

- [ ] 编辑页可打开
- [ ] 模板切换可用
- [ ] 模板保存可用
- [ ] fallback database/auth/outbox 行为不回归

---

## 6. `common` Facade 改造

- [x] 将旧路径改为 re-export 或薄 adapter
- [x] 禁止继续在 facade 中新增真实实现
- [x] `four_zhu_add_palette` 已切到 facade/compat bridge
- [ ] 标记所有迁移完成后的旧入口状态

验收：

- [x] 旧 app 仍可工作
- [x] 新 app 可直接依赖 feature package

---

## 7. 业务试点：`qizhengsiyu`

- [x] 识别 `qizhengsiyu` 当前四柱接入点
- [x] 优先切宿主展示入口到新 package
- [x] 保持编辑页入口正常
- [x] 验证 fallback 能力在独立业务中仍成立

验收：

- [x] 展示正常
- [x] controls 正常
- [x] 编辑页可打开
- [x] 模板更新可回流

---

## 8. 风险回收

- [ ] 检查是否出现新 package 继续大而全
- [ ] 检查 `common` facade 是否重新长出新逻辑
- [ ] 检查是否有 feature core 反向依赖 editor/UI
- [ ] 检查 all-in-one 后续是否仍会绕过 package 直接吃 `common`

---

## 9. 第一阶段 Done Definition

- [x] package scaffold 存在
- [x] UI / host 至少部分真实实现已迁出
- [x] `common` 兼容导出成立
- [x] `qizhengsiyu` 具备试点迁移能力
- [x] 文档、任务和边界约束全部落地

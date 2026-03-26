# not_only_common：四柱 Card 首批 package 化实施计划

## 1. 总体执行策略

本轮实施不做“大爆炸式拆分”，采用三步法：

1. **立边界**
   - 建立 package 目标结构
   - 明确哪些代码属于 core / ui / host / editor
2. **立兼容**
   - `common` 保留旧导入路径
   - 新 package 开始承接真实实现
3. **立试点**
   - 先拿 `qizhengsiyu` 做第一业务样板
   - 再推广到其他业务 app

---

## 2. 阶段划分

### 阶段 A：文档与 package 边界冻结

目标：

- 冻结四柱 Card 第一阶段 package 设计
- 确认哪些代码暂时不迁
- 明确兼容路径

产出：

- `docs/not_only_common/PRDs.md`
- `docs/not_only_common/Plans.md`
- `docs/not_only_common/Tasks.md`

### 阶段 B：建立 package scaffold

目标：

- 新建四柱 Card 相关 package 目录
- 建立 pubspec、lib 导出入口、最小 package 结构
- 不要求一开始就全部迁完

建议最小 scaffold：

- `xuan-four-zhu-card-core/`
- `xuan-four-zhu-card-ui/`
- `xuan-four-zhu-card-host/`
- `xuan-four-zhu-card-editor/`

注意：

- 第一步可以只真正填充 `ui` 和 `host`
- `editor` 允许先保留大量 facade

### 阶段 B.5：打断循环依赖（真实迁移前置步骤）

当前已确认：

- `xuan_four_zhu_card` 已存在 bridge package
- 但它当前仍依赖 `xuan-common`
- 因此 `common` 还不能立刻反向 re-export 新 package，否则会形成循环依赖
- 当前阶段的对外 root API 只承诺 style/theme 子集，不承诺 render widget 入口

这意味着第一批“真实迁移”必须优先抽走一小块四柱专属基础类型，先把 `xuan_four_zhu_card -> common` 的依赖缩窄，再逐步实现 `common -> xuan_four_zhu_card` 的兼容导出。

建议优先处理：

- 四柱 Card 专属 theme/style model
- 四柱 Card 专属 box/pillar/cell style config
- 与四柱渲染直接相关的最小公共数据类型
- render bridge 必须留在 subpath，不能混到 root export

当前阶段的实际结果：

- `xuan_four_zhu_card` 已经拥有本地 `EditableFourZhuCardTheme`
- `base/card/cell/pillar` style models 已迁入新包
- root 仅承诺 style/theme 公共面
- 主渲染 widget bridge 仍未机械迁移，当前只做了域入口与模型闭包预备
- render/widget bridge 仍保留在子路径，不进入 root API

不建议这一阶段就处理：

- host
- editor
- 模板平台层
- 非四柱专属 capsule/settings widgets

### 阶段 C：优先迁 `ui`

原因：

- `EditableFourZhuCardV3` 与其主题/渲染部件边界最清晰
- 与数据库/模板平台耦合相对较少
- 但其内部仍直接依赖多处 `package:common/...` 类型，必须先打断最小循环依赖

目标：

- 将 card 本体与相关 theme/model 迁入 `xuan_four_zhu_card_ui`
- `common` 改为 re-export

当前已完成的前置收口：

- `EditableFourZhuCardTheme` 已本地化
- `TextStyleConfig` 已本地化
- `FourZhuAddPalette` 已本地化
- `RowData` / `PillarData` / `PillarContent` / `CardLayoutModel` / `FourZhuText` 已本地化
- 仍留在 `common` 的只剩 `style_resolver` 与部分底层桥接类型

### 阶段 C.6：机械迁移主渲染 widget 目录树本体

目标：

- 将 `features/four_zhu_card/widgets/editable_fourzhu_card/` 中可原样复制的文件组迁入 `xuan_four_zhu_card`
- 让 `widgets/editable_fourzhu_card.dart` 指向本地 impl
- 保留 `style_resolver`、`four_zhu_engine`、`eight_chars`、基础 enums 作为允许桥接
- 不修改任何渲染算法和行为

当前状态：

- 主渲染目录树已机械本地化
- `widgets/editable_fourzhu_card.dart` 已切换为本地入口
- `style_resolver.dart` 仍桥接，作为本轮最后的外部依赖点
- host/editor/template/marketplace 不在本轮范围内

### 阶段 C.5：机械迁移主渲染模型闭包

目标：

- 只做文件迁移、import 调整、兼容导出，不改渲染逻辑
- 将主渲染链的模型闭包收进 `xuan-four-zhu-card`
- 明确保留仍然需要桥接 `common` 的最小残留

已迁入的新包文件：

- `lib/enums.dart`
- `lib/enums/enum_gender.dart`
- `lib/enums/enum_jia_zi.dart`
- `lib/enums/enum_di_zhi.dart`
- `lib/enums/enum_tian_gan.dart`
- `lib/enums/enum_twelve_zhang_sheng.dart`
- `lib/enums/layout_template_enums.dart`
- `lib/models/drag_payloads.dart`
- `lib/models/pillar_content.dart`
- `lib/models/pillar_data.dart`
- `lib/models/pillar_styles.dart`
- `lib/models/row_data.dart`
- `lib/models/row_strategy.dart`
- `lib/utils/constant_values_utils.dart`
- `lib/widgets/four_zhu/card_layout_model.dart`
- `lib/four_zhu_card_models.dart`
- `lib/four_zhu_card_domain.dart`

仍然桥接 `common` 的点：

- `lib/widgets/editable_fourzhu_card.dart`
- `lib/widgets/four_zhu_add_palette.dart`
- `lib/utils/style_resolver.dart`

阻塞点：

- `style_resolver.dart` 机械迁移会把 `layout_template.dart` 一起带进来，因此本轮只保留桥接
- 主渲染 widget 本体尚未迁移，当前仅完成了机械迁移前的目录和导出预备

### 阶段 D：迁 `host`

目标：

- 迁出 `FourZhuCardHost`
- 迁出 host resolver
- 清理 host 中的非四柱专属 UI 依赖
- 保留对平台模板能力的临时依赖

重点：

- `host` 不应继续吸收不属于四柱 card 的 settings widget
- `host` 与 editor 的边界必须固定

### 阶段 E：迁 `editor`

目标：

- 迁出 `FourZhuEditPage`
- 迁出 `FourZhuEditorViewModel`
- 迁出 editor workspace 与 sidebar

约束：

- 允许 editor 在阶段 E 仍依赖平台模板/数据库层
- 不要求 editor 第一版完全脱离 `common` 的 platform 能力

### 阶段 F：业务试点迁移

目标：

- `qizhengsiyu` 优先切新 package 导入
- 旧业务 app 暂时保留旧路径

验证：

- 宿主展示正常
- controls 正常
- 编辑页跳转正常
- 模板 fallback 正常

---

## 3. 代码归属建议

### 3.1 优先迁入 `xuan_four_zhu_card_ui`

建议迁入：

- `themes/editable_four_zhu_card_theme.dart`
- `features/four_zhu_card/widgets/editable_fourzhu_card/...`
- `themes/editable_four_zhu_card_theme.dart`
- card 装饰 / 尺寸计算 / cells / theme models

优先级更高的第一批候选：

- `editable_four_zhu_card_theme.dart`
- `models/base_style_config.dart`
- `models/card_style_config.dart`
- `models/cell_style_config.dart`
- `models/pillar_style_config.dart`
- `models/theme_color_mode.dart`

暂缓迁入：

- 与 `common` 其他 feature 紧耦合的 demo 或旧兼容页面
- 仍依赖 `common/models/text_style_config.dart`、`common/models/pillar_styles.dart` 等未拆基础类型的文件

### 3.2 优先迁入 `xuan_four_zhu_card_host`

建议迁入：

- `widgets/four_zhu_card_host.dart`
- `features/four_zhu_card_host/four_zhu_card_host_resolver.dart`

迁前必须先清理：

- 非四柱专属 capsule/settings 依赖
- 不必要的跨 feature UI 引用

### 3.3 暂时保留在 `common` 的内容

过渡期先保留：

- 模板平台层：DAO / datasource / repository / usecases
- 共享模板市场
- 部分数据库 fallback 能力

理由：

- 这些能力属于更底层的平台拆分问题
- 第一阶段应先拆 feature 边界，而不是同时重做平台底座

---

## 4. 兼容导出策略

### 4.1 `common` 兼容方式

迁移后，`common` 中对应入口改为：

- 直接 `export` 新 package 公共 API
- 或保留一个薄 wrapper / adapter

禁止：

- 在兼容文件中继续新增真实实现
- 因兼容需要把新逻辑回灌进旧目录

### 4.2 app 迁移策略

迁移顺序：

1. `qizhengsiyu` 先试点
2. 其他业务按需切换
3. all-in-one 后续直接依赖 feature package

---

## 5. 验收标准

每一阶段都要通过这些验证：

### UI 阶段

- card 组件可独立被依赖
- 旧 `common` 导入路径仍可编译
- 主题和 payload 相关类型不丢失

### Host 阶段

- 宿主 controls 正常
- 主题切换 / 标题显隐 / 字段显隐正常
- desktop / tablet / phone surface 行为不回归

### Editor 阶段

- 编辑页仍可打开
- 模板保存/切换/导入正常
- fallback database/auth/outbox 行为不回归

### App 试点阶段

- `qizhengsiyu` 切到新 package 后功能与现状一致
- 不要求其他 app 同步迁移

---

## 6. 第一阶段完成定义

只有满足以下条件，才算第一阶段完成：

- 四柱 Card package scaffold 已建立
- UI / host 至少有一部分真实实现已迁移
- `common` 对旧路径提供兼容
- `qizhengsiyu` 具备切换到新 package 的明确路径
- 文档、任务分解和风险约束已落地

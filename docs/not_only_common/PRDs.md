# not_only_common：去中心化 `common` 与四柱 Card 首批 package 化 PRD

**文档版本**: v1.0  
**核心议题**: 解决 `xuan-common` 持续膨胀、业务 app 过度依赖单中心包、以及独立发布版与 all-in-one 双轨发布下的边界失控问题。  
**首批样板能力**: 四柱 Card（展示 / 宿主 / 编辑）

---

## 1. 背景

当前仓库中，绝大多数业务子项目直接依赖 `common`。而 `common` 实际上已经同时承担：

1. **基础设施层**
   - 数据库、DAO、持久化、同步/outbox、作用域 provider
2. **能力层**
   - 四柱卡、日期细节、流年树、共享模板等
3. **表现层**
   - Flutter UI 组件、宿主控件、编辑器、示例页、资源、字体
4. **兼容层**
   - 多个子项目默认通过 `common` 间接拿到上面所有能力

这种结构在“单仓多业务 + 未来独立发布 + all-in-one 双轨并重”的目标下，会持续放大三个问题：

- 任何一个局部能力都会反向污染整个平台
- 独立业务 app 无法只携带自己需要的能力
- `common` 成为版本耦合源，一处变化牵动所有子项目

---

## 2. 目标

本轮重构不是一次性拆完全部平台，而是完成以下第一阶段目标：

1. 明确 `common` 不能继续作为唯一中心包扩张
2. 将“四柱 Card”确定为第一条样板迁移线
3. 为四柱 Card 建立未来的 package 边界模型
4. 在不破坏现有业务的前提下，为子项目逐步切换到新 package 做准备
5. 保留 `common` 作为过渡期兼容门面，但停止向其中继续堆叠新的核心实现

---

## 3. 非目标

以下内容不在第一阶段直接完成：

- 一次性拆分全部术数业务 package
- 立刻移除 `common`
- 立刻拆仓为多 repo
- 一次性完成所有 import 迁移
- 一次性把所有编辑器和模板市场都独立发布

第一阶段只做“立边界、立样板、立兼容面”的工作。

---

## 4. 设计原则

### 4.1 分层原则

目标依赖方向固定为：

`foundation -> platform -> feature_core -> feature_ui/host/editor -> app/all-in-one`

禁止：

- app 反向影响 feature core
- editor 直接污染 core
- all-in-one 持有独家业务实现
- 业务特化逻辑回流 `common`

### 4.2 兼容原则

`common` 在过渡期允许存在，但只允许承担：

- facade
- re-export
- adapter

不允许继续承担：

- 新增核心能力实现
- 新增业务特化页面
- 新增“只有 common 能提供”的平台能力

### 4.3 样板原则

首个拆分样板选择四柱 Card，原因：

- 已存在完整展示链路
- 已存在完整宿主化链路
- 已存在模板管理和编辑页
- 已经接入真实业务子项目 `qizhengsiyu`
- 已暴露出 `common` 中心化带来的典型问题

---

## 5. 四柱 Card 当前问题诊断

当前四柱 Card 相关能力虽然已经有一定边界，但仍然散落在多个位置：

- `features/four_zhu_card/`：核心渲染与 card 组件
- `widgets/four_zhu_card_host.dart`：业务宿主层
- `pages/four_zhu_edit_page.dart`：标准编辑页
- `viewmodels/four_zhu_editor_view_model.dart`：编辑状态与模板编辑逻辑
- 多种模板存储 / 数据库 / DAO / sync 依赖仍在 `common` 主体中

并且当前宿主层已经出现了“边界被再次污染”的信号：

- `FourZhuCardHost` 引入了非四柱专属的 capsule/settings 组件
- host 内直接吸收数据库 fallback、auth fallback、模板仓储组装
- UI 控件、模板编辑、能力解析和基础设施启动逻辑混在一起

这说明如果不先拆四柱样板，`common` 会继续沿着“所有东西都先塞进宿主组件”这条路径膨胀。

---

## 6. 第一阶段目标边界：四柱 Card package 化

### 6.1 目标 package 模型

建议第一阶段按以下逻辑边界拆分：

#### A. `xuan_four_zhu_card_core`

职责：

- CardPayload、row/pillar 相关核心模型
- 四柱 card 渲染所需的纯数据与主题模型
- resolver 所需的纯计算与可见性映射
- 不依赖编辑器、不依赖模板数据库

不包含：

- Flutter 页面
- 编辑器
- 模板仓储
- 业务宿主控件

#### B. `xuan_four_zhu_card_ui`

职责：

- `EditableFourZhuCardV3` 及其渲染部件
- 主题、装饰、尺寸计算、cells/widgets
- 纯展示型和可交互型 card UI

依赖：

- `xuan_four_zhu_card_core`

不包含：

- 编辑页
- 模板存储
- DAO/数据库
- app 级 fallback provider

#### C. `xuan_four_zhu_card_host`

职责：

- `FourZhuCardHost`
- host resolver
- runtime controls（主题/标题/字段显隐）
- 多设备 surface 策略（desktop/tablet/phone）

依赖：

- `xuan_four_zhu_card_core`
- `xuan_four_zhu_card_ui`
- 临时仍可依赖 `common`/平台层提供的模板与数据库能力

不包含：

- 编辑器 workspace
- 编辑器 sidebar
- 非四柱专属的通用 settings widgets，除非变成 package 内局部抽象

#### D. `xuan_four_zhu_card_editor`

职责：

- `FourZhuEditPage`
- `FourZhuEditorViewModel`
- 样式编辑器、模板编辑 workspace、editor sidebar

依赖：

- `xuan_four_zhu_card_core`
- `xuan_four_zhu_card_ui`
- `xuan_four_zhu_card_host`（可选）
- 平台模板能力

### 6.2 第一步只要求做到什么

第一阶段不要求四个 package 全部彻底独立发布。  
第一步只要求做到：

- 明确这四层边界
- 至少把 package scaffold 建起来
- 将四柱 Card 相关 import 路径从“全部指向 common”开始逐步迁移
- `common` 对外提供兼容 export

---

## 7. 兼容策略

为了避免一次性迁移所有子项目，第一阶段采用“双层兼容”：

### 7.1 旧路径兼容

`common` 暂时继续暴露旧的导入入口，例如：

- `package:common/widgets/four_zhu_card_host.dart`
- `package:common/pages/four_zhu_edit_page.dart`

但实现可以逐步转为 re-export 新 package。

### 7.2 新路径试点

从 `qizhengsiyu` 先开始允许直接引用新 package：

- 宿主展示优先切到 `xuan_four_zhu_card_host`
- 编辑器和模板编辑保持过渡期兼容

这样可以一边试点，一边保证其他业务不被迫同步迁移。

---

## 8. 成功标准

第一阶段完成后，必须达到：

1. `common` 不再是四柱 Card 唯一实现归宿
2. 四柱 Card 有明确 package 级边界文档和目录落点
3. `qizhengsiyu` 作为样板业务，可以逐步从 `common` 单点依赖转向 feature package 依赖
4. `common` 可以对旧路径提供兼容，不造成大面积破坏
5. 新增四柱相关能力默认进入目标 package，而不是继续放回 `common`

---

## 9. 风险

### 9.1 伪拆分风险

如果只是新建 package，但内部仍继续从 `common` 大量跨层 import，本轮拆分会变成“目录搬家”，不会真正降低耦合。

### 9.2 兼容层反膨胀风险

如果 `common` facade 在迁移期继续新增逻辑，它会重新变成新的中心实现。

### 9.3 UI 污染扩散风险

如果把 host 当前依赖的非四柱专属 capsule/settings 控件一并打包进四柱 package，会把新的 feature package 继续做成小型 `common`。

### 9.4 编辑器依赖过重风险

如果一开始就强行让 editor 完全脱离平台层，会显著增加第一阶段复杂度。应先容忍 editor 临时依赖模板平台能力。

---

## 10. 结论

第一阶段不是“把四柱 Card 从 common 中搬出去”，而是借四柱 Card 这条样板线建立一套以后所有共享能力都能复用的 package 化方法：

- core 独立
- ui 独立
- host 独立
- editor 独立
- `common` 仅做兼容门面

四柱拆通，后面的日期细节、流年、其他共享能力才有可复制路径。

# 命理架构重构与迁移落地计划 (Implementation Plans)

根据 `PRDs.md` 中的设计蓝图，我们将整个重构拆解为严密的实施阶段。以下是具体的执行步骤、注意事项、潜在风险以及未来展望。

---

## 一、 执行步骤与阶段划分 (Execution Phases)

### 阶段 1：数据库 Schema 定义与 Drift 迁移 (Database Schema & Drift)

这是地基工程，必须首先生效。

- **建表**: 建立 `t_divination_calendars`, `t_da_yun_records`, `t_tai_yuan_records` 三张带有版本快照特征的实体表。
- **瘦身**: 修改 `Seekers` 和 `TimingDivinations`，彻底移除 `info_list_json` (即原本的 `timingInfoListJson`)，添加核心版本指针字段 `current_calendar_uuid`。
- **编译生成**: 运行 `build_runner` 生成最新的 SQLite 类与 DAO 对象。
- **编写 Migration 脚手架**: 在 Drift 的 `onUpgrade` 回调中编写版本升级策略。

### 阶段 2：历史数据清洗与平滑升级 (Data MigrationScript)

旧系统用户的庞大数据必须平滑过渡，不能出现丢失。

- 拦截数据库 `SCHEMA_VERSION` 升级挂载点。
- 逐行扫描旧版本主表中的 `info_list_json` 字符串，利用现有的反序列化库，把它们解析在内存中。
- 将原本被挤压在一个 List 中的多个历法结果打散，对每一个结果生成一条独立的 `DivinationCalendar` 记录插入新表。
- 将列表中“被选中（Active）”的那个结果的 uuid，回填到主表的 `current_calendar_uuid` 中。
- 清理掉原始的 `info_list_json` 列数据，缩减数据库体积。

### 阶段 3：底层计算服务的解耦与重构 (Service Refactoring)

计算引擎的输入输出流向改变。

- 拦截所有的排盘调用点：不再是“算出一个巨大的包含 N 套历法的 JSON 并附加给 Seeker”。
- 变更为流式运算：针对标准时、真太阳时等分别并行运算，**直接在运算完成时将结果写入 `DivinationCalendars` 表**。
- 重构大运排盘引擎和胎元计算器 (`BirthdayCountbackCalculator` 等)，使它们的运算输入彻底从主表剥离，转而依赖单一的 `DivinationCalendar` 实体对象。
- 运算完成的大运、胎元直接作为子节点挂载入库（`calendar_uuid`）。

### 阶段 4：前端 UI 与交互流重塑 (UI / UX Refactoring)

由于架构变更，前端排盘界面的逻辑将发生质变。

- **极速切换**: 取代此前的“拉动 SegmentControl 触发实时重新计算导致卡顿”的现象；改为“直接拉取对应 UUID 的现成干支记录，纯视图属性重绘”。
- **强校正模式支持**: 在 UI 层新增“手工校正/盲派强排”界面入口。
- **异常退化链路 (Degrade UI)**: 在执行大运/流年计算时，如遇到无 `calculatedDatetime` （纯手工强推）的八字快照，弹窗强制要求占卜师“输入大运起运岁数及胎孕天数”，填补断层。
- **UI 指针下达**: 如果占卜师手动调整了胎元的 300天 至 280天，界面不仅向子表插入一条新胎元记录，更重要的是触发 `UPDATE Seekers SET current_tai_yuan_uuid = '新UUID'` 以立即切换当前显示态。

---

## 二、 核心注意事项 (Precautions)

1. **JSON 序列化向下兼容（防崩防腐）**
   虽然我们将大多数核心字段（如 `taiYuanGanZhi`）提平到了列里，但依然保留了 `extendPayloadJson` 或 `pillars_json` 来封存复杂数据。
   在写 Dart 模型层的 `.fromJson` 代码时，必须使用提供默认值、容错处理的强容灾写法，避免万一以后增删了属性导致 `TypeError` 解析崩溃。

2. **关系依赖与悬挂指针防范（Orphan Data Prevention）**
   既然拆分了 4 张表，就会面临悬空指针问题（例如一条大运快照找不到它所归属的生辰盘）：
   - 在主表（Seeker）被删除时，务必在 SQLite 层开启 `ON DELETE CASCADE`（级联删除），或者在业务仓库（Repository）中通过事务（Transaction）一并清理该 UUID 下所有的日历、大运、胎元记录。

3. **脏数据暴增陷阱与无感 GC（性能节流）**
   假如用户在 UI 界面狂点高频切换“真负太阳时”计算、狂切推算流派，后台是否就要一直生成快照并存入 SQLite？
   - **正确做法**：这种中间试探态应该只保留在内存（State）中，只有当用户**真正采纳、保存或点击“查看详细排盘”时**，才将其序列化落库；
   - 也可以增加定时或者异步的 GC 脚本，对“既不是 current_uuid，又超过半年未被浏览”的游离快照执行垃圾回收。

---

## 三、 潜在问题与风险规避 (Potential Issues & Risks)

1. **历史账本“坏账”的反序列化地雷（The Migration Bomb）**
   - **潜在问题**：部分旧版本用户由于之前的 Bug，其本地 `info_list_json` 是一坨非法、残缺的 JSON，这会直接导致 Migration 脚本崩溃，进而导致应用彻底“白屏”或打不开。
   - **规避手段**：将整个解析清洗过程套入最严密的 `try-catch` 。如果这一行的 JSON 解析出错，切不可中止整个表的升级；通过记录日志跳过深层解析，给这个受损的 Seeker 补办一张空壳/降级的 `DivinationCalendar` 记录，保证主线系统平滑迁移。

2. **强排孤岛导致的历法雪崩（Null DateTime Exception）**
   - **潜在问题**：基于《PRD》我们放宽了限制，充许纯手工推盘（`calculatedDatetime == null`）。但系统中极多上游工具（比如“真平太阳换算库”、“万年历扫盘库”）骨子里认定必传非空 `DateTime`。这在它们接收到 null 时必定抛出空指针异常。
   - **规避手段**：梳理所有调用 `DateTime` 及向万年历要截点的代码处，统一引入断言与防御式编程：提前向上层抛出清晰的业务异常（如 `RequireManualAgeException`）。绝不允许让底层历法库触发红底黄字的框架级 Error。

---

## 四、 未来可扩展的功能点 (Future Extensibility)

1. **精进至“刻分”的六柱预测（极高维度体系支撑）**
   这套关系架构为传说中的“六柱体系”铺平了道路。`DivinationCalendars` 提前预留了 `ke_gan_zhi`（刻干支）和 `fen_gan_zhi`（分干支）这两个列。当下系统可以不用它们，但未来如果接入极高精度的天文推步库，我们只需为这 2 列赋值，便能兵不血刃地上线“六柱流月流日同映”的超级排盘功能，丝毫不会破坏已有的大运挂载依赖。

2. **“查房式”的时间线版本比对体系 (Multi-track Divination & Review)**
   系统之所以坚持 “Append-Only（只追加不删除记录）”的快照哲学，就是为了这个宏大的功能：
   未来，可以为主算命师开发一个“历史推断重放视图”。以并排的分屏页面，同时刷出此人“未修正前的客观真太阳盘”和“加上了人为经验微调了15分钟的盘”，并在图表上对比两张盘在接下来的两年发生“大运交接”和“流年冲克”上的巨大时间分野。成为真正的命理推演沙盘。

3. **衍生流派的无极扩张 (如星宿、奇门遁甲、紫微斗数关联)**
   胎元（`TaiYuanRecords`）与大运（`DaYunRecords`）成功独立成表的模式将被复刻！
   如果后续想要在这个“生辰锚点”上加算**命宫、身宫、小限**，或是想要给这个八字叠加上一盘**奇门遁甲**、**紫微斗数十二宫**星盘，根本不需要在八字核心库上伤筋动骨。
   统一战法：直接建子表（`t_qimen_records` / `t_ziwei_records`），将外键直接勾在刚才那位兄弟（特定的 `calendar_uuid`）身上。
   这套**“以历法快照定桩、以子域独立延展”**的星系级架构图不仅消灭了一源多态的错误，更是一部足以容下命理学全集的数据航母蓝图。

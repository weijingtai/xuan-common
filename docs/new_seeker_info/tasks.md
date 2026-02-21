# 命理架构重构落地：原子化任务清单 (tasks.md)

这份清单将整个重构架构拆解为了原子化的具体任务，作为开发阶段的 Checklist。

---

## 阶段1：数据库底层骨架搭建（Schema & Drift）

### 1.1 核心表结构定义

- [ ] **创建 `DivinationCalendars` 表**: 包含 `source_uuid`, `timing_type`, `calculated_datetime`, `is_manual`, `manual_description`, `zi_strategy`, `jie_qi_type`, `year`, `month`, `day`, `time`, `ke`, `fen` 等干支列及其它占卜环境记录列。
- [ ] **创建 `DaYunRecords` 表**: 包含 `source_uuid`, `source_type`, `jie_qi_type`, `precision` 算法配置列，以及封存柱组结果的 `pillars_json` 列。
- [ ] **创建 `TaiYuanRecords` 表**: 包含 `calendar_uuid`, `strategy`, `actual_mature_days`, `total_mature_month`, 预计算出的 `tai_yuan_gan_zhi`，以及复杂对象的 `extend_payload_json`。

### 1.2 主表剥离瘦身

- [ ] 修改 `Seekers` 表：
  - [ ] 移除 `timingInfoListJson` (`info_list_json`) 庞大字段。
  - [ ] 添加 `current_calendar_uuid` 标记当前生辰快照外键。
  - [ ] 确保 `yearGanZhi` 等基础外显必保字段存留。
- [ ] 修改 `TimingDivinations` 表（临时占卜）：
  - [ ] 执行与 `Seekers` 相同的瘦身与添加 `current_calendar_uuid` 操作。

### 1.3 核心依赖与代码生成

- [ ] 运行 `flutter pub run build_runner build --delete-conflicting-outputs` 生成最新的 Drift Schema。

---

## 阶段2：旧有“坏账”平滑升级脚本（Migration）

必须确保线上用户的生辰数据能够无损升级拆解到多张表中。

- [ ] 拦截 Drift DB 中的 `onUpgrade` 至新版本的回调函数。
- [ ] 读取含有旧式 `info_list_json` 的所有 `Seekers` / `TimingDivinations`。
- [ ] 建立循环遍历脚本：
  - [ ] 使用 `try-catch` 包裹单条数据的 JSON 反序列化解析。
  - [ ] 如果解析失败，向日志暴露异常，并跳过或生成一条“占位空壳”记录。
  - [ ] 把解析出的 N 个 `DivinationDatetimeModel`，分别转换为 `DivinationCalendar` 的记录持久化插入 `t_divination_calendars` 中。
- [ ] 捕捉并设置每个用户的 `current_calendar_uuid`：将解包出来的这组记录中被“标记为 active / 真太阳时为准”的那一条对象的 UUID，回写给主表。
- [ ] (可选) 在一切迁移无误后，清理掉主表中旧有的 JSON 碎片（降低数据库本身体积）。

---

## 阶段3：计算引擎层的流式重构 (Engine Refactoring)

计算不再以组合装扮的方式挂在一个 JSON 数组里，而是变成产生快照实体对象的工厂流水线。

### 3.1 八字天文生辰引擎

- [ ] 拦截入口：修改原有生成 `info_list_json` 的代码段，不返回大泥巴数组。
- [ ] 执行天文排盘并在结束时直接按配置生成 `DivinationCalendar` 实体对象。

### 3.2 大运高阶计算引擎

- [ ] 重构 `DaYunCalculator`，将其入参从旧模型剥离，替换为只依赖一个纯粹的 `DivinationCalendar` 核心快照进行运算。
- [ ] 处理手工强排的空时间断点异常（降级处理），如果 `calculatedDatetime == null` 则必须抛出业务级别的 `RequireManualAgeException`，等待 UI 层的岁数赋归。
- [ ] 运算完成后直接封装生成独立的 `DaYunRecord` 实体。

### 3.3 胎元多维流派支持

- [ ] 修改 `BirthdayCountbackCalculator`，使其 `actualMatureDays` 从数据库记录里动态提取注入（280/300天模式）。
- [ ] 验证包含“胎日、胎时”的 `EightChars` 对象能完整被封装在 `extend_payload_json` 里正常反脱水。

---

## 阶段4：数据访问层抽象（Repository / Provider / Bloc）

- [ ] `DivinationCalendarRepository`
  - [ ] 增加 `insert`, `queryBySourceUuid` 等方法。
  - [ ] 增加 `switchCurrentCalendar(String sourceUuid, String newCalendarUuid)` 快速切换主指针事务。
- [ ] `DaYunRecordRepository`
  - [ ] 增加针对特定 `sourceUuid` 和算法维度组合查询。
- [ ] `TaiYuanRecordRepository`
  - [ ] 增加保存及根据 `calendar_uuid` 获取对应胎元版本的方法。
- [ ] 更新 `SeekerProvider/Bloc` 中相关排盘调用流向，使其响应数据库 UUID 指针的改变而不是本地 State JSON 数组的修改。

---

## 阶段5：UI 界面的破茧重生 (UI/UX Layer)

### 5.1 真排盘“快切”视图

- [ ] 用 `Dropdown` 或者 `SegmentControl` 展示当下可用的 `DivinationCalendars` 选项。
- [ ] 修改切换行为：点击选项不再呼叫大量 CPU 进行重复生辰计算，而是立即发送一个切换 `current_calendar_uuid` 指针的指令并重绘 UI。

### 5.2 盲派“纯干支手工强排”面板

- [ ] 新造一个特殊的“排盘录入页”。
- [ ] 去除输入精确年月日的日历组件，改为让卦师直接用“拨片/转轮”拨出四柱天干地支。
- [ ] UI 层必须弹出大运必须参数：“由于缺失天文公历时间，请手动指定大运起运岁数：[下拉列表 1~12]”。
- [ ] 生成 `DivinationCalendar` 且 `calculatedDatetime` 设定为 `null`，`isManual` = `true`。

### 5.3 数据溯源与历史标签验证

- [ ] 在八字排盘的最顶部增加一个轻盈の微小标签（Tag）。
- [ ] 判断当前选中的盘如果 `isManual == true`，强高亮显示“人工补正：XXX原因为午时...”。
- [ ] 显示大运算法组合：比如“当前大运：依据平气法且按分定节得出”。

### 5.4 胎元无极切换面板

- [ ] 在胎元模块增加一个 `Settings`（齿轮）图标用于切换 300 / 280 天流派。
- [ ] 若卦师点击生成新流派，平行推送记录至数据库后自动拉去最新流派刷新 UI，并在原记录中保留旧存根供回退。
- [ ] 以 `current_tai_yuan_uuid` 标记目前启用的版本。

---

## 阶段6：严格验收测试准则 (Acceptance Criteria)

本底座重构具有极强的数据破坏风险，**上线合版前必须 100% 通过以下验收节点**：

### 6.1 逆境跑批跑通 (Migration Resilience Test)

- [ ] **构造毒药数据**：往旧表的 `info_list_json` 塞入两段格式完全损坏的脏 JSON 以及一个含非法日期的 JSON 对象。
- [ ] **跑批验收**：触发热更升级后，App 未发生闪退，控制台打印出格式化 Error Log，**且其他正常数据的 Seeker 全部成功完成了关系表的子表拆解插入**。

### 6.2 零延迟 UI 性能验证 (Zero-lag UI Test)

- [ ] **操作**：在同一个人的排盘结果页，疯狂且连续地点击切换“平太阳时”、“真太阳时”、“标准时”选项卡 10 次。
- [ ] **验收**：面板切换必须顺滑，卡顿感（Frame Drop）消失。
- [ ] **数据审查**：打开 SQLite 数据库，检查 `t_divination_calendars` 中是否仅仅只有最初该人默认生成的记录，而**没有**因为狂点被乱塞了几十条临时垃圾快照。

### 6.3 盲推极寒测试 (Blind-Pillar Degrade Test)

- [ ] **操作**：新建排盘时不选时间，直接人工用天干地支填充满了“年月时日”创建八字。
- [ ] **大运拦截验收**：当请求渲染大运模块时，必须成功拦截并弹出**“缺失天文坐标，请手动赋予起运岁数”**的交互。赋年保存后，`t_da_yun_records` 被正确且独立地插入一行。
- [ ] **历法雪崩防御验收**：整个创建流程中，绝不允许控制台报出任何因为试图解析 `null` DateTime 而导致的崩溃红字。

### 6.4 胎元时间机器验收 (TaiYuan Time-Machine Test)

- [ ] **操作**：使用真太阳时对某人排盘。查看默认的（300天）胎元结果。
- [ ] **操作**：点击设置修改孕期时长为 280 天。
- [ ] **验收**：界面上胎日/胎月瞬间改变。此时查看数据库，`t_tai_yuan_records` 表中此人应有**两条**所属的平行胎元记录（而绝非覆盖修改）。主表的 `current_tai_yuan_uuid` 成功指向了新产生的那一条。

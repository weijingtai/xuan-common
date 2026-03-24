# 动态推演架构：大运与十年流年流月计算极速方案

## 背景与目标

在《命主（Seeker）大运与流年存储设计》中，我们定下了“仅存储首柱大运起算基点（`first_turn_time`）”的极简策略，并决定采用 Schema-Free Payload 来挂载多流派断语。

但在没有“高精度万年历数据库表”支撑的前提下，当用户在排盘界面点击某一步大运（如 2026-2035 这一柱 10 年）时，系统需要**在运行时（Runtime）凭空硬算出这 10 年的流年干支、以及包含的 120 个流月干支**，然后把这套“时空坐标骨架”分发给八字引擎和铁板引擎进行断事。

若逐年逐月调用天文历法库计算交节时刻，Flutter UI 将严重卡顿；若全量存库，则前功尽弃。
**因此，我们的核心方案是：只通过历法库计算首次元数据集（锚点），其余全部基于甲子六十花甲子的数道运算（五虎遁）极速推演。**

---

## 详细执行架构与步骤

### 第 1 步：大运与公历年份的坐标锚定

首先，我们从数据库/本地存储中，提取当前命主（Seeker）以及其某一项排盘配置（Setting）的数据。

```json
// 从 DivinationSetting 提取
"da_yun_info": {
    "first_turn_time": "1993-11-01T10:00:00Z", 
    "step_duration_years": 10 // 通常是 10
}
```

当用户点击 UI 上的**第 4 柱大运**时：

1. **起止年份锁定**：我们很容易算出这一柱管辖的公历区间。
   `startYear` = 1993（首年） + (4 - 1) * 10 = 2023。
   `endYear` = 2023 + 9 = 2032。
2. **大运干支锁定**：从八字的月柱顺/逆推 4 步即可得到当前大运干支（如 `戊申`）。我们将其存为 `currentDaYunPillar`。

这就拿到了宏观的基础上下文：`{大运: 戊申, 起始年: 2023, 结束年: 2032}`。

### 第 2 步：只算一次首年（2023）流年干支

为了避免重复调用重型的节气天文历法库（如 `tyme`/`sweph`），整个十年推演引擎的**原点**就定在首年（2023年）。

```dart
// [引擎底层调用] 只耗费 1 次天文历算性能
JiaZi startYearPillar = TymeLibrary.getYearPillar(2023); // 获得 癸卯
JiaZi currentYearPillar = startYearPillar; // 遍历指针初始化
```

### 第 3 步：内存树构建与五虎遁流月极速推导 (核心 O(N) 循环)

在 Flutter 主线程（或极轻量的 `compute` 中），根据 `currentYearPillar` 构建 10 年 120 个月的干支骨架：

```dart
List<YearViewModel> decadeTree = [];

// 遍历 10 次流年
for (int y = 2023; y <= 2032; y++) {
    
    // ----------------------------------------------------------------
    // 【关键】：五虎遁极速起月！
    // 歌诀：甲己之年丙作首，乙庚之岁戊为头。丙辛之岁寻庚上，丁壬壬寅顺水流。若问戊癸何方发，甲寅之上好追求。
    // 我们只需要把 currentYearPillar 的天干传入算法，瞬间得到当年 正月（寅月） 的天干。
    // ----------------------------------------------------------------
    TianGan firstMonthStem = WuHuDun.getStartMonthStem(currentYearPillar.stem);
    
    // 正月地支永远是寅，所以流年正月的基础干支就是：
    JiaZi currentMonthPillar = JiaZi(stem: firstMonthStem, branch: DiZhi.yin);
    
    List<MonthViewModel> monthsInYear = [];
    
    // 遍历 12 次流月
    for (int m = 1; m <= 12; m++) {
        monthsInYear.add(MonthViewModel(
            monthIndex: m, // 第 1 到 12 个命理月
            monthPillar: currentMonthPillar,
            // (注：由于此时未耗费天文学性能算公历起止日，这里暂不填精确的交节日历时间，留给 UI 展开月历时再异步计算展开)
        ));
        
        // 极速步进：利用甲子环形加法（(天干索引+1)%10, (地支索引+1)%12）
        currentMonthPillar = currentMonthPillar.next(); 
    }
    
    decadeTree.add(YearViewModel(
        year: y,
        yearPillar: currentYearPillar,
        months: monthsInYear,
    ));
    
    // 流年干支步进
    currentYearPillar = currentYearPillar.next();
}
```

**性能优势**：整个 10 循环 + 12 循环（共执行 120 次 `JiaZi.next()`），纯内存运算耗时不超过 `0.1 毫秒`。

### 第 4 步：携带大运与 10 年干支骨架，下发给各大流派插件推断

现在，我们拥有一棵以 `YearViewModel` 为节点，子节点是 `MonthViewModel` 的完美十年时间骨架（此时里面干干净净，只有 `JiaZi` 数据）。
接着，采用我们之前讨论的**插件化批处理分发策略（推模式）**：

```dart
// 1. 将上面构建好的骨干十年树，派发给各大引擎插件
await Future.wait([
   // 八字引擎根据命主底盘（十神神煞等基础），在这个 10 年树里挂载流年、流月的吉凶与神煞标签
   BaziEngine.batchCalculateAndFill(seekerProfile, currentDaYunPillar, decadeTree),
   
   // 铁板神数引擎根据命主底盘的卦象密码，在这个 10 年树里挂载对应的条文数组（如 "1204: 云开见月明"）
   TiebanEngine.batchCalculateAndFill(seekerProfile, currentDaYunPillar, decadeTree),
]);

// ... 还可以继续接入诸如紫微斗数引擎等
```

### 第 5 步：驱动前端虚拟化 UI 渲染

当所有的插件引擎都在 `decadeTree` 上挂载完了自己解析出的 EAV Payload 之后：

1. **缓存更新**：引擎将这算好的批量 Payload （或部分运算量极大的流派 Payload，如铁板）异步序列化存入数据库 `YearlyPrediction` 表。下次这 10 年的数据就可直接 DB `SELECT` 捞出并结合数学推演极速组装。
2. **状态机通知**：调用 `setState` 或把 `decadeTree` 丢进 Provider/Riverpod/Bloc。
3. **UI 列表渲染**：`DaYunLiuNianTableWidget` 现已完全重构为基于 `TreeView`、`ListView.builder` 收缩展开面板式的列表架构。首屏只瞬间渲染 10 个年份的卡片。
4. **月历按需二次推演（渐进增强）**：如果用户点开了“2023 癸卯年”，由于界面展示 12 个月的空间变大，我们这时可以在 UI `build` 内或后台开启一个小任务，**仅针对这指定的 12 个月**去调用 `tyme` 精确算出公历交节时刻（“3月5日惊蛰”，“4月4日清明”）填充到 UI 里供用户查看。

---

## 终局总结与收益

本执行方案达成了一个近乎完美的优雅漏斗：

* **存储极致节约**：底层仅存起步时间点；
* **天文计算极致节约**：仅查一次**流年首年**干支起点（后续全凭算式环形递进），仅在**用户点开具体某一年时**计算更精细的月份交节时刻表；
* **跨流派大包容的极致解耦**：利用生成的一棵完全客观、纯由“年份干支、月份干支”构成的干支坐标树，像公交车一样把所有流派拉在一条时间轴上，他们各自计算完把结果放入这个格子的空篮子里，UI 最后像开盲盒一样把它们渲染出来。

你的项目将由一个硬编码排盘工具，升格为一个“能扛得住无限扩充插件、毫秒级响应一切时间长河数据”的**现代命理流年结算云平台**！

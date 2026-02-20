# 玄 · Common 模块

> 玄学数术应用的共用基础模块 —— 集天文历法、排盘推演、AI 辅助于一体的 Flutter 核心包

[English](README_en.md) · [开发指引](CLAUDE.md)

---

## ✨ 概述

`common` 是玄学数术应用的共享 Flutter 模块，为奇门遁甲、七政四余、太乙神数、大六壬四大术数子模块提供统一的基础设施。涵盖数据库层、天文历法计算、UI 组件库、AI 集成、以及布局编辑系统。

## 🏗️ 架构总览

```
lib/
├── database/           数据库 (Drift ORM, 双库架构)
├── domain/             领域层 (用例、AI、GUI 抽象)
├── features/           业务功能模块 (四柱、大运、流运、胎元)
├── models/             领域模型
├── enums/              玄学枚举 (天干、地支、五行、甲子、十神等)
├── commands/           命令模式 (编辑器 undo/redo)
├── services/           服务层 (AI 服务、模板配置)
├── repositories/       数据仓库
├── viewmodels/         视图模型 (MVVM)
├── widgets/            UI 组件库
├── themes/             主题与配色
├── painter/            自定义画板 (环形图、刻度盘)
├── helpers/            历法计算工具
├── adapters/           第三方适配器
└── ...
```

## 🔮 核心能力

### 🗃️ 双数据库架构

- **AppDatabase** — 排盘、求测者、面板、技能等核心业务数据
- **WorldInfoDatabase** — 全球地理信息（地区、国家、省市）
- 基于 **Drift ORM**，支持 iOS / Android / Web 跨平台
- UUID 主键 · 软删除 · 审计字段

### 🌟 业务功能模块

| 模块 | 说明 |
|------|------|
| `features/four_zhu/` | 四柱八字核心 |
| `features/da_yun/` | 大运推演 |
| `features/liu_yun/` | 流年流月 |
| `features/tai_yuan/` | 胎元计算 |
| `features/four_zhu_card/` | 四柱卡片 UI (39 文件) |
| `features/datetime_details/` | 日期时间详情 |

### 🤖 AI 集成

- AI Persona 与 Context 管理
- Agent Tools 工具注册
- 会话审计日志与事件系统

### 🎨 布局编辑系统

- 可视化模板编辑器，支持 **拖拽排序**
- Command 模式实现完整的 **撤销/重做** 操作
- 样式编辑器（15 组件）· 颜色选择器 · 主题切换

### 🔭 天文历法

- **Swiss Ephemeris** (sweph) — 精密天文计算
- **Tyme** — 中国农历与干支历法
- 太阳时计算 · 真太阳时换算
- 二十四节气 · 七十二候

## 📦 主要依赖

| 类别 | 依赖 | 版本 |
|------|------|------|
| 数据库 | drift + drift_flutter | ^2.30.1 / ^0.2.8 |
| 持久化 | persistence_core | git (xuan-storage) |
| 天文 | sweph | ^3.2.1+2.10.3 |
| 历法 | tyme | ^1.4.1 |
| 地图 | flutter_map + geolocator | ^8.2.2 / ^14.0.2 |
| 状态 | provider | ^6.1.5+1 |
| 网络 | dio | ^5.9.1 |
| 序列化 | json_serializable + protobuf | ^6.12.0 / ^6.0.0 |
| 字体 | google_fonts | ^8.0.0 |
| 屏幕适配 | flutter_screenutil | ^5.9.3 |

## 🚀 快速开始

```bash
# 安装依赖
flutter pub get

# 代码生成（修改数据库表、DAO、JSON 模型后必须运行）
dart run build_runner build --delete-conflicting-outputs

# 运行测试
flutter test

# 代码分析
flutter analyze
```

## 📁 资源文件

```
assets/
├── colors/
│   ├── zhongguose.pb          # 中国色色板 (protobuf)
│   └── forbidden_city.pb      # 故宫色色板 (protobuf)
└── templates/
    └── chinese/               # 中式布局模板

../assets/
├── dataset/                   # 数据集
│   └── geo/                   # 地理数据 (JSON / GeoJSON / protobuf)
└── sql/                       # SQL 脚本
```

## 📐 开发规范

- 遵循 `flutter_lints`，提交前执行 `dart format .`
- 文件命名 `snake_case.dart`，类/Widget 命名 `UpperCamelCase`
- 优先使用 `const` 构造函数
- 测试文件放在 `test/` 下，与 `lib/` 结构镜像

## 📄 许可证

本项目为私有项目。

# Xuan · Common Module

> The shared foundation module for Chinese metaphysics divination — a Flutter core package integrating astronomical calculations, divination engines, and AI assistance

[中文](README.md) · [Developer Guide](CLAUDE.md)

---

## ✨ Overview

`common` is the shared Flutter module for the Xuan (玄学) divination application, providing unified infrastructure for four major divination systems: Qi Men Dun Jia (奇门遁甲), Qi Zheng Si Yu (七政四余), Tai Yi Shen Shu (太乙神数), and Da Liu Ren (大六壬). It encompasses the database layer, astronomical/calendar calculations, UI component library, AI integration, and layout editing system.

## 🏗️ Architecture Overview

```
lib/
├── database/           Database (Drift ORM, dual-database architecture)
├── domain/             Domain layer (use cases, AI, GUI abstractions)
├── features/           Feature modules (Four Pillars, DaYun, LiuYun, TaiYuan)
├── models/             Domain models
├── enums/              Metaphysics enums (TianGan, DiZhi, FiveXing, JiaZi, TenGods, etc.)
├── commands/           Command pattern (editor undo/redo)
├── services/           Service layer (AI service, template config)
├── repositories/       Data repositories
├── viewmodels/         ViewModels (MVVM)
├── widgets/            UI component library
├── themes/             Themes & color strategies
├── painter/            Custom painters (ring charts, scale dials)
├── helpers/            Calendar calculation utilities
├── adapters/           Third-party adapters
└── ...
```

## 🔮 Core Capabilities

### 🗃️ Dual Database Architecture

- **AppDatabase** — Core business data: divinations, seekers, panels, skills
- **WorldInfoDatabase** — Global geographic information (regions, countries, states, cities)
- Built on **Drift ORM** with cross-platform support (iOS / Android / Web)
- UUID primary keys · Soft deletes · Audit fields

### 🌟 Feature Modules

| Module | Description |
|--------|-------------|
| `features/four_zhu/` | Four Pillars (BaZi) core |
| `features/da_yun/` | Great Luck (大运) calculations |
| `features/liu_yun/` | Yearly & monthly luck flows |
| `features/tai_yuan/` | Tai Yuan (胎元) calculations |
| `features/four_zhu_card/` | Four Pillars card UI (39 files) |
| `features/datetime_details/` | DateTime detail views |

### 🤖 AI Integration

- AI Persona & Context management
- Agent Tools registry
- Session audit logging & event system

### 🎨 Layout Editing System

- Visual template editor with **drag-and-drop** reordering
- Full **undo/redo** via Command pattern
- Style editor (15 components) · Color picker · Theme switching

### 🔭 Astronomical Calculations

- **Swiss Ephemeris** (sweph) — Precision astronomical calculations
- **Tyme** — Chinese lunar calendar & Stem-Branch (GanZhi) system
- Solar time calculation · True solar time conversion
- 24 Solar Terms · 72 Pentads (七十二候)

## 📦 Key Dependencies

| Category | Dependency | Version |
|----------|-----------|---------|
| Database | drift + drift_flutter | ^2.30.1 / ^0.2.8 |
| Persistence | persistence_core | git (xuan-storage) |
| Astronomy | sweph | ^3.2.1+2.10.3 |
| Calendar | tyme | ^1.4.1 |
| Maps | flutter_map + geolocator | ^8.2.2 / ^14.0.2 |
| State | provider | ^6.1.5+1 |
| Network | dio | ^5.9.1 |
| Serialization | json_serializable + protobuf | ^6.12.0 / ^6.0.0 |
| Fonts | google_fonts | ^8.0.0 |
| Screen Adapt | flutter_screenutil | ^5.9.3 |

## 🚀 Quick Start

```bash
# Install dependencies
flutter pub get

# Code generation (required after modifying DB tables, DAOs, or JSON models)
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Static analysis
flutter analyze
```

## 📁 Assets

```
assets/
├── colors/
│   ├── zhongguose.pb          # Traditional Chinese colors (protobuf)
│   └── forbidden_city.pb      # Forbidden City palette (protobuf)
└── templates/
    └── chinese/               # Chinese-style layout templates

../assets/
├── dataset/                   # Datasets
│   └── geo/                   # Geographic data (JSON / GeoJSON / protobuf)
└── sql/                       # SQL scripts
```

## 📐 Development Conventions

- Follow `flutter_lints`; run `dart format .` before committing
- File names: `snake_case.dart`; classes/widgets: `UpperCamelCase`
- Prefer `const` constructors whenever possible
- Test files in `test/`, mirroring `lib/` structure

## 📄 License

This is a private project.

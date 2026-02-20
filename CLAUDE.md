# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Module Overview

The `common` module is a shared Flutter package that provides core functionality for the xuan (玄学) divination application. It contains database models, UI widgets, astronomical calculations, location services, AI integration, layout/template editors, and shared utilities used across all divination modules (qimendunjia, qizhengsiyu, taiyishenshu, daliuren).

### Key Subsystems

- **Divination Engine**: Four Pillars (四柱), DaYun (大运), LiuYun (流运), TaiYuan (胎元) feature modules
- **Layout/Template System**: Drag-and-drop card layout editor with undo/redo command support
- **AI Integration**: AI personas, context management, agent tools, and audit logging
- **Astronomical Calculations**: Swiss Ephemeris (sweph) and Chinese calendar (tyme) integration

## Architecture

### Database Layer (Drift ORM)

- **Two separate databases**:
  - `AppDatabase` (`lib/database/app_database.dart`): Core app data including divinations, seekers, panels, skills
  - `WorldInfoDatabase` (`lib/database/world_info_database.dart`): Geographic data (regions, countries, states, cities)
- **DAO Pattern**: Each table has a dedicated DAO in `lib/database/daos/` for query operations
- **Type Converters**: Custom converters in `lib/database/converters/` handle complex types (Location, DivinationDateTime, GanZhi, JieQiInfo, Coordinates)
- **Platform Support**: Separate connection implementations for native (`native.dart`), web (`web.dart`), and unsupported platforms (`unsupported.dart`)

### Data Models

- **Divination Models** (`lib/datamodel/`): Core business objects for divination requests, types, seekers, observers
- **Domain Models** (`lib/models/`): Rich domain models including pillar data, layout templates, ShenSha, text style configs, year/month models, etc.
- **Enums** (`lib/enums/`): Extensive Chinese metaphysics enums (TianGan, DiZhi, FiveXing, JiaZi, TenGods, NineStar, HouTianGua, TwelveZhangSheng, LayoutTemplate enums, etc.)
- **JSON Serialization**: Models use `@JsonSerializable()` annotations with `.g.dart` companions

### Domain Layer (`lib/domain/`)

- **Use Cases** (`domain/usecases/`): Business logic use cases
- **AI Domain** (`domain/ai/`): AI persona, context, agent tools, audit logs, chat events, session summaries
- **GUI Domain** (`domain/gui/`): GUI-specific domain abstractions

### Feature Modules (`lib/features/`)

Feature-based organization for major business domains:

- `da_yun/` — 大运 (Great Luck) feature
- `liu_yun/` — 流运 (Year/Month Luck) feature
- `four_zhu/` — 四柱 (Four Pillars) core feature
- `four_zhu_card/` — Four Pillars card UI components
- `four_zhu_card_style_editor/` — Card style editor
- `tai_yuan/` — 胎元 (Tai Yuan) feature
- `datetime_details/` — DateTime detail views
- `shared_card_template/` — Shared card template components

### Services & Repositories

- **Services** (`lib/services/`): AI service, AI registry, AI audit service, card template settings overlay
- **Repositories** (`lib/repositories/`): Repository pattern implementations (eight_chars_info, layout_template)
- **ViewModels** (`lib/viewmodels/`): MVVM ViewModels (bazi_card, four_zhu_editor, four_zhu_card_demo, timezone_location, etc.)

### Commands (`lib/commands/`)

Command pattern with undo/redo support for editor operations:

- `editor_command.dart` — Base editor command
- `template_commands.dart` — Layout template manipulation commands
- `theme_commands.dart` — Theme editing commands

### UI Components (`lib/widgets/`)

- **Eight Characters (BaZi) Widgets**: `eight_chars_card.dart`, `four_zhu_eight_chars_card.dart`, `pillar_card.dart`, `generic_pillar_card.dart`, `vertical_pillar_card.dart`
- **Editable Four Zhu Card** (`editable_fourzhu_card/`): 10-file component suite for interactive four pillars editing
- **Style Editor** (`style_editor/`): 15-file component suite for visual style editing
- **Input Components**: `city_picker_bottom_sheet.dart`, `divination_datetime_selection_card.dart`, `gan_zhi_picker_alert_dialog.dart`, `query_time_input_card.dart`
- **Editor Components**: `editor_sidebar_v2.dart`, `editor_top_bar.dart`, `row_style_editor_form.dart`, `layout_editor_sidebar.dart`
- **Display Widgets**: `lunar_date_info_card.dart`, `twenty_four_jie_qi_tag.dart`, `yao_widget.dart`, `gold_text.dart`, `season_24_tag.dart`
- **Map**: `flutter_map_screen.dart` for geolocation display

### Additional Layers

- **Adapters** (`lib/adapters/`): External library adapters (e.g., `lunar_adapter.dart`)
- **Helpers** (`lib/helpers/`): Calendar/time calculation helpers (`solar_lunar_datetime_helper.dart`, `solar_time_calculator.dart`)
- **Painters** (`lib/painter/`): Custom painters for circular charts (circle_ring, ring_scale, text_circle_ring, divided_circle, etc.)
- **Themes** (`lib/themes/`): App themes, color strategies, editable card themes with JSON serialization
- **Pages** (`lib/pages/`): Full-page screens (four_zhu_edit_page, layout_editor_page, editable card demo, etc.)
- **Shared** (`lib/shared/`): Cross-feature shared utilities and components

## Common Commands

### Code Generation

```bash
# Regenerate Drift database code and JSON serialization
dart run build_runner build --delete-conflicting-outputs

# Watch mode for development
dart run build_runner watch --delete-conflicting-outputs
```

**Always run after modifying:**

- Drift table definitions in `lib/database/tables/tables.dart`
- DAO classes in `lib/database/daos/`
- Models with `@JsonSerializable()` annotations
- Type converters

### Development

```bash
# Install dependencies (run from common/ directory)
flutter pub get

# Run tests
flutter test

# Analyze code
flutter analyze
```

## Key Dependencies

### Core

- **drift** (^2.30.1) + **drift_flutter** (^0.2.8): Database ORM with cross-platform support
- **persistence_core** (git: xuan-storage): Persistence abstraction core layer
- **provider** (^6.1.5+1): State management
- **json_serializable** (^6.12.0) + **json_annotation** (^4.10.0): JSON serialization code generation
- **equatable** (^2.0.8): Value object comparison

### Astronomical & Calendar

- **sweph** (^3.2.1+2.10.3): Swiss Ephemeris for astronomical calculations
- **tyme** (^1.4.1): Chinese lunar calendar library
- **timezone** (^0.11.0) + **flutter_timezone** (^5.0.1): Timezone handling

### Maps & Location

- **flutter_map** (^8.2.2) + **flutter_map_cancellable_tile_provider** (^3.1.1): Map display
- **geolocator** (^14.0.2): Location services
- **lat_lng_to_timezone** (^0.2.0): Coordinate to timezone conversion

### UI

- **google_fonts** (^8.0.0): Font management
- **flutter_screenutil** (^5.9.3): Screen adaptation
- **flex_color_picker** (^3.7.2): Color picker
- **auto_size_text** (^3.0.0): Auto-sizing text
- **drag_and_drop_lists** (^0.4.2): Drag-and-drop reordering
- **board_datetime_picker** (2.8.5): DateTime picker
- **dotted_border** (^3.1.0): Dotted border decoration

### Networking & Data

- **dio** (^5.9.1): HTTP client
- **protobuf** (^6.0.0): Protocol Buffers support
- **shared_preferences** (^2.5.4): Local key-value storage
- **uuid** (4.5.2): UUID generation

## Development Notes

### Database Schema

- Primary keys use UUID strings (not auto-increment) for most tables
- Soft deletes via `deletedAt` column (nullable DateTime)
- Standard audit fields: `createdAt`, `lastUpdatedAt`, `deletedAt`
- Many-to-many relationships via mapper tables (e.g., `SeekerDivinationMappers`, `DivinationPanelMappers`)

### File Organization

```
lib/
├── adapters/           # External library adapters (e.g. lunar_adapter)
├── commands/           # Command pattern: editor, template, theme commands (undo/redo)
├── database/           # Drift database, tables, DAOs, converters
├── datamodel/          # Business data models (JSON serializable)
├── datasource/         # Data sources (local, binary protobuf for geo data)
├── divinatioin_history_record/  # Divination history record page
├── domain/
│   ├── ai/             # AI domain models (persona, context, agent tools, audit)
│   ├── gui/            # GUI domain abstractions
│   └── usecases/       # Business logic use cases
├── enums/              # Chinese metaphysics enumerations
├── features/           # Feature modules (da_yun, liu_yun, four_zhu, tai_yuan, etc.)
├── helpers/            # Calendar/time helpers (solar/lunar datetime, solar time calc)
├── log/                # Logging infrastructure (xuan_logger)
├── models/             # Domain models (pillar, layout_template, shen_sha, text_style, etc.)
├── pages/              # Full-page screens
├── painter/            # Custom painters (circle rings, scales, text painters)
├── palette/            # Color palette definitions
├── repositories/       # Repository pattern implementations
├── services/           # Services layer (AI, card template overlay)
├── shared/             # Cross-feature shared components
├── themes/             # App themes, color strategies, card themes
├── utils/              # Utility functions
├── viewmodels/         # MVVM ViewModels
└── widgets/            # Reusable UI components
```

### Assets

- Parent directory assets: `../assets/dataset/`, `../assets/dataset/geo/`, `../assets/sql/`
- Color palettes: `assets/colors/zhongguose.pb`, `assets/colors/forbidden_city.pb` (Protocol Buffer format)
- Layout templates: `assets/templates/`, `assets/templates/chinese/`
- Fonts: NotoSansSC-Regular for Chinese text support

### Platform-Specific Database Connections

- Native platforms (iOS/Android): Use `drift_flutter` with `getApplicationSupportDirectory`
- Web: Uses WASM SQLite with `sqlite3.wasm` and `drift_worker.js`
- Query executor selection happens in `connection.dart` with platform-specific imports

## Common Patterns

### Creating a New DAO

1. Define table in `lib/database/tables/tables.dart`
2. Create DAO class in `lib/database/daos/` extending `DatabaseAccessor<AppDatabase>`
3. Add table to `@DriftDatabase` tables list in `app_database.dart`
4. Add DAO to `daos` list in `app_database.dart`
5. Run `dart run build_runner build --delete-conflicting-outputs`

### Adding a New Enum

1. Create enum file in `lib/enums/enum_*.dart`
2. Define enum with Chinese and English descriptions as needed
3. Add to `lib/enums.dart` barrel export
4. If used in database, create a text converter or use `textEnum<T>()`

### Creating JSON-Serializable Models

1. Add `@JsonSerializable()` annotation to class
2. Include `part 'filename.g.dart';` directive
3. Define `fromJson` and `toJson` factory methods
4. Run code generation to create `.g.dart` companion

### Command Pattern (Editor Commands)

1. Create command class in `lib/commands/` extending base editor command
2. Implement `execute()` and `undo()` methods
3. Register command through the editor ViewModel
4. Commands support undo/redo stack for template and theme operations

### Feature Module Pattern

1. Create feature directory in `lib/features/<feature_name>/`
2. Organize internally with models, widgets, and logic specific to the feature
3. Expose public API through barrel exports
4. Share common components via `lib/features/shared_card_template/`

### Repository Pattern

1. Define abstract repository interface in `lib/repositories/`
2. Create implementation class with `_impl` suffix
3. Inject via Provider for testability
4. Handles data access logic for eight_chars_info and layout_template

# 阶段性成果总结

- `xuan-four-zhu-card` 本地化了 style/theme、枚举、row/column 模型与 render bridge，first commit 4f08bad。
- `xuan-four-zhu-templates` 已独立并被 `common` 通过 re-export 依赖，新包经过 `flutter pub get` 与 `dart analyze`。
- `xuan-four-zhu-host` 初具 resolver/contracts，新增 runtime/editor contracts，并继续补齐 runtime overrides、bootstrap helper、template->card mapper（`b3d7d21`、`a94b666`）。
- `xuan-four-zhu-editor` 已建立独立 bridge package，先承接 editor 公开入口与最小 compat 导出（`d8780bd`）。
- `xuan-four-zhu-editor` 已进一步整理为 `pages / viewmodels / widgets` 分层公开入口，并补充 editor entrypoints contract（`cc4f84f`）。
- `xuan-four-zhu-editor` 已将 `FourZhuEditPage`、editor workspace 升级为本地 facade widget，并把 `FourZhuEditorViewModel` 收敛为精简公共导出（`7e932aa`）。
- `xuan-four-zhu-editor` 已新增 `EditorSidebar` 本地 facade 入口，并接入 editor barrel export / entrypoints contract（`643a115`）。
- `xuan-template-marketplace` 已建立独立 marketplace core package，先承接 marketplace metadata / gateway / install contracts，不引入具体 Four Zhu 逻辑（`0b39fbb`）。
- `xuan-common` 依赖统一收拢：resolver 由新 host facade 代理，新增 runtime/editor adapter (`7a0b59b`、`d254815`)，并引入 host/card packages (`20b6f45`)。
- `xuan-common` 的 `FourZhuCardHost` 现在通过 `CommonFourZhuHostRuntime` 和 `CommonFourZhuHostEditorLauncher` 驱动 runtime/editor 行为，确保 host 壳只暴露 facade 级契约。
- `xuan-common` 的 `FourZhuCardHost` 已经切换为 `xuan-four-zhu-card` 的 `EditableFourZhuCardV3` render，并收紧 notifier/render adapter 桥接（`5261224`、`d0cda9c`）。
- `xuan-common` 的 `FourZhuCardHost` 已去掉对 shared capsule/settings 组件的直接 import，改成宿主本地 UI 构件和本地 adapter（`60492f8`）。
- `xuan-common` 的 `four_zhu_add_palette` 入口已切到 `xuan-four-zhu-card` facade；`EditableFourZhuCardV4` 仅保留为未完成实验文件，并明确禁止接入任何运行路径（`ce17e87`）。
- `xuan-common` 里 `cell_style_config.dart`、`pillar_style_config.dart` 已切到 `xuan-four-zhu-card` facade，继续缩小旧 style model 真实现残留（`33ee5ea`）。
- `xuan-common` 里 `four_zhu_card.dart`、`theme_color_mode.dart` 已切到 `xuan-four-zhu-card` facade，进一步收敛旧 theme/export 真实现（`3a4a600`）。
- `xuan-four-zhu-card` 已本地化 `style_resolver.dart` 与 `gan_zhi_gua_colors.dart`，主渲染实现不再直接依赖 `common/utils/style_resolver.dart`（`55d1e9b`）。
- 目前各 repo `dart analyze` 通过，`xuan-qizhengsiyu` 保持用户接受的未提交状态（`beauty_view_page.dart` 未动）。

## 当前未完成项

- `xuan-four-zhu-editor` 已有独立 package，但 `FourZhuEditPage`、`FourZhuEditorViewModel` 和 editor workspace 仍主要以 bridge/compat 形式留在 `xuan-common`。
- `FourZhuCardHost` widget 壳本身还没有迁出 `xuan-common`，当前只是 resolver/runtime/editor/render 依赖已经被分层。
- `common` 侧旧 render 导出兼容入口还没有系统化标注完成状态，仍需继续压薄。
- `host` 中非四柱专属的 capsule/settings UI 直连依赖已经移除，但本地 adapter 仍在复用旧组件，需要后续决定是继续保留还是彻底替换。
- `LayoutTemplate Marketplace` 已有 core package scaffold，但具体 Four Zhu 模板市场实现与迁移还未开始。
- `qizhengsiyu` 还没有改成直接面向 `xuan-four-zhu-host` / `xuan-four-zhu-card` 依赖，当前更多是通过 `xuan-common` 的兼容宿主接入。

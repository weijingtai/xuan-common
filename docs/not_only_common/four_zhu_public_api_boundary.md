# Four Zhu Package Boundary

Current migration stage:

- `xuan_four_zhu_card` root exports the Four Zhu style/theme subset only.
- `xuan_four_zhu_card/four_zhu_card_models.dart` and `four_zhu_card_domain.dart` expose the mechanically migrated model closure.
- the main render widget entry is now local to `xuan_four_zhu_card`; render/widget bridge APIs are intentionally kept off the root package export.
- `FourZhuAddPalette` is now package-local and no longer a bridge widget.
- it now uses local drag payload/enums types and only keeps the remaining allowed bridges elsewhere in the render tree.
- `xuan-common` still hosts the canonical `style_resolver` bridge for now.
- the render directory tree has been mechanically localized, but `style_resolver` remains bridged.
- `TextStyleConfig` and other Four Zhu typography models are now package-local.
- a dedicated `four_zhu_card_domain` subpath now owns the safe domain models and layout utilities.
- `style_resolver.dart` remains bridged because it would pull `layout_template.dart` into this cut.
- host/editor are explicitly out of scope for this step.

Stability rule:

- root package imports should not assume `EditableFourZhuCardTheme` or `TextStyleConfig` from `common`.
- style/theme consumers should import `package:xuan_four_zhu_card/xuan_four_zhu_card.dart` or `package:xuan_four_zhu_card/four_zhu_card_styles.dart`.
- domain consumers should import `package:xuan_four_zhu_card/four_zhu_card_domain.dart`.
- render bridge consumers should use explicit subpath bridge APIs only.
- palette consumers should import `package:xuan_four_zhu_card/widgets/four_zhu_add_palette.dart`.
- callers should now import the local editable card entry, but should still assume `style_resolver` is external.

Next cut:

- decouple the render bridge from `common` only if it can be done without pulling host/editor into the same cut.

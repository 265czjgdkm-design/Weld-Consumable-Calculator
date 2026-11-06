import '../../data/base_material_catalog.dart';
import '../../l10n/strings.dart';

/// Localized heading for a [CatalogBaseMaterial.group] in the pickers.
/// Standard codes (EN 10025, ASTM A335, ...) inside the headings are
/// language-neutral; only the descriptive words are translated.
String baseMaterialGroupLabel(L10nStrings strings, String group) =>
    switch (group) {
      'EN 10025 structural steel' => strings.baseGroupEn10025,
      'EN 10028 / 10216 pressure steel' => strings.baseGroupPressure,
      'ASTM carbon steel' => strings.baseGroupAstmCarbon,
      'ASTM chrome-moly (A335 / A387)' => strings.baseGroupAstmCrMo,
      'API 5L line pipe' => strings.baseGroupApi,
      'Stainless steel' => strings.baseGroupStainless,
      'Aluminium' => strings.baseGroupAluminium,
      _ => group,
    };

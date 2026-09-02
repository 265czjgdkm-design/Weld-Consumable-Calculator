import '../l10n/strings.dart';
import 'custom_material_models.dart';
import 'weld_models.dart';

/// Union of the two things the Filler dropdown can resolve to: a built-in
/// AWS classification, or a snapshot of a user's custom filler material
/// from [CustomFillerMaterialStore]. A snapshot rather than a live
/// reference -- once saved into a calculation, later edits/deletes to the
/// library entry must not change the saved calculation (see coder task
/// decision #2).
sealed class ConsumableSelection {
  const ConsumableSelection();

  factory ConsumableSelection.fromJson(Map<String, dynamic> json) {
    if (json['consumableSelectionType'] == 'custom') {
      return CustomConsumableSelection(
        CustomFillerMaterial.fromJson(
          json['customFillerMaterial'] as Map<String, dynamic>,
        ),
      );
    }
    return BuiltInConsumableSelection(
      ConsumablePreset.values.byName(json['consumablePreset'] as String),
    );
  }

  Map<String, dynamic> toJson();
}

class BuiltInConsumableSelection extends ConsumableSelection {
  const BuiltInConsumableSelection(this.preset);

  final ConsumablePreset preset;

  @override
  Map<String, dynamic> toJson() => {
    'consumableSelectionType': 'builtin',
    'consumablePreset': preset.name,
  };

  @override
  bool operator ==(Object other) =>
      other is BuiltInConsumableSelection && other.preset == preset;

  @override
  int get hashCode => preset.hashCode;
}

class CustomConsumableSelection extends ConsumableSelection {
  const CustomConsumableSelection(this.material);

  final CustomFillerMaterial material;

  @override
  Map<String, dynamic> toJson() => {
    'consumableSelectionType': 'custom',
    'customFillerMaterial': material.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      other is CustomConsumableSelection &&
      other.material.id == material.id &&
      other.material.updatedAtEpochMs == material.updatedAtEpochMs;

  @override
  int get hashCode => Object.hash(material.id, material.updatedAtEpochMs);
}

extension ConsumableSelectionX on ConsumableSelection {
  String get label => switch (this) {
    BuiltInConsumableSelection(:final preset) => preset.label,
    CustomConsumableSelection(:final material) => material.name,
  };

  ConsumableFamily get family => switch (this) {
    BuiltInConsumableSelection(:final preset) => preset.family,
    CustomConsumableSelection(:final material) => material.family,
  };

  /// Null for custom materials that were saved without an AWS spec.
  String? get awsSpecification => switch (this) {
    BuiltInConsumableSelection(:final preset) => preset.awsSpecification,
    CustomConsumableSelection(:final material) => material.awsSpecification,
  };

  String awsDisplayLabelFor(L10nStrings strings) => switch (this) {
    BuiltInConsumableSelection(:final preset) => preset.awsDisplayLabelFor(
      strings,
    ),
    CustomConsumableSelection() =>
      awsSpecification == null
          ? '$label (${family.labelFor(strings)})'
          : '$awsSpecification $label (${family.labelFor(strings)})',
  };

  double get densityGPerCm3 => switch (this) {
    BuiltInConsumableSelection(:final preset) => preset.densityGPerCm3,
    CustomConsumableSelection(:final material) => material.densityGPerCm3,
  };

  String get description => switch (this) {
    BuiltInConsumableSelection(:final preset) => preset.description,
    CustomConsumableSelection(:final material) =>
      material.notes.trim().isNotEmpty
          ? material.notes
          : 'Custom filler material from your library.',
  };

  String descriptionFor(L10nStrings strings) => switch (this) {
    BuiltInConsumableSelection(:final preset) => preset.descriptionFor(strings),
    CustomConsumableSelection(:final material) =>
      material.notes.trim().isNotEmpty
          ? material.notes
          : strings.consumableCustomFallbackDescription,
  };

  // Built-in base-metal designation lists stay English-only (disclosed
  // follow-up, see ConsumablePresetX.typicalBaseMetals) -- only the custom
  // fallback sentence (actual UI prose, not a code list) is localized here.
  String typicalBaseMetalsTextFor(L10nStrings strings) => switch (this) {
    BuiltInConsumableSelection(:final preset) => preset.typicalBaseMetals.join(
      ', ',
    ),
    CustomConsumableSelection(:final material) =>
      material.notes.trim().isNotEmpty
          ? material.notes
          : strings.consumableCustomNoTypicalBaseMetals,
  };
}

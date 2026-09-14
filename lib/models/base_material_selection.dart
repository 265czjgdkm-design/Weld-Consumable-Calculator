import 'custom_material_models.dart';

/// Companion to [ConsumableSelection] (see consumable_selection.dart) for
/// the base-metal side of a calculation. Unlike the filler dropdown, this
/// app has no pre-existing built-in base-material catalog/enum anywhere to
/// extend (confirmed by grep before this feature was added) -- so there is
/// no "built-in vs. custom" union to model here, only the one real case: a
/// snapshot of a user's custom base material from [CustomBaseMaterialStore].
/// A `BaseMaterialSelection?` field being `null` represents "not specified",
/// matching how every other optional field in this codebase is modeled,
/// rather than inventing a placeholder "unspecified" variant.
///
/// A snapshot rather than a live reference -- once saved into a
/// calculation, later edits/deletes to the library entry must not change
/// the saved calculation (same immutability decision as
/// CustomConsumableSelection).
class BaseMaterialSelection {
  const BaseMaterialSelection(this.material);

  factory BaseMaterialSelection.fromJson(Map<String, dynamic> json) =>
      BaseMaterialSelection(
        CustomBaseMaterial.fromJson(
          json['customBaseMaterial'] as Map<String, dynamic>,
        ),
      );

  final CustomBaseMaterial material;

  String get label => material.name;

  Map<String, dynamic> toJson() => {'customBaseMaterial': material.toJson()};

  @override
  bool operator ==(Object other) =>
      other is BaseMaterialSelection &&
      other.material.id == material.id &&
      other.material.updatedAtEpochMs == material.updatedAtEpochMs;

  @override
  int get hashCode => Object.hash(material.id, material.updatedAtEpochMs);
}

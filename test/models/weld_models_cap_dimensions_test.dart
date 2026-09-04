import 'package:flutter_test/flutter_test.dart';
import 'package:weld_consumable_calculator/models/consumable_selection.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';

void main() {
  test(
    'a pre-existing saved calculation JSON (no cap fields at all) loads '
    'with null capOverlapMm/capHeightMm, not a parse error or a default 0',
    () {
      final oldJson = {
        'jointType': 'plateButt',
        'grooveType': 'singleV',
        'weldingProcess': 'gtaw',
        'consumablePreset': 'er70s2',
        'quantity': 1,
        'wasteFactorPercent': 10,
        'lengthPerPieceMm': 1000,
        'thicknessMm': 12,
        'rootGapMm': 3,
        'rootFaceMm': 2,
        'bevelAngleDeg': 30,
      };

      final preset = WeldInputPresetData.fromJson(oldJson);

      expect(preset.capOverlapMm, isNull);
      expect(preset.capHeightMm, isNull);
    },
  );

  test('capOverlapMm/capHeightMm round-trip through toJson/fromJson', () {
    const preset = WeldInputPresetData(
      jointType: JointType.plateButt,
      grooveType: GrooveType.singleV,
      weldingProcess: WeldingProcess.gtaw,
      consumableSelection: BuiltInConsumableSelection(ConsumablePreset.er70s2),
      quantity: 1,
      wasteFactorPercent: 10,
      capOverlapMm: 2.5,
      capHeightMm: 3.5,
    );

    final roundTripped = WeldInputPresetData.fromJson(preset.toJson());

    expect(roundTripped.capOverlapMm, 2.5);
    expect(roundTripped.capHeightMm, 3.5);
  });

  test('capOverlapMm/capHeightMm are omitted from toJson when null (no '
      'spurious 0mm entries for calculations that never set them)', () {
    const preset = WeldInputPresetData(
      jointType: JointType.plateButt,
      grooveType: GrooveType.singleV,
      weldingProcess: WeldingProcess.gtaw,
      consumableSelection: BuiltInConsumableSelection(ConsumablePreset.er70s2),
      quantity: 1,
      wasteFactorPercent: 10,
    );

    final json = preset.toJson();

    expect(json.containsKey('capOverlapMm'), isFalse);
    expect(json.containsKey('capHeightMm'), isFalse);
  });
}

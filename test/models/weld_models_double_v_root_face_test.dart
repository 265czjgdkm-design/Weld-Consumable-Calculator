import 'package:flutter_test/flutter_test.dart';
import 'package:weld_consumable_calculator/models/consumable_selection.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';

WeldInputPresetData _preset(GrooveType g) => WeldInputPresetData(
  jointType: JointType.plateButt,
  grooveType: g,
  weldingProcess: WeldingProcess.smaw,
  consumableSelection: const BuiltInConsumableSelection(ConsumablePreset.e7018),
  quantity: 1,
  wasteFactorPercent: 10,
  rootFaceMm: 2,
  backGougeDepthMm: g == GrooveType.doubleV ? 4 : null,
);

void main() {
  test('new Double V presets keep c (total land) and back-gouge as saved', () {
    final r = WeldInputPresetData.fromJson(
      _preset(GrooveType.doubleV).toJson(),
    );
    expect(r.rootFaceMm, 2);
    expect(r.backGougeDepthMm, 4);
  });

  test('legacy Double V presets (c per side) are converted to total land', () {
    final json = _preset(GrooveType.doubleV).toJson()
      ..remove('rootFaceTotalLand');
    expect(WeldInputPresetData.fromJson(json).rootFaceMm, 4);
  });

  test('other grooves are never touched', () {
    final json = _preset(GrooveType.singleV).toJson();
    expect(json.containsKey('rootFaceTotalLand'), isFalse);
    expect(WeldInputPresetData.fromJson(json).rootFaceMm, 2);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/models/base_material_selection.dart';
import 'package:weld_consumable_calculator/models/consumable_selection.dart';
import 'package:weld_consumable_calculator/models/custom_material_models.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/custom_base_material_store.dart';
import 'package:weld_consumable_calculator/services/user_preset_store.dart';

const _customMaterial = CustomBaseMaterial(
  id: 'base-custom-1',
  name: 'Acme S355',
  designation: 'S355J2',
  notes: 'Structural steel plate stock.',
  updatedAtEpochMs: 5000,
  carbonPercent: 0.2,
);

WeldInputPresetData _presetDataWith(BaseMaterialSelection? selection) =>
    WeldInputPresetData(
      jointType: JointType.plateButt,
      grooveType: GrooveType.singleV,
      weldingProcess: WeldingProcess.gmaw,
      consumableSelection: BuiltInConsumableSelection(ConsumablePreset.er70s6),
      baseMaterialSelection: selection,
      quantity: 1,
      wasteFactorPercent: 10,
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BaseMaterialSelection', () {
    test('toJson embeds a full material snapshot, not just an id', () {
      const selection = BaseMaterialSelection(_customMaterial);
      final json = selection.toJson();

      final embedded = json['customBaseMaterial'] as Map<String, dynamic>;
      expect(embedded['name'], 'Acme S355');
      expect(embedded['designation'], 'S355J2');
      expect(embedded['carbonPercent'], 0.2);

      final restored = BaseMaterialSelection.fromJson(json);
      expect(restored.material.name, 'Acme S355');
      expect(restored.material.designation, 'S355J2');
      expect(restored.material.carbonPercent, 0.2);
    });

    test('equality is by id + updatedAtEpochMs, matching the snapshot-'
        'immutability semantics of CustomConsumableSelection', () {
      const a = BaseMaterialSelection(_customMaterial);
      const editedButSameStamp = BaseMaterialSelection(
        CustomBaseMaterial(
          id: 'base-custom-1',
          name: 'Different name, same stamp',
          designation: '',
          notes: '',
          updatedAtEpochMs: 5000,
        ),
      );
      const editedWithNewStamp = BaseMaterialSelection(
        CustomBaseMaterial(
          id: 'base-custom-1',
          name: 'Acme S355',
          designation: 'S355J2',
          notes: '',
          updatedAtEpochMs: 6000,
        ),
      );

      expect(a, editedButSameStamp);
      expect(a, isNot(editedWithNewStamp));
    });
  });

  group('WeldInputPresetData baseMaterialSelection JSON compatibility', () {
    test('absent on a preset saved before this feature existed -- loads as '
        'null ("not specified"), not a crash', () {
      final legacyJson = {
        'jointType': 'plateButt',
        'grooveType': 'singleV',
        'weldingProcess': 'gmaw',
        'consumableSelection': BuiltInConsumableSelection(ConsumablePreset.er70s6)
            .toJson(),
        'quantity': 1.0,
        'wasteFactorPercent': 10.0,
      };

      final data = WeldInputPresetData.fromJson(legacyJson);
      expect(data.baseMaterialSelection, isNull);
    });

    test('null selection round-trips as no key at all (not a null value)', () {
      final data = _presetDataWith(null);
      final json = data.toJson();
      expect(json.containsKey('baseMaterialSelection'), isFalse);

      final restored = WeldInputPresetData.fromJson(json);
      expect(restored.baseMaterialSelection, isNull);
    });

    test('a selected custom base material round-trips through JSON', () {
      final data = _presetDataWith(const BaseMaterialSelection(_customMaterial));
      final restored = WeldInputPresetData.fromJson(data.toJson());
      expect(restored.baseMaterialSelection, isNotNull);
      expect(restored.baseMaterialSelection!.material.name, 'Acme S355');
      expect(restored.baseMaterialSelection!.material.designation, 'S355J2');
    });

    test('a malformed baseMaterialSelection value causes the whole preset '
        'row to be skipped rather than corrupting the rest of the list '
        '(matches the existing skip-and-log resilience convention)', () async {
      final goodPreset = _presetDataWith(null);
      final badJson = {
        'id': 'bad-1',
        'name': 'Corrupt',
        'updatedAtEpochMs': 1,
        'data': {
          ...goodPreset.toJson(),
          'baseMaterialSelection': 'not-a-map',
        },
      };
      final goodJson = UserWeldPreset(
        id: 'good-1',
        name: 'Fine',
        updatedAtEpochMs: 2,
        data: goodPreset,
      ).toJson();

      const store = UserPresetStore();
      await store.save([]);
      final decoded = [badJson, goodJson];
      // Exercise UserWeldPreset.fromJson the same way UserPresetStore.load
      // does internally (per-row try/catch), rather than the store's own
      // load() (which reads only from SharedPreferences).
      var skipped = 0;
      final parsed = <UserWeldPreset>[];
      for (final item in decoded) {
        try {
          parsed.add(UserWeldPreset.fromJson(item));
        } catch (_) {
          skipped++;
        }
      }
      expect(skipped, 1);
      expect(parsed, hasLength(1));
      expect(parsed.single.id, 'good-1');
    });
  });

  test('a saved calculation referencing a custom base material keeps its '
      'snapshot even after the source library entry is edited or deleted',
      () async {
    const baseStore = CustomBaseMaterialStore();
    await baseStore.save([_customMaterial]);

    const selection = BaseMaterialSelection(_customMaterial);
    final preset = UserWeldPreset(
      id: 'preset-1',
      name: 'Custom Base Material Test',
      updatedAtEpochMs: 1,
      data: _presetDataWith(selection),
    );

    const presetStore = UserPresetStore();
    await presetStore.save([preset]);

    const editedMaterial = CustomBaseMaterial(
      id: 'base-custom-1',
      name: 'Renamed Material',
      designation: 'X100',
      notes: 'Edited after the calculation was saved.',
      updatedAtEpochMs: 6000,
    );
    await baseStore.save([editedMaterial]);
    await baseStore.save(const []);

    final reloaded = (await presetStore.load()).presets;
    expect(reloaded, hasLength(1));
    final reloadedSelection = reloaded.single.data.baseMaterialSelection!;
    expect(reloadedSelection.material.name, 'Acme S355');
    expect(reloadedSelection.material.designation, 'S355J2');
  });
}

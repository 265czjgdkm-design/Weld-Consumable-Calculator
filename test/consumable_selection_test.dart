import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/core/weld_calculator.dart';
import 'package:weld_consumable_calculator/models/consumable_selection.dart';
import 'package:weld_consumable_calculator/models/custom_material_models.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/custom_filler_material_store.dart';
import 'package:weld_consumable_calculator/services/user_preset_store.dart';
import 'package:weld_consumable_calculator/services/weld_pdf_report_service.dart';

const _customMaterial = CustomFillerMaterial(
  id: 'filler-custom-1',
  name: 'Acme XR-70',
  family: ConsumableFamily.carbonSteel,
  awsSpecification: null,
  densityGPerCm3: 7.9,
  notes: 'House-brand equivalent to ER70S-6.',
  updatedAtEpochMs: 5000,
);

WeldInputPresetData _presetDataWith(ConsumableSelection selection) =>
    WeldInputPresetData(
      jointType: JointType.plateButt,
      grooveType: GrooveType.singleV,
      weldingProcess: WeldingProcess.gmaw,
      consumableSelection: selection,
      quantity: 1,
      wasteFactorPercent: 10,
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ConsumableSelection', () {
    test('builtin toJson/fromJson round-trips', () {
      const selection = BuiltInConsumableSelection(ConsumablePreset.er70s6);
      final restored = ConsumableSelection.fromJson(selection.toJson());
      expect(restored, isA<BuiltInConsumableSelection>());
      expect((restored as BuiltInConsumableSelection).preset, ConsumablePreset.er70s6);
    });

    test('custom toJson embeds a full material snapshot, not just an id', () {
      const selection = CustomConsumableSelection(_customMaterial);
      final json = selection.toJson();

      expect(json['consumableSelectionType'], 'custom');
      final embedded = json['customFillerMaterial'] as Map<String, dynamic>;
      expect(embedded['name'], 'Acme XR-70');
      expect(embedded['densityGPerCm3'], 7.9);

      final restored = ConsumableSelection.fromJson(json);
      expect(restored, isA<CustomConsumableSelection>());
      final material = (restored as CustomConsumableSelection).material;
      expect(material.name, 'Acme XR-70');
      expect(material.awsSpecification, isNull);
      expect(material.densityGPerCm3, 7.9);
    });

    test('custom selection has no AWS spec and falls back gracefully', () {
      const selection = CustomConsumableSelection(_customMaterial);
      expect(selection.awsSpecification, isNull);
      expect(selection.awsDisplayLabel, 'Acme XR-70 (Carbon Steel)');
      expect(selection.description, 'House-brand equivalent to ER70S-6.');
    });
  });

  group('WeldInputPresetData legacy JSON compatibility', () {
    test(
      'a bare "consumablePreset" key with no discriminant still loads as builtin',
      () {
        final legacyJson = {
          'jointType': 'plateButt',
          'grooveType': 'singleV',
          'weldingProcess': 'gmaw',
          'consumablePreset': 'er70s6',
          'quantity': 1.0,
          'wasteFactorPercent': 10.0,
        };

        final data = WeldInputPresetData.fromJson(legacyJson);
        expect(data.consumableSelection, isA<BuiltInConsumableSelection>());
        expect(
          (data.consumableSelection as BuiltInConsumableSelection).preset,
          ConsumablePreset.er70s6,
        );
      },
    );

    test('new-format JSON with a custom selection round-trips', () {
      final data = _presetDataWith(const CustomConsumableSelection(_customMaterial));
      final restored = WeldInputPresetData.fromJson(data.toJson());
      expect(restored.consumableSelection, isA<CustomConsumableSelection>());
      expect(
        (restored.consumableSelection as CustomConsumableSelection).material.name,
        'Acme XR-70',
      );
    });
  });

  test(
    'a saved calculation referencing a custom material keeps its snapshot '
    'even after the source library entry is edited or deleted',
    () async {
      const fillerStore = CustomFillerMaterialStore();
      await fillerStore.save([_customMaterial]);

      // Capture the selection as the calculator would at save time.
      const selection = CustomConsumableSelection(_customMaterial);
      final preset = UserWeldPreset(
        id: 'preset-1',
        name: 'Custom Filler Test',
        updatedAtEpochMs: 1,
        data: _presetDataWith(selection),
      );

      const presetStore = UserPresetStore();
      await presetStore.save([preset]);

      // The library entry is now edited (same id, different values) and
      // then deleted entirely -- neither should affect the saved snapshot.
      const editedMaterial = CustomFillerMaterial(
        id: 'filler-custom-1',
        name: 'Renamed Material',
        family: ConsumableFamily.stainlessSteel,
        densityGPerCm3: 8.0,
        notes: 'Edited after the calculation was saved.',
        updatedAtEpochMs: 6000,
      );
      await fillerStore.save([editedMaterial]);
      await fillerStore.save(const []);

      final reloaded = await presetStore.load();
      expect(reloaded, hasLength(1));
      final reloadedSelection =
          reloaded.single.data.consumableSelection as CustomConsumableSelection;
      expect(reloadedSelection.material.name, 'Acme XR-70');
      expect(reloadedSelection.material.family, ConsumableFamily.carbonSteel);
      expect(reloadedSelection.material.densityGPerCm3, 7.9);
    },
  );

  test(
    'PDF report generation does not crash for a custom material with no AWS spec',
    () async {
      const calculator = WeldCalculator();
      const input = WeldInputData(
        jointType: JointType.plateButt,
        grooveType: GrooveType.square,
        weldingProcess: WeldingProcess.gmaw,
        depositionRateMode: DepositionRateMode.preset,
        quantity: 1,
        densityGPerCm3: 7.9,
        wasteFactorPercent: 10,
        lengthPerPieceMm: 500,
        thicknessMm: 6,
        rootGapMm: 2,
        wireDiameterMm: 1.2,
      );
      final result = calculator.calculate(input);

      const service = WeldPdfReportService();
      final bytes = await service.buildReportBytes(
        jointType: JointType.plateButt,
        grooveType: GrooveType.square,
        weldingProcess: WeldingProcess.gmaw,
        consumableSelection: const CustomConsumableSelection(_customMaterial),
        result: result,
        basisEntries: const [MapEntry('Density', '7.9 g/cm3')],
      );

      expect(bytes, isNotEmpty);
    },
  );
}

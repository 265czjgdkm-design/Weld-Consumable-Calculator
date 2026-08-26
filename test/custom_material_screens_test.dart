import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/models/custom_material_models.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/custom_base_material_store.dart';
import 'package:weld_consumable_calculator/services/custom_filler_material_store.dart';
import 'package:weld_consumable_calculator/ui/base_material_screen.dart';
import 'package:weld_consumable_calculator/ui/filler_material_screen.dart';

Future<void> _pumpScreen(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(
    AppLocaleScope(locale: AppLocale(), child: MaterialApp(home: screen)),
  );
  await tester.pumpAndSettle();
}

Finder _fieldByLabel(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

Future<void> _enterByLabel(
  WidgetTester tester,
  String label,
  String value,
) async {
  final finder = _fieldByLabel(label);
  await tester.ensureVisible(finder);
  await tester.enterText(finder, value);
}

String _textOf(WidgetTester tester, String label) =>
    tester.widget<TextField>(_fieldByLabel(label)).controller!.text;

const _fullBaseMaterial = CustomBaseMaterial(
  id: 'base-1',
  name: 'S355J2',
  designation: 'EN 10025-2',
  notes: 'note',
  updatedAtEpochMs: 1000,
  sheetThicknessMm: 12,
  minSheetThicknessMm: 5,
  maxSheetThicknessMm: 20,
  producerName: 'ArcelorMittal',
  materialId: '1.0577',
  carbonPercent: 0.20,
  siliconPercent: 0.55,
  cetPercent: 0.38,
  pcmPercent: 0.21,
);

const _fullFillerMaterial = CustomFillerMaterial(
  id: 'filler-1',
  name: 'ER70S-6',
  family: ConsumableFamily.carbonSteel,
  densityGPerCm3: 7.85,
  notes: 'note',
  updatedAtEpochMs: 1000,
  awsSpecification: 'AWS A5.18',
  producerName: 'Lincoln Electric',
  materialId: 'LNX-ER70S6',
  carbonPercent: 0.08,
  cetPercent: 0.22,
  pcmPercent: 0.15,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'creating a base material with the new fields persists and reloads into the edit form',
    (tester) async {
      await _pumpScreen(tester, const BaseMaterialScreen());

      await tester.tap(find.text('Add Base Material'));
      await tester.pumpAndSettle();

      await _enterByLabel(tester, 'Name', 'S355J2');
      await _enterByLabel(tester, 'Designation', 'EN 10025-2');
      await _enterByLabel(tester, 'Sheet Thickness (d, mm)', '12');
      await _enterByLabel(tester, 'Min. Sheet Thickness (dmin, mm)', '5');
      await _enterByLabel(tester, 'Max. Sheet Thickness (dmax, mm)', '20');
      await _enterByLabel(tester, 'Producer Name', 'ArcelorMittal');
      await _enterByLabel(tester, 'Material ID', '1.0577');
      await _enterByLabel(tester, 'C (%)', '0.20');
      await _enterByLabel(tester, 'Si (%)', '0.55');
      await _enterByLabel(tester, 'Mn (%)', '1.60');
      await _enterByLabel(tester, 'Cr (%)', '0.30');
      await _enterByLabel(tester, 'Mo (%)', '0.10');
      await _enterByLabel(tester, 'Cu (%)', '0.55');
      await _enterByLabel(tester, 'V (%)', '0.10');
      await _enterByLabel(tester, 'Nb (%)', '0.05');
      await _enterByLabel(tester, 'Ti (%)', '0.05');
      await _enterByLabel(tester, 'B (%)', '0.005');
      await _enterByLabel(tester, 'N (%)', '0.012');
      await _enterByLabel(tester, 'CET (%)', '0.38');
      await _enterByLabel(tester, 'Pcm (%)', '0.21');

      final saveButton = find.widgetWithText(FilledButton, 'Save');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('S355J2'), findsOneWidget);

      final stored = await const CustomBaseMaterialStore().load();
      expect(stored, hasLength(1));
      final saved = stored.single;
      expect(saved.name, 'S355J2');
      expect(saved.designation, 'EN 10025-2');
      expect(saved.sheetThicknessMm, 12);
      expect(saved.minSheetThicknessMm, 5);
      expect(saved.maxSheetThicknessMm, 20);
      expect(saved.producerName, 'ArcelorMittal');
      expect(saved.materialId, '1.0577');
      expect(saved.carbonPercent, 0.20);
      expect(saved.siliconPercent, 0.55);
      expect(saved.manganesePercent, 1.60);
      expect(saved.chromiumPercent, 0.30);
      expect(saved.molybdenumPercent, 0.10);
      expect(saved.copperPercent, 0.55);
      expect(saved.vanadiumPercent, 0.10);
      expect(saved.niobiumPercent, 0.05);
      expect(saved.titaniumPercent, 0.05);
      expect(saved.boronPercent, 0.005);
      expect(saved.nitrogenPercent, 0.012);
      expect(saved.cetPercent, 0.38);
      expect(saved.pcmPercent, 0.21);

      // Reopen for edit and confirm every new field reloaded correctly.
      await tester.tap(find.text('S355J2'));
      await tester.pumpAndSettle();

      expect(_textOf(tester, 'Producer Name'), 'ArcelorMittal');
      expect(_textOf(tester, 'Material ID'), '1.0577');
      expect(
        double.parse(_textOf(tester, 'Sheet Thickness (d, mm)')),
        closeTo(12, 1e-9),
      );
      expect(
        double.parse(_textOf(tester, 'Min. Sheet Thickness (dmin, mm)')),
        closeTo(5, 1e-9),
      );
      expect(
        double.parse(_textOf(tester, 'Max. Sheet Thickness (dmax, mm)')),
        closeTo(20, 1e-9),
      );
      expect(double.parse(_textOf(tester, 'C (%)')), closeTo(0.20, 1e-9));
      expect(double.parse(_textOf(tester, 'Mn (%)')), closeTo(1.60, 1e-9));
      expect(double.parse(_textOf(tester, 'B (%)')), closeTo(0.005, 1e-9));
      expect(double.parse(_textOf(tester, 'CET (%)')), closeTo(0.38, 1e-9));
      expect(double.parse(_textOf(tester, 'Pcm (%)')), closeTo(0.21, 1e-9));
    },
  );

  testWidgets(
    'creating a filler material with the new fields persists and reloads into the edit form',
    (tester) async {
      await _pumpScreen(tester, const FillerMaterialScreen());

      await tester.tap(find.text('Add Filler Material'));
      await tester.pumpAndSettle();

      await _enterByLabel(tester, 'Name', 'ER70S-6');
      await _enterByLabel(tester, 'AWS Specification', 'AWS A5.18');
      await _enterByLabel(tester, 'Density (g/cm³)', '7.85');
      await _enterByLabel(tester, 'Producer Name', 'Lincoln Electric');
      await _enterByLabel(tester, 'Material ID', 'LNX-ER70S6');
      await _enterByLabel(tester, 'C (%)', '0.08');
      await _enterByLabel(tester, 'Si (%)', '0.90');
      await _enterByLabel(tester, 'Mn (%)', '1.50');
      await _enterByLabel(tester, 'Cr (%)', '0.02');
      await _enterByLabel(tester, 'Mo (%)', '0.01');
      await _enterByLabel(tester, 'Cu (%)', '0.25');
      await _enterByLabel(tester, 'V (%)', '0.01');
      await _enterByLabel(tester, 'Nb (%)', '0.01');
      await _enterByLabel(tester, 'Ti (%)', '0.01');
      await _enterByLabel(tester, 'B (%)', '0.001');
      await _enterByLabel(tester, 'N (%)', '0.01');
      await _enterByLabel(tester, 'CET (%)', '0.22');
      await _enterByLabel(tester, 'Pcm (%)', '0.15');

      final saveButton = find.widgetWithText(FilledButton, 'Save');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('ER70S-6'), findsOneWidget);

      final stored = await const CustomFillerMaterialStore().load();
      expect(stored, hasLength(1));
      final saved = stored.single;
      expect(saved.name, 'ER70S-6');
      expect(saved.densityGPerCm3, 7.85);
      expect(saved.producerName, 'Lincoln Electric');
      expect(saved.materialId, 'LNX-ER70S6');
      expect(saved.carbonPercent, 0.08);
      expect(saved.siliconPercent, 0.90);
      expect(saved.manganesePercent, 1.50);
      expect(saved.chromiumPercent, 0.02);
      expect(saved.molybdenumPercent, 0.01);
      expect(saved.copperPercent, 0.25);
      expect(saved.vanadiumPercent, 0.01);
      expect(saved.niobiumPercent, 0.01);
      expect(saved.titaniumPercent, 0.01);
      expect(saved.boronPercent, 0.001);
      expect(saved.nitrogenPercent, 0.01);
      expect(saved.cetPercent, 0.22);
      expect(saved.pcmPercent, 0.15);

      // Reopen for edit and confirm every new field reloaded correctly.
      await tester.tap(find.text('ER70S-6'));
      await tester.pumpAndSettle();

      expect(_textOf(tester, 'Producer Name'), 'Lincoln Electric');
      expect(_textOf(tester, 'Material ID'), 'LNX-ER70S6');
      expect(double.parse(_textOf(tester, 'C (%)')), closeTo(0.08, 1e-9));
      expect(double.parse(_textOf(tester, 'Mn (%)')), closeTo(1.50, 1e-9));
      expect(double.parse(_textOf(tester, 'CET (%)')), closeTo(0.22, 1e-9));
      expect(double.parse(_textOf(tester, 'Pcm (%)')), closeTo(0.15, 1e-9));
    },
  );

  testWidgets(
    'clearing previously-set base material fields persists them as null, '
    'leaving untouched fields intact (copyWith-clear regression guard)',
    (tester) async {
      await const CustomBaseMaterialStore().save([_fullBaseMaterial]);
      await _pumpScreen(tester, const BaseMaterialScreen());

      await tester.tap(find.text('S355J2'));
      await tester.pumpAndSettle();

      // Sanity: fields arrived populated before we clear any of them.
      expect(_textOf(tester, 'Producer Name'), 'ArcelorMittal');

      await _enterByLabel(tester, 'Producer Name', '');
      await _enterByLabel(tester, 'C (%)', '');
      await _enterByLabel(tester, 'CET (%)', '');

      final saveButton = find.widgetWithText(FilledButton, 'Save');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      final reloaded = (await const CustomBaseMaterialStore().load()).single;
      expect(reloaded.producerName, isNull, reason: 'producerName must clear');
      expect(reloaded.carbonPercent, isNull, reason: 'carbonPercent must clear');
      expect(reloaded.cetPercent, isNull, reason: 'cetPercent must clear');
      // Untouched neighbours must survive the copyWith-free rebuild.
      expect(reloaded.materialId, '1.0577');
      expect(reloaded.siliconPercent, 0.55);
      expect(reloaded.pcmPercent, 0.21);
      expect(reloaded.sheetThicknessMm, 12);
    },
  );

  testWidgets(
    'clearing previously-set filler material fields persists them as null, '
    'leaving untouched fields intact (copyWith-clear regression guard)',
    (tester) async {
      await const CustomFillerMaterialStore().save([_fullFillerMaterial]);
      await _pumpScreen(tester, const FillerMaterialScreen());

      await tester.tap(find.text('ER70S-6'));
      await tester.pumpAndSettle();

      await _enterByLabel(tester, 'AWS Specification', '');
      await _enterByLabel(tester, 'Producer Name', '');
      await _enterByLabel(tester, 'C (%)', '');
      await _enterByLabel(tester, 'CET (%)', '');

      final saveButton = find.widgetWithText(FilledButton, 'Save');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      final reloaded = (await const CustomFillerMaterialStore().load()).single;
      expect(
        reloaded.awsSpecification,
        isNull,
        reason: 'awsSpecification must clear',
      );
      expect(reloaded.producerName, isNull, reason: 'producerName must clear');
      expect(reloaded.carbonPercent, isNull, reason: 'carbonPercent must clear');
      expect(reloaded.cetPercent, isNull, reason: 'cetPercent must clear');
      // Untouched neighbours must survive.
      expect(reloaded.materialId, 'LNX-ER70S6');
      expect(reloaded.densityGPerCm3, 7.85);
      expect(reloaded.pcmPercent, 0.15);
    },
  );

  testWidgets(
    'a stale numeric validation error does not survive after the field is '
    'corrected, even when a later validation (Name) blocks the save',
    (tester) async {
      await _pumpScreen(tester, const BaseMaterialScreen());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Valid name + invalid C(%) -> save -> C(%) error appears.
      await _enterByLabel(tester, 'Name', 'S355');
      await _enterByLabel(tester, 'C (%)', 'abc');
      final saveButton = find.widgetWithText(FilledButton, 'Save');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid number'), findsOneWidget);

      // User fixes C(%) but clears Name, then saves again.
      await _enterByLabel(tester, 'C (%)', '0.2');
      await _enterByLabel(tester, 'Name', '');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Name is required'), findsOneWidget);
      expect(
        find.text('Enter a valid number'),
        findsNothing,
        reason: 'C(%) is now valid and must not still show a stale error',
      );
    },
  );

  testWidgets(
    'out-of-range chemical composition and sheet thickness values are '
    'rejected and not persisted',
    (tester) async {
      await const CustomBaseMaterialStore().save([_fullBaseMaterial]);
      await _pumpScreen(tester, const BaseMaterialScreen());
      await tester.tap(find.text('S355J2'));
      await tester.pumpAndSettle();

      await _enterByLabel(tester, 'C (%)', '-5');
      await _enterByLabel(tester, 'Si (%)', '900');
      await _enterByLabel(tester, 'Sheet Thickness (d, mm)', '-3');
      await _enterByLabel(tester, 'Min. Sheet Thickness (dmin, mm)', '99');
      await _enterByLabel(tester, 'Max. Sheet Thickness (dmax, mm)', '1');

      final saveButton = find.widgetWithText(FilledButton, 'Save');
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Enter a value in the valid range'), findsWidgets);
      final stored = (await const CustomBaseMaterialStore().load()).single;
      expect(stored.carbonPercent, 0.20, reason: 'invalid input must not overwrite');
      expect(stored.siliconPercent, 0.55, reason: 'invalid input must not overwrite');
      expect(stored.sheetThicknessMm, 12, reason: 'invalid input must not overwrite');
    },
  );
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/models/consumable_selection.dart';
import 'package:weld_consumable_calculator/models/custom_material_models.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/ui/calculator_page.dart';

/// The saved-calculation snapshot always used across these regression
/// tests -- deliberately distinct from whatever the live library holds in
/// each scenario, so opening it exercises the dropdown-item-injection fix
/// (see finding #1).
const _savedMaterial = CustomFillerMaterial(
  id: 'filler-1',
  name: 'Acme XR-70',
  family: ConsumableFamily.carbonSteel,
  densityGPerCm3: 7.9,
  notes: 'House-brand equivalent to ER70S-6.',
  updatedAtEpochMs: 5000,
);

UserWeldPreset _presetWithCustomFiller(CustomFillerMaterial material) {
  final base = InputPreset.csPlateSingleVGmaw.data!;
  return UserWeldPreset(
    id: 'preset-with-custom-filler',
    name: 'Saved With Custom Filler',
    updatedAtEpochMs: 1000,
    data: WeldInputPresetData(
      jointType: base.jointType,
      grooveType: base.grooveType,
      weldingProcess: base.weldingProcess,
      consumableSelection: CustomConsumableSelection(material),
      quantity: base.quantity,
      wasteFactorPercent: base.wasteFactorPercent,
      lengthPerPieceMm: base.lengthPerPieceMm,
      thicknessMm: base.thicknessMm,
      rootGapMm: base.rootGapMm,
      rootFaceMm: base.rootFaceMm,
      bevelAngleDeg: base.bevelAngleDeg,
      wireDiameterMm: base.wireDiameterMm,
    ),
  );
}

/// Desktop width (>=1120px, matching how the reviewer reproduced the bug)
/// so the calculator renders `_buildWidePage`'s always-visible consumable
/// dropdown rather than the mobile wizard's step-gated one.
void _setDesktopViewport(WidgetTester tester) {
  final originalPhysicalSize = tester.view.physicalSize;
  final originalDevicePixelRatio = tester.view.devicePixelRatio;
  tester.view.physicalSize = const Size(1400, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.physicalSize = originalPhysicalSize;
    tester.view.devicePixelRatio = originalDevicePixelRatio;
  });
}

void main() {
  testWidgets(
    'opening a saved calculation whose custom filler material was edited '
    'after save does not crash the consumable dropdown',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        // Same id, later updatedAtEpochMs -- an edit in the library since
        // this calculation was saved.
        'custom_filler_materials_v1': jsonEncode([
          _savedMaterial.toJson().cast<String, dynamic>()
            ..['updatedAtEpochMs'] = 9000,
        ]),
      });
      _setDesktopViewport(tester);

      await tester.pumpWidget(
        AppLocaleScope(
          locale: AppLocale(),
          child: MaterialApp(
            home: CalculatorPage(
              presetToLoad: _presetWithCustomFiller(_savedMaterial),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ErrorWidget), findsNothing);
      expect(find.textContaining('Acme XR-70'), findsWidgets);
      expect(find.textContaining('as saved'), findsWidgets);
    },
  );

  testWidgets(
    'opening a saved calculation whose custom filler material was deleted '
    'after save does not crash the consumable dropdown',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'custom_filler_materials_v1': jsonEncode(const []),
      });
      _setDesktopViewport(tester);

      await tester.pumpWidget(
        AppLocaleScope(
          locale: AppLocale(),
          child: MaterialApp(
            home: CalculatorPage(
              presetToLoad: _presetWithCustomFiller(_savedMaterial),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ErrorWidget), findsNothing);
      expect(find.textContaining('Acme XR-70'), findsWidgets);
      expect(find.textContaining('as saved'), findsWidgets);
    },
  );

  testWidgets(
    'a deleted custom filler snapshot stays selectable in the dropdown '
    'after picking something else, for the life of this screen instance '
    '(see finding #4)',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'custom_filler_materials_v1': jsonEncode(const []),
      });
      final originalPhysicalSize = tester.view.physicalSize;
      final originalDevicePixelRatio = tester.view.devicePixelRatio;
      // Tall enough that the dropdown menu route actually builds the
      // trailing "My Materials" entry, not just the leading built-ins (see
      // the note on `_setDesktopViewport`'s counterpart in
      // calculator_page_custom_filler_test.dart).
      tester.view.physicalSize = const Size(1400, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.physicalSize = originalPhysicalSize;
        tester.view.devicePixelRatio = originalDevicePixelRatio;
      });

      await tester.pumpWidget(
        AppLocaleScope(
          locale: AppLocale(),
          child: MaterialApp(
            home: CalculatorPage(
              presetToLoad: _presetWithCustomFiller(_savedMaterial),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('as saved'), findsWidgets);

      // Switch to a built-in classification to compare against.
      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is DropdownButtonFormField<ConsumableSelection>,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('AWS A5.18 ER70S-6 (Carbon Steel)').last);
      await tester.pumpAndSettle();

      // The "(as saved)" snapshot must still be offered, not silently
      // dropped once it stopped being the current selection.
      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is DropdownButtonFormField<ConsumableSelection>,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('as saved'), findsWidgets);

      // Reselecting it must work, restoring the original custom material.
      await tester.tap(find.textContaining('as saved').last);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final densityField = tester.widget<TextField>(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.labelText == 'Density (g/cm3)',
        ),
      );
      expect(densityField.controller!.text, '7.90');
    },
  );

  testWidgets(
    'opening a saved calculation with a custom filler material renders the '
    'very first frame without crashing, before the library store finishes '
    'loading asynchronously',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'custom_filler_materials_v1': jsonEncode([_savedMaterial.toJson()]),
      });
      _setDesktopViewport(tester);

      // Deliberately just one pump (what pumpWidget itself does) instead of
      // pumpAndSettle/an extra pump -- `_fillerMaterialStore.load()` still
      // has an async gap (a real SharedPreferences platform-channel round
      // trip) that hasn't resolved yet, so `_customFillerMaterials` is
      // still its initial empty list on this very first frame.
      await tester.pumpWidget(
        AppLocaleScope(
          locale: AppLocale(),
          child: MaterialApp(
            home: CalculatorPage(
              presetToLoad: _presetWithCustomFiller(_savedMaterial),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(ErrorWidget), findsNothing);
      // The library hasn't loaded yet on this very first frame, so the
      // still-healthy snapshot must not be flagged "(as saved)" -- that
      // label should wait for `_fillerMaterialsLoaded` (see finding #3).
      expect(find.textContaining('as saved'), findsNothing);

      // Let the async store load settle so the test doesn't leak a pending
      // timer/future into the next test.
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(ErrorWidget), findsNothing);
      expect(find.textContaining('as saved'), findsNothing);
    },
  );

  testWidgets(
    'tapping Reset clears a pinned stale custom-material selection, so the '
    'dropdown no longer offers a "My Materials" / "(as saved)" entry left '
    'over from a since-reset saved calculation (see finding #2)',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'custom_filler_materials_v1': jsonEncode(const []),
      });
      final originalPhysicalSize = tester.view.physicalSize;
      final originalDevicePixelRatio = tester.view.devicePixelRatio;
      tester.view.physicalSize = const Size(1400, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.physicalSize = originalPhysicalSize;
        tester.view.devicePixelRatio = originalDevicePixelRatio;
      });

      await tester.pumpWidget(
        AppLocaleScope(
          locale: AppLocale(),
          child: MaterialApp(
            home: CalculatorPage(
              presetToLoad: _presetWithCustomFiller(_savedMaterial),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The pin gets set as soon as the (now-deleted) snapshot fails to
      // match the loaded (empty) library.
      expect(find.textContaining('as saved'), findsWidgets);

      await tester.ensureVisible(find.text('Reset'));
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      final dropdownFinder = find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<ConsumableSelection>,
      );
      await tester.ensureVisible(dropdownFinder);
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      // Reset restores the GTAW default (ER70S-2); confirm the menu route
      // actually opened (closed field + open menu entry) rather than this
      // assertion trivially passing because nothing rendered at all.
      expect(
        find.textContaining('AWS A5.18 ER70S-2 (Carbon Steel)'),
        findsNWidgets(2),
      );
      expect(find.textContaining('as saved'), findsNothing);
      expect(find.text('My Materials'), findsNothing);
    },
  );
}

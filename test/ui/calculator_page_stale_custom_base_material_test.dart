import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/models/base_material_selection.dart';
import 'package:weld_consumable_calculator/models/custom_material_models.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/ui/calculator_page.dart';

/// The saved-calculation snapshot always used across these regression
/// tests -- deliberately distinct from whatever the live library holds in
/// each scenario, so opening it exercises the dropdown-item-injection fix
/// (mirroring consumable_selection's own precedent, finding #1).
const _savedMaterial = CustomBaseMaterial(
  id: 'base-1',
  name: 'Acme S355',
  designation: 'S355J2',
  notes: 'Structural steel plate stock.',
  updatedAtEpochMs: 5000,
);

UserWeldPreset _presetWithCustomBaseMaterial(CustomBaseMaterial material) {
  final base = InputPreset.csPlateSingleVGmaw.data!;
  return UserWeldPreset(
    id: 'preset-with-custom-base-material',
    name: 'Saved With Custom Base Material',
    updatedAtEpochMs: 1000,
    data: WeldInputPresetData(
      jointType: base.jointType,
      grooveType: base.grooveType,
      weldingProcess: base.weldingProcess,
      consumableSelection: base.consumableSelection,
      baseMaterialSelection: BaseMaterialSelection(material),
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

/// Desktop width (>=1120px) so the calculator renders `_buildWidePage`'s
/// always-visible dropdowns rather than the mobile wizard's step-gated one.
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
    'opening a saved calculation whose custom base material was edited '
    'after save does not crash the base-material dropdown',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        // Same id, later updatedAtEpochMs -- an edit in the library since
        // this calculation was saved.
        'custom_base_materials_v1': jsonEncode([
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
              presetToLoad: _presetWithCustomBaseMaterial(_savedMaterial),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ErrorWidget), findsNothing);
      expect(find.textContaining('Acme S355'), findsWidgets);
      expect(find.textContaining('as saved'), findsWidgets);
    },
  );

  testWidgets(
    'opening a saved calculation whose custom base material was deleted '
    'after save does not crash the base-material dropdown',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'custom_base_materials_v1': jsonEncode(const []),
      });
      _setDesktopViewport(tester);

      await tester.pumpWidget(
        AppLocaleScope(
          locale: AppLocale(),
          child: MaterialApp(
            home: CalculatorPage(
              presetToLoad: _presetWithCustomBaseMaterial(_savedMaterial),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ErrorWidget), findsNothing);
      expect(find.textContaining('Acme S355'), findsWidgets);
      expect(find.textContaining('as saved'), findsWidgets);
    },
  );

  testWidgets(
    'a deleted custom base-material snapshot stays selectable in the '
    'dropdown after picking "Not specified", for the life of this screen '
    'instance',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'custom_base_materials_v1': jsonEncode(const []),
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
              presetToLoad: _presetWithCustomBaseMaterial(_savedMaterial),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('as saved'), findsWidgets);

      final dropdownFinder = find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<BaseMaterialSelection?>,
      );

      // Switch to "Not specified" to compare against.
      await tester.ensureVisible(dropdownFinder);
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Not specified').last);
      await tester.pumpAndSettle();

      // The "(as saved)" snapshot must still be offered, not silently
      // dropped once it stopped being the current selection.
      await tester.ensureVisible(dropdownFinder);
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();
      expect(find.textContaining('as saved'), findsWidgets);

      // Reselecting it must work, restoring the original custom material.
      await tester.tap(find.textContaining('as saved').last);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.textContaining('Selected base material: Acme S355 (S355J2)'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'opening a saved calculation with a custom base material renders the '
    'very first frame without crashing, before the library store finishes '
    'loading asynchronously',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'custom_base_materials_v1': jsonEncode([_savedMaterial.toJson()]),
      });
      _setDesktopViewport(tester);

      // Deliberately just one pump instead of pumpAndSettle -- the base
      // material store's load() still has an async gap (a real
      // SharedPreferences platform-channel round trip) that hasn't
      // resolved yet on this very first frame.
      await tester.pumpWidget(
        AppLocaleScope(
          locale: AppLocale(),
          child: MaterialApp(
            home: CalculatorPage(
              presetToLoad: _presetWithCustomBaseMaterial(_savedMaterial),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(ErrorWidget), findsNothing);
      // The library hasn't loaded yet on this very first frame, so the
      // still-healthy snapshot must not be flagged "(as saved)".
      expect(find.textContaining('as saved'), findsNothing);

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(ErrorWidget), findsNothing);
      expect(find.textContaining('as saved'), findsNothing);
    },
  );

  testWidgets(
    'tapping Reset clears a pinned stale base-material selection, so the '
    'dropdown reverts to "Not specified" with no leftover "My Materials" / '
    '"(as saved)" entry',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'custom_base_materials_v1': jsonEncode(const []),
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
              presetToLoad: _presetWithCustomBaseMaterial(_savedMaterial),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('as saved'), findsWidgets);

      await tester.ensureVisible(find.text('Reset'));
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      final dropdownFinder = find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<BaseMaterialSelection?>,
      );
      await tester.ensureVisible(dropdownFinder);
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      expect(find.text('Not specified'), findsNWidgets(2));
      expect(find.textContaining('as saved'), findsNothing);
      expect(find.text('My Materials'), findsNothing);
    },
  );
}

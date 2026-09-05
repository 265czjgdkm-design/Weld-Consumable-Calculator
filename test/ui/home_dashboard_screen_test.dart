import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/app.dart';
import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/ui/base_material_screen.dart';
import 'package:weld_consumable_calculator/ui/calculator_page.dart';
import 'package:weld_consumable_calculator/ui/cooling_time_calculator_screen.dart';
import 'package:weld_consumable_calculator/ui/filler_material_screen.dart';
import 'package:weld_consumable_calculator/ui/home_dashboard_screen.dart';
import 'package:weld_consumable_calculator/ui/preheat_calculator_screen.dart';
import 'package:weld_consumable_calculator/ui/saved_calculations_screen.dart';
import 'package:weld_consumable_calculator/ui/saved_reports_screen.dart';

/// Pumps the REAL app (real `WeldConsumableCalculatorApp` theme, not a bare
/// `MaterialApp` with no theme) all the way to [HomeDashboardScreen] --
/// this matters specifically for the button-color assertions below, since
/// the reviewer's Finding 1 was only ever visible under the app's actual
/// `filledButtonTheme`, never under an untheemed `MaterialApp`.
Future<void> _gotoDashboard(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({
    'signup_gate_resolved_v1': true,
    'app_language_code': AppLanguage.en.code,
  });
  await tester.pumpWidget(const WeldConsumableCalculatorApp());
  // Splash screen navigates on a timer once its animation finishes.
  await tester.pump(const Duration(milliseconds: 2200));
  await tester.pumpAndSettle();
  expect(find.byType(HomeDashboardScreen), findsOneWidget);
}

/// Resolves the actual painted background [Color] of the [Material] that
/// backs a given `FilledButton` label -- the same "painted Material.color
/// readback" technique the reviewer used to catch Finding 1 in the first
/// place, so a regression here would be caught the same way it was found.
Color _filledButtonColor(WidgetTester tester, String label) {
  final buttonFinder = find.ancestor(
    of: find.text(label),
    matching: find.byType(FilledButton),
  );
  final materialFinder = find.descendant(
    of: buttonFinder,
    matching: find.byType(Material),
  );
  return tester.widget<Material>(materialFinder.first).color!;
}

void main() {
  final strings = stringsFor(AppLanguage.en);

  testWidgets('all 7 dashboard buttons render', (tester) async {
    await _gotoDashboard(tester);

    for (final label in [
      strings.dashboardFillerConsumption,
      strings.dashboardPreheatCalculator,
      strings.dashboardCoolingTimeCalculator,
      strings.dashboardBaseMaterial,
      strings.dashboardFillerMaterial,
      strings.dashboardSavedCalculations,
      strings.dashboardSavedReports,
    ]) {
      expect(find.text(label), findsOneWidget, reason: 'missing "$label"');
    }
  });

  testWidgets('Filler Material Consumption navigates to CalculatorPage', (
    tester,
  ) async {
    await _gotoDashboard(tester);
    await tester.ensureVisible(find.text(strings.dashboardFillerConsumption));
    await tester.tap(find.text(strings.dashboardFillerConsumption));
    await tester.pumpAndSettle();
    expect(find.byType(CalculatorPage), findsOneWidget);
  });

  testWidgets('Preheat Temperature navigates to PreheatCalculatorScreen', (
    tester,
  ) async {
    await _gotoDashboard(tester);
    await tester.ensureVisible(find.text(strings.dashboardPreheatCalculator));
    await tester.tap(find.text(strings.dashboardPreheatCalculator));
    await tester.pumpAndSettle();
    expect(find.byType(PreheatCalculatorScreen), findsOneWidget);
  });

  testWidgets('Cooling Time (t8/5) navigates to CoolingTimeCalculatorScreen', (
    tester,
  ) async {
    await _gotoDashboard(tester);
    await tester.ensureVisible(
      find.text(strings.dashboardCoolingTimeCalculator),
    );
    await tester.tap(find.text(strings.dashboardCoolingTimeCalculator));
    await tester.pumpAndSettle();
    expect(find.byType(CoolingTimeCalculatorScreen), findsOneWidget);
  });

  testWidgets('Base Material navigates to BaseMaterialScreen', (tester) async {
    await _gotoDashboard(tester);
    await tester.ensureVisible(find.text(strings.dashboardBaseMaterial));
    await tester.tap(find.text(strings.dashboardBaseMaterial));
    await tester.pumpAndSettle();
    expect(find.byType(BaseMaterialScreen), findsOneWidget);
  });

  testWidgets('Filler Material navigates to FillerMaterialScreen', (
    tester,
  ) async {
    await _gotoDashboard(tester);
    await tester.ensureVisible(find.text(strings.dashboardFillerMaterial));
    await tester.tap(find.text(strings.dashboardFillerMaterial));
    await tester.pumpAndSettle();
    expect(find.byType(FillerMaterialScreen), findsOneWidget);
  });

  testWidgets('Saved Calculations navigates to SavedCalculationsScreen', (
    tester,
  ) async {
    await _gotoDashboard(tester);
    await tester.ensureVisible(find.text(strings.dashboardSavedCalculations));
    await tester.tap(find.text(strings.dashboardSavedCalculations));
    await tester.pumpAndSettle();
    expect(find.byType(SavedCalculationsScreen), findsOneWidget);
  });

  testWidgets('Saved Reports navigates to SavedReportsScreen', (tester) async {
    await _gotoDashboard(tester);
    await tester.ensureVisible(find.text(strings.dashboardSavedReports));
    await tester.tap(find.text(strings.dashboardSavedReports));
    await tester.pumpAndSettle();
    expect(find.byType(SavedReportsScreen), findsOneWidget);
  });

  testWidgets(
    'the 3 calculator (emphasized) buttons and the 4 tonal buttons render '
    'with genuinely different painted colors (reviewer Finding 1: the '
    "app-wide filledButtonTheme used to intercept FilledButton.tonalIcon's "
    'own default color before it was ever reached)',
    (tester) async {
      await _gotoDashboard(tester);

      final emphasizedColors = [
        _filledButtonColor(tester, strings.dashboardFillerConsumption),
        _filledButtonColor(tester, strings.dashboardPreheatCalculator),
        _filledButtonColor(tester, strings.dashboardCoolingTimeCalculator),
      ];
      final tonalColors = [
        _filledButtonColor(tester, strings.dashboardBaseMaterial),
        _filledButtonColor(tester, strings.dashboardFillerMaterial),
        _filledButtonColor(tester, strings.dashboardSavedCalculations),
        _filledButtonColor(tester, strings.dashboardSavedReports),
      ];

      // The 3 emphasized (calculator) buttons all share one color...
      expect(emphasizedColors.toSet(), hasLength(1));
      // ...the 4 tonal (library/history) buttons all share a different one...
      expect(tonalColors.toSet(), hasLength(1));
      // ...and the two groups are genuinely different from each other, not
      // both silently resolved to the same app-wide theme color.
      expect(emphasizedColors.first, isNot(equals(tonalColors.first)));
    },
  );
}

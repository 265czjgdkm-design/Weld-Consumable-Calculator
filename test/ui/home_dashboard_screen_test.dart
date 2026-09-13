import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/app.dart';
import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/ui/account_screen.dart';
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

/// Resolves the actual painted [BoxDecoration] of the square dashboard
/// tile's own [Container] for a given label -- the same "painted decoration
/// readback" technique the reviewer used to catch Finding 1 in the first
/// place, so a regression here would be caught the same way it was found.
/// `_DashboardTile` paints its `Container` directly around the tile
/// content, so the closest `Container` ancestor of the label is the tile's
/// own, not an ambient one further up the tree.
BoxDecoration _tileDecoration(WidgetTester tester, String label) {
  final containerFinder = find.ancestor(
    of: find.text(label),
    matching: find.byType(Container),
  );
  return tester.widget<Container>(containerFinder.first).decoration
      as BoxDecoration;
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
    'the 3 calculator (primary) tiles, the AI assistant (accent) tile, and '
    'the 4 neutral tiles render with genuinely different decorations '
    '(reviewer Finding 1: the app-wide filledButtonTheme used to intercept '
    "FilledButton.tonalIcon's own default color before it was ever reached "
    '-- this is the same "shared-look regression" check, updated for the '
    'square-tile redesign)',
    (tester) async {
      await _gotoDashboard(tester);

      final primaryGradients = [
        _tileDecoration(tester, strings.dashboardFillerConsumption).gradient,
        _tileDecoration(tester, strings.dashboardPreheatCalculator).gradient,
        _tileDecoration(
          tester,
          strings.dashboardCoolingTimeCalculator,
        ).gradient,
      ];
      final accentDecoration = _tileDecoration(
        tester,
        strings.dashboardAiAssistant,
      );
      final neutralColors = [
        _tileDecoration(tester, strings.dashboardBaseMaterial).color,
        _tileDecoration(tester, strings.dashboardFillerMaterial).color,
        _tileDecoration(tester, strings.dashboardSavedCalculations).color,
        _tileDecoration(tester, strings.dashboardSavedReports).color,
      ];

      // The 3 calculator tiles all share the same gradient...
      expect(primaryGradients.toSet(), hasLength(1));
      // ...the 4 neutral tiles all share the same (non-null) solid color...
      expect(neutralColors.toSet(), hasLength(1));
      expect(neutralColors.first, isNotNull);
      // ...the AI assistant tile shares the calculators' dark gradient (same
      // brand surface) but is NOT just another plain calculator tile: it
      // carries its own distinct border/glow the calculators don't have.
      expect(accentDecoration.gradient, equals(primaryGradients.first));
      expect(accentDecoration.border, isNotNull);
      expect(
        _tileDecoration(
          tester,
          strings.dashboardFillerConsumption,
        ).border,
        isNull,
      );
      // ...and the primary/accent dark surfaces are genuinely different from
      // the neutral tiles' solid white, not both silently resolved to the
      // same app-wide theme color.
      expect(primaryGradients.first, isNotNull);
    },
  );

  testWidgets('account entry card shows Guest when signed out, and '
      'navigates to AccountScreen on tap', (tester) async {
    await _gotoDashboard(tester);

    expect(find.text(strings.dashboardAccountCardGuestValue), findsOneWidget);

    await tester.tap(find.text(strings.dashboardAccountCardGuestValue));
    await tester.pumpAndSettle();
    expect(find.byType(AccountScreen), findsOneWidget);
  });

  testWidgets('account entry card shows the signed-in email instead of '
      'Guest', (tester) async {
    SharedPreferences.setMockInitialValues({
      'signup_gate_resolved_v1': true,
      'app_language_code': AppLanguage.en.code,
      'user_account_email_v1': 'user@example.com',
    });
    await tester.pumpWidget(const WeldConsumableCalculatorApp());
    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pumpAndSettle();
    expect(find.byType(HomeDashboardScreen), findsOneWidget);

    expect(find.text('user@example.com'), findsOneWidget);
    expect(find.text(strings.dashboardAccountCardGuestValue), findsNothing);
  });
}

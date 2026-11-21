import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/models/consumable_selection.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/ui/calculator_page/calculator_page_widgets.dart';

WeldCalculationResult _result(List<WeldWarning> warnings) =>
    WeldCalculationResult(
      areaMm2: 100,
      lengthMm: 1000,
      volumeCm3: 100,
      weldMetalKg: 0.785,
      fillerKg: 1,
      arcTimeHours: 0.5,
      depositionEfficiency: 0.8,
      depositionRateKgPerHour: 1.57,
      processBreakdowns: const [],
      warnings: warnings,
    );

Future<void> _pump(WidgetTester tester, WeldCalculationResult r) async {
  SharedPreferences.setMockInitialValues({});
  final locale = AppLocale();
  await locale.setLanguage(AppLanguage.tr);
  await tester.pumpWidget(
    MaterialApp(
      home: AppLocaleScope(
        locale: locale,
        child: Scaffold(
          body: SingleChildScrollView(
            child: ResultsSection(
              result: r,
              basis: const [],
              consumableSelection: const BuiltInConsumableSelection(
                ConsumablePreset.e7018,
              ),
              onPdfPressed: () {},
              pdfBusy: false,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('a result warning stays on screen as a box with its text', (
    tester,
  ) async {
    await _pump(tester, _result([WeldWarning.doubleVPipeNoInternalAccess]));
    expect(find.byKey(const ValueKey('result-warning-box')), findsOneWidget);
    expect(
      find.text(stringsFor(AppLanguage.tr).warningDoubleVPipeNoInternalAccess),
      findsOneWidget,
    );
  });

  testWidgets('no warning, no box', (tester) async {
    await _pump(tester, _result(const []));
    expect(find.byKey(const ValueKey('result-warning-box')), findsNothing);
  });
}

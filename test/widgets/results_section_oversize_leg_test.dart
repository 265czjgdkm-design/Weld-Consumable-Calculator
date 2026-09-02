// Regression test for a display-only parse bug: ResultsSection's
// `_basisNumber` used to re-parse the leg-size basis text with a regex
// that stopped dead at a comma decimal separator (e.g. TR locale's
// "8,5 mm"), silently reading it as "8" and computing the wrong
// oversize-leg percentage (~56.3% instead of the correct ~38.4% for an
// 8.5mm leg) even though the underlying calculation itself was correct.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/models/consumable_selection.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/ui/calculator_page/calculator_page_models.dart';
import 'package:weld_consumable_calculator/ui/calculator_page/calculator_page_widgets.dart';

const _result = WeldCalculationResult(
  areaMm2: 36.125,
  lengthMm: 1000,
  volumeCm3: 361.25,
  weldMetalKg: 2.83,
  fillerKg: 3.54,
  arcTimeHours: 1,
  depositionEfficiency: 0.8,
  depositionRateKgPerHour: 1,
  processBreakdowns: [],
);

void main() {
  testWidgets(
    'TR locale: comma-decimal fillet leg size (8,5) yields ~38.4% oversize, not ~56.3%',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final locale = AppLocale();
      await locale.setLanguage(AppLanguage.tr);

      final basis = [
        const CalculationBasisItem(
          BasisKey.filletLegSize,
          'Fillet Leg Size',
          '8,5 mm',
        ),
        const CalculationBasisItem(BasisKey.quantity, 'Quantity', '1'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: AppLocaleScope(
            locale: locale,
            child: Scaffold(
              body: SingleChildScrollView(
                child: ResultsSection(
                  result: _result,
                  basis: basis,
                  consumableSelection: const BuiltInConsumableSelection(
                    ConsumablePreset.er70s6,
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

      expect(find.textContaining('38.4'), findsOneWidget);
      expect(find.textContaining('56.3'), findsNothing);
    },
  );
}

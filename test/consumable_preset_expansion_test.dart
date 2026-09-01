import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/app.dart';
import 'package:weld_consumable_calculator/core/welding_defaults.dart';
import 'package:weld_consumable_calculator/models/consumable_selection.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/weld_pdf_report_service.dart';

Future<void> _pumpPastSplash(WidgetTester tester) async {
  await tester.pumpWidget(const WeldConsumableCalculatorApp());
  await tester.tap(find.byType(GestureDetector).first);
  await tester.pumpAndSettle();

  final guestButton = find.text('Continue as guest');
  if (guestButton.evaluate().isNotEmpty) {
    await tester.tap(guestButton);
    await tester.pumpAndSettle();
  }

  final fillerConsumptionButton = find.text('Filler Material Consumption');
  if (fillerConsumptionButton.evaluate().isNotEmpty) {
    await tester.tap(fillerConsumptionButton);
    await tester.pumpAndSettle();
  }
}

Future<void> _pumpPastIntro(WidgetTester tester) async {
  await _pumpPastSplash(tester);
  await tester.ensureVisible(find.text('Get Started'));
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();
}

Future<void> _continueWizardStep(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Continue'));
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('new low-alloy steel entries are wired into SMAW filtering', () {
    final smawConsumables = WeldingDefaults.consumablesFor(WeldingProcess.smaw);
    expect(smawConsumables, contains(ConsumablePreset.e7018a1));
    expect(smawConsumables, contains(ConsumablePreset.e8018c3));
    expect(ConsumablePreset.e7018a1.family, ConsumableFamily.lowAlloySteel);
  });

  const newPresets = [
    ConsumablePreset.e6013,
    ConsumablePreset.e7024,
    ConsumablePreset.er70s3,
    ConsumablePreset.e7018a1,
    ConsumablePreset.e8018c3,
    ConsumablePreset.er80sNi1,
    ConsumablePreset.er80sB2,
    ConsumablePreset.e316l16,
    ConsumablePreset.er347,
    ConsumablePreset.er4043,
    ConsumablePreset.er5183,
    ConsumablePreset.eniCi,
    ConsumablePreset.enifeCi,
    ConsumablePreset.ernicr3,
    ConsumablePreset.enicrfe3,
    ConsumablePreset.ercusiA,
    ConsumablePreset.ecualA2,
  ];

  for (final preset in newPresets) {
    test('${preset.name} has valid catalog data', () {
      expect(preset.label, isNotEmpty);
      expect(preset.awsSpecification, isNotEmpty);
      expect(preset.typicalBaseMetals, isNotEmpty);
      expect(preset.description, isNotEmpty);
      expect(preset.densityGPerCm3, greaterThan(0));
      expect(preset.densityGPerCm3, lessThan(20));
      expect(preset.supportedProcesses, isNotEmpty);
    });
  }

  testWidgets('new consumable entry appears in the SMAW dropdown and selects '
      'without crashing', (tester) async {
    await _pumpPastIntro(tester);

    await tester.ensureVisible(find.text('SMAW'));
    await tester.tap(find.text('SMAW'));
    await tester.pumpAndSettle();

    await _continueWizardStep(tester); // process -> dimensions
    await _continueWizardStep(tester); // dimensions -> consumable

    expect(find.text('Consumable Classification'), findsOneWidget);

    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<ConsumableSelection>,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(ConsumablePreset.e7018a1.awsDisplayLabel), findsWidgets);

    await tester.tap(find.text(ConsumablePreset.e7018a1.awsDisplayLabel).last);
    await tester.pumpAndSettle();

    expect(find.textContaining('Low Alloy Steel'), findsWidgets);
  });

  test(
    'PDF report generates successfully with a new consumable preset',
    () async {
      const result = WeldCalculationResult(
        areaMm2: 120,
        lengthMm: 1000,
        volumeCm3: 12,
        weldMetalKg: 0.094,
        fillerKg: 0.11,
        arcTimeHours: 0.4,
        depositionEfficiency: 0.65,
        depositionRateKgPerHour: 1.2,
        processBreakdowns: [
          ProcessBreakdown(
            process: WeldingProcess.smaw,
            weldMetalKg: 0.094,
            fillerKg: 0.11,
            arcTimeHours: 0.4,
            depositionEfficiency: 0.65,
            depositionRateKgPerHour: 1.2,
            sharePercent: 100,
          ),
        ],
      );

      const service = WeldPdfReportService();
      final bytes = await service.buildReportBytes(
        jointType: JointType.plateButt,
        grooveType: GrooveType.doubleV,
        weldingProcess: WeldingProcess.smaw,
        consumableSelection: const BuiltInConsumableSelection(
          ConsumablePreset.e7018a1,
        ),
        result: result,
        basisEntries: const [MapEntry('Density', '7.85 g/cm3')],
      );

      expect(bytes, isNotEmpty);
    },
  );
}

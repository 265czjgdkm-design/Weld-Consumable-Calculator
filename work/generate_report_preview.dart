import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:weld_consumable_calculator/core/weld_calculator.dart';
import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/models/consumable_selection.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/weld_pdf_report_service.dart';
import 'package:weld_consumable_calculator/ui/calculator_page/calculator_page_models.dart';

Future<void> main() async {
  // buildReportBytes now loads bundled fonts via rootBundle, which requires
  // a Flutter binding -- this script is invoked with `flutter test
  // work/generate_report_preview.dart` rather than plain `dart run` for
  // that reason.
  TestWidgetsFlutterBinding.ensureInitialized();
  const calculator = WeldCalculator();
  const reportService = WeldPdfReportService();

  const input = WeldInputData(
    jointType: JointType.pipeButt,
    grooveType: GrooveType.doubleV,
    weldingProcess: WeldingProcess.gtawSmaw,
    depositionRateMode: DepositionRateMode.preset,
    quantity: 4,
    densityGPerCm3: 7.85,
    wasteFactorPercent: 10,
    pipeOdMm: 323.9,
    thicknessMm: 16,
    rootGapMm: 3,
    rootFaceMm: 2,
    bevelAngleDeg: 30,
    gtawTransitionMm: 4,
    gtawWireDiameterMm: 2.4,
    smawElectrodeDiameterMm: 4.0,
  );

  final result = calculator.calculate(input);
  final bytes = await reportService.buildReportBytes(
    jointType: JointType.pipeButt,
    grooveType: GrooveType.doubleV,
    weldingProcess: WeldingProcess.gtawSmaw,
    consumableSelection: const BuiltInConsumableSelection(
      ConsumablePreset.gtawRootSmawFill,
    ),
    result: result,
    basisEntries: const [
      CalculationBasisItem(BasisKey.process, 'Process', 'GTAW + SMAW'),
      CalculationBasisItem(BasisKey.rateBasis, 'Rate Basis', 'Estimated'),
      CalculationBasisItem(BasisKey.joint, 'Joint', 'Pipe Butt Weld'),
      CalculationBasisItem(BasisKey.geometry, 'Geometry', 'Equal'),
      CalculationBasisItem(BasisKey.groove, 'Groove', 'Double V'),
      CalculationBasisItem(
        BasisKey.classification,
        'Classification',
        'AWS A5.18 + AWS A5.1 ER70S-2 + E7018',
      ),
      CalculationBasisItem(
        BasisKey.fillerMetalFamily,
        'Filler Metal Family',
        'Carbon Steel',
      ),
      CalculationBasisItem(BasisKey.density, 'Density', '7.85 g/cm3'),
      CalculationBasisItem(BasisKey.wasteAllowance, 'Waste Allowance', '10%'),
      CalculationBasisItem(BasisKey.quantity, 'Quantity', '4'),
      CalculationBasisItem(BasisKey.pipeOd, 'Pipe OD', '323.9 mm'),
      CalculationBasisItem(BasisKey.thickness, 'Thickness', '16 mm'),
      CalculationBasisItem(BasisKey.rootGap, 'Root Gap', '3 mm'),
      CalculationBasisItem(
        BasisKey.rootFacePerSide,
        'Root Face per Side',
        '2 mm',
      ),
      CalculationBasisItem(BasisKey.bevelAngle, 'Bevel Angle', '30 deg'),
      CalculationBasisItem(
        BasisKey.gtawTransitionDepth,
        'GTAW Transition Depth',
        '4 mm',
      ),
      CalculationBasisItem(
        BasisKey.gtawWireDiameter,
        'GTAW Wire Diameter',
        '2.4 mm',
      ),
      CalculationBasisItem(
        BasisKey.smawElectrodeDiameter,
        'SMAW Electrode Diameter',
        '4.0 mm',
      ),
    ],
    strings: stringsFor(AppLanguage.en),
  );

  final outputDir = Directory(
    '/Users/muhammetyigit/Documents/Codex/2026-06-30/bu-projede-benim-yerime-geli-tirici/work/tmp/pdfs',
  );
  await outputDir.create(recursive: true);
  final file = File('${outputDir.path}/report_preview.pdf');
  await file.writeAsBytes(bytes, flush: true);
  stdout.writeln(file.path);
}

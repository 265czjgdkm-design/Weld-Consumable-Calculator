import 'dart:io';

import 'package:weld_consumable_calculator/core/weld_calculator.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/weld_pdf_report_service.dart';

Future<void> main() async {
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
    consumablePreset: ConsumablePreset.gtawRootSmawFill,
    result: result,
    basisEntries: const [
      MapEntry('Process', 'GTAW + SMAW'),
      MapEntry('Rate Basis', 'Estimated'),
      MapEntry('Joint', 'Pipe Butt Weld'),
      MapEntry('Geometry', 'Equal'),
      MapEntry('Groove', 'Double V'),
      MapEntry('Classification', 'AWS A5.18 + AWS A5.1 ER70S-2 + E7018'),
      MapEntry('Filler Metal Family', 'Carbon Steel'),
      MapEntry('Density', '7.85 g/cm3'),
      MapEntry('Waste Allowance', '10%'),
      MapEntry('Quantity', '4'),
      MapEntry('Pipe OD', '323.9 mm'),
      MapEntry('Thickness', '16 mm'),
      MapEntry('Root Gap', '3 mm'),
      MapEntry('Root Face per Side', '2 mm'),
      MapEntry('Bevel Angle', '30 deg'),
      MapEntry('GTAW Transition Depth', '4 mm'),
      MapEntry('GTAW Wire Diameter', '2.4 mm'),
      MapEntry('SMAW Electrode Diameter', '4.0 mm'),
    ],
  );

  final outputDir = Directory(
    '/Users/muhammetyigit/Documents/Codex/2026-06-30/bu-projede-benim-yerime-geli-tirici/work/tmp/pdfs',
  );
  await outputDir.create(recursive: true);
  final file = File('${outputDir.path}/report_preview.pdf');
  await file.writeAsBytes(bytes, flush: true);
  stdout.writeln(file.path);
}

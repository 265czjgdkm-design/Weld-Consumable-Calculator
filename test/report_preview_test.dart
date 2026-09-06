import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:weld_consumable_calculator/core/weld_calculator.dart';
import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/models/consumable_selection.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/weld_pdf_report_service.dart';
import 'package:weld_consumable_calculator/ui/calculator_page/calculator_page_models.dart';

final _en = stringsFor(AppLanguage.en);

WeldInputData _pipeButtInput() => const WeldInputData(
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

List<CalculationBasisItem> _pipeButtBasisEntries() => const [
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
  CalculationBasisItem(BasisKey.rootFacePerSide, 'Root Face per Side', '2 mm'),
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
];

Future<Uint8List> _buildBytes(L10nStrings strings) async {
  const calculator = WeldCalculator();
  const reportService = WeldPdfReportService();
  final result = calculator.calculate(_pipeButtInput());
  return reportService.buildReportBytes(
    jointType: JointType.pipeButt,
    grooveType: GrooveType.doubleV,
    weldingProcess: WeldingProcess.gtawSmaw,
    consumableSelection: const BuiltInConsumableSelection(
      ConsumablePreset.gtawRootSmawFill,
    ),
    result: result,
    basisEntries: _pipeButtBasisEntries(),
    strings: strings,
  );
}

void main() {
  // buildReportBytes loads bundled fonts via rootBundle, which needs a
  // Flutter binding even for these non-widget tests.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generate report preview pdf', () async {
    const calculator = WeldCalculator();
    const reportService = WeldPdfReportService();

    final result = calculator.calculate(_pipeButtInput());
    final bytes = await reportService.buildReportBytes(
      jointType: JointType.pipeButt,
      grooveType: GrooveType.doubleV,
      weldingProcess: WeldingProcess.gtawSmaw,
      consumableSelection: const BuiltInConsumableSelection(
        ConsumablePreset.gtawRootSmawFill,
      ),
      result: result,
      basisEntries: _pipeButtBasisEntries(),
      strings: _en,
    );

    final outputDir = await Directory.systemTemp.createTemp(
      'weld_report_preview_',
    );
    addTearDown(() => outputDir.delete(recursive: true));
    final file = File('${outputDir.path}/report_preview.pdf');
    await file.writeAsBytes(bytes, flush: true);
    expect(await file.exists(), isTrue);
  });

  test('a non-English locale produces different rendered PDF content than '
      'English (proves the new pdfXxx strings are actually wired through, '
      'not just added to strings.dart)', () async {
    final enBytes = await _buildBytes(_en);
    final deBytes = await _buildBytes(stringsFor(AppLanguage.de));
    final ruBytes = await _buildBytes(stringsFor(AppLanguage.ru));

    expect(deBytes, isNot(equals(enBytes)));
    expect(ruBytes, isNot(equals(enBytes)));
  });

  test(
    'Russian and Hindi report text renders via the bundled Noto fonts '
    "instead of falling back to a glyph-less/tofu state (the pdf package's "
    'own font resolution prints "Unable to find a font to draw" for every '
    'rune it cannot render, so its absence here proves every Cyrillic and '
    'Devanagari character in these reports actually resolved to a glyph)',
    () async {
      final messages = <String>[];
      await runZoned(
        () async {
          await _buildBytes(stringsFor(AppLanguage.ru));
          await _buildBytes(stringsFor(AppLanguage.hi));
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) => messages.add(line),
        ),
      );

      final missingGlyphWarnings = messages
          .where((line) => line.contains('Unable to find a font to draw'))
          .toList();
      expect(
        missingGlyphWarnings,
        isEmpty,
        reason:
            'expected the bundled Noto Sans / Noto Sans Devanagari fonts to '
            'cover every rune in the Russian and Hindi reports, but got: '
            '${missingGlyphWarnings.join(', ')}',
      );
    },
  );
}

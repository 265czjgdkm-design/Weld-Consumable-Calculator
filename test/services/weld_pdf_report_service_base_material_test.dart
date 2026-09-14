import 'package:flutter_test/flutter_test.dart';
import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/models/consumable_selection.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/weld_pdf_report_service.dart';
import 'package:weld_consumable_calculator/ui/calculator_page/calculator_page_models.dart';

final _strings = stringsFor(AppLanguage.en);

const _result = WeldCalculationResult(
  areaMm2: 30,
  lengthMm: 1000,
  volumeCm3: 30,
  weldMetalKg: 0.24,
  fillerKg: 0.3,
  arcTimeHours: 0.2,
  depositionEfficiency: 0.9,
  depositionRateKgPerHour: 1.2,
  processBreakdowns: [
    ProcessBreakdown(
      process: WeldingProcess.gtaw,
      weldMetalKg: 0.24,
      fillerKg: 0.3,
      arcTimeHours: 0.2,
      depositionEfficiency: 0.9,
      depositionRateKgPerHour: 1.2,
      sharePercent: 1,
    ),
  ],
);

Future<int> _buildReportLength(List<CalculationBasisItem> basisEntries) async {
  const service = WeldPdfReportService();
  final bytes = await service.buildReportBytes(
    jointType: JointType.plateButt,
    grooveType: GrooveType.singleV,
    weldingProcess: WeldingProcess.gtaw,
    consumableSelection: const BuiltInConsumableSelection(
      ConsumablePreset.er70s2,
    ),
    result: _result,
    basisEntries: basisEntries,
    strings: _strings,
  );
  return bytes.length;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mirrors the cap-overlap/cap-height PDF regression guard: a new BasisKey
  // that isn't added to one of _groupBasisEntries's ordering allowlists in
  // weld_pdf_report_service.dart is silently dropped from the PDF.
  test(
    'a Base Material basis entry actually changes the rendered PDF (proving '
    'it is not silently dropped from the basis/summary section)',
    () async {
      final baseEntries = [
        const CalculationBasisItem(BasisKey.process, 'Process', 'GTAW'),
        const CalculationBasisItem(BasisKey.joint, 'Joint', 'Plate Butt'),
        const CalculationBasisItem(BasisKey.groove, 'Groove', 'Single V'),
        const CalculationBasisItem(BasisKey.thickness, 'Thickness', '12 mm'),
      ];
      final withBaseMaterial = [
        ...baseEntries,
        const CalculationBasisItem(
          BasisKey.baseMaterial,
          'Base Material',
          'Acme S355 (S355J2)',
        ),
      ];

      final baseLength = await _buildReportLength(baseEntries);
      final withBaseMaterialLength = await _buildReportLength(
        withBaseMaterial,
      );

      expect(
        withBaseMaterialLength,
        greaterThan(baseLength),
        reason:
            'adding a Base Material basis entry should add visible content '
            'to the PDF, not be silently dropped',
      );
    },
  );
}

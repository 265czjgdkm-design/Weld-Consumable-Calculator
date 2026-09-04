import 'package:flutter_test/flutter_test.dart';
import 'package:weld_consumable_calculator/models/consumable_selection.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/weld_pdf_report_service.dart';

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

Future<int> _buildReportLength(
  List<MapEntry<String, String>> basisEntries,
) async {
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
  );
  return bytes.length;
}

void main() {
  // Regression guard for a real bug found while implementing the cap
  // overlap/height feature: _groupBasisEntries in weld_pdf_report_service.dart
  // only renders basis entries whose label is in one of its hardcoded
  // setup/geometry/process allowlists - a new basis entry key that isn't
  // added there is silently dropped from the PDF (not an error, just never
  // rendered), which is exactly what would have happened to "Cap Overlap
  // (each edge)"/"Cap Height" without adding them to `geometryOrder`.
  test(
    'Cap Overlap/Cap Height basis entries actually change the rendered PDF '
    '(proving they are not silently dropped like an unlisted label would be)',
    () async {
      final baseEntries = [
        const MapEntry('Process', 'GTAW'),
        const MapEntry('Joint', 'Plate Butt'),
        const MapEntry('Groove', 'Single V'),
        const MapEntry('Thickness', '12 mm'),
        const MapEntry('Root Gap', '3 mm'),
      ];
      final withCapEntries = [
        ...baseEntries,
        const MapEntry('Cap Overlap (each edge)', '2 mm'),
        const MapEntry('Cap Height', '3 mm'),
      ];

      final baseLength = await _buildReportLength(baseEntries);
      final withCapLength = await _buildReportLength(withCapEntries);

      expect(
        withCapLength,
        greaterThan(baseLength),
        reason:
            'adding Cap Overlap/Cap Height basis entries should add visible '
            'content to the PDF, not be silently dropped',
      );
    },
  );

  test(
    'an unlisted basis label now fails loudly in debug/test mode (Finding '
    '5 safety net) instead of silently vanishing from the PDF with no '
    'error - the never-taken "Other" catch-all section below this '
    'assertion is the release-mode fallback for the same case',
    () async {
      final withUnlistedEntry = [
        const MapEntry('Process', 'GTAW'),
        const MapEntry('Totally Unlisted Label', 'some value'),
      ];

      await expectLater(
        _buildReportLength(withUnlistedEntry),
        throwsA(isA<AssertionError>()),
      );
    },
  );
}

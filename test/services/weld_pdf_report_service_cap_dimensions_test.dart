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
  // buildReportBytes loads bundled fonts via rootBundle, which needs a
  // Flutter binding even for these non-widget tests.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Regression guard for a real bug found while implementing the cap
  // overlap/height feature: _groupBasisEntries in weld_pdf_report_service.dart
  // only renders basis entries whose key is in one of its hardcoded
  // setup/geometry/process allowlists - a new basis entry key that isn't
  // added there is silently dropped from the PDF (not an error, just never
  // rendered), which is exactly what would have happened to
  // BasisKey.capOverlap/BasisKey.capHeight without adding them to
  // `geometryOrder`.
  test(
    'Cap Overlap/Cap Height basis entries actually change the rendered PDF '
    '(proving they are not silently dropped like an unlisted key would be)',
    () async {
      final baseEntries = [
        const CalculationBasisItem(BasisKey.process, 'Process', 'GTAW'),
        const CalculationBasisItem(BasisKey.joint, 'Joint', 'Plate Butt'),
        const CalculationBasisItem(BasisKey.groove, 'Groove', 'Single V'),
        const CalculationBasisItem(BasisKey.thickness, 'Thickness', '12 mm'),
        const CalculationBasisItem(BasisKey.rootGap, 'Root Gap', '3 mm'),
      ];
      final withCapEntries = [
        ...baseEntries,
        const CalculationBasisItem(
          BasisKey.capOverlap,
          'Cap Overlap (each edge)',
          '2 mm',
        ),
        const CalculationBasisItem(BasisKey.capHeight, 'Cap Height', '3 mm'),
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

  // BasisKey is now a closed enum (see calculator_page_models.dart), so a
  // typo'd or otherwise-unlisted *string* label can no longer reach
  // _groupBasisEntries at all -- the type system rules that out. The
  // remaining real failure mode is a *new* BasisKey member added to the enum
  // without also adding it to one of setupOrder/geometryOrder/processOrder
  // in weld_pdf_report_service.dart (a plain `List<BasisKey>` literal, which
  // the analyzer does not check for exhaustiveness the way it would a
  // switch). This test exercises every current BasisKey value at once, so
  // it fails loudly (via the debug-mode assert) the moment a future key is
  // forgotten from the ordering lists, instead of only being caught if
  // someone happens to also update this test by hand.
  test(
    'every BasisKey value is claimed by one of the PDF ordering allowlists '
    '(regression guard: a forgotten future key fails loudly here instead of '
    'silently vanishing from the PDF)',
    () async {
      final allKeyEntries = [
        for (final key in BasisKey.values)
          CalculationBasisItem(key, key.name, 'value'),
      ];

      await expectLater(_buildReportLength(allKeyEntries), completes);
    },
  );
}

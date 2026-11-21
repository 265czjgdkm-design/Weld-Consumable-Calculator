import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weld_consumable_calculator/core/weld_calculator.dart';
import 'package:weld_consumable_calculator/core/weld_formulas.dart';
import 'package:weld_consumable_calculator/core/welding_defaults.dart';
import 'package:weld_consumable_calculator/data/consumable_catalog.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/ui/widgets/weld_drawing_preview.dart';

const calc = WeldCalculator();

WeldInputData _combo(WeldingProcess p, {double? wire, double? electrode}) =>
    WeldInputData(
      jointType: JointType.plateButt,
      grooveType: GrooveType.singleV,
      weldingProcess: p,
      depositionRateMode: DepositionRateMode.preset,
      quantity: 1,
      lengthPerPieceMm: 1000,
      thicknessMm: 12,
      rootFaceMm: 2,
      rootGapMm: 3,
      bevelAngleDeg: 30,
      gtawTransitionMm: 3,
      gtawWireDiameterMm: 2.4,
      wireDiameterMm: wire,
      smawElectrodeDiameterMm: electrode,
      densityGPerCm3: WeldingDefaults.densityGPerCm3,
      wasteFactorPercent: WeldingDefaults.wasteFactorPercent,
    );

void main() {
  group('GTAW root + FCAW / GMAW fill', () {
    for (final (p, fill, rate) in [
      (WeldingProcess.gtawFcaw, WeldingProcess.fcaw, 3.4),
      (WeldingProcess.gtawGmaw, WeldingProcess.gmaw, 3.5),
    ]) {
      test('${p.label}: GTAW root share + ${fill.label} fill at its own '
          'efficiency and wire rate', () {
        final smaw = calc.calculate(
          _combo(WeldingProcess.gtawSmaw, electrode: 3.2),
        );
        final r = calc.calculate(_combo(p, wire: 1.2));
        final g = r.processBreakdowns.firstWhere(
          (b) => b.process == WeldingProcess.gtaw,
        );
        final f = r.processBreakdowns.firstWhere((b) => b.process == fill);
        // Same geometry -> same GTAW root metal as GTAW+SMAW.
        final gs = smaw.processBreakdowns.firstWhere(
          (b) => b.process == WeldingProcess.gtaw,
        );
        expect(g.weldMetalKg, closeTo(gs.weldMetalKg, 1e-9));
        expect(f.depositionEfficiency, WeldingDefaults.efficiencyFor(fill));
        expect(f.depositionRateKgPerHour, rate);
        expect(g.weldMetalKg + f.weldMetalKg, closeTo(r.weldMetalKg, 1e-9));
      });
    }

    test('fill-process consumables are offered, SMAW electrodes are not', () {
      final gmaw = WeldingDefaults.consumablesFor(WeldingProcess.gtawGmaw);
      expect(gmaw, contains(ConsumablePreset.er70s6));
      expect(gmaw, isNot(contains(ConsumablePreset.e7018)));
      final fcaw = WeldingDefaults.consumablesFor(WeldingProcess.gtawFcaw);
      expect(fcaw, contains(ConsumablePreset.e71t1));
      expect(ConsumableCatalog.forProcess(WeldingProcess.gtawFcaw), isNotEmpty);
    });
  });

  group('unequal thickness (thicker member tapered to the thinner)', () {
    test('groove is sized on the thinner wall, OD of the thinner member', () {
      expect(WeldFormulas.governingThicknessMm(12, 8), 8);
      expect(WeldFormulas.governingThicknessMm(null, 8), 8);
      expect(
        WeldFormulas.governingPipeOdMm(
          thicknessAMm: 12,
          thicknessBMm: 8,
          odAMm: 219.1,
          odBMm: 210,
        ),
        210,
      );
      expect(
        WeldFormulas.governingPipeOdMm(
          thicknessAMm: 8,
          thicknessBMm: 8,
          odAMm: 219.1,
          odBMm: 210,
        ),
        219.1,
      );
    });

    test('drawing: thicker plate gets a 1:4 taper, weld spans the thinner '
        'wall only', () {
      final scene = buildWeldDrawingScene(
        grooveType: GrooveType.singleV,
        jointType: JointType.plateButt,
        data: const WeldDrawingData(
          weldingProcess: WeldingProcess.smaw,
          geometryMode: JointGeometryMode.unequal,
          alignment: JointAlignment.centerline,
          thicknessAMm: 20,
          thicknessBMm: 10,
          rootGapMm: 3,
          rootFaceMm: 2,
          bevelAngleDeg: 30,
        ),
        size: const Size(390, 400),
        smawFillCapLabel: 'SMAW',
        gtawRootLabel: 'GTAW',
        capTopLabel: 'Top',
        capBottomLabel: 'Bottom',
        capOverlapValueLabel: 'mm',
        capHeightValueLabel: 'mm',
      );
      final thick = scene.plates.first.getBounds();
      final thin = scene.plates.last.getBounds();
      final weld = scene.weld.getBounds();
      expect(thin.height, closeTo(thick.height / 2, 1));
      // Weld sits on the thin wall (bounds include the cap/root Bezier
      // control points, hence the margin) and is centred on it, well
      // short of the thick plate's full height.
      // (cap rise above > root rise below, so a few px off centre)
      expect(weld.center.dy, closeTo(thin.center.dy, 8));
      expect(weld.height, lessThan(thick.height * 0.8));
    });
  });

  group('Double V on pipe', () {
    WeldInputData pipe(double od) => WeldInputData(
      jointType: JointType.pipeButt,
      grooveType: GrooveType.doubleV,
      weldingProcess: WeldingProcess.smaw,
      depositionRateMode: DepositionRateMode.preset,
      quantity: 1,
      pipeOdMm: od,
      thicknessMm: 16,
      rootFaceMm: 2,
      rootGapMm: 3,
      bevelAngleDeg: 30,
      densityGPerCm3: WeldingDefaults.densityGPerCm3,
      wasteFactorPercent: WeldingDefaults.wasteFactorPercent,
    );

    test('warns when the bore is too small to weld from inside', () {
      expect(calc.calculate(pipe(323.9)).warnings, [
        WeldWarning.doubleVPipeNoInternalAccess,
      ]);
      expect(calc.calculate(pipe(914)).warnings, isEmpty);
    });

    test('symmetric Double V girth length runs through mid-wall', () {
      // Symmetric groove, no caps: centroid exactly at t/2.
      final r = calc.calculate(pipe(914));
      expect(r.lengthMm, closeTo(3.141592653589793 * (914 - 16), 0.05));
    });
  });

  test('every built-in starter template calculates without errors or '
      'warnings', () {
    for (final preset in InputPreset.values) {
      final d = preset.data;
      if (d == null) continue;
      final r = calc.calculate(
        WeldInputData(
          jointType: d.jointType,
          grooveType: d.grooveType,
          weldingProcess: d.weldingProcess,
          depositionRateMode: d.depositionRateMode,
          quantity: d.quantity,
          lengthPerPieceMm: d.lengthPerPieceMm ?? 1000,
          pipeOdMm: d.pipeOdMm,
          thicknessMm: d.thicknessMm,
          rootGapMm: d.rootGapMm,
          rootFaceMm: d.rootFaceMm,
          bevelAngleDeg: d.bevelAngleDeg,
          secondaryBevelAngleDeg: d.secondaryBevelAngleDeg,
          breakHeightMm: d.breakHeightMm,
          capOverlapMm: d.capOverlapMm,
          capHeightMm: d.capHeightMm,
          backGougeDepthMm: d.backGougeDepthMm,
          legSizeMm: d.legSizeMm,
          gtawTransitionMm: d.gtawTransitionMm,
          wireDiameterMm: d.wireDiameterMm,
          electrodeDiameterMm: d.electrodeDiameterMm,
          gtawWireDiameterMm: d.gtawWireDiameterMm,
          smawElectrodeDiameterMm: d.smawElectrodeDiameterMm,
          densityGPerCm3: d.densityGPerCm3 ?? 7.85,
          wasteFactorPercent: d.wasteFactorPercent,
        ),
      );
      expect(r.warnings, isEmpty, reason: '$preset');
      expect(r.fillerKg, greaterThan(0), reason: '$preset');
    }
  });

  test('compound V is offered for plate butt and matches the pipe groove '
      'area (same section, straight length)', () {
    expect(
      JointType.plateButt.supportedGrooves,
      contains(GrooveType.compoundV),
    );
    WeldInputData input(JointType j) => WeldInputData(
      jointType: j,
      grooveType: GrooveType.compoundV,
      weldingProcess: WeldingProcess.gtawFcaw,
      depositionRateMode: DepositionRateMode.preset,
      quantity: 1,
      lengthPerPieceMm: 1000,
      pipeOdMm: 610,
      thicknessMm: 40,
      rootFaceMm: 2,
      rootGapMm: 3,
      bevelAngleDeg: 20,
      secondaryBevelAngleDeg: 8,
      breakHeightMm: 10,
      gtawTransitionMm: 4,
      gtawWireDiameterMm: 2.4,
      wireDiameterMm: 1.2,
      densityGPerCm3: 7.85,
      wasteFactorPercent: 10,
    );
    final plate = calc.calculate(input(JointType.plateButt));
    final pipe = calc.calculate(input(JointType.pipeButt));
    expect(plate.areaMm2, closeTo(pipe.areaMm2, 1e-9));
    expect(plate.lengthMm, 1000);
    final scene = buildWeldDrawingScene(
      grooveType: GrooveType.compoundV,
      jointType: JointType.plateButt,
      data: const WeldDrawingData(
        weldingProcess: WeldingProcess.gtawFcaw,
        geometryMode: JointGeometryMode.equal,
        alignment: JointAlignment.centerline,
        thicknessMm: 40,
        rootGapMm: 3,
        rootFaceMm: 2,
        bevelAngleDeg: 20,
        secondaryBevelAngleDeg: 8,
        breakHeightMm: 10,
        gtawTransitionMm: 4,
      ),
      size: const Size(390, 400),
      smawFillCapLabel: 'FCAW',
      gtawRootLabel: 'GTAW',
      capTopLabel: 'Top',
      capBottomLabel: 'Bottom',
      capOverlapValueLabel: 'mm',
      capHeightValueLabel: 'mm',
    );
    expect(
      scene.labels.map((l) => l.text).join(' '),
      allOf(contains('h 10'), contains('β 8')),
    );
  });
}

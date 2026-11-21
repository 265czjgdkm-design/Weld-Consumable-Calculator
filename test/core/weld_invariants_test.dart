// Property / sanity sweep over the whole calculator: every groove, every
// process, a grid of realistic dimensions. Each check is an engineering
// invariant that must hold for ANY input, not a single worked example.
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:weld_consumable_calculator/core/weld_calculator.dart';
import 'package:weld_consumable_calculator/core/weld_formulas.dart';
import 'package:weld_consumable_calculator/core/welding_defaults.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';

const calc = WeldCalculator();

WeldInputData _in({
  JointType joint = JointType.plateButt,
  required GrooveType groove,
  WeldingProcess process = WeldingProcess.smaw,
  double t = 12,
  double c = 2,
  double gap = 3,
  double angle = 30,
  double? transition,
  double? capOv,
  double? capH,
  double? gouge,
  double od = 168.3,
  double leg = 6,
}) => WeldInputData(
  jointType: groove == GrooveType.fillet
      ? JointType.fillet
      : (joint.supportedGrooves.contains(groove) ? joint : JointType.pipeButt),
  grooveType: groove,
  weldingProcess: process,
  depositionRateMode: DepositionRateMode.preset,
  quantity: 1,
  lengthPerPieceMm: 1000,
  pipeOdMm: od,
  thicknessMm: t,
  rootFaceMm: c,
  rootGapMm: gap,
  bevelAngleDeg: angle,
  secondaryBevelAngleDeg: 10,
  breakHeightMm: math.min(4, (t - c) * 0.5),
  capOverlapMm: capOv,
  capHeightMm: capH,
  legSizeMm: leg,
  gtawTransitionMm: transition ?? (process.isCombined ? 3 : null),
  gtawWireDiameterMm: 2.4,
  smawElectrodeDiameterMm: 3.2,
  wireDiameterMm: 1.2,
  backGougeDepthMm: gouge,
  densityGPerCm3: 7.85,
  wasteFactorPercent: 10,
);

const _grooves = [
  GrooveType.square,
  GrooveType.singleV,
  GrooveType.halfV,
  GrooveType.doubleV,
  GrooveType.compoundV,
  GrooveType.fillet,
];

/// Groove width profile, integrated numerically, must reproduce the closed
/// form area (this is what the girth-length centroid relies on).
double _numericArea(GrooveType g, double t, double c, double gap, double a) {
  final tanA = math.tan(a * math.pi / 180);
  final tanB = math.tan(10 * math.pi / 180);
  final brk = math.min(4.0, (t - c) * 0.5);
  double w(double z) {
    final u = t - z;
    switch (g) {
      case GrooveType.singleV:
        return u <= c ? gap : gap + 2 * (u - c) * tanA;
      case GrooveType.halfV:
        return u <= c ? gap : gap + (u - c) * tanA;
      case GrooveType.compoundV:
        if (u <= c) return gap;
        if (u <= c + brk) return gap + 2 * (u - c) * tanA;
        return gap + 2 * brk * tanA + 2 * (u - c - brk) * tanB;
      case GrooveType.doubleV:
        final d = (z - t / 2).abs();
        return d <= c / 2 ? gap : gap + 2 * (d - c / 2) * tanA;
      default:
        return gap;
    }
  }

  const n = 20000;
  var a2 = 0.0;
  for (var i = 0; i < n; i++) {
    a2 += w((i + 0.5) * t / n) * t / n;
  }
  return a2;
}

void main() {
  test('chain: volume = area x length, metal = volume x density, '
      'filler >= metal, every number finite and positive', () {
    var n = 0;
    for (final g in _grooves) {
      for (final p in WeldingProcess.values) {
        for (final t in [6.0, 12.0, 25.0, 60.0]) {
          for (final cap in [null, 2.0]) {
            final r = calc.calculate(
              _in(groove: g, process: p, t: t, capOv: cap, capH: cap),
            );
            n++;
            for (final v in [
              r.areaMm2,
              r.lengthMm,
              r.volumeCm3,
              r.weldMetalKg,
              r.fillerKg,
              r.arcTimeHours,
              r.depositionRateKgPerHour,
            ]) {
              expect(v.isFinite && v > 0, isTrue, reason: '$g $p t$t');
            }
            expect(r.volumeCm3, closeTo(r.areaMm2 * r.lengthMm / 1000, 1e-9));
            expect(r.weldMetalKg, closeTo(r.volumeCm3 * 7.85 / 1000, 1e-9));
            expect(r.fillerKg, greaterThan(r.weldMetalKg));
            expect(r.depositionEfficiency, inInclusiveRange(0.5, 1.0));
            final sumMetal = r.processBreakdowns.fold<double>(
              0,
              (a, b) => a + b.weldMetalKg,
            );
            final sumFiller = r.processBreakdowns.fold<double>(
              0,
              (a, b) => a + b.fillerKg,
            );
            expect(sumMetal, closeTo(r.weldMetalKg, 1e-9));
            expect(sumFiller, closeTo(r.fillerKg, 1e-9));
            // Arc-on time = deposited weld metal / deposition rate, per
            // process segment (AWS A3.0 deposition rate definition).
            final arc = r.processBreakdowns.fold<double>(
              0,
              (a, b) => a + b.weldMetalKg / b.depositionRateKgPerHour,
            );
            expect(r.arcTimeHours, closeTo(arc, 1e-9));
            expect(
              r.depositionRateKgPerHour,
              closeTo(r.weldMetalKg / r.arcTimeHours, 1e-9),
            );
          }
        }
      }
    }
    expect(n, greaterThan(300));
  });

  test('width profiles used for the girth centroid integrate to the exact '
      'closed-form groove areas', () {
    for (final g in [
      GrooveType.square,
      GrooveType.singleV,
      GrooveType.halfV,
      GrooveType.doubleV,
      GrooveType.compoundV,
    ]) {
      for (final (t, c, gap, a) in [
        (12.0, 2.0, 3.0, 30.0),
        (25.0, 3.0, 2.0, 37.5),
        (40.0, 0.0, 0.0, 20.0),
        (8.0, 1.5, 4.0, 45.0),
      ]) {
        final exact = calc
            .calculate(_in(groove: g, t: t, c: c, gap: gap, angle: a))
            .areaMm2;
        expect(
          _numericArea(g, t, c, gap, a),
          closeTo(exact, exact * 1e-4 + 1e-6),
          reason: '$g t$t c$c b$gap a$a',
        );
      }
    }
  });

  test('area grows with thickness, bevel angle and gap; shrinks with root '
      'face', () {
    for (final g in [
      GrooveType.singleV,
      GrooveType.halfV,
      GrooveType.doubleV,
      GrooveType.compoundV,
    ]) {
      double a(WeldInputData i) => calc.calculate(i).areaMm2;
      expect(a(_in(groove: g, t: 20)), greaterThan(a(_in(groove: g, t: 12))));
      expect(
        a(_in(groove: g, angle: 37.5)),
        greaterThan(a(_in(groove: g, angle: 30))),
      );
      expect(a(_in(groove: g, gap: 4)), greaterThan(a(_in(groove: g, gap: 2))));
      expect(a(_in(groove: g, c: 3)), lessThan(a(_in(groove: g, c: 1))));
    }
  });

  group('combined GTAW root + fill', () {
    for (final p in [
      WeldingProcess.gtawSmaw,
      WeldingProcess.gtawFcaw,
      WeldingProcess.gtawGmaw,
    ]) {
      test('${p.label}: GTAW share is 0..groove, monotonic in depth, and '
          'saturates at the full first-side height', () {
        for (final g in _grooves) {
          final full = g == GrooveType.fillet
              ? 6.0
              : g == GrooveType.doubleV
              ? 12 / 2 + 2 / 2
              : 12.0;
          var prev = 0.0;
          for (final d in [0.5, 1.0, 2.0, 3.0, 5.0, full, full + 5]) {
            final r = calc.calculate(_in(groove: g, process: p, transition: d));
            final gt = r.processBreakdowns
                .firstWhere((b) => b.process == WeldingProcess.gtaw)
                .weldMetalKg;
            expect(gt, greaterThanOrEqualTo(prev - 1e-12), reason: '$g d$d');
            expect(gt, lessThanOrEqualTo(r.weldMetalKg + 1e-12));
            prev = gt;
          }
          // Beyond the full height nothing more becomes GTAW.
          final atFull = calc.calculate(
            _in(groove: g, process: p, transition: full),
          );
          final past = calc.calculate(
            _in(groove: g, process: p, transition: full + 5),
          );
          double gtaw(WeldCalculationResult r) => r.processBreakdowns
              .firstWhere((b) => b.process == WeldingProcess.gtaw)
              .weldMetalKg;
          expect(gtaw(past), closeTo(gtaw(atFull), 1e-12), reason: '$g');
        }
      });
    }

    test('Double V at full depth: GTAW = first-side groove + whole land', () {
      final groove = WeldFormulas.doubleVAreaMm2(
        thicknessMm: 12,
        rootFaceMm: 2,
        rootGapMm: 3,
        bevelAngleDeg: 30,
      );
      final gtawArea = WeldFormulas.doubleVPartialAreaFromRootMm2(
        thicknessMm: 12,
        rootFaceMm: 2,
        rootGapMm: 3,
        bevelAngleDeg: 30,
        fillHeightMm: 7,
      );
      // Half the groove (one side incl. half the land) + other half land.
      expect(gtawArea, closeTo(groove / 2 + 3 * 1, 1e-9));
    });

    test('caps and back-gouge never become GTAW', () {
      final base = calc.calculate(
        _in(groove: GrooveType.doubleV, process: WeldingProcess.gtawFcaw),
      );
      final more = calc.calculate(
        _in(
          groove: GrooveType.doubleV,
          process: WeldingProcess.gtawFcaw,
          capOv: 2,
          capH: 2,
          gouge: 4,
        ),
      );
      double gtaw(WeldCalculationResult r) => r.processBreakdowns
          .firstWhere((b) => b.process == WeldingProcess.gtaw)
          .weldMetalKg;
      expect(gtaw(more), closeTo(gtaw(base), 1e-12));
    });
  });

  group('girth weld length', () {
    test('lies between pi*ID and pi*OD without caps; symmetric grooves at '
        'mid-wall; V grooves nearer the OD', () {
      for (final g in [
        GrooveType.square,
        GrooveType.singleV,
        GrooveType.halfV,
        GrooveType.doubleV,
        GrooveType.compoundV,
      ]) {
        for (final t in [6.0, 12.0, 25.0]) {
          final r = calc.calculate(
            _in(joint: JointType.pipeButt, groove: g, t: t, od: 273),
          );
          expect(r.lengthMm, lessThan(math.pi * 273));
          expect(r.lengthMm, greaterThan(math.pi * (273 - 2 * t)));
          final mid = math.pi * (273 - t);
          if (g == GrooveType.square || g == GrooveType.doubleV) {
            expect(r.lengthMm, closeTo(mid, 0.01), reason: '$g t$t');
          } else {
            expect(r.lengthMm, greaterThan(mid), reason: '$g t$t');
          }
        }
      }
    });

    test('quantity scales length linearly; plate length is untouched', () {
      final one = calc.calculate(
        _in(joint: JointType.pipeButt, groove: GrooveType.singleV),
      );
      final i = _in(joint: JointType.pipeButt, groove: GrooveType.singleV);
      final three = calc.calculate(
        WeldInputData(
          jointType: i.jointType,
          grooveType: i.grooveType,
          weldingProcess: i.weldingProcess,
          depositionRateMode: i.depositionRateMode,
          quantity: 3,
          pipeOdMm: i.pipeOdMm,
          thicknessMm: i.thicknessMm,
          rootFaceMm: i.rootFaceMm,
          rootGapMm: i.rootGapMm,
          bevelAngleDeg: i.bevelAngleDeg,
          densityGPerCm3: 7.85,
          wasteFactorPercent: 10,
        ),
      );
      expect(three.lengthMm, closeTo(one.lengthMm * 3, 1e-9));
      expect(calc.calculate(_in(groove: GrooveType.singleV)).lengthMm, 1000);
    });
  });

  group('validation edges', () {
    test('root face must stay below the thickness; angle below 90', () {
      for (final g in [
        GrooveType.singleV,
        GrooveType.halfV,
        GrooveType.doubleV,
        GrooveType.compoundV,
      ]) {
        expect(
          () => calc.calculate(_in(groove: g, t: 10, c: 10)),
          throwsA(isA<InputValidationException>()),
          reason: '$g c=t',
        );
        expect(
          () => calc.calculate(_in(groove: g, angle: 90)),
          throwsA(isA<InputValidationException>()),
          reason: '$g 90deg',
        );
      }
    });

    test('zero gap and zero root face are valid and still give metal', () {
      for (final g in [
        GrooveType.singleV,
        GrooveType.doubleV,
        GrooveType.halfV,
      ]) {
        expect(
          calc.calculate(_in(groove: g, gap: 0, c: 0)).areaMm2,
          greaterThan(0),
        );
      }
    });

    test('every process has a positive efficiency <= 1 and a default '
        'consumable that it actually accepts', () {
      for (final p in WeldingProcess.values) {
        final e = WeldingDefaults.efficiencyFor(p);
        expect(e > 0 && e <= 1, isTrue);
        expect(
          WeldingDefaults.consumablesFor(p),
          contains(WeldingDefaults.defaultConsumableFor(p)),
          reason: '$p',
        );
      }
    });
  });
}

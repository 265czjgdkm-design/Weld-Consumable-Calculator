import 'package:flutter_test/flutter_test.dart';
import 'package:weld_consumable_calculator/core/en1011_formulas.dart';

void main() {
  group('computeCet', () {
    test('matches hand arithmetic for a representative composition', () {
      // CET = 0.18 + (1.2+0.1)/10 + (0.3+0.2)/20 + 0.5/40
      //     = 0.18 + 0.13 + 0.025 + 0.0125 = 0.3475
      final cet = computeCet(c: 0.18, mn: 1.2, mo: 0.1, cr: 0.3, cu: 0.2, ni: 0.5);
      expect(cet, closeTo(0.3475, 0.0001));
    });
  });

  group('resolveDesignCet', () {
    test('returns parentMetalCet unchanged when weldMetalCet is null', () {
      expect(resolveDesignCet(parentMetalCet: 0.35), 0.35);
    });

    test('returns parentMetalCet unchanged when the gap is >= 0.03', () {
      // parent - weld = 0.40 - 0.30 = 0.10 >= 0.03
      expect(
        resolveDesignCet(parentMetalCet: 0.40, weldMetalCet: 0.30),
        0.40,
      );
    });

    test('returns weldMetalCet + 0.03 when the gap is < 0.03', () {
      // parent - weld = 0.32 - 0.30 = 0.02 < 0.03
      final designCet = resolveDesignCet(parentMetalCet: 0.32, weldMetalCet: 0.30);
      expect(designCet, closeTo(0.33, 0.0001));
    });
  });

  group('computePreheatTempC', () {
    test('matches hand-computed arithmetic for a representative input set', () {
      // cet=0.35, d=20mm, hd=5ml/100g, Q=1.5kJ/mm
      // tanhTerm = 160*tanh(20/35) = 82.6252248...
      // hdTerm = 62*5^0.35 = 108.9008303...
      // qTerm = (53*0.35-32)*1.5 = -20.175
      // Tp = 697*0.35 + 82.6252248 + 108.9008303 - 20.175 - 328 = 87.301055...
      final tp = computePreheatTempC(
        cet: 0.35,
        thicknessMm: 20,
        hd: 5,
        heatInputKJPerMm: 1.5,
      );
      expect(tp, closeTo(87.3011, 0.001));
    });
  });

  group('checkPreheatRanges', () {
    test('returns no flags when every input is inside the validated ranges', () {
      final flags = checkPreheatRanges(
        cet: 0.35,
        thicknessMm: 20,
        hd: 5,
        heatInputKJPerMm: 1.5,
        yieldStrengthNPerMm2: 500,
      );
      expect(flags, isEmpty);
    });

    test('flags every violated range simultaneously, including yield strength', () {
      final flags = checkPreheatRanges(
        cet: 0.6,
        thicknessMm: 100,
        hd: 25,
        heatInputKJPerMm: 5.0,
        yieldStrengthNPerMm2: 1200,
      );
      expect(
        flags,
        containsAll(<PreheatRangeFlag>[
          PreheatRangeFlag.cetOutOfRange,
          PreheatRangeFlag.thicknessOutOfRange,
          PreheatRangeFlag.hdOutOfRange,
          PreheatRangeFlag.heatInputOutOfRange,
          PreheatRangeFlag.yieldStrengthOutOfRange,
        ]),
      );
      expect(flags.length, 5);
    });

    test('never raises the yield flag when yieldStrengthNPerMm2 is omitted', () {
      final flags = checkPreheatRanges(
        cet: 0.35,
        thicknessMm: 20,
        hd: 5,
        heatInputKJPerMm: 1.5,
      );
      expect(flags, isEmpty);
      expect(flags.contains(PreheatRangeFlag.yieldStrengthOutOfRange), isFalse);
    });
  });

  group('shapeFactorsFor', () {
    test('runOnPlate returns f2 = f3 = 1.0', () {
      final factors = shapeFactorsFor(CoolingJointType.runOnPlate);
      expect(factors.f2, 1.0);
      expect(factors.f3, 1.0);
    });

    test('buttWeldBetweenRuns returns f2 = f3 = 0.9', () {
      final factors = shapeFactorsFor(CoolingJointType.buttWeldBetweenRuns);
      expect(factors.f2, 0.9);
      expect(factors.f3, 0.9);
    });
  });

  group('isPreheatOrInterpassTempValid / _assertT0Valid guard', () {
    test('t0 = 499 does not throw', () {
      expect(isPreheatOrInterpassTempValid(499), isTrue);
      expect(
        () => computeT85ThreeDSeconds(t0: 499, heatInputKJPerMm: 1.2, f3: 1.0),
        returnsNormally,
      );
    });

    test('t0 = 500 throws ArgumentError', () {
      expect(isPreheatOrInterpassTempValid(500), isFalse);
      expect(
        () => computeT85ThreeDSeconds(t0: 500, heatInputKJPerMm: 1.2, f3: 1.0),
        throwsArgumentError,
      );
    });

    test('t0 = 600 throws ArgumentError', () {
      expect(isPreheatOrInterpassTempValid(600), isFalse);
      expect(
        () => computeT85ThreeDSeconds(t0: 600, heatInputKJPerMm: 1.2, f3: 1.0),
        throwsArgumentError,
      );
    });
  });

  group('computeT85ThreeDSeconds and computeT85TwoDSeconds', () {
    test('3D matches hand-computed arithmetic for t0=20, Q=1.2, F3=1.0', () {
      // t85 = (6700-100) * 1.2 * [1/480 - 1/780] * 1.0 = 6.346153846...
      final t85 = computeT85ThreeDSeconds(t0: 20, heatInputKJPerMm: 1.2, f3: 1.0);
      expect(t85, closeTo(6.3462, 0.001));
    });

    test('2D matches hand-computed arithmetic for t0=20, Q=1.2, d=10, F2=1.0', () {
      // t85 = (4300-86)*1e5*(1.44/100)*[1/480^2 - 1/780^2]*1.0 = 16.3635...
      final t85 = computeT85TwoDSeconds(
        t0: 20,
        heatInputKJPerMm: 1.2,
        thicknessMm: 10,
        f2: 1.0,
      );
      expect(t85, closeTo(16.3635, 0.001));
    });

    test('continuity self-check: 2D at d=dt agrees with 3D at the same t0/Q (f2=f3=1.0)', () {
      const t0 = 20.0;
      const q = 1.2;
      final dt = computeTransitionThicknessMm(t0: t0, heatInputKJPerMm: q);
      final t85TwoD = computeT85TwoDSeconds(
        t0: t0,
        heatInputKJPerMm: q,
        thicknessMm: dt,
        f2: 1.0,
      );
      final t85ThreeD = computeT85ThreeDSeconds(t0: t0, heatInputKJPerMm: q, f3: 1.0);
      expect(t85TwoD, closeTo(t85ThreeD, 0.01));
    });
  });

  group('computeHeatInputKJPerMm / arcThermalEfficiencyFor', () {
    test('SAW: eff=1.0, 30V, 200A, 300mm/min -> 1.2 kJ/mm', () {
      final q = computeHeatInputKJPerMm(
        efficiency: arcThermalEfficiencyFor(ArcProcess.saw),
        voltageV: 30,
        currentA: 200,
        travelSpeedMmPerMin: 300,
      );
      expect(q, closeTo(1.2, 0.0001));
    });

    test('SMAW: eff=0.85, 30V, 200A, 300mm/min -> 1.02 kJ/mm', () {
      final q = computeHeatInputKJPerMm(
        efficiency: arcThermalEfficiencyFor(ArcProcess.smaw),
        voltageV: 30,
        currentA: 200,
        travelSpeedMmPerMin: 300,
      );
      expect(q, closeTo(1.02, 0.0001));
    });

    test('GMAW/MAG: eff=0.85, 30V, 200A, 300mm/min -> 1.02 kJ/mm', () {
      final q = computeHeatInputKJPerMm(
        efficiency: arcThermalEfficiencyFor(ArcProcess.gmawMag),
        voltageV: 30,
        currentA: 200,
        travelSpeedMmPerMin: 300,
      );
      expect(q, closeTo(1.02, 0.0001));
    });
  });

  group('computeCevIiw and computePcmItoBessyo', () {
    test('CEV matches hand-computed arithmetic', () {
      // CEV = 0.2 + 1.0/6 + (0.5+0.2+0.05)/5 + (0.3+0.2)/15 = 0.55
      final cev = computeCevIiw(c: 0.2, mn: 1.0, cr: 0.5, mo: 0.2, v: 0.05, ni: 0.3, cu: 0.2);
      expect(cev, closeTo(0.55, 0.001));
    });

    test('Pcm matches hand-computed arithmetic', () {
      // Pcm = 0.1 + 0.3/30 + (1.0+0.2+0.3)/20 + 0.3/60 + 0.1/15 + 0.02/10 + 5*0.001
      //     = 0.20366666...
      final pcm = computePcmItoBessyo(
        c: 0.1,
        si: 0.3,
        mn: 1.0,
        cu: 0.2,
        cr: 0.3,
        ni: 0.3,
        mo: 0.1,
        v: 0.02,
        b: 0.001,
      );
      expect(pcm, closeTo(0.2037, 0.001));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:weld_consumable_calculator/core/weld_calculator.dart';
import 'package:weld_consumable_calculator/core/welding_defaults.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';

void main() {
  const calculator = WeldCalculator();

  test('returns expected default consumables by process', () {
    expect(
      WeldingDefaults.defaultConsumableFor(WeldingProcess.gtaw),
      ConsumablePreset.er70s2,
    );
    expect(
      WeldingDefaults.defaultConsumableFor(WeldingProcess.smaw),
      ConsumablePreset.e7018,
    );
    expect(
      WeldingDefaults.defaultConsumableFor(WeldingProcess.gtawSmaw),
      ConsumablePreset.gtawRootSmawFill,
    );
    expect(
      WeldingDefaults.defaultConsumableFor(WeldingProcess.gmaw),
      ConsumablePreset.er70s6,
    );
    expect(
      WeldingDefaults.defaultConsumableFor(WeldingProcess.fcaw),
      ConsumablePreset.e71t1,
    );
  });

  test('calculates plate square butt values', () {
    const input = WeldInputData(
      jointType: JointType.plateButt,
      grooveType: GrooveType.square,
      weldingProcess: WeldingProcess.gmaw,
      depositionRateMode: DepositionRateMode.preset,
      quantity: 2,
      lengthPerPieceMm: 1000,
      thicknessMm: 10,
      rootGapMm: 3,
      densityGPerCm3: WeldingDefaults.densityGPerCm3,
      wasteFactorPercent: WeldingDefaults.wasteFactorPercent,
    );

    final result = calculator.calculate(input);

    expect(result.areaMm2, closeTo(30, 0.0001));
    expect(result.lengthMm, closeTo(2000, 0.0001));
    expect(result.volumeCm3, closeTo(60, 0.0001));
    expect(result.weldMetalKg, closeTo(0.471, 0.0001));
    expect(result.fillerKg, closeTo(0.5757, 0.0002));
    expect(result.arcTimeHours, closeTo(0.1645, 0.0002));
  });

  test('calculates pipe single V using circumference mode', () {
    const input = WeldInputData(
      jointType: JointType.pipeButt,
      grooveType: GrooveType.singleV,
      weldingProcess: WeldingProcess.gtaw,
      depositionRateMode: DepositionRateMode.preset,
      quantity: 1,
      pipeOdMm: 168.3,
      thicknessMm: 12,
      rootGapMm: 3,
      rootFaceMm: 2,
      bevelAngleDeg: 30,
      densityGPerCm3: WeldingDefaults.densityGPerCm3,
      wasteFactorPercent: WeldingDefaults.wasteFactorPercent,
    );

    final result = calculator.calculate(input);

    expect(result.areaMm2, closeTo(93.735, 0.01));
    expect(result.lengthMm, closeTo(528.73, 0.05));
    expect(result.volumeCm3, closeTo(49.56, 0.05));
  });

  test('calculates plate half V values', () {
    const input = WeldInputData(
      jointType: JointType.plateButt,
      grooveType: GrooveType.halfV,
      weldingProcess: WeldingProcess.smaw,
      depositionRateMode: DepositionRateMode.preset,
      quantity: 1,
      lengthPerPieceMm: 1000,
      thicknessMm: 12,
      rootGapMm: 3,
      rootFaceMm: 2,
      bevelAngleDeg: 30,
      densityGPerCm3: WeldingDefaults.densityGPerCm3,
      wasteFactorPercent: WeldingDefaults.wasteFactorPercent,
    );

    final result = calculator.calculate(input);

    expect(result.areaMm2, closeTo(64.867, 0.01));
    expect(result.volumeCm3, closeTo(64.867, 0.02));
    expect(result.weldMetalKg, closeTo(0.5092, 0.001));
  });

  test('calculates pipe compound V values', () {
    const input = WeldInputData(
      jointType: JointType.pipeButt,
      grooveType: GrooveType.compoundV,
      weldingProcess: WeldingProcess.gtaw,
      depositionRateMode: DepositionRateMode.preset,
      quantity: 1,
      pipeOdMm: 168.3,
      thicknessMm: 16,
      rootGapMm: 3,
      rootFaceMm: 2,
      bevelAngleDeg: 35,
      secondaryBevelAngleDeg: 10,
      breakHeightMm: 5,
      densityGPerCm3: WeldingDefaults.densityGPerCm3,
      wasteFactorPercent: WeldingDefaults.wasteFactorPercent,
    );

    final result = calculator.calculate(input);

    expect(result.areaMm2, closeTo(142.81, 0.05));
    expect(result.lengthMm, closeTo(528.73, 0.05));
    expect(result.volumeCm3, closeTo(75.50, 0.1));
  });

  test('calculates fillet weld values', () {
    const input = WeldInputData(
      jointType: JointType.fillet,
      grooveType: GrooveType.fillet,
      weldingProcess: WeldingProcess.fcaw,
      depositionRateMode: DepositionRateMode.preset,
      quantity: 3,
      lengthPerPieceMm: 750,
      legSizeMm: 6,
      densityGPerCm3: WeldingDefaults.densityGPerCm3,
      wasteFactorPercent: WeldingDefaults.wasteFactorPercent,
    );

    final result = calculator.calculate(input);

    expect(result.areaMm2, closeTo(18, 0.0001));
    expect(result.lengthMm, closeTo(2250, 0.0001));
    expect(result.volumeCm3, closeTo(40.5, 0.0001));
    expect(result.weldMetalKg, closeTo(0.317925, 0.0001));
  });

  test('calculates GTAW + SMAW split using transition and diameters', () {
    const input = WeldInputData(
      jointType: JointType.plateButt,
      grooveType: GrooveType.square,
      weldingProcess: WeldingProcess.gtawSmaw,
      depositionRateMode: DepositionRateMode.preset,
      quantity: 1,
      lengthPerPieceMm: 1000,
      thicknessMm: 10,
      rootGapMm: 3,
      gtawTransitionMm: 3,
      gtawWireDiameterMm: 2.4,
      smawElectrodeDiameterMm: 3.2,
      densityGPerCm3: WeldingDefaults.densityGPerCm3,
      wasteFactorPercent: WeldingDefaults.wasteFactorPercent,
    );

    final result = calculator.calculate(input);

    expect(result.areaMm2, closeTo(30, 0.0001));
    expect(result.weldMetalKg, closeTo(0.2355, 0.0001));
    expect(result.fillerKg, closeTo(0.3607, 0.001));
    expect(result.arcTimeHours, closeTo(0.3347, 0.001));
    expect(result.depositionEfficiency, closeTo(0.7187, 0.001));
    expect(result.depositionRateKgPerHour, closeTo(1.0778, 0.001));
    expect(result.processBreakdowns, hasLength(2));
    expect(result.processBreakdowns.first.process, WeldingProcess.gtaw);
    expect(result.processBreakdowns.last.process, WeldingProcess.smaw);
  });

  test('throws helpful validation error for invalid double V root face', () {
    const input = WeldInputData(
      jointType: JointType.plateButt,
      grooveType: GrooveType.doubleV,
      weldingProcess: WeldingProcess.smaw,
      depositionRateMode: DepositionRateMode.preset,
      quantity: 1,
      lengthPerPieceMm: 1000,
      thicknessMm: 10,
      rootGapMm: 2,
      rootFaceMm: 5,
      bevelAngleDeg: 30,
      densityGPerCm3: WeldingDefaults.densityGPerCm3,
      wasteFactorPercent: WeldingDefaults.wasteFactorPercent,
    );

    expect(
      () => calculator.calculate(input),
      throwsA(
        isA<InputValidationException>().having(
          (error) => error.message,
          'message',
          contains('half the thickness'),
        ),
      ),
    );
  });

  test('uses manual deposition rate override for single process arc time', () {
    const input = WeldInputData(
      jointType: JointType.plateButt,
      grooveType: GrooveType.square,
      weldingProcess: WeldingProcess.gtaw,
      depositionRateMode: DepositionRateMode.manual,
      quantity: 1,
      lengthPerPieceMm: 1000,
      thicknessMm: 10,
      rootGapMm: 3,
      densityGPerCm3: WeldingDefaults.densityGPerCm3,
      wasteFactorPercent: WeldingDefaults.wasteFactorPercent,
      manualDepositionRateKgPerHour: 1.5,
    );

    final result = calculator.calculate(input);

    expect(result.depositionRateKgPerHour, closeTo(1.5, 0.0001));
    expect(result.arcTimeHours, closeTo(0.1818, 0.001));
  });

  test('uses separate manual rates for GTAW + SMAW split', () {
    const input = WeldInputData(
      jointType: JointType.plateButt,
      grooveType: GrooveType.square,
      weldingProcess: WeldingProcess.gtawSmaw,
      depositionRateMode: DepositionRateMode.manual,
      quantity: 1,
      lengthPerPieceMm: 1000,
      thicknessMm: 10,
      rootGapMm: 3,
      gtawTransitionMm: 3,
      densityGPerCm3: WeldingDefaults.densityGPerCm3,
      wasteFactorPercent: WeldingDefaults.wasteFactorPercent,
      manualGtawRateKgPerHour: 1.0,
      manualSmawRateKgPerHour: 2.0,
    );

    final result = calculator.calculate(input);

    expect(result.arcTimeHours, closeTo(0.2213, 0.001));
    expect(result.depositionRateKgPerHour, closeTo(1.6301, 0.001));
    expect(
      result.processBreakdowns.map((item) => item.depositionRateKgPerHour),
      [closeTo(1.0, 0.0001), closeTo(2.0, 0.0001)],
    );
  });
}

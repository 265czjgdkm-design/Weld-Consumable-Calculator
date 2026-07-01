class InsightItem {
  const InsightItem({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;
}

enum CalculatorModule { weldEstimator, branchConnections }

extension CalculatorModuleX on CalculatorModule {
  String get label => switch (this) {
    CalculatorModule.weldEstimator => 'Butt & Fillet Estimator',
    CalculatorModule.branchConnections => 'Branch Connections',
  };
}

enum FieldKey {
  quantity,
  lengthMm,
  pipeOdMm,
  pipeOdAMm,
  pipeOdBMm,
  thicknessMm,
  thicknessAMm,
  thicknessBMm,
  rootGapMm,
  rootFaceMm,
  bevelAngleDeg,
  secondaryBevelAngleDeg,
  breakHeightMm,
  legSizeMm,
  gtawTransitionMm,
  wireDiameterMm,
  electrodeDiameterMm,
  gtawWireDiameterMm,
  smawElectrodeDiameterMm,
  manualDepositionRateKgPerHour,
  manualGtawRateKgPerHour,
  manualSmawRateKgPerHour,
  density,
  wasteFactor,
}

class InputFieldSpec {
  const InputFieldSpec({
    required this.key,
    required this.label,
    required this.helperText,
  }) : diameterOptions = null;

  const InputFieldSpec.diameter({
    required this.key,
    required this.label,
    required this.helperText,
    required this.diameterOptions,
  });

  final FieldKey key;
  final String label;
  final String helperText;
  final List<DiameterPresetOption>? diameterOptions;
}

class DiameterPresetOption {
  const DiameterPresetOption({required this.label, required this.value});

  final String label;
  final double value;
}

class CalculationBasisItem {
  const CalculationBasisItem(this.label, this.value);

  final String label;
  final String value;
}

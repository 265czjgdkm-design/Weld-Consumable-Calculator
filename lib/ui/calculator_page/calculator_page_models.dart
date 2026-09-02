import '../../l10n/strings.dart';

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

enum WizardStep { process, dimensions, consumable, summary }

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

// Machine-readable identity for a [CalculationBasisItem], decoupled from its
// (English, PDF-facing) `label` text -- see [BasisKeyX.labelFor] for the
// localized UI display text. Grouping/lookup logic (wizard summary recap
// cards, oversize-leg lookup in ResultsSection) matches on this key instead
// of the display label, so translating labels can never silently break it.
enum BasisKey {
  process,
  rateBasis,
  inputPreset,
  savedPreset,
  joint,
  geometry,
  alignment,
  groove,
  classification,
  fillerMetalFamily,
  density,
  wasteAllowance,
  quantity,
  weldLengthPerPiece,
  pipeOd,
  thickness,
  thicknessA,
  thicknessB,
  controllingThickness,
  odA,
  odB,
  referenceOd,
  rootGap,
  rootFace,
  rootFacePerSide,
  bevelAngle,
  primaryBevelAngle,
  secondaryBevelAngle,
  breakHeight,
  filletLegSize,
  userDefinedRate,
  wireDiameter,
  electrodeDiameter,
  gtawTransitionDepth,
  gtawDepositionRate,
  gtawWireDiameter,
  smawDepositionRate,
  smawElectrodeDiameter,
}

extension BasisKeyX on BasisKey {
  String labelFor(L10nStrings strings) => switch (this) {
    BasisKey.process => strings.basisProcess,
    BasisKey.rateBasis => strings.basisRateBasis,
    BasisKey.inputPreset => strings.basisInputPreset,
    BasisKey.savedPreset => strings.basisSavedPreset,
    BasisKey.joint => strings.basisJoint,
    BasisKey.geometry => strings.basisGeometry,
    BasisKey.alignment => strings.basisAlignment,
    BasisKey.groove => strings.basisGroove,
    BasisKey.classification => strings.basisClassification,
    BasisKey.fillerMetalFamily => strings.basisFillerMetalFamily,
    BasisKey.density => strings.basisDensity,
    BasisKey.wasteAllowance => strings.basisWasteAllowance,
    BasisKey.quantity => strings.basisQuantity,
    BasisKey.weldLengthPerPiece => strings.basisWeldLengthPerPiece,
    BasisKey.pipeOd => strings.basisPipeOd,
    BasisKey.thickness => strings.basisThickness,
    BasisKey.thicknessA => strings.basisThicknessA,
    BasisKey.thicknessB => strings.basisThicknessB,
    BasisKey.controllingThickness => strings.basisControllingThickness,
    BasisKey.odA => strings.basisOdA,
    BasisKey.odB => strings.basisOdB,
    BasisKey.referenceOd => strings.basisReferenceOd,
    BasisKey.rootGap => strings.basisRootGap,
    BasisKey.rootFace => strings.basisRootFace,
    BasisKey.rootFacePerSide => strings.basisRootFacePerSide,
    BasisKey.bevelAngle => strings.basisBevelAngle,
    BasisKey.primaryBevelAngle => strings.basisPrimaryBevelAngle,
    BasisKey.secondaryBevelAngle => strings.basisSecondaryBevelAngle,
    BasisKey.breakHeight => strings.basisBreakHeight,
    BasisKey.filletLegSize => strings.basisFilletLegSize,
    BasisKey.userDefinedRate => strings.basisUserDefinedRate,
    BasisKey.wireDiameter => strings.basisWireDiameter,
    BasisKey.electrodeDiameter => strings.basisElectrodeDiameter,
    BasisKey.gtawTransitionDepth => strings.basisGtawTransitionDepth,
    BasisKey.gtawDepositionRate => strings.basisGtawDepositionRate,
    BasisKey.gtawWireDiameter => strings.basisGtawWireDiameter,
    BasisKey.smawDepositionRate => strings.basisSmawDepositionRate,
    BasisKey.smawElectrodeDiameter => strings.basisSmawElectrodeDiameter,
  };
}

class CalculationBasisItem {
  const CalculationBasisItem(
    this.key,
    this.label,
    this.value, [
    String? localizedValue,
  ]) : localizedValue = localizedValue ?? value;

  final BasisKey key;
  // Plain English -- weld_pdf_report_service.dart's PDF export consumes
  // this directly (via _exportPdf's basisEntries), which is out of scope
  // for this localization pass. UI call sites display
  // `key.labelFor(strings)` instead of this field.
  final String label;
  final String value;
  // Localized display value for UI call sites (wizard recap, results
  // Engineering Basis panel). Falls back to [value] for entries whose
  // underlying value is already locale-neutral (numbers, units, free text).
  final String localizedValue;
}

// Pure, Flutter-independent implementations of EN 1011-2:2001+A1:2003
// Annex C.3 (Method B carbon equivalent / preheat) and Annex D.6 (t8/5
// cooling time) formulas, verified against the standard text by a
// researcher pass on 2026-08-28.
//
// IMPORTANT: `arcThermalEfficiencyFor` below is a DIFFERENT physical
// quantity from `WeldingDefaults.efficiencyFor` in welding_defaults.dart
// (that one is deposition/metal-transfer efficiency, e.g. SMAW=0.65; this
// one is arc thermal efficiency for heat-input calculations, e.g.
// SMAW=0.85). Do not merge or reuse one for the other.

import 'dart:math' as math;

// ---------------------------------------------------------------------
// Carbon equivalent (CET, Method B) and preheat temperature
// ---------------------------------------------------------------------

/// CET = C + (Mn+Mo)/10 + (Cr+Cu)/20 + Ni/40, all inputs percent by weight.
/// Only C, Mn, Mo, Cr, Cu, Ni feed CET -- Si/Nb/Ti/V/B/N deliberately do
/// not. Any composition input not analyzed/entered should be passed as 0.0
/// by the caller (not skipped), matching standard carbon-equivalent
/// convention.
double computeCet({
  required double c,
  required double mn,
  required double mo,
  required double cr,
  required double cu,
  required double ni,
}) {
  return c + (mn + mo) / 10 + (cr + cu) / 20 + ni / 40;
}

/// EN 1011-2 Method B special rule: if the parent-metal CET exceeds the
/// weld-metal CET by less than 0.03 (percentage points), the design CET
/// used in computePreheatTempC must be weldMetalCet + 0.03 instead of
/// parentMetalCet. If weldMetalCet is null (not provided), parentMetalCet
/// is returned unchanged.
double resolveDesignCet({
  required double parentMetalCet,
  double? weldMetalCet,
}) {
  if (weldMetalCet == null) return parentMetalCet;
  if (parentMetalCet - weldMetalCet < 0.03) {
    return weldMetalCet + 0.03;
  }
  return parentMetalCet;
}

/// Tp = 697*CET + 160*tanh(d/35) + 62*HD^0.35 + (53*CET-32)*Q - 328  (deg C)
/// thicknessMm = plate thickness (use the thicker of two dissimilar
/// plates), hd = diffusible hydrogen ml/100g deposited metal (ISO 3690),
/// heatInputKJPerMm = net heat input kJ/mm. `cet` here should already be
/// the *design* CET, i.e. the output of resolveDesignCet, not the raw
/// parent-metal CET.
double computePreheatTempC({
  required double cet,
  required double thicknessMm,
  required double hd,
  required double heatInputKJPerMm,
}) {
  final tanhTerm = 160 * _tanh(thicknessMm / 35);
  final hdTerm = 62 * math.pow(hd, 0.35);
  final qTerm = (53 * cet - 32) * heatInputKJPerMm;
  return 697 * cet + tanhTerm + hdTerm + qTerm - 328;
}

double _tanh(double x) {
  final e2x = math.exp(2 * x);
  return (e2x - 1) / (e2x + 1);
}

/// Which of EN 1011-2's explicitly stated Method-B validated input ranges
/// are violated. Non-blocking by design -- render as warnings, never
/// prevent calculation. yieldStrengthNPerMm2 is optional; its check is
/// skipped entirely if null (the app has no other yield-strength/steel-
/// group input anywhere, so this is opt-in only).
enum PreheatRangeFlag {
  cetOutOfRange, // valid 0.2 - 0.5 %
  thicknessOutOfRange, // valid 10 - 90 mm
  hdOutOfRange, // valid 1 - 20 ml/100g
  heatInputOutOfRange, // valid 0.5 - 4.0 kJ/mm
  yieldStrengthOutOfRange, // valid up to 1000 N/mm^2
}

List<PreheatRangeFlag> checkPreheatRanges({
  required double cet,
  required double thicknessMm,
  required double hd,
  required double heatInputKJPerMm,
  double? yieldStrengthNPerMm2,
}) {
  final flags = <PreheatRangeFlag>[];
  if (cet < 0.2 || cet > 0.5) flags.add(PreheatRangeFlag.cetOutOfRange);
  if (thicknessMm < 10 || thicknessMm > 90) {
    flags.add(PreheatRangeFlag.thicknessOutOfRange);
  }
  if (hd < 1 || hd > 20) flags.add(PreheatRangeFlag.hdOutOfRange);
  if (heatInputKJPerMm < 0.5 || heatInputKJPerMm > 4.0) {
    flags.add(PreheatRangeFlag.heatInputOutOfRange);
  }
  if (yieldStrengthNPerMm2 != null && yieldStrengthNPerMm2 > 1000) {
    flags.add(PreheatRangeFlag.yieldStrengthOutOfRange);
  }
  return flags;
}

// ---------------------------------------------------------------------
// t8/5 cooling time (Annex D.6)
// ---------------------------------------------------------------------

enum CoolingRegime { twoDThinPlate, threeDThickPlate }

enum CoolingJointType { runOnPlate, buttWeldBetweenRuns }

/// Fixed shape factors from Table D.1. Fillet-weld joints are deliberately
/// NOT modeled here -- the standard gives only a range (F2 0.45-0.67 or
/// 0.9-0.67 depending on joint) with no interpolation rule, and this app
/// does not expose fillet joints in the cooling-time calculator for that
/// reason (see plan section 0, Q2).
({double f2, double f3}) shapeFactorsFor(CoolingJointType jointType) {
  switch (jointType) {
    case CoolingJointType.runOnPlate:
      return (f2: 1.0, f3: 1.0);
    case CoolingJointType.buttWeldBetweenRuns:
      return (f2: 0.9, f3: 0.9);
  }
}

/// True if t0 is in the physically valid domain for the t8/5 formulas
/// below (both divide by (500-T0) and (800-T0); T0 >= 500 makes the
/// 500-T0 term zero or negative, which is not physically meaningful for a
/// cooling curve from 800 to 500 C). Callers MUST check this and hard-
/// block calculation (inline field error), not just warn, before calling
/// computeT85ThreeDSeconds / computeT85TwoDSeconds /
/// computeTransitionThicknessMm.
bool isPreheatOrInterpassTempValid(double t0) => t0 < 500;

/// 3D (thick plate): t8/5 = (6700-5*T0) * Q * [1/(500-T0) - 1/(800-T0)] * F3
/// Throws ArgumentError if t0 >= 500 (see isPreheatOrInterpassTempValid) --
/// this is a defense-in-depth check; the UI layer must also validate
/// before calling.
double computeT85ThreeDSeconds({
  required double t0,
  required double heatInputKJPerMm,
  required double f3,
}) {
  _assertT0Valid(t0);
  return (6700 - 5 * t0) *
      heatInputKJPerMm *
      (1 / (500 - t0) - 1 / (800 - t0)) *
      f3;
}

/// 2D (thin plate): t8/5 = (4300-4.3*T0) * 1e5 * (Q^2/d^2) *
///   [1/(500-T0)^2 - 1/(800-T0)^2] * F2
double computeT85TwoDSeconds({
  required double t0,
  required double heatInputKJPerMm,
  required double thicknessMm,
  required double f2,
}) {
  _assertT0Valid(t0);
  final bracketTerm =
      1 / math.pow(500 - t0, 2) - 1 / math.pow(800 - t0, 2);
  return (4300 - 4.3 * t0) *
      1e5 *
      (math.pow(heatInputKJPerMm, 2) / math.pow(thicknessMm, 2)) *
      bracketTerm *
      f2;
}

/// Transition thickness dt: thicknessMm < dt -> use the 2D formula;
/// thicknessMm >= dt -> use the 3D formula. Derived by setting the 2D and
/// 3D formulas equal and solving for d; cross-checked against an
/// independent published source, NOT literal EN 1011-2 text.
double computeTransitionThicknessMm({
  required double t0,
  required double heatInputKJPerMm,
}) {
  _assertT0Valid(t0);
  final numerator = (4300 - 4.3 * t0) *
      1e5 *
      heatInputKJPerMm *
      (1 / (500 - t0) + 1 / (800 - t0));
  final denominator = 6700 - 5 * t0;
  return math.sqrt(numerator / denominator);
}

CoolingRegime selectCoolingRegime({
  required double thicknessMm,
  required double transitionThicknessMm,
}) {
  return thicknessMm < transitionThicknessMm
      ? CoolingRegime.twoDThinPlate
      : CoolingRegime.threeDThickPlate;
}

void _assertT0Valid(double t0) {
  if (t0 >= 500) {
    throw ArgumentError(
      'T0 must be < 500 C: the 1/(500-T0) term is undefined or negative '
      'at/above 500 C.',
    );
  }
}

// ---------------------------------------------------------------------
// Net heat input (Q) from arc parameters -- only for the 3 processes
// EN 1011-2 verifies arc thermal efficiency for.
// ---------------------------------------------------------------------

enum ArcProcess { saw, smaw, gmawMag }

/// Arc thermal efficiency, verified against EN 1011-2 Annex D.6 for
/// exactly these 3 processes. This is NOT the same quantity as
/// WeldingDefaults.efficiencyFor in welding_defaults.dart (deposition
/// efficiency) -- do not conflate, do not reuse that function's switch.
double arcThermalEfficiencyFor(ArcProcess process) {
  switch (process) {
    case ArcProcess.saw:
      return 1.0;
    case ArcProcess.smaw:
      return 0.85;
    case ArcProcess.gmawMag:
      return 0.85;
  }
}

/// Q [kJ/mm] = efficiency * U[V] * I[A] * 60 / (travelSpeedMmPerMin * 1000)
/// General welding heat-input formula -- NOT itself verified against
/// EN 1011-2 primary text (only the 3 efficiency values above are
/// standard-verified); this is standard, uncontroversial welding
/// engineering practice but flagged here for transparency.
double computeHeatInputKJPerMm({
  required double efficiency,
  required double voltageV,
  required double currentA,
  required double travelSpeedMmPerMin,
}) {
  return efficiency * voltageV * currentA * 60 / (travelSpeedMmPerMin * 1000);
}

// ---------------------------------------------------------------------
// CEV / Pcm -- informational only, NOT part of EN 1011-2. Cross-verified
// from multiple consistent secondary metallurgy sources.
// ---------------------------------------------------------------------

/// CEV (IIW), best-fit for C > 0.18%.
double computeCevIiw({
  required double c,
  required double mn,
  required double cr,
  required double mo,
  required double v,
  required double ni,
  required double cu,
}) {
  return c + mn / 6 + (cr + mo + v) / 5 + (ni + cu) / 15;
}

/// Pcm (Ito-Bessyo), best-fit for C < 0.18%.
double computePcmItoBessyo({
  required double c,
  required double si,
  required double mn,
  required double cu,
  required double cr,
  required double ni,
  required double mo,
  required double v,
  required double b,
}) {
  return c + si / 30 + (mn + cu + cr) / 20 + ni / 60 + mo / 15 + v / 10 + 5 * b;
}

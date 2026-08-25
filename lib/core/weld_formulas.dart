import 'dart:math' as math;

class WeldFormulas {
  const WeldFormulas._();

  static double volumeCm3({
    required double areaMm2,
    required double lengthMm,
  }) => areaMm2 * lengthMm / 1000;

  static double weldMetalKg({
    required double volumeCm3,
    required double densityGPerCm3,
  }) => volumeCm3 * densityGPerCm3 / 1000;

  static double fillerKg({
    required double weldMetalKg,
    required double depositionEfficiency,
    required double wasteFactorPercent,
  }) => weldMetalKg / depositionEfficiency * (1 + wasteFactorPercent / 100);

  static double arcTimeHours({
    required double fillerKg,
    required double depositionRateKgPerHour,
  }) => fillerKg / depositionRateKgPerHour;

  static double squareButtAreaMm2({
    required double thicknessMm,
    required double rootGapMm,
  }) => thicknessMm * rootGapMm;

  static double squareButtPartialAreaFromRootMm2({
    required double thicknessMm,
    required double rootGapMm,
    required double fillHeightMm,
  }) => rootGapMm * fillHeightMm.clamp(0, thicknessMm).toDouble();

  static double singleVAreaMm2({
    required double thicknessMm,
    required double rootFaceMm,
    required double rootGapMm,
    required double bevelAngleDeg,
  }) {
    final grooveHeight = thicknessMm - rootFaceMm;
    final angleRad = bevelAngleDeg * math.pi / 180;
    final topWidth = rootGapMm + (2 * grooveHeight * math.tan(angleRad));

    return (rootGapMm * rootFaceMm) +
        (((rootGapMm + topWidth) / 2) * grooveHeight);
  }

  static double singleVPartialAreaFromRootMm2({
    required double thicknessMm,
    required double rootFaceMm,
    required double rootGapMm,
    required double bevelAngleDeg,
    required double fillHeightMm,
  }) {
    final boundedHeight = fillHeightMm.clamp(0, thicknessMm).toDouble();
    final lowerRectHeight = math.min(boundedHeight, rootFaceMm);
    final upperHeight = math.max(0, boundedHeight - rootFaceMm);
    final widthAtTop =
        rootGapMm + (2 * upperHeight * math.tan(bevelAngleDeg * math.pi / 180));

    return (rootGapMm * lowerRectHeight) +
        (((rootGapMm + widthAtTop) / 2) * upperHeight);
  }

  static double halfVAreaMm2({
    required double thicknessMm,
    required double rootFaceMm,
    required double rootGapMm,
    required double bevelAngleDeg,
  }) {
    final grooveHeight = thicknessMm - rootFaceMm;
    final angleRad = bevelAngleDeg * math.pi / 180;
    final topWidth = rootGapMm + (grooveHeight * math.tan(angleRad));

    return (rootGapMm * rootFaceMm) +
        (((rootGapMm + topWidth) / 2) * grooveHeight);
  }

  static double halfVPartialAreaFromRootMm2({
    required double thicknessMm,
    required double rootFaceMm,
    required double rootGapMm,
    required double bevelAngleDeg,
    required double fillHeightMm,
  }) {
    final boundedHeight = fillHeightMm.clamp(0, thicknessMm).toDouble();
    final lowerRectHeight = math.min(boundedHeight, rootFaceMm);
    final upperHeight = math.max(0, boundedHeight - rootFaceMm);
    final widthAtTop =
        rootGapMm + (upperHeight * math.tan(bevelAngleDeg * math.pi / 180));

    return (rootGapMm * lowerRectHeight) +
        (((rootGapMm + widthAtTop) / 2) * upperHeight);
  }

  static double doubleVAreaMm2({
    required double thicknessMm,
    required double rootFaceMm,
    required double rootGapMm,
    required double bevelAngleDeg,
  }) {
    final sideThickness = thicknessMm / 2;
    return singleVAreaMm2(
          thicknessMm: sideThickness,
          rootFaceMm: rootFaceMm,
          rootGapMm: rootGapMm,
          bevelAngleDeg: bevelAngleDeg,
        ) *
        2;
  }

  static double compoundVAreaMm2({
    required double thicknessMm,
    required double rootFaceMm,
    required double rootGapMm,
    required double primaryBevelAngleDeg,
    required double secondaryBevelAngleDeg,
    required double breakHeightMm,
  }) {
    final lowerHeight = breakHeightMm;
    final upperHeight = thicknessMm - rootFaceMm - breakHeightMm;
    final primaryAngleRad = primaryBevelAngleDeg * math.pi / 180;
    final secondaryAngleRad = secondaryBevelAngleDeg * math.pi / 180;
    final widthAtBreak =
        rootGapMm + (2 * lowerHeight * math.tan(primaryAngleRad));
    final topWidth =
        widthAtBreak + (2 * upperHeight * math.tan(secondaryAngleRad));

    return (rootGapMm * rootFaceMm) +
        (((rootGapMm + widthAtBreak) / 2) * lowerHeight) +
        (((widthAtBreak + topWidth) / 2) * upperHeight);
  }

  static double compoundVPartialAreaFromRootMm2({
    required double thicknessMm,
    required double rootFaceMm,
    required double rootGapMm,
    required double primaryBevelAngleDeg,
    required double secondaryBevelAngleDeg,
    required double breakHeightMm,
    required double fillHeightMm,
  }) {
    final boundedHeight = fillHeightMm.clamp(0, thicknessMm).toDouble();
    final lowerRectHeight = math.min(boundedHeight, rootFaceMm);
    final bevelFillHeight = math.max(0, boundedHeight - rootFaceMm);
    final lowerSegmentHeight = math.min(bevelFillHeight, breakHeightMm);
    final upperSegmentHeight = math.max(0, bevelFillHeight - breakHeightMm);
    final widthAtLowerBreak =
        rootGapMm +
        (2 *
            lowerSegmentHeight *
            math.tan(primaryBevelAngleDeg * math.pi / 180));
    final widthAtTop =
        widthAtLowerBreak +
        (2 *
            upperSegmentHeight *
            math.tan(secondaryBevelAngleDeg * math.pi / 180));

    return (rootGapMm * lowerRectHeight) +
        (((rootGapMm + widthAtLowerBreak) / 2) * lowerSegmentHeight) +
        (((widthAtLowerBreak + widthAtTop) / 2) * upperSegmentHeight);
  }

  static double filletAreaMm2({required double legSizeMm}) =>
      0.5 * math.pow(legSizeMm, 2);

  /// Standard metric fillet-weld leg sizes (mm), ascending.
  static const List<double> standardFilletLegSizesMm = [3, 4, 5, 6, 8, 10, 12];

  /// The next size up from [standardFilletLegSizesMm] above [currentLegMm],
  /// or `null` if [currentLegMm] is already at or above the largest
  /// standard size in the table.
  static double? nextStandardFilletLegMm(double currentLegMm) {
    for (final size in standardFilletLegSizesMm) {
      if (size > currentLegMm) return size;
    }
    return null;
  }

  /// Fillet cross-sectional area is exactly quadratic in leg size
  /// (`filletAreaMm2`), so the weld-metal increase from stepping up to a
  /// larger leg size is a pure derived ratio - no new estimate assumptions.
  /// Returns the fractional increase (e.g. `0.778` for +77.8%), not a
  /// value already scaled to 100 - see [nextStandardFilletLegMm] for a real
  /// next-standard-size lookup to pass as [nextLegMm].
  static double filletOversizeDeltaFraction({
    required double currentLegMm,
    required double nextLegMm,
  }) => math.pow(nextLegMm / currentLegMm, 2) - 1;

  static double filletPartialAreaFromRootMm2({
    required double legSizeMm,
    required double fillHeightMm,
  }) {
    final boundedHeight = fillHeightMm.clamp(0, legSizeMm).toDouble();
    return 0.5 * math.pow(boundedHeight, 2);
  }

  static double circumferenceLengthMm({
    required double pipeOdMm,
    required double quantity,
  }) => math.pi * pipeOdMm * quantity;

  static double straightLengthMm({
    required double lengthPerPieceMm,
    required double quantity,
  }) => lengthPerPieceMm * quantity;
}

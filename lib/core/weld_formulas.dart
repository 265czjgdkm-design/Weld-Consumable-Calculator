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

  /// Deposition rate (AWS A3.0) is the weld metal DEPOSITED per hour, so
  /// arc-on time divides the deposited weld metal by it -- not the filler
  /// bought, which also carries stub/spatter losses and the waste
  /// allowance that never pass through the arc as deposit.
  static double arcTimeHours({
    required double weldMetalKg,
    required double depositionRateKgPerHour,
  }) => weldMetalKg / depositionRateKgPerHour;

  static double squareButtAreaMm2({
    required double thicknessMm,
    required double rootGapMm,
  }) => thicknessMm * rootGapMm;

  static double squareButtPartialAreaFromRootMm2({
    required double thicknessMm,
    required double rootGapMm,
    required double fillHeightMm,
  }) => rootGapMm * fillHeightMm.clamp(0, thicknessMm).toDouble();

  static double singleVTopWidthMm({
    required double thicknessMm,
    required double rootFaceMm,
    required double rootGapMm,
    required double bevelAngleDeg,
  }) {
    final grooveHeight = thicknessMm - rootFaceMm;
    final angleRad = bevelAngleDeg * math.pi / 180;
    return rootGapMm + (2 * grooveHeight * math.tan(angleRad));
  }

  static double singleVAreaMm2({
    required double thicknessMm,
    required double rootFaceMm,
    required double rootGapMm,
    required double bevelAngleDeg,
  }) {
    final grooveHeight = thicknessMm - rootFaceMm;
    final topWidth = singleVTopWidthMm(
      thicknessMm: thicknessMm,
      rootFaceMm: rootFaceMm,
      rootGapMm: rootGapMm,
      bevelAngleDeg: bevelAngleDeg,
    );

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

  static double halfVTopWidthMm({
    required double thicknessMm,
    required double rootFaceMm,
    required double rootGapMm,
    required double bevelAngleDeg,
  }) {
    final grooveHeight = thicknessMm - rootFaceMm;
    final angleRad = bevelAngleDeg * math.pi / 180;
    return rootGapMm + (grooveHeight * math.tan(angleRad));
  }

  static double halfVAreaMm2({
    required double thicknessMm,
    required double rootFaceMm,
    required double rootGapMm,
    required double bevelAngleDeg,
  }) {
    final grooveHeight = thicknessMm - rootFaceMm;
    final topWidth = halfVTopWidthMm(
      thicknessMm: thicknessMm,
      rootFaceMm: rootFaceMm,
      rootGapMm: rootGapMm,
      bevelAngleDeg: bevelAngleDeg,
    );

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

  static double doubleVTopWidthMm({
    required double thicknessMm,
    required double rootFaceMm,
    required double rootGapMm,
    required double bevelAngleDeg,
  }) => singleVTopWidthMm(
    thicknessMm: thicknessMm / 2,
    rootFaceMm: rootFaceMm / 2,
    rootGapMm: rootGapMm,
    bevelAngleDeg: bevelAngleDeg,
  );

  static double doubleVAreaMm2({
    required double thicknessMm,
    required double rootFaceMm,
    required double rootGapMm,
    required double bevelAngleDeg,
  }) {
    // [rootFaceMm] is the TOTAL land (ISO 9692-1 / AWS "c"/"f"), split
    // evenly about the mid-thickness: each half is a Single V of t/2 with
    // c/2 land.
    final sideThickness = thicknessMm / 2;
    return singleVAreaMm2(
          thicknessMm: sideThickness,
          rootFaceMm: rootFaceMm / 2,
          rootGapMm: rootGapMm,
          bevelAngleDeg: bevelAngleDeg,
        ) *
        2;
  }

  /// GTAW share of a Double V, measured from the root: the root pass sits on
  /// the land (total root face c, centred on mid-thickness) and GTAW then
  /// climbs into the FIRST side's groove. Geometrically this is a Single V
  /// of height t/2 + c/2 whose root face is the whole land c; the second
  /// side (back-gouged) is never GTAW here.
  static double doubleVPartialAreaFromRootMm2({
    required double thicknessMm,
    required double rootFaceMm,
    required double rootGapMm,
    required double bevelAngleDeg,
    required double fillHeightMm,
  }) => singleVPartialAreaFromRootMm2(
    thicknessMm: thicknessMm / 2 + rootFaceMm / 2,
    rootFaceMm: rootFaceMm,
    rootGapMm: rootGapMm,
    bevelAngleDeg: bevelAngleDeg,
    fillHeightMm: fillHeightMm,
  );

  /// Metal re-deposited after back-gouging the second side of a Double V.
  /// Air-carbon-arc / grinding gouges leave a U-shaped groove roughly 1.5x
  /// as wide as it is deep (never narrower than the root gap + 2 mm); it is
  /// modelled as a half-ellipse: area = pi/4 * width * depth.
  static double backGougeWidthMm({
    required double depthMm,
    required double rootGapMm,
  }) => math.max(1.5 * depthMm, rootGapMm + 2);

  static double backGougeAreaMm2({
    required double depthMm,
    required double rootGapMm,
  }) {
    if (depthMm <= 0) return 0;
    return math.pi /
        4 *
        backGougeWidthMm(depthMm: depthMm, rootGapMm: rootGapMm) *
        depthMm;
  }

  /// Butt joint between members of unequal thickness: the thicker member is
  /// tapered down to the thinner one before the groove is prepared (ASME
  /// B16.25 / B31.3 para. 328.4.3 for piping, AWS D1.1 unequal-thickness
  /// transition for structures; taper 1:4 here, steeper limits are 30 deg
  /// and 1:2.5). The groove, and so the weld, is sized on the THINNER wall.
  /// The taper itself is base-metal machining, not weld metal.
  static double? governingThicknessMm(double? a, double? b) {
    if (a == null) return b;
    if (b == null) return a;
    return math.min(a, b);
  }

  /// Taper length (horizontal) for a thickness step of [stepMm] at 1:4.
  static const double unequalTaperRatio = 4;

  /// OD at the weld: the thinner member's OD (the thicker one is tapered to
  /// meet it). Equal walls: the larger OD.
  static double? governingPipeOdMm({
    required double? thicknessAMm,
    required double? thicknessBMm,
    required double? odAMm,
    required double? odBMm,
  }) {
    if (odAMm == null) return odBMm;
    if (odBMm == null) return odAMm;
    if (thicknessAMm != null &&
        thicknessBMm != null &&
        thicknessAMm != thicknessBMm) {
      return thicknessAMm < thicknessBMm ? odAMm : odBMm;
    }
    return math.max(odAMm, odBMm);
  }

  static double compoundVTopWidthMm({
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
    return widthAtBreak + (2 * upperHeight * math.tan(secondaryAngleRad));
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
    final widthAtBreak =
        rootGapMm + (2 * lowerHeight * math.tan(primaryAngleRad));
    final topWidth = compoundVTopWidthMm(
      thicknessMm: thicknessMm,
      rootFaceMm: rootFaceMm,
      rootGapMm: rootGapMm,
      primaryBevelAngleDeg: primaryBevelAngleDeg,
      secondaryBevelAngleDeg: secondaryBevelAngleDeg,
      breakHeightMm: breakHeightMm,
    );

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

  static double capReinforcementAreaMm2({
    required double grooveTopWidthMm,
    required double capOverlapMm,
    required double capHeightMm,
  }) => (grooveTopWidthMm + 2 * capOverlapMm) * capHeightMm;

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

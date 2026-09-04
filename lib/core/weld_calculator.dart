import '../models/weld_models.dart';
import 'weld_formulas.dart';
import 'welding_defaults.dart';

class WeldCalculator {
  const WeldCalculator();

  WeldCalculationResult calculate(WeldInputData input) {
    _validateCommon(input);
    _validateCompatibility(input);

    final lengthMm = _resolveLength(input);
    final grooveAreaMm2 = _resolveArea(input);
    final capAreaMm2 = input.grooveType == GrooveType.fillet
        ? 0.0
        : _resolveCapAreaMm2(input, _resolveGrooveTopWidthMm(input));
    final areaMm2 = grooveAreaMm2 + capAreaMm2;
    final volumeCm3 = WeldFormulas.volumeCm3(
      areaMm2: areaMm2,
      lengthMm: lengthMm,
    );
    final weldMetalKg = WeldFormulas.weldMetalKg(
      volumeCm3: volumeCm3,
      densityGPerCm3: input.densityGPerCm3,
    );
    final processSummary = input.weldingProcess == WeldingProcess.gtawSmaw
        ? _combinedGtawSmawSummary(
            input,
            areaMm2,
            grooveAreaMm2,
            weldMetalKg,
          )
        : _singleProcessSummary(input, weldMetalKg);

    return WeldCalculationResult(
      areaMm2: areaMm2,
      lengthMm: lengthMm,
      volumeCm3: volumeCm3,
      weldMetalKg: weldMetalKg,
      fillerKg: processSummary.fillerKg,
      arcTimeHours: processSummary.arcTimeHours,
      depositionEfficiency: processSummary.depositionEfficiency,
      depositionRateKgPerHour: processSummary.depositionRateKgPerHour,
      processBreakdowns: processSummary.processBreakdowns,
    );
  }

  void _validateCommon(WeldInputData input) {
    if (input.quantity <= 0) {
      throw const InputValidationException('Quantity must be greater than 0.');
    }
    if (input.densityGPerCm3 <= 0) {
      throw const InputValidationException(
        'Density must be greater than 0 g/cm3.',
      );
    }
    if (input.wasteFactorPercent < 0) {
      throw const InputValidationException('Waste factor cannot be negative.');
    }
  }

  void _validateCompatibility(WeldInputData input) {
    if (!input.jointType.supportedGrooves.contains(input.grooveType)) {
      throw const InputValidationException(
        'Selected groove type is not compatible with the joint type.',
      );
    }

    if (input.depositionRateMode == DepositionRateMode.manual) {
      if (input.weldingProcess == WeldingProcess.gtawSmaw) {
        _requirePositive(input.manualGtawRateKgPerHour, 'Manual GTAW rate');
        _requirePositive(input.manualSmawRateKgPerHour, 'Manual SMAW rate');
      } else {
        _requirePositive(
          input.manualDepositionRateKgPerHour,
          'Manual deposition rate',
        );
      }
    }
  }

  _ProcessSummary _singleProcessSummary(
    WeldInputData input,
    double weldMetalKg,
  ) {
    final efficiency = WeldingDefaults.efficiencyFor(input.weldingProcess);
    final depositionRate = _resolveDepositionRate(input);
    final fillerKg = WeldFormulas.fillerKg(
      weldMetalKg: weldMetalKg,
      depositionEfficiency: efficiency,
      wasteFactorPercent: input.wasteFactorPercent,
    );
    final arcTimeHours = WeldFormulas.arcTimeHours(
      fillerKg: fillerKg,
      depositionRateKgPerHour: depositionRate,
    );

    return _ProcessSummary(
      fillerKg: fillerKg,
      arcTimeHours: arcTimeHours,
      depositionEfficiency: efficiency,
      depositionRateKgPerHour: depositionRate,
      processBreakdowns: [
        ProcessBreakdown(
          process: input.weldingProcess,
          weldMetalKg: weldMetalKg,
          fillerKg: fillerKg,
          arcTimeHours: arcTimeHours,
          depositionEfficiency: efficiency,
          depositionRateKgPerHour: depositionRate,
          sharePercent: 1,
        ),
      ],
    );
  }

  _ProcessSummary _combinedGtawSmawSummary(
    WeldInputData input,
    double totalAreaMm2,
    double grooveAreaMm2,
    double totalWeldMetalKg,
  ) {
    // The GTAW root pass never includes the cap-reinforcement area (the cap
    // is always the final/last pass, 100% SMAW) -- so its share must be
    // computed against the groove-only area, then re-expressed as a ratio
    // of the (possibly cap-inflated) total area for the split below.
    final gtawAreaMm2 = _resolveGtawAreaForCombined(input, grooveAreaMm2);
    final gtawRatio = totalAreaMm2 == 0 ? 0.0 : gtawAreaMm2 / totalAreaMm2;
    final gtawWeldMetalKg = totalWeldMetalKg * gtawRatio;
    final smawWeldMetalKg = totalWeldMetalKg - gtawWeldMetalKg;
    final gtawEfficiency = WeldingDefaults.efficiencyFor(WeldingProcess.gtaw);
    final smawEfficiency = WeldingDefaults.efficiencyFor(WeldingProcess.smaw);
    final gtawRate = _resolveCombinedGtawRate(input);
    final smawRate = _resolveCombinedSmawRate(input);
    final gtawFillerKg = WeldFormulas.fillerKg(
      weldMetalKg: gtawWeldMetalKg,
      depositionEfficiency: gtawEfficiency,
      wasteFactorPercent: input.wasteFactorPercent,
    );
    final smawFillerKg = WeldFormulas.fillerKg(
      weldMetalKg: smawWeldMetalKg,
      depositionEfficiency: smawEfficiency,
      wasteFactorPercent: input.wasteFactorPercent,
    );
    final totalFillerKg = gtawFillerKg + smawFillerKg;
    final arcTimeHours =
        WeldFormulas.arcTimeHours(
          fillerKg: gtawFillerKg,
          depositionRateKgPerHour: gtawRate,
        ) +
        WeldFormulas.arcTimeHours(
          fillerKg: smawFillerKg,
          depositionRateKgPerHour: smawRate,
        );
    final wasteMultiplier = 1.0 + (input.wasteFactorPercent / 100);
    final effectiveEfficiency = totalFillerKg == 0
        ? 0.0
        : (totalWeldMetalKg * wasteMultiplier) / totalFillerKg;
    final effectiveRate = arcTimeHours == 0
        ? 0.0
        : totalFillerKg / arcTimeHours;

    return _ProcessSummary(
      fillerKg: totalFillerKg,
      arcTimeHours: arcTimeHours,
      depositionEfficiency: effectiveEfficiency,
      depositionRateKgPerHour: effectiveRate,
      processBreakdowns: [
        ProcessBreakdown(
          process: WeldingProcess.gtaw,
          weldMetalKg: gtawWeldMetalKg,
          fillerKg: gtawFillerKg,
          arcTimeHours: WeldFormulas.arcTimeHours(
            fillerKg: gtawFillerKg,
            depositionRateKgPerHour: gtawRate,
          ),
          depositionEfficiency: gtawEfficiency,
          depositionRateKgPerHour: gtawRate,
          sharePercent: gtawRatio,
        ),
        ProcessBreakdown(
          process: WeldingProcess.smaw,
          weldMetalKg: smawWeldMetalKg,
          fillerKg: smawFillerKg,
          arcTimeHours: WeldFormulas.arcTimeHours(
            fillerKg: smawFillerKg,
            depositionRateKgPerHour: smawRate,
          ),
          depositionEfficiency: smawEfficiency,
          depositionRateKgPerHour: smawRate,
          sharePercent: 1.0 - gtawRatio,
        ),
      ],
    );
  }

  double _resolveLength(WeldInputData input) => switch (input.jointType) {
    JointType.pipeButt => WeldFormulas.circumferenceLengthMm(
      pipeOdMm: _requirePositive(input.pipeOdMm, 'Pipe OD'),
      quantity: input.quantity,
    ),
    JointType.plateButt => WeldFormulas.straightLengthMm(
      lengthPerPieceMm: _requirePositive(input.lengthPerPieceMm, 'Weld length'),
      quantity: input.quantity,
    ),
    JointType.fillet => WeldFormulas.straightLengthMm(
      lengthPerPieceMm: _requirePositive(input.lengthPerPieceMm, 'Weld length'),
      quantity: input.quantity,
    ),
  };

  double _resolveArea(WeldInputData input) => switch (input.grooveType) {
    GrooveType.square => WeldFormulas.squareButtAreaMm2(
      thicknessMm: _requirePositive(input.thicknessMm, 'Thickness'),
      rootGapMm: _requireZeroOrPositive(input.rootGapMm, 'Root gap'),
    ),
    GrooveType.singleV => _singleVArea(input),
    GrooveType.halfV => _halfVArea(input),
    GrooveType.doubleV => _doubleVArea(input),
    GrooveType.compoundV => _compoundVArea(input),
    GrooveType.fillet => WeldFormulas.filletAreaMm2(
      legSizeMm: _requirePositive(input.legSizeMm, 'Leg size'),
    ),
  };

  double _resolveGrooveTopWidthMm(WeldInputData input) =>
      switch (input.grooveType) {
        GrooveType.square => _requireZeroOrPositive(
          input.rootGapMm,
          'Root gap',
        ),
        GrooveType.singleV => WeldFormulas.singleVTopWidthMm(
          thicknessMm: _requirePositive(input.thicknessMm, 'Thickness'),
          rootFaceMm: _requireZeroOrPositive(input.rootFaceMm, 'Root face'),
          rootGapMm: _requireZeroOrPositive(input.rootGapMm, 'Root gap'),
          bevelAngleDeg: _requirePositive(input.bevelAngleDeg, 'Bevel angle'),
        ),
        GrooveType.halfV => WeldFormulas.halfVTopWidthMm(
          thicknessMm: _requirePositive(input.thicknessMm, 'Thickness'),
          rootFaceMm: _requireZeroOrPositive(input.rootFaceMm, 'Root face'),
          rootGapMm: _requireZeroOrPositive(input.rootGapMm, 'Root gap'),
          bevelAngleDeg: _requirePositive(input.bevelAngleDeg, 'Bevel angle'),
        ),
        GrooveType.doubleV => WeldFormulas.doubleVTopWidthMm(
          thicknessMm: _requirePositive(input.thicknessMm, 'Thickness'),
          rootFaceMm: _requireZeroOrPositive(input.rootFaceMm, 'Root face'),
          rootGapMm: _requireZeroOrPositive(input.rootGapMm, 'Root gap'),
          bevelAngleDeg: _requirePositive(input.bevelAngleDeg, 'Bevel angle'),
        ),
        GrooveType.compoundV => WeldFormulas.compoundVTopWidthMm(
          thicknessMm: _requirePositive(input.thicknessMm, 'Thickness'),
          rootFaceMm: _requireZeroOrPositive(input.rootFaceMm, 'Root face'),
          rootGapMm: _requireZeroOrPositive(input.rootGapMm, 'Root gap'),
          primaryBevelAngleDeg: _requirePositive(
            input.bevelAngleDeg,
            'Primary bevel angle',
          ),
          secondaryBevelAngleDeg: _requirePositive(
            input.secondaryBevelAngleDeg,
            'Secondary bevel angle',
          ),
          breakHeightMm: _requirePositive(input.breakHeightMm, 'Break height'),
        ),
        GrooveType.fillet => 0,
      };

  double _resolveCapAreaMm2(WeldInputData input, double grooveTopWidthMm) {
    if (input.capOverlapMm != null) {
      _requireZeroOrPositive(input.capOverlapMm, 'Cap overlap');
    }
    if (input.capHeightMm != null) {
      _requireZeroOrPositive(input.capHeightMm, 'Cap height');
    }

    final singleFaceCapAreaMm2 = WeldFormulas.capReinforcementAreaMm2(
      grooveTopWidthMm: grooveTopWidthMm,
      capOverlapMm: input.capOverlapMm ?? 0,
      capHeightMm: input.capHeightMm ?? 0,
    );

    // Double V is welded from both sides, so it gets a cap reinforcement
    // pass on BOTH faces -- the entered overlap/height values apply
    // identically to each face, so the area contribution is exactly 2x a
    // single-face groove type for the same inputs.
    return input.grooveType == GrooveType.doubleV
        ? singleFaceCapAreaMm2 * 2
        : singleFaceCapAreaMm2;
  }

  double _resolveGtawAreaForCombined(
    WeldInputData input,
    double grooveAreaMm2,
  ) {
    final transition = _requirePositive(
      input.gtawTransitionMm,
      'GTAW up to thickness',
    );

    return switch (input.grooveType) {
      GrooveType.square => WeldFormulas.squareButtPartialAreaFromRootMm2(
        thicknessMm: _requirePositive(input.thicknessMm, 'Thickness'),
        rootGapMm: _requireZeroOrPositive(input.rootGapMm, 'Root gap'),
        fillHeightMm: transition,
      ),
      GrooveType.singleV => WeldFormulas.singleVPartialAreaFromRootMm2(
        thicknessMm: _requirePositive(input.thicknessMm, 'Thickness'),
        rootFaceMm: _requireZeroOrPositive(input.rootFaceMm, 'Root face'),
        rootGapMm: _requireZeroOrPositive(input.rootGapMm, 'Root gap'),
        bevelAngleDeg: _requirePositive(input.bevelAngleDeg, 'Bevel angle'),
        fillHeightMm: transition,
      ),
      GrooveType.halfV => WeldFormulas.halfVPartialAreaFromRootMm2(
        thicknessMm: _requirePositive(input.thicknessMm, 'Thickness'),
        rootFaceMm: _requireZeroOrPositive(input.rootFaceMm, 'Root face'),
        rootGapMm: _requireZeroOrPositive(input.rootGapMm, 'Root gap'),
        bevelAngleDeg: _requirePositive(input.bevelAngleDeg, 'Bevel angle'),
        fillHeightMm: transition,
      ),
      GrooveType.compoundV => WeldFormulas.compoundVPartialAreaFromRootMm2(
        thicknessMm: _requirePositive(input.thicknessMm, 'Thickness'),
        rootFaceMm: _requireZeroOrPositive(input.rootFaceMm, 'Root face'),
        rootGapMm: _requireZeroOrPositive(input.rootGapMm, 'Root gap'),
        primaryBevelAngleDeg: _requirePositive(
          input.bevelAngleDeg,
          'Primary bevel angle',
        ),
        secondaryBevelAngleDeg: _requirePositive(
          input.secondaryBevelAngleDeg,
          'Secondary bevel angle',
        ),
        breakHeightMm: _requirePositive(input.breakHeightMm, 'Break height'),
        fillHeightMm: transition,
      ),
      GrooveType.doubleV => _resolveDoubleVGtawArea(input, grooveAreaMm2),
      GrooveType.fillet => WeldFormulas.filletPartialAreaFromRootMm2(
        legSizeMm: _requirePositive(input.legSizeMm, 'Leg size'),
        fillHeightMm: transition,
      ),
    };
  }

  double _resolveDoubleVGtawArea(WeldInputData input, double grooveAreaMm2) {
    final thickness = _requirePositive(input.thicknessMm, 'Thickness');
    final transition = _requirePositive(
      input.gtawTransitionMm,
      'GTAW up to thickness',
    );
    final ratio = (transition / thickness).clamp(0.0, 1.0);
    // groove-only area (cap-reinforcement area is excluded here and added
    // entirely to the SMAW/final-pass side by the caller).
    return grooveAreaMm2 * ratio;
  }

  double _singleVArea(WeldInputData input) {
    final thickness = _requirePositive(input.thicknessMm, 'Thickness');
    final rootFace = _requireZeroOrPositive(input.rootFaceMm, 'Root face');
    final rootGap = _requireZeroOrPositive(input.rootGapMm, 'Root gap');
    final bevelAngle = _requirePositive(input.bevelAngleDeg, 'Bevel angle');

    if (rootFace >= thickness) {
      throw const InputValidationException(
        'Root face must be smaller than thickness for Single V.',
      );
    }
    if (bevelAngle >= 90) {
      throw const InputValidationException(
        'Bevel angle must be smaller than 90 degrees.',
      );
    }

    return WeldFormulas.singleVAreaMm2(
      thicknessMm: thickness,
      rootFaceMm: rootFace,
      rootGapMm: rootGap,
      bevelAngleDeg: bevelAngle,
    );
  }

  double _doubleVArea(WeldInputData input) {
    final thickness = _requirePositive(input.thicknessMm, 'Thickness');
    final rootFace = _requireZeroOrPositive(input.rootFaceMm, 'Root face');
    final rootGap = _requireZeroOrPositive(input.rootGapMm, 'Root gap');
    final bevelAngle = _requirePositive(input.bevelAngleDeg, 'Bevel angle');

    if (rootFace >= thickness / 2) {
      throw const InputValidationException(
        'Root face must be smaller than half the thickness for Double V.',
      );
    }
    if (bevelAngle >= 90) {
      throw const InputValidationException(
        'Bevel angle must be smaller than 90 degrees.',
      );
    }

    return WeldFormulas.doubleVAreaMm2(
      thicknessMm: thickness,
      rootFaceMm: rootFace,
      rootGapMm: rootGap,
      bevelAngleDeg: bevelAngle,
    );
  }

  double _compoundVArea(WeldInputData input) {
    final thickness = _requirePositive(input.thicknessMm, 'Thickness');
    final rootFace = _requireZeroOrPositive(input.rootFaceMm, 'Root face');
    final rootGap = _requireZeroOrPositive(input.rootGapMm, 'Root gap');
    final primaryAngle = _requirePositive(
      input.bevelAngleDeg,
      'Primary bevel angle',
    );
    final secondaryAngle = _requirePositive(
      input.secondaryBevelAngleDeg,
      'Secondary bevel angle',
    );
    final breakHeight = _requirePositive(input.breakHeightMm, 'Break height');

    final usableHeight = thickness - rootFace;
    if (rootFace >= thickness) {
      throw const InputValidationException(
        'Root face must be smaller than thickness for Compound V.',
      );
    }
    if (breakHeight >= usableHeight) {
      throw const InputValidationException(
        'Break height must be smaller than groove height for Compound V.',
      );
    }
    if (primaryAngle >= 90 || secondaryAngle >= 90) {
      throw const InputValidationException(
        'Both bevel angles must be smaller than 90 degrees.',
      );
    }

    return WeldFormulas.compoundVAreaMm2(
      thicknessMm: thickness,
      rootFaceMm: rootFace,
      rootGapMm: rootGap,
      primaryBevelAngleDeg: primaryAngle,
      secondaryBevelAngleDeg: secondaryAngle,
      breakHeightMm: breakHeight,
    );
  }

  double _halfVArea(WeldInputData input) {
    final thickness = _requirePositive(input.thicknessMm, 'Thickness');
    final rootFace = _requireZeroOrPositive(input.rootFaceMm, 'Root face');
    final rootGap = _requireZeroOrPositive(input.rootGapMm, 'Root gap');
    final bevelAngle = _requirePositive(input.bevelAngleDeg, 'Bevel angle');

    if (rootFace >= thickness) {
      throw const InputValidationException(
        'Root face must be smaller than thickness for Half V.',
      );
    }
    if (bevelAngle >= 90) {
      throw const InputValidationException(
        'Bevel angle must be smaller than 90 degrees.',
      );
    }

    return WeldFormulas.halfVAreaMm2(
      thicknessMm: thickness,
      rootFaceMm: rootFace,
      rootGapMm: rootGap,
      bevelAngleDeg: bevelAngle,
    );
  }

  double _resolveDepositionRate(WeldInputData input) {
    if (input.depositionRateMode == DepositionRateMode.manual) {
      return _requirePositive(
        input.manualDepositionRateKgPerHour,
        'Manual deposition rate',
      );
    }

    return switch (input.weldingProcess) {
      WeldingProcess.gtaw => WeldingDefaults.gtawRateForWire(
        input.wireDiameterMm,
      ),
      WeldingProcess.smaw => WeldingDefaults.smawRateForElectrode(
        input.electrodeDiameterMm,
      ),
      WeldingProcess.gtawSmaw => WeldingDefaults.depositionRateFor(
        WeldingProcess.gtawSmaw,
      ),
      WeldingProcess.gmaw => WeldingDefaults.gmawRateForWire(
        input.wireDiameterMm,
      ),
      WeldingProcess.fcaw => WeldingDefaults.fcawRateForWire(
        input.wireDiameterMm,
      ),
    };
  }

  double _resolveCombinedGtawRate(WeldInputData input) {
    if (input.depositionRateMode == DepositionRateMode.manual) {
      return _requirePositive(
        input.manualGtawRateKgPerHour,
        'Manual GTAW rate',
      );
    }
    return WeldingDefaults.gtawRateForWire(input.gtawWireDiameterMm);
  }

  double _resolveCombinedSmawRate(WeldInputData input) {
    if (input.depositionRateMode == DepositionRateMode.manual) {
      return _requirePositive(
        input.manualSmawRateKgPerHour,
        'Manual SMAW rate',
      );
    }
    return WeldingDefaults.smawRateForElectrode(input.smawElectrodeDiameterMm);
  }

  double _requirePositive(double? value, String label) {
    if (value == null || value <= 0) {
      throw InputValidationException('$label must be greater than 0.');
    }
    return value;
  }

  double _requireZeroOrPositive(double? value, String label) {
    if (value == null || value < 0) {
      throw InputValidationException('$label cannot be negative.');
    }
    return value;
  }
}

class _ProcessSummary {
  const _ProcessSummary({
    required this.fillerKg,
    required this.arcTimeHours,
    required this.depositionEfficiency,
    required this.depositionRateKgPerHour,
    required this.processBreakdowns,
  });

  final double fillerKg;
  final double arcTimeHours;
  final double depositionEfficiency;
  final double depositionRateKgPerHour;
  final List<ProcessBreakdown> processBreakdowns;
}

import '../l10n/strings.dart';
import 'consumable_selection.dart';

enum JointType { pipeButt, plateButt, fillet }

enum GrooveType { singleV, halfV, doubleV, compoundV, square, fillet }

enum WeldingProcess { gtaw, smaw, gtawSmaw, gmaw, fcaw }

enum DepositionRateMode { preset, manual }

enum JointGeometryMode { equal, unequal }

enum JointAlignment { centerline, odMatch, idMatch }

enum ConsumableFamily {
  carbonSteel,
  stainlessSteel,
  dissimilar,
  aluminium,
  lowAlloySteel,
  nickelAlloy,
  copperAlloy,
  castIron,
}

enum ConsumablePreset {
  er70s6,
  er70s2,
  e7018,
  e6010,
  e71t1,
  er308l,
  e308l16,
  er316l,
  er309l,
  e309l16,
  er5356,
  gtawRootSmawFill,
  e6013,
  e7024,
  er70s3,
  e7018a1,
  e8018c3,
  er80sNi1,
  er80sB2,
  e316l16,
  er347,
  er4043,
  er5183,
  eniCi,
  enifeCi,
  ernicr3,
  enicrfe3,
  ercusiA,
  ecualA2,
}

enum InputPreset {
  custom,
  csPipeSingleVGtawSmaw,
  csPipeDoubleVGtawSmaw,
  ssPipeSingleVGtaw,
  csPlateSingleVGmaw,
  csPlateDoubleVSmaw,
  csFilletFcaw,
}

extension JointTypeX on JointType {
  String get label => switch (this) {
    JointType.pipeButt => 'Pipe Butt Weld',
    JointType.plateButt => 'Plate Butt Weld',
    JointType.fillet => 'Fillet Weld',
  };

  String get helper => switch (this) {
    JointType.pipeButt =>
      'Total weld length is calculated from pipe outside diameter x quantity.',
    JointType.plateButt =>
      'Total weld length is calculated from weld run length x quantity.',
    JointType.fillet =>
      'Fillet weld area is based on equal-leg geometry and entered weld length.',
  };

  // `label`/`helper` above stay plain English -- weld_pdf_report_service.dart
  // depends on them for the (separately scoped) PDF export. UI call sites
  // use these localized counterparts instead.
  String labelFor(L10nStrings strings) => switch (this) {
    JointType.pipeButt => strings.jointTypePipeButt,
    JointType.plateButt => strings.jointTypePlateButt,
    JointType.fillet => strings.jointTypeFillet,
  };

  String helperFor(L10nStrings strings) => switch (this) {
    JointType.pipeButt => strings.jointTypeHelperPipeButt,
    JointType.plateButt => strings.jointTypeHelperPlateButt,
    JointType.fillet => strings.jointTypeHelperFillet,
  };

  List<GrooveType> get supportedGrooves => switch (this) {
    JointType.pipeButt => const [
      GrooveType.singleV,
      GrooveType.halfV,
      GrooveType.doubleV,
      GrooveType.compoundV,
      GrooveType.square,
    ],
    JointType.plateButt => const [
      GrooveType.singleV,
      GrooveType.halfV,
      GrooveType.doubleV,
      GrooveType.square,
    ],
    JointType.fillet => const [GrooveType.fillet],
  };
}

extension GrooveTypeX on GrooveType {
  String get label => switch (this) {
    GrooveType.singleV => 'Single V',
    GrooveType.halfV => 'Half V',
    GrooveType.doubleV => 'Double V',
    GrooveType.compoundV => 'Compound V',
    GrooveType.square => 'Square',
    GrooveType.fillet => 'Fillet',
  };

  String labelFor(L10nStrings strings) => switch (this) {
    GrooveType.singleV => strings.grooveSingleV,
    GrooveType.halfV => strings.grooveHalfV,
    GrooveType.doubleV => strings.grooveDoubleV,
    GrooveType.compoundV => strings.grooveCompoundV,
    GrooveType.square => strings.grooveSquare,
    GrooveType.fillet => strings.grooveFillet,
  };
}

extension WeldingProcessX on WeldingProcess {
  // Never localized -- GTAW/SMAW/GMAW/FCAW are international AWS process
  // abbreviations, not prose (explicit user decision), so this label is
  // already identical across every supported locale.
  String get label => switch (this) {
    WeldingProcess.gtaw => 'GTAW',
    WeldingProcess.smaw => 'SMAW',
    WeldingProcess.gtawSmaw => 'GTAW + SMAW',
    WeldingProcess.gmaw => 'GMAW',
    WeldingProcess.fcaw => 'FCAW',
  };
}

extension DepositionRateModeX on DepositionRateMode {
  String get label => switch (this) {
    DepositionRateMode.preset => 'Estimated',
    DepositionRateMode.manual => 'Manual',
  };

  String labelFor(L10nStrings strings) => switch (this) {
    DepositionRateMode.preset => strings.depositionRateModePreset,
    DepositionRateMode.manual => strings.depositionRateModeManual,
  };
}

extension JointGeometryModeX on JointGeometryMode {
  String get label => switch (this) {
    JointGeometryMode.equal => 'Equal',
    JointGeometryMode.unequal => 'Unequal',
  };

  String labelFor(L10nStrings strings) => switch (this) {
    JointGeometryMode.equal => strings.jointGeometryEqual,
    JointGeometryMode.unequal => strings.jointGeometryUnequal,
  };
}

extension JointAlignmentX on JointAlignment {
  String get label => switch (this) {
    JointAlignment.centerline => 'Centerline Match',
    JointAlignment.odMatch => 'OD Match',
    JointAlignment.idMatch => 'ID Match',
  };

  String labelFor(L10nStrings strings) => switch (this) {
    JointAlignment.centerline => strings.jointAlignmentCenterline,
    JointAlignment.odMatch => strings.jointAlignmentOdMatch,
    JointAlignment.idMatch => strings.jointAlignmentIdMatch,
  };
}

extension ConsumableFamilyX on ConsumableFamily {
  String get label => switch (this) {
    ConsumableFamily.carbonSteel => 'Carbon Steel',
    ConsumableFamily.stainlessSteel => 'Stainless Steel',
    ConsumableFamily.dissimilar => 'Dissimilar',
    ConsumableFamily.aluminium => 'Aluminium',
    ConsumableFamily.lowAlloySteel => 'Low Alloy Steel',
    ConsumableFamily.nickelAlloy => 'Nickel Alloy',
    ConsumableFamily.copperAlloy => 'Copper Alloy',
    ConsumableFamily.castIron => 'Cast Iron',
  };

  String labelFor(L10nStrings strings) => switch (this) {
    ConsumableFamily.carbonSteel => strings.consumableFamilyCarbonSteel,
    ConsumableFamily.stainlessSteel => strings.consumableFamilyStainlessSteel,
    ConsumableFamily.dissimilar => strings.consumableFamilyDissimilar,
    ConsumableFamily.aluminium => strings.consumableFamilyAluminium,
    ConsumableFamily.lowAlloySteel => strings.consumableFamilyLowAlloySteel,
    ConsumableFamily.nickelAlloy => strings.consumableFamilyNickelAlloy,
    ConsumableFamily.copperAlloy => strings.consumableFamilyCopperAlloy,
    ConsumableFamily.castIron => strings.consumableFamilyCastIron,
  };
}

extension ConsumablePresetX on ConsumablePreset {
  String get label => switch (this) {
    ConsumablePreset.er70s6 => 'ER70S-6',
    ConsumablePreset.er70s2 => 'ER70S-2',
    ConsumablePreset.e7018 => 'E7018',
    ConsumablePreset.e6010 => 'E6010',
    ConsumablePreset.e71t1 => 'E71T-1',
    ConsumablePreset.er308l => 'ER308L',
    ConsumablePreset.e308l16 => 'E308L-16',
    ConsumablePreset.er316l => 'ER316L',
    ConsumablePreset.er309l => 'ER309L',
    ConsumablePreset.e309l16 => 'E309L-16',
    ConsumablePreset.er5356 => 'ER5356',
    ConsumablePreset.gtawRootSmawFill => 'ER70S-2 + E7018',
    ConsumablePreset.e6013 => 'E6013',
    ConsumablePreset.e7024 => 'E7024',
    ConsumablePreset.er70s3 => 'ER70S-3',
    ConsumablePreset.e7018a1 => 'E7018-A1',
    ConsumablePreset.e8018c3 => 'E8018-C3',
    ConsumablePreset.er80sNi1 => 'ER80S-Ni1',
    ConsumablePreset.er80sB2 => 'ER80S-B2',
    ConsumablePreset.e316l16 => 'E316L-16',
    ConsumablePreset.er347 => 'ER347',
    ConsumablePreset.er4043 => 'ER4043',
    ConsumablePreset.er5183 => 'ER5183',
    ConsumablePreset.eniCi => 'ENi-CI',
    ConsumablePreset.enifeCi => 'ENiFe-CI',
    ConsumablePreset.ernicr3 => 'ERNiCr-3',
    ConsumablePreset.enicrfe3 => 'ENiCrFe-3',
    ConsumablePreset.ercusiA => 'ERCuSi-A',
    ConsumablePreset.ecualA2 => 'ECuAl-A2',
  };

  ConsumableFamily get family => switch (this) {
    ConsumablePreset.er70s6 => ConsumableFamily.carbonSteel,
    ConsumablePreset.er70s2 => ConsumableFamily.carbonSteel,
    ConsumablePreset.e7018 => ConsumableFamily.carbonSteel,
    ConsumablePreset.e6010 => ConsumableFamily.carbonSteel,
    ConsumablePreset.e71t1 => ConsumableFamily.carbonSteel,
    ConsumablePreset.er308l => ConsumableFamily.stainlessSteel,
    ConsumablePreset.e308l16 => ConsumableFamily.stainlessSteel,
    ConsumablePreset.er316l => ConsumableFamily.stainlessSteel,
    ConsumablePreset.er309l => ConsumableFamily.dissimilar,
    ConsumablePreset.e309l16 => ConsumableFamily.dissimilar,
    ConsumablePreset.er5356 => ConsumableFamily.aluminium,
    ConsumablePreset.gtawRootSmawFill => ConsumableFamily.carbonSteel,
    ConsumablePreset.e6013 => ConsumableFamily.carbonSteel,
    ConsumablePreset.e7024 => ConsumableFamily.carbonSteel,
    ConsumablePreset.er70s3 => ConsumableFamily.carbonSteel,
    ConsumablePreset.e7018a1 => ConsumableFamily.lowAlloySteel,
    ConsumablePreset.e8018c3 => ConsumableFamily.lowAlloySteel,
    ConsumablePreset.er80sNi1 => ConsumableFamily.lowAlloySteel,
    ConsumablePreset.er80sB2 => ConsumableFamily.lowAlloySteel,
    ConsumablePreset.e316l16 => ConsumableFamily.stainlessSteel,
    ConsumablePreset.er347 => ConsumableFamily.stainlessSteel,
    ConsumablePreset.er4043 => ConsumableFamily.aluminium,
    ConsumablePreset.er5183 => ConsumableFamily.aluminium,
    ConsumablePreset.eniCi => ConsumableFamily.castIron,
    ConsumablePreset.enifeCi => ConsumableFamily.castIron,
    ConsumablePreset.ernicr3 => ConsumableFamily.nickelAlloy,
    ConsumablePreset.enicrfe3 => ConsumableFamily.nickelAlloy,
    ConsumablePreset.ercusiA => ConsumableFamily.copperAlloy,
    ConsumablePreset.ecualA2 => ConsumableFamily.copperAlloy,
  };

  String get displayLabel => '$label (${family.label})';

  String get awsSpecification => switch (this) {
    ConsumablePreset.er70s6 => 'AWS A5.18',
    ConsumablePreset.er70s2 => 'AWS A5.18',
    ConsumablePreset.e7018 => 'AWS A5.1',
    ConsumablePreset.e6010 => 'AWS A5.1',
    ConsumablePreset.e71t1 => 'AWS A5.20',
    ConsumablePreset.er308l => 'AWS A5.9',
    ConsumablePreset.e308l16 => 'AWS A5.4',
    ConsumablePreset.er316l => 'AWS A5.9',
    ConsumablePreset.er309l => 'AWS A5.9',
    ConsumablePreset.e309l16 => 'AWS A5.4',
    ConsumablePreset.er5356 => 'AWS A5.10',
    ConsumablePreset.gtawRootSmawFill => 'AWS A5.18 + AWS A5.1',
    ConsumablePreset.e6013 => 'AWS A5.1',
    ConsumablePreset.e7024 => 'AWS A5.1',
    ConsumablePreset.er70s3 => 'AWS A5.18',
    ConsumablePreset.e7018a1 => 'AWS A5.5',
    ConsumablePreset.e8018c3 => 'AWS A5.5',
    ConsumablePreset.er80sNi1 => 'AWS A5.28',
    ConsumablePreset.er80sB2 => 'AWS A5.28',
    ConsumablePreset.e316l16 => 'AWS A5.4',
    ConsumablePreset.er347 => 'AWS A5.9',
    ConsumablePreset.er4043 => 'AWS A5.10',
    ConsumablePreset.er5183 => 'AWS A5.10',
    ConsumablePreset.eniCi => 'AWS A5.15',
    ConsumablePreset.enifeCi => 'AWS A5.15',
    ConsumablePreset.ernicr3 => 'AWS A5.14',
    ConsumablePreset.enicrfe3 => 'AWS A5.11',
    ConsumablePreset.ercusiA => 'AWS A5.7',
    ConsumablePreset.ecualA2 => 'AWS A5.6',
  };

  String get awsDisplayLabel => '$awsSpecification $label (${family.label})';

  // `label`/`awsSpecification` are AWS classification codes (ER70S-6, AWS
  // A5.18, etc.) and never translated (explicit user decision) -- only the
  // family name in parentheses is localized here.
  String awsDisplayLabelFor(L10nStrings strings) =>
      '$awsSpecification $label (${family.labelFor(strings)})';

  // Base-metal designation lists (ASTM/aluminum-series codes mixed with a
  // little prose) are left English-only for now -- translating ~30 lists of
  // mostly-standard-code text is a disclosed follow-up, not done in this
  // pass (see coder task report).
  List<String> get typicalBaseMetals => switch (this) {
    ConsumablePreset.er70s6 => const ['ASTM A36', 'ASTM A106', 'ASTM A53'],
    ConsumablePreset.er70s2 => const ['ASTM A36', 'ASTM A106', 'ASTM A53'],
    ConsumablePreset.e7018 => const ['ASTM A36', 'ASTM A106', 'ASTM A53'],
    ConsumablePreset.e6010 => const ['ASTM A36', 'ASTM A106', 'ASTM A53'],
    ConsumablePreset.e71t1 => const ['ASTM A36', 'ASTM A106', 'ASTM A53'],
    ConsumablePreset.gtawRootSmawFill => const [
      'ASTM A36',
      'ASTM A106',
      'ASTM A53',
    ],
    ConsumablePreset.er308l => const [
      'ASTM A312 TP304/TP304L',
      'ASTM A240 304/304L (UNS S30400/S30403)',
    ],
    ConsumablePreset.e308l16 => const [
      'ASTM A312 TP304/TP304L',
      'ASTM A240 304/304L (UNS S30400/S30403)',
    ],
    ConsumablePreset.er316l => const [
      'ASTM A312 TP316/TP316L',
      'ASTM A240 316/316L (UNS S31600/S31603)',
    ],
    ConsumablePreset.er309l => const [
      'Dissimilar transition joints, e.g. ASTM A106 carbon steel to ASTM A312 TP304L stainless',
    ],
    ConsumablePreset.e309l16 => const [
      'Dissimilar transition joints, e.g. ASTM A106 carbon steel to ASTM A312 TP304L stainless',
    ],
    ConsumablePreset.er5356 => const ['5xxx-series aluminium alloys'],
    ConsumablePreset.e6013 => const [
      'ASTM A36',
      'ASTM A53',
      'EN S235JR',
      'GB/T Q235',
    ],
    ConsumablePreset.e7024 => const ['ASTM A36', 'ASTM A53'],
    ConsumablePreset.er70s3 => const ['ASTM A36', 'ASTM A53'],
    ConsumablePreset.e7018a1 => const ['ASTM A335 P1', 'ASTM A106 Gr B'],
    ConsumablePreset.e8018c3 => const ['ASTM A203', 'ASTM A537'],
    ConsumablePreset.er80sNi1 => const ['ASTM A333 Gr 6', 'ASTM A420 WPL3'],
    ConsumablePreset.er80sB2 => const ['ASTM A335 P11'],
    ConsumablePreset.e316l16 => const [
      'ASTM A312 TP316/316L',
      'ASTM A240 316/316L',
    ],
    ConsumablePreset.er347 => const [
      'ASTM A312 TP347',
      'ASTM A240 347 (Nb-stabilized)',
    ],
    ConsumablePreset.er4043 => const [
      '6061 aluminum',
      '6063 aluminum',
      '356 aluminum castings',
    ],
    ConsumablePreset.er5183 => const [
      '5083 aluminum',
      '5456 aluminum (marine/high-Mg alloys)',
    ],
    ConsumablePreset.eniCi => const [
      'Gray cast iron',
      'Ductile cast iron repair',
    ],
    ConsumablePreset.enifeCi => const ['Ductile (nodular) cast iron'],
    ConsumablePreset.ernicr3 => const [
      'Inconel 600/601',
      'Dissimilar nickel-to-steel joints',
    ],
    ConsumablePreset.enicrfe3 => const [
      'Inconel 600',
      'Dissimilar nickel-to-steel joints',
    ],
    ConsumablePreset.ercusiA => const [
      'Copper',
      'Galvanized steel (braze-welding)',
    ],
    ConsumablePreset.ecualA2 => const [
      'Aluminum bronze parts',
      'Dissimilar copper-to-steel joints',
    ],
  };

  String get description => switch (this) {
    ConsumablePreset.er70s6 => 'Carbon steel solid wire or filler metal',
    ConsumablePreset.er70s2 => 'Carbon steel GTAW filler metal',
    ConsumablePreset.e7018 => 'Low-hydrogen carbon steel covered electrode',
    ConsumablePreset.e6010 => 'Cellulosic carbon steel root electrode',
    ConsumablePreset.e71t1 => 'Carbon steel flux-cored wire',
    ConsumablePreset.er308l => '308L stainless steel filler metal',
    ConsumablePreset.e308l16 => '308L stainless steel covered electrode',
    ConsumablePreset.er316l => '316L stainless steel filler metal',
    ConsumablePreset.er309l => '309L filler metal for dissimilar welds',
    ConsumablePreset.e309l16 => '309L covered electrode for dissimilar welds',
    ConsumablePreset.er5356 => '5356 aluminium filler metal',
    ConsumablePreset.gtawRootSmawFill =>
      'Typical carbon steel pipe root and fill combination',
    ConsumablePreset.e6013 =>
      'Rutile, easy-to-use general-purpose electrode, AC/DC',
    ConsumablePreset.e7024 =>
      'Iron-powder electrode, high deposition rate, flat/horizontal fillets',
    ConsumablePreset.er70s3 =>
      'General-purpose solid GMAW wire for carbon steel',
    ConsumablePreset.e7018a1 =>
      'Low-hydrogen electrode for 0.5% Mo alloy steel piping',
    ConsumablePreset.e8018c3 =>
      'Low-hydrogen electrode for nickel-bearing low-temperature steel (~1% Ni)',
    ConsumablePreset.er80sNi1 =>
      'Nickel-bearing low-alloy steel filler for low-temperature service',
    ConsumablePreset.er80sB2 =>
      'Chrome-moly filler for elevated-temperature piping',
    ConsumablePreset.e316l16 => 'SMAW electrode counterpart to ER316L',
    ConsumablePreset.er347 =>
      'Niobium-stabilized stainless filler for high-temperature/carbide-precipitation-resistant service',
    ConsumablePreset.er4043 =>
      'General-purpose 5% silicon aluminum filler, good flow/crack resistance',
    ConsumablePreset.er5183 =>
      'High-magnesium filler for marine and high-strength aluminum structures',
    ConsumablePreset.eniCi =>
      'Near-pure-nickel electrode for cast iron repair welding',
    ConsumablePreset.enifeCi =>
      'Nickel-iron electrode for higher-strength cast iron repairs',
    ConsumablePreset.ernicr3 =>
      'Nickel-chromium bare filler wire for Inconel and dissimilar-metal welds',
    ConsumablePreset.enicrfe3 =>
      'Nickel-chromium-iron electrode, SMAW counterpart use-case to ERNiCr-3',
    ConsumablePreset.ercusiA =>
      'Silicon bronze filler for copper and braze-welding applications',
    ConsumablePreset.ecualA2 =>
      'Aluminum bronze electrode for wear-resistant overlays and dissimilar joints',
  };

  String descriptionFor(L10nStrings strings) => switch (this) {
    ConsumablePreset.er70s6 => strings.consumablePresetDescEr70s6,
    ConsumablePreset.er70s2 => strings.consumablePresetDescEr70s2,
    ConsumablePreset.e7018 => strings.consumablePresetDescE7018,
    ConsumablePreset.e6010 => strings.consumablePresetDescE6010,
    ConsumablePreset.e71t1 => strings.consumablePresetDescE71t1,
    ConsumablePreset.er308l => strings.consumablePresetDescEr308l,
    ConsumablePreset.e308l16 => strings.consumablePresetDescE308l16,
    ConsumablePreset.er316l => strings.consumablePresetDescEr316l,
    ConsumablePreset.er309l => strings.consumablePresetDescEr309l,
    ConsumablePreset.e309l16 => strings.consumablePresetDescE309l16,
    ConsumablePreset.er5356 => strings.consumablePresetDescEr5356,
    ConsumablePreset.gtawRootSmawFill =>
      strings.consumablePresetDescGtawRootSmawFill,
    ConsumablePreset.e6013 => strings.consumablePresetDescE6013,
    ConsumablePreset.e7024 => strings.consumablePresetDescE7024,
    ConsumablePreset.er70s3 => strings.consumablePresetDescEr70s3,
    ConsumablePreset.e7018a1 => strings.consumablePresetDescE7018a1,
    ConsumablePreset.e8018c3 => strings.consumablePresetDescE8018c3,
    ConsumablePreset.er80sNi1 => strings.consumablePresetDescEr80sNi1,
    ConsumablePreset.er80sB2 => strings.consumablePresetDescEr80sB2,
    ConsumablePreset.e316l16 => strings.consumablePresetDescE316l16,
    ConsumablePreset.er347 => strings.consumablePresetDescEr347,
    ConsumablePreset.er4043 => strings.consumablePresetDescEr4043,
    ConsumablePreset.er5183 => strings.consumablePresetDescEr5183,
    ConsumablePreset.eniCi => strings.consumablePresetDescEniCi,
    ConsumablePreset.enifeCi => strings.consumablePresetDescEnifeCi,
    ConsumablePreset.ernicr3 => strings.consumablePresetDescErnicr3,
    ConsumablePreset.enicrfe3 => strings.consumablePresetDescEnicrfe3,
    ConsumablePreset.ercusiA => strings.consumablePresetDescErcusiA,
    ConsumablePreset.ecualA2 => strings.consumablePresetDescEcualA2,
  };

  double get densityGPerCm3 => switch (this) {
    ConsumablePreset.er70s6 => 7.85,
    ConsumablePreset.er70s2 => 7.85,
    ConsumablePreset.e7018 => 7.85,
    ConsumablePreset.e6010 => 7.85,
    ConsumablePreset.e71t1 => 7.85,
    ConsumablePreset.er308l => 7.90,
    ConsumablePreset.e308l16 => 7.90,
    ConsumablePreset.er316l => 7.98,
    ConsumablePreset.er309l => 7.90,
    ConsumablePreset.e309l16 => 7.90,
    ConsumablePreset.er5356 => 2.66,
    ConsumablePreset.gtawRootSmawFill => 7.85,
    ConsumablePreset.e6013 => 7.85,
    ConsumablePreset.e7024 => 7.85,
    ConsumablePreset.er70s3 => 7.85,
    ConsumablePreset.e7018a1 => 7.85,
    ConsumablePreset.e8018c3 => 7.85,
    ConsumablePreset.er80sNi1 => 7.85,
    ConsumablePreset.er80sB2 => 7.85,
    ConsumablePreset.e316l16 => 7.98,
    ConsumablePreset.er347 => 8.00,
    ConsumablePreset.er4043 => 2.68,
    ConsumablePreset.er5183 => 2.66,
    // density estimated from alloy composition
    ConsumablePreset.eniCi => 8.90,
    // density estimated from alloy composition
    ConsumablePreset.enifeCi => 8.20,
    // density estimated from alloy composition
    ConsumablePreset.ernicr3 => 8.30,
    // density estimated from alloy composition
    ConsumablePreset.enicrfe3 => 8.30,
    // density estimated from alloy composition
    ConsumablePreset.ercusiA => 8.50,
    // density estimated from alloy composition
    ConsumablePreset.ecualA2 => 7.70,
  };

  List<WeldingProcess> get supportedProcesses => switch (this) {
    ConsumablePreset.er70s6 => const [WeldingProcess.gtaw, WeldingProcess.gmaw],
    ConsumablePreset.er70s2 => const [WeldingProcess.gtaw],
    ConsumablePreset.e7018 => const [
      WeldingProcess.smaw,
      WeldingProcess.gtawSmaw,
    ],
    ConsumablePreset.e6010 => const [
      WeldingProcess.smaw,
      WeldingProcess.gtawSmaw,
    ],
    ConsumablePreset.e71t1 => const [WeldingProcess.fcaw],
    ConsumablePreset.er308l => const [WeldingProcess.gtaw, WeldingProcess.gmaw],
    ConsumablePreset.e308l16 => const [WeldingProcess.smaw],
    ConsumablePreset.er316l => const [WeldingProcess.gtaw, WeldingProcess.gmaw],
    ConsumablePreset.er309l => const [WeldingProcess.gtaw, WeldingProcess.gmaw],
    ConsumablePreset.e309l16 => const [WeldingProcess.smaw],
    ConsumablePreset.er5356 => const [WeldingProcess.gtaw, WeldingProcess.gmaw],
    ConsumablePreset.gtawRootSmawFill => const [WeldingProcess.gtawSmaw],
    ConsumablePreset.e6013 => const [WeldingProcess.smaw],
    ConsumablePreset.e7024 => const [WeldingProcess.smaw],
    ConsumablePreset.er70s3 => const [WeldingProcess.gmaw],
    ConsumablePreset.e7018a1 => const [WeldingProcess.smaw],
    ConsumablePreset.e8018c3 => const [WeldingProcess.smaw],
    ConsumablePreset.er80sNi1 => const [
      WeldingProcess.gtaw,
      WeldingProcess.gmaw,
    ],
    ConsumablePreset.er80sB2 => const [
      WeldingProcess.gtaw,
      WeldingProcess.gmaw,
    ],
    ConsumablePreset.e316l16 => const [WeldingProcess.smaw],
    ConsumablePreset.er347 => const [WeldingProcess.gtaw, WeldingProcess.gmaw],
    ConsumablePreset.er4043 => const [WeldingProcess.gtaw, WeldingProcess.gmaw],
    ConsumablePreset.er5183 => const [WeldingProcess.gtaw, WeldingProcess.gmaw],
    ConsumablePreset.eniCi => const [WeldingProcess.smaw],
    ConsumablePreset.enifeCi => const [WeldingProcess.smaw],
    ConsumablePreset.ernicr3 => const [
      WeldingProcess.gtaw,
      WeldingProcess.gmaw,
    ],
    ConsumablePreset.enicrfe3 => const [WeldingProcess.smaw],
    ConsumablePreset.ercusiA => const [
      WeldingProcess.gtaw,
      WeldingProcess.gmaw,
    ],
    ConsumablePreset.ecualA2 => const [WeldingProcess.smaw],
  };
}

extension InputPresetX on InputPreset {
  String get label => switch (this) {
    InputPreset.custom => 'Custom',
    InputPreset.csPipeSingleVGtawSmaw => 'CS Pipe Single V / GTAW + SMAW',
    InputPreset.csPipeDoubleVGtawSmaw => 'CS Pipe Double V / GTAW + SMAW',
    InputPreset.ssPipeSingleVGtaw => 'SS Pipe Single V / GTAW',
    InputPreset.csPlateSingleVGmaw => 'CS Plate Single V / GMAW',
    InputPreset.csPlateDoubleVSmaw => 'CS Plate Double V / SMAW',
    InputPreset.csFilletFcaw => 'CS Fillet / FCAW',
  };

  String get description => switch (this) {
    InputPreset.custom => 'Manual setup with no preset assumptions applied.',
    InputPreset.csPipeSingleVGtawSmaw =>
      'Carbon steel pipe root-pass plus fill-pass starter setup.',
    InputPreset.csPipeDoubleVGtawSmaw =>
      'Heavy-wall carbon steel pipe double-V starter setup.',
    InputPreset.ssPipeSingleVGtaw => 'Stainless pipe GTAW-only starter setup.',
    InputPreset.csPlateSingleVGmaw =>
      'Carbon steel plate single-V production starter setup.',
    InputPreset.csPlateDoubleVSmaw =>
      'Carbon steel plate double-V manual welding starter setup.',
    InputPreset.csFilletFcaw => 'Carbon steel structural fillet starter setup.',
  };

  String labelFor(L10nStrings strings) => switch (this) {
    InputPreset.custom => strings.inputPresetCustom,
    InputPreset.csPipeSingleVGtawSmaw =>
      strings.inputPresetCsPipeSingleVGtawSmaw,
    InputPreset.csPipeDoubleVGtawSmaw =>
      strings.inputPresetCsPipeDoubleVGtawSmaw,
    InputPreset.ssPipeSingleVGtaw => strings.inputPresetSsPipeSingleVGtaw,
    InputPreset.csPlateSingleVGmaw => strings.inputPresetCsPlateSingleVGmaw,
    InputPreset.csPlateDoubleVSmaw => strings.inputPresetCsPlateDoubleVSmaw,
    InputPreset.csFilletFcaw => strings.inputPresetCsFilletFcaw,
  };

  String descriptionFor(L10nStrings strings) => switch (this) {
    InputPreset.custom => strings.inputPresetDescCustom,
    InputPreset.csPipeSingleVGtawSmaw =>
      strings.inputPresetDescCsPipeSingleVGtawSmaw,
    InputPreset.csPipeDoubleVGtawSmaw =>
      strings.inputPresetDescCsPipeDoubleVGtawSmaw,
    InputPreset.ssPipeSingleVGtaw => strings.inputPresetDescSsPipeSingleVGtaw,
    InputPreset.csPlateSingleVGmaw => strings.inputPresetDescCsPlateSingleVGmaw,
    InputPreset.csPlateDoubleVSmaw => strings.inputPresetDescCsPlateDoubleVSmaw,
    InputPreset.csFilletFcaw => strings.inputPresetDescCsFilletFcaw,
  };

  WeldInputPresetData? get data => switch (this) {
    InputPreset.custom => null,
    InputPreset.csPipeSingleVGtawSmaw => const WeldInputPresetData(
      jointType: JointType.pipeButt,
      grooveType: GrooveType.singleV,
      weldingProcess: WeldingProcess.gtawSmaw,
      consumableSelection: BuiltInConsumableSelection(
        ConsumablePreset.gtawRootSmawFill,
      ),
      quantity: 1,
      pipeOdMm: 168.3,
      thicknessMm: 12,
      rootGapMm: 3,
      rootFaceMm: 2,
      bevelAngleDeg: 30,
      gtawTransitionMm: 3,
      gtawWireDiameterMm: 2.4,
      smawElectrodeDiameterMm: 3.2,
      wasteFactorPercent: 10,
    ),
    InputPreset.csPipeDoubleVGtawSmaw => const WeldInputPresetData(
      jointType: JointType.pipeButt,
      grooveType: GrooveType.doubleV,
      weldingProcess: WeldingProcess.gtawSmaw,
      consumableSelection: BuiltInConsumableSelection(
        ConsumablePreset.gtawRootSmawFill,
      ),
      quantity: 1,
      pipeOdMm: 323.9,
      thicknessMm: 16,
      rootGapMm: 3,
      rootFaceMm: 2,
      bevelAngleDeg: 30,
      gtawTransitionMm: 4,
      gtawWireDiameterMm: 2.4,
      smawElectrodeDiameterMm: 4.0,
      wasteFactorPercent: 10,
    ),
    InputPreset.ssPipeSingleVGtaw => const WeldInputPresetData(
      jointType: JointType.pipeButt,
      grooveType: GrooveType.singleV,
      weldingProcess: WeldingProcess.gtaw,
      consumableSelection: BuiltInConsumableSelection(ConsumablePreset.er308l),
      quantity: 1,
      pipeOdMm: 114.3,
      thicknessMm: 6,
      rootGapMm: 2,
      rootFaceMm: 1.5,
      bevelAngleDeg: 37.5,
      wireDiameterMm: 1.6,
      wasteFactorPercent: 10,
    ),
    InputPreset.csPlateSingleVGmaw => const WeldInputPresetData(
      jointType: JointType.plateButt,
      grooveType: GrooveType.singleV,
      weldingProcess: WeldingProcess.gmaw,
      consumableSelection: BuiltInConsumableSelection(ConsumablePreset.er70s6),
      quantity: 1,
      lengthPerPieceMm: 800,
      thicknessMm: 10,
      rootGapMm: 2,
      rootFaceMm: 1.5,
      bevelAngleDeg: 30,
      wireDiameterMm: 1.2,
      wasteFactorPercent: 10,
    ),
    InputPreset.csPlateDoubleVSmaw => const WeldInputPresetData(
      jointType: JointType.plateButt,
      grooveType: GrooveType.doubleV,
      weldingProcess: WeldingProcess.smaw,
      consumableSelection: BuiltInConsumableSelection(ConsumablePreset.e7018),
      quantity: 1,
      lengthPerPieceMm: 1000,
      thicknessMm: 20,
      rootGapMm: 3,
      rootFaceMm: 2,
      bevelAngleDeg: 30,
      electrodeDiameterMm: 4.0,
      wasteFactorPercent: 10,
    ),
    InputPreset.csFilletFcaw => const WeldInputPresetData(
      jointType: JointType.fillet,
      grooveType: GrooveType.fillet,
      weldingProcess: WeldingProcess.fcaw,
      consumableSelection: BuiltInConsumableSelection(ConsumablePreset.e71t1),
      quantity: 2,
      lengthPerPieceMm: 600,
      legSizeMm: 8,
      wireDiameterMm: 1.6,
      wasteFactorPercent: 10,
    ),
  };
}

class WeldInputPresetData {
  const WeldInputPresetData({
    required this.jointType,
    required this.grooveType,
    required this.weldingProcess,
    required this.consumableSelection,
    required this.quantity,
    required this.wasteFactorPercent,
    this.depositionRateMode = DepositionRateMode.preset,
    this.jointGeometryMode = JointGeometryMode.equal,
    this.jointAlignment = JointAlignment.centerline,
    this.densityGPerCm3,
    this.lengthPerPieceMm,
    this.pipeOdMm,
    this.pipeOdAMm,
    this.pipeOdBMm,
    this.thicknessMm,
    this.thicknessAMm,
    this.thicknessBMm,
    this.rootGapMm,
    this.rootFaceMm,
    this.bevelAngleDeg,
    this.secondaryBevelAngleDeg,
    this.breakHeightMm,
    this.legSizeMm,
    this.gtawTransitionMm,
    this.wireDiameterMm,
    this.electrodeDiameterMm,
    this.gtawWireDiameterMm,
    this.smawElectrodeDiameterMm,
    this.manualDepositionRateKgPerHour,
    this.manualGtawRateKgPerHour,
    this.manualSmawRateKgPerHour,
  });

  final JointType jointType;
  final GrooveType grooveType;
  final WeldingProcess weldingProcess;
  final ConsumableSelection consumableSelection;
  final DepositionRateMode depositionRateMode;
  final JointGeometryMode jointGeometryMode;
  final JointAlignment jointAlignment;
  final double quantity;
  final double wasteFactorPercent;
  final double? densityGPerCm3;
  final double? lengthPerPieceMm;
  final double? pipeOdMm;
  final double? pipeOdAMm;
  final double? pipeOdBMm;
  final double? thicknessMm;
  final double? thicknessAMm;
  final double? thicknessBMm;
  final double? rootGapMm;
  final double? rootFaceMm;
  final double? bevelAngleDeg;
  final double? secondaryBevelAngleDeg;
  final double? breakHeightMm;
  final double? legSizeMm;
  final double? gtawTransitionMm;
  final double? wireDiameterMm;
  final double? electrodeDiameterMm;
  final double? gtawWireDiameterMm;
  final double? smawElectrodeDiameterMm;
  final double? manualDepositionRateKgPerHour;
  final double? manualGtawRateKgPerHour;
  final double? manualSmawRateKgPerHour;

  Map<String, dynamic> toJson() => {
    'jointType': jointType.name,
    'grooveType': grooveType.name,
    'weldingProcess': weldingProcess.name,
    'consumableSelection': consumableSelection.toJson(),
    // Legacy key kept for pre-custom-filler-materials app builds reading
    // this account's presets from the shared cloud sheet (see finding #2)
    // -- no legacy equivalent exists for custom materials, so it's simply
    // omitted there, which those older builds don't understand anyway.
    if (consumableSelection case BuiltInConsumableSelection(:final preset))
      'consumablePreset': preset.name,
    'depositionRateMode': depositionRateMode.name,
    'jointGeometryMode': jointGeometryMode.name,
    'jointAlignment': jointAlignment.name,
    'quantity': quantity,
    'wasteFactorPercent': wasteFactorPercent,
    if (densityGPerCm3 != null) 'densityGPerCm3': densityGPerCm3,
    if (lengthPerPieceMm != null) 'lengthPerPieceMm': lengthPerPieceMm,
    if (pipeOdMm != null) 'pipeOdMm': pipeOdMm,
    if (pipeOdAMm != null) 'pipeOdAMm': pipeOdAMm,
    if (pipeOdBMm != null) 'pipeOdBMm': pipeOdBMm,
    if (thicknessMm != null) 'thicknessMm': thicknessMm,
    if (thicknessAMm != null) 'thicknessAMm': thicknessAMm,
    if (thicknessBMm != null) 'thicknessBMm': thicknessBMm,
    if (rootGapMm != null) 'rootGapMm': rootGapMm,
    if (rootFaceMm != null) 'rootFaceMm': rootFaceMm,
    if (bevelAngleDeg != null) 'bevelAngleDeg': bevelAngleDeg,
    if (secondaryBevelAngleDeg != null)
      'secondaryBevelAngleDeg': secondaryBevelAngleDeg,
    if (breakHeightMm != null) 'breakHeightMm': breakHeightMm,
    if (legSizeMm != null) 'legSizeMm': legSizeMm,
    if (gtawTransitionMm != null) 'gtawTransitionMm': gtawTransitionMm,
    if (wireDiameterMm != null) 'wireDiameterMm': wireDiameterMm,
    if (electrodeDiameterMm != null) 'electrodeDiameterMm': electrodeDiameterMm,
    if (gtawWireDiameterMm != null) 'gtawWireDiameterMm': gtawWireDiameterMm,
    if (smawElectrodeDiameterMm != null)
      'smawElectrodeDiameterMm': smawElectrodeDiameterMm,
    if (manualDepositionRateKgPerHour != null)
      'manualDepositionRateKgPerHour': manualDepositionRateKgPerHour,
    if (manualGtawRateKgPerHour != null)
      'manualGtawRateKgPerHour': manualGtawRateKgPerHour,
    if (manualSmawRateKgPerHour != null)
      'manualSmawRateKgPerHour': manualSmawRateKgPerHour,
  };

  factory WeldInputPresetData.fromJson(
    Map<String, dynamic> json,
  ) => WeldInputPresetData(
    jointType: JointType.values.byName(json['jointType'] as String),
    grooveType: GrooveType.values.byName(json['grooveType'] as String),
    weldingProcess: WeldingProcess.values.byName(
      json['weldingProcess'] as String,
    ),
    // Old saved calculations (local store + cloud sheet) stored a bare
    // `consumablePreset` key with no discriminant, predating custom filler
    // materials -- keep loading those without migration.
    consumableSelection: json['consumableSelection'] != null
        ? ConsumableSelection.fromJson(
            json['consumableSelection'] as Map<String, dynamic>,
          )
        : BuiltInConsumableSelection(
            ConsumablePreset.values.byName(json['consumablePreset'] as String),
          ),
    quantity: (json['quantity'] as num).toDouble(),
    wasteFactorPercent: (json['wasteFactorPercent'] as num).toDouble(),
    depositionRateMode: json['depositionRateMode'] == null
        ? DepositionRateMode.preset
        : DepositionRateMode.values.byName(
            json['depositionRateMode'] as String,
          ),
    jointGeometryMode: json['jointGeometryMode'] == null
        ? JointGeometryMode.equal
        : JointGeometryMode.values.byName(json['jointGeometryMode'] as String),
    jointAlignment: json['jointAlignment'] == null
        ? JointAlignment.centerline
        : JointAlignment.values.byName(json['jointAlignment'] as String),
    densityGPerCm3: _nullableDouble(json['densityGPerCm3']),
    lengthPerPieceMm: _nullableDouble(json['lengthPerPieceMm']),
    pipeOdMm: _nullableDouble(json['pipeOdMm']),
    pipeOdAMm: _nullableDouble(json['pipeOdAMm']),
    pipeOdBMm: _nullableDouble(json['pipeOdBMm']),
    thicknessMm: _nullableDouble(json['thicknessMm']),
    thicknessAMm: _nullableDouble(json['thicknessAMm']),
    thicknessBMm: _nullableDouble(json['thicknessBMm']),
    rootGapMm: _nullableDouble(json['rootGapMm']),
    rootFaceMm: _nullableDouble(json['rootFaceMm']),
    bevelAngleDeg: _nullableDouble(json['bevelAngleDeg']),
    secondaryBevelAngleDeg: _nullableDouble(json['secondaryBevelAngleDeg']),
    breakHeightMm: _nullableDouble(json['breakHeightMm']),
    legSizeMm: _nullableDouble(json['legSizeMm']),
    gtawTransitionMm: _nullableDouble(json['gtawTransitionMm']),
    wireDiameterMm: _nullableDouble(json['wireDiameterMm']),
    electrodeDiameterMm: _nullableDouble(json['electrodeDiameterMm']),
    gtawWireDiameterMm: _nullableDouble(json['gtawWireDiameterMm']),
    smawElectrodeDiameterMm: _nullableDouble(json['smawElectrodeDiameterMm']),
    manualDepositionRateKgPerHour: _nullableDouble(
      json['manualDepositionRateKgPerHour'],
    ),
    manualGtawRateKgPerHour: _nullableDouble(json['manualGtawRateKgPerHour']),
    manualSmawRateKgPerHour: _nullableDouble(json['manualSmawRateKgPerHour']),
  );

  static double? _nullableDouble(Object? value) =>
      value == null ? null : (value as num).toDouble();
}

class UserWeldPreset {
  const UserWeldPreset({
    required this.id,
    required this.name,
    required this.data,
    required this.updatedAtEpochMs,
  });

  final String id;
  final String name;
  final WeldInputPresetData data;
  final int updatedAtEpochMs;

  UserWeldPreset copyWith({
    String? id,
    String? name,
    WeldInputPresetData? data,
    int? updatedAtEpochMs,
  }) => UserWeldPreset(
    id: id ?? this.id,
    name: name ?? this.name,
    data: data ?? this.data,
    updatedAtEpochMs: updatedAtEpochMs ?? this.updatedAtEpochMs,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'updatedAtEpochMs': updatedAtEpochMs,
    'data': data.toJson(),
  };

  factory UserWeldPreset.fromJson(Map<String, dynamic> json) => UserWeldPreset(
    id: json['id'] as String,
    name: json['name'] as String,
    updatedAtEpochMs: json['updatedAtEpochMs'] as int? ?? 0,
    data: WeldInputPresetData.fromJson(json['data'] as Map<String, dynamic>),
  );
}

class WeldInputData {
  const WeldInputData({
    required this.jointType,
    required this.grooveType,
    required this.weldingProcess,
    required this.depositionRateMode,
    required this.quantity,
    required this.densityGPerCm3,
    required this.wasteFactorPercent,
    this.lengthPerPieceMm,
    this.pipeOdMm,
    this.thicknessMm,
    this.rootGapMm,
    this.rootFaceMm,
    this.bevelAngleDeg,
    this.secondaryBevelAngleDeg,
    this.breakHeightMm,
    this.legSizeMm,
    this.gtawTransitionMm,
    this.wireDiameterMm,
    this.electrodeDiameterMm,
    this.gtawWireDiameterMm,
    this.smawElectrodeDiameterMm,
    this.manualDepositionRateKgPerHour,
    this.manualGtawRateKgPerHour,
    this.manualSmawRateKgPerHour,
  });

  final JointType jointType;
  final GrooveType grooveType;
  final WeldingProcess weldingProcess;
  final DepositionRateMode depositionRateMode;
  final double quantity;
  final double densityGPerCm3;
  final double wasteFactorPercent;
  final double? lengthPerPieceMm;
  final double? pipeOdMm;
  final double? thicknessMm;
  final double? rootGapMm;
  final double? rootFaceMm;
  final double? bevelAngleDeg;
  final double? secondaryBevelAngleDeg;
  final double? breakHeightMm;
  final double? legSizeMm;
  final double? gtawTransitionMm;
  final double? wireDiameterMm;
  final double? electrodeDiameterMm;
  final double? gtawWireDiameterMm;
  final double? smawElectrodeDiameterMm;
  final double? manualDepositionRateKgPerHour;
  final double? manualGtawRateKgPerHour;
  final double? manualSmawRateKgPerHour;
}

class WeldCalculationResult {
  const WeldCalculationResult({
    required this.areaMm2,
    required this.lengthMm,
    required this.volumeCm3,
    required this.weldMetalKg,
    required this.fillerKg,
    required this.arcTimeHours,
    required this.depositionEfficiency,
    required this.depositionRateKgPerHour,
    required this.processBreakdowns,
  });

  final double areaMm2;
  final double lengthMm;
  final double volumeCm3;
  final double weldMetalKg;
  final double fillerKg;
  final double arcTimeHours;
  final double depositionEfficiency;
  final double depositionRateKgPerHour;
  final List<ProcessBreakdown> processBreakdowns;
}

class ProcessBreakdown {
  const ProcessBreakdown({
    required this.process,
    required this.weldMetalKg,
    required this.fillerKg,
    required this.arcTimeHours,
    required this.depositionEfficiency,
    required this.depositionRateKgPerHour,
    required this.sharePercent,
  });

  final WeldingProcess process;
  final double weldMetalKg;
  final double fillerKg;
  final double arcTimeHours;
  final double depositionEfficiency;
  final double depositionRateKgPerHour;
  final double sharePercent;
}

class InputValidationException implements Exception {
  const InputValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

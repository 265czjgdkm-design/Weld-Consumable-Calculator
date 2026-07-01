enum JointType { pipeButt, plateButt, fillet }

enum GrooveType { singleV, halfV, doubleV, compoundV, square, fillet }

enum WeldingProcess { gtaw, smaw, gtawSmaw, gmaw, fcaw }

enum DepositionRateMode { preset, manual }

enum JointGeometryMode { equal, unequal }

enum JointAlignment { centerline, odMatch, idMatch }

enum ConsumableFamily { carbonSteel, stainlessSteel, dissimilar, aluminium }

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
}

extension WeldingProcessX on WeldingProcess {
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
}

extension JointGeometryModeX on JointGeometryMode {
  String get label => switch (this) {
    JointGeometryMode.equal => 'Equal',
    JointGeometryMode.unequal => 'Unequal',
  };
}

extension JointAlignmentX on JointAlignment {
  String get label => switch (this) {
    JointAlignment.centerline => 'Centerline Match',
    JointAlignment.odMatch => 'OD Match',
    JointAlignment.idMatch => 'ID Match',
  };
}

extension ConsumableFamilyX on ConsumableFamily {
  String get label => switch (this) {
    ConsumableFamily.carbonSteel => 'Carbon Steel',
    ConsumableFamily.stainlessSteel => 'Stainless Steel',
    ConsumableFamily.dissimilar => 'Dissimilar',
    ConsumableFamily.aluminium => 'Aluminium',
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
  };

  String get awsDisplayLabel => '$awsSpecification $label (${family.label})';

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

  WeldInputPresetData? get data => switch (this) {
    InputPreset.custom => null,
    InputPreset.csPipeSingleVGtawSmaw => const WeldInputPresetData(
      jointType: JointType.pipeButt,
      grooveType: GrooveType.singleV,
      weldingProcess: WeldingProcess.gtawSmaw,
      consumablePreset: ConsumablePreset.gtawRootSmawFill,
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
      consumablePreset: ConsumablePreset.gtawRootSmawFill,
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
      consumablePreset: ConsumablePreset.er308l,
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
      consumablePreset: ConsumablePreset.er70s6,
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
      consumablePreset: ConsumablePreset.e7018,
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
      consumablePreset: ConsumablePreset.e71t1,
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
    required this.consumablePreset,
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
  final ConsumablePreset consumablePreset;
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
    'consumablePreset': consumablePreset.name,
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
    consumablePreset: ConsumablePreset.values.byName(
      json['consumablePreset'] as String,
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

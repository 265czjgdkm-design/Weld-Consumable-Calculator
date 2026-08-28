import 'weld_models.dart';

class CustomBaseMaterial {
  const CustomBaseMaterial({
    required this.id,
    required this.name,
    required this.designation,
    required this.notes,
    required this.updatedAtEpochMs,
    this.sheetThicknessMm,
    this.minSheetThicknessMm,
    this.maxSheetThicknessMm,
    this.producerName,
    this.materialId,
    this.carbonPercent,
    this.siliconPercent,
    this.manganesePercent,
    this.chromiumPercent,
    this.molybdenumPercent,
    this.copperPercent,
    this.nickelPercent,
    this.vanadiumPercent,
    this.niobiumPercent,
    this.titaniumPercent,
    this.boronPercent,
    this.nitrogenPercent,
    this.cetPercent,
    this.pcmPercent,
  });

  final String id;
  final String name;
  final String designation;
  final String notes;
  final int updatedAtEpochMs;
  final double? sheetThicknessMm;
  final double? minSheetThicknessMm;
  final double? maxSheetThicknessMm;
  final String? producerName;
  final String? materialId;
  final double? carbonPercent;
  final double? siliconPercent;
  final double? manganesePercent;
  final double? chromiumPercent;
  final double? molybdenumPercent;
  final double? copperPercent;
  final double? nickelPercent;
  final double? vanadiumPercent;
  final double? niobiumPercent;
  final double? titaniumPercent;
  final double? boronPercent;
  final double? nitrogenPercent;
  final double? cetPercent;
  final double? pcmPercent;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'designation': designation,
    'notes': notes,
    'updatedAtEpochMs': updatedAtEpochMs,
    if (sheetThicknessMm != null) 'sheetThicknessMm': sheetThicknessMm,
    if (minSheetThicknessMm != null)
      'minSheetThicknessMm': minSheetThicknessMm,
    if (maxSheetThicknessMm != null)
      'maxSheetThicknessMm': maxSheetThicknessMm,
    if (producerName != null) 'producerName': producerName,
    if (materialId != null) 'materialId': materialId,
    if (carbonPercent != null) 'carbonPercent': carbonPercent,
    if (siliconPercent != null) 'siliconPercent': siliconPercent,
    if (manganesePercent != null) 'manganesePercent': manganesePercent,
    if (chromiumPercent != null) 'chromiumPercent': chromiumPercent,
    if (molybdenumPercent != null) 'molybdenumPercent': molybdenumPercent,
    if (copperPercent != null) 'copperPercent': copperPercent,
    if (nickelPercent != null) 'nickelPercent': nickelPercent,
    if (vanadiumPercent != null) 'vanadiumPercent': vanadiumPercent,
    if (niobiumPercent != null) 'niobiumPercent': niobiumPercent,
    if (titaniumPercent != null) 'titaniumPercent': titaniumPercent,
    if (boronPercent != null) 'boronPercent': boronPercent,
    if (nitrogenPercent != null) 'nitrogenPercent': nitrogenPercent,
    if (cetPercent != null) 'cetPercent': cetPercent,
    if (pcmPercent != null) 'pcmPercent': pcmPercent,
  };

  factory CustomBaseMaterial.fromJson(Map<String, dynamic> json) =>
      CustomBaseMaterial(
        id: json['id'] as String,
        name: json['name'] as String,
        designation: json['designation'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
        updatedAtEpochMs: json['updatedAtEpochMs'] as int? ?? 0,
        sheetThicknessMm: (json['sheetThicknessMm'] as num?)?.toDouble(),
        minSheetThicknessMm: (json['minSheetThicknessMm'] as num?)
            ?.toDouble(),
        maxSheetThicknessMm: (json['maxSheetThicknessMm'] as num?)
            ?.toDouble(),
        producerName: json['producerName'] as String?,
        materialId: json['materialId'] as String?,
        carbonPercent: (json['carbonPercent'] as num?)?.toDouble(),
        siliconPercent: (json['siliconPercent'] as num?)?.toDouble(),
        manganesePercent: (json['manganesePercent'] as num?)?.toDouble(),
        chromiumPercent: (json['chromiumPercent'] as num?)?.toDouble(),
        molybdenumPercent: (json['molybdenumPercent'] as num?)?.toDouble(),
        copperPercent: (json['copperPercent'] as num?)?.toDouble(),
        nickelPercent: (json['nickelPercent'] as num?)?.toDouble(),
        vanadiumPercent: (json['vanadiumPercent'] as num?)?.toDouble(),
        niobiumPercent: (json['niobiumPercent'] as num?)?.toDouble(),
        titaniumPercent: (json['titaniumPercent'] as num?)?.toDouble(),
        boronPercent: (json['boronPercent'] as num?)?.toDouble(),
        nitrogenPercent: (json['nitrogenPercent'] as num?)?.toDouble(),
        cetPercent: (json['cetPercent'] as num?)?.toDouble(),
        pcmPercent: (json['pcmPercent'] as num?)?.toDouble(),
      );
}

class CustomFillerMaterial {
  const CustomFillerMaterial({
    required this.id,
    required this.name,
    required this.family,
    required this.densityGPerCm3,
    required this.notes,
    required this.updatedAtEpochMs,
    this.awsSpecification,
    this.producerName,
    this.materialId,
    this.carbonPercent,
    this.siliconPercent,
    this.manganesePercent,
    this.chromiumPercent,
    this.molybdenumPercent,
    this.copperPercent,
    this.nickelPercent,
    this.vanadiumPercent,
    this.niobiumPercent,
    this.titaniumPercent,
    this.boronPercent,
    this.nitrogenPercent,
    this.cetPercent,
    this.pcmPercent,
  });

  final String id;
  final String name;
  final ConsumableFamily family;
  final String? awsSpecification;
  final double densityGPerCm3;
  final String notes;
  final int updatedAtEpochMs;
  final String? producerName;
  final String? materialId;
  final double? carbonPercent;
  final double? siliconPercent;
  final double? manganesePercent;
  final double? chromiumPercent;
  final double? molybdenumPercent;
  final double? copperPercent;
  final double? nickelPercent;
  final double? vanadiumPercent;
  final double? niobiumPercent;
  final double? titaniumPercent;
  final double? boronPercent;
  final double? nitrogenPercent;
  final double? cetPercent;
  final double? pcmPercent;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'family': family.name,
    if (awsSpecification != null) 'awsSpecification': awsSpecification,
    'densityGPerCm3': densityGPerCm3,
    'notes': notes,
    'updatedAtEpochMs': updatedAtEpochMs,
    if (producerName != null) 'producerName': producerName,
    if (materialId != null) 'materialId': materialId,
    if (carbonPercent != null) 'carbonPercent': carbonPercent,
    if (siliconPercent != null) 'siliconPercent': siliconPercent,
    if (manganesePercent != null) 'manganesePercent': manganesePercent,
    if (chromiumPercent != null) 'chromiumPercent': chromiumPercent,
    if (molybdenumPercent != null) 'molybdenumPercent': molybdenumPercent,
    if (copperPercent != null) 'copperPercent': copperPercent,
    if (nickelPercent != null) 'nickelPercent': nickelPercent,
    if (vanadiumPercent != null) 'vanadiumPercent': vanadiumPercent,
    if (niobiumPercent != null) 'niobiumPercent': niobiumPercent,
    if (titaniumPercent != null) 'titaniumPercent': titaniumPercent,
    if (boronPercent != null) 'boronPercent': boronPercent,
    if (nitrogenPercent != null) 'nitrogenPercent': nitrogenPercent,
    if (cetPercent != null) 'cetPercent': cetPercent,
    if (pcmPercent != null) 'pcmPercent': pcmPercent,
  };

  factory CustomFillerMaterial.fromJson(Map<String, dynamic> json) =>
      CustomFillerMaterial(
        id: json['id'] as String,
        name: json['name'] as String,
        family: ConsumableFamily.values.byName(json['family'] as String),
        awsSpecification: json['awsSpecification'] as String?,
        densityGPerCm3: (json['densityGPerCm3'] as num).toDouble(),
        notes: json['notes'] as String? ?? '',
        updatedAtEpochMs: json['updatedAtEpochMs'] as int? ?? 0,
        producerName: json['producerName'] as String?,
        materialId: json['materialId'] as String?,
        carbonPercent: (json['carbonPercent'] as num?)?.toDouble(),
        siliconPercent: (json['siliconPercent'] as num?)?.toDouble(),
        manganesePercent: (json['manganesePercent'] as num?)?.toDouble(),
        chromiumPercent: (json['chromiumPercent'] as num?)?.toDouble(),
        molybdenumPercent: (json['molybdenumPercent'] as num?)?.toDouble(),
        copperPercent: (json['copperPercent'] as num?)?.toDouble(),
        nickelPercent: (json['nickelPercent'] as num?)?.toDouble(),
        vanadiumPercent: (json['vanadiumPercent'] as num?)?.toDouble(),
        niobiumPercent: (json['niobiumPercent'] as num?)?.toDouble(),
        titaniumPercent: (json['titaniumPercent'] as num?)?.toDouble(),
        boronPercent: (json['boronPercent'] as num?)?.toDouble(),
        nitrogenPercent: (json['nitrogenPercent'] as num?)?.toDouble(),
        cetPercent: (json['cetPercent'] as num?)?.toDouble(),
        pcmPercent: (json['pcmPercent'] as num?)?.toDouble(),
      );
}

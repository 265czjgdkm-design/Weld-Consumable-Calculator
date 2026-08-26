class SavedReport {
  const SavedReport({
    required this.id,
    required this.fileName,
    required this.generatedAtEpochMs,
    required this.pdfBytesBase64,
  });

  final String id;
  final String fileName;
  final int generatedAtEpochMs;
  final String pdfBytesBase64;

  Map<String, dynamic> toJson() => {
    'id': id,
    'fileName': fileName,
    'generatedAtEpochMs': generatedAtEpochMs,
    'pdfBytesBase64': pdfBytesBase64,
  };

  factory SavedReport.fromJson(Map<String, dynamic> json) => SavedReport(
    id: json['id'] as String,
    fileName: json['fileName'] as String,
    generatedAtEpochMs: json['generatedAtEpochMs'] as int? ?? 0,
    pdfBytesBase64: json['pdfBytesBase64'] as String,
  );
}

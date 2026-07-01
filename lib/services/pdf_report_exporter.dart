import 'dart:typed_data';

import 'pdf_report_exporter_stub.dart'
    if (dart.library.html) 'pdf_report_exporter_web.dart'
    as exporter;

Future<void> exportPdfReport(Uint8List bytes, String fileName) =>
    exporter.exportPdfReport(bytes, fileName);

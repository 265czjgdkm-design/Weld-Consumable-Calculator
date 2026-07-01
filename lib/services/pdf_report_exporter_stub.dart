import 'dart:typed_data';

import 'package:printing/printing.dart';

Future<void> exportPdfReport(Uint8List bytes, String fileName) async {
  try {
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  } catch (_) {
    await Printing.layoutPdf(name: fileName, onLayout: (_) async => bytes);
  }
}

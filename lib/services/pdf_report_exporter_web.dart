@JS()
library;

import 'dart:typed_data';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

Future<void> exportPdfReport(Uint8List bytes, String fileName) async {
  final blob = web.Blob(
    [bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/pdf'),
  );

  if (web.window.hasProperty('showSaveFilePicker'.toJS).toDart) {
    final accept = JSObject();
    accept.setProperty('application/pdf'.toJS, ['.pdf'.toJS].toJS);

    final pickerType = FilePickerAcceptType(
      description: 'PDF Document',
      accept: accept,
    );
    final handle = await _showSaveFilePicker(
      SaveFilePickerOptions(
        suggestedName: fileName,
        excludeAcceptAllOption: false,
        types: [pickerType].toJS,
      ),
    ).toDart;
    final writable = await handle.createWritable().toDart;
    await writable.write(blob).toDart;
    await writable.close().toDart;
    return;
  }

  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;

  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}

@JS('window.showSaveFilePicker')
external JSPromise<web.FileSystemFileHandle> _showSaveFilePicker([
  SaveFilePickerOptions options,
]);

extension type SaveFilePickerOptions._(JSObject _) implements JSObject {
  external factory SaveFilePickerOptions({
    String? suggestedName,
    bool? excludeAcceptAllOption,
    JSArray<FilePickerAcceptType>? types,
  });
}

extension type FilePickerAcceptType._(JSObject _) implements JSObject {
  external factory FilePickerAcceptType({String description, JSObject accept});
}

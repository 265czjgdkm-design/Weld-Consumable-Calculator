import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Saves `binding.takeScreenshot` images to build/screenshots/ (App Store).
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final file = File('build/screenshots/$name.png');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}

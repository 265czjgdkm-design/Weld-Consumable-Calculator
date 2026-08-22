import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart' as rive;

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await rive.RiveNative.init();
  runApp(const WeldConsumableCalculatorApp());
}

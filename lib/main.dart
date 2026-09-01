import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart' as rive;

import 'app.dart';
import 'services/entitlement_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await rive.RiveNative.init();
  await EntitlementService().configure();
  runApp(const WeldConsumableCalculatorApp());
}

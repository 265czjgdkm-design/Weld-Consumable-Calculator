import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart' as rive;

import 'app.dart';
import 'services/auth_service.dart';
import 'services/entitlement_service.dart';
import 'services/firebase_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await rive.RiveNative.init();
  await EntitlementService().configure();
  AuthServices.instance = await createAuthService();
  runApp(const WeldConsumableCalculatorApp());
}

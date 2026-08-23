import 'package:http/http.dart' as http;

import 'signup_config.dart';

/// Native (iOS/Android) submission path: a plain POST, since mobile apps
/// aren't subject to browser CORS restrictions the way the web build is.
Future<bool> submitSignupEmail(String email) async {
  try {
    final response = await http
        .post(
          Uri.parse(SignupConfig.formResponseUrl),
          body: {SignupConfig.emailEntryField: email},
        )
        .timeout(const Duration(seconds: 8));
    return response.statusCode >= 200 && response.statusCode < 400;
  } catch (_) {
    return false;
  }
}

import 'package:shared_preferences/shared_preferences.dart';

/// Remembers whether the post-splash email gate has already been resolved
/// (either the user left an email, or chose to continue as a guest) so it
/// only ever appears once per install.
class SignupGateStore {
  const SignupGateStore();

  static const _resolvedKey = 'signup_gate_resolved_v1';

  Future<bool> isResolved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_resolvedKey) ?? false;
  }

  Future<void> markResolved() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_resolvedKey, true);
  }
}

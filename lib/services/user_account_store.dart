import 'package:shared_preferences/shared_preferences.dart';

/// Persists the email address that identifies the current "account" --
/// entering an email (on the gate screen, or later when a guest taps Save
/// on a preset) is what makes someone a logged-in user rather than a guest.
/// The same email, entered on any device, retrieves the same saved presets
/// via [PresetSyncService].
class UserAccountStore {
  const UserAccountStore();

  static const _emailKey = 'user_account_email_v1';

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey);
    return (email == null || email.isEmpty) ? null : email;
  }

  Future<void> setEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email.trim().toLowerCase());
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
  }
}

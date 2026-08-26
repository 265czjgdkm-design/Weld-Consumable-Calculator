import 'package:shared_preferences/shared_preferences.dart';

/// Persists the email address that identifies the current "account" --
/// entering an email (on the gate screen, or later when a guest taps Save
/// on a preset) is what makes someone a logged-in user rather than a guest.
/// The same email, entered on any device, retrieves the same saved presets
/// via [PresetSyncService].
class UserAccountStore {
  const UserAccountStore();

  static const _emailKey = 'user_account_email_v1';
  static const _firstNameKey = 'user_account_first_name_v1';
  static const _lastNameKey = 'user_account_last_name_v1';

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey);
    return (email == null || email.isEmpty) ? null : email;
  }

  Future<void> setEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email.trim().toLowerCase());
  }

  Future<String?> getFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    final firstName = prefs.getString(_firstNameKey);
    return (firstName == null || firstName.isEmpty) ? null : firstName;
  }

  Future<String?> getLastName() async {
    final prefs = await SharedPreferences.getInstance();
    final lastName = prefs.getString(_lastNameKey);
    return (lastName == null || lastName.isEmpty) ? null : lastName;
  }

  Future<void> setName(String firstName, String lastName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firstNameKey, firstName.trim());
    await prefs.setString(_lastNameKey, lastName.trim());
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_firstNameKey);
    await prefs.remove(_lastNameKey);
  }
}

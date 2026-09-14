import 'package:shared_preferences/shared_preferences.dart';

/// Remembers whether the user has acknowledged that AI assistant messages
/// are sent to a third-party AI service to generate a response (Apple
/// guideline 5.1.2(i) / Google Play's AI-disclosure policy), so the
/// one-time consent step only ever appears once per install.
class AiConsentStore {
  const AiConsentStore();

  static const _acknowledgedKey = 'ai_consent_acknowledged_v1';

  Future<bool> isAcknowledged() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_acknowledgedKey) ?? false;
  }

  Future<void> markAcknowledged() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_acknowledgedKey, true);
  }
}

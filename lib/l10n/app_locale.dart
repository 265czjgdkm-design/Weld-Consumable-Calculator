import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_language.dart';

/// Holds the user's chosen [AppLanguage] and persists it locally so the
/// choice survives app restarts. Starts at [AppLanguage.en] synchronously
/// so the app can render immediately; call [hydrate] once to pick up a
/// previously saved choice as soon as it resolves.
class AppLocale extends ChangeNotifier {
  AppLocale() : _language = AppLanguage.en;

  static const _prefsKey = 'app_language_code';

  AppLanguage _language;
  AppLanguage get language => _language;

  Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = AppLanguageX.fromCode(prefs.getString(_prefsKey));
    if (saved != _language) {
      _language = saved;
      notifyListeners();
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;
    _language = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language.code);
  }
}

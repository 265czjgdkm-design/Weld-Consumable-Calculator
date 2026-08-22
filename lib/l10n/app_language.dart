enum AppLanguage { tr, en, ru, de, hi }

extension AppLanguageX on AppLanguage {
  String get code => switch (this) {
    AppLanguage.tr => 'tr',
    AppLanguage.en => 'en',
    AppLanguage.ru => 'ru',
    AppLanguage.de => 'de',
    AppLanguage.hi => 'hi',
  };

  String get nativeName => switch (this) {
    AppLanguage.tr => 'Türkçe',
    AppLanguage.en => 'English',
    AppLanguage.ru => 'Русский',
    AppLanguage.de => 'Deutsch',
    AppLanguage.hi => 'हिन्दी',
  };

  String get flagEmoji => switch (this) {
    AppLanguage.tr => '🇹🇷',
    AppLanguage.en => '🇬🇧',
    AppLanguage.ru => '🇷🇺',
    AppLanguage.de => '🇩🇪',
    AppLanguage.hi => '🇮🇳',
  };

  static AppLanguage fromCode(String? code) => AppLanguage.values.firstWhere(
    (language) => language.code == code,
    orElse: () => AppLanguage.en,
  );
}

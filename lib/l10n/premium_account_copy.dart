import 'app_language.dart';

/// Copy for the account screen's Premium status card, the post-purchase
/// "link to account" prompt and the guide entry points. Kept apart from
/// [L10nStrings] so the 5-locale constructor there is not widened for text
/// that only these surfaces use.
class PremiumAccountCopy {
  const PremiumAccountCopy({
    required this.cardTitle,
    required this.statusNone,
    required this.statusActive,
    required this.statusExpired,
    required this.planLabel,
    required this.planMonthly,
    required this.planYearly,
    required this.planUnknown,
    required this.renewsOn,
    required this.endsOn,
    required this.expiredOn,
    required this.appleIdNote,
    required this.linkHint,
    required this.linkPromptText,
    required this.linkPromptAction,
    required this.guideRow,
    required this.howToUse,
  });

  final String cardTitle;
  final String statusNone;
  final String statusActive;
  final String statusExpired;
  final String planLabel;
  final String planMonthly;
  final String planYearly;
  final String planUnknown;

  /// Each takes a `{date}` placeholder.
  final String renewsOn;
  final String endsOn;
  final String expiredOn;
  final String appleIdNote;
  final String linkHint;
  final String linkPromptText;
  final String linkPromptAction;
  final String guideRow;
  final String howToUse;
}

PremiumAccountCopy premiumAccountCopyFor(AppLanguage language) =>
    switch (language) {
      AppLanguage.tr => _tr,
      AppLanguage.en => _en,
      AppLanguage.ru => _ru,
      AppLanguage.de => _de,
      AppLanguage.hi => _hi,
    };

const _en = PremiumAccountCopy(
  cardTitle: 'Premium status',
  statusNone: 'No active Premium',
  statusActive: 'Active',
  statusExpired: 'Expired',
  planLabel: 'Plan',
  planMonthly: 'Monthly',
  planYearly: 'Yearly',
  planUnknown: 'Premium',
  renewsOn: 'Renews on {date}',
  endsOn: 'Ends on {date} (will not renew)',
  expiredOn: 'Expired on {date}',
  appleIdNote:
      'Premium is tied to your Apple ID, not to this app account. It works on every device signed in with the same Apple ID: install the app there and tap Restore Purchases.',
  linkHint:
      'Optional: sign in with your email to keep track of your Premium with your account.',
  linkPromptText: 'Link to account — track your Premium with your email',
  linkPromptAction: 'Link',
  guideRow: 'User guide',
  howToUse: 'How to use?',
);

const _tr = PremiumAccountCopy(
  cardTitle: 'Premium durumu',
  statusNone: 'Aktif Premium yok',
  statusActive: 'Aktif',
  statusExpired: 'Süresi doldu',
  planLabel: 'Plan',
  planMonthly: 'Aylık',
  planYearly: 'Yıllık',
  planUnknown: 'Premium',
  renewsOn: '{date} tarihinde yenilenir',
  endsOn: '{date} tarihinde sona erer (yenilenmeyecek)',
  expiredOn: '{date} tarihinde sona erdi',
  appleIdNote:
      "Premium, bu uygulamadaki hesaba değil Apple Kimliğinize bağlıdır. Aynı Apple Kimliğiyle giriş yapılmış tüm cihazlarda çalışır: uygulamayı orada yükleyip Satın Alımları Geri Yükle'ye dokunun.",
  linkHint:
      "İsteğe bağlı: Premium'unuzu hesabınızla takip etmek için e-postanızla giriş yapın.",
  linkPromptText: "Hesabına bağla — Premium'unu e-postanla takip et",
  linkPromptAction: 'Bağla',
  guideRow: 'Kullanım Kılavuzu',
  howToUse: 'Nasıl kullanılır?',
);

const _ru = PremiumAccountCopy(
  cardTitle: 'Статус Premium',
  statusNone: 'Premium не активен',
  statusActive: 'Активен',
  statusExpired: 'Истёк',
  planLabel: 'План',
  planMonthly: 'Ежемесячный',
  planYearly: 'Годовой',
  planUnknown: 'Premium',
  renewsOn: 'Продлится {date}',
  endsOn: 'Действует до {date} (не продлится)',
  expiredOn: 'Истёк {date}',
  appleIdNote:
      'Premium привязан к вашему Apple ID, а не к аккаунту в приложении. Он работает на всех устройствах с тем же Apple ID: установите приложение и нажмите «Восстановить покупки».',
  linkHint:
      'По желанию: войдите по e-mail, чтобы отслеживать Premium вместе с аккаунтом.',
  linkPromptText: 'Привязать к аккаунту — отслеживайте Premium по e-mail',
  linkPromptAction: 'Привязать',
  guideRow: 'Руководство',
  howToUse: 'Как пользоваться?',
);

const _de = PremiumAccountCopy(
  cardTitle: 'Premium-Status',
  statusNone: 'Kein aktives Premium',
  statusActive: 'Aktiv',
  statusExpired: 'Abgelaufen',
  planLabel: 'Tarif',
  planMonthly: 'Monatlich',
  planYearly: 'Jährlich',
  planUnknown: 'Premium',
  renewsOn: 'Verlängert sich am {date}',
  endsOn: 'Endet am {date} (keine Verlängerung)',
  expiredOn: 'Abgelaufen am {date}',
  appleIdNote:
      'Premium ist an Ihre Apple-ID gebunden, nicht an das App-Konto. Es gilt auf allen Geräten mit derselben Apple-ID: App installieren und „Käufe wiederherstellen“ tippen.',
  linkHint:
      'Optional: Melden Sie sich mit Ihrer E-Mail an, um Premium mit Ihrem Konto zu verfolgen.',
  linkPromptText: 'Mit Konto verknüpfen — Premium per E-Mail verfolgen',
  linkPromptAction: 'Verknüpfen',
  guideRow: 'Benutzerhandbuch',
  howToUse: 'Wie benutze ich das?',
);

const _hi = PremiumAccountCopy(
  cardTitle: 'Premium स्थिति',
  statusNone: 'कोई सक्रिय Premium नहीं',
  statusActive: 'सक्रिय',
  statusExpired: 'समाप्त',
  planLabel: 'प्लान',
  planMonthly: 'मासिक',
  planYearly: 'वार्षिक',
  planUnknown: 'Premium',
  renewsOn: '{date} को नवीनीकरण होगा',
  endsOn: '{date} को समाप्त होगा (नवीनीकरण नहीं होगा)',
  expiredOn: '{date} को समाप्त हुआ',
  appleIdNote:
      'Premium आपकी Apple ID से जुड़ा है, ऐप खाते से नहीं। यह उसी Apple ID वाले हर डिवाइस पर चलता है: ऐप इंस्टॉल करें और "खरीदारी पुनर्स्थापित करें" दबाएँ।',
  linkHint:
      'वैकल्पिक: अपने Premium को खाते के साथ ट्रैक करने के लिए ईमेल से साइन इन करें।',
  linkPromptText: 'खाते से जोड़ें — ईमेल से अपना Premium ट्रैक करें',
  linkPromptAction: 'जोड़ें',
  guideRow: 'उपयोग गाइड',
  howToUse: 'कैसे उपयोग करें?',
);

String formatCopyDate(AppLanguage language, DateTime date) {
  final local = date.toLocal();
  final d = local.day.toString().padLeft(2, '0');
  final m = local.month.toString().padLeft(2, '0');
  return switch (language) {
    AppLanguage.en || AppLanguage.hi => '$d/$m/${local.year}',
    _ => '$d.$m.${local.year}',
  };
}

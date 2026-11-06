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
      'Premium follows your verified Varyos account and your Apple ID. On a new device, sign in to the same account or tap Restore Purchases.',
  linkHint:
      'Create a free account (or sign in) so your Premium follows you to new devices.',
  linkPromptText: 'Create an account — keep your Premium',
  linkPromptAction: 'Create',
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
      "Premium, doğrulanmış Varyos hesabınızı ve Apple Kimliğinizi takip eder. Yeni cihazda aynı hesapla giriş yapın veya Satın Alımları Geri Yükle'ye dokunun.",
  linkHint:
      "Premium'unuz yeni cihazlarda da sizinle olsun diye ücretsiz hesap oluşturun veya giriş yapın.",
  linkPromptText: "Hesap oluştur — Premium'unu koru",
  linkPromptAction: 'Oluştur',
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
      'Premium следует за вашим подтверждённым аккаунтом Varyos и вашим Apple ID. На новом устройстве войдите в тот же аккаунт или нажмите «Восстановить покупки».',
  linkHint:
      'Создайте бесплатный аккаунт (или войдите), чтобы Premium был с вами на новых устройствах.',
  linkPromptText: 'Создайте аккаунт — сохраните Premium',
  linkPromptAction: 'Создать',
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
      'Premium folgt Ihrem bestätigten Varyos-Konto und Ihrer Apple-ID. Auf einem neuen Gerät melden Sie sich mit demselben Konto an oder tippen auf „Käufe wiederherstellen“.',
  linkHint:
      'Erstellen Sie ein kostenloses Konto (oder melden Sie sich an), damit Premium auf neue Geräte mitkommt.',
  linkPromptText: 'Konto erstellen — Premium behalten',
  linkPromptAction: 'Erstellen',
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
      'Premium आपके सत्यापित Varyos खाते और Apple ID के साथ चलता है। नए डिवाइस पर उसी खाते से साइन इन करें या "खरीदारी पुनर्स्थापित करें" दबाएँ।',
  linkHint:
      'अपना Premium नए डिवाइस पर साथ रखने के लिए मुफ़्त खाता बनाएँ या साइन इन करें।',
  linkPromptText: 'खाता बनाएँ — Premium सुरक्षित रखें',
  linkPromptAction: 'बनाएँ',
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

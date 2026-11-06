import 'app_language.dart';

/// Copy for sign-up / sign-in / email verification / account prompts. Kept
/// apart from [L10nStrings] (same reason as [PremiumAccountCopy]).
class AuthCopy {
  const AuthCopy({
    required this.registerButton,
    required this.signInButton,
    required this.guestButton,
    required this.signInRequired,
    required this.legacyTitle,
    required this.legacyBody,
    required this.unavailableNote,
    required this.orWord,
    required this.passwordLabel,
    required this.passwordConfirmLabel,
    required this.showPassword,
    required this.hidePassword,
    required this.passwordRequired,
    required this.passwordTooShort,
    required this.passwordMismatch,
    required this.consentRequired,
    required this.signInTitle,
    required this.forgotPassword,
    required this.forgotTitle,
    required this.forgotBody,
    required this.forgotSend,
    required this.forgotSent,
    required this.verifyTitle,
    required this.verifyBody,
    required this.verifyResend,
    required this.verifyResent,
    required this.verifyDone,
    required this.verifyNotYet,
    required this.verifyLater,
    required this.errEmailInUse,
    required this.errInvalidEmail,
    required this.errWeakPassword,
    required this.errWrongCredentials,
    required this.errNetwork,
    required this.errTooMany,
    required this.errUnavailable,
    required this.errGeneric,
    required this.sheetTitle,
    required this.sheetBody,
    required this.sheetNotNow,
    required this.saveTitle,
    required this.saveBody,
    required this.accountVerified,
    required this.accountUnverifiedNotice,
    required this.accountVerifyNow,
    required this.accountGuestBody,
    required this.accountSignedInNote,
    required this.deleteReauthTitle,
    required this.deleteReauthBody,
  });

  final String registerButton;
  final String signInButton;
  final String guestButton;
  final String signInRequired;
  final String legacyTitle;
  final String legacyBody;
  final String unavailableNote;
  final String orWord;
  final String passwordLabel;
  final String passwordConfirmLabel;
  final String showPassword;
  final String hidePassword;
  final String passwordRequired;
  final String passwordTooShort;
  final String passwordMismatch;
  final String consentRequired;
  final String signInTitle;
  final String forgotPassword;
  final String forgotTitle;
  final String forgotBody;
  final String forgotSend;
  final String forgotSent;
  final String verifyTitle;
  final String verifyBody;
  final String verifyResend;
  final String verifyResent;
  final String verifyDone;
  final String verifyNotYet;
  final String verifyLater;
  final String errEmailInUse;
  final String errInvalidEmail;
  final String errWeakPassword;
  final String errWrongCredentials;
  final String errNetwork;
  final String errTooMany;
  final String errUnavailable;
  final String errGeneric;
  final String sheetTitle;
  final String sheetBody;
  final String sheetNotNow;
  final String saveTitle;
  final String saveBody;
  final String accountVerified;
  final String accountUnverifiedNotice;
  final String accountVerifyNow;
  final String accountGuestBody;
  final String accountSignedInNote;
  final String deleteReauthTitle;
  final String deleteReauthBody;
}

AuthCopy authCopyFor(AppLanguage language) => switch (language) {
  AppLanguage.tr => _tr,
  AppLanguage.en => _en,
  AppLanguage.ru => _ru,
  AppLanguage.de => _de,
  AppLanguage.hi => _hi,
};

const _tr = AuthCopy(
  registerButton: 'E-posta ile kayıt ol',
  signInButton: 'Giriş yap',
  guestButton: 'Misafir olarak devam et',
  signInRequired: 'Lütfen hesabına giriş yap.',
  legacyTitle: 'Hesap sistemimiz yenilendi',
  legacyBody:
      'Kayıtlarını görmek için aynı e-postayla kayıt ol veya giriş yap. Eski kayıtların geri gelecek.',
  unavailableNote:
      'Hesap şu an kullanılamıyor. Misafir olarak devam edebilirsin.',
  orWord: 'veya',
  passwordLabel: 'Şifre',
  passwordConfirmLabel: 'Şifre (tekrar)',
  showPassword: 'Şifreyi göster',
  hidePassword: 'Şifreyi gizle',
  passwordRequired: 'Şifreni gir',
  passwordTooShort: 'Şifre en az 8 karakter olmalı',
  passwordMismatch: 'Şifreler eşleşmiyor',
  consentRequired: 'Devam etmek için onay kutusunu işaretle',
  signInTitle: 'Giriş yap',
  forgotPassword: 'Şifremi unuttum',
  forgotTitle: 'Şifreni sıfırla',
  forgotBody:
      'Hesabının e-posta adresini gir; sana şifre sıfırlama bağlantısı gönderelim.',
  forgotSend: 'Sıfırlama bağlantısı gönder',
  forgotSent:
      'Bu e-posta kayıtlıysa sıfırlama bağlantısı gönderildi. Gelen kutunu ve spam klasörünü kontrol et.',
  verifyTitle: 'E-postanı doğrula',
  verifyBody:
      '{email} adresine bir doğrulama bağlantısı gönderdik. Gelen kutunu (ve spam klasörünü) kontrol edip bağlantıya dokun.',
  verifyResend: 'Tekrar gönder',
  verifyResent: 'Doğrulama e-postası tekrar gönderildi.',
  verifyDone: 'Doğruladım',
  verifyNotYet:
      'E-posta henüz doğrulanmamış görünüyor. Bağlantıya dokunduktan sonra tekrar dene.',
  verifyLater: 'Şimdilik geç',
  errEmailInUse: 'Bu e-posta ile zaten bir hesap var. Giriş yapmayı dene.',
  errInvalidEmail: 'Geçerli bir e-posta adresi gir.',
  errWeakPassword: 'Şifre çok zayıf. Daha uzun bir şifre seç.',
  errWrongCredentials: 'E-posta veya şifre hatalı.',
  errNetwork: 'Bağlantı hatası. İnternetini kontrol edip tekrar dene.',
  errTooMany: 'Çok fazla deneme yapıldı. Biraz bekleyip tekrar dene.',
  errUnavailable: 'Hesap hizmeti şu an kullanılamıyor. Daha sonra tekrar dene.',
  errGeneric: 'Bir şeyler ters gitti. Tekrar dene.',
  sheetTitle: 'Hesap oluştur, Premium\'unu koru',
  sheetBody:
      'Premium\'un hesabına bağlanır; telefonunu değiştirsen de giriş yapınca geri gelir. Hesap oluşturmak ücretsizdir.',
  sheetNotNow: 'Şimdi değil',
  saveTitle: 'Kaydetmek için hesap oluştur',
  saveBody:
      'Kayıtlı hesaplamaların hesabına bağlı olarak bulutta saklanır ve tüm cihazlarında seninle olur.',
  accountVerified: 'E-posta doğrulandı',
  accountUnverifiedNotice:
      'E-postan henüz doğrulanmadı. Bulut kayıtların ve Premium hesabın doğrulamadan sonra etkinleşir.',
  accountVerifyNow: 'E-postayı doğrula',
  accountGuestBody:
      'Hesap oluştur veya giriş yap: kayıtların bulutta saklanır, Premium\'un yeni cihazlarda seninle olur.',
  accountSignedInNote: 'Kayıtlı hesaplamaların bu hesaba bağlıdır.',
  deleteReauthTitle: 'Kimliğini doğrula',
  deleteReauthBody: 'Hesabı silmek için şifreni tekrar gir.',
);

const _en = AuthCopy(
  registerButton: 'Sign up with email',
  signInButton: 'Sign in',
  guestButton: 'Continue as guest',
  signInRequired: 'Please sign in to your account.',
  legacyTitle: 'Our account system was renewed',
  legacyBody:
      'To see your saved calculations, sign up or sign in with the same email. Your old presets will come back.',
  unavailableNote:
      'Accounts are unavailable right now. You can continue as a guest.',
  orWord: 'or',
  passwordLabel: 'Password',
  passwordConfirmLabel: 'Confirm password',
  showPassword: 'Show password',
  hidePassword: 'Hide password',
  passwordRequired: 'Enter your password',
  passwordTooShort: 'Password must be at least 8 characters',
  passwordMismatch: 'Passwords do not match',
  consentRequired: 'Tick the box to continue',
  signInTitle: 'Sign in',
  forgotPassword: 'Forgot password',
  forgotTitle: 'Reset your password',
  forgotBody:
      'Enter your account email and we will send you a password reset link.',
  forgotSend: 'Send reset link',
  forgotSent:
      'If this email is registered, a reset link was sent. Check your inbox and spam folder.',
  verifyTitle: 'Verify your email',
  verifyBody:
      'We sent a verification link to {email}. Check your inbox (and spam folder) and tap the link.',
  verifyResend: 'Resend email',
  verifyResent: 'Verification email sent again.',
  verifyDone: 'I verified',
  verifyNotYet:
      'Your email does not look verified yet. Tap the link in the email, then try again.',
  verifyLater: 'Skip for now',
  errEmailInUse: 'An account with this email already exists. Try signing in.',
  errInvalidEmail: 'Enter a valid email address.',
  errWeakPassword: 'That password is too weak. Choose a longer one.',
  errWrongCredentials: 'Wrong email or password.',
  errNetwork: 'Connection problem. Check your internet and try again.',
  errTooMany: 'Too many attempts. Wait a bit and try again.',
  errUnavailable:
      'The account service is unavailable right now. Try again later.',
  errGeneric: 'Something went wrong. Please try again.',
  sheetTitle: 'Create an account, keep your Premium',
  sheetBody:
      'Your Premium is tied to your account, so it comes back when you sign in on a new phone. Creating an account is free.',
  sheetNotNow: 'Not now',
  saveTitle: 'Create an account to save',
  saveBody:
      'Your saved calculations are stored in the cloud under your account and follow you to all your devices.',
  accountVerified: 'Email verified',
  accountUnverifiedNotice:
      'Your email is not verified yet. Cloud presets and your Premium account become active after verification.',
  accountVerifyNow: 'Verify email',
  accountGuestBody:
      'Create an account or sign in: your presets are stored in the cloud and your Premium follows you to new devices.',
  accountSignedInNote: 'Your saved calculations are tied to this account.',
  deleteReauthTitle: 'Confirm it is you',
  deleteReauthBody: 'Enter your password again to delete the account.',
);

const _ru = AuthCopy(
  registerButton: 'Зарегистрироваться по e-mail',
  signInButton: 'Войти',
  guestButton: 'Продолжить как гость',
  signInRequired: 'Пожалуйста, войдите в аккаунт.',
  legacyTitle: 'Система аккаунтов обновлена',
  legacyBody:
      'Чтобы увидеть сохранённые расчёты, зарегистрируйтесь или войдите с тем же e-mail. Старые пресеты вернутся.',
  unavailableNote: 'Аккаунты сейчас недоступны. Можно продолжить как гость.',
  orWord: 'или',
  passwordLabel: 'Пароль',
  passwordConfirmLabel: 'Повторите пароль',
  showPassword: 'Показать пароль',
  hidePassword: 'Скрыть пароль',
  passwordRequired: 'Введите пароль',
  passwordTooShort: 'Пароль должен содержать не менее 8 символов',
  passwordMismatch: 'Пароли не совпадают',
  consentRequired: 'Отметьте флажок, чтобы продолжить',
  signInTitle: 'Вход',
  forgotPassword: 'Забыли пароль',
  forgotTitle: 'Сброс пароля',
  forgotBody:
      'Введите e-mail аккаунта, и мы отправим ссылку для сброса пароля.',
  forgotSend: 'Отправить ссылку',
  forgotSent:
      'Если этот e-mail зарегистрирован, ссылка отправлена. Проверьте входящие и папку «Спам».',
  verifyTitle: 'Подтвердите e-mail',
  verifyBody:
      'Мы отправили ссылку для подтверждения на {email}. Проверьте входящие (и папку «Спам») и нажмите на ссылку.',
  verifyResend: 'Отправить ещё раз',
  verifyResent: 'Письмо для подтверждения отправлено повторно.',
  verifyDone: 'Я подтвердил(а)',
  verifyNotYet:
      'E-mail пока не подтверждён. Нажмите на ссылку в письме и повторите.',
  verifyLater: 'Пропустить',
  errEmailInUse: 'Аккаунт с этим e-mail уже существует. Попробуйте войти.',
  errInvalidEmail: 'Введите корректный e-mail.',
  errWeakPassword: 'Слишком простой пароль. Выберите длиннее.',
  errWrongCredentials: 'Неверный e-mail или пароль.',
  errNetwork: 'Проблема с соединением. Проверьте интернет и повторите.',
  errTooMany: 'Слишком много попыток. Подождите и повторите.',
  errUnavailable: 'Сервис аккаунтов сейчас недоступен. Попробуйте позже.',
  errGeneric: 'Что-то пошло не так. Повторите попытку.',
  sheetTitle: 'Создайте аккаунт, сохраните Premium',
  sheetBody:
      'Premium привязывается к аккаунту и вернётся при входе на новом телефоне. Создание аккаунта бесплатно.',
  sheetNotNow: 'Не сейчас',
  saveTitle: 'Создайте аккаунт для сохранения',
  saveBody:
      'Сохранённые расчёты хранятся в облаке под вашим аккаунтом и доступны на всех устройствах.',
  accountVerified: 'E-mail подтверждён',
  accountUnverifiedNotice:
      'E-mail ещё не подтверждён. Облачные пресеты и Premium-аккаунт заработают после подтверждения.',
  accountVerifyNow: 'Подтвердить e-mail',
  accountGuestBody:
      'Создайте аккаунт или войдите: пресеты хранятся в облаке, а Premium следует за вами на новые устройства.',
  accountSignedInNote: 'Сохранённые расчёты привязаны к этому аккаунту.',
  deleteReauthTitle: 'Подтвердите, что это вы',
  deleteReauthBody: 'Введите пароль ещё раз, чтобы удалить аккаунт.',
);

const _de = AuthCopy(
  registerButton: 'Mit E-Mail registrieren',
  signInButton: 'Anmelden',
  guestButton: 'Als Gast fortfahren',
  signInRequired: 'Bitte melden Sie sich bei Ihrem Konto an.',
  legacyTitle: 'Unser Kontosystem wurde erneuert',
  legacyBody:
      'Um Ihre gespeicherten Berechnungen zu sehen, registrieren Sie sich oder melden Sie sich mit derselben E-Mail an. Ihre alten Vorlagen kommen zurück.',
  unavailableNote:
      'Konten sind derzeit nicht verfügbar. Sie können als Gast fortfahren.',
  orWord: 'oder',
  passwordLabel: 'Passwort',
  passwordConfirmLabel: 'Passwort bestätigen',
  showPassword: 'Passwort anzeigen',
  hidePassword: 'Passwort verbergen',
  passwordRequired: 'Passwort eingeben',
  passwordTooShort: 'Das Passwort muss mindestens 8 Zeichen haben',
  passwordMismatch: 'Passwörter stimmen nicht überein',
  consentRequired: 'Zum Fortfahren das Kästchen aktivieren',
  signInTitle: 'Anmelden',
  forgotPassword: 'Passwort vergessen',
  forgotTitle: 'Passwort zurücksetzen',
  forgotBody:
      'Geben Sie die E-Mail Ihres Kontos ein; wir senden Ihnen einen Link zum Zurücksetzen.',
  forgotSend: 'Link senden',
  forgotSent:
      'Falls diese E-Mail registriert ist, wurde ein Link gesendet. Prüfen Sie Posteingang und Spam-Ordner.',
  verifyTitle: 'E-Mail bestätigen',
  verifyBody:
      'Wir haben einen Bestätigungslink an {email} gesendet. Prüfen Sie Posteingang (und Spam-Ordner) und tippen Sie auf den Link.',
  verifyResend: 'Erneut senden',
  verifyResent: 'Bestätigungs-E-Mail erneut gesendet.',
  verifyDone: 'Ich habe bestätigt',
  verifyNotYet:
      'Die E-Mail scheint noch nicht bestätigt. Tippen Sie auf den Link und versuchen Sie es erneut.',
  verifyLater: 'Vorerst überspringen',
  errEmailInUse:
      'Für diese E-Mail existiert bereits ein Konto. Versuchen Sie die Anmeldung.',
  errInvalidEmail: 'Geben Sie eine gültige E-Mail-Adresse ein.',
  errWeakPassword: 'Das Passwort ist zu schwach. Wählen Sie ein längeres.',
  errWrongCredentials: 'E-Mail oder Passwort falsch.',
  errNetwork:
      'Verbindungsproblem. Prüfen Sie Ihr Internet und versuchen Sie es erneut.',
  errTooMany: 'Zu viele Versuche. Warten Sie kurz und versuchen Sie es erneut.',
  errUnavailable:
      'Der Kontodienst ist derzeit nicht verfügbar. Versuchen Sie es später erneut.',
  errGeneric: 'Etwas ist schiefgelaufen. Bitte erneut versuchen.',
  sheetTitle: 'Konto erstellen, Premium behalten',
  sheetBody:
      'Premium ist an Ihr Konto gebunden und kommt bei der Anmeldung auf einem neuen Telefon zurück. Das Konto ist kostenlos.',
  sheetNotNow: 'Jetzt nicht',
  saveTitle: 'Konto zum Speichern erstellen',
  saveBody:
      'Gespeicherte Berechnungen liegen in der Cloud unter Ihrem Konto und folgen Ihnen auf alle Geräte.',
  accountVerified: 'E-Mail bestätigt',
  accountUnverifiedNotice:
      'Ihre E-Mail ist noch nicht bestätigt. Cloud-Vorlagen und Ihr Premium-Konto werden nach der Bestätigung aktiv.',
  accountVerifyNow: 'E-Mail bestätigen',
  accountGuestBody:
      'Konto erstellen oder anmelden: Vorlagen liegen in der Cloud, Premium folgt Ihnen auf neue Geräte.',
  accountSignedInNote:
      'Ihre gespeicherten Berechnungen sind an dieses Konto gebunden.',
  deleteReauthTitle: 'Bitte bestätigen',
  deleteReauthBody:
      'Geben Sie Ihr Passwort erneut ein, um das Konto zu löschen.',
);

const _hi = AuthCopy(
  registerButton: 'ईमेल से साइन अप करें',
  signInButton: 'साइन इन',
  guestButton: 'अतिथि के रूप में जारी रखें',
  signInRequired: 'कृपया अपने खाते में साइन इन करें।',
  legacyTitle: 'हमारा खाता सिस्टम नया हो गया है',
  legacyBody:
      'अपनी सेव की गई गणनाएँ देखने के लिए उसी ईमेल से साइन अप या साइन इन करें। आपके पुराने प्रीसेट वापस आ जाएँगे।',
  unavailableNote:
      'खाते अभी उपलब्ध नहीं हैं। आप अतिथि के रूप में जारी रख सकते हैं।',
  orWord: 'या',
  passwordLabel: 'पासवर्ड',
  passwordConfirmLabel: 'पासवर्ड दोबारा लिखें',
  showPassword: 'पासवर्ड दिखाएँ',
  hidePassword: 'पासवर्ड छिपाएँ',
  passwordRequired: 'पासवर्ड दर्ज करें',
  passwordTooShort: 'पासवर्ड कम से कम 8 अक्षरों का होना चाहिए',
  passwordMismatch: 'पासवर्ड मेल नहीं खाते',
  consentRequired: 'आगे बढ़ने के लिए बॉक्स पर टिक करें',
  signInTitle: 'साइन इन',
  forgotPassword: 'पासवर्ड भूल गए',
  forgotTitle: 'पासवर्ड रीसेट करें',
  forgotBody:
      'अपने खाते का ईमेल दर्ज करें; हम आपको पासवर्ड रीसेट लिंक भेजेंगे।',
  forgotSend: 'रीसेट लिंक भेजें',
  forgotSent:
      'यदि यह ईमेल पंजीकृत है तो रीसेट लिंक भेज दिया गया है। इनबॉक्स और स्पैम फ़ोल्डर देखें।',
  verifyTitle: 'अपना ईमेल सत्यापित करें',
  verifyBody:
      'हमने {email} पर सत्यापन लिंक भेजा है। इनबॉक्स (और स्पैम फ़ोल्डर) देखें और लिंक पर टैप करें।',
  verifyResend: 'दोबारा भेजें',
  verifyResent: 'सत्यापन ईमेल दोबारा भेजा गया।',
  verifyDone: 'मैंने सत्यापित कर लिया',
  verifyNotYet:
      'ईमेल अभी सत्यापित नहीं दिख रहा। ईमेल का लिंक टैप करके फिर कोशिश करें।',
  verifyLater: 'अभी छोड़ें',
  errEmailInUse: 'इस ईमेल से खाता पहले से मौजूद है। साइन इन करें।',
  errInvalidEmail: 'मान्य ईमेल पता दर्ज करें।',
  errWeakPassword: 'पासवर्ड बहुत कमज़ोर है। लंबा पासवर्ड चुनें।',
  errWrongCredentials: 'ईमेल या पासवर्ड गलत है।',
  errNetwork: 'कनेक्शन की समस्या। इंटरनेट जाँचकर फिर कोशिश करें।',
  errTooMany: 'बहुत अधिक प्रयास। थोड़ी देर बाद फिर कोशिश करें।',
  errUnavailable: 'खाता सेवा अभी उपलब्ध नहीं है। बाद में कोशिश करें।',
  errGeneric: 'कुछ गलत हो गया। फिर कोशिश करें।',
  sheetTitle: 'खाता बनाएँ, Premium सुरक्षित रखें',
  sheetBody:
      'Premium आपके खाते से जुड़ता है, इसलिए नए फ़ोन पर साइन इन करते ही वापस आ जाता है। खाता बनाना मुफ़्त है।',
  sheetNotNow: 'अभी नहीं',
  saveTitle: 'सेव करने के लिए खाता बनाएँ',
  saveBody:
      'आपकी सेव की गई गणनाएँ आपके खाते के तहत क्लाउड में रहती हैं और सभी डिवाइस पर साथ चलती हैं।',
  accountVerified: 'ईमेल सत्यापित',
  accountUnverifiedNotice:
      'आपका ईमेल अभी सत्यापित नहीं है। क्लाउड प्रीसेट और Premium खाता सत्यापन के बाद सक्रिय होंगे।',
  accountVerifyNow: 'ईमेल सत्यापित करें',
  accountGuestBody:
      'खाता बनाएँ या साइन इन करें: प्रीसेट क्लाउड में रहते हैं और Premium नए डिवाइस पर साथ चलता है।',
  accountSignedInNote: 'आपकी सेव की गई गणनाएँ इसी खाते से जुड़ी हैं।',
  deleteReauthTitle: 'पुष्टि करें कि यह आप हैं',
  deleteReauthBody: 'खाता हटाने के लिए पासवर्ड फिर से दर्ज करें।',
);

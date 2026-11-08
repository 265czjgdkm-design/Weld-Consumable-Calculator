# Localized welcome mail

The app submits the welcome trigger to the Google Form once per account, at
the first verified sign-in, with the email, the first name from the
registration form and the app language code (en/tr/de/ru/hi).

Status (1.0.1): the Form has the optional short-answer questions "First
name" (`entry.1576418057`) and "Locale" (`entry.1914024187`), wired in
`lib/services/signup_config.dart` (`firstNameEntryField`,
`localeEntryField`); both submitters send them.

On the script side: `docs/apps_script/Kod_auth.gs` already reads the "First
   name" / "Locale" answers by title, embeds these five templates
   (`WELCOME_TEMPLATES_`, generated verbatim from this folder -- regenerate
   it if a template changes), picks `welcome_<locale>` (fallback `en`),
   fills `{{firstName}}` (HTML-escaped; dropped when empty), takes the
   subject from the first-line comment and sends through Resend like the
   live script. While both answers are empty the original live mail is sent.

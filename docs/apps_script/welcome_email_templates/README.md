# Localized welcome mail

The app submits the welcome trigger to the Google Form only after a
successful registration (and for a brand-new Sign in with Apple account).

The form currently has ONLY the email question, so first name and locale are
not sent yet (`SignupConfig.firstNameEntryField` / `localeEntryField` are
`null`). To switch on the personalised mail:

1. In the Google Form add two short-answer questions: "First name" and
   "Locale" (not required). Get their ids from the pre-filled link
   (`entry.NNN`).
2. Paste the ids into `lib/services/signup_config.dart`
   (`firstNameEntryField`, `localeEntryField`). Nothing else in the app
   changes; both submitters already send them when set.
3. Nothing else: `docs/apps_script/Kod_auth.gs` already reads the "First
   name" / "Locale" answers by title, embeds these five templates
   (`WELCOME_TEMPLATES_`, generated verbatim from this folder -- regenerate
   it if a template changes), picks `welcome_<locale>` (fallback `en`),
   fills `{{firstName}}` (HTML-escaped; dropped when empty), takes the
   subject from the first-line comment and sends through Resend like the
   live script. While both answers are empty the original live mail is sent.

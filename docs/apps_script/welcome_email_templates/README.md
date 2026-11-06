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
3. In the form-bound Apps Script (`onFormSubmit` trigger), read the answers by
   question title, pick `welcome_<locale>.html` (fallback `en`), replace
   `{{firstName}}` with the HTML-escaped first name (fallback: "there"),
   take the subject from the first-line HTML comment and send with
   `MailApp.sendEmail({to, subject, htmlBody, name: 'Varyos Weld',
   replyTo: 'team@varyosweld.com'})`. Store the five HTML files as HTML
   files in the Apps Script project (`HtmlService.createHtmlOutputFromFile`)
   or as string constants.

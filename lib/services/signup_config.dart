/// Configuration for the post-splash email-capture step.
///
/// Submissions go to a Google Form (created under the project's own Google
/// account, zero cost, no billing account required) whose responses land in
/// a linked Google Sheet; a bound Apps Script sends the welcome email from
/// there. See lib/services/signup_service.dart for the submission code.
class SignupConfig {
  const SignupConfig._();

  static const String formResponseUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLSdxzjxWewO-7ncfq0S2pgwWvnzllVKYEygO2vhjcxqw5acubw/formResponse';

  static const String emailEntryField = 'entry.708179914';

  // TODO(welcome-email): the Google Form currently has ONLY the email
  // question. To send a personalised, localized welcome mail, add two short
  // answer questions (first name, locale) to the form, paste their
  // `entry.NNN` ids below and update the Apps Script as described in
  // docs/apps_script/welcome_email_templates/README.md. While these are null
  // they are simply not submitted.
  static const String? firstNameEntryField = null;
  static const String? localeEntryField = null;

  /// Apps Script Web App URL backing the account-based preset sync API
  /// (doGet/doPost in the same project as the welcome-email trigger, backed
  /// by a lazily-created "Varyos Weld - Presets" Google Sheet keyed by
  /// email). See lib/services/preset_sync_service.dart.
  static const String presetApiUrl =
      'https://script.google.com/macros/s/AKfycbzRk_P38l3vtj6RaPMDD-0Z0-gzvoFmK4gArfYGKg2vPFOUzdIk2rfDe7zx9TrbiexiKg/exec';
}

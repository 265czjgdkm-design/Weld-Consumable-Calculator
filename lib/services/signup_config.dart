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
}

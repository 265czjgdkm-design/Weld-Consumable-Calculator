import 'signup_submitter_stub.dart'
    if (dart.library.html) 'signup_submitter_web.dart'
    as submitter;

/// Submits the welcome-mail trigger. Call only after a successful
/// verified sign-in. [firstName] and [locale] (app language code) are sent
/// when given (see SignupConfig).
Future<bool> submitSignupEmail(
  String email, {
  String? firstName,
  String? locale,
}) => submitter.submitSignupEmail(email, firstName: firstName, locale: locale);

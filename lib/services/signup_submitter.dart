import 'signup_submitter_stub.dart'
    if (dart.library.html) 'signup_submitter_web.dart'
    as submitter;

/// Submits the welcome-mail trigger. Call only after a successful
/// registration. [firstName] and [locale] are sent only when the form has
/// the matching fields (see SignupConfig).
Future<bool> submitSignupEmail(
  String email, {
  String? firstName,
  String? locale,
}) => submitter.submitSignupEmail(email, firstName: firstName, locale: locale);

import 'signup_submitter_stub.dart'
    if (dart.library.html) 'signup_submitter_web.dart'
    as submitter;

Future<bool> submitSignupEmail(String email) => submitter.submitSignupEmail(email);

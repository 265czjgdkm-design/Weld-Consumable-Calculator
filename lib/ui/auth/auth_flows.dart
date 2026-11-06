import 'package:flutter/material.dart';

import '../../l10n/app_locale_scope.dart';
import '../../l10n/app_language.dart';
import '../../services/account_session.dart';
import '../../services/auth_service.dart';
import '../../services/entitlement_service.dart';
import '../../services/signup_submitter.dart';
import 'auth_widgets.dart';

/// How an auth flow ended. [unverified] means an email account exists but its
/// address is not verified yet (cloud presets and Premium stay off).
enum AuthOutcome { none, unverified, verified }

/// Sends the welcome-mail trigger. Call only after a successful registration.
Future<void> sendWelcomeMail(
  BuildContext context, {
  required String email,
  required String firstName,
}) {
  final language = AppLocaleScope.of(context).language;
  return submitSignupEmail(email, firstName: firstName, locale: language.code);
}

/// Whole Sign in with Apple flow: native sheet, Firebase sign-in, account
/// session, welcome mail for a brand-new Apple account.
Future<AuthOutcome> runAppleSignIn(
  BuildContext context, {
  EntitlementService? entitlement,
}) async {
  final copy = authCopyOf(context);
  final messenger = ScaffoldMessenger.of(context);
  final auth = AuthServices.instance;
  try {
    final result = await auth.signInWithApple();
    await AccountSession.apply(result.user, entitlement: entitlement);
    final email = result.user.email;
    if (result.isNewUser && email != null && context.mounted) {
      await sendWelcomeMail(
        context,
        email: email,
        firstName: result.user.firstName,
      );
    }
    return AuthOutcome.verified;
  } on AuthException catch (error) {
    if (error.code != AuthErrorCode.cancelled) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(authErrorText(copy, error))));
    }
    return AuthOutcome.none;
  }
}

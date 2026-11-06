import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/l10n/auth_copy.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/services/auth_service.dart';
import 'package:weld_consumable_calculator/services/entitlement_service.dart';
import 'package:weld_consumable_calculator/services/signup_gate_store.dart';
import 'package:weld_consumable_calculator/services/user_account_store.dart';
import 'package:weld_consumable_calculator/ui/auth/auth_flows.dart';
import 'package:weld_consumable_calculator/ui/auth/auth_screens.dart';
import 'package:weld_consumable_calculator/ui/email_gate_screen.dart';
import 'package:weld_consumable_calculator/ui/premium_paywall.dart';

import '../support/fake_auth_service.dart';

class _RecordingEntitlement extends EntitlementService {
  final calls = <String?>[];

  @override
  Future<void> syncAccount(String? appUserId) async => calls.add(appUserId);
}

final _copy = authCopyFor(AppLanguage.en);
final _strings = stringsFor(AppLanguage.en);

late FakeAuthService _auth;
AuthOutcome? _lastOutcome;

/// Opens [screen] on top of a launcher route so pops deliver a result.
Future<void> _open(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  _lastOutcome = null;
  final locale = AppLocale();
  await locale.setLanguage(AppLanguage.en);
  await tester.pumpWidget(
    AppLocaleScope(
      locale: locale,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                _lastOutcome = await Navigator.of(
                  context,
                ).push<AuthOutcome>(MaterialPageRoute(builder: (_) => screen));
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _fill(WidgetTester tester, String label, String text) async {
  await tester.enterText(find.widgetWithText(TextField, label), text);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _auth = FakeAuthService();
    AuthServices.instance = _auth;
  });
  tearDown(() => AuthServices.instance = const UnavailableAuthService());

  group('registration validation', () {
    testWidgets('empty submit shows every error and creates nothing', (
      tester,
    ) async {
      await _open(tester, const RegistrationScreen());
      await tester.tap(find.text(_strings.authFormSubmitButton));
      await tester.pumpAndSettle();

      expect(find.text(_strings.authFormFirstNameError), findsOneWidget);
      expect(find.text(_strings.authFormLastNameError), findsOneWidget);
      expect(find.text(_strings.emailGateInvalidEmail), findsOneWidget);
      expect(find.text(_copy.passwordTooShort), findsOneWidget);
      expect(find.text(_copy.consentRequired), findsOneWidget);
      expect(_auth.signUps, isEmpty);
    });

    testWidgets('password needs 8 chars, confirmation must match', (
      tester,
    ) async {
      await _open(tester, const RegistrationScreen());
      await _fill(tester, _strings.authFormFirstNameLabel, 'Ayse');
      await _fill(tester, _strings.authFormLastNameLabel, 'Yilmaz');
      await _fill(tester, _strings.authFormEmailLabel, 'a@b.co');
      await _fill(tester, _copy.passwordLabel, 'short');
      await _fill(tester, _copy.passwordConfirmLabel, 'different');
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.tap(find.text(_strings.authFormSubmitButton));
      await tester.pumpAndSettle();

      expect(find.text(_copy.passwordTooShort), findsOneWidget);
      expect(find.text(_copy.passwordMismatch), findsOneWidget);
      expect(find.text(_copy.consentRequired), findsNothing);
      expect(_auth.signUps, isEmpty);
    });

    testWidgets('the password field can be revealed', (tester) async {
      await _open(tester, const RegistrationScreen());
      TextField field() => tester.widget<TextField>(
        find.widgetWithText(TextField, _copy.passwordLabel),
      );
      expect(field().obscureText, isTrue);
      await tester.tap(find.byTooltip(_copy.showPassword).first);
      await tester.pump();
      expect(field().obscureText, isFalse);
    });

    testWidgets('scrolls the first invalid field into view', (tester) async {
      await _open(tester, const RegistrationScreen());
      tester.view.physicalSize = const Size(800, 420);
      await tester.pumpAndSettle();
      await _fill(tester, _strings.authFormFirstNameLabel, 'Ayse');
      await _fill(tester, _strings.authFormLastNameLabel, 'Yilmaz');
      // Email left empty; password fields sit below the fold.
      await _fill(tester, _copy.passwordLabel, 'longenough1');
      await _fill(tester, _copy.passwordConfirmLabel, 'longenough1');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      final submit = find.text(_strings.authFormSubmitButton);
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      final emailTop = tester
          .getTopLeft(
            find.widgetWithText(TextField, _strings.authFormEmailLabel),
          )
          .dy;
      expect(emailTop, inInclusiveRange(0, 420));
    });
  });

  group('registration and email verification gate', () {
    Future<void> register(WidgetTester tester) async {
      await _fill(tester, _strings.authFormFirstNameLabel, 'Ayse');
      await _fill(tester, _strings.authFormLastNameLabel, 'Yilmaz');
      await _fill(tester, _strings.authFormEmailLabel, 'Ayse@Example.com');
      await _fill(tester, _copy.passwordLabel, 'longenough1');
      await _fill(tester, _copy.passwordConfirmLabel, 'longenough1');
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.tap(find.text(_strings.authFormSubmitButton));
      await tester.pumpAndSettle();
    }

    testWidgets('sign-up lands on the check-your-inbox screen', (tester) async {
      await _open(tester, const RegistrationScreen());
      await register(tester);

      expect(_auth.signUps.single.firstName, 'Ayse');
      expect(_auth.signUps.single.lastName, 'Yilmaz');
      expect(find.text(_copy.verifyTitle), findsOneWidget);
      expect(find.textContaining('ayse@example.com'), findsOneWidget);
      // Unverified: no cloud identity yet.
      expect(await const UserAccountStore().getEmail(), isNull);
    });

    testWidgets('"I verified" before verifying stays and explains', (
      tester,
    ) async {
      await _open(tester, const RegistrationScreen());
      await register(tester);

      await tester.tap(find.text(_copy.verifyDone));
      await tester.pumpAndSettle();
      expect(find.text(_copy.verifyNotYet), findsOneWidget);
      expect(find.text(_copy.verifyTitle), findsOneWidget);
    });

    testWidgets('resend sends another verification mail', (tester) async {
      await _open(tester, const RegistrationScreen());
      await register(tester);
      final before = _auth.verificationMailsSent;

      await tester.tap(find.text(_copy.verifyResend));
      await tester.pumpAndSettle();
      expect(_auth.verificationMailsSent, before + 1);
      expect(find.text(_copy.verifyResent), findsOneWidget);
    });

    testWidgets('after verifying, "I verified" completes and binds the email', (
      tester,
    ) async {
      final rc = _RecordingEntitlement();
      await _open(tester, RegistrationScreen(entitlementService: rc));
      await register(tester);
      _auth.verifiedAfterReload = true;

      await tester.tap(find.text(_copy.verifyDone));
      await tester.pumpAndSettle();

      expect(_lastOutcome, AuthOutcome.verified);
      expect(await const UserAccountStore().getEmail(), 'ayse@example.com');
      expect(rc.calls, ['uid-new']);
    });

    testWidgets('"Skip for now" leaves the account unverified', (tester) async {
      final rc = _RecordingEntitlement();
      await _open(tester, RegistrationScreen(entitlementService: rc));
      await register(tester);

      await tester.tap(find.text(_copy.verifyLater));
      await tester.pumpAndSettle();
      expect(_lastOutcome, AuthOutcome.unverified);
      expect(await const UserAccountStore().getEmail(), isNull);
      expect(rc.calls, isEmpty);
    });

    testWidgets('an email already in use is reported on the email field', (
      tester,
    ) async {
      await _open(tester, const RegistrationScreen());
      _auth.failNext = const AuthException(AuthErrorCode.emailInUse);
      await _fill(tester, _strings.authFormFirstNameLabel, 'Ayse');
      await _fill(tester, _strings.authFormLastNameLabel, 'Yilmaz');
      await _fill(tester, _strings.authFormEmailLabel, 'a@b.co');
      await _fill(tester, _copy.passwordLabel, 'longenough1');
      await _fill(tester, _copy.passwordConfirmLabel, 'longenough1');
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.tap(find.text(_strings.authFormSubmitButton));
      await tester.pumpAndSettle();

      expect(find.text(_copy.errEmailInUse), findsOneWidget);
      expect(find.text(_copy.verifyTitle), findsNothing);
    });
  });

  group('sign in', () {
    testWidgets('an unverified account is sent to the verify screen', (
      tester,
    ) async {
      _auth.user = fakeUser(emailVerified: false);
      await _open(tester, const SignInScreen());
      await _fill(tester, _strings.authFormEmailLabel, 'user@example.com');
      await _fill(tester, _copy.passwordLabel, 'longenough1');
      await tester.tap(find.widgetWithText(FilledButton, _copy.signInButton));
      await tester.pumpAndSettle();

      expect(find.text(_copy.verifyTitle), findsOneWidget);
      expect(await const UserAccountStore().getEmail(), isNull);
    });

    testWidgets('a verified account signs in and binds the email', (
      tester,
    ) async {
      final rc = _RecordingEntitlement();
      _auth.user = fakeUser();
      await _open(tester, SignInScreen(entitlementService: rc));
      await _fill(tester, _strings.authFormEmailLabel, 'user@example.com');
      await _fill(tester, _copy.passwordLabel, 'longenough1');
      await tester.tap(find.widgetWithText(FilledButton, _copy.signInButton));
      await tester.pumpAndSettle();

      expect(_lastOutcome, AuthOutcome.verified);
      expect(await const UserAccountStore().getEmail(), 'user@example.com');
      expect(rc.calls, ['uid-1']);
    });

    testWidgets('wrong credentials show an error and stay', (tester) async {
      await _open(tester, const SignInScreen());
      _auth.failNext = const AuthException(AuthErrorCode.wrongCredentials);
      await _fill(tester, _strings.authFormEmailLabel, 'user@example.com');
      await _fill(tester, _copy.passwordLabel, 'wrongwrong');
      await tester.tap(find.widgetWithText(FilledButton, _copy.signInButton));
      await tester.pumpAndSettle();
      expect(find.text(_copy.errWrongCredentials), findsOneWidget);
    });
  });

  group('password reset', () {
    testWidgets('"Forgot password" sends a reset mail for the typed email', (
      tester,
    ) async {
      await _open(tester, const SignInScreen());
      await _fill(tester, _strings.authFormEmailLabel, 'user@example.com');
      await tester.tap(find.text(_copy.forgotPassword));
      await tester.pumpAndSettle();

      expect(find.text(_copy.forgotTitle), findsOneWidget);
      await tester.tap(find.text(_copy.forgotSend));
      await tester.pumpAndSettle();
      expect(_auth.resetRequests, ['user@example.com']);
      expect(find.text(_copy.forgotSent), findsOneWidget);
    });

    testWidgets('an unknown email gets the same confirmation', (tester) async {
      await _open(tester, const ForgotPasswordScreen(initialEmail: 'x@y.co'));
      _auth.failNext = const AuthException(AuthErrorCode.userNotFound);
      await tester.tap(find.text(_copy.forgotSend));
      await tester.pumpAndSettle();
      expect(find.text(_copy.forgotSent), findsOneWidget);
    });

    testWidgets('an invalid email is rejected before sending', (tester) async {
      await _open(tester, const ForgotPasswordScreen(initialEmail: 'nope'));
      await tester.tap(find.text(_copy.forgotSend));
      await tester.pumpAndSettle();
      expect(find.text(_strings.emailGateInvalidEmail), findsOneWidget);
      expect(_auth.resetRequests, isEmpty);
    });
  });

  group('first-launch gate', () {
    Future<void> pumpGate(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final locale = AppLocale();
      await locale.setLanguage(AppLanguage.en);
      await tester.pumpWidget(
        AppLocaleScope(
          locale: locale,
          child: const MaterialApp(home: EmailGateScreen()),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('offers Apple first, then email sign-up, sign-in and guest', (
      tester,
    ) async {
      await pumpGate(tester);
      expect(find.byType(SignInWithAppleButton), findsOneWidget);
      expect(find.text(_copy.appleButton), findsOneWidget);
      expect(find.text(_copy.registerButton), findsOneWidget);
      expect(find.text(_copy.signInButton), findsOneWidget);
      expect(find.text(_copy.guestButton), findsOneWidget);

      final appleY = tester.getTopLeft(find.byType(SignInWithAppleButton)).dy;
      final registerY = tester.getTopLeft(find.text(_copy.registerButton)).dy;
      expect(appleY, lessThan(registerY));
    });

    testWidgets('Apple sign-in resolves the gate', (tester) async {
      await pumpGate(tester);
      await tester.tap(find.text(_copy.appleButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(_auth.appleSignIns, 1);
      expect(await const SignupGateStore().isResolved(), isTrue);
    });

    testWidgets('a cancelled Apple sheet keeps the gate open', (tester) async {
      await pumpGate(tester);
      _auth.failNext = const AuthException(AuthErrorCode.cancelled);
      await tester.tap(find.text(_copy.appleButton));
      await tester.pumpAndSettle();
      expect(await const SignupGateStore().isResolved(), isFalse);
      expect(find.text(_copy.appleButton), findsOneWidget);
    });
  });

  group('guest purchase', () {
    Future<void> pumpOffer(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final locale = AppLocale();
      await locale.setLanguage(AppLanguage.en);
      await tester.pumpWidget(
        AppLocaleScope(
          locale: locale,
          child: MaterialApp(
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () =>
                    offerAccountAfterPurchase(context, EntitlementService()),
                child: const Text('purchased'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('purchased'));
      await tester.pumpAndSettle();
    }

    testWidgets('a guest sees the dismissible account sheet', (tester) async {
      await pumpOffer(tester);
      expect(find.text(_copy.sheetTitle), findsOneWidget);
      expect(find.text(_copy.appleButton), findsOneWidget);
      expect(find.text(_copy.registerButton), findsOneWidget);

      await tester.tap(find.text(_copy.sheetNotNow));
      await tester.pumpAndSettle();
      expect(find.text(_copy.sheetTitle), findsNothing);
    });

    testWidgets('a verified user is not asked again', (tester) async {
      _auth.user = fakeUser();
      await pumpOffer(tester);
      expect(find.text(_copy.sheetTitle), findsNothing);
    });

    testWidgets('an unverified user is still offered the sheet', (
      tester,
    ) async {
      _auth.user = fakeUser(emailVerified: false);
      await pumpOffer(tester);
      expect(find.text(_copy.sheetTitle), findsOneWidget);
    });
  });
}

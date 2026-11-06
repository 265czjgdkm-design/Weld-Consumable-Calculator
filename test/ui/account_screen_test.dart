import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/ai_consent_store.dart';
import 'package:weld_consumable_calculator/services/auth_service.dart';
import 'package:weld_consumable_calculator/services/user_account_store.dart';
import 'package:weld_consumable_calculator/services/user_preset_store.dart';
import 'package:weld_consumable_calculator/ui/account_screen.dart';

import '../support/fake_auth_service.dart';

class _MockUrlLauncherPlatform extends UrlLauncherPlatform {
  String? lastLaunchedUrl;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    lastLaunchedUrl = url;
    return true;
  }
}

Future<void> _pumpAccountScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    AppLocaleScope(
      locale: AppLocale(),
      child: const MaterialApp(home: AccountScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final strings = stringsFor(AppLanguage.en);
  late FakeAuthService auth;

  setUp(() {
    auth = FakeAuthService();
    AuthServices.instance = auth;
  });
  tearDown(() => AuthServices.instance = const UnavailableAuthService());

  group('Signed-in state', () {
    testWidgets('Sign Out clears the account identity but leaves local saved '
        'calculations untouched', (tester) async {
      final localPreset = UserWeldPreset(
        id: 'local-1',
        name: 'Local Preset',
        updatedAtEpochMs: 1000,
        data: InputPreset.csPlateSingleVGmaw.data!,
      );
      SharedPreferences.setMockInitialValues({
        'user_account_email_v1': 'user@example.com',
        'user_weld_presets_v1': jsonEncode([localPreset.toJson()]),
      });
      auth.user = fakeUser();

      await _pumpAccountScreen(tester);

      // This account has no first/last name on file, so the identity
      // header falls back to showing the email itself (see the dedicated
      // named-user test below for the common case, where the header shows
      // the name and the body shows the email -- two different strings).
      expect(find.text('user@example.com'), findsNWidgets(2));

      await tester.tap(find.text(strings.accountSignOutButton));
      await tester.pumpAndSettle();

      // Account identity is gone -- the screen now shows the Guest form.
      expect(find.text('user@example.com'), findsNothing);
      expect(find.text(strings.accountGuestStateTitle), findsOneWidget);

      const accountStore = UserAccountStore();
      expect(await accountStore.getEmail(), isNull);

      // Local presets were NOT touched by Sign Out (decision #1).
      const presetStore = UserPresetStore();
      final survivingPresets = (await presetStore.load()).presets;
      expect(survivingPresets, hasLength(1));
      expect(survivingPresets.single.id, 'local-1');
    });

    testWidgets(
      'a signed-in user with a first/last name sees the name once (identity '
      'header) and the email once (signed-in detail body), not the same '
      'string duplicated in both places (reviewer finding: account-screen '
      'identity duplication)',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        auth.user = fakeUser(
          email: 'alice@example.com',
          displayName: 'Alice Smith',
        );

        await _pumpAccountScreen(tester);

        expect(find.text('Alice Smith'), findsOneWidget);
        expect(find.text('alice@example.com'), findsOneWidget);
      },
    );

    testWidgets(
      'Delete Account: Cancel leaves the account, local presets, and cloud '
      'data untouched',
      (tester) async {
        final localPreset = UserWeldPreset(
          id: 'local-1',
          name: 'Local Preset',
          updatedAtEpochMs: 1000,
          data: InputPreset.csPlateSingleVGmaw.data!,
        );
        SharedPreferences.setMockInitialValues({
          'user_account_email_v1': 'user@example.com',
          'user_weld_presets_v1': jsonEncode([localPreset.toJson()]),
        });
      auth.user = fakeUser();

        var listCalled = false;
        await http.runWithClient(
          () async {
            await _pumpAccountScreen(tester);

            await tester.tap(find.text(strings.accountDeleteAccountButton));
            await tester.pumpAndSettle();
            expect(
              find.text(strings.accountDeleteConfirmTitle),
              findsOneWidget,
            );

            await tester.tap(find.text(strings.commonCancel));
            await tester.pumpAndSettle();
          },
          () => MockClient((request) async {
            listCalled = true;
            return http.Response(jsonEncode({'ok': true, 'presets': []}), 200);
          }),
        );

        expect(listCalled, isFalse);
        expect(find.text('user@example.com'), findsNWidgets(2));

        const accountStore = UserAccountStore();
        expect(await accountStore.getEmail(), 'user@example.com');

        const presetStore = UserPresetStore();
        final survivingPresets = (await presetStore.load()).presets;
        expect(survivingPresets, hasLength(1));
      },
    );

    testWidgets(
      'Delete Account: Confirm sends one deleteAccount request for the '
      'email, clears local account + presets, and shows the success text',
      (tester) async {
        final localPreset = UserWeldPreset(
          id: 'local-1',
          name: 'Local Preset',
          updatedAtEpochMs: 1000,
          data: InputPreset.csPlateSingleVGmaw.data!,
        );
        SharedPreferences.setMockInitialValues({
          'user_account_email_v1': 'user@example.com',
          'user_weld_presets_v1': jsonEncode([localPreset.toJson()]),
        });
      auth.user = fakeUser();

        final bodies = <Map<String, dynamic>>[];
        await http.runWithClient(
          () async {
            await _pumpAccountScreen(tester);

            await tester.tap(find.text(strings.accountDeleteAccountButton));
            await tester.pumpAndSettle();
            await tester.tap(find.text(strings.commonDelete));
            await tester.pumpAndSettle();

            expect(
              find.text(strings.accountDeleteSuccessTitle),
              findsOneWidget,
            );
            expect(find.text(strings.accountDeleteSuccessBody), findsOneWidget);
            expect(find.text(strings.accountDeleteFailedTitle), findsNothing);

            await tester.tap(find.text(strings.commonContinue));
            await tester.pumpAndSettle();
          },
          () => MockClient((request) async {
            bodies.add(jsonDecode(request.body) as Map<String, dynamic>);
            return http.Response(jsonEncode({'ok': true}), 200);
          }),
        );

        expect(bodies, [
          {'action': 'deleteAccount', 'email': 'user@example.com'},
        ]);
        expect(await const UserAccountStore().getEmail(), isNull);
        expect((await const UserPresetStore().load()).presets, isEmpty);
      },
    );

    testWidgets(
      'Delete Account: a failed request shows the error with Retry (never '
      'the success text), still clears local state, and Retry re-sends '
      'the request for the same email until it succeeds',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'user_account_email_v1': 'user@example.com',
        });
      auth.user = fakeUser();

        var calls = 0;
        final emails = <String>[];
        await http.runWithClient(
          () async {
            await _pumpAccountScreen(tester);

            await tester.tap(find.text(strings.accountDeleteAccountButton));
            await tester.pumpAndSettle();
            await tester.tap(find.text(strings.commonDelete));
            await tester.pumpAndSettle();

            expect(find.text(strings.accountDeleteFailedTitle), findsOneWidget);
            expect(find.text(strings.accountDeleteFailedBody), findsOneWidget);
            expect(find.text(strings.accountDeleteSuccessTitle), findsNothing);
            expect(await const UserAccountStore().getEmail(), isNull);

            await tester.tap(find.text(strings.accountDeleteRetryButton));
            await tester.pumpAndSettle();

            expect(find.text(strings.accountDeleteFailedTitle), findsNothing);
            expect(
              find.text(strings.accountDeleteSuccessTitle),
              findsOneWidget,
            );
            await tester.tap(find.text(strings.commonContinue));
            await tester.pumpAndSettle();
          },
          () => MockClient((request) async {
            calls++;
            emails.add(
              (jsonDecode(request.body) as Map<String, dynamic>)['email']
                  as String,
            );
            // First attempt: server error. Second attempt: success.
            return calls == 1
                ? http.Response('Internal error', 500)
                : http.Response(jsonEncode({'ok': true}), 200);
          }),
        );

        expect(calls, 2);
        expect(emails, ['user@example.com', 'user@example.com']);
      },
    );

    testWidgets(
      'Delete Account: an ok:false response (e.g. a backend without the '
      'deleteAccount action) is treated as a failure, and closing the error '
      'leaves the user on the screen',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'user_account_email_v1': 'user@example.com',
        });
      auth.user = fakeUser();

        await http.runWithClient(
          () async {
            await _pumpAccountScreen(tester);

            await tester.tap(find.text(strings.accountDeleteAccountButton));
            await tester.pumpAndSettle();
            await tester.tap(find.text(strings.commonDelete));
            await tester.pumpAndSettle();

            expect(find.text(strings.accountDeleteFailedTitle), findsOneWidget);
            await tester.tap(find.text(strings.commonClose));
            await tester.pumpAndSettle();

            expect(find.text(strings.accountDeleteSuccessTitle), findsNothing);
            expect(find.text(strings.accountGuestStateTitle), findsOneWidget);
          },
          () => MockClient(
            (request) async => http.Response(
              jsonEncode({'ok': false, 'error': 'Unknown action.'}),
              200,
            ),
          ),
        );
      },
    );

    testWidgets(
      'Delete Account: while the request is in flight the screen stays '
      'signed-in with the deleting message, back is blocked, and the '
      'failure dialog still appears afterwards',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'user_account_email_v1': 'user@example.com',
        });
      auth.user = fakeUser();

        final gate = Completer<void>();
        await http.runWithClient(
          () async {
            await tester.pumpWidget(
              AppLocaleScope(
                locale: AppLocale(),
                child: MaterialApp(
                  home: Builder(
                    builder: (context) => TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AccountScreen(),
                        ),
                      ),
                      child: const Text('open account'),
                    ),
                  ),
                ),
              ),
            );
            await tester.tap(find.text('open account'));
            await tester.pumpAndSettle();

            await tester.tap(find.text(strings.accountDeleteAccountButton));
            await tester.pumpAndSettle();
            await tester.tap(find.text(strings.commonDelete));
            await tester.pump();
            await tester.pump();

            expect(find.text(strings.accountDeletingMessage), findsOneWidget);
            expect(find.text(strings.accountGuestStateTitle), findsNothing);
            expect(
              await const UserAccountStore().getEmail(),
              'user@example.com',
            );
            await tester.binding.handlePopRoute();
            await tester.pump();
            expect(find.text(strings.accountScreenTitle), findsOneWidget);

            gate.complete();
            await tester.pumpAndSettle();
            expect(find.text(strings.accountDeleteFailedTitle), findsOneWidget);
            expect(await const UserAccountStore().getEmail(), isNull);
          },
          () => MockClient((request) async {
            await gate.future;
            return http.Response('Internal error', 500);
          }),
        );
      },
    );

    testWidgets('Manage subscriptions opens the App Store subscriptions page', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'user_account_email_v1': 'user@example.com',
      });
      auth.user = fakeUser();
      final mockPlatform = _MockUrlLauncherPlatform();
      UrlLauncherPlatform.instance = mockPlatform;

      await _pumpAccountScreen(tester);
      expect(find.text(strings.accountSubscriptionNote), findsOneWidget);

      await tester.ensureVisible(
        find.text(strings.accountManageSubscriptionsButton),
      );
      await tester.tap(find.text(strings.accountManageSubscriptionsButton));
      await tester.pumpAndSettle();

      expect(
        mockPlatform.lastLaunchedUrl,
        'https://apps.apple.com/account/subscriptions',
      );
    });

    testWidgets(
      'Withdraw AI consent clears the stored consent and hides the button',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'user_account_email_v1': 'user@example.com',
          'ai_consent_acknowledged_v1': true,
        });
      auth.user = fakeUser();

        await _pumpAccountScreen(tester);
        await tester.ensureVisible(
          find.text(strings.accountWithdrawAiConsentButton),
        );
        await tester.tap(find.text(strings.accountWithdrawAiConsentButton));
        await tester.pumpAndSettle();

        expect(await const AiConsentStore().isAcknowledged(), isFalse);
        expect(find.text(strings.accountWithdrawAiConsentButton), findsNothing);
      },
    );
  });

  group('Guest state', () {
    testWidgets('offers Apple, email sign-up and sign-in, no email field', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await _pumpAccountScreen(tester);

      expect(find.text(strings.accountGuestStateTitle), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.text('Sign up with email'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('Unverified email account', () {
    testWidgets('shows the verify notice and no verified badge', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      auth.user = fakeUser(displayName: 'Ayse Yilmaz', emailVerified: false);
      await _pumpAccountScreen(tester);

      expect(find.text('Ayse Yilmaz'), findsOneWidget);
      expect(find.text('Verify email'), findsOneWidget);
      expect(find.text('Email verified'), findsNothing);
    });
  });
}

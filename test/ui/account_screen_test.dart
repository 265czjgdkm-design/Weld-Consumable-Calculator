import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/user_account_store.dart';
import 'package:weld_consumable_calculator/services/user_preset_store.dart';
import 'package:weld_consumable_calculator/ui/account_screen.dart';

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

      await _pumpAccountScreen(tester);

      expect(find.text('user@example.com'), findsOneWidget);

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
        expect(find.text('user@example.com'), findsOneWidget);

        const accountStore = UserAccountStore();
        expect(await accountStore.getEmail(), 'user@example.com');

        const presetStore = UserPresetStore();
        final survivingPresets = (await presetStore.load()).presets;
        expect(survivingPresets, hasLength(1));
      },
    );

    testWidgets(
      'Delete Account: Confirm lists then deletes every cloud preset, and '
      'clears the local account + preset cache',
      (tester) async {
        final cloudPreset1 = UserWeldPreset(
          id: 'cloud-1',
          name: 'Cloud Preset 1',
          updatedAtEpochMs: 1000,
          data: InputPreset.csPlateSingleVGmaw.data!,
        );
        final cloudPreset2 = UserWeldPreset(
          id: 'cloud-2',
          name: 'Cloud Preset 2',
          updatedAtEpochMs: 2000,
          data: InputPreset.csPlateSingleVGmaw.data!,
        );
        SharedPreferences.setMockInitialValues({
          'user_account_email_v1': 'user@example.com',
          'user_weld_presets_v1': jsonEncode([
            cloudPreset1.toJson(),
            cloudPreset2.toJson(),
          ]),
        });

        final deletedIds = <String>[];
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

            await tester.tap(find.text(strings.commonContinue));
            await tester.pumpAndSettle();
          },
          () => MockClient((request) async {
            final uri = request.url;
            if (request.method == 'GET' &&
                uri.queryParameters['action'] == 'listPresets') {
              return http.Response(
                jsonEncode({
                  'ok': true,
                  'presets': [cloudPreset1.toJson(), cloudPreset2.toJson()],
                }),
                200,
              );
            }
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            if (body['action'] == 'delete') {
              deletedIds.add(body['presetId'] as String);
              return http.Response(jsonEncode({'ok': true}), 200);
            }
            return http.Response(jsonEncode({'ok': false}), 200);
          }),
        );

        expect(deletedIds.toSet(), {'cloud-1', 'cloud-2'});

        const accountStore = UserAccountStore();
        expect(await accountStore.getEmail(), isNull);

        const presetStore = UserPresetStore();
        expect((await presetStore.load()).presets, isEmpty);
      },
    );

    testWidgets(
      'Delete Account: a cloud delete failure still fully clears local '
      'state, but shows the partial-failure message instead of claiming '
      'full success',
      (tester) async {
        final cloudPreset = UserWeldPreset(
          id: 'cloud-1',
          name: 'Cloud Preset',
          updatedAtEpochMs: 1000,
          data: InputPreset.csPlateSingleVGmaw.data!,
        );
        SharedPreferences.setMockInitialValues({
          'user_account_email_v1': 'user@example.com',
          'user_weld_presets_v1': jsonEncode([cloudPreset.toJson()]),
        });

        await http.runWithClient(
          () async {
            await _pumpAccountScreen(tester);

            await tester.tap(find.text(strings.accountDeleteAccountButton));
            await tester.pumpAndSettle();
            await tester.tap(find.text(strings.commonDelete));
            await tester.pumpAndSettle();

            expect(
              find.text(strings.accountDeletePartialFailureBody),
              findsOneWidget,
            );

            await tester.tap(find.text(strings.commonContinue));
            await tester.pumpAndSettle();
          },
          () => MockClient((request) async {
            if (request.method == 'GET') {
              return http.Response(
                jsonEncode({
                  'ok': true,
                  'presets': [cloudPreset.toJson()],
                }),
                200,
              );
            }
            // The delete call fails -- network/server error.
            return http.Response('Internal error', 500);
          }),
        );

        // The account is still fully cleared locally regardless of the
        // cloud failure.
        const accountStore = UserAccountStore();
        expect(await accountStore.getEmail(), isNull);
        const presetStore = UserPresetStore();
        expect((await presetStore.load()).presets, isEmpty);
      },
    );
  });

  group('Guest state', () {
    testWidgets(
      'Sign in with an existing email sets the account and triggers a '
      'preset refresh from the cloud',
      (tester) async {
        SharedPreferences.setMockInitialValues({});

        final syncedPreset = UserWeldPreset(
          id: 'synced-1',
          name: 'Synced Preset',
          updatedAtEpochMs: 1000,
          data: InputPreset.csPlateSingleVGmaw.data!,
        );

        await http.runWithClient(
          () async {
            await _pumpAccountScreen(tester);

            expect(find.text(strings.accountGuestStateTitle), findsOneWidget);

            await tester.enterText(
              find.byType(TextField),
              'existing@example.com',
            );
            await tester.tap(find.text(strings.accountSignInButton));
            await tester.pumpAndSettle();
          },
          () => MockClient((request) async {
            return http.Response(
              jsonEncode({
                'ok': true,
                'presets': [syncedPreset.toJson()],
              }),
              200,
            );
          }),
        );

        expect(find.text('existing@example.com'), findsOneWidget);

        const accountStore = UserAccountStore();
        expect(await accountStore.getEmail(), 'existing@example.com');

        const presetStore = UserPresetStore();
        final presets = (await presetStore.load()).presets;
        expect(presets, hasLength(1));
        expect(presets.single.id, 'synced-1');
      },
    );

    testWidgets(
      'an invalid email shows a validation error and does not sign in',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        await _pumpAccountScreen(tester);

        await tester.enterText(find.byType(TextField), 'not-an-email');
        await tester.tap(find.text(strings.accountSignInButton));
        await tester.pumpAndSettle();

        expect(find.text(strings.emailGateInvalidEmail), findsOneWidget);
        const accountStore = UserAccountStore();
        expect(await accountStore.getEmail(), isNull);
      },
    );

    testWidgets(
      'Sign in uploads local presets to the cloud BEFORE refreshing, so an '
      'empty cloud list does not wipe local saved calculations '
      '(reviewer finding #1)',
      (tester) async {
        final localPreset = UserWeldPreset(
          id: 'local-1',
          name: 'Local Preset',
          updatedAtEpochMs: 1000,
          data: InputPreset.csPlateSingleVGmaw.data!,
        );
        SharedPreferences.setMockInitialValues({
          'user_weld_presets_v1': jsonEncode([localPreset.toJson()]),
        });

        var saveCalled = false;
        // The cloud starts out empty for this email -- a stateful mock so
        // the GET after migrate-upload reflects what was just saved,
        // matching how the real Apps Script backend behaves.
        final cloudPresets = <Map<String, dynamic>>[];

        await http.runWithClient(
          () async {
            await _pumpAccountScreen(tester);

            await tester.enterText(
              find.byType(TextField),
              'existing@example.com',
            );
            await tester.tap(find.text(strings.accountSignInButton));
            await tester.pumpAndSettle();
          },
          () => MockClient((request) async {
            if (request.method == 'GET') {
              return http.Response(
                jsonEncode({'ok': true, 'presets': cloudPresets}),
                200,
              );
            }
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            if (body['action'] == 'save') {
              saveCalled = true;
              cloudPresets.add(body['preset'] as Map<String, dynamic>);
            }
            return http.Response(jsonEncode({'ok': true}), 200);
          }),
        );

        expect(
          saveCalled,
          isTrue,
          reason:
              'local preset must be uploaded to the cloud before the '
              'cloud-authoritative refresh happens',
        );

        const presetStore = UserPresetStore();
        final survivingPresets = (await presetStore.load()).presets;
        expect(
          survivingPresets,
          hasLength(1),
          reason: 'local preset must not be wiped by an empty cloud list',
        );
        expect(survivingPresets.single.id, 'local-1');
      },
    );

    testWidgets(
      'Sign in normalizes a mixed-case email, and Delete Account reuses the '
      'same normalized email for the cloud list/delete calls '
      '(reviewer finding #2)',
      (tester) async {
        SharedPreferences.setMockInitialValues({});

        final cloudPreset = UserWeldPreset(
          id: 'cloud-1',
          name: 'Cloud Preset',
          updatedAtEpochMs: 1000,
          data: InputPreset.csPlateSingleVGmaw.data!,
        );

        final requestedEmails = <String>[];

        await http.runWithClient(
          () async {
            await _pumpAccountScreen(tester);

            await tester.enterText(
              find.byType(TextField),
              'User@Example.com',
            );
            await tester.tap(find.text(strings.accountSignInButton));
            await tester.pumpAndSettle();

            expect(find.text('user@example.com'), findsOneWidget);

            await tester.tap(find.text(strings.accountDeleteAccountButton));
            await tester.pumpAndSettle();
            await tester.tap(find.text(strings.commonDelete));
            await tester.pumpAndSettle();

            await tester.tap(find.text(strings.commonContinue));
            await tester.pumpAndSettle();
          },
          () => MockClient((request) async {
            if (request.method == 'GET') {
              requestedEmails.add(request.url.queryParameters['email']!);
              return http.Response(
                jsonEncode({
                  'ok': true,
                  'presets': [cloudPreset.toJson()],
                }),
                200,
              );
            }
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            requestedEmails.add(body['email'] as String);
            return http.Response(jsonEncode({'ok': true}), 200);
          }),
        );

        expect(requestedEmails, isNotEmpty);
        expect(
          requestedEmails.every((email) => email == 'user@example.com'),
          isTrue,
          reason:
              'every cloud call must use the lowercased email, not the '
              'raw-typed "User@Example.com": $requestedEmails',
        );
      },
    );

    testWidgets(
      'Delete Account: skippedCount > 0 from list() is treated as a '
      'partial failure even when every returned preset deletes fine '
      '(reviewer finding #3)',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'user_account_email_v1': 'user@example.com',
          'user_weld_presets_v1': jsonEncode([]),
        });

        final goodPreset = UserWeldPreset(
          id: 'cloud-good',
          name: 'Cloud Good',
          updatedAtEpochMs: 1000,
          data: InputPreset.csPlateSingleVGmaw.data!,
        );

        await http.runWithClient(
          () async {
            await _pumpAccountScreen(tester);

            await tester.tap(find.text(strings.accountDeleteAccountButton));
            await tester.pumpAndSettle();
            await tester.tap(find.text(strings.commonDelete));
            await tester.pumpAndSettle();

            // One row was unparseable (skippedCount: 1 in list()'s
            // response) even though the one returned preset's delete()
            // call below succeeds -- this must still show the honest
            // partial-failure message, not full success.
            expect(
              find.text(strings.accountDeletePartialFailureBody),
              findsOneWidget,
            );
            expect(
              find.text(strings.accountDeleteSuccessBody),
              findsNothing,
            );

            await tester.tap(find.text(strings.commonContinue));
            await tester.pumpAndSettle();
          },
          () => MockClient((request) async {
            if (request.method == 'GET') {
              return http.Response(
                jsonEncode({
                  'ok': true,
                  'presets': [
                    goodPreset.toJson(),
                    // Unparseable: missing required 'data' field, so
                    // PresetSyncService.list counts it in skippedCount
                    // instead of returning it in `presets`.
                    {'id': 'unparseable-1', 'name': 'Broken'},
                  ],
                }),
                200,
              );
            }
            // Every delete() call succeeds.
            return http.Response(jsonEncode({'ok': true}), 200);
          }),
        );
      },
    );
  });
}

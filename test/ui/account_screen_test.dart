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
  });
}

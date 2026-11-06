import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/auth_service.dart';
import 'package:weld_consumable_calculator/services/user_preset_store.dart';
import 'package:weld_consumable_calculator/ui/calculator_page.dart';

import '../support/fake_auth_service.dart';

/// See _FailingHttpClient in calculator_page_save_update_test.dart --
/// PresetSyncService has no injectable client, so network is stubbed out
/// via HttpOverrides to deterministically simulate the backend's write side
/// being down for both the migration upload and the new preset's own save.
class _FailingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('network disabled in tests');
}

void main() {
  final auth = FakeAuthService();
  setUp(() => AuthServices.instance = auth);
  tearDown(() => AuthServices.instance = const UnavailableAuthService());

  testWidgets(
    'a guest saving a new preset while the migration upload fails keeps '
    'the pre-existing local preset instead of overwriting the local cache '
    'with only the newly-created one (reviewer finding #1, HIGH)',
    (tester) async {
      await HttpOverrides.runZoned(() async {
        final legacyPreset = UserWeldPreset(
          id: 'legacy-1',
          name: 'Legacy Preset',
          updatedAtEpochMs: 1000,
          data: InputPreset.csPlateSingleVGmaw.data!,
        );
        SharedPreferences.setMockInitialValues({
          'user_weld_presets_v1': jsonEncode([legacyPreset.toJson()]),
        });

        await tester.pumpWidget(
          AppLocaleScope(
            locale: AppLocale(),
            child: MaterialApp(
              home: CalculatorPage(presetToLoad: legacyPreset),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Guest (no account yet) landed straight on Summary via
        // presetToLoad -- Save as Preset is the button shown since there's
        // no account yet to make this an in-place update.
        expect(find.text('Save as Preset'), findsOneWidget);
        await tester.ensureVisible(find.text('Save as Preset'));
        await tester.tap(find.text('Save as Preset'));
        await tester.pumpAndSettle();

        // A guest is asked to create an account first; Sign in with Apple
        // yields a verified account without any typing.
        await tester.tap(find.text('Continue with Apple'));
        await tester.pumpAndSettle();
        expect(auth.appleSignIns, 1);

        final dialogTextFields = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        );
        expect(dialogTextFields, findsOneWidget);
        await tester.enterText(dialogTextFields, 'New Preset');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        const store = UserPresetStore();
        final survivingPresets = (await store.load()).presets;
        expect(
          survivingPresets.map((preset) => preset.id),
          containsAll(['legacy-1']),
          reason:
              'the pre-existing local preset must survive a failed '
              'migration upload, not just the newly-created one',
        );
        expect(survivingPresets, hasLength(2));
      }, createHttpClient: (context) => _FailingHttpClient());
    },
  );
}

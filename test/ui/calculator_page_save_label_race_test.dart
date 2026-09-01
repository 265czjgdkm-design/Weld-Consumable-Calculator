import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/ui/calculator_page.dart';

/// See _FailingHttpClient in calculator_page_save_update_test.dart --
/// PresetSyncService has no injectable client, so network is stubbed out
/// via HttpOverrides rather than let a real request reach production
/// infrastructure.
class _FailingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('network disabled in tests');
}

void main() {
  testWidgets(
    "the Save button's label agrees with the branch _saveCurrentAsUserPreset "
    "actually takes, even on the very first frame -- before the async "
    "account-email/preset-list load in _initUserPresets resolves and could "
    'still clear _selectedUserPresetId (see finding #5)',
    (tester) async {
      await HttpOverrides.runZoned(() async {
        final existing = UserWeldPreset(
          id: 'existing-1',
          name: 'My Saved Calc',
          updatedAtEpochMs: 1000,
          data: InputPreset.csPlateSingleVGmaw.data!,
        );
        SharedPreferences.setMockInitialValues({
          'user_account_email_v1': 'test@example.com',
          'user_weld_presets_v1': jsonEncode([existing.toJson()]),
        });

        await tester.pumpWidget(
          AppLocaleScope(
            locale: AppLocale(),
            child: MaterialApp(home: CalculatorPage(presetToLoad: existing)),
          ),
        );

        // Deliberately no further pump here: _selectedUserPresetId is
        // already set synchronously (in initState, via _applyUserPreset),
        // but _accountEmail/_userPresets are both still their initial
        // (null / empty) values because SharedPreferences reads in
        // _initUserPresets haven't resolved yet. The pre-fix label ignored
        // that and would already read "Update Saved Calculation" here even
        // though tapping it would not actually resolve to the update branch.
        expect(find.text('Save as Preset'), findsOneWidget);
        expect(find.text('Update Saved Calculation'), findsNothing);

        // Once the async loads resolve and the preset is confirmed to
        // still exist for this account, the label should catch up.
        await tester.pumpAndSettle();
        expect(find.text('Update Saved Calculation'), findsOneWidget);
        expect(find.text('Save as Preset'), findsNothing);
      }, createHttpClient: (context) => _FailingHttpClient());
    },
  );
}

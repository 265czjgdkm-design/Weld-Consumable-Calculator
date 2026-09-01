import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/user_preset_store.dart';
import 'package:weld_consumable_calculator/ui/calculator_page.dart';

void main() {
  testWidgets('a cloud row this build cannot parse merges with the local cache '
      "instead of replacing it, so a preset the cloud dropped doesn't "
      'destroy a good local copy (see finding #1)', (tester) async {
    final localOnlyPreset = UserWeldPreset(
      id: 'local-only-1',
      name: 'Local Only',
      updatedAtEpochMs: 1000,
      data: InputPreset.csPlateSingleVGmaw.data!,
    );
    SharedPreferences.setMockInitialValues({
      'user_account_email_v1': 'test@example.com',
      'user_weld_presets_v1': jsonEncode([localOnlyPreset.toJson()]),
    });

    // The cloud only returns a single row this build can't parse, so
    // `list()` reports zero usable presets and skippedCount: 1.
    final responseBody = jsonEncode({
      'ok': true,
      'presets': [
        {'name': 'Malformed row with no id or data'},
      ],
    });

    await http.runWithClient(() async {
      await tester.pumpWidget(
        AppLocaleScope(
          locale: AppLocale(),
          child: MaterialApp(home: CalculatorPage()),
        ),
      );
      await tester.pumpAndSettle();
    }, () => MockClient((request) async => http.Response(responseBody, 200)));

    // The local cache fully recovered the one row the cloud couldn't parse,
    // so there's no actual data loss to warn the user about (see finding #1
    // of the third reviewer pass).
    expect(
      find.textContaining("couldn't be loaded and were skipped"),
      findsNothing,
    );

    const store = UserPresetStore();
    final survivingPresets = (await store.load()).presets;
    expect(survivingPresets, hasLength(1));
    expect(survivingPresets.single.id, 'local-only-1');
    expect(survivingPresets.single.name, 'Local Only');
  });

  testWidgets(
    'the skipped-row warning is suppressed once the local-cache merge fully '
    'recovers every row the cloud could not parse (see finding #1 of the '
    'third reviewer pass)',
    (tester) async {
      final goodPreset = UserWeldPreset(
        id: 'good-1',
        name: 'Good',
        updatedAtEpochMs: 2000,
        data: InputPreset.csPlateSingleVGmaw.data!,
      );
      final recoverablePreset = UserWeldPreset(
        id: 'recoverable-1',
        name: 'Recoverable',
        updatedAtEpochMs: 1000,
        data: InputPreset.csPlateSingleVGmaw.data!,
      );
      SharedPreferences.setMockInitialValues({
        'user_account_email_v1': 'test@example.com',
        'user_weld_presets_v1': jsonEncode([
          goodPreset.toJson(),
          recoverablePreset.toJson(),
        ]),
      });

      // The cloud returns the good row plus one row this build can't parse
      // (`skippedCount: 1`) -- the local cache already has both, so the
      // merge should recover the unparseable one in full.
      final responseBody = jsonEncode({
        'ok': true,
        'presets': [
          goodPreset.toJson(),
          {'name': 'Malformed row with no id or data'},
        ],
      });

      await http.runWithClient(() async {
        await tester.pumpWidget(
          AppLocaleScope(
            locale: AppLocale(),
            child: MaterialApp(home: CalculatorPage()),
          ),
        );
        await tester.pumpAndSettle();
      }, () => MockClient((request) async => http.Response(responseBody, 200)));

      expect(
        find.textContaining("couldn't be loaded and were skipped"),
        findsNothing,
      );

      const store = UserPresetStore();
      final survivingPresets = (await store.load()).presets;
      expect(survivingPresets.map((preset) => preset.id).toSet(), {
        'good-1',
        'recoverable-1',
      });
    },
  );
}

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
          child: const MaterialApp(home: CalculatorPage()),
        ),
      );
      await tester.pumpAndSettle();
    }, () => MockClient((request) async => http.Response(responseBody, 200)));

    expect(
      find.textContaining("couldn't be loaded and were skipped"),
      findsOneWidget,
    );

    const store = UserPresetStore();
    final survivingPresets = (await store.load()).presets;
    expect(survivingPresets, hasLength(1));
    expect(survivingPresets.single.id, 'local-only-1');
    expect(survivingPresets.single.name, 'Local Only');
  });
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/ui/calculator_page.dart';

void main() {
  testWidgets(
    'a dropped/unreadable synced preset row surfaces a message to the '
    "user instead of silently shrinking the local cache (see finding #3)",
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'user_account_email_v1': 'test@example.com',
      });

      final validPreset = UserWeldPreset(
        id: 'preset-1',
        name: 'Valid',
        updatedAtEpochMs: 1,
        data: InputPreset.csPlateSingleVGmaw.data!,
      );
      final responseBody = jsonEncode({
        'ok': true,
        'presets': [
          validPreset.toJson(),
          {'name': 'Malformed row with no id or data'},
        ],
      });

      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            AppLocaleScope(
              locale: AppLocale(),
              child: const MaterialApp(home: CalculatorPage()),
            ),
          );
          await tester.pumpAndSettle();
        },
        () => MockClient(
          (request) async => http.Response(responseBody, 200),
        ),
      );

      expect(
        find.textContaining("couldn't be loaded and was skipped"),
        findsOneWidget,
      );
    },
  );
}

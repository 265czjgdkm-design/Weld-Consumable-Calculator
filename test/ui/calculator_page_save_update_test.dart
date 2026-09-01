import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/user_preset_store.dart';
import 'package:weld_consumable_calculator/ui/calculator_page.dart';

/// [PresetSyncService] talks to a live Apps Script endpoint with no
/// injectable client, so this test stubs the network out via [HttpOverrides]
/// rather than let a real POST reach production infrastructure. The save
/// flow already falls back to a local-only save on any sync failure, so
/// this still exercises the exact same in-place-update code path
/// deterministically.
class _FailingHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw const SocketException('network disabled in tests');
}

Future<void> _pumpCalculatorWithPreset(
  WidgetTester tester,
  UserWeldPreset preset,
) async {
  await tester.pumpWidget(
    AppLocaleScope(
      locale: AppLocale(),
      child: MaterialApp(home: CalculatorPage(presetToLoad: preset)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'hitting Save on a loaded calculation updates it in place instead of '
    'creating a duplicate',
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

        await _pumpCalculatorWithPreset(tester, existing);

        expect(find.text('Update Saved Calculation'), findsOneWidget);
        expect(find.text('Save as Preset'), findsNothing);

        // Edit -> Dimensions step, change Quantity, then back to Summary.
        await tester.ensureVisible(find.text('Edit').at(1));
        await tester.tap(find.text('Edit').at(1));
        await tester.pumpAndSettle();

        final quantityField = find.byWidgetPredicate(
          (widget) =>
              widget is TextField && widget.decoration?.labelText == 'Quantity',
        );
        await tester.ensureVisible(quantityField);
        await tester.enterText(quantityField, '5');

        await tester.ensureVisible(find.text('Continue'));
        await tester.tap(find.text('Continue')); // dimensions -> consumable
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Continue'));
        await tester.tap(find.text('Continue')); // consumable -> summary
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Update Saved Calculation'));
        await tester.tap(find.text('Update Saved Calculation'));
        await tester.pumpAndSettle();

        const store = UserPresetStore();
        final saved = (await store.load()).presets;
        expect(saved, hasLength(1));
        expect(saved.single.id, 'existing-1');
        expect(saved.single.name, 'My Saved Calc');
        expect(saved.single.data.quantity, 5);
      }, createHttpClient: (context) => _FailingHttpClient());
    },
  );
}

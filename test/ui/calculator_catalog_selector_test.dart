import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/ui/calculator_page.dart';
import 'package:weld_consumable_calculator/ui/widgets/searchable_picker.dart';

Future<void> _toConsumable(WidgetTester tester) async {
  await tester.pumpWidget(
    AppLocaleScope(
      locale: AppLocale(),
      child: MaterialApp(home: CalculatorPage()),
    ),
  );
  await tester.pumpAndSettle();
  for (final label in ['Get Started', 'Continue', 'Continue']) {
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }
}

Finder _picker(String label) =>
    find.byWidgetPredicate((w) => w is PickerField && w.label == label);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('consumable and base-material selectors scroll, search, and '
      'apply catalog entries at 375pt without overflow', (tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await _toConsumable(tester);

    // Consumable: open, scroll the long list, then search and pick.
    await tester.ensureVisible(_picker('AWS Classification'));
    await tester.tap(_picker('AWS Classification'));
    await tester.pumpAndSettle();
    final list = find.byType(ListView);
    for (var i = 0; i < 5; i++) {
      await tester.drag(list, const Offset(0, -400));
      await tester.pumpAndSettle();
    }
    await tester.enterText(
      find.byKey(const ValueKey('picker-search')),
      'ER316LSi',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'ER316LSi').first);
    await tester.pumpAndSettle();

    final density = tester.widget<TextField>(
      find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Density (g/cm3)',
      ),
    );
    expect(density.controller!.text, '7.98');

    // Base material: pick a catalog entry that is not CET-ready too.
    await tester.ensureVisible(_picker('Base Material'));
    await tester.tap(_picker('Base Material'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('picker-search')),
      'S355J2',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'S355J2').first);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Selected base material: S355J2'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Calculate'));
    await tester.tap(find.text('Calculate'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ER316LSi', findRichText: true), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/ui/calculator_page.dart';

Future<void> _pumpToDimensionsStep(WidgetTester tester) async {
  await tester.pumpWidget(
    AppLocaleScope(
      locale: AppLocale(),
      child: MaterialApp(home: CalculatorPage()),
    ),
  );
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.text('Get Started'));
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.text('Continue'));
  await tester.tap(find.text('Continue')); // process -> dimensions
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Cap Overlap/Cap Height fields appear for the default Single V groove',
    (tester) async {
      await _pumpToDimensionsStep(tester);

      expect(find.text('Cap Overlap (each edge, mm)'), findsOneWidget);
      expect(find.text('Cap Height / Reinforcement (mm)'), findsOneWidget);
    },
  );

  testWidgets(
    'Cap Overlap/Cap Height fields are hidden once Fillet Weld is selected '
    '(fillet is explicitly out of scope for this feature)',
    (tester) async {
      await _pumpToDimensionsStep(tester);

      await tester.ensureVisible(find.text('Fillet Weld'));
      await tester.tap(find.text('Fillet Weld'));
      await tester.pumpAndSettle();

      expect(find.text('Cap Overlap (each edge, mm)'), findsNothing);
      expect(find.text('Cap Height / Reinforcement (mm)'), findsNothing);
    },
  );

  testWidgets(
    'Cap Overlap/Cap Height stay hidden for every other butt-groove type too '
    'once switched back from Fillet',
    (tester) async {
      await _pumpToDimensionsStep(tester);

      await tester.ensureVisible(find.text('Fillet Weld'));
      await tester.tap(find.text('Fillet Weld'));
      await tester.pumpAndSettle();
      expect(find.text('Cap Overlap (each edge, mm)'), findsNothing);

      await tester.ensureVisible(find.text('Plate Butt Weld'));
      await tester.tap(find.text('Plate Butt Weld'));
      await tester.pumpAndSettle();
      expect(find.text('Cap Overlap (each edge, mm)'), findsOneWidget);
      expect(find.text('Cap Height / Reinforcement (mm)'), findsOneWidget);
    },
  );
}

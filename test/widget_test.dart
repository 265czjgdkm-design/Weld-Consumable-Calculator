import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/app.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';

Future<void> _pumpPastSplash(WidgetTester tester) async {
  await tester.pumpWidget(const WeldConsumableCalculatorApp());
  await tester.tap(find.byType(GestureDetector).first);
  await tester.pumpAndSettle();

  // First launch also shows the one-time, skippable email gate.
  final guestButton = find.text('Continue as guest');
  if (guestButton.evaluate().isNotEmpty) {
    await tester.tap(guestButton);
    await tester.pumpAndSettle();
  }
}

Future<void> _pumpPastIntro(WidgetTester tester) async {
  await _pumpPastSplash(tester);
  await tester.ensureVisible(find.text('Get Started'));
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('intro screen leads into the calculator shell', (tester) async {
    await _pumpPastSplash(tester);
    expect(find.text('Varyos Weld'), findsAtLeastNWidgets(1));

    await tester.ensureVisible(find.text('Get Started'));
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Joint Type'), findsOneWidget);
    expect(find.text('Technical Drawing'), findsOneWidget);
    expect(find.text('Visual'), findsAtLeastNWidgets(1));
    expect(find.text('Technical'), findsAtLeastNWidgets(1));
    expect(find.text('Input Preset'), findsOneWidget);
    expect(find.text('My Saved Presets'), findsOneWidget);
    expect(find.text('Consumable Classification'), findsOneWidget);
    expect(find.text('Calculate'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets('input preset applies pipe joint starter values', (tester) async {
    await _pumpPastIntro(tester);

    await tester.ensureVisible(find.text('Input Preset'));
    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<InputPreset>,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('CS Pipe Double V / GTAW + SMAW').last);
    await tester.pumpAndSettle();

    expect(find.text('Pipe OD (mm)'), findsOneWidget);
    expect(find.text('GTAW Transition Depth (mm)'), findsOneWidget);
    expect(find.text('Root Face per Side (mm)'), findsOneWidget);
  });

  testWidgets('manual deposition basis reveals user-defined rate field', (
    tester,
  ) async {
    await _pumpPastIntro(tester);

    await tester.ensureVisible(find.text('Manual'));
    await tester.tap(find.text('Manual'));
    await tester.pumpAndSettle();

    expect(find.text('Deposition Rate (kg/h)'), findsOneWidget);
  });

  testWidgets('unequal geometry reveals A/B member fields', (tester) async {
    await _pumpPastIntro(tester);

    await tester.ensureVisible(find.text('Unequal'));
    await tester.tap(find.text('Unequal'));
    await tester.pumpAndSettle();

    expect(find.text('Thickness A (mm)'), findsOneWidget);
    expect(find.text('Thickness B (mm)'), findsOneWidget);
    expect(find.text('Alignment Reference'), findsOneWidget);
  });

  testWidgets('pdf export is locked behind the premium paywall until unlocked', (
    tester,
  ) async {
    await _pumpPastIntro(tester);

    await tester.ensureVisible(find.text('Calculate'));
    await tester.tap(find.text('Calculate'));
    await tester.pumpAndSettle();

    expect(find.text('Unlock PDF'), findsOneWidget);

    await tester.tap(find.text('Unlock PDF'));
    await tester.pumpAndSettle();

    expect(find.text('Varyos Weld Premium'), findsOneWidget);

    await tester.tap(find.textContaining('Subscribe'));
    await tester.pumpAndSettle();

    expect(find.text('Export PDF'), findsOneWidget);
  });
}

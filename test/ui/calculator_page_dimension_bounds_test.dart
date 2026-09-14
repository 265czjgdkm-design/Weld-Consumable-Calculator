import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/ui/calculator_page.dart';

/// Same wizard-navigation pattern as calculator_page_cap_dimensions_test.dart.
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

Finder _fieldWithLabel(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

Future<void> _enterField(
  WidgetTester tester,
  String label,
  String value,
) async {
  final field = _fieldWithLabel(label);
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> _tapCalculate(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Continue')); // dimensions -> consumable
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Continue')); // consumable -> summary
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.text('Calculate'));
  await tester.tap(find.text('Calculate'));
  // Not pumpAndSettle: a SnackBar has a multi-second auto-dismiss timer that
  // pumpAndSettle would wait out entirely, leaving nothing left to find.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 750));
}

String _outOfRangeMessage(L10nStrings strings, String label, String max) =>
    strings.calcFieldOutOfRangeError
        .replaceFirst('{label}', label)
        .replaceFirst('{max}', max);

void main() {
  final strings = stringsFor(AppLanguage.en);

  testWidgets(
    'a Thickness far beyond any real wall/plate section (5000 mm) is '
    'rejected instead of silently accepted',
    (tester) async {
      await _pumpToDimensionsStep(tester);
      await _enterField(tester, 'Thickness (mm)', '5000');
      await _tapCalculate(tester);

      expect(
        find.text(_outOfRangeMessage(strings, 'Thickness (mm)', '500 mm')),
        findsOneWidget,
      );
      expect(find.text(strings.calcResultsTitle), findsNothing);
    },
  );

  testWidgets(
    'a large-but-plausible heavy-section Thickness (400 mm) is accepted',
    (tester) async {
      await _pumpToDimensionsStep(tester);
      await _enterField(tester, 'Thickness (mm)', '400');
      await _tapCalculate(tester);

      expect(find.text(strings.calcResultsTitle), findsWidgets);
    },
  );

  testWidgets(
    'a Root Gap far beyond any real fit-up (500 mm) is rejected instead of '
    'silently accepted',
    (tester) async {
      await _pumpToDimensionsStep(tester);
      await _enterField(tester, 'Root Gap (mm)', '500');
      await _tapCalculate(tester);

      expect(
        find.text(_outOfRangeMessage(strings, 'Root Gap (mm)', '50 mm')),
        findsOneWidget,
      );
      expect(find.text(strings.calcResultsTitle), findsNothing);
    },
  );

  testWidgets(
    'a large-but-plausible wide-fit-up Root Gap (45 mm) is accepted',
    (tester) async {
      await _pumpToDimensionsStep(tester);
      await _enterField(tester, 'Root Gap (mm)', '45');
      await _tapCalculate(tester);

      expect(find.text(strings.calcResultsTitle), findsWidgets);
    },
  );

  testWidgets(
    'a Root Face far beyond any real land dimension (150 mm on a 300 mm '
    'section) is rejected by the new absolute ceiling, not just the '
    'existing relative-to-thickness check',
    (tester) async {
      await _pumpToDimensionsStep(tester);
      await _enterField(tester, 'Thickness (mm)', '300');
      await _enterField(tester, 'Root Face (mm)', '150');
      await _tapCalculate(tester);

      expect(
        find.text(_outOfRangeMessage(strings, 'Root Face (mm)', '100 mm')),
        findsOneWidget,
      );
      expect(find.text(strings.calcResultsTitle), findsNothing);
    },
  );

  testWidgets(
    'a large-but-plausible thick-section Root Face (80 mm on a 300 mm '
    'section) is accepted',
    (tester) async {
      await _pumpToDimensionsStep(tester);
      await _enterField(tester, 'Thickness (mm)', '300');
      await _enterField(tester, 'Root Face (mm)', '80');
      await _tapCalculate(tester);

      expect(find.text(strings.calcResultsTitle), findsWidgets);
    },
  );

  testWidgets(
    'a Bevel Angle beyond a physical angle (200 deg) is rejected by the '
    'new 0-180 deg ceiling',
    (tester) async {
      await _pumpToDimensionsStep(tester);
      await _enterField(tester, 'Bevel Angle (deg)', '200');
      await _tapCalculate(tester);

      expect(
        find.text(_outOfRangeMessage(strings, 'Bevel Angle (deg)', '180°')),
        findsOneWidget,
      );
      expect(find.text(strings.calcResultsTitle), findsNothing);
    },
  );

  testWidgets(
    'a large-but-plausible near-square-groove Bevel Angle (85 deg) is '
    'accepted',
    (tester) async {
      await _pumpToDimensionsStep(tester);
      await _enterField(tester, 'Bevel Angle (deg)', '85');
      await _tapCalculate(tester);

      expect(find.text(strings.calcResultsTitle), findsWidgets);
    },
  );

  testWidgets(
    'a fillet Leg Size far beyond any real structural fillet (250 mm) is '
    'rejected instead of silently accepted',
    (tester) async {
      await _pumpToDimensionsStep(tester);
      await tester.ensureVisible(find.text('Fillet Weld'));
      await tester.tap(find.text('Fillet Weld'));
      await tester.pumpAndSettle();

      await _enterField(tester, 'Leg Size (mm)', '250');
      await _tapCalculate(tester);

      expect(
        find.text(_outOfRangeMessage(strings, 'Leg Size (mm)', '200 mm')),
        findsOneWidget,
      );
      expect(find.text(strings.calcResultsTitle), findsNothing);
    },
  );

  testWidgets(
    'a large-but-plausible heavy-structural fillet Leg Size (150 mm) is '
    'accepted',
    (tester) async {
      await _pumpToDimensionsStep(tester);
      await tester.ensureVisible(find.text('Fillet Weld'));
      await tester.tap(find.text('Fillet Weld'));
      await tester.pumpAndSettle();

      await _enterField(tester, 'Leg Size (mm)', '150');
      await _tapCalculate(tester);

      expect(find.text(strings.calcResultsTitle), findsWidgets);
    },
  );
}

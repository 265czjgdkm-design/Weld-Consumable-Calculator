import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/ui/calculator_page.dart';

/// Desktop width (>=1120px) so the calculator renders `_buildWidePage`'s
/// always-visible starter-template dropdown instead of the mobile wizard's
/// step-gated one. Tall enough that the dropdown menu route builds every
/// item rather than only as many as fit a shorter constrained surface.
void _setDesktopViewport(WidgetTester tester) {
  final originalPhysicalSize = tester.view.physicalSize;
  final originalDevicePixelRatio = tester.view.devicePixelRatio;
  tester.view.physicalSize = const Size(1400, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.physicalSize = originalPhysicalSize;
    tester.view.devicePixelRatio = originalDevicePixelRatio;
  });
}

Future<void> _openStarterTemplateDropdown(WidgetTester tester) async {
  final dropdown = find.byWidgetPredicate(
    (widget) => widget is DropdownButtonFormField<InputPreset>,
  );
  await tester.ensureVisible(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(dropdown);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    "the mobile wizard's Step 2 starter-template dropdown only offers "
    "templates matching Step 1's already-selected welding process (plus "
    'Custom), so it can never conflict with that earlier choice',
    (tester) async {
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

      // GTAW is already the default process, but select it explicitly so
      // this test doesn't silently pass if that default ever changes.
      await tester.tap(find.text('GTAW').first);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue')); // process -> dimensions
      await tester.pumpAndSettle();

      await _openStarterTemplateDropdown(tester);

      expect(find.text('Custom'), findsWidgets);
      expect(find.text('SS Pipe Single V / GTAW'), findsOneWidget);
      expect(find.text('CS Plate Single V / GMAW'), findsNothing);
      expect(find.text('CS Plate Double V / SMAW'), findsNothing);
      expect(find.text('CS Fillet / FCAW'), findsNothing);
      // A "process CONTAINS gtaw" filter (instead of "process EQUALS
      // gtaw") would incorrectly let these combined-process templates
      // through too, since they're partly GTAW.
      expect(find.text('CS Pipe Single V / GTAW + SMAW'), findsNothing);
      expect(find.text('CS Pipe Double V / GTAW + SMAW'), findsNothing);
      // Exact count: only Custom + the one pure-GTAW template should be
      // offered, nothing else.
      expect(
        find.byWidgetPredicate((widget) => widget is DropdownMenuItem<InputPreset>),
        findsNWidgets(2),
      );
    },
  );

  testWidgets(
    "the desktop wide layout's equivalent starter-template dropdown still "
    'offers every template unfiltered (regression guard: the process '
    'filter above must not leak into the desktop layout, which has no '
    "separate Step 1 process picker of its own)",
    (tester) async {
      _setDesktopViewport(tester);

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

      await _openStarterTemplateDropdown(tester);

      expect(find.text('Custom'), findsWidgets);
      expect(find.text('SS Pipe Single V / GTAW'), findsOneWidget);
      expect(find.text('CS Plate Single V / GMAW'), findsOneWidget);
      expect(find.text('CS Plate Double V / SMAW'), findsOneWidget);
      expect(find.text('CS Fillet / FCAW'), findsOneWidget);
    },
  );
}

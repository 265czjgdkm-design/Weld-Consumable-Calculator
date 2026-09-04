import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
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

/// Desktop width (>=1120px) so the calculator renders `_buildWidePage`,
/// the only layout with a visible Reset button -- the mobile wizard has no
/// equivalent (its Summary step only has Calculate/Save).
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

Finder _fieldWithLabel(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

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
    'Cap Overlap/Cap Height reappear for every other butt-groove type '
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

  testWidgets(
    'Reset clears Cap Overlap/Cap Height, not just leaving stale values '
    'behind (reviewer repro: Cap Overlap 5 / Cap Height 4, tap Reset)',
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

      final capOverlapField = _fieldWithLabel('Cap Overlap (each edge, mm)');
      final capHeightField = _fieldWithLabel(
        'Cap Height / Reinforcement (mm)',
      );
      await tester.ensureVisible(capOverlapField);
      await tester.enterText(capOverlapField, '5');
      await tester.ensureVisible(capHeightField);
      await tester.enterText(capHeightField, '4');
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(capOverlapField).controller?.text,
        '5',
      );
      expect(tester.widget<TextField>(capHeightField).controller?.text, '4');

      await tester.ensureVisible(find.text('Reset'));
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Root Gap reverting to its default confirms Reset actually ran.
      expect(
        tester.widget<TextField>(_fieldWithLabel('Root Gap (mm)')).controller?.text,
        '3',
      );
      expect(
        tester.widget<TextField>(capOverlapField).controller?.text,
        '',
      );
      expect(tester.widget<TextField>(capHeightField).controller?.text, '');
    },
  );

  testWidgets(
    'applying a starter template with null cap values clears stale Cap '
    'Overlap/Cap Height instead of leaving them behind (reviewer repro: '
    'Cap Overlap 5 / Cap Height 4, then apply "SS Pipe Single V / GTAW")',
    (tester) async {
      await _pumpToDimensionsStep(tester);

      final capOverlapField = _fieldWithLabel('Cap Overlap (each edge, mm)');
      final capHeightField = _fieldWithLabel(
        'Cap Height / Reinforcement (mm)',
      );
      await tester.ensureVisible(capOverlapField);
      await tester.enterText(capOverlapField, '5');
      await tester.ensureVisible(capHeightField);
      await tester.enterText(capHeightField, '4');
      await tester.pumpAndSettle();

      final dropdown = find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<InputPreset>,
      );
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('SS Pipe Single V / GTAW').last);
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(capOverlapField).controller?.text,
        '',
      );
      expect(tester.widget<TextField>(capHeightField).controller?.text, '');
    },
  );
}

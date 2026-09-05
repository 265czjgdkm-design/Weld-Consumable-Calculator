import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/l10n/app_language.dart';
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

/// Turkish equivalent of [_pumpToDimensionsStep] - used only to confirm the
/// Double V cap-doubling helper text (Finding 3) actually renders in a
/// second locale too, not just English.
Future<void> _pumpToDimensionsStepTr(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final locale = AppLocale();
  await locale.setLanguage(AppLanguage.tr);
  await tester.pumpWidget(
    AppLocaleScope(locale: locale, child: MaterialApp(home: CalculatorPage())),
  );
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.text('Başla'));
  await tester.tap(find.text('Başla'));
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.text('Devam Et'));
  await tester.tap(find.text('Devam Et')); // process -> dimensions
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Cap Overlap/Cap Height fields appear for the default Single V groove',
    (tester) async {
      await _pumpToDimensionsStep(tester);

      expect(find.text('Cap Overlap (mm)'), findsOneWidget);
      expect(find.text('Cap Height (mm)'), findsOneWidget);
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

      expect(find.text('Cap Overlap (mm)'), findsNothing);
      expect(find.text('Cap Height (mm)'), findsNothing);
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
      expect(find.text('Cap Overlap (mm)'), findsNothing);

      await tester.ensureVisible(find.text('Plate Butt Weld'));
      await tester.tap(find.text('Plate Butt Weld'));
      await tester.pumpAndSettle();
      expect(find.text('Cap Overlap (mm)'), findsOneWidget);
      expect(find.text('Cap Height (mm)'), findsOneWidget);
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

      final capOverlapField = _fieldWithLabel('Cap Overlap (mm)');
      final capHeightField = _fieldWithLabel(
        'Cap Height (mm)',
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
    'Cap Overlap/Cap Height helper text discloses the both-faces doubling '
    'for Double V, but not for other groove types (reviewer Finding 3)',
    (tester) async {
      await _pumpToDimensionsStep(tester);

      // Default groove is Single V - plain helper text, no doubling note.
      expect(
        tester
            .widget<TextField>(_fieldWithLabel('Cap Overlap (mm)'))
            .decoration
            ?.helperText,
        isNot(contains('counted twice')),
      );

      final grooveDropdown = find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<GrooveType>,
      );
      await tester.ensureVisible(grooveDropdown);
      await tester.tap(grooveDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Double V').last);
      await tester.pumpAndSettle();

      final capOverlapHelper = tester
          .widget<TextField>(_fieldWithLabel('Cap Overlap (mm)'))
          .decoration
          ?.helperText;
      final capHeightHelper = tester
          .widget<TextField>(
            _fieldWithLabel('Cap Height (mm)'),
          )
          .decoration
          ?.helperText;
      expect(capOverlapHelper, contains('applied to both faces'));
      expect(capOverlapHelper, contains('counted twice'));
      expect(capHeightHelper, contains('applied to both faces'));
      expect(capHeightHelper, contains('counted twice'));
    },
  );

  testWidgets(
    'Cap Overlap/Cap Height helper text discloses the both-faces doubling '
    'for Double V in Turkish too, not just English (reviewer Finding 3)',
    (tester) async {
      await _pumpToDimensionsStepTr(tester);

      final grooveDropdown = find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<GrooveType>,
      );
      await tester.ensureVisible(grooveDropdown);
      await tester.tap(grooveDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Çift V').last);
      await tester.pumpAndSettle();

      final capOverlapHelper = tester
          .widget<TextField>(
            _fieldWithLabel('Bindirme (mm)'),
          )
          .decoration
          ?.helperText;
      final capHeightHelper = tester
          .widget<TextField>(
            _fieldWithLabel('Yükseklik (mm)'),
          )
          .decoration
          ?.helperText;
      expect(capOverlapHelper, contains('her iki yüzeye de uygulanır'));
      expect(capOverlapHelper, contains('iki kez sayılır'));
      expect(capHeightHelper, contains('her iki yüzeye de uygulanır'));
      expect(capHeightHelper, contains('iki kez sayılır'));
    },
  );

  testWidgets(
    'applying a starter template with null cap values clears stale Cap '
    'Overlap/Cap Height instead of leaving them behind (reviewer repro: '
    'Cap Overlap 5 / Cap Height 4, then apply "SS Pipe Single V / GTAW")',
    (tester) async {
      await _pumpToDimensionsStep(tester);

      final capOverlapField = _fieldWithLabel('Cap Overlap (mm)');
      final capHeightField = _fieldWithLabel(
        'Cap Height (mm)',
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

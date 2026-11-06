import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/ui/calculator_page.dart';
import 'package:weld_consumable_calculator/ui/calculator_page/calculator_page_models.dart';
import 'package:weld_consumable_calculator/ui/cooling_time_calculator_screen.dart';
import 'package:weld_consumable_calculator/ui/widgets/weld_drawing_preview.dart';

final _strings = stringsFor(AppLanguage.en);

Widget _app(Widget home) => AppLocaleScope(
  locale: AppLocale(),
  child: MaterialApp(home: home),
);

Finder _fieldWithLabel(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 667);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _toDimensions(WidgetTester tester) async {
  await tester.pumpWidget(_app(CalculatorPage()));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Get Started'));
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Continue'));
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('filler calculator: Calculate with an empty required field '
      'returns to its step, scrolls it into view, focuses it, shows the '
      'message and a snackbar', (tester) async {
    _phone(tester);
    await _toDimensions(tester);

    final thickness = _fieldWithLabel('Thickness (mm)');
    await tester.ensureVisible(thickness);
    await tester.enterText(thickness, '');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue')); // -> consumable
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue')); // -> summary
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Calculate'));
    await tester.tap(find.text('Calculate'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(thickness, findsOneWidget, reason: 'wizard went back to the step');
    final field = tester.widget<TextField>(thickness);
    expect(field.focusNode!.hasFocus, isTrue);
    expect(field.decoration!.errorText, _strings.fieldRequiredShort);
    final top = tester.getTopLeft(thickness).dy;
    expect(top, inInclusiveRange(0, 667));
    expect(
      find.text(
        _strings.calcMissingFieldsSnack
            .replaceFirst('{count}', '1')
            .replaceFirst('{fields}', 'Thickness (mm)'),
      ),
      findsOneWidget,
    );
    expect(find.text(_strings.calcResultsTitle), findsNothing);
  });

  testWidgets('t8/5 calculator: missing fields are scrolled to, focused, '
      'marked and announced', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app(const CoolingTimeCalculatorScreen()));
    await tester.pumpAndSettle();

    final button = find.widgetWithText(
      FilledButton,
      _strings.coolingCalculateButton,
    );
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();

    final t0 = _fieldWithLabel(_strings.coolingT0Label);
    expect(tester.widget<TextField>(t0).focusNode!.hasFocus, isTrue);
    expect(tester.getTopLeft(t0).dy, inInclusiveRange(0, 667));
    expect(find.text(_strings.fieldRequiredShort), findsWidgets);
    expect(
      find.textContaining(
        _strings.calcMissingFieldsSnack
            .replaceFirst('{count}', '3')
            .replaceFirst('{fields}', ''),
      ),
      findsOneWidget,
    );
  });

  testWidgets('t8/5 calculator: empty heat input in arc-parameter mode flags '
      'the voltage field', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app(const CoolingTimeCalculatorScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(_fieldWithLabel(_strings.coolingT0Label), '100');
    await tester.enterText(
      _fieldWithLabel(_strings.coolingThicknessLabel),
      '10',
    );
    final arc = find.text(_strings.heatInputArcParamsModeLabel);
    await tester.ensureVisible(arc);
    await tester.tap(arc);
    await tester.pumpAndSettle();

    final button = find.widgetWithText(
      FilledButton,
      _strings.coolingCalculateButton,
    );
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();

    final voltage = _fieldWithLabel(_strings.heatInputVoltageLabel);
    expect(tester.widget<TextField>(voltage).focusNode!.hasFocus, isTrue);
    expect(find.text(_strings.fieldRequiredShort), findsNWidgets(3));
  });

  testWidgets('editing a value from the drawing returns to the drawing: '
      'same scroll position, updated value applied', (tester) async {
    _phone(tester);
    await _toDimensions(tester);

    final scrollable = find.byType(Scrollable).first;
    final before = tester.state<ScrollableState>(scrollable).position.pixels;
    final drawing = tester.widget<WeldDrawingPreview>(
      find.byType(WeldDrawingPreview),
    );
    drawing.onFieldTap!(FieldKey.thicknessMm);
    await tester.pumpAndSettle();

    final sheetField = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(TextField),
    );
    expect(sheetField, findsOneWidget);
    await tester.enterText(sheetField, '15');
    await tester.pump();
    await tester.tap(find.text(_strings.commonDone));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(WeldDrawingPreview), findsOneWidget);
    final rect = tester.getRect(find.byType(WeldDrawingPreview));
    expect(rect.bottom, greaterThan(0));
    expect(rect.top, lessThan(667));
    expect(tester.state<ScrollableState>(scrollable).position.pixels, before);
    final updated = tester.widget<TextField>(_fieldWithLabel('Thickness (mm)'));
    expect(updated.controller!.text, '15');
  });
}

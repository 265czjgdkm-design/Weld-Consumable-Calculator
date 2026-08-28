import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/core/en1011_formulas.dart';
import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/models/custom_material_models.dart';
import 'package:weld_consumable_calculator/services/custom_base_material_store.dart';
import 'package:weld_consumable_calculator/ui/preheat_calculator_screen.dart';

final _strings = stringsFor(AppLanguage.en);

Future<void> _pumpScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    AppLocaleScope(
      locale: AppLocale(),
      child: const MaterialApp(home: PreheatCalculatorScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _fieldByLabel(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

Future<void> _enterByLabel(
  WidgetTester tester,
  String label,
  String value,
) async {
  final finder = _fieldByLabel(label);
  await tester.ensureVisible(finder);
  await tester.enterText(finder, value);
  await tester.pump();
}

Future<void> _enterMinimalValidJoint(WidgetTester tester) async {
  await _enterByLabel(tester, _strings.preheatThicknessLabel, '10');
  await _enterByLabel(tester, _strings.preheatHdLabel, '1');
  await _enterByLabel(tester, _strings.heatInputQLabel, '0.5');
}

Future<void> _tapCalculate(WidgetTester tester) async {
  final button = find.widgetWithText(
    FilledButton,
    _strings.preheatCalculateButton,
  );
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

const _libraryMaterial = CustomBaseMaterial(
  id: 'base-1',
  name: 'S355J2',
  designation: 'EN 10025-2',
  notes: '',
  updatedAtEpochMs: 1000,
  carbonPercent: 0.18,
  siliconPercent: 0.55,
  manganesePercent: 1.20,
  cetPercent: 0.35,
  pcmPercent: 0.30,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'a below-ambient Tp shows the No preheat required label with the '
    'actual computed value, not a placeholder',
    (tester) async {
      await _pumpScreen(tester);
      await _enterMinimalValidJoint(tester);
      await _tapCalculate(tester);

      final expectedCet = computeCet(c: 0, mn: 0, mo: 0, cr: 0, cu: 0, ni: 0);
      final expectedTp = computePreheatTempC(
        cet: expectedCet,
        thicknessMm: 10,
        hd: 1,
        heatInputKJPerMm: 0.5,
      );
      expect(expectedTp, lessThanOrEqualTo(20));

      expect(find.text(_strings.preheatNoPreheatRequiredLabel), findsOneWidget);
      expect(
        find.text(
          _strings.preheatComputedValueBelowAmbientNote.replaceFirst(
            '{value}',
            expectedTp.toStringAsFixed(1),
          ),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'out-of-range thickness and diffusible-hydrogen warnings interpolate '
    'the actual entered values, not the literal {value} placeholder',
    (tester) async {
      await _pumpScreen(tester);
      await _enterByLabel(tester, _strings.materialFieldCarbon, '0.2');
      await _enterByLabel(tester, _strings.preheatThicknessLabel, '5');
      await _enterByLabel(tester, _strings.preheatHdLabel, '25');
      await _enterByLabel(tester, _strings.heatInputQLabel, '1.0');
      await _tapCalculate(tester);

      expect(
        find.text(
          _strings.preheatWarningThicknessOutOfRange.replaceFirst(
            '{value}',
            '5.0',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          _strings.preheatWarningHdOutOfRange.replaceFirst('{value}', '25.0'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('{value}'), findsNothing);
    },
  );

  testWidgets(
    'editing composition after loading a library material invalidates the '
    'stored Pcm override so the displayed value matches fresh composition',
    (tester) async {
      await const CustomBaseMaterialStore().save([_libraryMaterial]);
      await _pumpScreen(tester);

      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is DropdownButtonFormField<CustomBaseMaterial>,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('S355J2').last);
      await tester.pumpAndSettle();

      // Edit carbon after load -- this must invalidate the stored Pcm
      // override (0.30) so the result reflects the freshly-entered
      // composition instead of the stale stored value.
      await _enterByLabel(tester, _strings.materialFieldCarbon, '0.45');
      await _enterMinimalValidJoint(tester);
      await _tapCalculate(tester);

      final expectedCet = computeCet(
        c: 0.45,
        mn: 1.20,
        mo: 0,
        cr: 0,
        cu: 0,
        ni: 0,
      );
      final expectedPcm = computePcmItoBessyo(
        c: 0.45,
        si: 0.55,
        mn: 1.20,
        cu: 0,
        cr: 0,
        ni: 0,
        mo: 0,
        v: 0,
        b: 0,
      );
      expect(expectedCet, isNot(closeTo(0.35, 1e-9)));
      expect(expectedPcm, isNot(closeTo(0.30, 1e-9)));

      expect(
        find.text(
          'CET (parent): ${expectedCet.toStringAsFixed(3)}',
          findRichText: true,
        ),
        findsOneWidget,
        reason: 'CET must always be computed live, never a stale stored value',
      );
      expect(
        find.textContaining('Pcm (stored override)'),
        findsNothing,
        reason:
            'the Pcm override must be invalidated by the composition edit',
      );
      expect(
        find.text('Pcm (Ito-Bessyo) = ${expectedPcm.toStringAsFixed(3)}%'),
        findsOneWidget,
      );
    },
  );
}

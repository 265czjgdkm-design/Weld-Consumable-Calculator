import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/app.dart';
import 'package:weld_consumable_calculator/models/consumable_selection.dart';
import 'package:weld_consumable_calculator/models/custom_material_models.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';

const _customMaterial = CustomFillerMaterial(
  id: 'filler-custom-1',
  name: 'Acme XR-70',
  family: ConsumableFamily.carbonSteel,
  densityGPerCm3: 7.9,
  notes: 'House-brand equivalent to ER70S-6.',
  updatedAtEpochMs: 5000,
);

Future<void> _pumpToConsumableStep(WidgetTester tester) async {
  await tester.pumpWidget(const WeldConsumableCalculatorApp());
  await tester.tap(find.byType(GestureDetector).first);
  await tester.pumpAndSettle();

  final guestButton = find.text('Continue as guest');
  if (guestButton.evaluate().isNotEmpty) {
    await tester.tap(guestButton);
    await tester.pumpAndSettle();
  }

  final fillerConsumptionButton = find.text('Filler Material Consumption');
  if (fillerConsumptionButton.evaluate().isNotEmpty) {
    await tester.tap(fillerConsumptionButton);
    await tester.pumpAndSettle();
  }

  await tester.ensureVisible(find.text('Get Started'));
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();

  await tester.ensureVisible(find.text('Continue'));
  await tester.tap(find.text('Continue')); // process -> dimensions
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Continue'));
  await tester.tap(find.text('Continue')); // dimensions -> consumable
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'custom_filler_materials_v1': jsonEncode([_customMaterial.toJson()]),
    });
  });

  testWidgets(
    'a custom filler material appears under "My Materials" and can be '
    'selected, autofilling density from the library entry',
    (tester) async {
      // A tall viewport, not because the app's layout needs it, but so the
      // dropdown menu route (bounded by available height) actually builds
      // enough items to reach the custom-material entry appended after the
      // builtins -- Flutter's dropdown menu only builds as many items as
      // fit the constrained test surface height otherwise.
      final originalPhysicalSize = tester.view.physicalSize;
      final originalDevicePixelRatio = tester.view.devicePixelRatio;
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.physicalSize = originalPhysicalSize;
        tester.view.devicePixelRatio = originalDevicePixelRatio;
      });

      await _pumpToConsumableStep(tester);

      expect(find.text('AWS Classification'), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is DropdownButtonFormField<ConsumableSelection>,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Materials'), findsOneWidget);
      expect(find.text('Acme XR-70 (Carbon Steel)'), findsWidgets);

      await tester.tap(find.text('Acme XR-70 (Carbon Steel)').last);
      await tester.pumpAndSettle();

      final densityField = tester.widget<TextField>(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.labelText == 'Density (g/cm3)',
        ),
      );
      expect(densityField.controller!.text, '7.90');

      expect(
        find.textContaining('Typical base metals: House-brand equivalent'),
        findsOneWidget,
      );

      // Run a calculation with the custom material selected and confirm the
      // results/engineering-basis panels render without crashing even
      // though this material has no AWS specification on file.
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue')); // consumable -> summary
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Calculate'));
      await tester.tap(find.text('Calculate'));
      await tester.pumpAndSettle();

      // The engineering-basis chips are built with RichText (label + value
      // spans), not plain Text, so this needs findRichText to see them.
      expect(
        find.textContaining('Acme XR-70', findRichText: true),
        findsWidgets,
      );
    },
  );
}

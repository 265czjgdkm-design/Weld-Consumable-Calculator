import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/app.dart';
import 'package:weld_consumable_calculator/models/base_material_selection.dart';
import 'package:weld_consumable_calculator/models/custom_material_models.dart';

const _customMaterial = CustomBaseMaterial(
  id: 'base-custom-1',
  name: 'Acme S355',
  designation: 'S355J2',
  notes: 'Structural steel plate stock.',
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
      'custom_base_materials_v1': jsonEncode([_customMaterial.toJson()]),
    });
  });

  testWidgets(
    'a custom base material appears under "My Materials", defaults to '
    '"Not specified", and can be selected',
    (tester) async {
      // Tall viewport for the same reason as the filler-material test: the
      // dropdown menu route only builds as many items as fit the
      // constrained test surface height.
      final originalPhysicalSize = tester.view.physicalSize;
      final originalDevicePixelRatio = tester.view.devicePixelRatio;
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.physicalSize = originalPhysicalSize;
        tester.view.devicePixelRatio = originalDevicePixelRatio;
      });

      await _pumpToConsumableStep(tester);

      expect(find.text('Base Material'), findsWidgets);
      expect(find.text('Not specified'), findsOneWidget);

      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is DropdownButtonFormField<BaseMaterialSelection?>,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Materials'), findsOneWidget);
      expect(find.text('Acme S355'), findsWidgets);

      await tester.tap(find.text('Acme S355').last);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Selected base material: Acme S355 (S355J2)'),
        findsOneWidget,
      );

      // Run a calculation with the base material selected and confirm the
      // results/engineering-basis panels render without crashing.
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue')); // consumable -> summary
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Calculate'));
      await tester.tap(find.text('Calculate'));
      await tester.pumpAndSettle();

      // The engineering-basis chips are built with RichText (label + value
      // spans), not plain Text, so this needs findRichText to see them.
      expect(
        find.textContaining('Acme S355', findRichText: true),
        findsWidgets,
      );
    },
  );

  testWidgets(
    'not selecting a base material omits it from the engineering basis '
    'entirely (optional field, no clutter when unused)',
    (tester) async {
      await _pumpToConsumableStep(tester);

      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue')); // consumable -> summary
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Calculate'));
      await tester.tap(find.text('Calculate'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Base Material', findRichText: true),
        findsNothing,
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/app.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/ui/calculator_page/wizard/process_icons.dart';

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

/// Lands on the wizard's first step (Welding Process).
Future<void> _pumpPastIntro(WidgetTester tester) async {
  await _pumpPastSplash(tester);
  await tester.ensureVisible(find.text('Get Started'));
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();
}

Future<void> _continueWizardStep(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Continue'));
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}

/// From the wizard's process step, advances all the way to the summary
/// step (Process -> Dimensions -> Consumable -> Summary).
Future<void> _pumpToWizardSummary(WidgetTester tester) async {
  await _pumpPastIntro(tester);
  await _continueWizardStep(tester); // process -> dimensions
  await _continueWizardStep(tester); // dimensions -> consumable
  await _continueWizardStep(tester); // consumable -> summary
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('wizard walks through every step to the summary', (
    tester,
  ) async {
    await _pumpPastIntro(tester);

    // Step 1: Welding Process.
    expect(find.text('Welding Process'), findsOneWidget);
    for (final process in WeldingProcess.values) {
      expect(find.text(process.label), findsOneWidget);
    }
    expect(find.text('Input Preset'), findsOneWidget);
    expect(find.text('My Saved Presets'), findsOneWidget);
    expect(find.text('Step 1 of 4'), findsOneWidget);

    await _continueWizardStep(tester);

    // Step 2: Dimensions.
    expect(find.text('Step 2 of 4'), findsOneWidget);
    expect(find.text('Technical Drawing'), findsOneWidget);
    expect(find.text('Visual'), findsAtLeastNWidgets(1));
    expect(find.text('Technical'), findsAtLeastNWidgets(1));
    expect(find.text('Joint Type'), findsOneWidget);

    await _continueWizardStep(tester);

    // Step 3: Consumable.
    expect(find.text('Step 3 of 4'), findsOneWidget);
    expect(find.text('Consumable Classification'), findsOneWidget);

    await _continueWizardStep(tester);

    // Step 4: Summary.
    expect(find.text('Step 4 of 4'), findsOneWidget);
    expect(find.text('Calculate'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets('input preset applies pipe joint starter values', (
    tester,
  ) async {
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

    await _continueWizardStep(tester); // process -> dimensions

    expect(find.text('Pipe OD (mm)'), findsOneWidget);
    expect(find.text('Root Face per Side (mm)'), findsOneWidget);

    await _continueWizardStep(tester); // dimensions -> consumable

    expect(find.text('GTAW Transition Depth (mm)'), findsOneWidget);
  });

  testWidgets('manual deposition basis reveals user-defined rate field', (
    tester,
  ) async {
    await _pumpPastIntro(tester);
    await _continueWizardStep(tester); // process -> dimensions
    await _continueWizardStep(tester); // dimensions -> consumable

    await tester.ensureVisible(find.text('Manual'));
    await tester.tap(find.text('Manual'));
    await tester.pumpAndSettle();

    expect(find.text('Deposition Rate (kg/h)'), findsOneWidget);
  });

  testWidgets('unequal geometry reveals A/B member fields', (tester) async {
    await _pumpPastIntro(tester);
    await _continueWizardStep(tester); // process -> dimensions

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
    await _pumpToWizardSummary(tester);

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

  testWidgets(
    'back navigation from dimensions returns to process step with selection kept',
    (tester) async {
      await _pumpPastIntro(tester);

      await tester.ensureVisible(find.text('GMAW'));
      await tester.tap(find.text('GMAW'));
      await tester.pumpAndSettle();

      await _continueWizardStep(tester); // process -> dimensions
      expect(find.text('Step 2 of 4'), findsOneWidget);

      await tester.ensureVisible(find.text('Back'));
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      expect(find.text('Step 1 of 4'), findsOneWidget);
      expect(find.text('Welding Process'), findsOneWidget);

      final gmawIcon = tester.widget<ProcessIcon>(
        find.byWidgetPredicate(
          (widget) =>
              widget is ProcessIcon && widget.process == WeldingProcess.gmaw,
        ),
      );
      expect(gmawIcon.color, Colors.white);
    },
  );

  testWidgets(
    'continuing to the next wizard step resets scroll to the top',
    (tester) async {
      await _pumpPastIntro(tester);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();

      final scrolledView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrolledView.controller!.position.pixels, greaterThan(0));

      await _continueWizardStep(tester); // process -> dimensions

      final resetView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(resetView.controller!.position.pixels, lessThan(5.0));
    },
  );

  testWidgets(
    'going back a wizard step resets scroll to the top',
    (tester) async {
      await _pumpPastIntro(tester);
      await _continueWizardStep(tester); // process -> dimensions

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();

      final scrolledView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrolledView.controller!.position.pixels, greaterThan(0));

      await tester.ensureVisible(find.text('Back'));
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      final resetView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(resetView.controller!.position.pixels, lessThan(5.0));
    },
  );

  testWidgets(
    'tapping Edit from the summary step resets scroll to the top',
    (tester) async {
      await _pumpToWizardSummary(tester);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();

      final scrolledView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrolledView.controller!.position.pixels, greaterThan(0));

      await tester.ensureVisible(find.text('Edit').first);
      await tester.tap(find.text('Edit').first);
      await tester.pumpAndSettle();

      final resetView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(resetView.controller!.position.pixels, lessThan(5.0));
    },
  );

  testWidgets(
    'desktop width still shows Joint Type and Technical Drawing together',
    (tester) async {
      final originalPhysicalSize = tester.view.physicalSize;
      final originalDevicePixelRatio = tester.view.devicePixelRatio;
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.physicalSize = originalPhysicalSize;
        tester.view.devicePixelRatio = originalDevicePixelRatio;
      });

      await _pumpPastIntro(tester);

      expect(find.text('Joint Type'), findsOneWidget);
      expect(find.text('Technical Drawing'), findsOneWidget);
    },
  );
}

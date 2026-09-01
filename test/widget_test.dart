import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/app.dart';
import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/services/entitlement_service.dart';
import 'package:weld_consumable_calculator/services/purchases_config.dart';
import 'package:weld_consumable_calculator/ui/calculator_page.dart';
import 'package:weld_consumable_calculator/ui/calculator_page/wizard/process_icons.dart';

/// Fake [EntitlementService] so paywall tests never touch the real
/// RevenueCat SDK -- see lib/services/entitlement_service.dart.
class _FakeEntitlementService extends EntitlementService {
  _FakeEntitlementService({this.offering, this.purchaseResult});

  final Offering? offering;
  final CustomerInfo? purchaseResult;

  @override
  Future<bool> isPremiumActive() async => false;

  @override
  Stream<bool> premiumStatusStream() => const Stream<bool>.empty();

  @override
  Future<Offering?> currentOffering() async => offering;

  @override
  Future<CustomerInfo> purchasePackage(Package package) async {
    final result = purchaseResult;
    if (result == null) {
      throw StateError('Unexpected purchase in test');
    }
    return result;
  }

  @override
  Future<CustomerInfo> restorePurchases() async {
    throw StateError('Unexpected restore in test');
  }
}

Package _fakePackage(String identifier) {
  return Package(
    identifier,
    PackageType.custom,
    StoreProduct(identifier, 'description', 'title', 2.99, '\$2.99', 'USD'),
    const PresentedOfferingContext(PurchasesConfig.offeringId, null, null),
  );
}

Offering _fakeOffering() {
  return Offering(PurchasesConfig.offeringId, 'description', const {}, [
    _fakePackage(PurchasesConfig.monthlyPackageId),
    _fakePackage(PurchasesConfig.yearlyPackageId),
  ]);
}

CustomerInfo _activeCustomerInfo() {
  final entitlement = EntitlementInfo(
    PurchasesConfig.entitlementId,
    true,
    true,
    '2026-01-01T00:00:00Z',
    '2026-01-01T00:00:00Z',
    PurchasesConfig.monthlyPackageId,
    false,
  );
  return CustomerInfo(
    EntitlementInfos({
      PurchasesConfig.entitlementId: entitlement,
    }, {PurchasesConfig.entitlementId: entitlement}),
    const {},
    [PurchasesConfig.monthlyPackageId],
    [PurchasesConfig.monthlyPackageId],
    const [],
    '2026-01-01T00:00:00Z',
    'test-app-user-id',
    const {},
    '2026-01-01T00:00:00Z',
  );
}

/// Builds [CalculatorPage] directly with a fake [EntitlementService] and
/// walks it through to the wizard's summary step, bypassing the splash/
/// registration/dashboard flow those don't need to be exercised for.
Future<void> _pumpCalculatorToSummary(
  WidgetTester tester,
  EntitlementService entitlementService,
) async {
  await tester.pumpWidget(
    AppLocaleScope(
      locale: AppLocale(),
      child: MaterialApp(
        home: CalculatorPage(entitlementService: entitlementService),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Get Started'));
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();
  await _continueWizardStep(tester); // process -> dimensions
  await _continueWizardStep(tester); // dimensions -> consumable
  await _continueWizardStep(tester); // consumable -> summary
}

Future<void> _pumpPastSplash(WidgetTester tester) async {
  await tester.pumpWidget(const WeldConsumableCalculatorApp());
  await tester.tap(find.byType(GestureDetector).first);
  await tester.pumpAndSettle();

  // First launch also shows the one-time, skippable registration choice.
  final guestButton = find.text('Continue as guest');
  if (guestButton.evaluate().isNotEmpty) {
    await tester.tap(guestButton);
    await tester.pumpAndSettle();
  }

  // Lands on the home dashboard now; enter the calculator through its
  // first button, same as a user tapping "Filler Material Consumption".
  final fillerConsumptionButton = find.text('Filler Material Consumption');
  if (fillerConsumptionButton.evaluate().isNotEmpty) {
    await tester.tap(fillerConsumptionButton);
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

Future<void> _pumpCalculatorWithPreset(
  WidgetTester tester,
  UserWeldPreset preset,
) async {
  await tester.pumpWidget(
    AppLocaleScope(
      locale: AppLocale(),
      child: MaterialApp(home: CalculatorPage(presetToLoad: preset)),
    ),
  );
  await tester.pumpAndSettle();
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
    expect(find.text('Step 1 of 4'), findsOneWidget);
    expect(find.text('Input Preset'), findsNothing);

    await _continueWizardStep(tester);

    // Step 2: Dimensions.
    expect(find.text('Step 2 of 4'), findsOneWidget);
    expect(find.text('Technical Drawing'), findsOneWidget);
    expect(find.text('Visual'), findsAtLeastNWidgets(1));
    expect(find.text('Technical'), findsAtLeastNWidgets(1));
    expect(find.text('Joint Type'), findsOneWidget);
    expect(find.text('Input Preset'), findsOneWidget);

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
    await _continueWizardStep(tester); // process -> dimensions

    await tester.ensureVisible(find.text('Input Preset'));
    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is DropdownButtonFormField<InputPreset>,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('CS Pipe Double V / GTAW + SMAW').last);
    await tester.pumpAndSettle();

    // Default process is GTAW; this preset uses GTAW + SMAW, so switching
    // processes needs confirming first.
    expect(find.text('Switch Welding Process?'), findsOneWidget);
    await tester.tap(find.text('Switch to GTAW + SMAW'));
    await tester.pumpAndSettle();

    expect(find.text('Pipe OD (mm)'), findsOneWidget);
    expect(find.text('Root Face per Side (mm)'), findsOneWidget);

    await _continueWizardStep(tester); // dimensions -> consumable

    expect(find.text('GTAW Transition Depth (mm)'), findsOneWidget);
  });

  testWidgets(
    'starter preset with a different process asks for confirmation before switching',
    (tester) async {
      await _pumpPastIntro(tester);

      await tester.ensureVisible(find.text('GMAW'));
      await tester.tap(find.text('GMAW'));
      await tester.pumpAndSettle();

      await _continueWizardStep(tester); // process -> dimensions

      await tester.ensureVisible(find.text('Input Preset'));
      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is DropdownButtonFormField<InputPreset>,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('SS Pipe Single V / GTAW').last);
      await tester.pumpAndSettle();

      expect(find.text('Switch Welding Process?'), findsOneWidget);

      // Cancel: keep GMAW, don't apply the preset at all.
      await tester.tap(find.text('Keep GMAW'));
      await tester.pumpAndSettle();

      expect(find.text('Switch Welding Process?'), findsNothing);
      expect(
        find.text('Manual setup with no preset assumptions applied.'),
        findsOneWidget,
      );

      await tester.ensureVisible(find.text('Back'));
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

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
    'starter preset with the same process applies directly without confirmation',
    (tester) async {
      await _pumpPastIntro(tester);
      await _continueWizardStep(tester); // process -> dimensions (default GTAW)

      await tester.ensureVisible(find.text('Input Preset'));
      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is DropdownButtonFormField<InputPreset>,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('SS Pipe Single V / GTAW').last);
      await tester.pumpAndSettle();

      expect(find.text('Switch Welding Process?'), findsNothing);
      expect(find.text('Pipe OD (mm)'), findsOneWidget);
    },
  );

  testWidgets('loading a saved preset lands on the summary step directly', (
    tester,
  ) async {
    final preset = UserWeldPreset(
      id: 'test-preset',
      name: 'Test Preset',
      updatedAtEpochMs: 0,
      data: InputPreset.csPlateSingleVGmaw.data!,
    );

    await _pumpCalculatorWithPreset(tester, preset);

    expect(find.text('Step 4 of 4'), findsOneWidget);
    expect(find.text('Calculate'), findsOneWidget);
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

  testWidgets(
    'pdf export shows a coming-soon paywall when no real offering is configured',
    (tester) async {
      await _pumpCalculatorToSummary(
        tester,
        _FakeEntitlementService(offering: null),
      );

      await tester.ensureVisible(find.text('Calculate'));
      await tester.tap(find.text('Calculate'));
      await tester.pumpAndSettle();

      expect(find.text('Unlock PDF'), findsOneWidget);

      await tester.tap(find.text('Unlock PDF'));
      await tester.pumpAndSettle();

      expect(find.text('Varyos Weld Premium'), findsOneWidget);
      expect(
        find.text('Client-ready PDF export for every estimate'),
        findsOneWidget,
      );
      expect(find.text('Restore Purchases'), findsOneWidget);

      final comingSoonButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Premium -- Coming Soon'),
      );
      expect(comingSoonButton.onPressed, isNull);

      // Dismiss the sheet via its barrier and confirm PDF export is still
      // locked -- nothing in the coming-soon state can unlock it.
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(find.text('Unlock PDF'), findsOneWidget);
    },
  );

  testWidgets(
    'pdf export unlocks after purchasing a package from a real offering',
    (tester) async {
      await _pumpCalculatorToSummary(
        tester,
        _FakeEntitlementService(
          offering: _fakeOffering(),
          purchaseResult: _activeCustomerInfo(),
        ),
      );

      await tester.ensureVisible(find.text('Calculate'));
      await tester.tap(find.text('Calculate'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unlock PDF'));
      await tester.pumpAndSettle();

      expect(find.text('Monthly -- \$2.99/mo'), findsOneWidget);
      expect(find.text('Yearly -- \$19.99/yr (save ~44%)'), findsOneWidget);

      await tester.tap(find.text('Monthly -- \$2.99/mo'));
      await tester.pumpAndSettle();

      expect(find.text('Export PDF'), findsOneWidget);
    },
  );

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

      await _continueWizardStep(tester); // dimensions -> consumable

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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/services/entitlement_service.dart';
import 'package:weld_consumable_calculator/services/purchases_config.dart';
import 'package:weld_consumable_calculator/ui/ai_assistant_screen.dart';
import 'package:weld_consumable_calculator/ui/paywall_shared.dart';

class _MockUrlLauncherPlatform extends UrlLauncherPlatform {
  String? lastLaunchedUrl;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    lastLaunchedUrl = url;
    return true;
  }
}

class _FakeEntitlementService extends EntitlementService {
  _FakeEntitlementService(this.offering);

  final Offering? offering;

  @override
  Future<bool> isPremiumActive() async => false;

  @override
  Stream<bool> premiumStatusStream() => const Stream<bool>.empty();

  @override
  Future<Offering?> currentOffering() async => offering;
}

Package _package(String id, double price, String priceString) => Package(
  id,
  PackageType.custom,
  StoreProduct(id, 'description', 'title', price, priceString, 'EUR'),
  const PresentedOfferingContext(PurchasesConfig.offeringId, null, null),
);

Offering _offering() => Offering(PurchasesConfig.offeringId, 'd', const {}, [
  _package(PurchasesConfig.monthlyPackageId, 3.49, '3,49 €'),
  _package(PurchasesConfig.yearlyPackageId, 24.99, '24,99 €'),
]);

Future<void> _pumpAiPaywall(
  WidgetTester tester,
  Offering? offering, {
  AppLanguage language = AppLanguage.en,
}) async {
  SharedPreferences.setMockInitialValues({});
  final locale = AppLocale();
  await locale.setLanguage(language);
  await tester.pumpWidget(
    AppLocaleScope(
      locale: locale,
      child: MaterialApp(
        home: AiAssistantScreen(
          entitlementService: _FakeEntitlementService(offering),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  final gateButton = find.text(
    stringsFor(language).aiAssistantPremiumGateButton,
  );
  await tester.ensureVisible(gateButton);
  await tester.tap(gateButton);
  await tester.pumpAndSettle();
}

void main() {
  final strings = stringsFor(AppLanguage.en);

  test('yearlySavingPercent compares against twelve monthly payments', () {
    final monthly = _package('m', 3.49, '3,49 €');
    final yearly = _package('y', 24.99, '24,99 €');
    expect(yearlySavingPercent(monthly, yearly), 40);
    expect(yearlySavingPercent(monthly, _package('y2', 50, '50 €')), isNull);
  });

  testWidgets('AI paywall renders the store priceString as the most '
      'prominent text, with a localized period, auto-renew disclosure and '
      'Privacy/Terms links', (tester) async {
    final mockPlatform = _MockUrlLauncherPlatform();
    UrlLauncherPlatform.instance = mockPlatform;
    await _pumpAiPaywall(tester, _offering());

    expect(find.text('3,49 €'), findsOneWidget);
    expect(find.text('24,99 €'), findsOneWidget);
    expect(find.text(strings.paywallPeriodMonth), findsOneWidget);
    expect(find.text(strings.paywallPeriodYear), findsOneWidget);
    expect(
      find.text(strings.paywallSaveBadge.replaceFirst('{percent}', '40')),
      findsOneWidget,
    );

    // The billed amount is the largest text on each purchase button.
    double size(String text) =>
        tester.widget<Text>(find.text(text)).style!.fontSize!;
    expect(size('3,49 €'), greaterThan(size(strings.paywallPeriodMonth)));
    expect(size('3,49 €'), greaterThan(size(strings.paywallPlanMonthly)));
    expect(size('24,99 €'), greaterThan(size(strings.paywallPeriodYear)));
    expect(size('24,99 €'), greaterThan(size(strings.paywallPlanYearly)));

    // No hardcoded USD prices from the old copy.
    expect(find.textContaining('2.99'), findsNothing);
    expect(find.textContaining('19.99'), findsNothing);

    expect(find.text(strings.paywallAutoRenewDisclosure), findsOneWidget);
    await tester.ensureVisible(find.text(strings.legalPrivacyPolicyLinkLabel));
    await tester.tap(find.text(strings.legalPrivacyPolicyLinkLabel));
    await tester.pumpAndSettle();
    expect(mockPlatform.lastLaunchedUrl, 'https://varyosweld.com/privacy.html');
    await tester.ensureVisible(find.text(strings.legalTermsOfUseLinkLabel));
    await tester.tap(find.text(strings.legalTermsOfUseLinkLabel));
    await tester.pumpAndSettle();
    expect(mockPlatform.lastLaunchedUrl, 'https://varyosweld.com/terms.html');
  });

  testWidgets('AI paywall falls back to coming-soon copy, with no price, '
      'when no offering is available', (tester) async {
    await _pumpAiPaywall(tester, null);

    expect(find.text(strings.paywallComingSoon), findsOneWidget);
    expect(find.text(strings.paywallComingSoonNote), findsOneWidget);
    expect(find.text(strings.paywallAutoRenewDisclosure), findsNothing);
    expect(find.text(strings.legalPrivacyPolicyLinkLabel), findsOneWidget);
    expect(find.text(strings.legalTermsOfUseLinkLabel), findsOneWidget);
  });

  testWidgets('AI paywall copy is localized', (tester) async {
    await _pumpAiPaywall(tester, _offering(), language: AppLanguage.tr);
    final tr = stringsFor(AppLanguage.tr);

    expect(find.text(tr.paywallPeriodMonth), findsOneWidget);
    expect(find.text(tr.paywallAutoRenewDisclosure), findsOneWidget);
    expect(find.text(strings.paywallPeriodMonth), findsNothing);
  });
}

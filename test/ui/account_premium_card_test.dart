import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/l10n/premium_account_copy.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/services/auth_service.dart';
import 'package:weld_consumable_calculator/services/entitlement_service.dart';
import 'package:weld_consumable_calculator/services/purchases_config.dart';
import 'package:weld_consumable_calculator/ui/account_screen.dart';
import 'package:weld_consumable_calculator/ui/user_guide_screen.dart';

import '../support/fake_auth_service.dart';

class _FakeEntitlementService extends EntitlementService {
  _FakeEntitlementService(this.status);

  PremiumStatus status;
  final syncCalls = <String?>[];

  @override
  Future<PremiumStatus> premiumStatus() async => status;

  @override
  Future<void> syncAccount(String? appUserId) async =>
      syncCalls.add(appUserId);
}

CustomerInfo _customerInfo({
  required bool active,
  required String productId,
  String? expiration,
  bool willRenew = true,
}) {
  final entitlement = EntitlementInfo(
    PurchasesConfig.entitlementId,
    active,
    willRenew,
    '2026-01-01T00:00:00Z',
    '2026-01-01T00:00:00Z',
    productId,
    false,
    expirationDate: expiration,
  );
  return CustomerInfo(
    EntitlementInfos({
      PurchasesConfig.entitlementId: entitlement,
    }, active ? {PurchasesConfig.entitlementId: entitlement} : const {}),
    const {},
    [productId],
    [productId],
    const [],
    '2026-01-01T00:00:00Z',
    'u',
    const {},
    '2026-01-01T00:00:00Z',
  );
}

Future<void> _pump(WidgetTester tester, EntitlementService service) async {
  final locale = AppLocale();
  await locale.setLanguage(AppLanguage.en);
  await tester.pumpWidget(
    AppLocaleScope(
      locale: locale,
      child: MaterialApp(home: AccountScreen(entitlementService: service)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final strings = stringsFor(AppLanguage.en);
  final copy = premiumAccountCopyFor(AppLanguage.en);

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Premium status card', () {
    testWidgets('guest without Premium', (tester) async {
      await _pump(tester, _FakeEntitlementService(const PremiumStatus()));

      expect(find.byKey(const Key('premium-status-card')), findsOneWidget);
      expect(find.text(copy.statusNone), findsOneWidget);
      expect(find.textContaining('${copy.planLabel}:'), findsNothing);
      expect(find.text(copy.appleIdNote), findsOneWidget);
      expect(find.text(strings.paywallRestore), findsOneWidget);
      expect(
        find.text(strings.accountManageSubscriptionsButton),
        findsOneWidget,
      );
      expect(find.text(strings.premiumSettingsRow), findsOneWidget);
    });

    testWidgets('active monthly shows plan and renewal date', (tester) async {
      final service = _FakeEntitlementService(
        PremiumStatus(
          state: PremiumState.active,
          plan: PremiumPlan.monthly,
          expirationDate: DateTime.utc(2027, 3, 15, 12),
          willRenew: true,
        ),
      );
      await _pump(tester, service);

      expect(find.text(copy.statusActive), findsOneWidget);
      expect(
        find.text('${copy.planLabel}: ${copy.planMonthly}'),
        findsOneWidget,
      );
      expect(find.text('Renews on 15/03/2027'), findsOneWidget);
      expect(find.text(copy.linkHint), findsOneWidget);
      expect(find.text(strings.premiumSettingsRow), findsNothing);
    });

    testWidgets('expired shows the expiry date', (tester) async {
      final service = _FakeEntitlementService(
        PremiumStatus(
          state: PremiumState.expired,
          plan: PremiumPlan.yearly,
          expirationDate: DateTime.utc(2026, 5, 2, 12),
        ),
      );
      await _pump(tester, service);

      expect(find.text(copy.statusExpired), findsOneWidget);
      expect(find.text('Expired on 02/05/2026'), findsOneWidget);
      expect(find.text(strings.premiumSettingsRow), findsOneWidget);
    });

    test('fromCustomerInfo maps plan, state, renewal and expiry', () {
      final monthly = PremiumStatus.fromCustomerInfo(
        _customerInfo(
          active: true,
          productId: PurchasesConfig.monthlyPackageId,
          expiration: '2027-03-15T12:00:00Z',
        ),
      );
      expect(monthly.state, PremiumState.active);
      expect(monthly.plan, PremiumPlan.monthly);
      expect(monthly.willRenew, isTrue);
      expect(monthly.expirationDate, DateTime.utc(2027, 3, 15, 12));

      final expiredYearly = PremiumStatus.fromCustomerInfo(
        _customerInfo(
          active: false,
          productId: PurchasesConfig.yearlyPackageId,
          expiration: '2026-05-02T12:00:00Z',
          willRenew: false,
        ),
      );
      expect(expiredYearly.state, PremiumState.expired);
      expect(expiredYearly.plan, PremiumPlan.yearly);
    });
  });

  group('RevenueCat account link', () {
    testWidgets('signed-in user does not see the link hint', (tester) async {
      SharedPreferences.setMockInitialValues({});
      AuthServices.instance = FakeAuthService(user: fakeUser());
      addTearDown(() => AuthServices.instance = const UnavailableAuthService());
      final service = _FakeEntitlementService(
        const PremiumStatus(state: PremiumState.active),
      );
      await _pump(tester, service);

      expect(find.text(copy.linkHint), findsNothing);
    });

    testWidgets('sign out logs RevenueCat out', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final auth = FakeAuthService(user: fakeUser());
      AuthServices.instance = auth;
      addTearDown(() => AuthServices.instance = const UnavailableAuthService());
      final service = _FakeEntitlementService(const PremiumStatus());
      await _pump(tester, service);

      await tester.tap(find.text(strings.accountSignOutButton));
      await tester.pumpAndSettle();
      expect(service.syncCalls, [null]);
    });
  });

  testWidgets('account screen Guide row opens the user guide', (tester) async {
    await _pump(tester, _FakeEntitlementService(const PremiumStatus()));

    await tester.scrollUntilVisible(
      find.text(copy.guideRow),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text(copy.guideRow));
    await tester.pumpAndSettle();

    expect(find.byType(UserGuideScreen), findsOneWidget);
  });
}

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'purchases_config.dart';

enum PremiumState { none, active, expired }

enum PremiumPlan { monthly, yearly, unknown }

/// Read-only snapshot of the `premium` entitlement for the account screen.
class PremiumStatus {
  const PremiumStatus({
    this.state = PremiumState.none,
    this.plan = PremiumPlan.unknown,
    this.expirationDate,
    this.willRenew = false,
  });

  final PremiumState state;
  final PremiumPlan plan;

  /// Null for a non-expiring entitlement (or the tester unlock).
  final DateTime? expirationDate;
  final bool willRenew;

  bool get isActive => state == PremiumState.active;

  factory PremiumStatus.fromCustomerInfo(CustomerInfo info) {
    final entitlement = info.entitlements.all[PurchasesConfig.entitlementId];
    if (entitlement == null) return const PremiumStatus();
    final product = entitlement.productIdentifier.toLowerCase();
    return PremiumStatus(
      state: entitlement.isActive ? PremiumState.active : PremiumState.expired,
      plan: product.contains('year') || product.contains('annual')
          ? PremiumPlan.yearly
          : product.contains('month')
          ? PremiumPlan.monthly
          : PremiumPlan.unknown,
      expirationDate: DateTime.tryParse(entitlement.expirationDate ?? ''),
      willRenew: entitlement.willRenew,
    );
  }
}

/// Wraps the RevenueCat `Purchases` static facade so the rest of the app
/// (and tests, via a fake) never talk to the SDK directly. Gates PDF export
/// via [PurchasesConfig.entitlementId]. See lib/ui/calculator_page.dart.
class EntitlementService {
  EntitlementService();

  /// TestFlight-only unlock: set by `--dart-define=TESTER_PREMIUM=true` on a
  /// build meant for internal testers. Never pass it to an App Store build.
  static const bool testerPremium = bool.fromEnvironment('TESTER_PREMIUM');

  /// [PurchasesConfig.appleApiKey] is a placeholder until the real
  /// RevenueCat API key exists, so this must not let a configure failure
  /// crash app startup.
  Future<void> configure() async {
    try {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }
      await Purchases.configure(
        PurchasesConfiguration(PurchasesConfig.appleApiKey),
      );
    } catch (error) {
      debugPrint('RevenueCat configure failed (placeholder API key?): $error');
    }
  }

  /// Stable, non-PII RevenueCat app user id for a signed-in account: the
  /// SHA-256 of the trimmed, lowercased email (never the email itself).
  static String appUserIdFor(String email) =>
      sha256.convert(utf8.encode(email.trim().toLowerCase())).toString();

  Future<PremiumStatus> premiumStatus() async {
    if (testerPremium) {
      return const PremiumStatus(state: PremiumState.active);
    }
    return PremiumStatus.fromCustomerInfo(await Purchases.getCustomerInfo());
  }

  /// Aligns the RevenueCat app user id with the app account: logIn with
  /// [appUserIdFor] when [email] is set, logOut when it is null. Never
  /// throws -- a failure only means purchases stay on the current id.
  Future<void> syncAccount(String? email) async {
    try {
      if (email == null) {
        if (await Purchases.isAnonymous) return;
        await Purchases.logOut();
        return;
      }
      final userId = appUserIdFor(email);
      if (await Purchases.appUserID == userId) return;
      final wasAnonymous = await Purchases.isAnonymous;
      final before = wasAnonymous
          ? PremiumStatus.fromCustomerInfo(await Purchases.getCustomerInfo())
          : const PremiumStatus();
      final result = await Purchases.logIn(userId);
      // A brand-new id inherits the anonymous purchase automatically; an id
      // that already exists on the server does not, so pull it across with
      // a restore (RevenueCat's transfer behavior moves it to this id).
      if (before.isActive &&
          !PremiumStatus.fromCustomerInfo(result.customerInfo).isActive) {
        await Purchases.restorePurchases();
      }
    } catch (error) {
      debugPrint('RevenueCat account sync failed: $error');
    }
  }

  Future<bool> isPremiumActive() async {
    if (testerPremium) return true;
    final customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.entitlements.active.containsKey(
      PurchasesConfig.entitlementId,
    );
  }

  /// Wraps the SDK's callback-based `addCustomerInfoUpdateListener` (there is
  /// no `Purchases.customerInfoStream` in this SDK version) as a broadcast
  /// stream of the same active-entitlement check [isPremiumActive] performs.
  Stream<bool> premiumStatusStream() {
    late final StreamController<bool> controller;
    void listener(CustomerInfo customerInfo) {
      controller.add(
        testerPremium ||
            customerInfo.entitlements.active.containsKey(
              PurchasesConfig.entitlementId,
            ),
      );
    }

    controller = StreamController<bool>.broadcast(
      onListen: () => Purchases.addCustomerInfoUpdateListener(listener),
      onCancel: () => Purchases.removeCustomerInfoUpdateListener(listener),
    );
    return controller.stream;
  }

  /// Returns null when the `default` offering isn't configured yet in
  /// RevenueCat -- the expected state until the real API key and App Store
  /// Connect products exist.
  Future<Offering?> currentOffering() async {
    final offerings = await Purchases.getOfferings();
    return offerings.current;
  }

  Future<CustomerInfo> purchasePackage(Package package) async {
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return result.customerInfo;
  }

  Future<CustomerInfo> restorePurchases() {
    return Purchases.restorePurchases();
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'purchases_config.dart';

/// Wraps the RevenueCat `Purchases` static facade so the rest of the app
/// (and tests, via a fake) never talk to the SDK directly. Gates PDF export
/// via [PurchasesConfig.entitlementId]. See lib/ui/calculator_page.dart.
class EntitlementService {
  EntitlementService();

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

  Future<bool> isPremiumActive() async {
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

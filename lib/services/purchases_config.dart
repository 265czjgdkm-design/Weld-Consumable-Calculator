/// Configuration for the RevenueCat-backed premium entitlement (gates PDF
/// export, see lib/services/entitlement_service.dart).
class PurchasesConfig {
  const PurchasesConfig._();

  /// RevenueCat public API key for this app, from the RevenueCat dashboard
  /// (Project Settings -> API Keys -> Apple App Store key). This is a
  /// placeholder until the Apple Developer Program account and an App Store
  /// Connect subscription product exist -- swap it for the real key here
  /// once both are set up.
  static const String appleApiKey = 'appl_REPLACE_ME';

  static const String entitlementId = 'premium';

  static const String monthlyPackageId = 'varyos_premium_monthly';
  static const String yearlyPackageId = 'varyos_premium_yearly';

  static const String offeringId = 'default';
}

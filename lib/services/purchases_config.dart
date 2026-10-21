/// Configuration for the RevenueCat-backed premium entitlement (gates PDF
/// export, see lib/services/entitlement_service.dart).
class PurchasesConfig {
  const PurchasesConfig._();

  /// RevenueCat public (client-side) SDK key for the App Store app, from the
  /// RevenueCat dashboard (project 8afb31f2 -> API keys). Public keys are
  /// designed to ship inside the app binary; this is not a secret.
  static const String appleApiKey = 'appl_dnWrEEzgbHjJgzdekHctpNmrrQi';

  static const String entitlementId = 'premium';

  static const String monthlyPackageId = 'varyos_premium_monthly';
  static const String yearlyPackageId = 'varyos_premium_yearly';

  static const String offeringId = 'default';
}

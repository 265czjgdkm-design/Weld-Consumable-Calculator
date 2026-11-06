import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../l10n/app_locale_scope.dart';
import '../l10n/premium_account_copy.dart';
import '../l10n/strings.dart';
import '../services/entitlement_service.dart';
import '../services/purchases_config.dart';
import '../services/user_account_store.dart';
import 'account_screen.dart';
import 'paywall_shared.dart';
import 'widgets/welding_loader.dart';

/// The single Premium paywall used by every entry point (home card, account
/// screen, AI assistant gate, "Unlock PDF"). [onMessage] receives purchase /
/// restore result text; when omitted a SnackBar on the caller's messenger is
/// used.
Future<void> showPremiumPaywall(
  BuildContext context, {
  required EntitlementService entitlementService,
  required ValueChanged<bool> onEntitlementChanged,
  ValueChanged<String>? onMessage,
  bool offerAccountLink = true,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final navigator = Navigator.of(context);
  final copy = premiumAccountCopyFor(AppLocaleScope.of(context).language);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (sheetContext) => PremiumPaywallSheet(
      entitlementService: entitlementService,
      onEntitlementChanged: onEntitlementChanged,
      onMessage:
          onMessage ??
          (message) =>
              messenger?.showSnackBar(SnackBar(content: Text(message))),
      onPurchased: !offerAccountLink
          ? null
          : () async {
              // A guest who just bought is offered (never forced) to tie Premium
              // to an email; queued behind the "unlocked" snackbar.
              if (await const UserAccountStore().getEmail() != null) return;
              messenger?.showSnackBar(
                SnackBar(
                  content: Text(copy.linkPromptText),
                  duration: const Duration(seconds: 12),
                  showCloseIcon: true,
                  action: SnackBarAction(
                    label: copy.linkPromptAction,
                    onPressed: () => navigator.push(
                      MaterialPageRoute(
                        builder: (_) => AccountScreen(
                          entitlementService: entitlementService,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
    ),
  );
}

class PremiumPaywallSheet extends StatefulWidget {
  const PremiumPaywallSheet({
    super.key,
    required this.entitlementService,
    required this.onEntitlementChanged,
    required this.onMessage,
    this.onPurchased,
  });

  final EntitlementService entitlementService;
  final ValueChanged<bool> onEntitlementChanged;
  final ValueChanged<String> onMessage;
  final VoidCallback? onPurchased;

  @override
  State<PremiumPaywallSheet> createState() => _PremiumPaywallSheetState();
}

class _PremiumPaywallSheetState extends State<PremiumPaywallSheet> {
  Offering? _offering;
  bool _loadingOffering = true;
  String? _purchasingPackageId;
  bool _restoring = false;

  @override
  void initState() {
    super.initState();
    _loadOffering();
  }

  Future<void> _loadOffering() async {
    if (!_loadingOffering) setState(() => _loadingOffering = true);
    Offering? offering;
    try {
      offering = await widget.entitlementService.currentOffering();
    } catch (error) {
      debugPrint('Failed to load RevenueCat offering: $error');
    }
    if (offering != null &&
        _resolveMonthly(offering) == null &&
        _resolveYearly(offering) == null) {
      debugPrint(
        'RevenueCat offering "${offering.identifier}" has no monthly or '
        'annual package (checked package duration and the '
        'PurchasesConfig custom ids) -- paywall has nothing purchasable.',
      );
    }
    if (!mounted) return;
    setState(() {
      _offering = offering;
      _loadingOffering = false;
    });
  }

  // `.monthly`/`.annual` resolve by the package's actual duration, so they
  // match whether the RevenueCat dashboard used its own predefined
  // $rc_monthly/$rc_annual ids or the custom PurchasesConfig ids.
  Package? _resolveMonthly(Offering offering) =>
      offering.monthly ?? offering.getPackage(PurchasesConfig.monthlyPackageId);
  Package? _resolveYearly(Offering offering) =>
      offering.annual ?? offering.getPackage(PurchasesConfig.yearlyPackageId);

  Package? get _monthlyPackage {
    final offering = _offering;
    return offering == null ? null : _resolveMonthly(offering);
  }

  Package? get _yearlyPackage {
    final offering = _offering;
    return offering == null ? null : _resolveYearly(offering);
  }

  bool get _hasAnyPackage => _monthlyPackage != null || _yearlyPackage != null;

  bool _isEntitlementActive(CustomerInfo customerInfo) => customerInfo
      .entitlements
      .active
      .containsKey(PurchasesConfig.entitlementId);

  // The sheet's route may already be popping (barrier dismiss) by the time an
  // in-flight purchase/restore resolves -- popping unconditionally would pop
  // the route underneath the sheet instead.
  void _dismissSheetIfCurrent(NavigatorState navigator, ModalRoute? route) {
    if (route?.isCurrent ?? false) navigator.pop();
  }

  Future<void> _purchase(Package package) async {
    final strings = AppLocaleScope.stringsOf(context);
    setState(() => _purchasingPackageId = package.identifier);
    final navigator = Navigator.of(context);
    final sheetRoute = ModalRoute.of(context);
    try {
      final customerInfo = await widget.entitlementService.purchasePackage(
        package,
      );
      final isActive = _isEntitlementActive(customerInfo);
      widget.onEntitlementChanged(isActive);
      if (mounted) _dismissSheetIfCurrent(navigator, sheetRoute);
      widget.onMessage(
        isActive
            ? strings.paywallPremiumUnlocked
            : strings.paywallPurchaseCompleted,
      );
      if (isActive) widget.onPurchased?.call();
      return;
    } on PlatformException catch (error) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        // User backed out of the store sheet -- not an error worth surfacing.
      } else {
        if (mounted) _dismissSheetIfCurrent(navigator, sheetRoute);
        widget.onMessage(
          code == PurchasesErrorCode.paymentPendingError
              ? strings.paywallPurchasePending
              : strings.paywallPurchaseFailed,
        );
      }
    } catch (error) {
      if (mounted) _dismissSheetIfCurrent(navigator, sheetRoute);
      widget.onMessage(strings.paywallPurchaseFailed);
    }
    if (mounted) setState(() => _purchasingPackageId = null);
  }

  Future<void> _restore() async {
    final strings = AppLocaleScope.stringsOf(context);
    setState(() => _restoring = true);
    final navigator = Navigator.of(context);
    final sheetRoute = ModalRoute.of(context);
    try {
      final customerInfo = await widget.entitlementService.restorePurchases();
      final isActive = _isEntitlementActive(customerInfo);
      widget.onEntitlementChanged(isActive);
      // Dismiss before messaging, otherwise the SnackBar paints underneath
      // the still-open sheet.
      if (mounted) _dismissSheetIfCurrent(navigator, sheetRoute);
      widget.onMessage(
        isActive ? strings.paywallRestored : strings.paywallNothingToRestore,
      );
    } catch (error) {
      if (mounted) _dismissSheetIfCurrent(navigator, sheetRoute);
      widget.onMessage(strings.paywallRestoreFailed);
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  Widget _benefit(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF12191B)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF33474F)),
          ),
        ),
      ],
    );
  }

  Widget _buildPlans(L10nStrings strings) {
    if (_loadingOffering) {
      return const Center(
        child: WeldingLoader(size: 36, bladeColor: Color(0xFF12191B)),
      );
    }
    if (_hasAnyPackage) {
      return PaywallPackageButtons(
        monthly: _monthlyPackage,
        yearly: _yearlyPackage,
        purchasingPackageId: _purchasingPackageId,
        disabled: _purchasingPackageId != null || _restoring,
        onPurchase: _purchase,
      );
    }
    return Column(
      children: [
        Text(
          strings.paywallLoadFailed,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF33474F)),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _restoring ? null : _loadOffering,
            icon: const Icon(Icons.refresh),
            label: Text(strings.paywallRetry),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF12191B),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 26),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2DCE3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: const Color(0xFFFF6A35),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.workspace_premium_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Varyos Weld Premium',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _benefit(Icons.smart_toy_outlined, strings.paywallBenefitAi),
              const SizedBox(height: 10),
              _benefit(
                Icons.picture_as_pdf_outlined,
                strings.paywallBenefitPdf,
              ),
              const SizedBox(height: 10),
              _benefit(Icons.badge_outlined, strings.paywallBenefitReport),
              const SizedBox(height: 10),
              _benefit(
                Icons.event_repeat_outlined,
                strings.paywallBenefitCancel,
              ),
              const SizedBox(height: 22),
              _buildPlans(strings),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: (_restoring || _purchasingPackageId != null)
                      ? null
                      : _restore,
                  child: _restoring
                      ? const WeldingLoader(
                          size: 18,
                          bladeColor: Color(0xFF12191B),
                        )
                      : Text(strings.paywallRestore),
                ),
              ),
              const SizedBox(height: 4),
              PaywallLegalFooter(onLinkError: widget.onMessage),
            ],
          ),
        ),
      ),
    );
  }
}

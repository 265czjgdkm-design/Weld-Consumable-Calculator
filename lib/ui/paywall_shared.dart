import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../l10n/app_locale_scope.dart';
import '../l10n/strings.dart';
import '../services/legal_links.dart';
import 'widgets/welding_loader.dart';

/// Whole-percent saving of [yearly] vs. twelve [monthly] payments, or null
/// when there is no real saving (or the prices aren't comparable).
int? yearlySavingPercent(Package monthly, Package yearly) {
  final monthlyPrice = monthly.storeProduct.price;
  final yearlyPrice = yearly.storeProduct.price;
  if (monthlyPrice <= 0 || yearlyPrice <= 0) return null;
  final percent = ((1 - yearlyPrice / (monthlyPrice * 12)) * 100).round();
  return percent > 0 ? percent : null;
}

/// A purchase button for one subscription package. The billed amount
/// (`storeProduct.priceString`, already localized by the App Store) is the
/// largest text; the plan name and billing period are smaller and secondary.
class PaywallPackageButton extends StatelessWidget {
  const PaywallPackageButton({
    super.key,
    required this.package,
    required this.planLabel,
    required this.periodLabel,
    required this.onPressed,
    this.busy = false,
    this.badge,
  });

  final Package package;
  final String planLabel;
  final String periodLabel;
  final VoidCallback? onPressed;
  final bool busy;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF12191B),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: busy
            ? const WeldingLoader(size: 18, bladeColor: Colors.white)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    planLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    package.storeProduct.priceString,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(periodLabel, style: const TextStyle(fontSize: 12)),
                  if (badge != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      badge!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF9A75),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Monthly/yearly buttons (whichever packages exist) built from a RevenueCat
/// offering's real store prices.
class PaywallPackageButtons extends StatelessWidget {
  const PaywallPackageButtons({
    super.key,
    required this.monthly,
    required this.yearly,
    required this.purchasingPackageId,
    required this.disabled,
    required this.onPurchase,
  });

  final Package? monthly;
  final Package? yearly;
  final String? purchasingPackageId;
  final bool disabled;
  final ValueChanged<Package> onPurchase;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    final saving = (monthly != null && yearly != null)
        ? yearlySavingPercent(monthly!, yearly!)
        : null;

    Widget button(Package package, String plan, String period, String? badge) {
      return PaywallPackageButton(
        package: package,
        planLabel: plan,
        periodLabel: period,
        badge: badge,
        busy: purchasingPackageId == package.identifier,
        onPressed: disabled ? null : () => onPurchase(package),
      );
    }

    return Column(
      children: [
        if (monthly != null)
          button(
            monthly!,
            strings.paywallPlanMonthly,
            strings.paywallPeriodMonth,
            null,
          ),
        if (monthly != null && yearly != null) const SizedBox(height: 10),
        if (yearly != null)
          button(
            yearly!,
            strings.paywallPlanYearly,
            strings.paywallPeriodYear,
            saving == null
                ? null
                : strings.paywallSaveBadge.replaceFirst('{percent}', '$saving'),
          ),
      ],
    );
  }
}

/// Auto-renew disclosure (or the coming-soon note when there is nothing to
/// buy) plus tappable Privacy Policy / Terms of Use links. Shared by both
/// paywalls so they can't drift apart.
class PaywallLegalFooter extends StatelessWidget {
  const PaywallLegalFooter({
    super.key,
    required this.hasPackages,
    required this.onLinkError,
  });

  final bool hasPackages;
  final ValueChanged<String> onLinkError;

  Future<void> _open(BuildContext context, String url) async {
    try {
      await LegalLinks.open(url);
    } catch (_) {
      if (!context.mounted) return;
      onLinkError(AppLocaleScope.stringsOf(context).legalLinkOpenError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final L10nStrings strings = AppLocaleScope.stringsOf(context);
    final linkStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: const Color(0xFF12191B),
      decoration: TextDecoration.underline,
    );
    return Column(
      children: [
        Text(
          hasPackages
              ? strings.paywallAutoRenewDisclosure
              : strings.paywallComingSoonNote,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: const Color(0xFF8398A5)),
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _open(context, LegalLinks.privacyPolicyUrl),
              child: Text(
                strings.legalPrivacyPolicyLinkLabel,
                style: linkStyle,
              ),
            ),
            const Text('  ·  ', style: TextStyle(color: Color(0xFF8398A5))),
            GestureDetector(
              onTap: () => _open(context, LegalLinks.termsOfUseUrl),
              child: Text(strings.legalTermsOfUseLinkLabel, style: linkStyle),
            ),
          ],
        ),
      ],
    );
  }
}

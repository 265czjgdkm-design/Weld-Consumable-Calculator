import 'package:url_launcher/url_launcher.dart';

/// URLs for the app's Privacy Policy / Terms of Use, and the shared
/// mechanism for opening them in a real browser.
///
/// These point at the live pages on varyosweld.com (deployed from the
/// separate `varyosweld-landing` repo, sourced from `site/privacy.html` and
/// `site/terms.html` in this repo).
class LegalLinks {
  const LegalLinks._();

  static const String privacyPolicyUrl = 'https://varyosweld.com/privacy.html';
  static const String termsOfUseUrl = 'https://varyosweld.com/terms.html';

  static const String manageSubscriptionsUrl =
      'https://apps.apple.com/account/subscriptions';

  static Future<void> open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

import 'package:url_launcher/url_launcher.dart';

/// URLs for the app's Privacy Policy / Terms of Use, and the shared
/// mechanism for opening them in a real browser.
///
/// These point at the intended real deployment target -- they do not
/// resolve correctly yet because `varyosweld.com` isn't hosting these pages
/// on GitHub Pages yet. Deploying `site/privacy.html`/`site/terms.html`
/// (this repo) to the separate `varyosweld-landing` repo, plus DNS/HTTPS
/// setup, is a deferred follow-up task -- see project memory
/// (project_varyos_domain_email_setup / project_varyos_weld_flutter_app).
class LegalLinks {
  const LegalLinks._();

  static const String privacyPolicyUrl = 'https://varyosweld.com/privacy.html';
  static const String termsOfUseUrl = 'https://varyosweld.com/terms.html';

  static Future<void> open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

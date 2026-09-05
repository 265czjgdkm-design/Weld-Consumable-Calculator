import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'package:weld_consumable_calculator/services/legal_links.dart';

/// Mocks the url_launcher plugin at the platform-interface level (the
/// official recommended way to test url_launcher call sites without
/// actually opening a browser) -- see
/// https://pub.dev/packages/url_launcher#faq.
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

void main() {
  test('LegalLinks.open() launches the given URL via url_launcher', () async {
    final mockPlatform = _MockUrlLauncherPlatform();
    UrlLauncherPlatform.instance = mockPlatform;

    await LegalLinks.open(LegalLinks.privacyPolicyUrl);

    expect(mockPlatform.lastLaunchedUrl, LegalLinks.privacyPolicyUrl);
  });

  test('the intended Privacy Policy / Terms of Use URLs point at the real '
      'deployment domain', () {
    expect(LegalLinks.privacyPolicyUrl, 'https://varyosweld.com/privacy.html');
    expect(LegalLinks.termsOfUseUrl, 'https://varyosweld.com/terms.html');
  });
}

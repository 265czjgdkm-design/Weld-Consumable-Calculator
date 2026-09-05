import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/ui/email_gate_screen.dart';

/// Mocks url_launcher at the platform-interface level -- see
/// test/services/legal_links_test.dart for the first use of this pattern.
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
  final strings = stringsFor(AppLanguage.en);

  testWidgets(
    'the registration form shows a Privacy Policy / Terms of Use consent '
    'line with tappable links (Apple guideline 5.1.1(i))',
    (tester) async {
      final mockPlatform = _MockUrlLauncherPlatform();
      UrlLauncherPlatform.instance = mockPlatform;

      await tester.pumpWidget(
        AppLocaleScope(
          locale: AppLocale(),
          child: const MaterialApp(home: EmailGateScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(strings.authChoiceRegisterButton));
      await tester.pumpAndSettle();

      expect(find.text(strings.legalPrivacyPolicyLinkLabel), findsOneWidget);
      expect(find.text(strings.legalTermsOfUseLinkLabel), findsOneWidget);

      await tester.tap(find.text(strings.legalPrivacyPolicyLinkLabel));
      await tester.pumpAndSettle();
      expect(
        mockPlatform.lastLaunchedUrl,
        'https://varyosweld.com/privacy.html',
      );

      await tester.tap(find.text(strings.legalTermsOfUseLinkLabel));
      await tester.pumpAndSettle();
      expect(mockPlatform.lastLaunchedUrl, 'https://varyosweld.com/terms.html');
    },
  );
}

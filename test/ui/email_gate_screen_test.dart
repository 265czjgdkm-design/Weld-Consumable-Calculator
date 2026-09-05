import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // Regression test for the finding that DE/HI's consent suffix rendered
  // with no space before it ("Nutzungsbedingungenzu." / run-together
  // Hindi) since the suffix Text widget is placed directly after the
  // Terms-of-Use link with no separator in between.
  for (final language in AppLanguage.values) {
    testWidgets(
      'the ${language.code} consent line has a properly spaced suffix '
      'after the Terms of Use link',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final localeStrings = stringsFor(language);
        final locale = AppLocale();
        await locale.setLanguage(language);

        await tester.pumpWidget(
          AppLocaleScope(
            locale: locale,
            child: const MaterialApp(home: EmailGateScreen()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text(localeStrings.authChoiceRegisterButton));
        await tester.pumpAndSettle();

        final consentTexts = tester
            .widgetList<Text>(
              find.descendant(
                of: find.byType(Wrap),
                matching: find.byType(Text),
              ),
            )
            .map((text) => text.data ?? '')
            .join();

        final expected =
            '${localeStrings.authFormConsentPrefix} '
            '${localeStrings.legalPrivacyPolicyLinkLabel} '
            '${localeStrings.authFormConsentConnector} '
            '${localeStrings.legalTermsOfUseLinkLabel}'
            '${localeStrings.authFormConsentSuffix}';

        expect(consentTexts, expected);

        // The Terms of Use label and the suffix must not be glued
        // together with no separating character in between.
        final termsEnd =
            consentTexts.indexOf(localeStrings.legalTermsOfUseLinkLabel) +
            localeStrings.legalTermsOfUseLinkLabel.length;
        final charAfterTerms = consentTexts[termsEnd];
        expect(
          charAfterTerms == ' ' || !RegExp(r'[A-Za-zА-Яа-яऀ-ॿ]').hasMatch(charAfterTerms),
          isTrue,
          reason:
              'Suffix must not run directly into the Terms of Use label '
              'with no separating space/punctuation: "$consentTexts"',
        );
      },
    );
  }
}

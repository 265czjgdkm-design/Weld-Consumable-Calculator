// Paywall screenshot for the subscription App Review screenshot. Run WITHOUT
// TESTER_PREMIUM so the real paywall shows:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/paywall_screenshot_test.dart -d <simulator-id>
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/main.dart' as app;

final _s = stringsFor(AppLanguage.en);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester tester, [int seconds = 2]) async {
    for (var i = 0; i < seconds * 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('paywall screenshot', (tester) async {
    app.main();
    await settle(tester, 6);
    if (find.text(_s.authChoiceGuestButton).evaluate().isNotEmpty) {
      await tester.tap(find.text(_s.authChoiceGuestButton).first);
      await settle(tester);
    }
    final ai = find.text(_s.dashboardAiAssistant).first;
    await tester.ensureVisible(ai);
    await settle(tester, 1);
    await tester.tap(ai);
    // Give StoreKit time to load the offering prices.
    await settle(tester, 12);
    await binding.takeScreenshot('paywall');
  });
}

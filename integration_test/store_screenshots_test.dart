// App Store screenshots. Run on the iPhone 6.9" simulator:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/store_screenshots_test.dart \
//     --dart-define=TESTER_PREMIUM=true -d <simulator-id>
import 'package:flutter/material.dart';
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

  Future<void> shot(WidgetTester tester, String name) async {
    await settle(tester);
    await binding.takeScreenshot(name);
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final finder = find.text(text).first;
    await tester.ensureVisible(finder);
    await settle(tester, 1);
    await tester.tap(finder);
    await settle(tester);
  }

  Finder fieldByLabel(String label) => find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.labelText == label,
  );

  Future<void> enter(WidgetTester tester, String label, String value) async {
    final finder = fieldByLabel(label).first;
    await tester.ensureVisible(finder);
    await tester.enterText(finder, value);
    await tester.pump();
  }

  Future<void> showResult(WidgetTester tester, String label) async {
    final finder = find.text(label).first;
    await tester.ensureVisible(finder);
    await settle(tester, 1);
    // Put the result card near the top of the screen.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 200));
    await settle(tester, 1);
  }

  Future<void> back(WidgetTester tester) async {
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.pop();
    await settle(tester);
  }

  testWidgets('store screenshots', (tester) async {
    app.main();
    await settle(tester, 6);
    if (find.text(_s.authChoiceGuestButton).evaluate().isNotEmpty) {
      await tapText(tester, _s.authChoiceGuestButton);
    }
    await shot(tester, '01_home');

    // Preheat (EN 1011-2 CET)
    await tapText(tester, 'Preheat Temperature');
    await enter(tester, _s.materialFieldCarbon, '0.18');
    await enter(tester, _s.materialFieldSilicon, '0.40');
    await enter(tester, _s.materialFieldManganese, '1.40');
    await enter(tester, _s.materialFieldChromium, '0.10');
    await enter(tester, _s.materialFieldMolybdenum, '0.05');
    await enter(tester, _s.materialFieldNickel, '0.10');
    await enter(tester, _s.materialFieldCopper, '0.10');
    await enter(tester, _s.preheatThicknessLabel, '30');
    await enter(tester, _s.preheatHdLabel, '5');
    await enter(tester, _s.heatInputQLabel, '1.2');
    FocusManager.instance.primaryFocus?.unfocus();
    await tapText(tester, _s.preheatCalculateButton);
    await showResult(tester, _s.preheatResultLabel);
    await shot(tester, '03_preheat');
    await back(tester);

    // Cooling time t8/5
    await tapText(tester, 'Cooling Time (t8/5)');
    await enter(tester, _s.coolingT0Label, '100');
    await enter(tester, _s.coolingThicknessLabel, '20');
    await enter(tester, _s.heatInputQLabel, '1.5');
    FocusManager.instance.primaryFocus?.unfocus();
    await tapText(tester, _s.coolingCalculateButton);
    await showResult(tester, _s.coolingResultLabel);
    await shot(tester, '05_cooling');
    await back(tester);

    // Filler / consumable wizard
    await tapText(tester, 'Filler Material Consumption');
    await tapText(tester, _s.getStarted);
    await shot(tester, '02_filler_process');
    for (var i = 0; i < 3; i++) {
      if (find.text(_s.commonContinue).evaluate().isEmpty) break;
      await tapText(tester, _s.commonContinue);
    }
    await shot(tester, '06_filler_step');
    if (find.text(_s.commonCalculate).evaluate().isNotEmpty) {
      await tapText(tester, _s.commonCalculate);
      await shot(tester, '07_filler_result');
    }
  });
}

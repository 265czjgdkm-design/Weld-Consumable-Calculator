import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/l10n/guide_content.dart';
import 'package:weld_consumable_calculator/l10n/premium_account_copy.dart';
import 'package:weld_consumable_calculator/ui/calculator_page/calculator_page_widgets.dart';
import 'package:weld_consumable_calculator/ui/cooling_time_calculator_screen.dart';
import 'package:weld_consumable_calculator/ui/preheat_calculator_screen.dart';
import 'package:weld_consumable_calculator/ui/user_guide_screen.dart';

Future<void> _pump(WidgetTester tester, Widget home) async {
  SharedPreferences.setMockInitialValues({});
  final locale = AppLocale();
  await locale.setLanguage(AppLanguage.en);
  tester.view.physicalSize = const Size(1000, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    AppLocaleScope(
      locale: locale,
      child: MaterialApp(home: home),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('every locale has non-empty content for every section', () {
    for (final language in AppLanguage.values) {
      final copy = guideCopyFor(language);
      expect(copy.screenTitle, isNotEmpty, reason: language.code);
      expect(copy.searchHint, isNotEmpty, reason: language.code);
      expect(copy.sections.keys.toSet(), guideSectionIds.toSet());
      for (final id in guideSectionIds) {
        final entry = copy.sections[id]!;
        expect(entry.title.trim(), isNotEmpty, reason: '${language.code}/$id');
        expect(
          entry.body.trim().length,
          greaterThan(40),
          reason: '${language.code}/$id',
        );
      }
      final howTo = premiumAccountCopyFor(language);
      expect(howTo.howToUse, isNotEmpty);
      expect(howTo.guideRow, isNotEmpty);
    }
  });

  test('guide numbers match the code', () {
    for (final language in AppLanguage.values) {
      final sections = guideCopyFor(language).sections;
      expect(sections['heatinput']!.body, matches(RegExp(r'SMAW 0[.,]8')));
      expect(sections['heatinput']!.body, matches(RegExp(r'SAW 1[.,]0')));
      expect(sections['preheat']!.body, contains('697'));
      expect(sections['cooling']!.body, contains('6700'));
      expect(sections['filler']!.body, matches(RegExp(r'GTAW 0[.,]95')));
    }
  });

  testWidgets('guide opens at the requested section and searches', (
    tester,
  ) async {
    await _pump(tester, const UserGuideScreen(initialSectionId: 'preheat'));
    final copy = guideCopyFor(AppLanguage.en);

    expect(find.text(copy.sections['preheat']!.title), findsOneWidget);
    expect(find.textContaining('CET = C +'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzzz-no-match');
    await tester.pumpAndSettle();
    expect(find.text(copy.noResults), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'travel speed');
    await tester.pumpAndSettle();
    expect(find.text(copy.sections['heatinput']!.title), findsOneWidget);
    expect(find.text(copy.sections['faq']!.title), findsNothing);
  });

  testWidgets('How to use link on the preheat calculator opens its section', (
    tester,
  ) async {
    await _pump(tester, const PreheatCalculatorScreen());
    await tester.tap(find.text(premiumAccountCopyFor(AppLanguage.en).howToUse));
    await tester.pumpAndSettle();

    expect(find.byType(UserGuideScreen), findsOneWidget);
    expect(find.textContaining('CET = C +'), findsOneWidget);
  });

  testWidgets('How to use link on the cooling calculator opens its section', (
    tester,
  ) async {
    await _pump(tester, const CoolingTimeCalculatorScreen());
    await tester.tap(find.text(premiumAccountCopyFor(AppLanguage.en).howToUse));
    await tester.pumpAndSettle();

    expect(find.byType(UserGuideScreen), findsOneWidget);
    expect(find.textContaining('3D (thick plate)'), findsOneWidget);
  });

  for (final width in [320.0, 375.0, 430.0]) {
    testWidgets('home header is one row without overflow at ${width}pt', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final locale = AppLocale();
      await locale.setLanguage(AppLanguage.tr);
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        AppLocaleScope(
          locale: locale,
          child: const MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: EdgeInsets.all(18),
                child: TopNavigationBar(showGuide: true),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(LanguagePickerButton), findsOneWidget);
      expect(find.byIcon(Icons.menu_book_outlined), findsOneWidget);
      expect(
        tester.getCenter(find.byType(LanguagePickerButton)).dy,
        closeTo(tester.getCenter(find.text('VARYOS')).dy, 12),
      );
      expect(
        tester.getTopRight(find.byType(LanguagePickerButton)).dx,
        lessThanOrEqualTo(width),
      );
    });
  }
}

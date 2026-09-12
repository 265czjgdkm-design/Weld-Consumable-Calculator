import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/ui/splash_screen.dart';
import 'package:weld_consumable_calculator/ui/widgets/welding_loader.dart';

class _RecordingNavigatorObserver extends NavigatorObserver {
  int replaceCount = 0;

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    replaceCount++;
  }
}

/// The splash always navigates on to either the email gate or the
/// dashboard, both of which read strings via [AppLocaleScope] -- so it
/// needs one in its ancestry same as any other real usage.
Widget _wrap(Widget home, {List<NavigatorObserver> observers = const []}) {
  return AppLocaleScope(
    locale: AppLocale(),
    child: MaterialApp(home: home, navigatorObservers: observers),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'the hammer swaps back to a clean mark once its strike completes, '
    'instead of staying parked on the corrupted struck pose through the '
    'wordmark reveal (reviewer finding #1)',
    (tester) async {
      await tester.pumpWidget(_wrap(const SplashScreen()));
      // Let the async Rive-asset probe resolve so the fallback plays.
      await tester.pump();

      // Formation is visually done and the hammer beat has started well
      // before this point (see _formationVisualEndFraction).
      await tester.pump(const Duration(milliseconds: 1400));
      expect(find.byType(WeldingLoader), findsOneWidget);

      // Run the one-shot hammer beat (700ms) to completion.
      await tester.pump(const Duration(milliseconds: 750));

      // The hammer must be gone -- not parked on its final struck pose --
      // while the wordmark reveals, or that corrupted frame would be the
      // last thing visible for the rest of the splash.
      expect(find.byType(WeldingLoader), findsNothing);
    },
  );

  testWidgets(
    'tapping to skip late in the sequence navigates exactly once, not '
    'twice (reviewer finding #6)',
    (tester) async {
      final observer = _RecordingNavigatorObserver();
      await tester.pumpWidget(
        _wrap(const SplashScreen(), observers: [observer]),
      );
      await tester.pump();

      // Tap close to when the auto-navigate timer would fire on its own.
      await tester.pump(const Duration(milliseconds: 2700));
      await tester.tap(find.byType(SplashScreen));
      await tester.pump(const Duration(milliseconds: 50));
      // Let any (incorrectly) still-pending timer also fire.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(observer.replaceCount, 1);
    },
  );

  testWidgets(
    'the corrected splash duration is meaningfully shorter than the '
    'original 3400ms, and the auto-navigate timer matches it exactly '
    '(reviewer finding #2)',
    (tester) async {
      final observer = _RecordingNavigatorObserver();
      await tester.pumpWidget(
        _wrap(const SplashScreen(), observers: [observer]),
      );
      await tester.pump();

      // Nothing has navigated yet well before the old 3400ms figure.
      await tester.pump(const Duration(milliseconds: 2800));
      expect(observer.replaceCount, 0);

      // ...but it has by shortly after the corrected total.
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      expect(observer.replaceCount, 1);
    },
  );
}

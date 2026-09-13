import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/ui/splash_screen.dart';
import 'package:weld_consumable_calculator/ui/widgets/welding_loader.dart';

/// Captures the exact rendered pixels of [finder]'s [RepaintBoundary] --
/// the same real frame-accurate technique reviewers used to catch findings
/// B and C, now pinned into the suite itself.
Future<Uint8List> _captureRgba(WidgetTester tester, Finder finder) async {
  final renderObject = tester.renderObject(finder) as RenderRepaintBoundary;
  final image = await renderObject.toImage(pixelRatio: 1.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  return byteData!.buffer.asUint8List();
}

bool _bytesEqual(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

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
      await tester.pump(const Duration(milliseconds: 2600));
      expect(observer.replaceCount, 0);

      // ...but it has by shortly after the corrected total.
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      expect(observer.replaceCount, 1);
    },
  );

  testWidgets(
    'the formation/hammer/wordmark sequence has no long stretch of '
    'frame-to-frame visual stillness -- catches a dead-air regression '
    '(finding B) at the test level, not just via manual pixel-diffing',
    (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        _wrap(RepaintBoundary(key: key, child: const SplashScreen())),
      );
      // Let the async Rive-asset probe resolve so the fallback plays.
      await tester.pump();

      const stepMs = 50;
      // Covers formation + hammer + wordmark only, deliberately excluding
      // the final ~300ms hold before navigation, which is an intentional
      // still beat, not a regression.
      const totalMs = 2300;
      Uint8List? previous;
      var stillStreakMs = 0;
      var maxStillStreakMs = 0;

      for (var t = 0; t <= totalMs; t += stepMs) {
        await tester.pump(const Duration(milliseconds: stepMs));
        final current = (await tester.runAsync(
          () => _captureRgba(tester, find.byKey(key)),
        ))!;
        if (previous != null && _bytesEqual(previous, current)) {
          stillStreakMs += stepMs;
          if (stillStreakMs > maxStillStreakMs) {
            maxStillStreakMs = stillStreakMs;
          }
        } else {
          stillStreakMs = 0;
        }
        previous = current;
      }

      expect(
        maxStillStreakMs,
        lessThan(150),
        reason:
            'found a ${maxStillStreakMs}ms stretch of zero visual change -- '
            'this is the dead-air regression finding B fixed',
      );
    },
  );
}

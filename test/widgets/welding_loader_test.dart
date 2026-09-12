import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weld_consumable_calculator/ui/widgets/welding_loader.dart';

/// Captures the exact rendered pixels of [finder]'s [RepaintBoundary] at a
/// fixed 1:1 pixel ratio (independent of the test surface's device pixel
/// ratio), so frame-to-frame comparisons below are a real pixel diff of
/// what's on screen -- the same technique the reviewer used to catch
/// findings #3 and #4.
Future<Uint8List> _captureRgba(WidgetTester tester, Finder finder) async {
  final renderObject =
      tester.renderObject(finder) as RenderRepaintBoundary;
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

void main() {
  testWidgets(
    'loop:true builds and animates through several cycles without throwing, '
    'in both simplified (<40) and full (>=40) size modes',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [WeldingLoader(size: 20), WeldingLoader(size: 64)],
            ),
          ),
        ),
      );

      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.byType(WeldingLoader), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('loop:false plays once and calls onComplete exactly once', (
    tester,
  ) async {
    var completeCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WeldingLoader(
            size: 96,
            loop: false,
            onComplete: () => completeCount++,
          ),
        ),
      ),
    );

    // Pump well past the 1000ms cycle duration to confirm it settles and
    // does not repeat.
    await tester.pump(const Duration(milliseconds: 1200));
    expect(completeCount, 1);

    await tester.pump(const Duration(milliseconds: 500));
    expect(completeCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disposing mid-animation does not throw', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: WeldingLoader(size: 40)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  for (final size in [18.0, 20.0, 36.0]) {
    testWidgets(
      'simplified mode at the real in-app size ${size}px has no '
      'multi-hundred-ms stretch of zero pixel change across a full loop '
      'cycle (reviewer finding #3)',
      (tester) async {
        final key = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: RepaintBoundary(
                  key: key,
                  child: WeldingLoader(size: size),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        const stepMs = 50;
        const totalMs = 1000;
        Uint8List? previous;
        var identicalStreakMs = 0;
        var maxIdenticalStreakMs = 0;

        for (var t = 0; t <= totalMs; t += stepMs) {
          await tester.pump(const Duration(milliseconds: stepMs));
          // toImage() rasterizes for real (outside the fake-async test
          // zone), so it must run via runAsync or it hangs forever.
          final current = (await tester.runAsync(
            () => _captureRgba(tester, find.byKey(key)),
          ))!;
          if (previous != null && _bytesEqual(previous, current)) {
            identicalStreakMs += stepMs;
            if (identicalStreakMs > maxIdenticalStreakMs) {
              maxIdenticalStreakMs = identicalStreakMs;
            }
          } else {
            identicalStreakMs = 0;
          }
          previous = current;
        }

        expect(
          maxIdenticalStreakMs,
          lessThan(200),
          reason:
              'no stretch of the loop should render as visually frozen -- '
              'longest run of pixel-identical frames was '
              '${maxIdenticalStreakMs}ms',
        );
      },
    );
  }

  testWidgets(
    'the hammer head visually reaches the impact point at full swing '
    'extension, not the handle (reviewer finding #4)',
    (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: RepaintBoundary(
                key: key,
                child: const WeldingLoader(size: 80, loop: false),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // The one-shot (loop:false) cycle is 700ms; swing ends at 20/70 and
      // impact ends at 35/70 of it (200ms/350ms) -- the midpoint of that
      // struck window (angle == 0, full extension) is 275ms in.
      await tester.pump(const Duration(milliseconds: 275));

      final bytes = (await tester.runAsync(
        () => _captureRgba(tester, find.byKey(key)),
      ))!;
      // 80px widget captured at pixelRatio 1.0 -> an 80x80 RGBA image. At
      // full extension the head spans screen-space x:[28.8, 51.2],
      // y:[53.6, 63.2] (see _paintHammer) -- sampled well inside that box,
      // clear of the anti-aliased edges (right at y=63.2 would blend with
      // the impact flash bloom underneath).
      const width = 80;
      const x = 40;
      const y = 58;
      final index = (y * width + x) * 4;
      final r = bytes[index];
      final g = bytes[index + 1];
      final b = bytes[index + 2];
      final a = bytes[index + 3];

      expect(
        a,
        greaterThan(0),
        reason: 'the impact point should be covered by something (the '
            'hammer head) at full swing extension, not transparent',
      );
      expect(
        r > 180 && g > 180 && b > 180,
        isTrue,
        reason:
            'the impact point should show the light hammer head color at '
            'full extension, not the orange spark or empty background -- '
            'got rgba($r, $g, $b, $a)',
      );
    },
  );
}

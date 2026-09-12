import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weld_consumable_calculator/ui/widgets/welding_loader.dart';

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
}

import 'package:flutter_test/flutter_test.dart';
import 'package:weld_consumable_calculator/core/weld_formulas.dart';

void main() {
  group('filletOversizeDeltaPercent', () {
    test('computes ~+77.8% going from a 3/16" to a 1/4" leg', () {
      final delta = WeldFormulas.filletOversizeDeltaPercent(
        currentLegMm: 4.7625,
        nextLegMm: 6.35,
      );

      expect(delta, closeTo(0.778, 0.001));
    });
  });
}

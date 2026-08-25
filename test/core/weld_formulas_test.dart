import 'package:flutter_test/flutter_test.dart';
import 'package:weld_consumable_calculator/core/weld_formulas.dart';

void main() {
  group('nextStandardFilletLegMm', () {
    test('returns the next size up from the shipped standard-size table', () {
      expect(WeldFormulas.nextStandardFilletLegMm(8), 10);
      expect(WeldFormulas.nextStandardFilletLegMm(7.5), 8);
    });

    test('returns null once at or above the largest standard size', () {
      expect(WeldFormulas.nextStandardFilletLegMm(12), null);
      expect(WeldFormulas.nextStandardFilletLegMm(15), null);
    });
  });

  group('filletOversizeDeltaFraction', () {
    test('computes ~+56% going from an 8mm to a 10mm leg (real shipped path)', () {
      final delta = WeldFormulas.filletOversizeDeltaFraction(
        currentLegMm: 8,
        nextLegMm: WeldFormulas.nextStandardFilletLegMm(8)!,
      );

      expect(delta, closeTo(0.5625, 0.001));
    });
  });
}

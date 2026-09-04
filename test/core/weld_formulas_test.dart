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
    test(
      'computes ~+56% going from an 8mm to a 10mm leg (real shipped path)',
      () {
        final delta = WeldFormulas.filletOversizeDeltaFraction(
          currentLegMm: 8,
          nextLegMm: WeldFormulas.nextStandardFilletLegMm(8)!,
        );

        expect(delta, closeTo(0.5625, 0.001));
      },
    );
  });

  group(
    'groove top-width helpers match the area functions they were extracted from',
    () {
      test('singleVTopWidthMm feeds singleVAreaMm2 unchanged', () {
        const args = (
          thicknessMm: 12.0,
          rootFaceMm: 2.0,
          rootGapMm: 3.0,
          bevelAngleDeg: 30.0,
        );
        final topWidth = WeldFormulas.singleVTopWidthMm(
          thicknessMm: args.thicknessMm,
          rootFaceMm: args.rootFaceMm,
          rootGapMm: args.rootGapMm,
          bevelAngleDeg: args.bevelAngleDeg,
        );
        final grooveHeight = args.thicknessMm - args.rootFaceMm;

        expect(topWidth, closeTo(14.547, 0.001));
        expect(
          WeldFormulas.singleVAreaMm2(
            thicknessMm: args.thicknessMm,
            rootFaceMm: args.rootFaceMm,
            rootGapMm: args.rootGapMm,
            bevelAngleDeg: args.bevelAngleDeg,
          ),
          closeTo(
            (args.rootGapMm * args.rootFaceMm) +
                (((args.rootGapMm + topWidth) / 2) * grooveHeight),
            0.0001,
          ),
        );
      });

      test('halfVTopWidthMm feeds halfVAreaMm2 unchanged', () {
        const args = (
          thicknessMm: 12.0,
          rootFaceMm: 2.0,
          rootGapMm: 3.0,
          bevelAngleDeg: 30.0,
        );
        final topWidth = WeldFormulas.halfVTopWidthMm(
          thicknessMm: args.thicknessMm,
          rootFaceMm: args.rootFaceMm,
          rootGapMm: args.rootGapMm,
          bevelAngleDeg: args.bevelAngleDeg,
        );
        final grooveHeight = args.thicknessMm - args.rootFaceMm;

        expect(topWidth, closeTo(8.7735, 0.001));
        expect(
          WeldFormulas.halfVAreaMm2(
            thicknessMm: args.thicknessMm,
            rootFaceMm: args.rootFaceMm,
            rootGapMm: args.rootGapMm,
            bevelAngleDeg: args.bevelAngleDeg,
          ),
          closeTo(
            (args.rootGapMm * args.rootFaceMm) +
                (((args.rootGapMm + topWidth) / 2) * grooveHeight),
            0.0001,
          ),
        );
      });

      test('doubleVTopWidthMm equals singleVTopWidthMm at half thickness', () {
        const thicknessMm = 16.0;
        const rootFaceMm = 2.0;
        const rootGapMm = 3.0;
        const bevelAngleDeg = 35.0;

        final topWidth = WeldFormulas.doubleVTopWidthMm(
          thicknessMm: thicknessMm,
          rootFaceMm: rootFaceMm,
          rootGapMm: rootGapMm,
          bevelAngleDeg: bevelAngleDeg,
        );

        expect(
          topWidth,
          closeTo(
            WeldFormulas.singleVTopWidthMm(
              thicknessMm: thicknessMm / 2,
              rootFaceMm: rootFaceMm,
              rootGapMm: rootGapMm,
              bevelAngleDeg: bevelAngleDeg,
            ),
            0.0001,
          ),
        );
      });

      test('compoundVTopWidthMm feeds compoundVAreaMm2 unchanged', () {
        const thicknessMm = 16.0;
        const rootFaceMm = 2.0;
        const rootGapMm = 3.0;
        const primaryBevelAngleDeg = 35.0;
        const secondaryBevelAngleDeg = 10.0;
        const breakHeightMm = 5.0;

        final topWidth = WeldFormulas.compoundVTopWidthMm(
          thicknessMm: thicknessMm,
          rootFaceMm: rootFaceMm,
          rootGapMm: rootGapMm,
          primaryBevelAngleDeg: primaryBevelAngleDeg,
          secondaryBevelAngleDeg: secondaryBevelAngleDeg,
          breakHeightMm: breakHeightMm,
        );

        expect(topWidth, greaterThan(rootGapMm));
        expect(
          WeldFormulas.compoundVAreaMm2(
            thicknessMm: thicknessMm,
            rootFaceMm: rootFaceMm,
            rootGapMm: rootGapMm,
            primaryBevelAngleDeg: primaryBevelAngleDeg,
            secondaryBevelAngleDeg: secondaryBevelAngleDeg,
            breakHeightMm: breakHeightMm,
          ),
          closeTo(142.81, 0.05),
        );
      });
    },
  );

  group('capReinforcementAreaMm2', () {
    test('is a rectangle spanning the groove top width plus both overlaps', () {
      final area = WeldFormulas.capReinforcementAreaMm2(
        grooveTopWidthMm: 10,
        capOverlapMm: 2,
        capHeightMm: 3,
      );

      expect(area, closeTo(42, 0.0001));
    });

    test('is zero when overlap and height are both zero', () {
      final area = WeldFormulas.capReinforcementAreaMm2(
        grooveTopWidthMm: 10,
        capOverlapMm: 0,
        capHeightMm: 0,
      );

      expect(area, 0);
    });
  });
}

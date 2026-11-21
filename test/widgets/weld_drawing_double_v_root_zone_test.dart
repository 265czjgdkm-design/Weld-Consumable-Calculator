import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/ui/widgets/weld_drawing_preview.dart';

WeldDrawingScene _scene(GrooveType g) => buildWeldDrawingScene(
  grooveType: g,
  jointType: JointType.plateButt,
  data: const WeldDrawingData(
    weldingProcess: WeldingProcess.gtawSmaw,
    geometryMode: JointGeometryMode.equal,
    alignment: JointAlignment.centerline,
    thicknessMm: 20,
    rootGapMm: 3,
    rootFaceMm: 2,
    bevelAngleDeg: 30,
    gtawTransitionMm: 6,
  ),
  size: const Size(360, 400),
  smawFillCapLabel: 'SMAW fill / cap',
  gtawRootLabel: 'GTAW root',
  capTopLabel: 'Top',
  capBottomLabel: 'Bottom',
  capOverlapValueLabel: 'mm',
  capHeightValueLabel: 'mm',
);

void main() {
  test(
    'Double V: GTAW zone sits at the mid-thickness land, not the back face',
    () {
      final s = _scene(GrooveType.doubleV);
      final b = s.weld.getBounds();
      final top = s.rootZoneTopY!;
      final bottom = s.rootZoneBottomY!;
      final mid = (b.top + b.bottom) / 2;
      expect(bottom, lessThan(b.bottom - 0.2 * b.height));
      expect(bottom, greaterThan(mid));
      expect(top, lessThan(mid));
      expect(top, greaterThan(b.top));
    },
  );

  test('Single V: GTAW zone runs from the back face (no bottom bound)', () {
    final s = _scene(GrooveType.singleV);
    expect(s.rootZoneTopY, isNotNull);
    expect(s.rootZoneBottomY, isNull);
  });
}

// Regression coverage for two reviewer findings in the cap-overlap/cap-
// height drawing feature:
//
// Finding 4: the cap-height/cap-overlap dimension LABEL must show the real
// entered value, not the drawing's clamped geometry - verified here
// differentially (two raw values that clamp down to the SAME drawn
// geometry must still produce different label rects, since only the text
// differs) rather than by trying to read literal pixels back out of a
// Canvas.
//
// Double-V-both-faces decision: Double V is welded from both sides, so its
// drawing must show a cap-reinforcement dimension pair on BOTH faces (top
// and bottom), not just one - verified via hotspot count (2 cap-overlap +
// 2 cap-height hotspots for Double V, vs 1 each for a single-face groove
// type) and via the two same-field hotspots never overlapping each other.
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/ui/calculator_page/calculator_page_models.dart';
import 'package:weld_consumable_calculator/ui/widgets/weld_drawing_preview.dart';

/// Same no-op approach as weld_drawing_hotspot_test.dart - only the hotspot
/// rects the paint pass computes matter here, not real pixels.
class _NoopCanvas implements Canvas {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

List<DrawingHotspot> _hotspotsFor(WeldDrawingData data, GrooveType groove) {
  final strings = stringsFor(AppLanguage.en);
  return debugWeldDrawingHotspots(
    grooveType: groove,
    jointType: JointType.plateButt,
    drawingMode: DrawingMode.visual,
    data: data,
    jointTypeLabel: JointType.plateButt.labelFor(strings),
    grooveTypeLabel: groove.labelFor(strings),
    filletWeldFaceLabel: strings.drawingLabelFilletWeldFace,
    tJointLabel: strings.drawingLabelTJoint,
    smawFillCapLabel: strings.drawingLabelSmawFillCap,
    gtawRootLabel: strings.drawingLabelGtawRoot,
    canvas: _NoopCanvas(),
    size: const Size(760, 400),
    fillAvailableSpace: false,
  );
}

void main() {
  setUpAll(() async {
    final root =
        Platform.environment['FLUTTER_ROOT'] ?? '/opt/homebrew/share/flutter';
    final fontDir = Directory('$root/bin/cache/artifacts/material_fonts');
    for (final name in [
      'Roboto-Regular.ttf',
      'Roboto-Medium.ttf',
      'Roboto-Bold.ttf',
    ]) {
      final file = File('${fontDir.path}/$name');
      if (!file.existsSync()) continue;
      final bytes = await file.readAsBytes();
      final loader = FontLoader('Roboto')
        ..addFont(Future.value(ByteData.view(bytes.buffer)));
      await loader.load();
    }
  });

  test(
    'Finding 4: cap-height label reflects the raw entered value, not the '
    'drawing-clamped geometry (two raw values that clamp to the same drawn '
    'geometry must still render different label text/rects)',
    () {
      // thicknessMm: 6 -> drawn cap-height clamp bound is
      // max(thickness*0.4, 1) = 2.4mm regardless of the raw entered value,
      // as long as the raw value exceeds that bound. 3 and 10 both clamp
      // to the identical 2.4mm drawn geometry, so if the bug were still
      // present (label built from the clamped value) both would render
      // the exact same "2.4 mm cap height" text and therefore an
      // identical-width rect.
      WeldDrawingData data(double capHeightMm) => WeldDrawingData(
        weldingProcess: WeldingProcess.gtaw,
        geometryMode: JointGeometryMode.equal,
        alignment: JointAlignment.centerline,
        thicknessMm: 6,
        rootGapMm: 3,
        rootFaceMm: 2,
        bevelAngleDeg: 30,
        capOverlapMm: 2,
        capHeightMm: capHeightMm,
      );

      Rect capHeightRect(double capHeightMm) => _hotspotsFor(
        data(capHeightMm),
        GrooveType.singleV,
      ).firstWhere((h) => h.fieldKey == FieldKey.capHeightMm).rect;

      final rectForRaw3 = capHeightRect(3);
      final rectForRaw10 = capHeightRect(10);

      expect(
        rectForRaw3,
        isNot(equals(rectForRaw10)),
        reason:
            'Cap height 3mm and 10mm both clamp to the same 2.4mm drawn '
            'geometry on a 6mm-thick plate, so their label rects can only '
            'differ if the label text uses the real entered value ("3" vs '
            '"10") rather than the identical clamped value ("2.4" both '
            'times).',
      );
    },
  );

  test(
    "Double-V-both-faces decision: Double V's drawing shows a cap "
    'dimension pair on BOTH faces (2 cap-overlap + 2 cap-height hotspots, '
    "not 1), while a single-face groove type (Single V) still shows only "
    'one of each',
    () {
      const doubleVData = WeldDrawingData(
        weldingProcess: WeldingProcess.smaw,
        geometryMode: JointGeometryMode.equal,
        alignment: JointAlignment.centerline,
        thicknessMm: 16,
        rootGapMm: 2,
        rootFaceMm: 2,
        bevelAngleDeg: 30,
        capOverlapMm: 2,
        capHeightMm: 3,
      );
      const singleVData = WeldDrawingData(
        weldingProcess: WeldingProcess.smaw,
        geometryMode: JointGeometryMode.equal,
        alignment: JointAlignment.centerline,
        thicknessMm: 12,
        rootGapMm: 3,
        rootFaceMm: 2,
        bevelAngleDeg: 30,
        capOverlapMm: 2,
        capHeightMm: 3,
      );

      final doubleVHotspots = _hotspotsFor(doubleVData, GrooveType.doubleV);
      final singleVHotspots = _hotspotsFor(singleVData, GrooveType.singleV);

      final doubleVOverlapRects = doubleVHotspots
          .where((h) => h.fieldKey == FieldKey.capOverlapMm)
          .map((h) => h.rect)
          .toList();
      final doubleVHeightRects = doubleVHotspots
          .where((h) => h.fieldKey == FieldKey.capHeightMm)
          .map((h) => h.rect)
          .toList();
      final singleVOverlapCount = singleVHotspots
          .where((h) => h.fieldKey == FieldKey.capOverlapMm)
          .length;
      final singleVHeightCount = singleVHotspots
          .where((h) => h.fieldKey == FieldKey.capHeightMm)
          .length;

      expect(singleVOverlapCount, 1);
      expect(singleVHeightCount, 1);
      expect(
        doubleVOverlapRects,
        hasLength(2),
        reason: 'Double V is welded from both sides, so it must show a '
            'cap-overlap callout on both faces.',
      );
      expect(
        doubleVHeightRects,
        hasLength(2),
        reason: 'Double V is welded from both sides, so it must show a '
            'cap-height callout on both faces.',
      );
      expect(
        doubleVOverlapRects[0].overlaps(doubleVOverlapRects[1]),
        isFalse,
        reason: "Double V's top-face and bottom-face cap-overlap labels "
            'must not overlap each other.',
      );
      expect(
        doubleVHeightRects[0].overlaps(doubleVHeightRects[1]),
        isFalse,
        reason: "Double V's top-face and bottom-face cap-height labels "
            'must not overlap each other.',
      );
    },
  );
}

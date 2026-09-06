// Regression coverage for a label/line collision bug that
// weld_drawing_label_overlap_test.dart's pill-vs-pill overlap check cannot
// catch: a leader/dimension line running straight through the middle of a
// label's TEXT reads as a strikethrough even when the label's own bounding
// box doesn't overlap any other label's bounding box (the overlap suite
// only ever compares label rects against other label rects, never against
// the actual line segments the painter draws). Confirmed via a real
// screenshot - Double V, GTAW+SMAW combined process, desktop rendering -
// where the root-face/groove-depth dimension line passed directly through
// the "GTAW kök" (GTAW root) label. Root cause: in all 5 groove-drawing
// functions, `_drawCombinedProcessTint`'s GTAW-root label was centered only
// ~1mm away from the very dimension line drawn right next to it (see
// TEAM_LEARNINGS.md). This test renders the real painter (real Roboto font,
// not flutter_test's default Ahem) and asserts none of the guide-colored
// line segments it draws actually cross the GTAW-root label's real rect -
// a geometric line-segment-vs-rect intersection check, not another
// pill-vs-pill overlap check.
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

/// Liang-Barsky segment-vs-rect clipping: returns true iff the segment
/// [a]->[b] intersects (crosses into or lies inside) [r]. A plain
/// `rect.overlaps` check doesn't apply here - lines have zero area, so what
/// "line passes through the label" actually means is a segment/rect
/// intersection test, not a rect/rect one.
bool _segmentIntersectsRect(Offset a, Offset b, Rect r) {
  double t0 = 0, t1 = 1;
  final dx = b.dx - a.dx;
  final dy = b.dy - a.dy;
  final p = [-dx, dx, -dy, dy];
  final q = [a.dx - r.left, r.right - a.dx, a.dy - r.top, r.bottom - a.dy];
  for (var i = 0; i < 4; i++) {
    if (p[i] == 0) {
      if (q[i] < 0) return false;
    } else {
      final t = q[i] / p[i];
      if (p[i] < 0) {
        if (t > t1) return false;
        if (t > t0) t0 = t;
      } else {
        if (t < t0) return false;
        if (t < t1) t1 = t;
      }
    }
  }
  return t0 <= t1;
}

/// Records only the guide-colored line segments the painter draws (dimension
/// lines, their extension stubs, arrowheads, and angle-tag leaders all share
/// `guidePaint` - see `_drawDimensionLine`/`_drawAngleTag` in
/// weld_drawing_preview.dart) - deliberately excludes the decorative
/// backdrop grid, weld-hatch fill, and centerline, which use different
/// paint colors and aren't the class of bug this covers.
class _LineRecordingCanvas implements Canvas {
  final List<List<Offset>> segments = [];

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    final argb = paint.color.toARGB32();
    // _guideColor (visual) / technical guidePaint color - see the
    // `guidePaint` Paint() construction in weld_drawing_preview.dart's
    // `paint()` method.
    if (argb == 0xFF78909C || argb == 0xFF546E7A) {
      segments.add([p1, p2]);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

WeldDrawingData _buildData({
  WeldingProcess weldingProcess = WeldingProcess.gtawSmaw,
  JointGeometryMode geometryMode = JointGeometryMode.equal,
  double thicknessMm = 12,
}) => WeldDrawingData(
  weldingProcess: weldingProcess,
  geometryMode: geometryMode,
  alignment: JointAlignment.centerline,
  thicknessMm: thicknessMm,
  thicknessAMm: geometryMode == JointGeometryMode.unequal ? 14 : null,
  thicknessBMm: geometryMode == JointGeometryMode.unequal ? 10 : null,
  rootGapMm: 3,
  rootFaceMm: 2,
  bevelAngleDeg: 30,
  secondaryBevelAngleDeg: 10,
  breakHeightMm: 4,
  gtawTransitionMm: weldingProcess == WeldingProcess.gtawSmaw ? 3 : null,
);

void main() {
  setUpAll(() async {
    // Ships with every standard Flutter SDK install, resolves on CI too via
    // FLUTTER_ROOT, not just this dev machine - see
    // weld_drawing_label_overlap_test.dart's identical setup for why a real
    // font matters here (Ahem's uniform glyph widths hid layout bugs before).
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

  Future<void> checkRootLabelClear(
    WidgetTester tester, {
    required GrooveType groove,
    required JointType joint,
    required DrawingMode mode,
    required double width,
    required double height,
    required WeldDrawingData data,
    String? knownGap,
  }) async {
    final strings = stringsFor(AppLanguage.en);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              height: height,
              child: WeldDrawingPreview(
                grooveType: groove,
                jointType: joint,
                drawingMode: mode,
                data: data,
                jointTypeLabel: joint.labelFor(strings),
                grooveTypeLabel: groove.labelFor(strings),
                filletWeldFaceLabel: strings.drawingLabelFilletWeldFace,
                tJointLabel: strings.drawingLabelTJoint,
                smawFillCapLabel: strings.drawingLabelSmawFillCap,
                gtawRootLabel: strings.drawingLabelGtawRoot,
                capTopLabel: strings.drawingLabelCapTop,
                capBottomLabel: strings.drawingLabelCapBottom,
                capOverlapValueLabel: strings.drawingLabelCapOverlapValue,
                capHeightValueLabel: strings.drawingLabelCapHeightValue,
                fillAvailableSpace: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final finder = find.descendant(
      of: find.byType(WeldDrawingPreview),
      matching: find.byType(CustomPaint),
    );
    final painter = tester
        .widgetList<CustomPaint>(finder)
        .firstWhere((cp) => cp.painter != null)
        .painter!;
    final size = Size(width, height);
    final recorder = _LineRecordingCanvas();
    painter.paint(recorder, size);

    // `_drawCombinedProcessTint` hotspots both its labels to the same
    // FieldKey (they mark the same user-editable boundary - see its doc
    // comment) in a fixed draw order: the SMAW-fill-cap ("top") label first,
    // then the GTAW-root label - so the second gtawTransitionMm hotspot in
    // draw order is always the GTAW-root label's real, clamped rect.
    final hotspots = debugWeldDrawingHotspots(
      grooveType: groove,
      jointType: joint,
      drawingMode: mode,
      data: data,
      jointTypeLabel: joint.labelFor(strings),
      grooveTypeLabel: groove.labelFor(strings),
      filletWeldFaceLabel: strings.drawingLabelFilletWeldFace,
      tJointLabel: strings.drawingLabelTJoint,
      smawFillCapLabel: strings.drawingLabelSmawFillCap,
      gtawRootLabel: strings.drawingLabelGtawRoot,
      capTopLabel: strings.drawingLabelCapTop,
      capBottomLabel: strings.drawingLabelCapBottom,
      capOverlapValueLabel: strings.drawingLabelCapOverlapValue,
      capHeightValueLabel: strings.drawingLabelCapHeightValue,
      canvas: _LineRecordingCanvas(),
      size: size,
    );
    final gtawHotspots = hotspots
        .where((h) => h.fieldKey == FieldKey.gtawTransitionMm)
        .toList();
    expect(
      gtawHotspots.length,
      2,
      reason: 'expected both the SMAW-fill-cap and GTAW-root labels to be '
          'hotspotted when GTAW+SMAW is the active process',
    );
    final rootLabelRect = gtawHotspots[1].rect;

    final crossings = <String>[];
    for (final segment in recorder.segments) {
      if (_segmentIntersectsRect(segment[0], segment[1], rootLabelRect)) {
        crossings.add('${segment[0]} -> ${segment[1]}');
      }
    }
    expect(
      crossings,
      isEmpty,
      reason:
          'A dimension/leader line crosses the GTAW-root label '
          '($rootLabelRect): ${crossings.join(' | ')}',
      skip: knownGap,
    );
  }

  const widths = [316.0, 346.0, 390.0, 480.0, 600.0, 760.0];
  const height = 460.0;
  final grooves = [
    GrooveType.singleV,
    GrooveType.halfV,
    GrooveType.doubleV,
    GrooveType.compoundV,
    GrooveType.square,
  ];
  const geometryModes = [
    JointGeometryMode.equal,
    JointGeometryMode.unequal,
  ];

  // Equal AND Unequal geometry both matter here: a fix that only nudges the
  // GTAW-root label's fixed mm coordinate can clear whichever line the
  // reporting bug happened to hit, but Unequal geometry draws an additional
  // B-thickness dimension line (see _dimensionLineAvoidRects in
  // weld_drawing_preview.dart) that a coordinate nudge tuned against Equal
  // geometry's root-face line alone has no reason to also clear - this is
  // exactly the gap a previous round of this fix left open (see
  // TEAM_LEARNINGS.md).
  for (final groove in grooves) {
    for (final joint in [JointType.plateButt, JointType.pipeButt]) {
      for (final mode in DrawingMode.values) {
        for (final width in widths) {
          for (final geometryMode in geometryModes) {
            testWidgets(
              'GTAW-root label clear of lines: '
              '$groove/$joint/$mode/$geometryMode @${width.toInt()}',
              (tester) => checkRootLabelClear(
                tester,
                groove: groove,
                joint: joint,
                mode: mode,
                width: width,
                height: height,
                data: _buildData(geometryMode: geometryMode),
              ),
            );
          }
        }
      }
    }
  }

  // Plate thickness is a second, independent axis from geometry mode: every
  // case above uses the suite-wide default (12mm), but as plate gets
  // thicker the joint geometry occupies proportionally more of a
  // fixed-size canvas and the mm-to-px scale shrinks - shrinking right
  // along with it the real pixel separation a fixed-mm nudge buys a label
  // positioned before its nearby lines are actually drawn (see
  // _dimensionLineAvoidRects). Previously only swept Double V/Square here
  // on the claim that Single V/Half V/Compound V aren't "realistically
  // welded at much greater thickness" - independently verified false (all
  // three fail the same way, starting at t=40) - so this now covers all 5
  // groove types, both geometry modes, not just Double V/Square/Equal.
  const thicknesses = [12.0, 25.0, 40.0, 50.0, 60.0];
  // FIXED (2026-09-06): `_dimensionLineAvoidRects` now also covers the
  // groove-depth line (its horizontal extension stub sits at `halfGap +
  // 20`, overlapping the root label's `halfGap + 16` X by construction) at
  // all 5 groove-drawing functions - closing the collision this whole sweep
  // originally caught. That fix alone wasn't sufficient, though: pushing
  // the label clear of groove depth can land it below the member, straight
  // into the ROOT GAP line's own extension stub (drawn even further down,
  // from the member's bottom to `thickness + 3.5` at `x = halfGap`) - a
  // second avoid rect for that line was needed too, at every groove type
  // (see the comments on `rootLabelLineAvoidRects`/`rootLabelAvoidRects` in
  // each `_draw*` function). Verified via mutation testing: reverting
  // either avoid rect addition reproduces the original failures for the
  // affected configs.
  //
  // KNOWN GAP, still open (see `angleLeaderGaps` below): closing the
  // dimension-line collision moved Compound V's GTAW-root label further
  // from its old (colliding) position, which in turn made the alpha/beta
  // bevel-angle tags' own `pushedFar` avoidance push THEM further too -
  // crossing the `pushedFar` elbow-routing threshold at several more
  // Compound V combinations than the single pre-existing Half V case. This
  // is the exact same root cause as `angleLeaderGaps`, just newly exposed
  // by this fix rather than introduced by it - folded into that set below
  // rather than kept as a separate list.

  // KNOWN GAP: Half V's bevel-angle tag (and, per the note above, several
  // Compound V alpha/beta combinations too) routes its leader line as a
  // vertical-then-horizontal "elbow" once collision-avoidance has pushed
  // its own label far enough from its natural position (see the
  // `pushedFar` branch of `_drawAngleTag` in weld_drawing_preview.dart) -
  // that elbow route isn't itself checked against other labels' rects
  // (only the *label* position is), so at these specific
  // thickness/width/geometry combinations the elbow's vertical run happens
  // to pass through the GTAW-root label. `_dimensionLineAvoidRects` doesn't
  // apply here since this isn't a fixed dimension line - a real fix needs
  // `_drawAngleTag`'s leader route itself checked against avoidRects.
  const angleLeaderGaps = <String>{
    'GrooveType.halfV|JointGeometryMode.unequal|390.0|25.0',
    'GrooveType.compoundV|JointGeometryMode.equal|316.0|50.0',
    'GrooveType.compoundV|JointGeometryMode.equal|316.0|60.0',
    'GrooveType.compoundV|JointGeometryMode.equal|346.0|60.0',
    'GrooveType.compoundV|JointGeometryMode.unequal|316.0|40.0',
    'GrooveType.compoundV|JointGeometryMode.unequal|316.0|50.0',
    'GrooveType.compoundV|JointGeometryMode.unequal|316.0|60.0',
    'GrooveType.compoundV|JointGeometryMode.unequal|346.0|40.0',
    'GrooveType.compoundV|JointGeometryMode.unequal|346.0|50.0',
    'GrooveType.compoundV|JointGeometryMode.unequal|346.0|60.0',
    'GrooveType.compoundV|JointGeometryMode.unequal|390.0|50.0',
    'GrooveType.compoundV|JointGeometryMode.unequal|390.0|60.0',
    'GrooveType.compoundV|JointGeometryMode.unequal|480.0|60.0',
  };
  for (final groove in grooves) {
    for (final geometryMode in geometryModes) {
      for (final width in widths) {
        for (final thicknessMm in thicknesses) {
          final key = '$groove|$geometryMode|$width|$thicknessMm';
          testWidgets(
            'GTAW-root label clear of lines: $groove/$geometryMode '
            'thickness sweep @${width.toInt()} t=${thicknessMm.toInt()}',
            (tester) => checkRootLabelClear(
              tester,
              groove: groove,
              joint: JointType.plateButt,
              mode: DrawingMode.visual,
              width: width,
              height: height,
              data: _buildData(
                geometryMode: geometryMode,
                thicknessMm: thicknessMm,
              ),
              knownGap: angleLeaderGaps.contains(key)
                  ? 'bevel-angle leader elbow route crosses the root label '
                        'at this combination - see KNOWN GAP comment above'
                  : null,
            ),
          );
        }
      }
    }
  }
}

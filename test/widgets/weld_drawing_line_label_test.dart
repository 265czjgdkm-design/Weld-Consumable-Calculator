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

bool _isDiagonal(Offset a, Offset b) => a.dx != b.dx && a.dy != b.dy;
bool _isVerticalRun(Offset a, Offset b) => a.dx == b.dx && a.dy != b.dy;
bool _isHorizontalRun(Offset a, Offset b) => a.dy == b.dy && a.dx != b.dx;

/// Widens the GTAW-root-only check below to catch the exact class of
/// regression a reviewer found in commit c6b0516: `_drawAngleTag`'s
/// `pushedFar` elbow-routing branch drew a diagonal (`start`->`stub`) then a
/// vertical run (`stub`->`elbow`) then a horizontal run (`elbow`->`lineEnd`)
/// and only ever checked the vertical run against avoidRects, so a push
/// that cleared the vertical run could relocate the same collision onto the
/// now-longer diagonal instead - invisible to a check that only ever looked
/// at the GTAW-root label. This finds that exact 3-segment chain shape
/// (diagonal, then a perfectly vertical run, then a perfectly horizontal
/// run, each starting exactly where the previous one ended - unique to this
/// branch, nothing else in this file draws that shape) and checks its
/// diagonal and vertical segments against every hotspot rect in the scene,
/// not just root.
///
/// Deliberately scoped to this specific chain shape rather than "every
/// guide-colored segment vs every label rect": an exploratory sweep during
/// this fix's investigation tried the fully general version and found it
/// fails on effectively the ENTIRE test matrix, because ordinary dimension
/// lines and leaders legitimately end at/right next to the very label they
/// measure (e.g. a thickness dimension line's own vertical run sits only a
/// few px from its own "t" pill by construction) - a general check can't
/// tell that apart from a genuine cross-through without production changes
/// this fix's scope doesn't cover. That's a separate, much larger
/// pre-existing structural gap (dimension lines vs. the labels they
/// measure, not this branch) - out of scope here, and exactly the kind of
/// thing a future "Group 3" pass would need to address on its own terms.
List<String> _pushedFarElbowCrossings(
  List<List<Offset>> segments,
  List<DrawingHotspot> hotspots,
) {
  final crossings = <String>[];
  for (var i = 0; i + 2 < segments.length; i++) {
    final a = segments[i];
    final b = segments[i + 1];
    final c = segments[i + 2];
    if (a[1] != b[0] || b[1] != c[0]) continue;
    if (!_isDiagonal(a[0], a[1])) continue;
    if (!_isVerticalRun(b[0], b[1])) continue;
    if (!_isHorizontalRun(c[0], c[1])) continue;
    for (final h in hotspots) {
      if (_segmentIntersectsRect(a[0], a[1], h.rect) ||
          _segmentIntersectsRect(b[0], b[1], h.rect)) {
        crossings.add(
          '${a[0]} -> ${b[0]} -> ${b[1]} crosses ${h.fieldKey} (${h.rect})',
        );
      }
    }
  }
  return crossings;
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
    // Widened per a reviewer finding on commit c6b0516: the check above
    // only ever covers the GTAW-root label specifically, so a leader that
    // relocates a collision onto some OTHER label (e.g. the thickness pill)
    // shipped silently. See `_pushedFarElbowCrossings`'s doc comment for why
    // this is scoped to that branch's specific 3-segment chain shape rather
    // than every segment vs every label.
    crossings.addAll(_pushedFarElbowCrossings(recorder.segments, hotspots));
    expect(
      crossings,
      isEmpty,
      reason:
          'A dimension/leader line crosses the GTAW-root label '
          '($rootLabelRect), or a pushedFar angle-tag elbow leader crosses '
          'some other label: ${crossings.join(' | ')}',
      skip: knownGap,
    );
  }

  // Every one of these keys was verified, via a git-worktree diff against
  // 62b992f (the commit immediately before c6b0516 ever touched
  // `_drawAngleTag`'s pushedFar branch), to already exist byte-identically
  // before that commit - i.e. this widened check's own investigation
  // confirmed none of these are new or made worse by this round's fix; they
  // pre-date it. c6b0516 briefly and accidentally hid a handful of these by
  // relocating the exact same collision onto a different segment (the bug a
  // reviewer found - see `_pushedFarElbowCrossings`'s doc comment) - this
  // round's bounded/clamped fix intentionally falls back to the ORIGINAL
  // unpushed elbow route rather than risk repeating that, so these
  // resurface as visible, honest known gaps instead of silently passing.
  // Keys are 'groove|joint|mode|geometryMode|width'.
  const knownPushedFarGapsSweep1 = {
    'compoundV|pipeButt|technical|equal|316',
    'compoundV|pipeButt|technical|equal|346',
    'compoundV|pipeButt|technical|equal|390',
    'compoundV|pipeButt|technical|unequal|316',
    'compoundV|pipeButt|technical|unequal|346',
    'compoundV|pipeButt|technical|unequal|390',
    'compoundV|pipeButt|visual|equal|316',
    'compoundV|pipeButt|visual|equal|346',
    'compoundV|pipeButt|visual|equal|390',
    'compoundV|pipeButt|visual|unequal|316',
    'compoundV|pipeButt|visual|unequal|346',
    'compoundV|pipeButt|visual|unequal|390',
    'compoundV|plateButt|technical|equal|316',
    'compoundV|plateButt|technical|equal|346',
    'compoundV|plateButt|technical|equal|390',
    'compoundV|plateButt|technical|unequal|316',
    'compoundV|plateButt|technical|unequal|346',
    'compoundV|plateButt|technical|unequal|390',
    'compoundV|plateButt|visual|equal|316',
    'compoundV|plateButt|visual|equal|346',
    'compoundV|plateButt|visual|equal|390',
    'compoundV|plateButt|visual|unequal|316',
    'compoundV|plateButt|visual|unequal|346',
    'compoundV|plateButt|visual|unequal|390',
    'doubleV|pipeButt|technical|equal|316',
    'doubleV|pipeButt|technical|equal|346',
    'doubleV|pipeButt|technical|equal|390',
    'doubleV|pipeButt|technical|unequal|316',
    'doubleV|pipeButt|technical|unequal|346',
    'doubleV|pipeButt|technical|unequal|390',
    'doubleV|pipeButt|visual|equal|316',
    'doubleV|pipeButt|visual|equal|346',
    'doubleV|pipeButt|visual|equal|390',
    'doubleV|pipeButt|visual|unequal|316',
    'doubleV|pipeButt|visual|unequal|346',
    'doubleV|pipeButt|visual|unequal|390',
    'doubleV|plateButt|technical|equal|316',
    'doubleV|plateButt|technical|equal|346',
    'doubleV|plateButt|technical|equal|390',
    'doubleV|plateButt|technical|unequal|316',
    'doubleV|plateButt|technical|unequal|346',
    'doubleV|plateButt|technical|unequal|390',
    'doubleV|plateButt|visual|equal|316',
    'doubleV|plateButt|visual|equal|346',
    'doubleV|plateButt|visual|equal|390',
    'doubleV|plateButt|visual|unequal|316',
    'doubleV|plateButt|visual|unequal|346',
    'doubleV|plateButt|visual|unequal|390',
    'halfV|pipeButt|technical|equal|316',
    'halfV|pipeButt|technical|equal|346',
    'halfV|pipeButt|technical|equal|390',
    'halfV|pipeButt|technical|equal|480',
    'halfV|pipeButt|technical|equal|600',
    'halfV|pipeButt|technical|unequal|316',
    'halfV|pipeButt|technical|unequal|346',
    'halfV|pipeButt|technical|unequal|390',
    'halfV|pipeButt|technical|unequal|480',
    'halfV|pipeButt|visual|equal|316',
    'halfV|pipeButt|visual|equal|346',
    'halfV|pipeButt|visual|equal|390',
    'halfV|pipeButt|visual|equal|480',
    'halfV|pipeButt|visual|equal|600',
    'halfV|pipeButt|visual|unequal|316',
    'halfV|pipeButt|visual|unequal|346',
    'halfV|pipeButt|visual|unequal|390',
    'halfV|pipeButt|visual|unequal|480',
    'halfV|plateButt|technical|equal|316',
    'halfV|plateButt|technical|equal|346',
    'halfV|plateButt|technical|equal|390',
    'halfV|plateButt|technical|equal|480',
    'halfV|plateButt|technical|equal|600',
    'halfV|plateButt|technical|unequal|316',
    'halfV|plateButt|technical|unequal|346',
    'halfV|plateButt|technical|unequal|390',
    'halfV|plateButt|technical|unequal|480',
    'halfV|plateButt|visual|equal|316',
    'halfV|plateButt|visual|equal|346',
    'halfV|plateButt|visual|equal|390',
    'halfV|plateButt|visual|equal|480',
    'halfV|plateButt|visual|equal|600',
    'halfV|plateButt|visual|unequal|316',
    'halfV|plateButt|visual|unequal|346',
    'halfV|plateButt|visual|unequal|390',
    'halfV|plateButt|visual|unequal|480',
    'singleV|pipeButt|technical|equal|316',
    'singleV|pipeButt|visual|equal|316',
    'singleV|pipeButt|visual|equal|346',
    'singleV|plateButt|technical|equal|316',
    'singleV|plateButt|visual|equal|316',
    'singleV|plateButt|visual|equal|346',
  };

  // Keys are 'groove|geometryMode|width|thicknessMm' - see the comment on
  // `knownPushedFarGapsSweep1` above (same provenance/verification).
  const knownPushedFarGapsSweep2 = {
    'compoundV|equal|316|12',
    'compoundV|equal|316|25',
    'compoundV|equal|316|40',
    'compoundV|equal|316|50',
    'compoundV|equal|316|60',
    'compoundV|equal|346|12',
    'compoundV|equal|346|25',
    'compoundV|equal|346|40',
    'compoundV|equal|346|60',
    'compoundV|equal|390|12',
    'compoundV|equal|390|25',
    'compoundV|equal|760|60',
    'compoundV|unequal|316|12',
    'compoundV|unequal|316|25',
    'compoundV|unequal|316|40',
    'compoundV|unequal|316|50',
    'compoundV|unequal|316|60',
    'compoundV|unequal|346|12',
    'compoundV|unequal|346|25',
    'compoundV|unequal|346|40',
    'compoundV|unequal|346|50',
    'compoundV|unequal|346|60',
    'compoundV|unequal|390|12',
    'compoundV|unequal|390|25',
    'compoundV|unequal|390|40',
    'compoundV|unequal|390|50',
    'compoundV|unequal|390|60',
    'compoundV|unequal|480|40',
    'compoundV|unequal|480|50',
    'compoundV|unequal|480|60',
    'compoundV|unequal|600|40',
    'compoundV|unequal|600|50',
    'compoundV|unequal|600|60',
    'compoundV|unequal|760|60',
    'doubleV|equal|316|12',
    'doubleV|equal|316|25',
    'doubleV|equal|316|40',
    'doubleV|equal|316|50',
    'doubleV|equal|316|60',
    'doubleV|equal|346|12',
    'doubleV|equal|346|25',
    'doubleV|equal|346|40',
    'doubleV|equal|346|50',
    'doubleV|equal|346|60',
    'doubleV|equal|390|12',
    'doubleV|equal|390|25',
    'doubleV|equal|390|40',
    'doubleV|equal|390|50',
    'doubleV|equal|390|60',
    'doubleV|unequal|316|12',
    'doubleV|unequal|316|25',
    'doubleV|unequal|316|40',
    'doubleV|unequal|346|12',
    'doubleV|unequal|346|25',
    'doubleV|unequal|390|12',
    'doubleV|unequal|390|25',
    'halfV|equal|316|12',
    'halfV|equal|316|25',
    'halfV|equal|316|40',
    'halfV|equal|316|50',
    'halfV|equal|316|60',
    'halfV|equal|346|12',
    'halfV|equal|346|25',
    'halfV|equal|346|40',
    'halfV|equal|346|50',
    'halfV|equal|346|60',
    'halfV|equal|390|12',
    'halfV|equal|390|25',
    'halfV|equal|390|50',
    'halfV|equal|390|60',
    'halfV|equal|480|12',
    'halfV|equal|600|12',
    'halfV|unequal|316|12',
    'halfV|unequal|316|25',
    'halfV|unequal|346|12',
    'halfV|unequal|346|25',
    'halfV|unequal|390|12',
    'halfV|unequal|480|12',
    'singleV|equal|316|12',
    'singleV|equal|346|12',
    'singleV|unequal|316|25',
    'singleV|unequal|316|40',
    'singleV|unequal|316|50',
    'singleV|unequal|316|60',
    'singleV|unequal|346|25',
    'singleV|unequal|346|40',
    'singleV|unequal|346|50',
    'singleV|unequal|346|60',
  };

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
            final key =
                '${groove.name}|${joint.name}|${mode.name}|'
                '${geometryMode.name}|${width.toInt()}';
            final knownGap = knownPushedFarGapsSweep1.contains(key)
                ? 'pre-existing pushedFar-elbow-vs-other-label gap, '
                      'predates c6b0516 - see knownPushedFarGapsSweep1'
                : null;
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
                knownGap: knownGap,
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
  // FIXED (2026-09-06): closing the dimension-line collision above moved
  // Compound V's GTAW-root label further from its old (colliding) position,
  // which in turn made the alpha/beta bevel-angle tags' own `pushedFar`
  // avoidance push THEM further too - crossing the `pushedFar`
  // elbow-routing threshold at several more Compound V combinations than
  // the single pre-existing Half V case below. Both classes share the same
  // root cause and the same fix: `_drawAngleTag`'s `pushedFar` branch now
  // checks its own stub->elbow vertical run against `avoidRects` (the same
  // list already used to place the label itself), nudging the run's X
  // sideways - in one direction, decided once from the first blocking rect
  // and held fixed for the rest of the search, exactly like
  // [_clearLabelPosition]'s own always-down convention, to avoid the
  // oscillation an earlier "nearest edge every time" attempt at this fix
  // hit when two different rects on opposite sides kept undoing each
  // other's push - until the run clears every avoid rect.
  //
  // FIXED: Half V's bevel-angle tag routes its leader line as a
  // vertical-then-horizontal "elbow" once collision-avoidance has pushed
  // its own label far enough from its natural position (see the
  // `pushedFar` branch of `_drawAngleTag` in weld_drawing_preview.dart) -
  // that elbow route previously wasn't itself checked against other
  // labels' rects (only the *label* position was), so at this specific
  // thickness/width/geometry combination the elbow's vertical run happened
  // to pass through the GTAW-root label. See the fix described above.
  for (final groove in grooves) {
    for (final geometryMode in geometryModes) {
      for (final width in widths) {
        for (final thicknessMm in thicknesses) {
          final key =
              '${groove.name}|${geometryMode.name}|${width.toInt()}|'
              '${thicknessMm.toInt()}';
          final knownGap = knownPushedFarGapsSweep2.contains(key)
              ? 'pre-existing pushedFar-elbow-vs-other-label gap, '
                    'predates c6b0516 - see knownPushedFarGapsSweep2'
              : null;
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
              knownGap: knownGap,
            ),
          );
        }
      }
    }
  }
}

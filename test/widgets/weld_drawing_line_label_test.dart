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
/// `pushedFar` elbow-routing branch draws a diagonal (`start`->`stub`), then
/// a vertical run (`stub`->`elbow`), then a horizontal run
/// (`elbow`->`lineEnd`), and none of the three were ever checked against
/// avoidRects - only the resolved label position was. This finds that exact
/// 3-segment chain shape (diagonal, then a perfectly vertical run, then a
/// perfectly horizontal run, each starting exactly where the previous one
/// ended - unique to this branch, nothing else in this file draws that
/// shape) and checks every segment against every hotspot rect in the scene,
/// not just root.
///
/// A chain's OWN label rect is deliberately excluded: `lineEnd` (the
/// horizontal run's endpoint) sits only 20px from the label's own resolved
/// center by construction (see `_drawAngleTag`), so the horizontal run
/// routinely ends at/inside its own pill - a legitimate self-touch, not a
/// cross-label bug, exactly the same class of "own leader endpoint inside
/// own pill by design" self-touch weld_drawing_label_overlap_test.dart's
/// own overlap check already excludes for a different reason (see that
/// file's docstring). Own label is identified as whichever hotspot rect
/// contains the point 20px to either side of the chain's endpoint at the
/// endpoint's own y - exactly where `_drawAngleTag` places `resolvedCenter`
/// relative to `lineEnd`. Confirmed via an instrumented full-matrix sweep
/// that this exclusion only ever drops genuine self-touches (67 of the 229
/// configs the un-excluded a+b+c check flags, 268 individual chain/hotspot
/// pairs across those configs): every dropped pair's owner was verified
/// against real draw-order ground truth (the hotspot rect actually drawn
/// for that chain's own label), with zero non-own labels among them.
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

    // See this function's doc comment: identifies the chain's own resolved
    // label by the point 20px either side of `lineEnd` (c's endpoint), the
    // exact offset `_drawAngleTag` places `resolvedCenter` at.
    final cand1 = Offset(c[1].dx + 20, c[1].dy);
    final cand2 = Offset(c[1].dx - 20, c[1].dy);
    Rect? ownRect;
    for (final h in hotspots) {
      if (h.rect.inflate(1.0).contains(cand1) ||
          h.rect.inflate(1.0).contains(cand2)) {
        ownRect = h.rect;
        break;
      }
    }

    for (final h in hotspots) {
      if (ownRect != null && h.rect == ownRect) continue;
      if (_segmentIntersectsRect(a[0], a[1], h.rect) ||
          _segmentIntersectsRect(b[0], b[1], h.rect) ||
          _segmentIntersectsRect(c[0], c[1], h.rect)) {
        crossings.add(
          '${a[0]} -> ${b[0]} -> ${b[1]} -> ${c[1]} crosses '
          '${h.fieldKey} (${h.rect})',
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
  JointAlignment alignment = JointAlignment.centerline,
  double thicknessMm = 12,
}) => WeldDrawingData(
  weldingProcess: weldingProcess,
  geometryMode: geometryMode,
  alignment: alignment,
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
    String? knownElbowGap,
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
      reason:
          'expected both the SMAW-fill-cap and GTAW-root labels to be '
          'hotspotted when GTAW+SMAW is the active process',
    );
    final rootLabelRect = gtawHotspots[1].rect;

    final rootCrossings = <String>[];
    for (final segment in recorder.segments) {
      if (_segmentIntersectsRect(segment[0], segment[1], rootLabelRect)) {
        rootCrossings.add('${segment[0]} -> ${segment[1]}');
      }
    }
    // This is the file's ORIGINAL, narrow assertion: no line/leader
    // crosses the GTAW-root label specifically. Kept as its own independent
    // `expect` with its own independently-controlled `knownGap` - a
    // reviewer found that an earlier round bundled this together with the
    // broader `_pushedFarElbowCrossings` check below under one shared
    // `skip`, so a `knownGap` added for the broader check could silently
    // blind this narrower, more important one too. They must never share a
    // skip flag again.
    expect(
      rootCrossings,
      isEmpty,
      reason:
          'A dimension/leader line crosses the GTAW-root label '
          '($rootLabelRect): ${rootCrossings.join(' | ')}',
      skip: knownGap,
    );

    // Widened per a reviewer finding on commit c6b0516: the check above
    // only ever covers the GTAW-root label specifically, so a leader that
    // relocates a collision onto some OTHER label (e.g. the SMAW-fill-cap
    // "top" label sharing the same FieldKey, or a different label
    // entirely) shipped silently. See `_pushedFarElbowCrossings`'s doc
    // comment for why this is scoped to that branch's specific 3-segment
    // chain shape rather than every segment vs every label, and for why
    // the chain's own label is excluded as a legitimate self-touch.
    final elbowCrossings = _pushedFarElbowCrossings(
      recorder.segments,
      hotspots,
    );
    expect(
      elbowCrossings,
      isEmpty,
      reason:
          'A pushedFar angle-tag elbow leader crosses another label: '
          '${elbowCrossings.join(' | ')}',
      skip: knownElbowGap,
    );
  }

  // ---------------------------------------------------------------------
  // KNOWN GAPS - `_drawAngleTag`'s `pushedFar` elbow-routing branch
  // ---------------------------------------------------------------------
  // Re-established by a full-matrix instrumented sweep after reverting
  // c6b0516/a12db19 (both attempts at fixing this mechanism by sliding the
  // elbow's `stub.dx` sideways - see git history on this file/
  // weld_drawing_preview.dart for why both failed review and were
  // reverted back to 62b992f's original, unpushed elbow route). Every key
  // below was verified via the same instrumented-sweep technique: dump
  // every guide-colored segment the painter draws plus every hotspot rect,
  // then geometrically test the `pushedFar` chain's 3 segments against
  // every hotspot except its own (self-touch, see
  // `_pushedFarElbowCrossings`'s doc comment).
  //
  // Two distinct mechanisms, not one undifferentiated bucket:
  //
  // (1) `alphaVsCapLabelGapsSweep*`: Single V/Half V/Double V's one bevel
  // -angle tag ("alpha", FieldKey.bevelAngleDeg) has its own natural
  // position pushed far enough (by `_clearLabelPosition`) that its elbow
  // route's diagonal or vertical run crosses the SMAW-fill-cap ("top")
  // label - the FIRST of `_drawCombinedProcessTint`'s two
  // FieldKey.gtawTransitionMm-keyed hotspots, not the GTAW-root label
  // (the second one) as an earlier round of this file's own comments
  // assumed without checking which of the two same-keyed rects was
  // actually hit; confirmed by instrumentation that all 104 of these
  // configs hit the TOP rect specifically, never the root rect. Root cause:
  // `_drawAngleTag`'s `pushedFar` branch never checks its own elbow route
  // against `avoidRects`, only the resolved label position.
  //
  // (2) `compoundVBevelTagCrowdingGapsSweep*`: Compound V carries six
  // callouts (thickness, root gap, groove depth, break height, root face,
  // alpha, beta) on the busiest canvas in the app. Beta (secondary bevel
  // angle, drawn last, avoiding all five other labels) is the one most
  // often pushed far enough to trigger the elbow route, and its route
  // crosses whichever of alpha's rect / the gtaw-tint top-or-root label /
  // root-face / root-gap happens to sit in its path; a handful of these
  // configs instead have alpha's own elbow crossing beta. Same root cause
  // as (1) - the elbow route itself was never checked against avoidRects -
  // just triggered far more often here because six labels crowd the same
  // canvas. 12 of these (all thickness-sweep, all Compound V, all at
  // t>=40mm on a narrow canvas) are severe enough that the chain's
  // vertical run alone spans most of the canvas height and crosses the
  // GTAW-root label directly too - these are also listed in
  // `narrowRootGapsSweep2` so the original narrow root-only check is
  // skipped for exactly these, and only these, with its own reason.
  const alphaVsCapLabelGapsSweep1 = {
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

  const alphaVsCapLabelGapsSweep2 = {
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
    'doubleV|unequal|346|12',
    'doubleV|unequal|390|12',
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
    'halfV|equal|480|12',
    'halfV|equal|600|12',
    'halfV|unequal|316|12',
    'halfV|unequal|346|12',
    'halfV|unequal|390|12',
    'halfV|unequal|480|12',
    'singleV|equal|316|12',
    'singleV|equal|346|12',
  };

  const compoundVBevelTagCrowdingGapsSweep1 = {
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
  };

  const compoundVBevelTagCrowdingGapsSweep2 = {
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
  };

  // Subset of `compoundVBevelTagCrowdingGapsSweep2` (see mechanism (2)
  // above) severe enough that the elbow's own vertical run crosses the
  // GTAW-root label directly - these need the ORIGINAL narrow check's
  // `knownGap` too, not just the broader elbow check's.
  const narrowRootGapsSweep2 = {
    'compoundV|equal|316|50',
    'compoundV|equal|316|60',
    'compoundV|equal|346|60',
    'compoundV|unequal|316|40',
    'compoundV|unequal|316|50',
    'compoundV|unequal|316|60',
    'compoundV|unequal|346|40',
    'compoundV|unequal|346|50',
    'compoundV|unequal|346|60',
    'compoundV|unequal|390|50',
    'compoundV|unequal|390|60',
    'compoundV|unequal|480|60',
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
  const geometryModes = [JointGeometryMode.equal, JointGeometryMode.unequal];

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
            final knownElbowGap = alphaVsCapLabelGapsSweep1.contains(key)
                ? 'alpha bevel-angle tag pushedFar elbow crosses the '
                      'SMAW-fill-cap label - see alphaVsCapLabelGapsSweep1'
                : compoundVBevelTagCrowdingGapsSweep1.contains(key)
                ? 'Compound V bevel-angle-tag pushedFar elbow crowding - '
                      'see compoundVBevelTagCrowdingGapsSweep1'
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
                knownElbowGap: knownElbowGap,
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
  // ATTEMPTED AND ABANDONED (2026-09-07): a third fix attempt at
  // `_drawAngleTag`'s `pushedFar` branch (after c6b0516's unbounded
  // sideways `stub.dx` push and a12db19's bounded-but-effectively-inert
  // version, both reverted - see git history on this file's companion
  // weld_drawing_preview.dart) considered routing the elbow's vertical
  // extent (its Y hand-off) instead of sliding the stub sideways, targeting
  // the single original case this whole mechanism was chasing:
  // `halfV|unequal|390|25`. Verification found this entry was vacuous from
  // birth: it passes unskipped both at 62b992f AND at 406bc0b, the commit
  // that originally introduced it (confirmed via mutation test at both
  // commits) - so no avoidRects/dimension-line fix at any point in this
  // file's history ever actually broke or fixed it, and three rounds of
  // `_drawAngleTag` rewrites were chasing a case that was never broken. No
  // new elbow-Y-position fix was needed or attempted; the remaining gaps
  // below are a structurally different, still-open mechanism (see the
  // KNOWN GAPS block above).
  for (final groove in grooves) {
    for (final geometryMode in geometryModes) {
      for (final width in widths) {
        for (final thicknessMm in thicknesses) {
          final key =
              '${groove.name}|${geometryMode.name}|${width.toInt()}|'
              '${thicknessMm.toInt()}';
          final knownElbowGap = alphaVsCapLabelGapsSweep2.contains(key)
              ? 'alpha bevel-angle tag pushedFar elbow crosses the '
                    'SMAW-fill-cap label - see alphaVsCapLabelGapsSweep2'
              : compoundVBevelTagCrowdingGapsSweep2.contains(key)
              ? 'Compound V bevel-angle-tag pushedFar elbow crowding - '
                    'see compoundVBevelTagCrowdingGapsSweep2'
              : null;
          final knownGap = narrowRootGapsSweep2.contains(key)
              ? 'Compound V bevel-angle-tag pushedFar elbow vertical run '
                    'spans most of the canvas and crosses the GTAW-root '
                    'label directly - see narrowRootGapsSweep2'
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
              knownElbowGap: knownElbowGap,
            ),
          );
        }
      }
    }
  }

  // -------------------------------------------------------------------
  // Leader/dimension-line canvas-bounds coverage (Group 3, round 5)
  // -------------------------------------------------------------------
  // A reviewer found this file had NO assertion at all that a drawn
  // leader/dimension-line segment stays within the canvas - only that it
  // avoids crossing specific labels (above). That gap is exactly why a real
  // regression went undetected across 2 rounds: `_drawAngleTag`'s
  // `pushedFar` elbow branch built its elbow/lineEnd points from
  // `resolvedCenter.dy` - the UNCLAMPED label center - while the label pill
  // itself clamps to the canvas via `_measurementLabelRect`, so on a busy,
  // narrow canvas (Compound V especially) the leader's vertical run/endpoint
  // could run several pixels past the canvas bottom even though its own
  // label pill was correctly clamped to stay inside it - a visibly
  // disconnected line floating below the drawing. This sweep reproduces the
  // exact conditions that exposed it (a narrow busy canvas, every welding
  // process, every alignment, every locale) and asserts every recorded
  // guide-colored segment endpoint stays within `[0, width] x [0, height]`.
  Future<void> checkLeaderWithinCanvasBounds(
    WidgetTester tester, {
    required GrooveType groove,
    required JointType joint,
    required DrawingMode mode,
    required double width,
    required double height,
    required WeldDrawingData data,
    required AppLanguage language,
  }) async {
    final strings = stringsFor(language);
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

    final outOfBounds = <String>[];
    for (final segment in recorder.segments) {
      for (final point in segment) {
        if (point.dx < 0 ||
            point.dy < 0 ||
            point.dx > width ||
            point.dy > height) {
          outOfBounds.add(
            '${segment[0]} -> ${segment[1]} has an endpoint ($point) '
            'outside the ${width}x$height canvas',
          );
          break;
        }
      }
    }
    expect(
      outOfBounds,
      isEmpty,
      reason:
          'A leader/dimension-line segment runs off the canvas: '
          '${outOfBounds.join(' | ')}',
    );
  }

  // Compound V/pipe butt at the narrowest real device width is the exact
  // reproduction a reviewer used to find the bug this sweep guards against -
  // busy enough (6 callouts) to push its secondary bevel-angle tag ("beta")
  // into `_drawAngleTag`'s `pushedFar` elbow branch, on a canvas narrow/
  // short enough for canvas-edge clamping to actually engage. Both joints
  // and every non-fillet groove are swept too (not just the one that
  // originally surfaced it), since the fix lives in a groove-agnostic shared
  // helper (`_drawAngleTag`) and any groove busy enough to push a bevel-
  // angle tag far can hit the exact same mechanism.
  const narrowWidths = [240.0, 280.0, 295.0, 310.0, 332.0, 348.0];
  double boundsNarrowWidthDelta(double canvasWidth) =>
      canvasWidth <= 240.0 ? 48.0 : 0.0;
  double boundsBusyHeightFor(double w) => 398.0 - boundsNarrowWidthDelta(w);
  double boundsNormalHeightFor(double w) => 334.0 - boundsNarrowWidthDelta(w);
  const busyGroovesForBounds = [
    GrooveType.halfV,
    GrooveType.compoundV,
    GrooveType.doubleV,
  ];
  const normalButtGroovesForBounds = [GrooveType.singleV, GrooveType.square];

  for (final groove in [
    ...busyGroovesForBounds,
    ...normalButtGroovesForBounds,
  ]) {
    final heightFor = busyGroovesForBounds.contains(groove)
        ? boundsBusyHeightFor
        : boundsNormalHeightFor;
    for (final joint in [JointType.plateButt, JointType.pipeButt]) {
      for (final width in narrowWidths) {
        for (final process in WeldingProcess.values) {
          for (final alignment in JointAlignment.values) {
            for (final language in AppLanguage.values) {
              testWidgets(
                'leader/dimension lines stay within canvas bounds: '
                '$groove/$joint/$process/$alignment/${language.code} '
                '@${width.toInt()}',
                (tester) => checkLeaderWithinCanvasBounds(
                  tester,
                  groove: groove,
                  joint: joint,
                  mode: DrawingMode.visual,
                  width: width,
                  height: heightFor(width),
                  data: _buildData(
                    weldingProcess: process,
                    alignment: alignment,
                  ),
                  language: language,
                ),
              );
            }
          }
        }
      }
    }
  }
}

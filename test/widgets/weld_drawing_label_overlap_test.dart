// Regression coverage for a label-collision bug that has recurred across
// this file's history (see TEAM_LEARNINGS.md, 2026-08-25 entries): several
// groove types pack more dimension/angle callouts into the compact mobile
// drawing card than fit without care, and every previous "fix" was verified
// with either mm-space math or flutter_test's default Ahem font (every
// glyph exactly `fontSize` wide, ~1.6-1.9x too wide vs real fonts), which
// let broken layouts read as fixed. This test renders the real painter,
// with a real Roboto font loaded from the Flutter SDK cache, and asserts
// none of the drawn label pills actually overlap - the same check a human
// would make by looking at a real device. Covers every groove type.
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/ui/widgets/weld_drawing_preview.dart';

/// Captures every label-pill background the painter draws (see
/// `_drawTechnicalLabel`/`_drawSoftLabel` in weld_drawing_preview.dart -
/// their fill colors, 0xF2FFFFFF and 0xCCFFFFFF for secondary pills and
/// 0xFF2B3538 for primary pills (`_primaryFillColor`), are what this filters
/// on; other drawRRect calls in that file are the canvas backdrop frame, not
/// labels) and no-ops every other canvas call - this only needs the real
/// geometry, not real pixels. Was missing the primary color until a reviewer
/// caught it: without it this test was blind to every primary (bigger, since
/// the primary/secondary hierarchy pass) label pill, exactly the ones most
/// likely to newly collide with something after growing in size.
class _RecordingCanvas implements Canvas {
  final List<Rect> fillRects = [];

  @override
  void drawRRect(RRect rrect, Paint paint) {
    final argb = paint.color.toARGB32();
    if (argb == 0xF2FFFFFF || argb == 0xCCFFFFFF || argb == 0xFF2B3538) {
      fillRects.add(rrect.outerRect);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

List<String> _overlapDescriptions(List<Rect> rects) {
  final out = <String>[];
  for (var i = 0; i < rects.length; i++) {
    for (var j = i + 1; j < rects.length; j++) {
      if (rects[i].overlaps(rects[j])) {
        final ix = rects[i].intersect(rects[j]);
        out.add(
          '${rects[i]} overlaps ${rects[j]} by '
          '${ix.width.toStringAsFixed(1)}x${ix.height.toStringAsFixed(1)}',
        );
      }
    }
  }
  return out;
}

/// Builds a representative [WeldDrawingData] for a given process/geometry
/// combination, using distinct A/B thickness values in Unequal mode (14 vs
/// 10mm, matching the reviewer audit's own example) so the "B ... mm" label
/// is never accidentally identical to the "A ... mm"/thickness label.
WeldDrawingData _buildData({
  required WeldingProcess weldingProcess,
  JointGeometryMode geometryMode = JointGeometryMode.equal,
  JointAlignment alignment = JointAlignment.centerline,
  double thicknessMm = 12,
}) {
  return WeldDrawingData(
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
    capOverlapMm: 2,
    capHeightMm: 2,
    legSizeMm: 6,
    pipeOdMm: 168.3,
    gtawTransitionMm: weldingProcess == WeldingProcess.gtawSmaw ? 3 : null,
  );
}

Future<List<Rect>> _renderLabelRects(
  WidgetTester tester, {
  required JointType jointType,
  required GrooveType grooveType,
  required DrawingMode drawingMode,
  required Size canvasSize,
  required L10nStrings strings,
  WeldDrawingData? data,
  bool fillAvailableSpace = true,
}) async {
  final resolvedData = data ?? _buildData(weldingProcess: WeldingProcess.gtaw);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: canvasSize.width,
            height: canvasSize.height,
            child: WeldDrawingPreview(
              grooveType: grooveType,
              jointType: jointType,
              drawingMode: drawingMode,
              data: resolvedData,
              jointTypeLabel: jointType.labelFor(strings),
              grooveTypeLabel: grooveType.labelFor(strings),
              filletWeldFaceLabel: strings.drawingLabelFilletWeldFace,
              tJointLabel: strings.drawingLabelTJoint,
              smawFillCapLabel: strings.drawingLabelSmawFillCap,
              gtawRootLabel: strings.drawingLabelGtawRoot,
              capTopLabel: strings.drawingLabelCapTop,
              capBottomLabel: strings.drawingLabelCapBottom,
              capOverlapValueLabel: strings.drawingLabelCapOverlapValue,
              capHeightValueLabel: strings.drawingLabelCapHeightValue,
              fillAvailableSpace: fillAvailableSpace,
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
  final recorder = _RecordingCanvas();
  painter.paint(recorder, canvasSize);
  return recorder.fillRects;
}

void _expectNoOverlap(
  String description, {
  required JointType jointType,
  required GrooveType grooveType,
  required DrawingMode drawingMode,
  required Size canvasSize,
  required AppLanguage language,
  WeldDrawingData? data,
  bool fillAvailableSpace = true,
  // Documents a currently-known, still-real gap this test would otherwise
  // catch (see the "KNOWN GAP" comments at each call site that sets this) -
  // `skip` rather than silently dropping the case, so the gap stays visible
  // in test output and isn't confused with something this round claims to
  // have fixed.
  String? knownGap,
}) {
  final title = knownGap == null
      ? 'no label overlap: $description'
      : 'no label overlap: $description (KNOWN GAP: $knownGap)';
  testWidgets(title, (tester) async {
    final rects = await _renderLabelRects(
      tester,
      jointType: jointType,
      grooveType: grooveType,
      drawingMode: drawingMode,
      canvasSize: canvasSize,
      strings: stringsFor(language),
      data: data,
      fillAvailableSpace: fillAvailableSpace,
    );
    final overlaps = _overlapDescriptions(rects);
    expect(
      overlaps,
      isEmpty,
      reason: 'Label rects overlap: ${overlaps.join(' | ')}',
    );
  }, skip: knownGap != null);
}

void main() {
  setUpAll(() async {
    // Ships with every standard Flutter SDK install (used for the engine's
    // own default-icon fallback rendering), so this resolves on CI too via
    // FLUTTER_ROOT, not just this dev machine.
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

  // Chrome measured directly against the real wizard Step 2 screen (not
  // estimated): horizontal chrome (card padding/margins around the drawing
  // canvas) is a flat 80px at every common device width, so these canvas
  // widths map directly to real common device widths: 320->240, 360->280,
  // 375->295, 390->310, 412->332, 428->348. The heights below (458/354/280,
  // plus their extraBusy counterparts 534/434) are this suite's existing
  // already-verified-safe per-tier canvas heights, unchanged for every one
  // of those widths - except the narrowest (320pt/240px canvas), where the
  // reviewer measured the real card header wrapping to two lines, pushing
  // vertical chrome ~42-48px higher there than at any wider width; rather
  // than reusing the same constant at that width too, [_narrowWidthDelta]
  // subtracts that same real measured penalty from it specifically.
  // Group 4 (prior session): busy/non-extraBusy bumped +60px (398->458 -
  // Russian's longer Double V both-faces cap labels needed more than
  // English's same combo did) and non-busy/non-extraBusy bumped +20px
  // (334->354), to match calculator_page.dart's `_narrowDrawingHeight`
  // tier-ceiling raise - see that function's own doc comment for the spike
  // measurements behind the exact deltas.
  // Follow-up round (this session): Group 4's fix was only verified at
  // `thicknessMm: 12` - a reviewer found the same canvas-bottom-clamp
  // mechanism recurs at 320pt/240px for realistic thicknesses away from
  // 12mm (thin plate ~3-11mm and thick plate ~45-60mm, both directions).
  // Bumped every tier by the worst-case-needed extra height (measured via
  // a thickness-sweeping throwaway spike, see calculator_page.dart's
  // `_narrowDrawingHeight` doc comment for the exact figures) plus a 10px
  // margin: non-busy/non-extraBusy +80px (354->434), non-busy/extraBusy
  // +90px (434->524), busy/non-extraBusy +110px (458->568), busy/extraBusy
  // +110px (534->644).
  const widths = [240.0, 280.0, 295.0, 310.0, 332.0, 348.0];
  double narrowWidthDelta(double canvasWidth) =>
      canvasWidth <= 240.0 ? 48.0 : 0.0;
  double busyHeightFor(double canvasWidth) =>
      568.0 - narrowWidthDelta(canvasWidth);
  double normalHeightFor(double canvasWidth) =>
      434.0 - narrowWidthDelta(canvasWidth);
  double filletHeightFor(double canvasWidth) =>
      280.0 - narrowWidthDelta(canvasWidth);
  final joints = [JointType.plateButt, JointType.pipeButt];

  final busyGrooves = [
    GrooveType.halfV,
    GrooveType.compoundV,
    GrooveType.doubleV,
  ];
  final normalButtGrooves = [GrooveType.singleV, GrooveType.square];

  // FIXED (Group 4, this session): Single V/pipe butt's cap-height
  // dimension line used to clamp down into the "t mm" thickness label's
  // lane at the narrowest real device width (320pt/240px, visual mode
  // only) - the same canvas-edge-clamp family as the other gaps this
  // session closed. A throwaway spike harness (see
  // calculator_page.dart's `_narrowDrawingHeight` doc comment) measured
  // this combo genuinely clears with +20px more canvas height; confirmed
  // via this suite's own painter (mutation-tested: reverting the height
  // bump reproduces the collision, reapplying clears it).

  // FIXED (Group 4, this session): Double V's both-faces cap-reinforcement
  // pills (bottom-face `capOverlapMm`/`capHeightMm`) used to canvas-edge-
  // clamp onto the identical y-band at the narrowest real device width
  // (320pt/240px) - both in `pipeButt`/visual and, in Russian only,
  // `plateButt`/visual (RU's longer top/bottom-face-prefixed cap labels) -
  // and the same collision recurred at 280/295/310px canvases once plate
  // thickness was in the realistic range for a Double V groove (t>=~50mm).
  // A throwaway spike harness (see calculator_page.dart's
  // `_narrowDrawingHeight` doc comment) measured every one of these combos
  // genuinely clears with more total canvas height - the worst case
  // (Russian's `pipeButt`/visual pair) needed +60px, every other combo
  // needed less. Confirmed via this suite's own painter across the full
  // width/thickness/locale sweep this comment used to describe as unfixed
  // (mutation-tested: reverting the height bump reproduces every one of
  // these collisions, reapplying clears all of them).

  for (final language in AppLanguage.values) {
    for (final width in widths) {
      for (final joint in joints) {
        for (final groove in busyGrooves) {
          for (final mode in DrawingMode.values) {
            _expectNoOverlap(
              '$groove/$joint/$mode @${width.toInt()} [$language]',
              jointType: joint,
              grooveType: groove,
              drawingMode: mode,
              canvasSize: Size(width, busyHeightFor(width)),
              language: language,
            );
          }
        }
        for (final groove in normalButtGrooves) {
          for (final mode in DrawingMode.values) {
            _expectNoOverlap(
              '$groove/$joint/$mode @${width.toInt()} [$language]',
              jointType: joint,
              grooveType: groove,
              drawingMode: mode,
              canvasSize: Size(width, normalHeightFor(width)),
              language: language,
            );
          }
        }
      }
      // FIXED (Group 4, this session): at the narrowest real device width
      // (320pt/240px), fillet's Russian labels used to genuinely overlap
      // (~39-43px horizontally) regardless of available height - a real,
      // pre-existing bug independent of the height-bump fixes above (a
      // locale/width-driven label-width issue, not a height one). A
      // reviewer round's original scoping of this gap named the wrong
      // labels: re-measured directly via this suite's own painter, the two
      // leg-size dimension pills (`leg1Rect`/`leg2Rect` in
      // weld_drawing_preview.dart's `_drawFillet`) are IDENTICAL text
      // ("X mm leg", hardcoded, never localized) across every locale - the
      // actual collision is between the T-joint leader's label (Russian's
      // "Т-образное соединение") and the leg1 dimension pill, after
      // Russian's long leader text (both `tJointLabel` and
      // `filletWeldFaceLabel`) forces a downward collision-avoidance push
      // far enough to land on it. Fixed with a narrow-width-only compact
      // font/padding variant (`compact` param, `_drawLeader`/
      // `_drawAnnotationLabel`/`_drawTechnicalLabel`/`_drawSoftLabel`/
      // `_unclampedMeasurementRect`) applied to both fillet leader labels
      // below 250px canvas width - information-preserving (smaller
      // font/padding, not shortened text), gated by width rather than mode
      // like `_isTechnical`'s existing sizing already is. Confirmed via
      // this suite's own painter across every locale/mode (mutation-tested:
      // reverting `compact` reproduces the RU overlap, reapplying clears
      // it) and a real rendered PNG (legible, not cramped).
      for (final mode in DrawingMode.values) {
        _expectNoOverlap(
          'fillet/$mode @${width.toInt()} [$language]',
          jointType: JointType.fillet,
          grooveType: GrooveType.fillet,
          drawingMode: mode,
          canvasSize: Size(width, filletHeightFor(width)),
          language: language,
        );
      }
    }
  }

  // Thickness axis for Double V: every matrix above/below builds its
  // `WeldDrawingData` via `_buildData`'s default `thicknessMm: 12`, so the
  // bottom-face cap-overlap/cap-height collision (see the FIXED comment
  // above) never got exercised at the thicker plate values realistic for a
  // Double V groove until a prior round added this sweep. Single language
  // (en) - this collision is driven by fixed-pixel-size label geometry, not
  // label text width/length, so locale isn't the relevant axis here (locale
  // coverage for Double V already exists above at thicknessMm: 12).
  const doubleVThicknesses = [12.0, 40.0, 50.0, 60.0];
  for (final width in widths) {
    for (final joint in joints) {
      for (final mode in DrawingMode.values) {
        for (final thicknessMm in doubleVThicknesses) {
          _expectNoOverlap(
            'doubleV/$joint/$mode @${width.toInt()} t=${thicknessMm.toInt()}mm [en]',
            jointType: joint,
            grooveType: GrooveType.doubleV,
            drawingMode: mode,
            canvasSize: Size(width, busyHeightFor(width)),
            language: AppLanguage.en,
            data: _buildData(
              weldingProcess: WeldingProcess.gtaw,
              thicknessMm: thicknessMm,
            ),
          );
        }
      }
    }
  }

  // Follow-up round (this session): every matrix above/below still only
  // ever exercises `_buildData`'s default `thicknessMm: 12` (or, for Double
  // V just above, a handful of thick-plate-only values) - a reviewer found
  // that with production-realistic thicknesses (governing thickness =
  // max(A,B) in Unequal mode) away from 12mm, in BOTH directions - thin
  // plate (~3-11mm) and thick plate (~45-60mm) - the same canvas-bottom-
  // clamp mechanism the earlier FIXED comments describe recurs at
  // 320pt/240px, because the angle-tag/groove-depth pills genuinely shift
  // position as the drawn groove geometry shrinks or grows with thickness.
  // Confined to 240px width - a throwaway spike harness (rendering the real
  // painter, the same technique as every FIXED comment above) confirmed
  // every wider width (280-348px) already clears the full 3-60mm range with
  // zero overlaps even before this round's height bump, so this sweep is
  // width=240-only rather than duplicating the full width axis. Every
  // locale, both joints and draw modes, and every groove type that showed a
  // real collision in the reviewer's audit (Single V, Double V, Compound
  // V) - Half V and Square are included too as a regression guard even
  // though neither failed in the equal-geometry/gtaw sweep specifically.
  const followUpThicknesses = [
    3.0,
    4.0,
    5.0,
    6.0,
    7.0,
    8.0,
    9.0,
    10.0,
    11.0,
    12.0,
    20.0,
    30.0,
    40.0,
    45.0,
    50.0,
    55.0,
    60.0,
  ];
  final followUpGrooves = [...busyGrooves, ...normalButtGrooves];
  for (final language in AppLanguage.values) {
    for (final joint in joints) {
      for (final groove in followUpGrooves) {
        for (final mode in DrawingMode.values) {
          for (final thicknessMm in followUpThicknesses) {
            final height = busyGrooves.contains(groove)
                ? busyHeightFor(240.0)
                : normalHeightFor(240.0);
            _expectNoOverlap(
              '$groove/$joint/$mode @240 t=${thicknessMm.toInt()}mm [$language]',
              jointType: joint,
              grooveType: groove,
              drawingMode: mode,
              canvasSize: Size(240.0, height),
              language: language,
              data: _buildData(
                weldingProcess: WeldingProcess.gtaw,
                thicknessMm: thicknessMm,
              ),
            );
          }
        }
      }
    }
  }

  // Follow-up round (this session), extraBusy tier: the same thickness-axis
  // gap also recurred under GTAW+SMAW's combined process (extraBusy, taller
  // tier) - narrower thickness list (targeted around the values the spike
  // harness found failing) and English-only (matching this file's existing
  // convention of single-locale coverage for secondary/audit-style axes,
  // e.g. the Double V sweep above) to keep this addition proportionate.
  const followUpExtraBusyThicknesses = [3.0, 6.0, 7.0, 8.0, 45.0, 60.0];
  for (final joint in joints) {
    for (final groove in busyGrooves) {
      for (final mode in DrawingMode.values) {
        for (final thicknessMm in followUpExtraBusyThicknesses) {
          // Every groove here is a busy groove and gtawSmaw always sets
          // extraBusy, so this is [busyGrooves]'s extraBusy tier (644,
          // `heightFor`'s own tier table below) - inlined rather than
          // calling `heightFor` since that helper is declared further down
          // this function body.
          _expectNoOverlap(
            'extraBusy/$groove/$joint/$mode @240 t=${thicknessMm.toInt()}mm [en]',
            jointType: joint,
            grooveType: groove,
            drawingMode: mode,
            canvasSize: Size(240.0, 644.0 - narrowWidthDelta(240.0)),
            language: AppLanguage.en,
            data: _buildData(
              weldingProcess: WeldingProcess.gtawSmaw,
              thicknessMm: thicknessMm,
            ),
          );
        }
      }
    }
  }

  // The matrices above (Equal geometry, gtaw, 316-390px) were the whole
  // suite before this reviewer round. Everything below extends coverage to
  // what that round's audit actually exercised - Unequal geometry (all 3
  // alignments), every welding process (not just gtaw - gtawSmaw activates
  // the combined-process tint's extra labels, which is what Findings 2-4
  // were about), and the wider desktop/compact-desktop-column width range,
  // not just phone widths. Two separate matrices cover this rather than one
  // full cartesian product across every axis at once (process x alignment x
  // joint x groove x mode x width x locale would be tens of thousands of
  // widget pumps) - one crosses process x alignment x width x groove x joint
  // x mode at a single fixed locale, the other crosses locale x alignment x
  // width at a fixed (worst-case) process - between them every dimension
  // the audit covered is exercised, just not combined all at once.
  final unequalGrooves = [
    GrooveType.singleV,
    GrooveType.halfV,
    GrooveType.doubleV,
    GrooveType.compoundV,
    GrooveType.square,
  ];
  // Includes the desktop FittedBox width (760) and the compact breakpoints
  // between narrow-phone and desktop the reviewer audit flagged - the
  // desktop-app's own compact left column commonly lands in the
  // 1120-1400px window range, which the FittedBox then shrinks the fixed
  // 760-wide virtual canvas to fit, so 760 is the actual canvas-space width
  // relevant there, not the window width.
  const auditWidths = [...widths, 480.0, 520.0, 600.0, 640.0, 760.0];
  // Unequal geometry's extra "B ... mm" label, and GTAW+SMAW combined
  // process's two extra labels REGARDLESS of geometry mode, each need more
  // canvas height than either tier normally gets - calculator_page.dart's
  // `_narrowDrawingHeight` grants exactly this combination a taller card
  // for that reason (see its `extraBusy` condition); mirror its bumped
  // floor, and (like [busyHeightFor]/[normalHeightFor] above) apply the
  // same narrowest-width chrome penalty via [narrowWidthDelta].
  // Group 4 (prior session): busy&&extraBusy and busy&&!extraBusy (458,
  // mirrored above) both bumped +60px (474->534, 398->458),
  // !busy&&extraBusy bumped +40px (394->434) - see `_narrowDrawingHeight`'s
  // own doc comment for the spike measurements behind the exact deltas.
  // Follow-up round (this session): every tier bumped again by the
  // thickness-axis worst case plus a 10px margin, mirroring
  // [busyHeightFor]/[normalHeightFor] above - see `_narrowDrawingHeight`'s
  // doc comment for the exact figures.
  bool isExtraBusy(WeldDrawingData data) =>
      data.geometryMode == JointGeometryMode.unequal ||
      data.weldingProcess == WeldingProcess.gtawSmaw;
  double heightFor(
    GrooveType groove,
    WeldDrawingData data,
    double canvasWidth,
  ) {
    final extraBusy = isExtraBusy(data);
    final delta = narrowWidthDelta(canvasWidth);
    if (busyGrooves.contains(groove)) {
      return (extraBusy ? 644.0 : 568.0) - delta;
    }
    return (extraBusy ? 524.0 : 434.0) - delta;
  }

  // FIXED (Group 4, this session): extraBusy's own label set (Unequal
  // geometry's "B ... mm", or GTAW+SMAW's 2 combined-process labels, at
  // 320pt/240px) - including every remaining Compound V/Half V groove-depth
  // vs beta/alpha angle-tag canvas-edge-clamp collision Group 3 (2026-09-07)
  // couldn't fully close (`idMatch|pipeButt`/`odMatch|pipeButt` in `visual`
  // mode, and Half V's `odMatch/pipeButt` in both modes) - was the same
  // canvas-edge-clamp family as the other gaps this session closed. A
  // throwaway spike harness (see calculator_page.dart's
  // `_narrowDrawingHeight` doc comment) measured every one of these combos
  // genuinely clears with more total canvas height - the worst case (Half
  // V's `odMatch/pipeButt`/visual) needed +60px, every other combo needed
  // less. Confirmed via this suite's own painter across the full
  // process/alignment/groove/joint/mode sweep below (mutation-tested:
  // reverting the height bump reproduces every one of these collisions,
  // reapplying clears all of them) - Group 3's `_declutterAfterClamp`
  // mechanism (still wired at beta/alpha's `_drawAngleTag` call sites)
  // stays in place as a no-op safety net for any future regression in this
  // family, not removed just because the height bump made it currently
  // redundant everywhere it used to engage.

  // FIXED (Group 4, this session): Single V's idMatch alignment used to
  // land root gap and groove depth's pills into each other at 310px width
  // (a cascading side effect of the GTAW-root-label line-crossing fix
  // pushing every later label down slightly) - same canvas-edge-clamp
  // family as the other gaps this session closed. The same spike measured
  // this combo genuinely clears with +40px more canvas height; confirmed
  // via this suite's own painter (mutation-tested: reverting the height
  // bump reproduces the collision, reapplying clears it).

  for (final alignment in JointAlignment.values) {
    for (final process in WeldingProcess.values) {
      final data = _buildData(
        weldingProcess: process,
        geometryMode: JointGeometryMode.unequal,
        alignment: alignment,
      );
      for (final width in auditWidths) {
        for (final joint in joints) {
          for (final groove in unequalGrooves) {
            for (final mode in DrawingMode.values) {
              _expectNoOverlap(
                'unequal/$alignment/$process/$groove/$joint/$mode '
                '@${width.toInt()} [en]',
                jointType: joint,
                grooveType: groove,
                drawingMode: mode,
                canvasSize: Size(width, heightFor(groove, data, width)),
                language: AppLanguage.en,
                data: data,
              );
            }
          }
        }
      }
    }
  }

  // Finding 2 (prior round): went uncaught because every matrix above
  // either hardcoded Unequal geometry (the matrix just above) or hardcoded
  // a single process, gtaw (the top-of-file matrix) - Equal geometry
  // crossed with GTAW+SMAW (which adds its own 2 extra labels regardless of
  // geometry mode) was never exercised at any width. Cover Equal geometry x
  // every process explicitly, at a representative narrow/mid/desktop width
  // spread rather than folding it into the full matrix above (which would
  // double an already-large combinatorial matrix for coverage this only
  // needs once). The extraBusy/cap-height/both-faces overlaps this loop
  // used to catch here are FIXED (Group 4, this session) - see the height
  // bump's doc comments above.
  for (final process in WeldingProcess.values) {
    final data = _buildData(
      weldingProcess: process,
      geometryMode: JointGeometryMode.equal,
    );
    for (final width in [240.0, 310.0, 760.0]) {
      for (final joint in joints) {
        for (final groove in unequalGrooves) {
          for (final mode in DrawingMode.values) {
            _expectNoOverlap(
              'equal/$process/$groove/$joint/$mode '
              '@${width.toInt()} [en]',
              jointType: joint,
              grooveType: groove,
              drawingMode: mode,
              canvasSize: Size(width, heightFor(groove, data, width)),
              language: AppLanguage.en,
              data: data,
            );
          }
        }
      }
    }
  }

  // Finding 4 (prior round): locale-specific overlaps only surfaced with
  // the combined GTAW+SMAW process (longest extra labels) and Unequal
  // geometry (extra "B ... mm" label) together - the worst case for
  // label-packing - across every alignment and locale, at a representative
  // narrow/mid/desktop width spread. The Single V idMatch/310px overlap
  // this loop used to catch is FIXED (Group 4, this session) - see the
  // height bump's doc comments above.
  const localeWidths = [310.0, 480.0, 760.0];
  for (final language in AppLanguage.values) {
    for (final alignment in JointAlignment.values) {
      final data = _buildData(
        weldingProcess: WeldingProcess.gtawSmaw,
        geometryMode: JointGeometryMode.unequal,
        alignment: alignment,
      );
      for (final width in localeWidths) {
        for (final joint in joints) {
          for (final groove in unequalGrooves) {
            for (final mode in DrawingMode.values) {
              _expectNoOverlap(
                'unequal/$alignment/gtawSmaw/$groove/$joint/$mode '
                '@${width.toInt()} [$language]',
                jointType: joint,
                grooveType: groove,
                drawingMode: mode,
                canvasSize: Size(width, heightFor(groove, data, width)),
                language: language,
                data: data,
              );
            }
          }
        }
      }
    }
  }

  // Finding 3: both matrices above only ever exercise `fillAvailableSpace:
  // true` (the compact mobile card path) - the desktop `FittedBox(760x400)`
  // path (`fillAvailableSpace: false`, calculator_page.dart:984-990) has no
  // regression coverage at all otherwise. The painter always draws at a
  // fixed 760x400 reference canvas in that mode (see
  // [WeldDrawingPreview.fillAvailableSpace]'s doc), so 760x400 is the
  // correct size to render at here too, matching production exactly.
  for (final process in [WeldingProcess.gtaw, WeldingProcess.gtawSmaw]) {
    for (final geometryMode in JointGeometryMode.values) {
      final data = _buildData(
        weldingProcess: process,
        geometryMode: geometryMode,
      );
      for (final joint in joints) {
        for (final groove in unequalGrooves) {
          for (final mode in DrawingMode.values) {
            _expectNoOverlap(
              'desktop/$geometryMode/$process/$groove/$joint/$mode',
              jointType: joint,
              grooveType: groove,
              drawingMode: mode,
              canvasSize: const Size(760, 400),
              language: AppLanguage.en,
              data: data,
              fillAvailableSpace: false,
            );
          }
        }
      }
    }
  }
}

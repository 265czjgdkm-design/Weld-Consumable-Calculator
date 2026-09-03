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
/// their fill colors, 0xF2FFFFFF and 0xCCFFFFFF, are what this filters on;
/// other drawRRect calls in that file are the canvas backdrop frame, not
/// labels) and no-ops every other canvas call - this only needs the real
/// geometry, not real pixels.
class _RecordingCanvas implements Canvas {
  final List<Rect> fillRects = [];

  @override
  void drawRRect(RRect rrect, Paint paint) {
    final argb = paint.color.toARGB32();
    if (argb == 0xF2FFFFFF || argb == 0xCCFFFFFF) {
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
}) {
  return WeldDrawingData(
    weldingProcess: weldingProcess,
    geometryMode: geometryMode,
    alignment: alignment,
    thicknessMm: 12,
    thicknessAMm: geometryMode == JointGeometryMode.unequal ? 14 : null,
    thicknessBMm: geometryMode == JointGeometryMode.unequal ? 10 : null,
    rootGapMm: 3,
    rootFaceMm: 2,
    bevelAngleDeg: 30,
    secondaryBevelAngleDeg: 10,
    breakHeightMm: 4,
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
}) {
  testWidgets('no label overlap: $description', (tester) async {
    final rects = await _renderLabelRects(
      tester,
      jointType: jointType,
      grooveType: grooveType,
      drawingMode: drawingMode,
      canvasSize: canvasSize,
      strings: stringsFor(language),
      data: data,
    );
    final overlaps = _overlapDescriptions(rects);
    expect(
      overlaps,
      isEmpty,
      reason: 'Label rects overlap: ${overlaps.join(' | ')}',
    );
  });
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

  // 316-390px covers the real compact-canvas width range for common
  // iPhone/Samsung device widths (canvas is roughly device width minus
  // ~36-44px of card/container chrome). Height matches what
  // _narrowDrawingHeight (calculator_page.dart) actually reserves: 345px
  // for the busiest groove types (Half V, Compound V, Double V), ~220px for
  // Single V/Square, ~180px for Fillet - each derived from that function's
  // outer-card clamp minus its ~94-100px of title/toggle/padding chrome.
  const widths = [316.0, 346.0, 390.0];
  const busyHeight = 398.0;
  const normalHeight = 334.0;
  const filletHeight = 280.0;
  final joints = [JointType.plateButt, JointType.pipeButt];

  final busyGrooves = [
    GrooveType.halfV,
    GrooveType.compoundV,
    GrooveType.doubleV,
  ];
  final normalButtGrooves = [GrooveType.singleV, GrooveType.square];

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
              canvasSize: Size(width, busyHeight),
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
              canvasSize: Size(width, normalHeight),
              language: language,
            );
          }
        }
      }
      for (final mode in DrawingMode.values) {
        _expectNoOverlap(
          'fillet/$mode @${width.toInt()} [$language]',
          jointType: JointType.fillet,
          grooveType: GrooveType.fillet,
          drawingMode: mode,
          canvasSize: Size(width, filletHeight),
          language: language,
        );
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
  const auditWidths = [316.0, 346.0, 390.0, 480.0, 520.0, 600.0, 640.0, 760.0];
  // Unequal geometry's extra "B ... mm" label plus GTAW+SMAW combined
  // process's two extra labels together need more canvas height than either
  // tier normally gets - calculator_page.dart's `_narrowDrawingHeight`
  // grants exactly this combination a taller card for that reason; mirror
  // its bumped floor (translated to canvas height via the same ~106px of
  // title/toggle/padding chrome the other heights above already subtract).
  double heightFor(GrooveType groove, WeldDrawingData data) {
    final extraBusy =
        data.geometryMode == JointGeometryMode.unequal &&
        data.weldingProcess == WeldingProcess.gtawSmaw;
    if (busyGrooves.contains(groove)) {
      return extraBusy ? 474.0 : busyHeight;
    }
    return extraBusy ? 394.0 : normalHeight;
  }

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
                canvasSize: Size(width, heightFor(groove, data)),
                language: AppLanguage.en,
                data: data,
              );
            }
          }
        }
      }
    }
  }

  // Finding 4: locale-specific overlaps only surfaced with the combined
  // GTAW+SMAW process (longest extra labels) and Unequal geometry (extra
  // "B ... mm" label) together - the worst case for label-packing - across
  // every alignment and locale, at a representative narrow/mid/desktop
  // width spread.
  const localeWidths = [316.0, 480.0, 760.0];
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
                canvasSize: Size(width, heightFor(groove, data)),
                language: language,
                data: data,
              );
            }
          }
        }
      }
    }
  }
}

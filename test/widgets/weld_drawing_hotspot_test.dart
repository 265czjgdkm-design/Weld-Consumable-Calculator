// Tap-correctness coverage for weld_drawing_preview.dart's [DrawingHotspot]
// system (see the reviewer audit findings this fixes): every numeric-looking
// dimension label must be tappable and must jump to its OWN correct
// [FieldKey], not a wrong one, and not be dead (unreachable because its
// hotspot's recorded position doesn't match where the label actually
// renders after canvas-edge clamping). This exercises the real widget's
// gesture dispatch end-to-end (not just the painter's internal hotspot
// list) by tapping at the exact rect [debugWeldDrawingHotspots] reports for
// a matching render and asserting `onFieldTap` fires with the right key.
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

/// Same recording approach as weld_drawing_label_overlap_test.dart's
/// `_RecordingCanvas`, reused here purely so [debugWeldDrawingHotspots] has
/// a `Canvas` to paint into - the pixels themselves are irrelevant, only
/// the hotspot rects the paint pass computes matter for this test.
class _NoopCanvas implements Canvas {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

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
    capOverlapMm: 2,
    capHeightMm: 2,
    legSizeMm: 6,
    pipeOdMm: 168.3,
    gtawTransitionMm: weldingProcess == WeldingProcess.gtawSmaw ? 3 : null,
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

  final joints = [JointType.plateButt, JointType.pipeButt];
  final buttGrooves = [
    GrooveType.singleV,
    GrooveType.halfV,
    GrooveType.doubleV,
    GrooveType.compoundV,
    GrooveType.square,
  ];
  // The compact breakpoints the reviewer audit used, plus the desktop
  // FittedBox width - the exact set Finding 1 says the clamped-rect bug hit.
  const widths = [316.0, 346.0, 390.0, 480.0, 520.0, 600.0, 640.0, 760.0];
  const height = 460.0;

  Future<void> checkAllHotspotsTappable(
    WidgetTester tester, {
    required String description,
    required JointType jointType,
    required GrooveType grooveType,
    required WeldDrawingData data,
    required Size canvasSize,
  }) async {
    final strings = stringsFor(AppLanguage.en);
    FieldKey? tapped;

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
                drawingMode: DrawingMode.visual,
                data: data,
                jointTypeLabel: jointType.labelFor(strings),
                grooveTypeLabel: grooveType.labelFor(strings),
                filletWeldFaceLabel: strings.drawingLabelFilletWeldFace,
                tJointLabel: strings.drawingLabelTJoint,
                smawFillCapLabel: strings.drawingLabelSmawFillCap,
                gtawRootLabel: strings.drawingLabelGtawRoot,
                capTopLabel: strings.drawingLabelCapTop,
                capBottomLabel: strings.drawingLabelCapBottom,
                fillAvailableSpace: true,
                onFieldTap: (key) => tapped = key,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final hotspots = debugWeldDrawingHotspots(
      grooveType: grooveType,
      jointType: jointType,
      drawingMode: DrawingMode.visual,
      data: data,
      jointTypeLabel: jointType.labelFor(strings),
      grooveTypeLabel: grooveType.labelFor(strings),
      filletWeldFaceLabel: strings.drawingLabelFilletWeldFace,
      tJointLabel: strings.drawingLabelTJoint,
      smawFillCapLabel: strings.drawingLabelSmawFillCap,
      gtawRootLabel: strings.drawingLabelGtawRoot,
      canvas: _NoopCanvas(),
      size: canvasSize,
    );
    expect(
      hotspots,
      isNotEmpty,
      reason: '$description: expected at least one hotspot',
    );

    final origin = tester.getTopLeft(find.byType(WeldDrawingPreview));
    for (final hotspot in hotspots) {
      // Every recorded hotspot's rect must itself be fully on-canvas (this
      // is what Finding 1 was actually about - a hotspot recorded at an
      // unclamped, possibly off-canvas position is what made labels dead).
      expect(
        Rect.fromLTWH(
          0,
          0,
          canvasSize.width,
          canvasSize.height,
        ).contains(hotspot.rect.center),
        isTrue,
        reason:
            '$description: ${hotspot.fieldKey} hotspot rect '
            '${hotspot.rect} center is off-canvas (size $canvasSize)',
      );
      tapped = null;
      await tester.tapAt(origin + hotspot.rect.center);
      await tester.pump();
      expect(
        tapped,
        hotspot.fieldKey,
        reason:
            '$description: tap at ${hotspot.fieldKey}\'s own pill center '
            '(${hotspot.rect.center}) resolved to $tapped instead',
      );
    }
  }

  for (final joint in joints) {
    for (final groove in buttGrooves) {
      for (final width in widths) {
        testWidgets(
          'equal/gtaw: $groove/$joint @${width.toInt()} hotspots all tap correctly',
          (tester) async {
            await checkAllHotspotsTappable(
              tester,
              description: 'equal/gtaw/$groove/$joint@${width.toInt()}',
              jointType: joint,
              grooveType: groove,
              data: _buildData(weldingProcess: WeldingProcess.gtaw),
              canvasSize: Size(width, height),
            );
          },
        );
        testWidgets(
          'unequal/gtawSmaw: $groove/$joint @${width.toInt()} hotspots all tap correctly',
          (tester) async {
            await checkAllHotspotsTappable(
              tester,
              description: 'unequal/gtawSmaw/$groove/$joint@${width.toInt()}',
              jointType: joint,
              grooveType: groove,
              data: _buildData(
                weldingProcess: WeldingProcess.gtawSmaw,
                geometryMode: JointGeometryMode.unequal,
              ),
              canvasSize: Size(width, height + 40),
            );
          },
        );
      }
    }
  }

  // Regression canary: Fillet/T-joint was already confirmed clean by the
  // reviewer before this fix round and doesn't participate in the
  // geometryMode/combined-process machinery above - verify it's still
  // fully clean (every hotspot present and correctly wired) after this
  // round's changes to the shared hotspot/avoidance plumbing.
  for (final width in widths) {
    testWidgets('fillet @${width.toInt()} hotspots all tap correctly', (
      tester,
    ) async {
      await checkAllHotspotsTappable(
        tester,
        description: 'fillet@${width.toInt()}',
        jointType: JointType.fillet,
        grooveType: GrooveType.fillet,
        data: _buildData(weldingProcess: WeldingProcess.gtaw),
        canvasSize: Size(width, 320),
      );
    });
  }

  group('Finding 5: previously-hotspot-free labels', () {
    testWidgets('pipe OD chip has a working hotspot mapped to pipeOdMm', (
      tester,
    ) async {
      final strings = stringsFor(AppLanguage.en);
      final hotspots = debugWeldDrawingHotspots(
        grooveType: GrooveType.singleV,
        jointType: JointType.pipeButt,
        drawingMode: DrawingMode.visual,
        data: _buildData(weldingProcess: WeldingProcess.gtaw),
        jointTypeLabel: JointType.pipeButt.labelFor(strings),
        grooveTypeLabel: GrooveType.singleV.labelFor(strings),
        filletWeldFaceLabel: strings.drawingLabelFilletWeldFace,
        tJointLabel: strings.drawingLabelTJoint,
        smawFillCapLabel: strings.drawingLabelSmawFillCap,
        gtawRootLabel: strings.drawingLabelGtawRoot,
        canvas: _NoopCanvas(),
        size: const Size(390, 400),
      );
      expect(
        hotspots.where((h) => h.fieldKey == FieldKey.pipeOdMm),
        isNotEmpty,
      );
    });

    testWidgets(
      'Double V half-thickness labels (equal geometry) map to thicknessMm',
      (tester) async {
        final strings = stringsFor(AppLanguage.en);
        final hotspots = debugWeldDrawingHotspots(
          grooveType: GrooveType.doubleV,
          jointType: JointType.plateButt,
          drawingMode: DrawingMode.visual,
          data: _buildData(weldingProcess: WeldingProcess.gtaw),
          jointTypeLabel: JointType.plateButt.labelFor(strings),
          grooveTypeLabel: GrooveType.doubleV.labelFor(strings),
          filletWeldFaceLabel: strings.drawingLabelFilletWeldFace,
          tJointLabel: strings.drawingLabelTJoint,
          smawFillCapLabel: strings.drawingLabelSmawFillCap,
          gtawRootLabel: strings.drawingLabelGtawRoot,
          canvas: _NoopCanvas(),
          size: const Size(390, 400),
        );
        // Main "<t> mm t" label + the two half-thickness brackets - all
        // three legitimately map to the same underlying field.
        expect(
          hotspots.where((h) => h.fieldKey == FieldKey.thicknessMm).length,
          3,
        );
      },
    );
  });

  group('Finding 6: Half V / Compound V render distinct A/B thicknesses', () {
    /// Mirrors weld_drawing_label_overlap_test.dart's `_RecordingCanvas`
    /// technique but records the steel-plate fill paths' bounds instead of
    /// label pills, to directly verify the DRAWING OUTPUT (not just that
    /// `_memberExtents` is called in the source) actually differs for
    /// different A/B thickness inputs.
    for (final groove in [GrooveType.halfV, GrooveType.compoundV]) {
      testWidgets(
        '$groove: right plate is visibly taller than left when B > A',
        (tester) async {
          final strings = stringsFor(AppLanguage.en);
          const canvasSize = Size(390, 400);
          final recorder = _PlateBoundsCanvas(canvasSize.width / 2);
          const data = WeldDrawingData(
            weldingProcess: WeldingProcess.gtaw,
            geometryMode: JointGeometryMode.unequal,
            alignment: JointAlignment.odMatch,
            // Governing thicknessMm is always max(A,B) in the real app
            // (calculator_page.dart's `_governingThicknessPreview`) - using
            // an inconsistent value here would let this test pass against
            // geometry the app can never actually produce.
            thicknessMm: 20,
            thicknessAMm: 8,
            thicknessBMm: 20,
            rootGapMm: 3,
            rootFaceMm: 2,
            bevelAngleDeg: 30,
            secondaryBevelAngleDeg: 10,
            breakHeightMm: 4,
          );
          debugWeldDrawingHotspots(
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
            canvas: recorder,
            size: canvasSize,
          );
          expect(recorder.leftPlateHeights, isNotEmpty);
          expect(recorder.rightPlateHeights, isNotEmpty);
          final leftHeight = recorder.leftPlateHeights.reduce(
            (a, b) => a > b ? a : b,
          );
          final rightHeight = recorder.rightPlateHeights.reduce(
            (a, b) => a > b ? a : b,
          );
          // odMatch alignment means both plates share the same top (y=0),
          // so with B (right, 20mm) more than double A (left, 8mm), the
          // right plate's drawn path must be visibly taller than the
          // left's - before Finding 6's fix both were identical (=
          // `thicknessMm`, 12) regardless of A/B.
          expect(
            rightHeight,
            greaterThan(leftHeight * 1.5),
            reason:
                'left=$leftHeight right=$rightHeight for $groove - '
                'plates should render at visibly different heights for '
                'A=8/B=20 in Unequal geometry',
          );
        },
      );
    }
  });
}

/// Records the bounding box of every filled path drawn, split into "left"
/// and "right" groups by checking each path's bounds against the canvas's
/// horizontal center (the plates in every butt-joint drawing in this file
/// are always drawn as closed polygons straddling the joint centerline -
/// `layout.centerX`, i.e. `size.width / 2` - one entirely left of it, one
/// entirely right, see e.g. `_drawHalfV`'s `leftPlate`/`rightPlate`), so
/// this cleanly separates them without needing to know which paint call
/// corresponds to which plate.
class _PlateBoundsCanvas implements Canvas {
  _PlateBoundsCanvas(this.centerX);

  final double centerX;
  final List<double> leftPlateHeights = [];
  final List<double> rightPlateHeights = [];

  @override
  void drawPath(Path path, Paint paint) {
    final bounds = path.getBounds();
    if (bounds.isEmpty) return;
    if (bounds.right <= centerX) {
      leftPlateHeights.add(bounds.height);
    } else if (bounds.left >= centerX) {
      rightPlateHeights.add(bounds.height);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

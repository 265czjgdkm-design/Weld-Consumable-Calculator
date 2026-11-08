// Covers the joint drawing: the geometry clamp, label collisions for every
// groove type at the thicknesses users hit, tap targets, and that every
// printed number is the model value (never the clamped drawing geometry).
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/ui/calculator_page/calculator_page_models.dart'
    show FieldKey;
import 'package:weld_consumable_calculator/ui/widgets/weld_drawing_preview.dart';

const _thicknesses = [3.0, 6.0, 10.0, 20.0, 50.0, 100.0];
const _widths = [240.0, 280.0, 322.0, 348.0];

Size _canvas(double width, GrooveType g) =>
    Size(width, g == GrooveType.fillet ? 275 : 375);

WeldDrawingData _data({
  double thickness = 12,
  double gap = 3,
  double rootFace = 2,
  double angle = 30,
  double leg = 6,
  bool unequal = false,
  JointAlignment alignment = JointAlignment.centerline,
  bool combined = false,
  bool caps = true,
}) {
  return WeldDrawingData(
    weldingProcess: combined ? WeldingProcess.gtawSmaw : WeldingProcess.gtaw,
    geometryMode: unequal ? JointGeometryMode.unequal : JointGeometryMode.equal,
    alignment: alignment,
    thicknessMm: thickness,
    thicknessAMm: unequal ? thickness : null,
    thicknessBMm: unequal ? thickness * 0.7 : null,
    rootGapMm: gap,
    rootFaceMm: rootFace,
    bevelAngleDeg: angle,
    secondaryBevelAngleDeg: 12,
    breakHeightMm: 4,
    capOverlapMm: caps ? 2.5 : null,
    capHeightMm: caps ? 1.5 : null,
    legSizeMm: leg,
    pipeOdMm: 168.3,
    gtawTransitionMm: combined ? 3 : null,
  );
}

WeldDrawingScene _scene(
  GrooveType g,
  JointType j,
  WeldDrawingData data,
  Size size,
  AppLanguage lang, {
  double fontSize = 11,
}) {
  final s = stringsFor(lang);
  return buildWeldDrawingScene(
    grooveType: g,
    jointType: j,
    data: data,
    size: size,
    smawFillCapLabel: s.drawingLabelSmawFillCap,
    gtawRootLabel: s.drawingLabelGtawRoot,
    capTopLabel: s.drawingLabelCapTop,
    capBottomLabel: s.drawingLabelCapBottom,
    capOverlapValueLabel: s.drawingLabelCapOverlapValue,
    capHeightValueLabel: s.drawingLabelCapHeightValue,
    fontSize: fontSize,
  );
}

double? _model(WeldDrawingData d, FieldKey k) => switch (k) {
  FieldKey.thicknessMm => d.thicknessMm,
  FieldKey.thicknessAMm => d.thicknessAMm,
  FieldKey.thicknessBMm => d.thicknessBMm,
  FieldKey.rootGapMm => d.rootGapMm,
  FieldKey.rootFaceMm => d.rootFaceMm,
  FieldKey.bevelAngleDeg => d.bevelAngleDeg,
  FieldKey.secondaryBevelAngleDeg => d.secondaryBevelAngleDeg,
  FieldKey.breakHeightMm => d.breakHeightMm,
  FieldKey.capOverlapMm => d.capOverlapMm,
  FieldKey.capHeightMm => d.capHeightMm,
  FieldKey.legSizeMm => d.legSizeMm,
  FieldKey.pipeOdMm => d.pipeOdMm,
  FieldKey.gtawTransitionMm => d.gtawTransitionMm,
  _ => null,
};

/// First number printed in a label, e.g. "α 30°" -> 30, "Üst 2.5 mm ..." -> 2.5.
double? _printed(String text) {
  final m = RegExp(r'\d+(\.\d+)?').firstMatch(text);
  return m == null ? null : double.parse(m.group(0)!);
}

String _describe(WeldDrawingScene scene) =>
    scene.labels.map((l) => '${l.text}@${l.rect}').join('\n');

void _expectNoOverlap(WeldDrawingScene scene, Size size, String reason) {
  final labels = scene.labels;
  for (var i = 0; i < labels.length; i++) {
    final r = labels[i].rect;
    expect(
      r.left >= 0 &&
          r.top >= 0 &&
          r.right <= size.width &&
          r.bottom <= size.height,
      isTrue,
      reason: '$reason: ${labels[i].text} outside $size\n${_describe(scene)}',
    );
    for (var j = i + 1; j < labels.length; j++) {
      expect(
        r.overlaps(labels[j].rect),
        isFalse,
        reason:
            '$reason: "${labels[i].text}" overlaps "${labels[j].text}"\n${_describe(scene)}',
      );
    }
  }
}

Set<FieldKey> _keys(WeldDrawingScene s) =>
    s.labels.map((l) => l.fieldKey).toSet();

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

  group('geometry thickness clamp', () {
    test('thin plates are drawn at the minimum, thick ones are bounded', () {
      expect(weldDrawingGeometryThicknessMm(3), 10);
      expect(weldDrawingGeometryThicknessMm(6), 10);
      expect(weldDrawingGeometryThicknessMm(9.99), 10);
      expect(weldDrawingGeometryThicknessMm(10), 10);
      expect(weldDrawingGeometryThicknessMm(20), 20);
      expect(weldDrawingGeometryThicknessMm(40), 40);
      expect(weldDrawingGeometryThicknessMm(50), 40);
      expect(weldDrawingGeometryThicknessMm(100), 40);
      expect(weldDrawingGeometryThicknessMm(double.nan), 10);
    });

    test('below 10 mm the drawn shape does not change, only the numbers', () {
      final size = _canvas(322, GrooveType.singleV);
      WeldDrawingScene at(double t) => _scene(
        GrooveType.singleV,
        JointType.plateButt,
        _data(thickness: t, caps: false),
        size,
        AppLanguage.en,
      );
      final a = at(3);
      final b = at(10);
      expect(a.weld.getBounds(), b.weld.getBounds());
      expect(
        a.labels.map((l) => l.rect.center.dy),
        b.labels.map((l) => l.rect.center.dy),
      );
      expect(a.labels.first.text, isNot(b.labels.first.text));
    });
  });

  group('labels never overlap and stay on the canvas', () {
    for (final g in GrooveType.values) {
      for (final j in [JointType.plateButt, JointType.pipeButt]) {
        if (g == GrooveType.fillet && j == JointType.pipeButt) continue;
        testWidgets('${g.name} / ${j.name}', (tester) async {
          for (final lang in AppLanguage.values) {
            for (final width in _widths) {
              final size = _canvas(width, g);
              for (final t in _thicknesses) {
                for (final variant in [
                  _data(thickness: t, leg: t),
                  _data(thickness: t, unequal: true, combined: true, leg: t),
                  _data(
                    thickness: t,
                    unequal: true,
                    alignment: JointAlignment.idMatch,
                    caps: false,
                    leg: t,
                  ),
                ]) {
                  _expectNoOverlap(
                    _scene(g, j, variant, size, lang),
                    size,
                    '${g.name}/${j.name}/${lang.name}/w$width/t$t',
                  );
                }
              }
            }
          }
        });
      }
    }

    testWidgets('extreme angles, gaps and root faces', (tester) async {
      for (final g in GrooveType.values) {
        for (final angle in [5.0, 10.0, 60.0, 89.0]) {
          for (final gap in [0.0, 1.0, 15.0, 40.0]) {
            for (final rf in [0.0, 2.0, 30.0]) {
              for (final t in [3.0, 12.0, 100.0]) {
                final size = _canvas(322, g);
                final data = _data(
                  thickness: t,
                  gap: gap,
                  angle: angle,
                  rootFace: rf,
                  combined: true,
                  leg: gap + 1,
                );
                _expectNoOverlap(
                  _scene(g, JointType.pipeButt, data, size, AppLanguage.tr),
                  size,
                  '${g.name} angle=$angle gap=$gap rf=$rf t=$t',
                );
              }
            }
          }
        }
      }
    });

    testWidgets('larger accessibility text still fits', (tester) async {
      for (final g in GrooveType.values) {
        final size = _canvas(348, g);
        for (final t in _thicknesses) {
          _expectNoOverlap(
            _scene(
              g,
              JointType.pipeButt,
              _data(thickness: t, unequal: true, combined: true, leg: t),
              size,
              AppLanguage.tr,
              fontSize: 14.3,
            ),
            size,
            '${g.name} t=$t font 14.3',
          );
        }
      }
    });
  });

  group('every dimension has a label with a tap target', () {
    final expected = <GrooveType, Set<FieldKey>>{
      GrooveType.singleV: {
        FieldKey.thicknessMm,
        FieldKey.rootGapMm,
        FieldKey.rootFaceMm,
        FieldKey.bevelAngleDeg,
      },
      GrooveType.halfV: {
        FieldKey.thicknessMm,
        FieldKey.rootGapMm,
        FieldKey.rootFaceMm,
        FieldKey.bevelAngleDeg,
      },
      GrooveType.doubleV: {
        FieldKey.thicknessMm,
        FieldKey.rootGapMm,
        FieldKey.rootFaceMm,
        FieldKey.bevelAngleDeg,
      },
      GrooveType.compoundV: {
        FieldKey.thicknessMm,
        FieldKey.rootGapMm,
        FieldKey.rootFaceMm,
        FieldKey.bevelAngleDeg,
        FieldKey.secondaryBevelAngleDeg,
        FieldKey.breakHeightMm,
      },
      GrooveType.square: {FieldKey.thicknessMm, FieldKey.rootGapMm},
      GrooveType.fillet: {FieldKey.legSizeMm},
    };

    for (final g in GrooveType.values) {
      testWidgets('${g.name}: labels exist, >=44pt hit areas, taps resolve', (
        tester,
      ) async {
        final size = _canvas(322, g);
        for (final t in _thicknesses) {
          final data = _data(thickness: t, leg: t, combined: true);
          final scene = _scene(
            g,
            JointType.pipeButt,
            data,
            size,
            AppLanguage.en,
          );
          final want = {
            ...expected[g]!,
            FieldKey.capOverlapMm,
            FieldKey.capHeightMm,
            if (g != GrooveType.fillet) FieldKey.pipeOdMm,
            if (g != GrooveType.fillet) FieldKey.gtawTransitionMm,
          };
          if (g == GrooveType.fillet) {
            want.removeAll([FieldKey.capOverlapMm, FieldKey.capHeightMm]);
          }
          expect(_keys(scene), want, reason: '${g.name} t=$t');
          for (final l in scene.labels) {
            expect(l.hitRect.width, greaterThanOrEqualTo(43.99));
            expect(l.hitRect.height, greaterThanOrEqualTo(43.99));
            expect(l.hitRect.contains(l.rect.center), isTrue);
          }
        }

        // Real widget: tapping each label's centre reports its own key.
        final data = _data(thickness: 12, combined: true);
        final tapped = <FieldKey>[];
        final strings = stringsFor(AppLanguage.en);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: WeldDrawingPreview(
                    grooveType: g,
                    jointType: JointType.pipeButt,
                    drawingMode: DrawingMode.visual,
                    data: data,
                    onFieldTap: tapped.add,
                    fillAvailableSpace: true,
                    jointTypeLabel: '',
                    grooveTypeLabel: '',
                    filletWeldFaceLabel: strings.drawingLabelFilletWeldFace,
                    tJointLabel: strings.drawingLabelTJoint,
                    smawFillCapLabel: strings.drawingLabelSmawFillCap,
                    gtawRootLabel: strings.drawingLabelGtawRoot,
                    capTopLabel: strings.drawingLabelCapTop,
                    capBottomLabel: strings.drawingLabelCapBottom,
                    capOverlapValueLabel: strings.drawingLabelCapOverlapValue,
                    capHeightValueLabel: strings.drawingLabelCapHeightValue,
                  ),
                ),
              ),
            ),
          ),
        );
        final origin = tester.getTopLeft(find.byType(WeldDrawingPreview));
        final scene = _scene(g, JointType.pipeButt, data, size, AppLanguage.en);
        for (final l in scene.labels) {
          tapped.clear();
          await tester.tapAt(origin + l.rect.center);
          expect(tapped, [l.fieldKey], reason: '${g.name} ${l.text}');
        }
      });
    }
  });

  group('printed values are the model values', () {
    for (final g in GrooveType.values) {
      testWidgets(g.name, (tester) async {
        for (final t in _thicknesses) {
          for (final unequal in [false, true]) {
            final data = WeldDrawingData(
              weldingProcess: WeldingProcess.gtawSmaw,
              geometryMode: unequal
                  ? JointGeometryMode.unequal
                  : JointGeometryMode.equal,
              alignment: JointAlignment.centerline,
              thicknessMm: t,
              thicknessAMm: unequal ? t : null,
              thicknessBMm: unequal ? t / 2 : null,
              rootGapMm: 4.25,
              rootFaceMm: 1.5,
              bevelAngleDeg: 37.5,
              secondaryBevelAngleDeg: 11,
              breakHeightMm: 3.5,
              capOverlapMm: 7.75,
              capHeightMm: 2.25,
              legSizeMm: t,
              pipeOdMm: 219.1,
              gtawTransitionMm: 2.5,
            );
            final scene = _scene(
              g,
              JointType.pipeButt,
              data,
              _canvas(322, g),
              AppLanguage.tr,
            );
            for (final l in scene.labels) {
              final model = _model(data, l.fieldKey);
              if (l.fieldKey == FieldKey.gtawTransitionMm && l.value == null) {
                continue; // zone name only
              }
              expect(l.value, model, reason: '${g.name} ${l.text}');
              expect(
                _printed(l.text),
                closeTo(model!, 0.005),
                reason: '${g.name} t=$t ${l.text}',
              );
            }
          }
        }
      });
    }

    test('a value that is not entered prints a dash, not a made-up number', () {
      final scene = _scene(
        GrooveType.singleV,
        JointType.plateButt,
        const WeldDrawingData(
          weldingProcess: WeldingProcess.gtaw,
          geometryMode: JointGeometryMode.equal,
          alignment: JointAlignment.centerline,
        ),
        _canvas(322, GrooveType.singleV),
        AppLanguage.en,
      );
      expect(scene.labels, isNotEmpty);
      for (final l in scene.labels) {
        expect(l.value, isNull);
        expect(l.text, contains('—'));
      }
    });
  });
}

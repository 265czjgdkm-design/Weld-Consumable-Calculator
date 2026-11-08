// Guarantees the old painter-internals tests enforced that the scene-level
// suite (weld_drawing_scene_test.dart) does not: Double V caps on both faces,
// visibly different A/B plates in unequal geometry, and the desktop
// (760x400 FittedBox) canvas staying collision-free.
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

WeldDrawingScene _scene(
  GrooveType g,
  WeldDrawingData data,
  Size size, [
  AppLanguage lang = AppLanguage.en,
]) {
  final s = stringsFor(lang);
  return buildWeldDrawingScene(
    grooveType: g,
    jointType: g == GrooveType.fillet ? JointType.fillet : JointType.pipeButt,
    data: data,
    size: size,
    smawFillCapLabel: s.drawingLabelSmawFillCap,
    gtawRootLabel: s.drawingLabelGtawRoot,
    capTopLabel: s.drawingLabelCapTop,
    capBottomLabel: s.drawingLabelCapBottom,
    capOverlapValueLabel: s.drawingLabelCapOverlapValue,
    capHeightValueLabel: s.drawingLabelCapHeightValue,
  );
}

WeldDrawingData _data({
  double t = 12,
  bool unequal = false,
  double? a,
  double? b,
  JointAlignment alignment = JointAlignment.centerline,
  bool combined = false,
}) => WeldDrawingData(
  weldingProcess: combined ? WeldingProcess.gtawSmaw : WeldingProcess.gtaw,
  geometryMode: unequal ? JointGeometryMode.unequal : JointGeometryMode.equal,
  alignment: alignment,
  thicknessMm: t,
  thicknessAMm: a,
  thicknessBMm: b,
  rootGapMm: 3,
  rootFaceMm: 2,
  bevelAngleDeg: 30,
  secondaryBevelAngleDeg: 12,
  breakHeightMm: 4,
  capOverlapMm: 2.5,
  capHeightMm: 1.5,
  legSizeMm: t,
  pipeOdMm: 168.3,
  gtawTransitionMm: combined ? 3 : null,
);

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

  test('Double V shows cap overlap and cap height on both faces', () {
    for (final t in [3.0, 12.0, 100.0]) {
      final scene = _scene(
        GrooveType.doubleV,
        _data(t: t),
        const Size(322, 375),
      );
      int count(FieldKey k) =>
          scene.labels.where((l) => l.fieldKey == k).length;
      expect(count(FieldKey.capOverlapMm), 2, reason: 't=$t');
      expect(count(FieldKey.capHeightMm), 2, reason: 't=$t');
      final single = _scene(
        GrooveType.singleV,
        _data(t: t),
        const Size(322, 375),
      );
      expect(
        single.labels.where((l) => l.fieldKey == FieldKey.capOverlapMm),
        hasLength(1),
      );
    }
  });

  test('unequal geometry draws plate B visibly taller than plate A', () {
    for (final g in [
      GrooveType.singleV,
      GrooveType.halfV,
      GrooveType.compoundV,
      GrooveType.doubleV,
      GrooveType.square,
    ]) {
      for (final al in JointAlignment.values) {
        final scene = _scene(
          g,
          _data(t: 20, unequal: true, a: 8, b: 20, alignment: al),
          const Size(322, 375),
        );
        final left = scene.plates[0].getBounds().height;
        final right = scene.plates[1].getBounds().height;
        expect(right, greaterThan(left * 1.5), reason: '${g.name}/${al.name}');
      }
    }
  });

  test('desktop 760x400 canvas: labels stay on canvas and never overlap', () {
    const size = Size(760, 400);
    for (final g in GrooveType.values) {
      for (final lang in AppLanguage.values) {
        for (final t in [3.0, 12.0, 100.0]) {
          for (final data in [
            _data(t: t),
            _data(t: t, unequal: true, a: t, b: t * 0.7, combined: true),
          ]) {
            final labels = _scene(g, data, size, lang).labels;
            for (var i = 0; i < labels.length; i++) {
              final r = labels[i].rect;
              expect(
                r.left >= 0 &&
                    r.top >= 0 &&
                    r.right <= size.width &&
                    r.bottom <= size.height,
                isTrue,
                reason: '${g.name}/${lang.name}/t$t ${labels[i].text}',
              );
              for (var j = i + 1; j < labels.length; j++) {
                expect(
                  r.overlaps(labels[j].rect),
                  isFalse,
                  reason:
                      '${g.name}/${lang.name}/t$t "${labels[i].text}" vs "${labels[j].text}"',
                );
              }
            }
          }
        }
      }
    }
  });
}

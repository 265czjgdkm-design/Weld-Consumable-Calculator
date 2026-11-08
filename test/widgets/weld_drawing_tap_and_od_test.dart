// Tap precedence between neighbouring labels, empty A thickness, and the
// unequal-pipe OD labels.
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

const _size = Size(322, 400);

WeldDrawingData _data({
  bool unequal = false,
  double? a,
  double? b,
  double? od,
  double? odA,
  double? odB,
}) => WeldDrawingData(
  weldingProcess: WeldingProcess.gtawSmaw,
  geometryMode: unequal ? JointGeometryMode.unequal : JointGeometryMode.equal,
  alignment: JointAlignment.centerline,
  thicknessMm: 12,
  thicknessAMm: a,
  thicknessBMm: b,
  rootGapMm: 3,
  rootFaceMm: 2,
  bevelAngleDeg: 30,
  capOverlapMm: 2,
  capHeightMm: 2,
  pipeOdMm: od,
  pipeOdAMm: odA,
  pipeOdBMm: odB,
  gtawTransitionMm: 3,
);

Widget _preview(WeldDrawingData data, ValueChanged<FieldKey> onTap) {
  final s = stringsFor(AppLanguage.en);
  return MaterialApp(
    home: Scaffold(
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: _size.width,
          height: _size.height,
          child: WeldDrawingPreview(
            grooveType: GrooveType.singleV,
            jointType: JointType.pipeButt,
            drawingMode: DrawingMode.visual,
            data: data,
            onFieldTap: onTap,
            fillAvailableSpace: true,
            jointTypeLabel: '',
            grooveTypeLabel: '',
            filletWeldFaceLabel: s.drawingLabelFilletWeldFace,
            tJointLabel: s.drawingLabelTJoint,
            smawFillCapLabel: s.drawingLabelSmawFillCap,
            gtawRootLabel: s.drawingLabelGtawRoot,
            capTopLabel: s.drawingLabelCapTop,
            capBottomLabel: s.drawingLabelCapBottom,
            capOverlapValueLabel: s.drawingLabelCapOverlapValue,
            capHeightValueLabel: s.drawingLabelCapHeightValue,
          ),
        ),
      ),
    ),
  );
}

WeldDrawingScene _scene(WeldDrawingData data) {
  final s = stringsFor(AppLanguage.en);
  return buildWeldDrawingScene(
    grooveType: GrooveType.singleV,
    jointType: JointType.pipeButt,
    data: data,
    size: _size,
    smawFillCapLabel: s.drawingLabelSmawFillCap,
    gtawRootLabel: s.drawingLabelGtawRoot,
    capTopLabel: s.drawingLabelCapTop,
    capBottomLabel: s.drawingLabelCapBottom,
    capOverlapValueLabel: s.drawingLabelCapOverlapValue,
    capHeightValueLabel: s.drawingLabelCapHeightValue,
  );
}

void main() {
  setUpAll(() async {
    final root =
        Platform.environment['FLUTTER_ROOT'] ?? '/opt/homebrew/share/flutter';
    for (final name in [
      'Roboto-Regular.ttf',
      'Roboto-Medium.ttf',
      'Roboto-Bold.ttf',
    ]) {
      final file = File('$root/bin/cache/artifacts/material_fonts/$name');
      if (!file.existsSync()) continue;
      final bytes = await file.readAsBytes();
      await (FontLoader(
        'Roboto',
      )..addFont(Future.value(ByteData.view(bytes.buffer)))).load();
    }
  });

  testWidgets('a tap inside a drawn label wins over a neighbour padded area', (
    tester,
  ) async {
    final data = _data(od: 168.3);
    final tapped = <FieldKey>[];
    await tester.pumpWidget(_preview(data, tapped.add));
    final origin = tester.getTopLeft(find.byType(WeldDrawingPreview));
    final labels = _scene(data).labels;
    var checked = 0;
    for (final l in labels) {
      // Four corners just inside the drawn pill.
      for (final corner in [
        l.rect.topLeft + const Offset(1, 1),
        l.rect.topRight + const Offset(-1, 1),
        l.rect.bottomLeft + const Offset(1, -1),
        l.rect.bottomRight + const Offset(-1, -1),
      ]) {
        tapped.clear();
        await tester.tapAt(origin + corner);
        expect(tapped, [l.fieldKey], reason: '${l.text} at $corner');
        checked++;
      }
    }
    expect(checked, greaterThan(20));
  });

  test('padded hit areas of neighbours do overlap (so precedence matters)', () {
    final labels = _scene(_data(od: 168.3)).labels;
    var overlapping = 0;
    for (var i = 0; i < labels.length; i++) {
      for (var j = i + 1; j < labels.length; j++) {
        if (labels[i].hitRect.overlaps(labels[j].hitRect)) overlapping++;
      }
    }
    expect(overlapping, greaterThan(0));
  });

  test('unequal geometry with A empty prints a dash, not the B/t value', () {
    final labels = _scene(_data(unequal: true, b: 8)).labels;
    final a = labels.firstWhere((l) => l.fieldKey == FieldKey.thicknessAMm);
    expect(a.value, isNull);
    expect(a.text, 'A — mm');
    final b = labels.firstWhere((l) => l.fieldKey == FieldKey.thicknessBMm);
    expect(b.value, 8);
  });

  test('unequal pipe shows OD A and OD B mapped to their own fields', () {
    final keys = _scene(
      _data(unequal: true, a: 12, b: 8, od: 168.3, odA: 168.3, odB: 114.3),
    ).labels;
    final odA = keys.firstWhere((l) => l.fieldKey == FieldKey.pipeOdAMm);
    final odB = keys.firstWhere((l) => l.fieldKey == FieldKey.pipeOdBMm);
    expect(odA.text, 'OD A 168.3 mm');
    expect(odB.text, 'OD B 114.3 mm');
    expect(keys.any((l) => l.fieldKey == FieldKey.pipeOdMm), isFalse);
  });

  test('equal pipe still shows a single OD on pipeOdMm', () {
    final labels = _scene(_data(od: 219.1)).labels;
    final od = labels.where((l) => l.text.startsWith('OD')).toList();
    expect(od.length, 1);
    expect(od.single.fieldKey, FieldKey.pipeOdMm);
  });

  test('GTAW root label never sits on a dimension line (240 px, unequal)', () {
    final strings = stringsFor(AppLanguage.tr);
    for (final g in GrooveType.values) {
      if (g == GrooveType.fillet) continue;
      for (final t in [3.0, 12.0, 50.0]) {
        final scene = buildWeldDrawingScene(
          grooveType: g,
          jointType: JointType.plateButt,
          data: WeldDrawingData(
            weldingProcess: WeldingProcess.gtawSmaw,
            geometryMode: JointGeometryMode.unequal,
            alignment: JointAlignment.centerline,
            thicknessMm: t,
            thicknessAMm: t,
            thicknessBMm: t * 0.7,
            rootGapMm: 3,
            rootFaceMm: 2,
            bevelAngleDeg: 30,
            secondaryBevelAngleDeg: 12,
            breakHeightMm: 4,
            capOverlapMm: 2,
            capHeightMm: 2,
            gtawTransitionMm: 3,
          ),
          size: const Size(240, 400),
          smawFillCapLabel: strings.drawingLabelSmawFillCap,
          gtawRootLabel: strings.drawingLabelGtawRoot,
          capTopLabel: strings.drawingLabelCapTop,
          capBottomLabel: strings.drawingLabelCapBottom,
          capOverlapValueLabel: strings.drawingLabelCapOverlapValue,
          capHeightValueLabel: strings.drawingLabelCapHeightValue,
        );
        final root = scene.labels.lastWhere(
          (l) => l.text.startsWith(strings.drawingLabelGtawRoot),
        );
        for (final seg in scene.debugLineSegments) {
          final d = seg.$2 - seg.$1;
          for (var k = 0; k <= 300; k++) {
            expect(
              root.rect.deflate(1).contains(seg.$1 + d * (k / 300)),
              isFalse,
              reason: '${g.name} t=$t: line ${seg.$1}->${seg.$2} on root label',
            );
          }
        }
      }
    }
  });

  group('highlight', () {
    final fieldsByGroove = <GrooveType, List<FieldKey>>{
      GrooveType.singleV: [
        FieldKey.thicknessMm,
        FieldKey.rootGapMm,
        FieldKey.rootFaceMm,
        FieldKey.bevelAngleDeg,
        FieldKey.capOverlapMm,
        FieldKey.capHeightMm,
        FieldKey.gtawTransitionMm,
        FieldKey.pipeOdMm,
      ],
      GrooveType.compoundV: [
        FieldKey.secondaryBevelAngleDeg,
        FieldKey.breakHeightMm,
      ],
      GrooveType.fillet: [FieldKey.legSizeMm],
    };

    test(
      'every dimension with lines has them tagged; others are pill-only',
      () {
        for (final entry in fieldsByGroove.entries) {
          final strings = stringsFor(AppLanguage.en);
          final scene = buildWeldDrawingScene(
            grooveType: entry.key,
            jointType: entry.key == GrooveType.fillet
                ? JointType.fillet
                : JointType.pipeButt,
            data: _data(od: 168.3),
            size: _size,
            smawFillCapLabel: strings.drawingLabelSmawFillCap,
            gtawRootLabel: strings.drawingLabelGtawRoot,
            capTopLabel: strings.drawingLabelCapTop,
            capBottomLabel: strings.drawingLabelCapBottom,
            capOverlapValueLabel: strings.drawingLabelCapOverlapValue,
            capHeightValueLabel: strings.drawingLabelCapHeightValue,
          );
          final labelKeys = scene.labels.map((l) => l.fieldKey).toSet();
          for (final k in entry.value) {
            expect(labelKeys, contains(k), reason: '${entry.key.name} $k');
            final hasLines = scene.debugElementKeys.contains(k);
            // OD has no dimension lines; the GTAW zone only a leader.
            if (k == FieldKey.pipeOdMm) {
              expect(hasLines, isFalse);
            } else if (k != FieldKey.gtawTransitionMm) {
              expect(hasLines, isTrue, reason: '${entry.key.name} $k');
            }
          }
        }
      },
    );

    testWidgets('selected dimension is painted in the accent, others are not', (
      tester,
    ) async {
      final data = _data(od: 168.3);
      for (final key in [
        FieldKey.thicknessMm,
        FieldKey.rootGapMm,
        FieldKey.rootFaceMm,
        FieldKey.bevelAngleDeg,
        FieldKey.capOverlapMm,
        FieldKey.capHeightMm,
        FieldKey.gtawTransitionMm,
        FieldKey.pipeOdMm,
      ]) {
        final strings = stringsFor(AppLanguage.en);
        Widget build(FieldKey? hl) => MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: _size.width,
              height: _size.height,
              child: WeldDrawingPreview(
                grooveType: GrooveType.singleV,
                jointType: JointType.pipeButt,
                drawingMode: DrawingMode.visual,
                data: data,
                highlightedField: hl,
                fillAvailableSpace: true,
                jointTypeLabel: '',
                grooveTypeLabel: '',
                filletWeldFaceLabel: '',
                tJointLabel: '',
                smawFillCapLabel: strings.drawingLabelSmawFillCap,
                gtawRootLabel: strings.drawingLabelGtawRoot,
                capTopLabel: strings.drawingLabelCapTop,
                capBottomLabel: strings.drawingLabelCapBottom,
                capOverlapValueLabel: strings.drawingLabelCapOverlapValue,
                capHeightValueLabel: strings.drawingLabelCapHeightValue,
              ),
            ),
          ),
        );

        Future<List<Rect>> accentPills(FieldKey? hl) async {
          await tester.pumpWidget(build(hl));
          final painter = tester
              .widget<CustomPaint>(
                find.descendant(
                  of: find.byType(WeldDrawingPreview),
                  matching: find.byType(CustomPaint),
                ),
              )
              .painter!;
          final rec = _RecordingCanvas();
          painter.paint(rec, _size);
          return rec.accentPills;
        }

        expect(await accentPills(null), isEmpty);
        final scene = _scene(data);
        final expected = scene.labels
            .where((l) => l.fieldKey == key)
            .map((l) => l.rect)
            .toList();
        expect(expected, isNotEmpty);
        final got = await accentPills(key);
        expect(got.length, expected.length, reason: '$key');
        for (final r in expected) {
          expect(got.any((g) => (g.center - r.center).distance < 0.5), isTrue);
        }
      }
    });
  });
}

class _RecordingCanvas implements Canvas {
  final List<Rect> accentPills = [];

  @override
  void drawRRect(RRect rrect, Paint paint) {
    if (paint.style == PaintingStyle.fill &&
        paint.color.toARGB32() == 0xFFD6246E) {
      accentPills.add(rrect.outerRect);
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

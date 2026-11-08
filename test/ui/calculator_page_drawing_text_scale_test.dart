// The phone drawing canvas must keep every label collision-free at SE/390
// widths and larger text sizes. Pumps the real page, measures the canvas it
// actually gets, and checks every groove type at that size.
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/models/weld_models.dart';
import 'package:weld_consumable_calculator/ui/calculator_page.dart';
import 'package:weld_consumable_calculator/ui/widgets/weld_drawing_preview.dart';

WeldDrawingData _data(
  double t, {
  bool unequal = false,
  bool combined = false,
  bool caps = true,
}) => WeldDrawingData(
  weldingProcess: combined ? WeldingProcess.gtawSmaw : WeldingProcess.gtaw,
  geometryMode: unequal ? JointGeometryMode.unequal : JointGeometryMode.equal,
  alignment: JointAlignment.centerline,
  thicknessMm: t,
  thicknessAMm: unequal ? t : null,
  thicknessBMm: unequal ? t * 0.7 : null,
  rootGapMm: 3,
  rootFaceMm: 2,
  bevelAngleDeg: 30,
  secondaryBevelAngleDeg: 12,
  breakHeightMm: 4,
  capOverlapMm: caps ? 2.5 : null,
  capHeightMm: caps ? 1.5 : null,
  legSizeMm: t,
  pipeOdMm: 168.3,
  pipeOdAMm: unequal ? 168.3 : null,
  pipeOdBMm: unequal ? 114.3 : null,
  gtawTransitionMm: combined ? 3 : null,
);

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

  for (final scale in [1.0, 1.3, 2.0]) {
    for (final phone in [const Size(320, 568), const Size(390, 844)]) {
      testWidgets('drawing stays collision-free at $phone, text x$scale', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({});
        tester.view.physicalSize = phone * 3;
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          AppLocaleScope(
            locale: AppLocale(),
            child: MaterialApp(
              builder: (c, child) => MediaQuery(
                data: MediaQuery.of(
                  c,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: CalculatorPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Get Started'));
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Continue').first);
        await tester.tap(find.text('Continue').first);
        await tester.pumpAndSettle();

        final preview = find.byType(WeldDrawingPreview);
        expect(preview, findsOneWidget);
        final canvas = tester.getSize(preview);
        final scaler = TextScaler.linear(scale);
        final widget = tester.widget<WeldDrawingPreview>(preview);
        expect(
          canvas.height,
          weldDrawingPhoneCanvasHeight(widget.grooveType, scaler),
        );
        // Drawing area keeps a usable minimum however large the text is.
        expect(canvas.height, greaterThanOrEqualTo(285));

        final fontSize = scaler.scale(11).clamp(11.0, 14.3);
        for (final g in GrooveType.values) {
          final size = Size(
            canvas.width,
            weldDrawingPhoneCanvasHeight(g, scaler),
          );
          for (final lang in AppLanguage.values) {
            final s = stringsFor(lang);
            for (final t in [3.0, 6.0, 12.0, 30.0, 100.0]) {
              for (final v in [
                _data(t),
                _data(t, unequal: true, combined: true),
                _data(t, combined: true, caps: false),
              ]) {
                final scene = buildWeldDrawingScene(
                  grooveType: g,
                  jointType: g == GrooveType.fillet
                      ? JointType.fillet
                      : JointType.pipeButt,
                  data: v,
                  size: size,
                  smawFillCapLabel: s.drawingLabelSmawFillCap,
                  gtawRootLabel: s.drawingLabelGtawRoot,
                  capTopLabel: s.drawingLabelCapTop,
                  capBottomLabel: s.drawingLabelCapBottom,
                  capOverlapValueLabel: s.drawingLabelCapOverlapValue,
                  capHeightValueLabel: s.drawingLabelCapHeightValue,
                  fontSize: fontSize,
                );
                final ls = scene.labels;
                for (var i = 0; i < ls.length; i++) {
                  final r = ls[i].rect;
                  final tag =
                      '${g.name}/${lang.name}/t$t $size "${ls[i].text}"';
                  expect(
                    r.left >= 0 &&
                        r.top >= 0 &&
                        r.right <= size.width &&
                        r.bottom <= size.height,
                    isTrue,
                    reason: 'outside canvas: $tag',
                  );
                  for (var j = i + 1; j < ls.length; j++) {
                    expect(
                      r.overlaps(ls[j].rect),
                      isFalse,
                      reason: '$tag overlaps "${ls[j].text}"',
                    );
                  }
                  for (final seg in scene.debugLeaderSegments) {
                    final d = seg.$2 - seg.$1;
                    for (var k = 0; k <= 200; k++) {
                      expect(
                        r.deflate(1).contains(seg.$1 + d * (k / 200)),
                        isFalse,
                        reason: 'leader crosses $tag',
                      );
                    }
                  }
                }
              }
            }
          }
        }
      });
    }
  }
}

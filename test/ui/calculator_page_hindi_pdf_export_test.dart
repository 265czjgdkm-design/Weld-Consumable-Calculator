import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weld_consumable_calculator/l10n/app_language.dart';
import 'package:weld_consumable_calculator/l10n/app_locale.dart';
import 'package:weld_consumable_calculator/l10n/app_locale_scope.dart';
import 'package:weld_consumable_calculator/l10n/strings.dart';
import 'package:weld_consumable_calculator/services/entitlement_service.dart';
import 'package:weld_consumable_calculator/ui/calculator_page.dart';

/// Matches every codepoint in the Devanagari Unicode block (U+0900-U+097F),
/// used by Hindi. If any of these show up in the exported PDF's decoded
/// text, the `pdfExportStringsFor` English fallback (calculator_page.dart)
/// isn't actually wired into the real export path anymore.
final _devanagariPattern = RegExp('[ऀ-ॿ]');

class _PremiumEntitlementService extends EntitlementService {
  @override
  Future<bool> isPremiumActive() async => true;
  @override
  Stream<bool> premiumStatusStream() => const Stream<bool>.empty();
}

/// Renders [bytes] to text via `pdftotext` (poppler), same technique used in
/// report_preview_test.dart, so this test asserts on decoded PDF content
/// rather than raw bytes.
Future<String> _extractPdfText(Uint8List bytes) async {
  final dir = await Directory.systemTemp.createTemp('hi_pdf_export_test_');
  try {
    final file = File('${dir.path}/report.pdf');
    await file.writeAsBytes(bytes, flush: true);
    final result = await Process.run('pdftotext', [
      file.path,
      '-',
    ], stdoutEncoding: utf8);
    if (result.exitCode != 0) {
      throw StateError('pdftotext failed: ${result.stderr}');
    }
    return result.stdout as String;
  } finally {
    await dir.delete(recursive: true);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'exporting a PDF from the real Hindi UI produces English PDF text, not '
    'Devanagari (regression guard for the stringsOverride: pdfStrings wiring '
    'at calculator_page.dart _exportPdf -- a future refactor dropping that '
    'override would silently reintroduce the Hindi-text leak this test '
    'would otherwise be the only thing catching)',
    (tester) async {
      SharedPreferences.setMockInitialValues({});

      Uint8List? exportedBytes;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('net.nfet.printing'),
        (call) async {
          if (call.method == 'sharePdf') {
            exportedBytes = call.arguments['doc'] as Uint8List;
          }
          return 1;
        },
      );

      final hi = stringsFor(AppLanguage.hi);
      final locale = AppLocale();
      await locale.setLanguage(AppLanguage.hi);

      // Desktop viewport so the wizard collapses to the single-page layout
      // with one Calculate button (see calculator_page_cap_dimensions_test's
      // _setDesktopViewport for the same convention).
      final originalPhysicalSize = tester.view.physicalSize;
      final originalDevicePixelRatio = tester.view.devicePixelRatio;
      tester.view.physicalSize = const Size(1400, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.physicalSize = originalPhysicalSize;
        tester.view.devicePixelRatio = originalDevicePixelRatio;
      });

      await tester.pumpWidget(
        AppLocaleScope(
          locale: locale,
          child: MaterialApp(
            home: CalculatorPage(
              entitlementService: _PremiumEntitlementService(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text(hi.getStarted));
      await tester.tap(find.text(hi.getStarted));
      await tester.pumpAndSettle();

      final calculateButton = find.text(hi.commonCalculate);
      await tester.ensureVisible(calculateButton.first);
      await tester.tap(calculateButton.first);
      await tester.pumpAndSettle();

      final pdfButton = find.widgetWithText(
        OutlinedButton,
        hi.resultsPdfExport,
      );
      expect(pdfButton, findsOneWidget, reason: 'PDF export button not found');
      await tester.scrollUntilVisible(pdfButton, 200, maxScrolls: 30);

      // rootBundle font loads inside _exportPdf stall indefinitely under
      // pumpAndSettle's fake async clock -- runAsync lets them actually
      // complete on the real event loop.
      await tester.runAsync(() async {
        final button = tester.widget<OutlinedButton>(pdfButton);
        button.onPressed!();
        for (var i = 0; i < 200; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          if (exportedBytes != null) break;
        }
      });

      expect(
        exportedBytes,
        isNotNull,
        reason: 'no PDF bytes reached the printing channel',
      );

      // pdftotext is a real subprocess -- like the font loads above, it
      // needs the real event loop, not the fake-async zone testWidgets
      // otherwise runs its body under.
      final pdfText = await tester.runAsync(
        () => _extractPdfText(exportedBytes!),
      );
      expect(
        _devanagariPattern.hasMatch(pdfText!),
        isFalse,
        reason:
            'Hindi PDF export leaked Devanagari text into the exported '
            'PDF instead of falling back to English:\n$pdfText',
      );
      expect(pdfText, contains('Weld Metal (kg)'));
    },
  );
}

import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/basis_value_parsing.dart';
import '../l10n/strings.dart';
import '../models/consumable_selection.dart';
import '../models/weld_models.dart';
import '../ui/calculator_page/calculator_page_models.dart';

class WeldPdfReportService {
  const WeldPdfReportService();

  static const _brandTeal = PdfColor.fromInt(0xFF0B0F10);
  static const _brandTeal2 = PdfColor.fromInt(0xFF2B3538);
  static const _brandTealSoft = PdfColor.fromInt(0xFFEAF2F4);
  static const _brandOrange = PdfColor.fromInt(0xFFFF6A35);
  static const _brandOrangeSoft = PdfColor.fromInt(0xFFFBE7DE);
  static const _ink = PdfColor.fromInt(0xFF15232D);
  static const _muted = PdfColor.fromInt(0xFF5E7380);
  static const _line = PdfColor.fromInt(0xFFD7E1E7);
  static const _panel = PdfColor.fromInt(0xFFF6FAFC);

  /// Loaded once per report build (rather than cached at the class level) so
  /// the service stays a stateless `const` -- the font bytes are small
  /// enough that re-loading per export is not a meaningful cost.
  Future<pw.ThemeData> _buildTheme() async {
    final notoRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );
    final notoBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
    );
    final notoDevanagari = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSansDevanagari-Regular.ttf'),
    );
    return pw.ThemeData.withFont(
      base: notoRegular,
      bold: notoBold,
      fontFallback: [notoDevanagari],
    );
  }

  Future<Uint8List> buildReportBytes({
    required JointType jointType,
    required GrooveType grooveType,
    required WeldingProcess weldingProcess,
    required ConsumableSelection consumableSelection,
    required WeldCalculationResult result,
    required List<CalculationBasisItem> basisEntries,
    required L10nStrings strings,
  }) async {
    final generatedAt = DateTime.now();
    final theme = await _buildTheme();
    final document = pw.Document(
      title: strings.pdfDocTitle,
      author: 'Varyos Weld',
      creator: 'Varyos Weld',
      subject: strings.pdfDocSubject,
      theme: theme,
    );

    final reportId =
        'VW-${generatedAt.year}${_two(generatedAt.month)}${_two(generatedAt.day)}-${_two(generatedAt.hour)}${_two(generatedAt.minute)}${_two(generatedAt.second)}';
    final indicators = _buildIndicators(result, basisEntries, strings);
    final basisSections = _groupBasisEntries(basisEntries, strings);

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        theme: theme,
        build: (context) => _buildCoverPage(
          reportId: reportId,
          jointType: jointType,
          grooveType: grooveType,
          weldingProcess: weldingProcess,
          consumableSelection: consumableSelection,
          generatedAt: generatedAt,
          result: result,
          strings: strings,
        ),
      ),
    );

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 32),
          theme: theme,
        ),
        footer: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 14),
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: _line, width: 0.8)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Varyos Weld',
                style: pw.TextStyle(
                  color: _muted,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                strings.pdfFooterPage
                    .replaceFirst('{current}', '${context.pageNumber}')
                    .replaceFirst('{total}', '${context.pagesCount}'),
                style: const pw.TextStyle(color: _muted, fontSize: 9),
              ),
            ],
          ),
        ),
        build: (context) => [
          _buildHeader(
            reportId: reportId,
            jointType: jointType,
            grooveType: grooveType,
            weldingProcess: weldingProcess,
            consumableSelection: consumableSelection,
            generatedAt: generatedAt,
            strings: strings,
          ),
          pw.SizedBox(height: 16),
          _buildReadinessBanner(result, indicators, strings),
          pw.SizedBox(height: 18),
          _buildSectionTitle(
            strings.pdfSectionExecutiveSummaryTitle,
            strings.pdfSectionExecutiveSummarySubtitle,
          ),
          pw.SizedBox(height: 10),
          _buildMetricGrid(result, strings),
          pw.SizedBox(height: 18),
          _buildSectionTitle(
            strings.pdfSectionPlanningIndicatorsTitle,
            strings.pdfSectionPlanningIndicatorsSubtitle,
          ),
          pw.SizedBox(height: 10),
          _buildIndicatorGrid(indicators),
          pw.SizedBox(height: 18),
          if (result.processBreakdowns.length > 1) ...[
            _buildSectionTitle(
              strings.pdfSectionProcessBreakdownTitle,
              strings.pdfSectionProcessBreakdownSubtitle,
            ),
            pw.SizedBox(height: 10),
            _buildProcessBreakdownTable(result.processBreakdowns, strings),
            pw.SizedBox(height: 18),
          ],
          _buildSectionTitle(
            strings.pdfSectionEngineeringBasisTitle,
            strings.pdfSectionEngineeringBasisSubtitle,
          ),
          pw.SizedBox(height: 10),
          for (final section in basisSections) ...[
            ..._buildBasisSectionWidgets(section, strings),
            pw.SizedBox(height: 12),
          ],
          pw.NewPage(),
          _buildSectionTitle(
            strings.pdfSectionCalculationMethodTitle,
            strings.pdfSectionCalculationMethodSubtitle,
          ),
          pw.SizedBox(height: 10),
          _buildMethodologyPanel(strings),
          pw.SizedBox(height: 18),
          _buildSectionTitle(
            strings.pdfSectionEngineeringNotesTitle,
            strings.pdfSectionEngineeringNotesSubtitle,
          ),
          pw.SizedBox(height: 10),
          _buildEngineeringNotes(strings),
        ],
      ),
    );

    return document.save();
  }

  /// Report bytes + file name, exposed separately from [buildReportBytes] so
  /// callers that also need to persist the report (e.g. Saved Reports) don't
  /// have to regenerate it before handing it to [exportPdfReport].
  Future<({Uint8List bytes, String fileName})> buildReport({
    required JointType jointType,
    required GrooveType grooveType,
    required WeldingProcess weldingProcess,
    required ConsumableSelection consumableSelection,
    required WeldCalculationResult result,
    required List<CalculationBasisItem> basisEntries,
    required L10nStrings strings,
  }) async {
    final generatedAt = DateTime.now();
    final bytes = await buildReportBytes(
      jointType: jointType,
      grooveType: grooveType,
      weldingProcess: weldingProcess,
      consumableSelection: consumableSelection,
      result: result,
      basisEntries: basisEntries,
      strings: strings,
    );
    final fileName = _buildFileName(
      jointType: jointType,
      grooveType: grooveType,
      weldingProcess: weldingProcess,
      generatedAt: generatedAt,
    );

    return (bytes: bytes, fileName: fileName);
  }

  pw.Widget _buildCoverPage({
    required String reportId,
    required JointType jointType,
    required GrooveType grooveType,
    required WeldingProcess weldingProcess,
    required ConsumableSelection consumableSelection,
    required DateTime generatedAt,
    required WeldCalculationResult result,
    required L10nStrings strings,
  }) {
    return pw.Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [_brandTeal, _brandTeal2],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
      ),
      child: pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(48, 48, 48, 40),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                _buildCoverLogo(),
                pw.SizedBox(width: 14),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'VARYOS',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1.6,
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text(
                      'WELD',
                      style: pw.TextStyle(
                        color: _brandOrange,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Spacer(flex: 2),
            pw.Text(
              strings.pdfReportTitle,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 34,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              strings.pdfCoverSubtitle,
              style: const pw.TextStyle(
                color: PdfColors.white,
                fontSize: 12,
                lineSpacing: 3,
              ),
            ),
            pw.SizedBox(height: 22),
            pw.Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _summaryChip(strings.basisJoint, jointType.labelFor(strings)),
                _summaryChip(
                  strings.basisGroove,
                  grooveType.labelFor(strings),
                ),
                _summaryChip(strings.basisProcess, weldingProcess.label),
                _summaryChip(
                  strings.basisClassification,
                  _classificationLabel(consumableSelection),
                ),
              ],
            ),
            pw.Spacer(flex: 3),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(16),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _coverHeadline(
                    strings.metricFillerMetalConsumption,
                    '${_number(result.fillerKg, 3)} kg',
                  ),
                  _coverHeadline(
                    strings.metricEstimatedArcOnTime,
                    '${_number(result.arcTimeHours, 3)} h',
                  ),
                  _coverHeadline(
                    strings.metricEffectiveDepositionRate,
                    '${_number(result.depositionRateKgPerHour, 2)} kg/h',
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),
            pw.Container(
              padding: const pw.EdgeInsets.only(top: 14),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(
                    color: PdfColor.fromInt(0x33FFFFFF),
                    width: 0.8,
                  ),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    strings.pdfReportIdLabel.replaceFirst('{id}', reportId),
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 9.5,
                    ),
                  ),
                  pw.Text(
                    strings.pdfCoverGenerated.replaceFirst(
                      '{date}',
                      '${generatedAt.year}-${_two(generatedAt.month)}-${_two(generatedAt.day)} ${_two(generatedAt.hour)}:${_two(generatedAt.minute)}',
                    ),
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildCoverLogo({double size = 56}) => _buildVaryosMark(size);

  /// The Varyos brand mark rendered for PDF output: two struck blades
  /// meeting at one point of impact, on a dark rounded-square field. Vector
  /// coordinates mirror lib/ui/calculator_page/calculator_page_widgets.dart's
  /// VaryosMark (a 200x200 viewBox) so the report matches the app exactly.
  pw.Widget _buildVaryosMark(double size) {
    return pw.Container(
      width: size,
      height: size,
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(size * 0.28),
        gradient: const pw.LinearGradient(
          colors: [_brandTeal2, _brandTeal],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
      ),
      child: pw.CustomPaint(
        size: PdfPoint(size, size),
        painter: (canvas, paintSize) {
          final scale = paintSize.x / 200;
          // PDF canvas y-axis points up; the source viewBox's y points down
          // (like Flutter's), so flip: y' = paintSize.y - y * scale.
          PdfPoint p(double x, double y) =>
              PdfPoint(x * scale, paintSize.y - y * scale);

          void blade(PdfPoint a, PdfPoint b, PdfPoint c, PdfPoint d) {
            canvas
              ..moveTo(a.x, a.y)
              ..lineTo(b.x, b.y)
              ..lineTo(c.x, c.y)
              ..lineTo(d.x, d.y)
              ..closePath();
          }

          canvas.setFillColor(PdfColors.white);
          blade(p(40, 25), p(65, 25), p(108, 168), p(83, 168));
          canvas.fillPath();
          blade(p(160, 25), p(135, 25), p(92, 168), p(117, 168));
          canvas.fillPath();

          canvas.setFillColor(_brandOrange);
          blade(p(100, 136), p(112, 158), p(100, 180), p(88, 158));
          canvas.fillPath();
        },
      ),
    );
  }

  pw.Widget _coverHeadline(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: pw.TextStyle(
            color: _muted,
            fontSize: 8.2,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 0.6,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildHeader({
    required String reportId,
    required JointType jointType,
    required GrooveType grooveType,
    required WeldingProcess weldingProcess,
    required ConsumableSelection consumableSelection,
    required DateTime generatedAt,
    required L10nStrings strings,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(22),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(18),
        gradient: const pw.LinearGradient(
          colors: [_brandTeal, _brandTeal2],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        _buildVaryosMark(26),
                        pw.SizedBox(width: 10),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'VARYOS',
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            pw.SizedBox(width: 5),
                            pw.Text(
                              'WELD',
                              style: pw.TextStyle(
                                color: _brandOrange,
                                fontSize: 7.5,
                                fontWeight: pw.FontWeight.bold,
                                letterSpacing: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 14),
                    pw.Text(
                      strings.pdfReportTitle,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      strings.pdfHeaderSubtitle,
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 10.5,
                        lineSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 14),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: _brandOrange,
                  borderRadius: pw.BorderRadius.circular(14),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      strings.pdfReportIdCaption,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      reportId,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _summaryChip(strings.basisJoint, jointType.labelFor(strings)),
              _summaryChip(strings.basisGroove, grooveType.labelFor(strings)),
              _summaryChip(strings.basisProcess, weldingProcess.label),
              _summaryChip(
                strings.basisClassification,
                _classificationLabel(consumableSelection),
              ),
              _summaryChip(
                strings.fillerMaterialFieldFamily,
                consumableSelection.family.labelFor(strings),
              ),
              _summaryChip(
                strings.pdfChipGenerated,
                '${generatedAt.year}-${_two(generatedAt.month)}-${_two(generatedAt.day)} ${_two(generatedAt.hour)}:${_two(generatedAt.minute)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildReadinessBanner(
    WeldCalculationResult result,
    List<_ReportIndicator> indicators,
    L10nStrings strings,
  ) {
    final fillerPerMeter = indicators
        .firstWhere((item) => item.kind == _IndicatorKind.fillerPerMeter)
        .formatted;
    final arcPerMeter = indicators
        .firstWhere((item) => item.kind == _IndicatorKind.arcOnPerMeter)
        .formatted;

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _panel,
        borderRadius: pw.BorderRadius.circular(16),
        border: pw.Border.all(color: _line, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: pw.BoxDecoration(
              color: _brandTeal,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              strings.resultsEstimateReadyBadge,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            strings.resultsHighlightSentence
                .replaceFirst('{filler}', _number(result.fillerKg, 3))
                .replaceFirst('{arcTime}', _number(result.arcTimeHours, 3)),
            style: pw.TextStyle(
              color: _ink,
              fontSize: 13.2,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _miniChip(
                strings.metricEffectiveDepositionRate,
                '${_number(result.depositionRateKgPerHour, 2)} kg/h',
              ),
              _miniChip(strings.resultsHighlightFillerPerMeter, fillerPerMeter),
              _miniChip(strings.resultsHighlightArcOnPerMeter, arcPerMeter),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMetricGrid(WeldCalculationResult result, L10nStrings strings) {
    final metrics = [
      (strings.metricWeldArea, _number(result.areaMm2, 2), 'mm2'),
      (strings.metricWeldLength, _number(result.lengthMm, 2), 'mm'),
      (strings.metricWeldMetalVolume, _number(result.volumeCm3, 3), 'cm3'),
      (strings.metricWeldMetalWeight, _number(result.weldMetalKg, 3), 'kg'),
      (
        strings.metricFillerMetalConsumption,
        _number(result.fillerKg, 3),
        'kg',
      ),
      (
        strings.metricEstimatedArcOnTime,
        _number(result.arcTimeHours, 3),
        'h',
      ),
      (
        strings.metricEffectiveDepositionEfficiency,
        _percent(result.depositionEfficiency),
        '',
      ),
      (
        strings.metricEffectiveDepositionRate,
        _number(result.depositionRateKgPerHour, 2),
        'kg/h',
      ),
    ];

    return pw.Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final metric in metrics)
          pw.Container(
            width: 250,
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(14),
              border: pw.Border.all(color: _line, width: 0.9),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 28,
                  height: 4,
                  decoration: pw.BoxDecoration(
                    color: _brandOrange,
                    borderRadius: pw.BorderRadius.circular(2),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  metric.$1,
                  style: pw.TextStyle(
                    color: _muted,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: metric.$2,
                        style: pw.TextStyle(
                          color: _ink,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      if (metric.$3.isNotEmpty)
                        pw.TextSpan(
                          text: ' ${metric.$3}',
                          style: const pw.TextStyle(
                            color: _muted,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  pw.Widget _buildIndicatorGrid(List<_ReportIndicator> indicators) {
    return pw.Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final indicator in indicators)
          pw.Container(
            width: 190,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(12),
              border: pw.Border.all(color: _line, width: 0.8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  indicator.label,
                  style: pw.TextStyle(
                    color: _muted,
                    fontSize: 8.8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  indicator.formatted,
                  style: pw.TextStyle(
                    color: _ink,
                    fontSize: 12.5,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  pw.Widget _buildProcessBreakdownTable(
    List<ProcessBreakdown> breakdowns,
    L10nStrings strings,
  ) {
    return pw.TableHelper.fromTextArray(
      border: pw.TableBorder.all(color: _line, width: 0.7),
      headerDecoration: const pw.BoxDecoration(color: _brandTealSoft),
      headerStyle: pw.TextStyle(
        color: _brandTeal,
        fontWeight: pw.FontWeight.bold,
        fontSize: 9,
      ),
      cellStyle: const pw.TextStyle(color: _ink, fontSize: 9.2),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      headers: [
        strings.basisProcess,
        strings.pdfBreakdownColAreaShare,
        strings.pdfBreakdownColWeldMetalKg,
        strings.pdfBreakdownColFillerKg,
        strings.pdfBreakdownColArcOnTimeH,
        strings.pdfBreakdownColRateKgPerH,
        strings.pdfBreakdownColEfficiency,
      ],
      data: [
        for (final breakdown in breakdowns)
          [
            breakdown.process.label,
            _percent(breakdown.sharePercent),
            _number(breakdown.weldMetalKg, 3),
            _number(breakdown.fillerKg, 3),
            _number(breakdown.arcTimeHours, 3),
            _number(breakdown.depositionRateKgPerHour, 2),
            _percent(breakdown.depositionEfficiency),
          ],
      ],
    );
  }

  /// Renders a basis section as two flat, top-level widgets (title strip +
  /// table) rather than one Container wrapping both. A decorated Container
  /// can't be split across a page break in this PDF widgets library — if the
  /// table inside it overflows the page, the whole container (background,
  /// border, and all) gets pushed as one unit, leaving an empty decorated
  /// box behind and the table orphaned on the next page. Two independent
  /// top-level widgets, by contrast, each break cleanly on their own.
  List<pw.Widget> _buildBasisSectionWidgets(
    _BasisSection section,
    L10nStrings strings,
  ) {
    return [
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: pw.BoxDecoration(
          color: section.accentBackground,
          borderRadius: const pw.BorderRadius.vertical(
            top: pw.Radius.circular(14),
          ),
          border: pw.Border.all(color: _line, width: 0.8),
        ),
        child: pw.Text(
          section.title,
          style: pw.TextStyle(
            color: section.accentColor,
            fontSize: 12.5,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
      pw.TableHelper.fromTextArray(
        border: pw.TableBorder(
          left: const pw.BorderSide(color: _line, width: 0.8),
          right: const pw.BorderSide(color: _line, width: 0.8),
          bottom: const pw.BorderSide(color: _line, width: 0.8),
          horizontalInside: const pw.BorderSide(color: _line, width: 0.7),
          verticalInside: const pw.BorderSide(color: _line, width: 0.7),
        ),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.white),
        headerStyle: pw.TextStyle(
          color: _muted,
          fontWeight: pw.FontWeight.bold,
          fontSize: 8.8,
        ),
        rowDecoration: pw.BoxDecoration(color: section.accentBackground),
        cellStyle: const pw.TextStyle(color: _ink, fontSize: 9.4),
        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        headers: [strings.pdfBasisColParameter, strings.pdfBasisColValue],
        data: [
          for (final item in section.entries)
            [item.key.labelFor(strings), item.localizedValue],
        ],
      ),
    ];
  }

  pw.Widget _buildMethodologyPanel(L10nStrings strings) {
    final formulas = [
      strings.pdfFormulaVolume,
      strings.pdfFormulaWeldMetal,
      strings.pdfFormulaFillerConsumption,
      strings.pdfFormulaArcOnTime,
    ];

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _panel,
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: _line, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (final formula in formulas)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(10),
                  border: pw.Border.all(color: _line, width: 0.6),
                ),
                child: pw.Text(
                  formula,
                  style: pw.TextStyle(
                    color: _ink,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildEngineeringNotes(L10nStrings strings) {
    final notes = [
      strings.pdfNote1,
      strings.pdfNote2,
      strings.pdfNote3,
      strings.pdfNote4,
      strings.pdfNote5,
      strings.pdfNote6,
    ];

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _brandTealSoft,
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: _line, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          for (final note in notes)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 6,
                    height: 6,
                    margin: const pw.EdgeInsets.only(top: 4, right: 8),
                    decoration: pw.BoxDecoration(
                      color: _brandOrange,
                      borderRadius: pw.BorderRadius.circular(1.5),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      note,
                      style: const pw.TextStyle(
                        color: _ink,
                        fontSize: 10.5,
                        lineSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<_ReportIndicator> _buildIndicators(
    WeldCalculationResult result,
    List<CalculationBasisItem> basisEntries,
    L10nStrings strings,
  ) {
    final quantity =
        _basisValueAsDouble(basisEntries, BasisKey.quantity) ?? 1.0;
    final totalLengthMeters = result.lengthMm / 1000;
    final fillerPerMeter = totalLengthMeters > 0
        ? result.fillerKg / totalLengthMeters
        : 0.0;
    final weldMetalPerMeter = totalLengthMeters > 0
        ? result.weldMetalKg / totalLengthMeters
        : 0.0;
    final arcMinutesPerMeter = totalLengthMeters > 0
        ? (result.arcTimeHours * 60) / totalLengthMeters
        : 0.0;
    final fillerPerJoint = quantity > 0 ? result.fillerKg / quantity : 0.0;
    final arcMinutesPerJoint = quantity > 0
        ? (result.arcTimeHours * 60) / quantity
        : 0.0;
    final theoreticalWithoutWaste = result.depositionEfficiency == 0
        ? 0.0
        : result.weldMetalKg / result.depositionEfficiency;
    final wasteAllowanceKg = result.fillerKg - theoreticalWithoutWaste;
    final efficiencyLossKg = theoreticalWithoutWaste - result.weldMetalKg;
    final multiplier = result.weldMetalKg == 0
        ? 0.0
        : result.fillerKg / result.weldMetalKg;

    return [
      _ReportIndicator(
        _IndicatorKind.fillerPerMeter,
        strings.resultsHighlightFillerPerMeter,
        '${_number(fillerPerMeter, 3)} kg/m',
      ),
      _ReportIndicator(
        _IndicatorKind.weldMetalPerMeter,
        strings.insightWeldMetalPerMeter,
        '${_number(weldMetalPerMeter, 3)} kg/m',
      ),
      _ReportIndicator(
        _IndicatorKind.arcOnPerMeter,
        strings.resultsHighlightArcOnPerMeter,
        '${_number(arcMinutesPerMeter, 2)} min/m',
      ),
      _ReportIndicator(
        _IndicatorKind.fillerPerJoint,
        strings.insightFillerPerJoint,
        '${_number(fillerPerJoint, 3)} kg/joint',
      ),
      _ReportIndicator(
        _IndicatorKind.arcOnPerJoint,
        strings.insightArcOnPerJoint,
        '${_number(arcMinutesPerJoint, 2)} min/joint',
      ),
      _ReportIndicator(
        _IndicatorKind.efficiencyLossBasis,
        strings.insightEfficiencyLossBasis,
        '${_number(efficiencyLossKg, 3)} kg',
      ),
      _ReportIndicator(
        _IndicatorKind.wasteAllowanceBasis,
        strings.insightWasteAllowanceBasis,
        '${_number(wasteAllowanceKg, 3)} kg',
      ),
      _ReportIndicator(
        _IndicatorKind.consumptionMultiplier,
        strings.insightConsumptionMultiplier,
        '${_number(multiplier, 3)} x',
      ),
    ];
  }

  List<_BasisSection> _groupBasisEntries(
    List<CalculationBasisItem> entries,
    L10nStrings strings,
  ) {
    const setupOrder = [
      BasisKey.process,
      BasisKey.rateBasis,
      BasisKey.inputPreset,
      BasisKey.savedPreset,
      BasisKey.joint,
      BasisKey.geometry,
      BasisKey.alignment,
      BasisKey.groove,
      BasisKey.classification,
      BasisKey.fillerMetalFamily,
      BasisKey.density,
      BasisKey.wasteAllowance,
      BasisKey.quantity,
    ];
    const geometryOrder = [
      BasisKey.weldLengthPerPiece,
      BasisKey.pipeOd,
      BasisKey.odA,
      BasisKey.odB,
      BasisKey.referenceOd,
      BasisKey.thickness,
      BasisKey.thicknessA,
      BasisKey.thicknessB,
      BasisKey.controllingThickness,
      BasisKey.rootGap,
      BasisKey.rootFace,
      BasisKey.rootFacePerSide,
      BasisKey.bevelAngle,
      BasisKey.primaryBevelAngle,
      BasisKey.secondaryBevelAngle,
      BasisKey.breakHeight,
      BasisKey.capOverlap,
      BasisKey.capHeight,
      BasisKey.filletLegSize,
    ];
    const processOrder = [
      BasisKey.userDefinedRate,
      BasisKey.wireDiameter,
      BasisKey.electrodeDiameter,
      BasisKey.gtawTransitionDepth,
      BasisKey.gtawWireDiameter,
      BasisKey.smawElectrodeDiameter,
      BasisKey.gtawDepositionRate,
      BasisKey.smawDepositionRate,
    ];

    final setup = _orderedEntries(entries, setupOrder);
    final geometry = _orderedEntries(entries, geometryOrder);
    final process = _orderedEntries(entries, processOrder);

    // Each entry must be claimed by exactly one of the ordered lists above,
    // or it silently vanishes from the PDF with no error -- this has bitten
    // this file before (a new cap-dimension label needed manual patching
    // into these lists). Fail loudly in debug/test so a future omission is
    // caught immediately, and fall back to a catch-all section in release
    // builds so real user data is never just dropped.
    final claimedKeys = {...setupOrder, ...geometryOrder, ...processOrder};
    final unclaimed = [
      for (final entry in entries)
        if (!claimedKeys.contains(entry.key)) entry,
    ];
    assert(
      unclaimed.isEmpty,
      'PDF basis entries not claimed by setupOrder/geometryOrder/'
      'processOrder, would be silently dropped: '
      '${unclaimed.map((e) => e.key).join(', ')}',
    );

    return [
      if (setup.isNotEmpty)
        _BasisSection(
          title: strings.pdfBasisGroupSetup,
          entries: setup,
          accentColor: _brandTeal,
          accentBackground: _panel,
        ),
      if (geometry.isNotEmpty)
        _BasisSection(
          title: strings.pdfBasisGroupGeometry,
          entries: geometry,
          accentColor: _brandOrange,
          accentBackground: _brandOrangeSoft,
        ),
      if (process.isNotEmpty)
        _BasisSection(
          title: strings.pdfBasisGroupProcess,
          entries: process,
          accentColor: _brandTeal2,
          accentBackground: _brandTealSoft,
        ),
      if (unclaimed.isNotEmpty)
        _BasisSection(
          title: strings.pdfBasisGroupOther,
          entries: unclaimed,
          accentColor: _brandTeal2,
          accentBackground: _brandTealSoft,
        ),
    ];
  }

  List<CalculationBasisItem> _orderedEntries(
    List<CalculationBasisItem> source,
    List<BasisKey> order,
  ) {
    final byKey = {for (final item in source) item.key: item};
    return [
      for (final key in order)
        if (byKey.containsKey(key)) byKey[key]!,
    ];
  }

  double? _basisValueAsDouble(
    List<CalculationBasisItem> entries,
    BasisKey key,
  ) {
    for (final item in entries) {
      if (item.key != key) continue;
      return parseBasisNumber(item.value);
    }
    return null;
  }

  pw.Widget _buildSectionTitle(String title, String subtitle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            color: _ink,
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          subtitle,
          style: const pw.TextStyle(
            color: _muted,
            fontSize: 10,
            lineSpacing: 2,
          ),
        ),
      ],
    );
  }

  pw.Widget _summaryChip(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColor.fromInt(0x66FFFFFF), width: 0.6),
      ),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label: ',
              style: pw.TextStyle(
                color: _brandTeal,
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.TextSpan(
              text: value,
              style: const pw.TextStyle(color: _ink, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _miniChip(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _line, width: 0.6),
      ),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: '$label: ',
              style: pw.TextStyle(
                color: _muted,
                fontSize: 8.8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.TextSpan(
              text: value,
              style: pw.TextStyle(
                color: _ink,
                fontSize: 8.8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildFileName({
    required JointType jointType,
    required GrooveType grooveType,
    required WeldingProcess weldingProcess,
    required DateTime generatedAt,
  }) {
    final joint = _slug(jointType.label);
    final groove = _slug(grooveType.label);
    final process = _slug(weldingProcess.label);
    final stamp =
        '${generatedAt.year}${_two(generatedAt.month)}${_two(generatedAt.day)}_${_two(generatedAt.hour)}${_two(generatedAt.minute)}';
    return 'weld_report_${joint}_${groove}_${process}_$stamp.pdf';
  }

  String _slug(String value) => value
      .toLowerCase()
      .replaceAll('+', 'plus')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  String _number(double value, int digits) => value.toStringAsFixed(digits);

  String _percent(double ratio, {int digits = 1}) =>
      '${(ratio * 100).toStringAsFixed(digits)}%';

  String _two(int value) => value.toString().padLeft(2, '0');

  /// Custom filler materials may have no AWS spec on file -- omit that
  /// segment entirely rather than printing a literal "null".
  String _classificationLabel(ConsumableSelection selection) {
    final awsSpec = selection.awsSpecification;
    return awsSpec == null ? selection.label : '$awsSpec ${selection.label}';
  }
}

// Identifies a [_ReportIndicator] independent of its (now localized) display
// label, so lookups elsewhere (e.g. the readiness banner's mini chips) don't
// have to match on translated text.
enum _IndicatorKind {
  fillerPerMeter,
  weldMetalPerMeter,
  arcOnPerMeter,
  fillerPerJoint,
  arcOnPerJoint,
  efficiencyLossBasis,
  wasteAllowanceBasis,
  consumptionMultiplier,
}

class _ReportIndicator {
  const _ReportIndicator(this.kind, this.label, this.formatted);

  final _IndicatorKind kind;
  final String label;
  final String formatted;
}

class _BasisSection {
  const _BasisSection({
    required this.title,
    required this.entries,
    required this.accentColor,
    required this.accentBackground,
  });

  final String title;
  final List<CalculationBasisItem> entries;
  final PdfColor accentColor;
  final PdfColor accentBackground;
}

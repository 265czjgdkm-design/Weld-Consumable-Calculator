import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/basis_value_parsing.dart';
import '../models/consumable_selection.dart';
import '../models/weld_models.dart';

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

  Future<Uint8List> buildReportBytes({
    required JointType jointType,
    required GrooveType grooveType,
    required WeldingProcess weldingProcess,
    required ConsumableSelection consumableSelection,
    required WeldCalculationResult result,
    required List<MapEntry<String, String>> basisEntries,
  }) async {
    final generatedAt = DateTime.now();
    final document = pw.Document(
      title: 'Weld Estimation Report',
      author: 'Varyos Weld',
      creator: 'Varyos Weld',
      subject: 'Weld consumable estimation report',
    );

    final reportId =
        'VW-${generatedAt.year}${_two(generatedAt.month)}${_two(generatedAt.day)}-${_two(generatedAt.hour)}${_two(generatedAt.minute)}${_two(generatedAt.second)}';
    final indicators = _buildIndicators(result, basisEntries);
    final basisSections = _groupBasisEntries(basisEntries);

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => _buildCoverPage(
          reportId: reportId,
          jointType: jointType,
          grooveType: grooveType,
          weldingProcess: weldingProcess,
          consumableSelection: consumableSelection,
          generatedAt: generatedAt,
          result: result,
        ),
      ),
    );

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 32),
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
                'Page ${context.pageNumber} / ${context.pagesCount}',
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
          ),
          pw.SizedBox(height: 16),
          _buildReadinessBanner(result, indicators),
          pw.SizedBox(height: 18),
          _buildSectionTitle(
            'Executive Summary',
            'Primary estimate outputs prepared for engineering review and shop planning.',
          ),
          pw.SizedBox(height: 10),
          _buildMetricGrid(result),
          pw.SizedBox(height: 18),
          _buildSectionTitle(
            'Planning Indicators',
            'Normalized performance indicators for comparing joints, labor load, and consumable demand.',
          ),
          pw.SizedBox(height: 10),
          _buildIndicatorGrid(indicators),
          pw.SizedBox(height: 18),
          if (result.processBreakdowns.length > 1) ...[
            _buildSectionTitle(
              'Process Breakdown',
              'Split estimate showing deposited weld metal, filler demand, and arc-on time by process segment.',
            ),
            pw.SizedBox(height: 10),
            _buildProcessBreakdownTable(result.processBreakdowns),
            pw.SizedBox(height: 18),
          ],
          _buildSectionTitle(
            'Engineering Basis',
            'Input selections and governing geometry used to calculate the estimate.',
          ),
          pw.SizedBox(height: 10),
          for (final section in basisSections) ...[
            ..._buildBasisSectionWidgets(section),
            pw.SizedBox(height: 12),
          ],
          pw.NewPage(),
          _buildSectionTitle(
            'Calculation Method',
            'Formula basis used in the application for weld volume, weld metal, filler consumption, and arc-on time.',
          ),
          pw.SizedBox(height: 10),
          _buildMethodologyPanel(),
          pw.SizedBox(height: 18),
          _buildSectionTitle(
            'Engineering Notes',
            'Practical interpretation notes for planning, estimating, and report handoff.',
          ),
          pw.SizedBox(height: 10),
          _buildEngineeringNotes(),
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
    required List<MapEntry<String, String>> basisEntries,
  }) async {
    final generatedAt = DateTime.now();
    final bytes = await buildReportBytes(
      jointType: jointType,
      grooveType: grooveType,
      weldingProcess: weldingProcess,
      consumableSelection: consumableSelection,
      result: result,
      basisEntries: basisEntries,
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
              'Weld Engineering Report',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 34,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Professional estimate of weld geometry, weld metal, filler metal consumption, and process-based arc-on time, prepared for engineering review and shop planning.',
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
                _summaryChip('Joint', jointType.label),
                _summaryChip('Groove', grooveType.label),
                _summaryChip('Process', weldingProcess.label),
                _summaryChip(
                  'Classification',
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
                    'Filler Metal Consumption',
                    '${_number(result.fillerKg, 3)} kg',
                  ),
                  _coverHeadline(
                    'Estimated Arc-On Time',
                    '${_number(result.arcTimeHours, 3)} h',
                  ),
                  _coverHeadline(
                    'Effective Deposition Rate',
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
                    'Report ID: $reportId',
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 9.5,
                    ),
                  ),
                  pw.Text(
                    'Generated ${generatedAt.year}-${_two(generatedAt.month)}-${_two(generatedAt.day)} ${_two(generatedAt.hour)}:${_two(generatedAt.minute)}',
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
                      'Weld Engineering Report',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Professional estimate of weld geometry, weld metal, filler metal consumption, and process-based arc-on time for planning and review.',
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
                      'REPORT ID',
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
              _summaryChip('Joint', jointType.label),
              _summaryChip('Groove', grooveType.label),
              _summaryChip('Process', weldingProcess.label),
              _summaryChip(
                'Classification',
                _classificationLabel(consumableSelection),
              ),
              _summaryChip('Family', consumableSelection.family.label),
              _summaryChip(
                'Generated',
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
  ) {
    final fillerPerMeter = indicators
        .firstWhere((item) => item.label == 'Filler per Meter')
        .formatted;
    final arcPerMeter = indicators
        .firstWhere((item) => item.label == 'Arc-On per Meter')
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
              'ESTIMATE READY',
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
            'Estimated filler metal consumption is ${_number(result.fillerKg, 3)} kg with ${_number(result.arcTimeHours, 3)} h of arc-on time.',
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
                'Effective Deposition Rate',
                '${_number(result.depositionRateKgPerHour, 2)} kg/h',
              ),
              _miniChip('Filler per Meter', fillerPerMeter),
              _miniChip('Arc-On per Meter', arcPerMeter),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMetricGrid(WeldCalculationResult result) {
    final metrics = [
      ('Weld Area', _number(result.areaMm2, 2), 'mm2'),
      ('Weld Length', _number(result.lengthMm, 2), 'mm'),
      ('Weld Metal Volume', _number(result.volumeCm3, 3), 'cm3'),
      ('Weld Metal Weight', _number(result.weldMetalKg, 3), 'kg'),
      ('Filler Metal Consumption', _number(result.fillerKg, 3), 'kg'),
      ('Estimated Arc-On Time', _number(result.arcTimeHours, 3), 'h'),
      (
        'Effective Deposition Efficiency',
        _percent(result.depositionEfficiency),
        '',
      ),
      (
        'Effective Deposition Rate',
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

  pw.Widget _buildProcessBreakdownTable(List<ProcessBreakdown> breakdowns) {
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
      headers: const [
        'Process',
        'Area Share',
        'Weld Metal (kg)',
        'Filler (kg)',
        'Arc-On Time (h)',
        'Rate (kg/h)',
        'Efficiency',
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
  List<pw.Widget> _buildBasisSectionWidgets(_BasisSection section) {
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
        cellPadding: const pw.EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 7,
        ),
        headers: const ['Parameter', 'Value'],
        data: [
          for (final entry in section.entries) [entry.key, entry.value],
        ],
      ),
    ];
  }

  pw.Widget _buildMethodologyPanel() {
    final formulas = [
      'Volume (cm3) = Area (mm2) x Length (mm) / 1000',
      'Weld Metal (kg) = Volume (cm3) x Density (g/cm3) / 1000',
      'Filler Consumption (kg) = Weld Metal / Deposition Efficiency x (1 + Waste / 100)',
      'Arc-On Time (h) = Filler Consumption / Deposition Rate',
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

  pw.Widget _buildEngineeringNotes() {
    final notes = [
      'Arc-on time covers active welding time only. Fit-up, tacking, interpass cleaning, repositioning, and inspection time are excluded.',
      'Filler metal consumption includes deposition efficiency loss and the entered waste allowance. It should be treated as planning consumption, not exact issued weight.',
      'Combined GTAW + SMAW output distributes weld metal and time by calculated process share using the entered transition depth.',
      'Deposition efficiency factors used above (SMAW ~65%, FCAW ~85%, GMAW ~90%, GTAW ~95%) reflect typical industry ranges, consistent with figures published in Lincoln Electric\'s Procedure Handbook of Arc Welding.',
      'This report is intended for estimating and engineering planning. Approved project documentation, client specifications, and production controls must always take precedence.',
      'This is a first-pass planning estimate - confirm against your qualified WPS and a test coupon before production use.',
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
    List<MapEntry<String, String>> basisEntries,
  ) {
    final quantity = _basisValueAsDouble(basisEntries, 'Quantity') ?? 1.0;
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
        'Filler per Meter',
        '${_number(fillerPerMeter, 3)} kg/m',
      ),
      _ReportIndicator(
        'Weld Metal per Meter',
        '${_number(weldMetalPerMeter, 3)} kg/m',
      ),
      _ReportIndicator(
        'Arc-On per Meter',
        '${_number(arcMinutesPerMeter, 2)} min/m',
      ),
      _ReportIndicator(
        'Filler per Joint',
        '${_number(fillerPerJoint, 3)} kg/joint',
      ),
      _ReportIndicator(
        'Arc-On per Joint',
        '${_number(arcMinutesPerJoint, 2)} min/joint',
      ),
      _ReportIndicator(
        'Efficiency Loss Basis',
        '${_number(efficiencyLossKg, 3)} kg',
      ),
      _ReportIndicator(
        'Waste Allowance Basis',
        '${_number(wasteAllowanceKg, 3)} kg',
      ),
      _ReportIndicator('Consumption Multiplier', '${_number(multiplier, 3)} x'),
    ];
  }

  List<_BasisSection> _groupBasisEntries(
    List<MapEntry<String, String>> entries,
  ) {
    const setupOrder = [
      'Process',
      'Rate Basis',
      'Input Preset',
      'Saved Preset',
      'Joint',
      'Geometry',
      'Alignment',
      'Groove',
      'Classification',
      'Filler Metal Family',
      'Density',
      'Waste Allowance',
      'Quantity',
    ];
    const geometryOrder = [
      'Weld Length per Piece',
      'Pipe OD',
      'OD A',
      'OD B',
      'Reference OD',
      'Thickness',
      'Thickness A',
      'Thickness B',
      'Controlling Thickness',
      'Root Gap',
      'Root Face',
      'Root Face per Side',
      'Bevel Angle',
      'Primary Bevel Angle',
      'Secondary Bevel Angle',
      'Break Height',
      'Fillet Leg Size',
    ];
    const processOrder = [
      'User-defined Rate',
      'Wire Diameter',
      'Electrode Diameter',
      'GTAW Transition Depth',
      'GTAW Wire Diameter',
      'SMAW Electrode Diameter',
      'GTAW Deposition Rate',
      'SMAW Deposition Rate',
    ];

    final setup = _orderedEntries(entries, setupOrder);
    final geometry = _orderedEntries(entries, geometryOrder);
    final process = _orderedEntries(entries, processOrder);

    return [
      if (setup.isNotEmpty)
        _BasisSection(
          title: 'Setup and Assumptions',
          entries: setup,
          accentColor: _brandTeal,
          accentBackground: _panel,
        ),
      if (geometry.isNotEmpty)
        _BasisSection(
          title: 'Joint Geometry',
          entries: geometry,
          accentColor: _brandOrange,
          accentBackground: _brandOrangeSoft,
        ),
      if (process.isNotEmpty)
        _BasisSection(
          title: 'Process Parameters',
          entries: process,
          accentColor: _brandTeal2,
          accentBackground: _brandTealSoft,
        ),
    ];
  }

  List<MapEntry<String, String>> _orderedEntries(
    List<MapEntry<String, String>> source,
    List<String> order,
  ) {
    final byKey = {for (final entry in source) entry.key: entry.value};
    return [
      for (final key in order)
        if (byKey.containsKey(key)) MapEntry(key, byKey[key]!),
    ];
  }

  double? _basisValueAsDouble(
    List<MapEntry<String, String>> entries,
    String label,
  ) {
    for (final entry in entries) {
      if (entry.key != label) continue;
      return parseBasisNumber(entry.value);
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

class _ReportIndicator {
  const _ReportIndicator(this.label, this.formatted);

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
  final List<MapEntry<String, String>> entries;
  final PdfColor accentColor;
  final PdfColor accentBackground;
}

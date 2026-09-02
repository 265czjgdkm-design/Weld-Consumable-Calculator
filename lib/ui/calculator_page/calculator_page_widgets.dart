import 'package:flutter/material.dart';

import '../../core/weld_formulas.dart';
import '../../l10n/app_language.dart';
import '../../l10n/app_locale_scope.dart';
import '../../models/consumable_selection.dart';
import '../../models/weld_models.dart';
import '../widgets/result_card.dart';
import 'calculator_page_models.dart';

/// The Varyos brand mark: two struck blades meeting at one point of
/// impact. Drawn as vector shapes (not a raster asset) so it stays crisp
/// at any size, from a 22px nav icon up to a full hero mark.
class VaryosMark extends StatelessWidget {
  const VaryosMark({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _VaryosMarkPainter()),
    );
  }
}

class _VaryosMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 200;
    Offset p(double x, double y) => Offset(x * scale, y * scale);

    final bladePaint = Paint()..color = Colors.white;
    final leftBlade = Path()
      ..moveTo(p(40, 25).dx, p(40, 25).dy)
      ..lineTo(p(65, 25).dx, p(65, 25).dy)
      ..lineTo(p(108, 168).dx, p(108, 168).dy)
      ..lineTo(p(83, 168).dx, p(83, 168).dy)
      ..close();
    final rightBlade = Path()
      ..moveTo(p(160, 25).dx, p(160, 25).dy)
      ..lineTo(p(135, 25).dx, p(135, 25).dy)
      ..lineTo(p(92, 168).dx, p(92, 168).dy)
      ..lineTo(p(117, 168).dx, p(117, 168).dy)
      ..close();
    canvas.drawPath(leftBlade, bladePaint);
    canvas.drawPath(rightBlade, bladePaint);

    final sparkPaint = Paint()..color = const Color(0xFFFF6A35);
    final spark = Path()
      ..moveTo(p(100, 136).dx, p(100, 136).dy)
      ..lineTo(p(112, 158).dx, p(112, 158).dy)
      ..lineTo(p(100, 180).dx, p(100, 180).dy)
      ..lineTo(p(88, 158).dx, p(88, 158).dy)
      ..close();
    canvas.drawPath(spark, sparkPaint);
  }

  @override
  bool shouldRepaint(covariant _VaryosMarkPainter oldDelegate) => false;
}

/// A small circular back affordance for screens reached via
/// `Navigator.push` from the home dashboard that don't use an [AppBar]
/// (which would otherwise auto-add one). Guarded by `canPop()` in case the
/// screen is ever reached some other way. Placed right before
/// [TopNavigationBar] in the layout.
class BackToDashboardButton extends StatelessWidget {
  const BackToDashboardButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Navigator.of(context).canPop()) return const SizedBox.shrink();
    final strings = AppLocaleScope.stringsOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: IconButton.filledTonal(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back),
        tooltip: strings.calcBackToDashboardTooltip,
      ),
    );
  }
}

class TopNavigationBar extends StatelessWidget {
  const TopNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.white.withValues(alpha: 0.84),
        border: Border.all(color: const Color(0xFFDCE5EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F3040),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 900;

          final identity = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B2326), Color(0xFF0B0F10)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(child: VaryosMark(size: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'VARYOS',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'WELD',
                          style: TextStyle(
                            color: Color(0xFFFF6A35),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      strings.navSubtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          );

          final pills = Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusPill(
                label: strings.navPillEstimator,
                color: const Color(0xFFE8F2F5),
                textColor: const Color(0xFF12191B),
              ),
              StatusPill(
                label: strings.navPillPdf,
                color: const Color(0xFFF1F5F8),
                textColor: const Color(0xFF395361),
              ),
              StatusPill(
                label: strings.navPillAws,
                color: const Color(0xFFF1F5F8),
                textColor: const Color(0xFF395361),
              ),
              const LanguagePickerButton(),
            ],
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [identity, const SizedBox(height: 14), pills],
            );
          }

          return Row(
            children: [
              Expanded(child: identity),
              const SizedBox(width: 20),
              Flexible(child: pills),
            ],
          );
        },
      ),
    );
  }
}

class ExperienceHero extends StatelessWidget {
  const ExperienceHero({
    super.key,
    required this.jointTypeLabel,
    required this.grooveLabel,
    required this.processLabel,
    required this.drawingModeLabel,
    required this.consumableLabel,
    required this.savedPresetCount,
    required this.hasResults,
  });

  final String jointTypeLabel;
  final String grooveLabel;
  final String processLabel;
  final String drawingModeLabel;
  final String consumableLabel;
  final int savedPresetCount;
  final bool hasResults;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    final heroSignals = [
      (strings.heroSignalLiveJoint, jointTypeLabel),
      (strings.heroSignalGroove, grooveLabel),
      (strings.heroSignalProcess, processLabel),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF232D30), Color(0xFF14191A), Color(0xFF0B0F10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220F3040),
            blurRadius: 34,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 980;
          final intro = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x26FFFFFF),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x32FFFFFF)),
                ),
                child: Text(
                  strings.heroTag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 660),
                child: Text(
                  strings.heroTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Text(
                  strings.heroBody,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFD9EBEF),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final signal in heroSignals)
                    HeroSignalCard(label: signal.$1, value: signal.$2),
                ],
              ),
            ],
          );

          final cockpit = Container(
            width: stacked ? double.infinity : 330,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0x1CFFFFFF),
              border: Border.all(color: const Color(0x2AFFFFFF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.snapshotTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 14),
                SnapshotRow(
                  label: strings.snapshotDrawingMode,
                  value: drawingModeLabel,
                ),
                SnapshotRow(
                  label: strings.snapshotConsumable,
                  value: consumableLabel,
                ),
                SnapshotRow(
                  label: strings.snapshotSavedPresets,
                  value: savedPresetCount.toString(),
                ),
                SnapshotRow(
                  label: strings.snapshotEstimateState,
                  value: hasResults
                      ? strings.snapshotCalculated
                      : strings.snapshotAwaitingRun,
                ),
              ],
            ),
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [intro, const SizedBox(height: 18), cockpit],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: intro),
              const SizedBox(width: 18),
              cockpit,
            ],
          );
        },
      ),
    );
  }
}

class CapabilityStrip extends StatelessWidget {
  const CapabilityStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    final items = [
      (
        Icons.calculate_outlined,
        strings.capabilityDailyTitle,
        strings.capabilityDailyDesc,
      ),
      (
        Icons.draw_outlined,
        strings.capabilityDrawingTitle,
        strings.capabilityDrawingDesc,
      ),
      (
        Icons.picture_as_pdf_outlined,
        strings.capabilityReportTitle,
        strings.capabilityReportDesc,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 980;
        final width = compact
            ? constraints.maxWidth
            : (constraints.maxWidth - 24) / 3;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: CapabilityCard(
                  icon: item.$1,
                  title: item.$2,
                  description: item.$3,
                ),
              ),
          ],
        );
      },
    );
  }
}

class CapabilityCard extends StatelessWidget {
  const CapabilityCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: 0.84),
        border: Border.all(color: const Color(0xFFDCE5EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFFE8F1F5),
            ),
            child: Icon(icon, color: const Color(0xFF12191B)),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF607482)),
          ),
        ],
      ),
    );
  }
}

class HeroSignalCard extends StatelessWidget {
  const HeroSignalCard({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x16FFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x24FFFFFF)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Color(0xFFD9EBEF),
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class SnapshotRow extends StatelessWidget {
  const SnapshotRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFD0E6EA),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// A small pill showing the current language's flag + code that opens a
/// menu of every supported language. Reused wherever the app needs a
/// language switcher (currently the top nav bar).
class LanguagePickerButton extends StatelessWidget {
  const LanguagePickerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocaleScope.of(context);
    final strings = AppLocaleScope.stringsOf(context);

    return PopupMenuButton<AppLanguage>(
      tooltip: strings.languagePickerTitle,
      initialValue: locale.language,
      onSelected: locale.setLanguage,
      itemBuilder: (context) => [
        for (final language in AppLanguage.values)
          PopupMenuItem<AppLanguage>(
            value: language,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(language.flagEmoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Text(language.nativeName),
                if (language == locale.language) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.check, size: 16),
                ],
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F8),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFD6E0E6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              locale.language.flagEmoji,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(width: 6),
            Text(
              locale.language.code.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF395361),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.expand_more, size: 14, color: Color(0xFF395361)),
          ],
        ),
      ),
    );
  }
}

class EmptyResultsState extends StatelessWidget {
  const EmptyResultsState({super.key, required this.process});

  final WeldingProcess process;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.calcResultsTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          process == WeldingProcess.gtawSmaw
              ? strings.calcEmptyResultsBodyGtawSmaw
              : strings.calcEmptyResultsBodyDefault.replaceFirst(
                  '{process}',
                  process.label,
                ),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF607482)),
        ),
      ],
    );
  }
}

class InputPanelSection extends StatelessWidget {
  const InputPanelSection({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFFFCFDFE), Color(0xFFF3F8FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFDCE5EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFFE8F1F5),
                  border: Border.all(color: const Color(0xFFD6E2E8)),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF12191B)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF607482),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class PanelNote extends StatelessWidget {
  const PanelNote({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE5EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4E6875)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class ResultsSection extends StatelessWidget {
  const ResultsSection({
    super.key,
    required this.result,
    required this.basis,
    required this.consumableSelection,
    required this.onPdfPressed,
    required this.pdfBusy,
    this.pdfLocked = false,
  });

  final WeldCalculationResult result;
  final List<CalculationBasisItem> basis;
  final ConsumableSelection consumableSelection;
  final VoidCallback? onPdfPressed;
  final bool pdfBusy;
  final bool pdfLocked;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    final quantity = _basisNumber(BasisKey.quantity) ?? 1;
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
    final currentLegSizeMm = _basisNumber(BasisKey.filletLegSize);
    final nextStandardLegSizeMm =
        currentLegSizeMm != null && currentLegSizeMm > 0
        ? WeldFormulas.nextStandardFilletLegMm(currentLegSizeMm)
        : null;
    final oversizeDeltaPercent = nextStandardLegSizeMm != null
        ? WeldFormulas.filletOversizeDeltaFraction(
                currentLegMm: currentLegSizeMm!,
                nextLegMm: nextStandardLegSizeMm,
              ) *
              100
        : null;
    final metrics = [
      (
        strings.metricWeldArea,
        _number(result.areaMm2, 2),
        'mm²',
        Icons.square_foot_outlined,
      ),
      (
        strings.metricWeldLength,
        _number(result.lengthMm, 2),
        'mm',
        Icons.straighten_outlined,
      ),
      (
        strings.metricWeldMetalVolume,
        _number(result.volumeCm3, 3),
        'cm³',
        Icons.view_in_ar_outlined,
      ),
      (
        strings.metricWeldMetalWeight,
        _number(result.weldMetalKg, 3),
        'kg',
        Icons.scale_outlined,
      ),
      (
        strings.metricFillerMetalConsumption,
        _number(result.fillerKg, 3),
        'kg',
        Icons.inventory_2_outlined,
      ),
      (
        strings.metricEstimatedArcOnTime,
        _number(result.arcTimeHours, 3),
        'h',
        Icons.timer_outlined,
      ),
      (
        strings.metricEffectiveDepositionEfficiency,
        _percent(result.depositionEfficiency),
        '',
        Icons.speed_outlined,
      ),
      (
        strings.metricEffectiveDepositionRate,
        _number(result.depositionRateKgPerHour, 2),
        'kg/h',
        Icons.bolt_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                strings.calcResultsTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            OutlinedButton.icon(
              onPressed: onPdfPressed,
              icon: pdfBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : Icon(
                      pdfLocked
                          ? Icons.lock_outline
                          : Icons.picture_as_pdf_outlined,
                      size: 18,
                    ),
              label: Text(
                pdfBusy
                    ? strings.resultsPdfPreparing
                    : (pdfLocked
                          ? strings.resultsPdfUnlock
                          : strings.resultsPdfExport),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          strings.resultsSummaryCaption,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF607482)),
        ),
        const SizedBox(height: 6),
        Text(
          strings.resultsDisclaimer,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: const Color(0xFF607482)),
        ),
        const SizedBox(height: 16),
        ResultsHighlightBanner(
          result: result,
          fillerPerMeter: fillerPerMeter,
          arcMinutesPerMeter: arcMinutesPerMeter,
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: 280,
                child: ResultCard(
                  title: metric.$1,
                  value: metric.$2,
                  unit: metric.$3,
                  icon: metric.$4,
                ),
              ),
          ],
        ),
        if (oversizeDeltaPercent != null && nextStandardLegSizeMm != null) ...[
          const SizedBox(height: 10),
          Text(
            strings.resultsNextStandardLeg
                .replaceFirst('{size}', _number(nextStandardLegSizeMm, 0))
                .replaceFirst('{percent}', _number(oversizeDeltaPercent, 1)),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF607482)),
          ),
        ],
        const SizedBox(height: 22),
        PlanningInsightsPanel(
          items: [
            InsightItem(
              label: strings.resultsHighlightFillerPerMeter,
              value: _number(fillerPerMeter, 3),
              unit: 'kg/m',
            ),
            InsightItem(
              label: strings.insightWeldMetalPerMeter,
              value: _number(weldMetalPerMeter, 3),
              unit: 'kg/m',
            ),
            InsightItem(
              label: strings.resultsHighlightArcOnPerMeter,
              value: _number(arcMinutesPerMeter, 2),
              unit: 'min/m',
            ),
            InsightItem(
              label: strings.insightFillerPerJoint,
              value: _number(fillerPerJoint, 3),
              unit: 'kg/joint',
            ),
            InsightItem(
              label: strings.insightArcOnPerJoint,
              value: _number(arcMinutesPerJoint, 2),
              unit: 'min/joint',
            ),
            InsightItem(
              label: strings.insightEfficiencyLossBasis,
              value: _number(efficiencyLossKg, 3),
              unit: 'kg',
            ),
            InsightItem(
              label: strings.insightWasteAllowanceBasis,
              value: _number(wasteAllowanceKg, 3),
              unit: 'kg',
            ),
            InsightItem(
              label: strings.insightConsumptionMultiplier,
              value: _number(
                result.weldMetalKg == 0
                    ? 0
                    : result.fillerKg / result.weldMetalKg,
                3,
              ),
              unit: 'x',
            ),
          ],
        ),
        if (result.processBreakdowns.length > 1) ...[
          const SizedBox(height: 22),
          Text(
            strings.processBreakdownTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            strings.processBreakdownSubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF607482)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final breakdown in result.processBreakdowns)
                SizedBox(
                  width: 280,
                  child: ProcessBreakdownCard(breakdown: breakdown),
                ),
            ],
          ),
        ],
        const SizedBox(height: 22),
        ReportMethodPanel(
          notes: [
            strings.engineeringNote1,
            strings.engineeringNote2,
            strings.engineeringNote3,
            strings.engineeringNote4,
          ],
        ),
        const SizedBox(height: 18),
        CalculationBasisPanel(
          items: basis,
          consumableSelection: consumableSelection,
          subtitle: strings.engineeringBasisSubtitle,
        ),
      ],
    );
  }

  double? _basisNumber(BasisKey key) {
    for (final item in basis) {
      if (item.key != key) continue;
      final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(item.value);
      if (match == null) return null;
      return double.tryParse(match.group(0)!);
    }
    return null;
  }

  static String _number(double value, int digits) =>
      value.toStringAsFixed(digits);

  static String _percent(double ratio, {int digits = 1}) =>
      '${(ratio * 100).toStringAsFixed(digits)}%';
}

class ProcessBreakdownCard extends StatelessWidget {
  const ProcessBreakdownCard({super.key, required this.breakdown});

  final ProcessBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    return Card(
      color: const Color(0xFFF9FBFC),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              breakdown.process.label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              strings.processBreakdownAreaShare.replaceFirst(
                '{value}',
                ResultsSection._number(breakdown.sharePercent * 100, 1),
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF607482),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              strings.processBreakdownWeldMetal.replaceFirst(
                '{value}',
                ResultsSection._number(breakdown.weldMetalKg, 3),
              ),
            ),
            Text(
              strings.processBreakdownFillerConsumption.replaceFirst(
                '{value}',
                ResultsSection._number(breakdown.fillerKg, 3),
              ),
            ),
            Text(
              strings.processBreakdownArcOnTime.replaceFirst(
                '{value}',
                ResultsSection._number(breakdown.arcTimeHours, 3),
              ),
            ),
            Text(
              strings.processBreakdownDepositionRate.replaceFirst(
                '{value}',
                ResultsSection._number(breakdown.depositionRateKgPerHour, 2),
              ),
            ),
            Text(
              strings.processBreakdownDepositionEfficiency.replaceFirst(
                '{value}',
                ResultsSection._percent(breakdown.depositionEfficiency),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalculationBasisPanel extends StatelessWidget {
  const CalculationBasisPanel({
    super.key,
    required this.items,
    required this.consumableSelection,
    required this.subtitle,
  });

  final List<CalculationBasisItem> items;
  final ConsumableSelection consumableSelection;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FBFD), Color(0xFFF1F6F8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFDCE5EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.engineeringBasisTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            consumableSelection.descriptionFor(strings),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF607482)),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF607482)),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final item in items)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDCE5EB)),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF15232D),
                      ),
                      children: [
                        TextSpan(
                          text: '${item.key.labelFor(strings)}: ',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: item.value),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ResultsHighlightBanner extends StatelessWidget {
  const ResultsHighlightBanner({
    super.key,
    required this.result,
    required this.fillerPerMeter,
    required this.arcMinutesPerMeter,
  });

  final WeldCalculationResult result;
  final double fillerPerMeter;
  final double arcMinutesPerMeter;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF1B2326), Color(0xFF0B0F10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x33FFFFFF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              strings.resultsEstimateReadyBadge,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            strings.resultsHighlightSentence
                .replaceFirst(
                  '{filler}',
                  ResultsSection._number(result.fillerKg, 3),
                )
                .replaceFirst(
                  '{arcTime}',
                  ResultsSection._number(result.arcTimeHours, 3),
                ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              HighlightChip(
                label: strings.resultsHighlightEffectiveRate,
                value:
                    '${ResultsSection._number(result.depositionRateKgPerHour, 2)} kg/h',
              ),
              HighlightChip(
                label: strings.resultsHighlightFillerPerMeter,
                value: '${ResultsSection._number(fillerPerMeter, 3)} kg/m',
              ),
              HighlightChip(
                label: strings.resultsHighlightArcOnPerMeter,
                value: '${ResultsSection._number(arcMinutesPerMeter, 2)} min/m',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HighlightChip extends StatelessWidget {
  const HighlightChip({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x1FFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x3DFFFFFF)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Color(0xFFD7ECEF),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class PlanningInsightsPanel extends StatelessWidget {
  const PlanningInsightsPanel({super.key, required this.items});

  final List<InsightItem> items;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FBFD), Color(0xFFF0F6F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFDCE5EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.planningIndicatorsTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            strings.planningIndicatorsSubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF607482)),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final item in items)
                Container(
                  width: 210,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFDCE5EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF607482),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: const Color(0xFF15232D),
                                fontWeight: FontWeight.w800,
                              ),
                          children: [
                            TextSpan(text: item.value),
                            TextSpan(
                              text: ' ${item.unit}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: const Color(0xFF607482),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReportMethodPanel extends StatelessWidget {
  const ReportMethodPanel({super.key, required this.notes});

  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFFAFCFD),
        border: Border.all(color: const Color(0xFFDCE5EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.engineeringNotesTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          for (final note in notes)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12191B),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      note,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF334C58),
                        height: 1.35,
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
}

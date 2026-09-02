import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/en1011_formulas.dart';
import '../l10n/app_locale_scope.dart';
import '../l10n/strings.dart';
import '../models/custom_material_models.dart';
import '../services/custom_base_material_store.dart';
import 'calculator_page/calculator_page_widgets.dart';
import 'cooling_time_calculator_screen.dart';
import 'widgets/formula_breakdown_card.dart';
import 'widgets/heat_input_field.dart';
import 'widgets/optional_number_field.dart';

/// EN 1011-2 Annex C.3 (Method B) preheat temperature calculator. Lives
/// standalone -- no PDF export or saved-history in v1 (see the
/// implementation plan's scope-cut note); results are shown in-app only.
class PreheatCalculatorScreen extends StatefulWidget {
  const PreheatCalculatorScreen({super.key});

  @override
  State<PreheatCalculatorScreen> createState() =>
      _PreheatCalculatorScreenState();
}

/// The 9 composition elements that feed CET / CEV / Pcm on this screen.
/// Nb/Ti/N are captured in the base-material library but feed none of
/// these formulas, so they are deliberately excluded here.
const _elementKeys = [
  'carbon',
  'silicon',
  'manganese',
  'chromium',
  'molybdenum',
  'nickel',
  'copper',
  'vanadium',
  'boron',
];

String _elementLabel(L10nStrings strings, String key) => switch (key) {
  'carbon' => strings.materialFieldCarbon,
  'silicon' => strings.materialFieldSilicon,
  'manganese' => strings.materialFieldManganese,
  'chromium' => strings.materialFieldChromium,
  'molybdenum' => strings.materialFieldMolybdenum,
  'nickel' => strings.materialFieldNickel,
  'copper' => strings.materialFieldCopper,
  'vanadium' => strings.materialFieldVanadium,
  'boron' => strings.materialFieldBoron,
  _ => throw ArgumentError('Unknown element key: $key'),
};

double? _elementValueOf(CustomBaseMaterial material, String key) =>
    switch (key) {
      'carbon' => material.carbonPercent,
      'silicon' => material.siliconPercent,
      'manganese' => material.manganesePercent,
      'chromium' => material.chromiumPercent,
      'molybdenum' => material.molybdenumPercent,
      'nickel' => material.nickelPercent,
      'copper' => material.copperPercent,
      'vanadium' => material.vanadiumPercent,
      'boron' => material.boronPercent,
      _ => throw ArgumentError('Unknown element key: $key'),
    };

/// Ambient reference temperature (°C) EN 1011-2 Method B is implicitly
/// computed against -- a Tp at or below this means no preheat is needed,
/// not a sub-zero preheat target.
const _ambientC = 20.0;

class _PreheatResult {
  const _PreheatResult({
    required this.tp,
    required this.parentCet,
    required this.designCet,
    required this.specialRuleApplied,
    required this.flags,
    required this.cev,
    required this.pcm,
    required this.pcmIsOverride,
    required this.tanhTerm,
    required this.hdTerm,
    required this.qTerm,
    required this.thicknessMm,
    required this.hd,
    required this.heatInputKJPerMm,
    required this.yieldStrengthNPerMm2,
  });

  final double tp;
  final double parentCet;
  final double designCet;
  final bool specialRuleApplied;
  final List<PreheatRangeFlag> flags;
  final double cev;
  final double pcm;
  final bool pcmIsOverride;
  final double tanhTerm;
  final double hdTerm;
  final double qTerm;
  final double thicknessMm;
  final double hd;
  final double heatInputKJPerMm;
  final double? yieldStrengthNPerMm2;

  bool get noPreheatRequired => tp <= _ambientC;
}

class _PreheatCalculatorScreenState extends State<PreheatCalculatorScreen> {
  static const _store = CustomBaseMaterialStore();

  late final Map<String, TextEditingController> _elementControllers = {
    for (final key in _elementKeys) key: TextEditingController(),
  };
  final TextEditingController _weldMetalCetController =
      TextEditingController();
  final TextEditingController _thicknessController = TextEditingController();
  final TextEditingController _hdController = TextEditingController();
  final TextEditingController _yieldController = TextEditingController();

  List<CustomBaseMaterial> _libraryMaterials = const [];
  CustomBaseMaterial? _selectedLibraryMaterial;
  double? _heatInputKJPerMm;

  // Set at load time from the picked material and kept around independently
  // of _selectedLibraryMaterial (which gets reset to null right after load
  // purely to reset the dropdown's visible selection -- see
  // _libraryDropdownResetToken below) so the stored override value is still
  // available to _calculate(). CET is deliberately NOT overridden this way
  // -- unlike Pcm (informational only, see en1011_formulas.dart), CET
  // directly drives the safety-relevant Tp result and the library's CET
  // field has no "measured/certified" semantics over the live composition,
  // so it is always computed fresh from the current composition fields.
  // Pcm's override is cleared on any composition edit via
  // _invalidateLoadedPcmOverride below, so it never goes stale either.
  double? _loadedPcmPercent;

  // Bumped on every load so the dropdown's key changes and it remounts
  // showing null again -- DropdownButtonFormField's `initialValue` is only
  // honored on first build, a setState alone won't reset a visibly-tapped
  // selection back to the hint (see coder learnings, 2026-08-26).
  int _libraryDropdownResetToken = 0;

  Map<String, String?> _elementErrors = const {};
  String? _weldMetalCetError;
  String? _thicknessError;
  String? _hdError;
  String? _yieldError;
  String? _heatInputError;

  _PreheatResult? _result;

  @override
  void initState() {
    super.initState();
    _store.load().then((materials) {
      if (!mounted) return;
      setState(() => _libraryMaterials = materials);
    });
  }

  @override
  void dispose() {
    for (final controller in _elementControllers.values) {
      controller.dispose();
    }
    _weldMetalCetController.dispose();
    _thicknessController.dispose();
    _hdController.dispose();
    _yieldController.dispose();
    super.dispose();
  }

  void _loadFromLibrary(CustomBaseMaterial material) {
    for (final key in _elementKeys) {
      final value = _elementValueOf(material, key);
      _elementControllers[key]!.text = value?.toString() ?? '';
    }
    setState(() {
      _selectedLibraryMaterial = null;
      _libraryDropdownResetToken++;
      _loadedPcmPercent = material.pcmPercent;
    });
  }

  /// Any edit to a composition field after a library load invalidates the
  /// loaded Pcm override -- otherwise a changed composition (e.g. a higher-
  /// carbon cast) would keep displaying the stale stored Pcm instead of a
  /// value matching what's actually been entered.
  void _invalidateLoadedPcmOverride(String _) {
    if (_loadedPcmPercent == null) return;
    setState(() => _loadedPcmPercent = null);
  }

  void _calculate() {
    final strings = AppLocaleScope.stringsOf(context);

    final elementResults = {
      for (final entry in _elementControllers.entries)
        entry.key: parseOptionalNumberField(entry.value.text),
    };
    final weldMetalCet = parseOptionalNumberField(_weldMetalCetController.text);
    final thickness = parseOptionalNumberField(_thicknessController.text);
    final hd = parseOptionalNumberField(_hdController.text);
    final yieldStrength = parseOptionalNumberField(_yieldController.text);

    final elementErrors = {
      for (final entry in elementResults.entries)
        if (_percentFieldError(strings, entry.value) != null)
          entry.key: _percentFieldError(strings, entry.value),
    };
    final weldMetalCetError = _percentFieldError(strings, weldMetalCet);
    final thicknessError = _positiveFieldError(strings, thickness);
    final hdError = _positiveFieldError(strings, hd);
    final yieldError = yieldStrength.invalid
        ? strings.materialFieldInvalidNumber
        : (yieldStrength.value != null && yieldStrength.value! <= 0
              ? strings.materialFieldOutOfRange
              : null);
    final heatInputError = _heatInputKJPerMm == null
        ? strings.materialFieldInvalidNumber
        : null;

    final invalid =
        elementErrors.isNotEmpty ||
        weldMetalCetError != null ||
        thicknessError != null ||
        hdError != null ||
        yieldError != null ||
        heatInputError != null;

    setState(() {
      _elementErrors = elementErrors;
      _weldMetalCetError = weldMetalCetError;
      _thicknessError = thicknessError;
      _hdError = hdError;
      _yieldError = yieldError;
      _heatInputError = heatInputError;
    });
    if (invalid) return;

    double v(String key) => elementResults[key]!.value ?? 0.0;
    final parentCet = computeCet(
      c: v('carbon'),
      mn: v('manganese'),
      mo: v('molybdenum'),
      cr: v('chromium'),
      cu: v('copper'),
      ni: v('nickel'),
    );
    final designCet = resolveDesignCet(
      parentMetalCet: parentCet,
      weldMetalCet: weldMetalCet.value,
    );
    final tanhTerm = 160 * _tanh(thickness.value! / 35);
    final hdTerm = 62 * _powFrac(hd.value!, 0.35);
    final qTerm = (53 * designCet - 32) * _heatInputKJPerMm!;
    final tp = computePreheatTempC(
      cet: designCet,
      thicknessMm: thickness.value!,
      hd: hd.value!,
      heatInputKJPerMm: _heatInputKJPerMm!,
    );
    final flags = checkPreheatRanges(
      cet: designCet,
      thicknessMm: thickness.value!,
      hd: hd.value!,
      heatInputKJPerMm: _heatInputKJPerMm!,
      yieldStrengthNPerMm2: yieldStrength.value,
    );
    final cev = computeCevIiw(
      c: v('carbon'),
      mn: v('manganese'),
      cr: v('chromium'),
      mo: v('molybdenum'),
      v: v('vanadium'),
      ni: v('nickel'),
      cu: v('copper'),
    );
    final storedPcm = _loadedPcmPercent;
    final pcm =
        storedPcm ??
        computePcmItoBessyo(
          c: v('carbon'),
          si: v('silicon'),
          mn: v('manganese'),
          cu: v('copper'),
          cr: v('chromium'),
          ni: v('nickel'),
          mo: v('molybdenum'),
          v: v('vanadium'),
          b: v('boron'),
        );

    setState(() {
      _result = _PreheatResult(
        tp: tp,
        parentCet: parentCet,
        designCet: designCet,
        specialRuleApplied: weldMetalCet.value != null && designCet != parentCet,
        flags: flags,
        cev: cev,
        pcm: pcm,
        pcmIsOverride: storedPcm != null,
        tanhTerm: tanhTerm,
        hdTerm: hdTerm,
        qTerm: qTerm,
        thicknessMm: thickness.value!,
        hd: hd.value!,
        heatInputKJPerMm: _heatInputKJPerMm!,
        yieldStrengthNPerMm2: yieldStrength.value,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F8FB), Color(0xFFE8EFF4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BackToDashboardButton(),
                    const TopNavigationBar(),
                    const SizedBox(height: 24),
                    Text(
                      strings.preheatScreenTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.preheatScreenSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF607482),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InputPanelSection(
                      icon: Icons.construction_outlined,
                      title: strings.preheatCompositionCardTitle,
                      subtitle: strings.preheatCompositionCardSubtitle,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_libraryMaterials.isNotEmpty) ...[
                            DropdownButtonFormField<CustomBaseMaterial>(
                              key: ValueKey(_libraryDropdownResetToken),
                              initialValue: _selectedLibraryMaterial,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: strings.preheatLoadFromLibraryLabel,
                              ),
                              items: [
                                for (final material in _libraryMaterials)
                                  DropdownMenuItem(
                                    value: material,
                                    child: Text(
                                      material.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                _loadFromLibrary(value);
                              },
                            ),
                            const SizedBox(height: 14),
                          ],
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (final key in _elementKeys)
                                OptionalNumberField(
                                  controller: _elementControllers[key]!,
                                  label: _elementLabel(strings, key),
                                  errorText: _elementErrors[key],
                                  width: 130,
                                  onChanged: _invalidateLoadedPcmOverride,
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          PanelNote(
                            icon: Icons.info_outline,
                            text: strings.preheatBlankMeansZeroNote,
                          ),
                          const SizedBox(height: 14),
                          OptionalNumberField(
                            controller: _weldMetalCetController,
                            label: strings.preheatWeldMetalCetLabel,
                            errorText: _weldMetalCetError,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    InputPanelSection(
                      icon: Icons.settings_outlined,
                      title: strings.preheatJointCardTitle,
                      subtitle: '',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OptionalNumberField(
                            controller: _thicknessController,
                            label: strings.preheatThicknessLabel,
                            errorText: _thicknessError,
                          ),
                          const SizedBox(height: 14),
                          OptionalNumberField(
                            controller: _hdController,
                            label: strings.preheatHdLabel,
                            errorText: _hdError,
                          ),
                          const SizedBox(height: 14),
                          HeatInputField(
                            onChanged: (value) =>
                                setState(() => _heatInputKJPerMm = value),
                          ),
                          if (_heatInputError != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              _heatInputError!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Theme.of(context).colorScheme.error),
                            ),
                          ],
                          const SizedBox(height: 14),
                          OptionalNumberField(
                            controller: _yieldController,
                            label: strings.preheatYieldStrengthLabel,
                            errorText: _yieldError,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _calculate,
                        child: Text(strings.preheatCalculateButton),
                      ),
                    ),
                    if (_result != null) ...[
                      const SizedBox(height: 24),
                      _PreheatResultView(result: _result!, strings: strings),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreheatResultView extends StatelessWidget {
  const _PreheatResultView({required this.result, required this.strings});

  final _PreheatResult result;
  final L10nStrings strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
              Text(
                strings.preheatResultLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                result.noPreheatRequired
                    ? strings.preheatNoPreheatRequiredLabel
                    : '${result.tp.round()} °C',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (result.noPreheatRequired) ...[
                const SizedBox(height: 4),
                Text(
                  strings.preheatComputedValueBelowAmbientNote.replaceFirst(
                    '{value}',
                    result.tp.toStringAsFixed(1),
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (result.specialRuleApplied) ...[
          const SizedBox(height: 12),
          Text(
            strings.preheatSpecialRuleNote.replaceFirst(
              '{value}',
              result.designCet.toStringAsFixed(3),
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF607482),
            ),
          ),
        ],
        const SizedBox(height: 16),
        for (final flag in result.flags) ...[
          PanelNote(
            icon: Icons.warning_amber_outlined,
            text: _warningTextFor(flag, result, strings),
          ),
          const SizedBox(height: 10),
        ],
        PanelNote(icon: Icons.info_outline, text: strings.preheatIso15608Note),
        const SizedBox(height: 16),
        FormulaBreakdownCard(
          title: 'EN 1011-2 Annex C.3 (Method B)',
          subtitle: 'Tp = 697·CET + 160·tanh(d/35) + 62·HD^0.35 + (53·CET−32)·Q − 328',
          items: [
            (label: 'CET (parent)', value: result.parentCet.toStringAsFixed(3)),
            if (result.specialRuleApplied)
              (label: 'Design CET', value: result.designCet.toStringAsFixed(3)),
            (
              label: '697×CET',
              value: (697 * result.designCet).toStringAsFixed(1),
            ),
            (label: '160×tanh(d/35)', value: result.tanhTerm.toStringAsFixed(1)),
            (label: '62×HD^0.35', value: result.hdTerm.toStringAsFixed(1)),
            (label: '(53×CET−32)×Q', value: result.qTerm.toStringAsFixed(1)),
            (label: 'Constant', value: '−328'),
            (label: 'Total Tp', value: '${result.tp.toStringAsFixed(1)} °C'),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            border: Border.all(color: const Color(0xFFDCE5EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.preheatOtherCarbonEquivalentsTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                strings.preheatOtherCarbonEquivalentsCaption,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF607482),
                ),
              ),
              const SizedBox(height: 12),
              Text('CEV (IIW) = ${result.cev.toStringAsFixed(3)}%'),
              const SizedBox(height: 4),
              Text(
                'Pcm (${result.pcmIsOverride ? 'stored override' : 'Ito-Bessyo'}) = ${result.pcm.toStringAsFixed(3)}%',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CoolingTimeCalculatorScreen(
                  initialPreheatTempC: result.noPreheatRequired
                      ? _ambientC
                      : result.tp,
                ),
              ),
            ),
            child: Text(strings.preheatUseInCoolingTimeButton),
          ),
        ),
      ],
    );
  }

  String _warningTextFor(
    PreheatRangeFlag flag,
    _PreheatResult result,
    L10nStrings strings,
  ) {
    return switch (flag) {
      PreheatRangeFlag.cetOutOfRange => strings.preheatWarningCetOutOfRange
          .replaceFirst('{value}', result.designCet.toStringAsFixed(3)),
      PreheatRangeFlag.thicknessOutOfRange =>
        strings.preheatWarningThicknessOutOfRange.replaceFirst(
          '{value}',
          result.thicknessMm.toStringAsFixed(1),
        ),
      PreheatRangeFlag.hdOutOfRange => strings.preheatWarningHdOutOfRange
          .replaceFirst('{value}', result.hd.toStringAsFixed(1)),
      PreheatRangeFlag.heatInputOutOfRange =>
        strings.preheatWarningHeatInputOutOfRange.replaceFirst(
          '{value}',
          result.heatInputKJPerMm.toStringAsFixed(2),
        ),
      PreheatRangeFlag.yieldStrengthOutOfRange =>
        strings.preheatWarningYieldOutOfRange.replaceFirst(
          '{value}',
          (result.yieldStrengthNPerMm2 ?? 0).toStringAsFixed(0),
        ),
    };
  }
}

String? _percentFieldError(L10nStrings strings, OptionalNumberParseResult result) {
  if (result.invalid) return strings.materialFieldInvalidNumber;
  final value = result.value;
  if (value != null && (value < 0 || value > 100)) {
    return strings.materialFieldOutOfRange;
  }
  return null;
}

String? _positiveFieldError(L10nStrings strings, OptionalNumberParseResult result) {
  if (result.invalid || result.value == null) {
    return strings.materialFieldInvalidNumber;
  }
  if (result.value! <= 0) return strings.materialFieldOutOfRange;
  return null;
}

// tanh/pow re-implemented here (not exported from en1011_formulas.dart)
// purely to render the individual formula terms in the breakdown card;
// computePreheatTempC itself is the single source of truth for Tp.
double _tanh(double x) {
  final e2x = math.exp(2 * x);
  return (e2x - 1) / (e2x + 1);
}

double _powFrac(double base, double exponent) => math.pow(base, exponent).toDouble();

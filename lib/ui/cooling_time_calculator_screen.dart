import 'package:flutter/material.dart';

import '../core/en1011_formulas.dart';
import '../l10n/app_locale_scope.dart';
import '../l10n/strings.dart';
import 'calculator_page/calculator_page_widgets.dart';
import 'widgets/formula_breakdown_card.dart';
import 'widgets/heat_input_field.dart';
import 'widgets/optional_number_field.dart';

/// EN 1011-2 Annex D.6 cooling time (t8/5) calculator. Lives standalone --
/// no PDF export or saved-history in v1 (see the implementation plan's
/// scope-cut note); results are shown in-app only. Fillet weld joints are
/// deliberately not modeled -- see `shapeFactorsFor` in
/// `en1011_formulas.dart`.
class CoolingTimeCalculatorScreen extends StatefulWidget {
  const CoolingTimeCalculatorScreen({super.key, this.initialPreheatTempC});

  final double? initialPreheatTempC;

  @override
  State<CoolingTimeCalculatorScreen> createState() =>
      _CoolingTimeCalculatorScreenState();
}

class _CoolingResult {
  const _CoolingResult({
    required this.t85,
    required this.regime,
    required this.dt,
    required this.f2,
    required this.f3,
    required this.t0,
    required this.heatInputKJPerMm,
    required this.thicknessMm,
  });

  final double t85;
  final CoolingRegime regime;
  final double dt;
  final double f2;
  final double f3;
  final double t0;
  final double heatInputKJPerMm;
  final double thicknessMm;
}

class _CoolingTimeCalculatorScreenState
    extends State<CoolingTimeCalculatorScreen> {
  late final TextEditingController _t0Controller = TextEditingController(
    text: widget.initialPreheatTempC?.toString() ?? '',
  );
  final TextEditingController _thicknessController = TextEditingController();

  double? _heatInputKJPerMm;
  CoolingJointType _jointType = CoolingJointType.runOnPlate;

  String? _t0Error;
  String? _thicknessError;
  String? _heatInputError;

  _CoolingResult? _result;

  @override
  void dispose() {
    _t0Controller.dispose();
    _thicknessController.dispose();
    super.dispose();
  }

  void _calculate() {
    final strings = AppLocaleScope.stringsOf(context);

    final t0 = parseOptionalNumberField(_t0Controller.text);
    final thickness = parseOptionalNumberField(_thicknessController.text);

    final t0Error = t0.invalid || t0.value == null
        ? strings.materialFieldInvalidNumber
        : (!isPreheatOrInterpassTempValid(t0.value!)
              ? strings.coolingT0InvalidError
              : null);
    final thicknessError = thickness.invalid || thickness.value == null
        ? strings.materialFieldInvalidNumber
        : (thickness.value! <= 0 ? strings.materialFieldOutOfRange : null);
    final heatInputError = _heatInputKJPerMm == null
        ? strings.materialFieldInvalidNumber
        : null;

    final invalid = t0Error != null || thicknessError != null || heatInputError != null;

    setState(() {
      _t0Error = t0Error;
      _thicknessError = thicknessError;
      _heatInputError = heatInputError;
    });
    if (invalid) return;

    final dt = computeTransitionThicknessMm(
      t0: t0.value!,
      heatInputKJPerMm: _heatInputKJPerMm!,
    );
    final regime = selectCoolingRegime(
      thicknessMm: thickness.value!,
      transitionThicknessMm: dt,
    );
    final factors = shapeFactorsFor(_jointType);
    final t85 = regime == CoolingRegime.twoDThinPlate
        ? computeT85TwoDSeconds(
            t0: t0.value!,
            heatInputKJPerMm: _heatInputKJPerMm!,
            thicknessMm: thickness.value!,
            f2: factors.f2,
          )
        : computeT85ThreeDSeconds(
            t0: t0.value!,
            heatInputKJPerMm: _heatInputKJPerMm!,
            f3: factors.f3,
          );

    setState(() {
      _result = _CoolingResult(
        t85: t85,
        regime: regime,
        dt: dt,
        f2: factors.f2,
        f3: factors.f3,
        t0: t0.value!,
        heatInputKJPerMm: _heatInputKJPerMm!,
        thicknessMm: thickness.value!,
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
                    const TopNavigationBar(),
                    const SizedBox(height: 24),
                    Text(
                      strings.coolingScreenTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.coolingScreenSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF607482),
                      ),
                    ),
                    const SizedBox(height: 20),
                    InputPanelSection(
                      icon: Icons.device_thermostat_outlined,
                      title: strings.coolingTempCardTitle,
                      subtitle: '',
                      child: OptionalNumberField(
                        controller: _t0Controller,
                        label: strings.coolingT0Label,
                        errorText: _t0Error,
                      ),
                    ),
                    const SizedBox(height: 18),
                    InputPanelSection(
                      icon: Icons.bolt_outlined,
                      title: strings.coolingHeatInputCardTitle,
                      subtitle: '',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    InputPanelSection(
                      icon: Icons.view_agenda_outlined,
                      title: strings.coolingJointCardTitle,
                      subtitle: '',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<CoolingJointType>(
                            initialValue: _jointType,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: strings.coolingJointTypeLabel,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: CoolingJointType.runOnPlate,
                                child: Text(
                                  strings.coolingJointTypeRunOnPlate,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DropdownMenuItem(
                                value: CoolingJointType.buttWeldBetweenRuns,
                                child: Text(
                                  strings.coolingJointTypeButtBetweenRuns,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _jointType = value);
                            },
                          ),
                          const SizedBox(height: 12),
                          PanelNote(
                            icon: Icons.info_outline,
                            text: strings.coolingFilletNotSupportedNote,
                          ),
                          const SizedBox(height: 14),
                          OptionalNumberField(
                            controller: _thicknessController,
                            label: strings.coolingThicknessLabel,
                            errorText: _thicknessError,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _calculate,
                        child: Text(strings.coolingCalculateButton),
                      ),
                    ),
                    if (_result != null) ...[
                      const SizedBox(height: 24),
                      _CoolingResultView(result: _result!, strings: strings),
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

class _CoolingResultView extends StatelessWidget {
  const _CoolingResultView({required this.result, required this.strings});

  final _CoolingResult result;
  final L10nStrings strings;

  @override
  Widget build(BuildContext context) {
    final regimeLabel = result.regime == CoolingRegime.twoDThinPlate
        ? strings.coolingRegimeTwoD
        : strings.coolingRegimeThreeD;
    final warnings = <String>[
      if (result.heatInputKJPerMm < 0.5 || result.heatInputKJPerMm > 4.0)
        strings.coolingWarningHeatInputOutOfRange.replaceFirst(
          '{value}',
          result.heatInputKJPerMm.toStringAsFixed(2),
        ),
      if (result.thicknessMm < 3 || result.thicknessMm > 150)
        strings.coolingWarningThicknessOutOfRange.replaceFirst(
          '{value}',
          result.thicknessMm.toStringAsFixed(1),
        ),
    ];

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
                strings.coolingResultLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${result.t85.toStringAsFixed(1)} s',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          strings.coolingRegimeExplanation
              .replaceFirst('{regime}', regimeLabel)
              .replaceFirst('{dt}', result.dt.toStringAsFixed(1)),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF607482),
          ),
        ),
        const SizedBox(height: 16),
        for (final warning in warnings) ...[
          PanelNote(icon: Icons.warning_amber_outlined, text: warning),
          const SizedBox(height: 10),
        ],
        FormulaBreakdownCard(
          title: 'EN 1011-2 Annex D.6',
          subtitle: result.regime == CoolingRegime.twoDThinPlate
              ? 't8/5 = (4300−4.3·T0)·1e5·(Q²/d²)·[1/(500−T0)²−1/(800−T0)²]·F2'
              : 't8/5 = (6700−5·T0)·Q·[1/(500−T0)−1/(800−T0)]·F3',
          items: [
            (label: 'T0', value: '${result.t0.toStringAsFixed(1)} °C'),
            (label: 'Q', value: '${result.heatInputKJPerMm.toStringAsFixed(2)} kJ/mm'),
            (label: 'Regime', value: regimeLabel),
            (label: 'dt', value: '${result.dt.toStringAsFixed(1)} mm'),
            (
              label: result.regime == CoolingRegime.twoDThinPlate ? 'F2' : 'F3',
              value: (result.regime == CoolingRegime.twoDThinPlate
                      ? result.f2
                      : result.f3)
                  .toStringAsFixed(2),
            ),
            (label: 't8/5', value: '${result.t85.toStringAsFixed(1)} s'),
          ],
        ),
      ],
    );
  }
}

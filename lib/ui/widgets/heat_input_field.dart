import 'package:flutter/material.dart';

import '../../core/en1011_formulas.dart';
import '../../l10n/app_locale_scope.dart';
import '../calculator_page/calculator_page_widgets.dart';
import 'optional_number_field.dart';

/// Shared net heat input (Q, kJ/mm) entry widget for the preheat and
/// cooling-time calculators. Two modes: direct entry (always available)
/// and a "calculate from arc parameters" sub-form restricted to the 3
/// processes EN 1011-2 verifies arc thermal efficiency for -- see
/// `arcThermalEfficiencyFor` in `en1011_formulas.dart`.
class HeatInputField extends StatefulWidget {
  const HeatInputField({
    super.key,
    required this.onChanged,
    this.initialKJPerMm,
  });

  /// Called whenever the effective net heat input value changes (from
  /// either the direct-entry field or the computed arc-parameters
  /// sub-form). Null means "no valid value currently available."
  final ValueChanged<double?> onChanged;
  final double? initialKJPerMm;

  @override
  State<HeatInputField> createState() => _HeatInputFieldState();
}

class _HeatInputFieldState extends State<HeatInputField> {
  late final TextEditingController _directController = TextEditingController(
    text: widget.initialKJPerMm?.toString() ?? '',
  );
  late final TextEditingController _voltageController =
      TextEditingController();
  late final TextEditingController _currentController =
      TextEditingController();
  late final TextEditingController _travelSpeedController =
      TextEditingController();

  bool _arcParamsMode = false;
  ArcProcess _process = ArcProcess.smaw;

  String? _directError;
  String? _voltageError;
  String? _currentError;
  String? _travelSpeedError;

  @override
  void initState() {
    super.initState();
    // OptionalNumberField's TextField has no onChanged of its own, so this
    // widget must listen to its controllers directly to notify the parent
    // as the user types -- without this, HeatInputField only ever reports
    // a value at mode-switch time, never as text is entered.
    _directController.addListener(_emitDirect);
    _voltageController.addListener(_emitFromArcParams);
    _currentController.addListener(_emitFromArcParams);
    _travelSpeedController.addListener(_emitFromArcParams);
  }

  @override
  void dispose() {
    _directController.removeListener(_emitDirect);
    _voltageController.removeListener(_emitFromArcParams);
    _currentController.removeListener(_emitFromArcParams);
    _travelSpeedController.removeListener(_emitFromArcParams);
    _directController.dispose();
    _voltageController.dispose();
    _currentController.dispose();
    _travelSpeedController.dispose();
    super.dispose();
  }

  void _emitDirect() {
    final result = parseOptionalNumberField(_directController.text);
    setState(() => _directError = result.invalid ? _invalidNumberLabel() : null);
    widget.onChanged(result.invalid ? null : result.value);
  }

  void _emitFromArcParams() {
    final voltage = parseOptionalNumberField(_voltageController.text);
    final current = parseOptionalNumberField(_currentController.text);
    final travelSpeed = parseOptionalNumberField(_travelSpeedController.text);
    setState(() {
      _voltageError = voltage.invalid ? _invalidNumberLabel() : null;
      _currentError = current.invalid ? _invalidNumberLabel() : null;
      _travelSpeedError = travelSpeed.invalid ? _invalidNumberLabel() : null;
    });

    if (voltage.value == null ||
        current.value == null ||
        travelSpeed.value == null ||
        travelSpeed.value == 0) {
      widget.onChanged(null);
      return;
    }

    final computed = computeHeatInputKJPerMm(
      efficiency: arcThermalEfficiencyFor(_process),
      voltageV: voltage.value!,
      currentA: current.value!,
      travelSpeedMmPerMin: travelSpeed.value!,
    );
    widget.onChanged(computed);
  }

  String _invalidNumberLabel() =>
      AppLocaleScope.stringsOf(context).materialFieldInvalidNumber;

  double? get _computedQ {
    final voltage = parseOptionalNumberField(_voltageController.text).value;
    final current = parseOptionalNumberField(_currentController.text).value;
    final travelSpeed =
        parseOptionalNumberField(_travelSpeedController.text).value;
    if (voltage == null || current == null || travelSpeed == null || travelSpeed == 0) {
      return null;
    }
    return computeHeatInputKJPerMm(
      efficiency: arcThermalEfficiencyFor(_process),
      voltageV: voltage,
      currentA: current,
      travelSpeedMmPerMin: travelSpeed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _ModeChip(
              label: strings.heatInputDirectModeLabel,
              selected: !_arcParamsMode,
              onSelected: () {
                setState(() => _arcParamsMode = false);
                _emitDirect();
              },
            ),
            _ModeChip(
              label: strings.heatInputArcParamsModeLabel,
              selected: _arcParamsMode,
              onSelected: () {
                setState(() => _arcParamsMode = true);
                _emitFromArcParams();
              },
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (!_arcParamsMode)
          OptionalNumberField(
            controller: _directController,
            label: strings.heatInputQLabel,
            errorText: _directError,
          )
        else ...[
          DropdownButtonFormField<ArcProcess>(
            initialValue: _process,
            isExpanded: true,
            decoration: InputDecoration(labelText: strings.heatInputProcessLabel),
            items: [
              DropdownMenuItem(
                value: ArcProcess.saw,
                child: Text(strings.heatInputProcessSaw),
              ),
              DropdownMenuItem(
                value: ArcProcess.smaw,
                child: Text(strings.heatInputProcessSmaw),
              ),
              DropdownMenuItem(
                value: ArcProcess.gmawMag,
                child: Text(strings.heatInputProcessGmawMag),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _process = value);
              _emitFromArcParams();
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OptionalNumberField(
                controller: _voltageController,
                label: strings.heatInputVoltageLabel,
                errorText: _voltageError,
                width: 150,
              ),
              OptionalNumberField(
                controller: _currentController,
                label: strings.heatInputCurrentLabel,
                errorText: _currentError,
                width: 150,
              ),
              OptionalNumberField(
                controller: _travelSpeedController,
                label: strings.heatInputTravelSpeedLabel,
                errorText: _travelSpeedError,
                width: 190,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            strings.heatInputComputedLabel.replaceFirst(
              '{value}',
              _computedQ?.toStringAsFixed(2) ?? '—',
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          PanelNote(
            icon: Icons.info_outline,
            text: strings.heatInputVerifiedProcessesNote,
          ),
        ],
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: const Color(0xFF12191B),
      backgroundColor: const Color(0xFFF1F5F7),
      side: BorderSide(
        color: selected ? const Color(0xFF12191B) : const Color(0xFFD6E0E6),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF29414D),
        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}


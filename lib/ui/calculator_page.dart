import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/weld_calculator.dart';
import '../core/welding_defaults.dart';
import '../models/weld_models.dart';
import '../services/user_preset_store.dart';
import '../services/weld_pdf_report_service.dart';
import 'widgets/branch_connection_module.dart';
import 'widgets/result_card.dart';
import 'widgets/weld_drawing_preview.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final WeldCalculator _calculator = const WeldCalculator();
  final WeldPdfReportService _pdfReportService = const WeldPdfReportService();
  final UserPresetStore _userPresetStore = const UserPresetStore();
  static const _customDiameterValue = 'custom';

  final Map<_FieldKey, TextEditingController> _controllers = {
    for (final key in _FieldKey.values) key: TextEditingController(),
  };
  final Map<_FieldKey, String> _diameterPresetModes = {};

  JointType _jointType = JointType.plateButt;
  GrooveType _grooveType = GrooveType.singleV;
  WeldingProcess _weldingProcess = WeldingProcess.gtaw;
  DepositionRateMode _depositionRateMode = DepositionRateMode.preset;
  DrawingMode _drawingMode = DrawingMode.visual;
  _CalculatorModule _activeModule = _CalculatorModule.weldEstimator;
  JointGeometryMode _jointGeometryMode = JointGeometryMode.equal;
  JointAlignment _jointAlignment = JointAlignment.centerline;
  ConsumablePreset _consumablePreset = ConsumablePreset.er70s2;
  InputPreset _inputPreset = InputPreset.custom;
  List<UserWeldPreset> _userPresets = const [];
  String? _selectedUserPresetId;
  WeldCalculationResult? _result;
  bool _isExportingPdf = false;
  bool _isUserPresetBusy = false;

  @override
  void initState() {
    super.initState();
    _resetFields();
    _loadUserPresets();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F8FB), Color(0xFFE8EFF4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: IgnorePointer(
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0x2B4EA1B7), Color(0x004EA1B7)],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 180,
              left: -120,
              child: IgnorePointer(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0x22538A95), Color(0x00538A95)],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1320),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopNavigationBar(
                          activeModuleLabel:
                              _activeModule ==
                                  _CalculatorModule.branchConnections
                              ? 'Branch detailing lab'
                              : 'Butt and fillet estimator',
                        ),
                        const SizedBox(height: 18),
                        _ExperienceHero(
                          activeModule: _activeModule,
                          jointTypeLabel: _jointType.label,
                          grooveLabel: _grooveType.label,
                          processLabel: _weldingProcess.label,
                          drawingModeLabel: _drawingMode.label,
                          consumableLabel: _consumablePreset.label,
                          savedPresetCount: _userPresets.length,
                          hasResults: _result != null,
                        ),
                        const SizedBox(height: 18),
                        _CapabilityStrip(
                          isBranchMode:
                              _activeModule ==
                              _CalculatorModule.branchConnections,
                        ),
                        const SizedBox(height: 18),
                        _buildModuleWorkspaceCard(context),
                        const SizedBox(height: 18),
                        if (_activeModule ==
                            _CalculatorModule.branchConnections)
                          const BranchConnectionsModule()
                        else
                          _buildEstimatorWorkspace(context),
                        const SizedBox(height: 18),
                        const _WebsiteReadyFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleWorkspaceCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Module Workspace',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const _StatusPill(
                  label: 'WEB APP PREVIEW',
                  color: Color(0xFFE5F1F5),
                  textColor: Color(0xFF0F4C5C),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Use one focused product shell for daily estimating while keeping advanced branch-detail development in a separate lane.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF607482)),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final module in _CalculatorModule.values)
                  _buildSelectionChip(
                    label: module.label,
                    selected: _activeModule == module,
                    onSelected: () {
                      setState(() {
                        _activeModule = module;
                      });
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimatorWorkspace(BuildContext context) {
    final visibleFields = _visibleFieldSpecs;
    final availableConsumables = WeldingDefaults.consumablesFor(
      _weldingProcess,
    );
    final selectedUserPreset = _selectedUserPreset;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1120;

        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEstimatorControlCard(context),
              const SizedBox(height: 18),
              _buildJointConfigurationCard(context),
              const SizedBox(height: 18),
              _buildTechnicalDrawingCard(context),
              const SizedBox(height: 18),
              _buildInputParametersCard(
                context,
                visibleFields,
                availableConsumables,
                selectedUserPreset,
              ),
              const SizedBox(height: 18),
              _buildActionPanel(context),
              const SizedBox(height: 18),
              _buildResultsCard(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildJointConfigurationCard(context),
                  const SizedBox(height: 18),
                  _buildTechnicalDrawingCard(context),
                  const SizedBox(height: 18),
                  _buildResultsCard(),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEstimatorControlCard(context),
                  const SizedBox(height: 18),
                  _buildInputParametersCard(
                    context,
                    visibleFields,
                    availableConsumables,
                    selectedUserPreset,
                  ),
                  const SizedBox(height: 18),
                  _buildActionPanel(context),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEstimatorControlCard(BuildContext context) {
    final processEfficiency = _previewEfficiency;
    final depositionRate = _previewDepositionRate;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estimator Control Tower',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'A compact summary layer for engineers, planners, and customers reviewing the active calculation basis.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF607482)),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _QuickMetricTile(
                  label: 'Joint',
                  value: _jointType.label,
                  icon: Icons.alt_route_outlined,
                ),
                _QuickMetricTile(
                  label: 'Groove',
                  value: _grooveType.label,
                  icon: Icons.change_history_outlined,
                ),
                _QuickMetricTile(
                  label: 'Process',
                  value: _weldingProcess.label,
                  icon: Icons.bolt_outlined,
                ),
                _QuickMetricTile(
                  label: 'Drawing',
                  value: _drawingMode.label,
                  icon: Icons.draw_outlined,
                ),
                _QuickMetricTile(
                  label: 'Efficiency',
                  value: _formatPercent(processEfficiency),
                  icon: Icons.speed_outlined,
                ),
                _QuickMetricTile(
                  label: 'Rate',
                  value: '${_formatNumber(depositionRate, 2)} kg/h',
                  icon: Icons.tips_and_updates_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F4C5C), Color(0xFF1C6671)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Engineering Basis',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${_jointType.helper} $_unequalGeometrySummary${_processRateSummary(processEfficiency, depositionRate)}',
                    style: const TextStyle(
                      color: Color(0xFFE1F0F3),
                      height: 1.42,
                      fontWeight: FontWeight.w500,
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

  Widget _buildJointConfigurationCard(BuildContext context) {
    final processEfficiency = _previewEfficiency;
    final depositionRate = _previewDepositionRate;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Joint Type',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final joint in JointType.values)
                  _buildSelectionChip(
                    label: joint.label,
                    selected: _jointType == joint,
                    onSelected: () => _onJointTypeChanged(joint),
                  ),
              ],
            ),
            if (_supportsUnequalGeometry) ...[
              const SizedBox(height: 18),
              Text(
                'Member Geometry',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final mode in JointGeometryMode.values)
                    _buildSelectionChip(
                      label: mode.label,
                      selected: _jointGeometryMode == mode,
                      onSelected: () {
                        setState(() {
                          _jointGeometryMode = mode;
                          _result = null;
                        });
                      },
                    ),
                ],
              ),
              if (_isUnequalGeometry) ...[
                const SizedBox(height: 12),
                _buildDropdownFrame(
                  DropdownButtonFormField<JointAlignment>(
                    initialValue: _jointAlignment,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Alignment Reference',
                      helperText:
                          'Defines how unequal members are aligned in the section sketch.',
                    ),
                    selectedItemBuilder: (context) => JointAlignment.values
                        .map(
                          (alignment) =>
                              _buildDropdownSelectedText(alignment.label),
                        )
                        .toList(),
                    items: JointAlignment.values
                        .map(
                          (alignment) => DropdownMenuItem(
                            value: alignment,
                            child: Text(
                              alignment.label,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _jointAlignment = value;
                        _result = null;
                      });
                    },
                  ),
                ),
              ],
            ],
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 560;
                final grooveDropdown = _buildDropdownFrame(
                  DropdownButtonFormField<GrooveType>(
                    initialValue: _grooveType,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Groove Type'),
                    selectedItemBuilder: (context) => _jointType
                        .supportedGrooves
                        .map(
                          (groove) => _buildDropdownSelectedText(groove.label),
                        )
                        .toList(),
                    items: _jointType.supportedGrooves
                        .map(
                          (groove) => DropdownMenuItem(
                            value: groove,
                            child: Text(
                              groove.label,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _grooveType = value;
                        _result = null;
                      });
                    },
                  ),
                );
                final processDropdown = _buildDropdownFrame(
                  DropdownButtonFormField<WeldingProcess>(
                    initialValue: _weldingProcess,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Welding Process',
                    ),
                    selectedItemBuilder: (context) => WeldingProcess.values
                        .map(
                          (process) =>
                              _buildDropdownSelectedText(process.label),
                        )
                        .toList(),
                    items: WeldingProcess.values
                        .map(
                          (process) => DropdownMenuItem(
                            value: process,
                            child: Text(
                              process.label,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _weldingProcess = value;
                        _applyProcessFieldDefaults();
                        _syncConsumableForProcess();
                        _result = null;
                      });
                    },
                  ),
                );

                if (narrow) {
                  return Column(
                    children: [
                      grooveDropdown,
                      const SizedBox(height: 14),
                      processDropdown,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: grooveDropdown),
                    const SizedBox(width: 14),
                    Expanded(child: processDropdown),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFF6F9FB),
                border: Border.all(color: const Color(0xFFDCE5EB)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.settings_suggest_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_jointType.helper} $_unequalGeometrySummary${_processRateSummary(processEfficiency, depositionRate)}',
                      style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildTechnicalDrawingCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Technical Drawing',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _drawingMode == DrawingMode.technical
                            ? 'Technical mode applies engineering-style line weights, hatch, and dimension annotations.'
                            : 'Visual mode keeps the sketch softer while still following the live joint geometry.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF607482),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      for (final mode in DrawingMode.values)
                        _buildSelectionChip(
                          label: mode.label,
                          selected: _drawingMode == mode,
                          onSelected: () {
                            setState(() {
                              _drawingMode = mode;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF8FBFD), Color(0xFFEAF1F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: WeldDrawingPreview(
                grooveType: _grooveType,
                jointType: _jointType,
                drawingMode: _drawingMode,
                data: _drawingData,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputParametersCard(
    BuildContext context,
    List<_InputFieldSpec> visibleFields,
    List<ConsumablePreset> availableConsumables,
    UserWeldPreset? selectedUserPreset,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Input Parameters',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Default assumptions: density ${WeldingDefaults.densityGPerCm3} g/cm3, waste allowance ${WeldingDefaults.wasteFactorPercent}%',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF5E7380)),
            ),
            const SizedBox(height: 16),
            _InputPanelSection(
              icon: Icons.auto_awesome_outlined,
              title: 'Preset Workspace',
              subtitle:
                  'Load built-in setups or manage your own reusable presets.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdownFrame(
                    DropdownButtonFormField<InputPreset>(
                      initialValue: _inputPreset,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Input Preset',
                        helperText:
                            'Load a practical starting setup, then fine-tune dimensions as needed.',
                      ),
                      selectedItemBuilder: (context) => InputPreset.values
                          .map(
                            (preset) =>
                                _buildDropdownSelectedText(preset.label),
                          )
                          .toList(),
                      items: InputPreset.values
                          .map(
                            (preset) => DropdownMenuItem(
                              value: preset,
                              child: Text(
                                preset.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        if (value == InputPreset.custom) {
                          setState(() {
                            _inputPreset = value;
                            _selectedUserPresetId = null;
                            _result = null;
                          });
                          return;
                        }
                        _applyInputPreset(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PanelNote(
                    icon: Icons.auto_fix_high_outlined,
                    text: _inputPreset.description,
                  ),
                  const SizedBox(height: 14),
                  _UserPresetSection(
                    presets: _userPresets,
                    selectedPresetId: _selectedUserPresetId,
                    selectedPresetName: selectedUserPreset?.name,
                    busy: _isUserPresetBusy,
                    onChanged: (presetId) {
                      if (presetId == null) return;
                      final preset = _userPresets.firstWhere(
                        (item) => item.id == presetId,
                      );
                      _applyUserPreset(preset);
                    },
                    onSavePressed: _isUserPresetBusy
                        ? null
                        : _saveCurrentAsUserPreset,
                    onUpdatePressed:
                        selectedUserPreset == null || _isUserPresetBusy
                        ? null
                        : _updateSelectedUserPreset,
                    onDeletePressed:
                        selectedUserPreset == null || _isUserPresetBusy
                        ? null
                        : _deleteSelectedUserPreset,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _InputPanelSection(
              icon: Icons.inventory_2_outlined,
              title: 'Consumable & Density',
              subtitle:
                  'AWS filler selection, family information, and weld metal density basis.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdownFrame(
                    DropdownButtonFormField<ConsumablePreset>(
                      initialValue: _consumablePreset,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Consumable Classification',
                        helperText:
                            'Select an AWS filler metal classification. Density is populated automatically and can still be adjusted.',
                      ),
                      selectedItemBuilder: (context) => availableConsumables
                          .map(
                            (preset) => _buildDropdownSelectedText(
                              preset.awsDisplayLabel,
                            ),
                          )
                          .toList(),
                      items: availableConsumables
                          .map(
                            (preset) => DropdownMenuItem(
                              value: preset,
                              child: Text(
                                preset.awsDisplayLabel,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _consumablePreset = value;
                          _applyConsumablePreset(value);
                          _result = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PanelNote(
                    icon: Icons.verified_outlined,
                    text:
                        'Selected classification: ${_consumablePreset.awsSpecification} | ${_consumablePreset.label} | ${_consumablePreset.family.label} | Density ${_formatNumber(_consumablePreset.densityGPerCm3, 2)} g/cm3',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _InputPanelSection(
              icon: Icons.speed_outlined,
              title: 'Rate Basis',
              subtitle:
                  'Choose whether deposition rate comes from estimated process defaults or manual planning data.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final mode in DepositionRateMode.values)
                        _buildSelectionChip(
                          label: mode.label,
                          selected: _depositionRateMode == mode,
                          onSelected: () {
                            setState(() {
                              _depositionRateMode = mode;
                              _result = null;
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _PanelNote(
                    icon: _depositionRateMode == DepositionRateMode.manual
                        ? Icons.tune_outlined
                        : Icons.auto_awesome_motion_outlined,
                    text: _depositionRateMode == DepositionRateMode.manual
                        ? _manualRateHelperText
                        : _presetRateHelperText,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _InputPanelSection(
              icon: Icons.straighten_outlined,
              title: 'Dimensional Inputs',
              subtitle:
                  'Enter weld geometry, member size, process diameter, and calculation assumptions.',
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 700;
                  final fieldWidth = wide
                      ? (constraints.maxWidth - 16) / 2
                      : constraints.maxWidth;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFFF7FBFD),
                      border: Border.all(color: const Color(0xFFDCE5EB)),
                    ),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final field in visibleFields)
                          SizedBox(
                            width: fieldWidth,
                            child: _buildFieldInput(field),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPanel(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Run Estimate',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Use calculate for live estimate refresh. Reset restores the default engineering starter values.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF607482)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate_outlined),
                    label: const Text('Calculate'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetFields,
                    icon: const Icon(Icons.refresh_outlined),
                    label: const Text('Reset'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: const Color(0xFFF7FBFD),
                border: Border.all(color: const Color(0xFFDCE5EB)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.picture_as_pdf_outlined,
                    size: 20,
                    color: Color(0xFF4E6875),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _result == null
                          ? 'PDF export activates after a successful estimate so the report always reflects the current engineering basis.'
                          : 'The report panel is ready for polished PDF output once the estimate looks correct.',
                      style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _buildResultsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: _result == null
            ? _EmptyResultsState(process: _weldingProcess)
            : _ResultsSection(
                result: _result!,
                basis: _buildCalculationBasis(),
                consumablePreset: _consumablePreset,
                onPdfPressed: _isExportingPdf ? null : _exportPdf,
                pdfBusy: _isExportingPdf,
              ),
      ),
    );
  }

  bool get _supportsUnequalGeometry =>
      _jointType == JointType.pipeButt || _jointType == JointType.plateButt;

  bool get _isUnequalGeometry =>
      _supportsUnequalGeometry &&
      _jointGeometryMode == JointGeometryMode.unequal;

  double? get _thicknessAPreview => _isUnequalGeometry
      ? _parsePreviewValue(_FieldKey.thicknessAMm)
      : _parsePreviewValue(_FieldKey.thicknessMm);

  double? get _thicknessBPreview => _isUnequalGeometry
      ? _parsePreviewValue(_FieldKey.thicknessBMm)
      : _parsePreviewValue(_FieldKey.thicknessMm);

  double? get _governingThicknessPreview {
    final a = _thicknessAPreview;
    final b = _thicknessBPreview;
    if (a == null && b == null) {
      return _parsePreviewValue(_FieldKey.thicknessMm);
    }
    if (a == null) return b;
    if (b == null) return a;
    return a >= b ? a : b;
  }

  double? get _pipeOdAPreview => _isUnequalGeometry
      ? _parsePreviewValue(_FieldKey.pipeOdAMm)
      : _parsePreviewValue(_FieldKey.pipeOdMm);

  double? get _pipeOdBPreview => _isUnequalGeometry
      ? _parsePreviewValue(_FieldKey.pipeOdBMm)
      : _parsePreviewValue(_FieldKey.pipeOdMm);

  double? get _governingPipeOdPreview {
    final a = _pipeOdAPreview;
    final b = _pipeOdBPreview;
    if (a == null && b == null) return _parsePreviewValue(_FieldKey.pipeOdMm);
    if (a == null) return b;
    if (b == null) return a;
    return a >= b ? a : b;
  }

  List<_InputFieldSpec> get _visibleFieldSpecs {
    final specs = <_InputFieldSpec>[
      const _InputFieldSpec(
        key: _FieldKey.quantity,
        label: 'Quantity',
        helperText: 'Number of identical welds.',
      ),
    ];

    if (_jointType == JointType.plateButt || _jointType == JointType.fillet) {
      specs.add(
        const _InputFieldSpec(
          key: _FieldKey.lengthMm,
          label: 'Weld Length per Piece (mm)',
          helperText: 'Straight weld run length.',
        ),
      );
    }

    if (_jointType == JointType.pipeButt) {
      if (_isUnequalGeometry) {
        specs.addAll(const [
          _InputFieldSpec(
            key: _FieldKey.pipeOdAMm,
            label: 'Pipe OD A (mm)',
            helperText: 'Outside diameter of member A.',
          ),
          _InputFieldSpec(
            key: _FieldKey.pipeOdBMm,
            label: 'Pipe OD B (mm)',
            helperText: 'Outside diameter of member B.',
          ),
        ]);
      } else {
        specs.add(
          const _InputFieldSpec(
            key: _FieldKey.pipeOdMm,
            label: 'Pipe OD (mm)',
            helperText: 'Outside diameter used for circumference calculation.',
          ),
        );
      }
    }

    if (_grooveType == GrooveType.square ||
        _grooveType == GrooveType.singleV ||
        _grooveType == GrooveType.halfV ||
        _grooveType == GrooveType.compoundV ||
        _grooveType == GrooveType.doubleV) {
      if (_isUnequalGeometry) {
        specs.addAll(const [
          _InputFieldSpec(
            key: _FieldKey.thicknessAMm,
            label: 'Thickness A (mm)',
            helperText: 'Wall or plate thickness of member A.',
          ),
          _InputFieldSpec(
            key: _FieldKey.thicknessBMm,
            label: 'Thickness B (mm)',
            helperText: 'Wall or plate thickness of member B.',
          ),
          _InputFieldSpec(
            key: _FieldKey.rootGapMm,
            label: 'Root Gap (mm)',
            helperText: 'Root opening.',
          ),
        ]);
      } else {
        specs.addAll(const [
          _InputFieldSpec(
            key: _FieldKey.thicknessMm,
            label: 'Thickness (mm)',
            helperText: 'Base material thickness.',
          ),
          _InputFieldSpec(
            key: _FieldKey.rootGapMm,
            label: 'Root Gap (mm)',
            helperText: 'Root opening.',
          ),
        ]);
      }
    }

    if (_grooveType == GrooveType.singleV ||
        _grooveType == GrooveType.halfV ||
        _grooveType == GrooveType.doubleV) {
      specs.add(
        _InputFieldSpec(
          key: _FieldKey.rootFaceMm,
          label: _grooveType == GrooveType.doubleV
              ? 'Root Face per Side (mm)'
              : 'Root Face (mm)',
          helperText: _grooveType == GrooveType.doubleV
              ? 'Root face on each side of the joint centerline.'
              : 'Root face before the bevel starts.',
        ),
      );
      specs.add(
        const _InputFieldSpec(
          key: _FieldKey.bevelAngleDeg,
          label: 'Bevel Angle (deg)',
          helperText: 'Included as bevel angle in degrees.',
        ),
      );
    }

    if (_grooveType == GrooveType.compoundV) {
      specs.addAll(const [
        _InputFieldSpec(
          key: _FieldKey.rootFaceMm,
          label: 'Root Face (mm)',
          helperText: 'Root face before the bevel starts.',
        ),
        _InputFieldSpec(
          key: _FieldKey.bevelAngleDeg,
          label: 'Primary Angle alpha (deg)',
          helperText: 'Lower bevel angle near the root.',
        ),
        _InputFieldSpec(
          key: _FieldKey.secondaryBevelAngleDeg,
          label: 'Secondary Angle beta (deg)',
          helperText: 'Upper bevel angle above the break point.',
        ),
        _InputFieldSpec(
          key: _FieldKey.breakHeightMm,
          label: 'Break Height h (mm)',
          helperText: 'Distance from root face to bevel break point.',
        ),
      ]);
    }

    if (_grooveType == GrooveType.fillet) {
      specs.add(
        const _InputFieldSpec(
          key: _FieldKey.legSizeMm,
          label: 'Leg Size (mm)',
          helperText: 'Equal leg size of the fillet weld.',
        ),
      );
    }

    if (_weldingProcess == WeldingProcess.gtaw) {
      specs.add(
        const _InputFieldSpec.diameter(
          key: _FieldKey.wireDiameterMm,
          label: 'GTAW Wire Diameter (mm)',
          helperText: 'Common filler diameters: 1.6, 2.0, 2.4, 3.2 mm.',
          diameterOptions: [
            _DiameterPresetOption(label: '1.6 mm', value: 1.6),
            _DiameterPresetOption(label: '2.0 mm', value: 2.0),
            _DiameterPresetOption(label: '2.4 mm', value: 2.4),
            _DiameterPresetOption(label: '3.2 mm', value: 3.2),
          ],
        ),
      );
    }

    if (_weldingProcess == WeldingProcess.smaw) {
      specs.add(
        const _InputFieldSpec.diameter(
          key: _FieldKey.electrodeDiameterMm,
          label: 'SMAW Electrode Diameter (mm)',
          helperText: 'Common electrode diameters: 2.5, 3.2, 4.0, 5.0 mm.',
          diameterOptions: [
            _DiameterPresetOption(label: '2.5 mm', value: 2.5),
            _DiameterPresetOption(label: '3.2 mm', value: 3.2),
            _DiameterPresetOption(label: '4.0 mm', value: 4.0),
            _DiameterPresetOption(label: '5.0 mm', value: 5.0),
          ],
        ),
      );
    }

    if (_weldingProcess == WeldingProcess.gmaw ||
        _weldingProcess == WeldingProcess.fcaw) {
      specs.add(
        _InputFieldSpec.diameter(
          key: _FieldKey.wireDiameterMm,
          label: _weldingProcess == WeldingProcess.gmaw
              ? 'GMAW Wire Diameter (mm)'
              : 'FCAW Wire Diameter (mm)',
          helperText: _weldingProcess == WeldingProcess.gmaw
              ? 'Common wire diameters: 0.8, 1.0, 1.2, 1.6 mm.'
              : 'Common wire diameters: 1.2, 1.6, 2.0 mm.',
          diameterOptions: _weldingProcess == WeldingProcess.gmaw
              ? const [
                  _DiameterPresetOption(label: '0.8 mm', value: 0.8),
                  _DiameterPresetOption(label: '1.0 mm', value: 1.0),
                  _DiameterPresetOption(label: '1.2 mm', value: 1.2),
                  _DiameterPresetOption(label: '1.6 mm', value: 1.6),
                ]
              : const [
                  _DiameterPresetOption(label: '1.2 mm', value: 1.2),
                  _DiameterPresetOption(label: '1.6 mm', value: 1.6),
                  _DiameterPresetOption(label: '2.0 mm', value: 2.0),
                ],
        ),
      );
    }

    if (_weldingProcess == WeldingProcess.gtawSmaw) {
      specs.addAll(const [
        _InputFieldSpec(
          key: _FieldKey.gtawTransitionMm,
          label: 'GTAW Transition Depth (mm)',
          helperText:
              'Depth deposited by GTAW from the root side before switching to SMAW.',
        ),
        _InputFieldSpec.diameter(
          key: _FieldKey.gtawWireDiameterMm,
          label: 'GTAW Wire Diameter (mm)',
          helperText: 'Common filler diameters: 1.6, 2.0, 2.4, 3.2 mm.',
          diameterOptions: [
            _DiameterPresetOption(label: '1.6 mm', value: 1.6),
            _DiameterPresetOption(label: '2.0 mm', value: 2.0),
            _DiameterPresetOption(label: '2.4 mm', value: 2.4),
            _DiameterPresetOption(label: '3.2 mm', value: 3.2),
          ],
        ),
        _InputFieldSpec.diameter(
          key: _FieldKey.smawElectrodeDiameterMm,
          label: 'SMAW Electrode Diameter (mm)',
          helperText: 'Common electrode diameters: 2.5, 3.2, 4.0, 5.0 mm.',
          diameterOptions: [
            _DiameterPresetOption(label: '2.5 mm', value: 2.5),
            _DiameterPresetOption(label: '3.2 mm', value: 3.2),
            _DiameterPresetOption(label: '4.0 mm', value: 4.0),
            _DiameterPresetOption(label: '5.0 mm', value: 5.0),
          ],
        ),
      ]);
    }

    if (_depositionRateMode == DepositionRateMode.manual) {
      if (_weldingProcess == WeldingProcess.gtawSmaw) {
        specs.addAll(const [
          _InputFieldSpec(
            key: _FieldKey.manualGtawRateKgPerHour,
            label: 'GTAW Deposition Rate (kg/h)',
            helperText:
                'User-defined deposition rate for the GTAW root portion.',
          ),
          _InputFieldSpec(
            key: _FieldKey.manualSmawRateKgPerHour,
            label: 'SMAW Deposition Rate (kg/h)',
            helperText:
                'User-defined deposition rate for the SMAW fill and cap portion.',
          ),
        ]);
      } else {
        specs.add(
          const _InputFieldSpec(
            key: _FieldKey.manualDepositionRateKgPerHour,
            label: 'Deposition Rate (kg/h)',
            helperText:
                'User-defined deposition rate based on shop data, planning value, or WPS assumption.',
          ),
        );
      }
    }

    specs.addAll(const [
      _InputFieldSpec(
        key: _FieldKey.density,
        label: 'Density (g/cm3)',
        helperText:
            'Bulk weld metal density. Default follows the selected classification.',
      ),
      _InputFieldSpec(
        key: _FieldKey.wasteFactor,
        label: 'Waste Allowance (%)',
        helperText: 'Allowance for stub loss, cut-off, spatter, and handling.',
      ),
    ]);

    return specs;
  }

  void _onJointTypeChanged(JointType jointType) {
    setState(() {
      _jointType = jointType;
      if (!_jointType.supportedGrooves.contains(_grooveType)) {
        _grooveType = _jointType.supportedGrooves.first;
      }
      _result = null;
    });
  }

  double get _previewDepositionRate {
    if (_depositionRateMode == DepositionRateMode.manual) {
      return _manualPreviewDepositionRate;
    }

    return switch (_weldingProcess) {
      WeldingProcess.gtaw => WeldingDefaults.gtawRateForWire(
        _parsePreviewValue(_FieldKey.wireDiameterMm),
      ),
      WeldingProcess.smaw => WeldingDefaults.smawRateForElectrode(
        _parsePreviewValue(_FieldKey.electrodeDiameterMm),
      ),
      WeldingProcess.gtawSmaw => _combinedPreviewRate,
      WeldingProcess.gmaw => WeldingDefaults.gmawRateForWire(
        _parsePreviewValue(_FieldKey.wireDiameterMm),
      ),
      WeldingProcess.fcaw => WeldingDefaults.fcawRateForWire(
        _parsePreviewValue(_FieldKey.wireDiameterMm),
      ),
    };
  }

  double get _manualPreviewDepositionRate {
    if (_weldingProcess != WeldingProcess.gtawSmaw) {
      return _parsePreviewValue(_FieldKey.manualDepositionRateKgPerHour) ??
          WeldingDefaults.depositionRateFor(_weldingProcess);
    }

    final gtawRate =
        _parsePreviewValue(_FieldKey.manualGtawRateKgPerHour) ??
        WeldingDefaults.depositionRateFor(WeldingProcess.gtaw);
    final smawRate =
        _parsePreviewValue(_FieldKey.manualSmawRateKgPerHour) ??
        WeldingDefaults.depositionRateFor(WeldingProcess.smaw);
    final ratio = _combinedProcessPreviewRatio;
    return (gtawRate * ratio) + (smawRate * (1 - ratio));
  }

  double get _previewEfficiency {
    if (_weldingProcess != WeldingProcess.gtawSmaw) {
      return WeldingDefaults.efficiencyFor(_weldingProcess);
    }

    final gtawMm = _parsePreviewValue(_FieldKey.gtawTransitionMm) ?? 3;
    final thickness = _parsePreviewValue(_FieldKey.thicknessMm);
    final leg = _parsePreviewValue(_FieldKey.legSizeMm);
    final totalHeight = thickness ?? leg ?? gtawMm;
    final ratio = totalHeight <= 0
        ? 0.5
        : (gtawMm / totalHeight).clamp(0.0, 1.0);
    final gtawEff = WeldingDefaults.efficiencyFor(WeldingProcess.gtaw);
    final smawEff = WeldingDefaults.efficiencyFor(WeldingProcess.smaw);
    final denominator = (ratio / gtawEff) + ((1 - ratio) / smawEff);
    return denominator == 0 ? 0 : 1 / denominator;
  }

  double get _combinedPreviewRate {
    final gtawRate = WeldingDefaults.gtawRateForWire(
      _parsePreviewValue(_FieldKey.gtawWireDiameterMm),
    );
    final smawRate = WeldingDefaults.smawRateForElectrode(
      _parsePreviewValue(_FieldKey.smawElectrodeDiameterMm),
    );
    final ratio = _combinedProcessPreviewRatio;
    return (gtawRate * ratio) + (smawRate * (1 - ratio));
  }

  double get _combinedProcessPreviewRatio {
    final gtawMm = _parsePreviewValue(_FieldKey.gtawTransitionMm) ?? 3;
    final thickness = _parsePreviewValue(_FieldKey.thicknessMm);
    final leg = _parsePreviewValue(_FieldKey.legSizeMm);
    final totalHeight = thickness ?? leg ?? gtawMm;
    return totalHeight <= 0 ? 0.5 : (gtawMm / totalHeight).clamp(0.0, 1.0);
  }

  String _processRateSummary(double efficiency, double depositionRate) {
    final sourceText = _depositionRateMode == DepositionRateMode.manual
        ? 'Manual'
        : 'Estimated';

    if (_weldingProcess == WeldingProcess.gtawSmaw) {
      final gtawUpTo = _formatNumber(
        _parsePreviewValue(_FieldKey.gtawTransitionMm) ?? 3,
        1,
      );
      final gtawSetting = _depositionRateMode == DepositionRateMode.manual
          ? '${_formatNumber(_parsePreviewValue(_FieldKey.manualGtawRateKgPerHour) ?? WeldingDefaults.depositionRateFor(WeldingProcess.gtaw), 2)} kg/h'
          : '${_formatNumber(_parsePreviewValue(_FieldKey.gtawWireDiameterMm) ?? 2.4, 1)} mm wire';
      final smawSetting = _depositionRateMode == DepositionRateMode.manual
          ? '${_formatNumber(_parsePreviewValue(_FieldKey.manualSmawRateKgPerHour) ?? WeldingDefaults.depositionRateFor(WeldingProcess.smaw), 2)} kg/h'
          : '${_formatNumber(_parsePreviewValue(_FieldKey.smawElectrodeDiameterMm) ?? 3.2, 1)} mm electrode';
      return 'Rate basis $sourceText | GTAW transition depth $gtawUpTo mm, then SMAW | Deposition efficiency ${_formatPercent(efficiency)} | Equivalent deposition rate ${_formatNumber(depositionRate, 2)} kg/h | GTAW $gtawSetting | SMAW $smawSetting';
    }

    final detailText = _depositionRateMode == DepositionRateMode.manual
        ? ' | User-defined ${_formatNumber(_parsePreviewValue(_FieldKey.manualDepositionRateKgPerHour) ?? WeldingDefaults.depositionRateFor(_weldingProcess), 2)} kg/h'
        : switch (_weldingProcess) {
            WeldingProcess.gtaw =>
              ' | Wire ${_formatNumber(_parsePreviewValue(_FieldKey.wireDiameterMm) ?? 2.4, 1)} mm',
            WeldingProcess.smaw =>
              ' | Electrode ${_formatNumber(_parsePreviewValue(_FieldKey.electrodeDiameterMm) ?? 3.2, 1)} mm',
            WeldingProcess.gmaw =>
              ' | Wire ${_formatNumber(_parsePreviewValue(_FieldKey.wireDiameterMm) ?? 1.2, 1)} mm',
            WeldingProcess.fcaw =>
              ' | Wire ${_formatNumber(_parsePreviewValue(_FieldKey.wireDiameterMm) ?? 1.6, 1)} mm',
            WeldingProcess.gtawSmaw => '',
          };
    return 'Rate basis $sourceText | Deposition efficiency ${_formatPercent(efficiency)} | Deposition rate ${_formatNumber(depositionRate, 2)} kg/h$detailText';
  }

  String get _unequalGeometrySummary {
    if (!_isUnequalGeometry) return '';

    final thickness = _governingThicknessPreview;
    final od = _governingPipeOdPreview;
    final thicknessText = thickness == null
        ? ''
        : 'Unequal joint | Governing thickness ${_formatNumber(thickness, 1)} mm | ';
    final odText = _jointType == JointType.pipeButt && od != null
        ? 'Reference OD ${_formatNumber(od, 1)} mm | ${_jointAlignment.label} | '
        : _jointType == JointType.plateButt
        ? '${_jointAlignment.label} | '
        : '';
    return '$thicknessText$odText';
  }

  String get _presetRateHelperText {
    if (_weldingProcess == WeldingProcess.gtawSmaw) {
      return 'Estimated mode derives GTAW and SMAW deposition rates from the selected filler diameters, then combines them using the GTAW transition depth.';
    }

    return 'Estimated mode derives deposition rate from process and filler diameter. Use it for preliminary estimating, not qualification-level planning.';
  }

  String get _manualRateHelperText {
    if (_weldingProcess == WeldingProcess.gtawSmaw) {
      return 'Manual mode lets you enter separate GTAW and SMAW deposition rates so arc time follows the planned root, fill, and cap sequence.';
    }

    return 'Manual mode overrides the estimated rate with a measured shop value, project planning value, or WPS assumption.';
  }

  void _syncConsumableForProcess() {
    final available = WeldingDefaults.consumablesFor(_weldingProcess);
    if (!available.contains(_consumablePreset)) {
      _consumablePreset = WeldingDefaults.defaultConsumableFor(_weldingProcess);
    }
    _applyConsumablePreset(_consumablePreset);
  }

  UserWeldPreset? get _selectedUserPreset {
    final presetId = _selectedUserPresetId;
    if (presetId == null) return null;
    for (final preset in _userPresets) {
      if (preset.id == presetId) return preset;
    }
    return null;
  }

  Future<void> _loadUserPresets() async {
    final presets = await _userPresetStore.load();
    if (!mounted) return;
    setState(() {
      _userPresets = presets;
      if (_selectedUserPresetId != null &&
          !_userPresets.any((preset) => preset.id == _selectedUserPresetId)) {
        _selectedUserPresetId = null;
      }
    });
  }

  void _applyInputPreset(InputPreset preset) {
    final data = preset.data;
    if (data == null) return;

    setState(() {
      _inputPreset = preset;
      _selectedUserPresetId = null;
      _applyPresetData(data, usePresetDiameters: true);
      _result = null;
    });
  }

  void _applyUserPreset(UserWeldPreset preset) {
    setState(() {
      _inputPreset = InputPreset.custom;
      _selectedUserPresetId = preset.id;
      _applyPresetData(preset.data, usePresetDiameters: false);
      _result = null;
    });
  }

  void _applyPresetData(
    WeldInputPresetData data, {
    required bool usePresetDiameters,
  }) {
    _jointType = data.jointType;
    _grooveType = data.grooveType;
    _weldingProcess = data.weldingProcess;
    _depositionRateMode = data.depositionRateMode;
    _jointGeometryMode = data.jointGeometryMode;
    _jointAlignment = data.jointAlignment;
    _consumablePreset = data.consumablePreset;

    _applyProcessFieldDefaults();
    _syncConsumableForProcess();

    _setControllerValue(_FieldKey.quantity, data.quantity);
    _setControllerValue(_FieldKey.lengthMm, data.lengthPerPieceMm);
    _setControllerValue(_FieldKey.pipeOdMm, data.pipeOdMm);
    _setControllerValue(_FieldKey.pipeOdAMm, data.pipeOdAMm);
    _setControllerValue(_FieldKey.pipeOdBMm, data.pipeOdBMm);
    _setControllerValue(_FieldKey.thicknessMm, data.thicknessMm);
    _setControllerValue(_FieldKey.thicknessAMm, data.thicknessAMm);
    _setControllerValue(_FieldKey.thicknessBMm, data.thicknessBMm);
    _setControllerValue(_FieldKey.rootGapMm, data.rootGapMm);
    _setControllerValue(_FieldKey.rootFaceMm, data.rootFaceMm);
    _setControllerValue(_FieldKey.bevelAngleDeg, data.bevelAngleDeg);
    _setControllerValue(
      _FieldKey.secondaryBevelAngleDeg,
      data.secondaryBevelAngleDeg,
    );
    _setControllerValue(_FieldKey.breakHeightMm, data.breakHeightMm);
    _setControllerValue(_FieldKey.legSizeMm, data.legSizeMm);
    _setControllerValue(_FieldKey.gtawTransitionMm, data.gtawTransitionMm);
    _setControllerValue(
      _FieldKey.manualDepositionRateKgPerHour,
      data.manualDepositionRateKgPerHour,
    );
    _setControllerValue(
      _FieldKey.manualGtawRateKgPerHour,
      data.manualGtawRateKgPerHour,
    );
    _setControllerValue(
      _FieldKey.manualSmawRateKgPerHour,
      data.manualSmawRateKgPerHour,
    );
    _setControllerValue(_FieldKey.wasteFactor, data.wasteFactorPercent);

    _applyDiameterOrValue(
      _FieldKey.wireDiameterMm,
      data.wireDiameterMm,
      usePreset: usePresetDiameters,
    );
    _applyDiameterOrValue(
      _FieldKey.electrodeDiameterMm,
      data.electrodeDiameterMm,
      usePreset: usePresetDiameters,
    );
    _applyDiameterOrValue(
      _FieldKey.gtawWireDiameterMm,
      data.gtawWireDiameterMm,
      usePreset: usePresetDiameters,
    );
    _applyDiameterOrValue(
      _FieldKey.smawElectrodeDiameterMm,
      data.smawElectrodeDiameterMm,
      usePreset: usePresetDiameters,
    );

    if (data.densityGPerCm3 != null) {
      _setControllerValue(_FieldKey.density, data.densityGPerCm3);
    }
  }

  Future<void> _saveCurrentAsUserPreset() async {
    final name = await _promptPresetName();
    if (name == null || name.trim().isEmpty) return;

    try {
      setState(() => _isUserPresetBusy = true);
      final preset = UserWeldPreset(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.trim(),
        updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        data: _captureCurrentPresetData(),
      );
      final presets = [..._userPresets, preset]
        ..sort((a, b) => b.updatedAtEpochMs.compareTo(a.updatedAtEpochMs));
      await _userPresetStore.save(presets);
      if (!mounted) return;
      setState(() {
        _userPresets = presets;
        _selectedUserPresetId = preset.id;
        _inputPreset = InputPreset.custom;
      });
      _showMessage('Preset saved.');
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isUserPresetBusy = false);
      }
    }
  }

  Future<void> _updateSelectedUserPreset() async {
    final current = _selectedUserPreset;
    if (current == null) return;

    final name = await _promptPresetName(initialValue: current.name);
    if (name == null || name.trim().isEmpty) return;

    try {
      setState(() => _isUserPresetBusy = true);
      final updated = current.copyWith(
        name: name.trim(),
        data: _captureCurrentPresetData(),
        updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      );
      final presets =
          _userPresets
              .map((preset) => preset.id == updated.id ? updated : preset)
              .toList()
            ..sort((a, b) => b.updatedAtEpochMs.compareTo(a.updatedAtEpochMs));
      await _userPresetStore.save(presets);
      if (!mounted) return;
      setState(() {
        _userPresets = presets;
        _selectedUserPresetId = updated.id;
      });
      _showMessage('Preset updated.');
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isUserPresetBusy = false);
      }
    }
  }

  Future<void> _deleteSelectedUserPreset() async {
    final current = _selectedUserPreset;
    if (current == null) return;

    final confirmed = await _confirmDeleteUserPreset(current.name);
    if (confirmed != true) return;

    try {
      setState(() => _isUserPresetBusy = true);
      final presets = _userPresets
          .where((preset) => preset.id != current.id)
          .toList();
      await _userPresetStore.save(presets);
      if (!mounted) return;
      setState(() {
        _userPresets = presets;
        _selectedUserPresetId = null;
      });
      _showMessage('Preset deleted.');
    } catch (_) {
      _showMessage('Preset delete failed.');
    } finally {
      if (mounted) {
        setState(() => _isUserPresetBusy = false);
      }
    }
  }

  WeldInputPresetData _captureCurrentPresetData() => WeldInputPresetData(
    jointType: _jointType,
    grooveType: _grooveType,
    weldingProcess: _weldingProcess,
    consumablePreset: _consumablePreset,
    depositionRateMode: _depositionRateMode,
    jointGeometryMode: _jointGeometryMode,
    jointAlignment: _jointAlignment,
    quantity: _parsePresetValue(_FieldKey.quantity, 'Quantity') ?? 1,
    wasteFactorPercent:
        _parsePresetValue(_FieldKey.wasteFactor, 'Waste allowance') ??
        WeldingDefaults.wasteFactorPercent,
    densityGPerCm3: _parsePresetValue(_FieldKey.density, 'Density'),
    lengthPerPieceMm: _parsePresetValue(_FieldKey.lengthMm, 'Weld length'),
    pipeOdMm: _parsePresetValue(_FieldKey.pipeOdMm, 'Pipe OD'),
    pipeOdAMm: _parsePresetValue(_FieldKey.pipeOdAMm, 'Pipe OD A'),
    pipeOdBMm: _parsePresetValue(_FieldKey.pipeOdBMm, 'Pipe OD B'),
    thicknessMm: _parsePresetValue(_FieldKey.thicknessMm, 'Thickness'),
    thicknessAMm: _parsePresetValue(_FieldKey.thicknessAMm, 'Thickness A'),
    thicknessBMm: _parsePresetValue(_FieldKey.thicknessBMm, 'Thickness B'),
    rootGapMm: _parsePresetValue(_FieldKey.rootGapMm, 'Root gap'),
    rootFaceMm: _parsePresetValue(_FieldKey.rootFaceMm, 'Root face'),
    bevelAngleDeg: _parsePresetValue(_FieldKey.bevelAngleDeg, 'Bevel angle'),
    secondaryBevelAngleDeg: _parsePresetValue(
      _FieldKey.secondaryBevelAngleDeg,
      'Secondary bevel angle',
    ),
    breakHeightMm: _parsePresetValue(_FieldKey.breakHeightMm, 'Break height'),
    legSizeMm: _parsePresetValue(_FieldKey.legSizeMm, 'Leg size'),
    gtawTransitionMm: _parsePresetValue(
      _FieldKey.gtawTransitionMm,
      'GTAW transition depth',
    ),
    wireDiameterMm: _parsePresetValue(
      _FieldKey.wireDiameterMm,
      'Wire diameter',
    ),
    electrodeDiameterMm: _parsePresetValue(
      _FieldKey.electrodeDiameterMm,
      'Electrode diameter',
    ),
    gtawWireDiameterMm: _parsePresetValue(
      _FieldKey.gtawWireDiameterMm,
      'GTAW wire diameter',
    ),
    smawElectrodeDiameterMm: _parsePresetValue(
      _FieldKey.smawElectrodeDiameterMm,
      'SMAW electrode diameter',
    ),
    manualDepositionRateKgPerHour: _parsePresetValue(
      _FieldKey.manualDepositionRateKgPerHour,
      'Deposition rate',
    ),
    manualGtawRateKgPerHour: _parsePresetValue(
      _FieldKey.manualGtawRateKgPerHour,
      'GTAW deposition rate',
    ),
    manualSmawRateKgPerHour: _parsePresetValue(
      _FieldKey.manualSmawRateKgPerHour,
      'SMAW deposition rate',
    ),
  );

  double? _parsePresetValue(_FieldKey key, String label) {
    final raw = _controllers[key]!.text.trim();
    if (raw.isEmpty) return null;
    final parsed = double.tryParse(raw.replaceAll(',', '.'));
    if (parsed == null || !parsed.isFinite) {
      throw FormatException('$label must be a valid number before saving.');
    }
    return parsed;
  }

  Future<String?> _promptPresetName({String? initialValue}) async {
    final controller = TextEditingController(text: initialValue ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(initialValue == null ? 'Save Preset' : 'Update Preset'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Preset Name',
              helperText: 'Use a short technical reference name.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(initialValue == null ? 'Save' : 'Update'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }

  Future<bool?> _confirmDeleteUserPreset(String name) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Preset'),
          content: Text(
            'Delete "$name" from local saved presets? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _applyConsumablePreset(ConsumablePreset preset) {
    _controllers[_FieldKey.density]!.text = preset.densityGPerCm3
        .toStringAsFixed(2);
  }

  void _applyProcessFieldDefaults() {
    _controllers[_FieldKey.manualDepositionRateKgPerHour]!.text =
        WeldingDefaults.depositionRateFor(_weldingProcess).toStringAsFixed(1);
    _controllers[_FieldKey.manualGtawRateKgPerHour]!.text =
        WeldingDefaults.depositionRateFor(
          WeldingProcess.gtaw,
        ).toStringAsFixed(1);
    _controllers[_FieldKey.manualSmawRateKgPerHour]!.text =
        WeldingDefaults.depositionRateFor(
          WeldingProcess.smaw,
        ).toStringAsFixed(1);

    if (_weldingProcess == WeldingProcess.gtaw) {
      _setDiameterPreset(_FieldKey.wireDiameterMm, 2.4);
    } else if (_weldingProcess == WeldingProcess.smaw) {
      _setDiameterPreset(_FieldKey.electrodeDiameterMm, 3.2);
    } else if (_weldingProcess == WeldingProcess.gtawSmaw) {
      _controllers[_FieldKey.gtawTransitionMm]!.text = '3';
      _setDiameterPreset(_FieldKey.gtawWireDiameterMm, 2.4);
      _setDiameterPreset(_FieldKey.smawElectrodeDiameterMm, 3.2);
    } else if (_weldingProcess == WeldingProcess.gmaw) {
      _setDiameterPreset(_FieldKey.wireDiameterMm, 1.2);
    } else if (_weldingProcess == WeldingProcess.fcaw) {
      _setDiameterPreset(_FieldKey.wireDiameterMm, 1.6);
    }
  }

  WeldDrawingData get _drawingData => WeldDrawingData(
    weldingProcess: _weldingProcess,
    geometryMode: _jointGeometryMode,
    alignment: _jointAlignment,
    thicknessMm: _governingThicknessPreview,
    thicknessAMm: _thicknessAPreview,
    thicknessBMm: _thicknessBPreview,
    rootGapMm: _parsePreviewValue(_FieldKey.rootGapMm),
    rootFaceMm: _parsePreviewValue(_FieldKey.rootFaceMm),
    bevelAngleDeg: _parsePreviewValue(_FieldKey.bevelAngleDeg),
    secondaryBevelAngleDeg: _parsePreviewValue(
      _FieldKey.secondaryBevelAngleDeg,
    ),
    breakHeightMm: _parsePreviewValue(_FieldKey.breakHeightMm),
    legSizeMm: _parsePreviewValue(_FieldKey.legSizeMm),
    pipeOdMm: _governingPipeOdPreview,
    pipeOdAMm: _pipeOdAPreview,
    pipeOdBMm: _pipeOdBPreview,
    gtawTransitionMm: _parsePreviewValue(_FieldKey.gtawTransitionMm),
  );

  Widget _buildFieldInput(_InputFieldSpec field) {
    if (field.diameterOptions != null) {
      return _buildDiameterField(field);
    }

    return TextField(
      controller: _controllers[field.key],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(
        labelText: field.label,
        helperText: field.helperText,
      ),
      onChanged: (_) => setState(() => _result = null),
    );
  }

  Widget _buildDiameterField(_InputFieldSpec field) {
    final selectedMode =
        _diameterPresetModes[field.key] ??
        _resolveDiameterModeFromController(field);
    final customMode = selectedMode == _customDiameterValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownFrame(
          DropdownButtonFormField<String>(
            initialValue: selectedMode,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: field.label,
              helperText: field.helperText,
            ),
            selectedItemBuilder: (context) => [
              for (final option in field.diameterOptions!)
                _buildDropdownSelectedText(option.label),
              _buildDropdownSelectedText('Custom diameter'),
            ],
            items: [
              for (final option in field.diameterOptions!)
                DropdownMenuItem(
                  value: _diameterValueToken(option.value),
                  child: Text(option.label, overflow: TextOverflow.ellipsis),
                ),
              const DropdownMenuItem(
                value: _customDiameterValue,
                child: Text('Custom diameter'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _diameterPresetModes[field.key] = value;
                if (value != _customDiameterValue) {
                  _controllers[field.key]!.text = value;
                }
                _result = null;
              });
            },
          ),
        ),
        if (customMode) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _controllers[field.key],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Custom Diameter (mm)',
              helperText: 'Enter an exact diameter value.',
            ),
            onChanged: (_) => setState(() => _result = null),
          ),
        ],
      ],
    );
  }

  String _resolveDiameterModeFromController(_InputFieldSpec field) {
    final parsed = _parsePreviewValue(field.key);
    if (parsed == null) return _customDiameterValue;

    for (final option in field.diameterOptions!) {
      if ((option.value - parsed).abs() < 0.001) {
        final token = _diameterValueToken(option.value);
        _diameterPresetModes[field.key] = token;
        return token;
      }
    }

    _diameterPresetModes[field.key] = _customDiameterValue;
    return _customDiameterValue;
  }

  Widget _buildSelectionChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: const Color(0xFF0F4C5C),
      backgroundColor: const Color(0xFFF1F5F7),
      side: BorderSide(
        color: selected ? const Color(0xFF0F4C5C) : const Color(0xFFD6E0E6),
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

  Widget _buildDropdownFrame(Widget child) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF4F8FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFDCE5EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F3040),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: child,
    );
  }

  Widget _buildDropdownSelectedText(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF17303C),
        ),
      ),
    );
  }

  String _diameterValueToken(double value) => value.toStringAsFixed(1);

  void _setControllerValue(_FieldKey key, double? value, {int? digits}) {
    if (value == null) return;
    _controllers[key]!.text = digits == null
        ? value.toString()
        : value.toStringAsFixed(digits);
  }

  void _setDiameterPreset(_FieldKey key, double value) {
    final token = _diameterValueToken(value);
    _diameterPresetModes[key] = token;
    _controllers[key]!.text = token;
  }

  void _applyDiameterOrValue(
    _FieldKey key,
    double? value, {
    required bool usePreset,
  }) {
    if (value == null) return;
    if (usePreset) {
      _setDiameterPreset(key, value);
      return;
    }
    _setControllerValue(key, value);
    _diameterPresetModes[key] = _customDiameterValue;
  }

  void _calculate() {
    try {
      final input = WeldInputData(
        jointType: _jointType,
        grooveType: _grooveType,
        weldingProcess: _weldingProcess,
        depositionRateMode: _depositionRateMode,
        quantity: _parseRequired(_FieldKey.quantity, 'Quantity'),
        densityGPerCm3: _parseRequired(_FieldKey.density, 'Density'),
        wasteFactorPercent: _parseRequired(
          _FieldKey.wasteFactor,
          'Waste factor',
        ),
        lengthPerPieceMm: _parseOptional(_FieldKey.lengthMm),
        pipeOdMm: _resolvePipeOdForCalculation(),
        thicknessMm: _resolveThicknessForCalculation(),
        rootGapMm: _parseOptional(_FieldKey.rootGapMm),
        rootFaceMm: _parseOptional(_FieldKey.rootFaceMm),
        bevelAngleDeg: _parseOptional(_FieldKey.bevelAngleDeg),
        secondaryBevelAngleDeg: _parseOptional(
          _FieldKey.secondaryBevelAngleDeg,
        ),
        breakHeightMm: _parseOptional(_FieldKey.breakHeightMm),
        legSizeMm: _parseOptional(_FieldKey.legSizeMm),
        gtawTransitionMm: _parseOptional(_FieldKey.gtawTransitionMm),
        wireDiameterMm: _parseOptional(_FieldKey.wireDiameterMm),
        electrodeDiameterMm: _parseOptional(_FieldKey.electrodeDiameterMm),
        gtawWireDiameterMm: _parseOptional(_FieldKey.gtawWireDiameterMm),
        smawElectrodeDiameterMm: _parseOptional(
          _FieldKey.smawElectrodeDiameterMm,
        ),
        manualDepositionRateKgPerHour: _parseOptional(
          _FieldKey.manualDepositionRateKgPerHour,
        ),
        manualGtawRateKgPerHour: _parseOptional(
          _FieldKey.manualGtawRateKgPerHour,
        ),
        manualSmawRateKgPerHour: _parseOptional(
          _FieldKey.manualSmawRateKgPerHour,
        ),
      );

      final result = _calculator.calculate(input);
      setState(() => _result = result);
    } on InputValidationException catch (error) {
      setState(() => _result = null);
      _showMessage(error.message);
    } on FormatException catch (error) {
      setState(() => _result = null);
      _showMessage(error.message);
    } catch (_) {
      setState(() => _result = null);
      _showMessage('Calculation failed. Please review the inputs.');
    }
  }

  double? _resolveThicknessForCalculation() {
    if (!_isUnequalGeometry) {
      return _parseOptional(_FieldKey.thicknessMm);
    }
    final a = _parseOptional(_FieldKey.thicknessAMm);
    final b = _parseOptional(_FieldKey.thicknessBMm);
    if (a == null && b == null) return null;
    if (a == null) return b;
    if (b == null) return a;
    return a >= b ? a : b;
  }

  double? _resolvePipeOdForCalculation() {
    if (!_isUnequalGeometry) {
      return _parseOptional(_FieldKey.pipeOdMm);
    }
    final a = _parseOptional(_FieldKey.pipeOdAMm);
    final b = _parseOptional(_FieldKey.pipeOdBMm);
    if (a == null && b == null) return null;
    if (a == null) return b;
    if (b == null) return a;
    return a >= b ? a : b;
  }

  void _resetFields() {
    _controllers[_FieldKey.quantity]!.text = '1';
    _controllers[_FieldKey.lengthMm]!.text = '1000';
    _controllers[_FieldKey.pipeOdMm]!.text = '168.3';
    _controllers[_FieldKey.pipeOdAMm]!.text = '168.3';
    _controllers[_FieldKey.pipeOdBMm]!.text = '168.3';
    _controllers[_FieldKey.thicknessMm]!.text = '12';
    _controllers[_FieldKey.thicknessAMm]!.text = '12';
    _controllers[_FieldKey.thicknessBMm]!.text = '12';
    _controllers[_FieldKey.rootGapMm]!.text = '3';
    _controllers[_FieldKey.rootFaceMm]!.text = '2';
    _controllers[_FieldKey.bevelAngleDeg]!.text = '30';
    _controllers[_FieldKey.secondaryBevelAngleDeg]!.text = '10';
    _controllers[_FieldKey.breakHeightMm]!.text = '4';
    _controllers[_FieldKey.legSizeMm]!.text = '6';
    _controllers[_FieldKey.gtawTransitionMm]!.text = '3';
    _controllers[_FieldKey.wireDiameterMm]!.text = '2.4';
    _controllers[_FieldKey.electrodeDiameterMm]!.text = '3.2';
    _controllers[_FieldKey.gtawWireDiameterMm]!.text = '2.4';
    _controllers[_FieldKey.smawElectrodeDiameterMm]!.text = '3.2';
    _controllers[_FieldKey.manualDepositionRateKgPerHour]!.text = '0.8';
    _controllers[_FieldKey.manualGtawRateKgPerHour]!.text = '0.8';
    _controllers[_FieldKey.manualSmawRateKgPerHour]!.text = '1.2';
    _controllers[_FieldKey.wasteFactor]!.text = WeldingDefaults
        .wasteFactorPercent
        .toStringAsFixed(0);

    setState(() {
      _jointType = JointType.plateButt;
      _grooveType = GrooveType.singleV;
      _weldingProcess = WeldingProcess.gtaw;
      _depositionRateMode = DepositionRateMode.preset;
      _drawingMode = DrawingMode.visual;
      _jointGeometryMode = JointGeometryMode.equal;
      _jointAlignment = JointAlignment.centerline;
      _inputPreset = InputPreset.custom;
      _selectedUserPresetId = null;
      _applyProcessFieldDefaults();
      _consumablePreset = WeldingDefaults.defaultConsumableFor(_weldingProcess);
      _applyConsumablePreset(_consumablePreset);
      _result = null;
    });
  }

  double _parseRequired(_FieldKey key, String label) {
    final value = _controllers[key]!.text.trim();
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) {
      throw FormatException('$label must be a valid number.');
    }
    return parsed;
  }

  double? _parseOptional(_FieldKey key) {
    final value = _controllers[key]!.text.trim();
    if (value.isEmpty) return null;
    return double.tryParse(value.replaceAll(',', '.'));
  }

  double? _parsePreviewValue(_FieldKey key) {
    final value = _controllers[key]!.text.trim();
    if (value.isEmpty) return null;
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null || !parsed.isFinite || parsed <= 0) {
      return null;
    }
    return parsed;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _exportPdf() async {
    final result = _result;
    if (result == null || _isExportingPdf) return;

    final basisEntries = _buildCalculationBasis()
        .map((item) => MapEntry(item.label, item.value))
        .toList();

    setState(() => _isExportingPdf = true);
    try {
      await _pdfReportService.export(
        jointType: _jointType,
        grooveType: _grooveType,
        weldingProcess: _weldingProcess,
        consumablePreset: _consumablePreset,
        result: result,
        basisEntries: basisEntries,
      );
      if (!mounted) return;
      _showMessage('PDF report exported successfully.');
    } catch (_) {
      if (!mounted) return;
      _showMessage('PDF export failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isExportingPdf = false);
      }
    }
  }

  String _formatNumber(double value, int digits) =>
      value.toStringAsFixed(digits);

  String _formatPercent(double ratio, {int digits = 1}) =>
      '${(ratio * 100).toStringAsFixed(digits)}%';

  List<_CalculationBasisItem> _buildCalculationBasis() {
    final items = <_CalculationBasisItem>[
      _CalculationBasisItem('Process', _weldingProcess.label),
      _CalculationBasisItem('Rate Basis', _depositionRateMode.label),
      if (_inputPreset != InputPreset.custom)
        _CalculationBasisItem('Input Preset', _inputPreset.label),
      if (_selectedUserPreset != null)
        _CalculationBasisItem('Saved Preset', _selectedUserPreset!.name),
      _CalculationBasisItem('Joint', _jointType.label),
      if (_supportsUnequalGeometry)
        _CalculationBasisItem('Geometry', _jointGeometryMode.label),
      if (_isUnequalGeometry)
        _CalculationBasisItem('Alignment', _jointAlignment.label),
      _CalculationBasisItem('Groove', _grooveType.label),
      _CalculationBasisItem(
        'Classification',
        '${_consumablePreset.awsSpecification} ${_consumablePreset.label}',
      ),
      _CalculationBasisItem(
        'Filler Metal Family',
        _consumablePreset.family.label,
      ),
      _CalculationBasisItem(
        'Density',
        '${_controllers[_FieldKey.density]!.text} g/cm3',
      ),
      _CalculationBasisItem(
        'Waste Allowance',
        '${_controllers[_FieldKey.wasteFactor]!.text}%',
      ),
      _CalculationBasisItem('Quantity', _controllers[_FieldKey.quantity]!.text),
    ];

    if (_jointType == JointType.plateButt || _jointType == JointType.fillet) {
      items.add(
        _CalculationBasisItem(
          'Weld Length per Piece',
          '${_controllers[_FieldKey.lengthMm]!.text} mm',
        ),
      );
    }

    if (_jointType == JointType.pipeButt && !_isUnequalGeometry) {
      items.add(
        _CalculationBasisItem(
          'Pipe OD',
          '${_controllers[_FieldKey.pipeOdMm]!.text} mm',
        ),
      );
    }

    if (!_isUnequalGeometry &&
        (_jointType == JointType.plateButt ||
            _jointType == JointType.pipeButt)) {
      items.add(
        _CalculationBasisItem(
          'Thickness',
          '${_controllers[_FieldKey.thicknessMm]!.text} mm',
        ),
      );
    }

    if (_isUnequalGeometry) {
      if (_jointType == JointType.plateButt ||
          _jointType == JointType.pipeButt) {
        items.addAll([
          _CalculationBasisItem(
            'Thickness A',
            '${_controllers[_FieldKey.thicknessAMm]!.text} mm',
          ),
          _CalculationBasisItem(
            'Thickness B',
            '${_controllers[_FieldKey.thicknessBMm]!.text} mm',
          ),
          _CalculationBasisItem(
            'Controlling Thickness',
            '${_formatNumber(_governingThicknessPreview ?? 0, 1)} mm',
          ),
        ]);
      }
      if (_jointType == JointType.pipeButt) {
        items.addAll([
          _CalculationBasisItem(
            'OD A',
            '${_controllers[_FieldKey.pipeOdAMm]!.text} mm',
          ),
          _CalculationBasisItem(
            'OD B',
            '${_controllers[_FieldKey.pipeOdBMm]!.text} mm',
          ),
          _CalculationBasisItem(
            'Reference OD',
            '${_formatNumber(_governingPipeOdPreview ?? 0, 1)} mm',
          ),
        ]);
      }
    }

    if (_grooveType == GrooveType.square ||
        _grooveType == GrooveType.singleV ||
        _grooveType == GrooveType.halfV ||
        _grooveType == GrooveType.doubleV ||
        _grooveType == GrooveType.compoundV) {
      items.add(
        _CalculationBasisItem(
          'Root Gap',
          '${_controllers[_FieldKey.rootGapMm]!.text} mm',
        ),
      );
    }

    if (_grooveType == GrooveType.singleV ||
        _grooveType == GrooveType.halfV ||
        _grooveType == GrooveType.doubleV) {
      items.addAll([
        _CalculationBasisItem(
          _grooveType == GrooveType.doubleV
              ? 'Root Face per Side'
              : 'Root Face',
          '${_controllers[_FieldKey.rootFaceMm]!.text} mm',
        ),
        _CalculationBasisItem(
          'Bevel Angle',
          '${_controllers[_FieldKey.bevelAngleDeg]!.text} deg',
        ),
      ]);
    }

    if (_grooveType == GrooveType.compoundV) {
      items.addAll([
        _CalculationBasisItem(
          'Root Face',
          '${_controllers[_FieldKey.rootFaceMm]!.text} mm',
        ),
        _CalculationBasisItem(
          'Primary Bevel Angle',
          '${_controllers[_FieldKey.bevelAngleDeg]!.text} deg',
        ),
        _CalculationBasisItem(
          'Secondary Bevel Angle',
          '${_controllers[_FieldKey.secondaryBevelAngleDeg]!.text} deg',
        ),
        _CalculationBasisItem(
          'Break Height',
          '${_controllers[_FieldKey.breakHeightMm]!.text} mm',
        ),
      ]);
    }

    if (_grooveType == GrooveType.fillet) {
      items.add(
        _CalculationBasisItem(
          'Fillet Leg Size',
          '${_controllers[_FieldKey.legSizeMm]!.text} mm',
        ),
      );
    }

    if (_weldingProcess == WeldingProcess.gtaw) {
      if (_depositionRateMode == DepositionRateMode.manual) {
        items.add(
          _CalculationBasisItem(
            'User-defined Rate',
            '${_controllers[_FieldKey.manualDepositionRateKgPerHour]!.text} kg/h',
          ),
        );
      } else {
        items.add(
          _CalculationBasisItem(
            'Wire Diameter',
            '${_controllers[_FieldKey.wireDiameterMm]!.text} mm',
          ),
        );
      }
    } else if (_weldingProcess == WeldingProcess.smaw) {
      if (_depositionRateMode == DepositionRateMode.manual) {
        items.add(
          _CalculationBasisItem(
            'User-defined Rate',
            '${_controllers[_FieldKey.manualDepositionRateKgPerHour]!.text} kg/h',
          ),
        );
      } else {
        items.add(
          _CalculationBasisItem(
            'Electrode Diameter',
            '${_controllers[_FieldKey.electrodeDiameterMm]!.text} mm',
          ),
        );
      }
    } else if (_weldingProcess == WeldingProcess.gmaw ||
        _weldingProcess == WeldingProcess.fcaw) {
      if (_depositionRateMode == DepositionRateMode.manual) {
        items.add(
          _CalculationBasisItem(
            'User-defined Rate',
            '${_controllers[_FieldKey.manualDepositionRateKgPerHour]!.text} kg/h',
          ),
        );
      } else {
        items.add(
          _CalculationBasisItem(
            'Wire Diameter',
            '${_controllers[_FieldKey.wireDiameterMm]!.text} mm',
          ),
        );
      }
    } else if (_weldingProcess == WeldingProcess.gtawSmaw) {
      items.addAll([
        _CalculationBasisItem(
          'GTAW Transition Depth',
          '${_controllers[_FieldKey.gtawTransitionMm]!.text} mm',
        ),
        if (_depositionRateMode == DepositionRateMode.manual)
          _CalculationBasisItem(
            'GTAW Deposition Rate',
            '${_controllers[_FieldKey.manualGtawRateKgPerHour]!.text} kg/h',
          )
        else
          _CalculationBasisItem(
            'GTAW Wire Diameter',
            '${_controllers[_FieldKey.gtawWireDiameterMm]!.text} mm',
          ),
        if (_depositionRateMode == DepositionRateMode.manual)
          _CalculationBasisItem(
            'SMAW Deposition Rate',
            '${_controllers[_FieldKey.manualSmawRateKgPerHour]!.text} kg/h',
          )
        else
          _CalculationBasisItem(
            'SMAW Electrode Diameter',
            '${_controllers[_FieldKey.smawElectrodeDiameterMm]!.text} mm',
          ),
      ]);
    }

    return items;
  }
}

class _TopNavigationBar extends StatelessWidget {
  const _TopNavigationBar({required this.activeModuleLabel});

  final String activeModuleLabel;

  @override
  Widget build(BuildContext context) {
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

          final identity = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F4C5C), Color(0xFF2E7B85)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.precision_manufacturing_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weld Consumable Calculator',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Professional estimating workspace for weld engineers and client-facing planning.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );

          final pills = Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              _StatusPill(
                label: activeModuleLabel.toUpperCase(),
                color: const Color(0xFFE8F2F5),
                textColor: const Color(0xFF0F4C5C),
              ),
              const _StatusPill(
                label: 'PDF READY',
                color: Color(0xFFF1F5F8),
                textColor: Color(0xFF395361),
              ),
              const _StatusPill(
                label: 'RESPONSIVE WEB',
                color: Color(0xFFF1F5F8),
                textColor: Color(0xFF395361),
              ),
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

class _ExperienceHero extends StatelessWidget {
  const _ExperienceHero({
    required this.activeModule,
    required this.jointTypeLabel,
    required this.grooveLabel,
    required this.processLabel,
    required this.drawingModeLabel,
    required this.consumableLabel,
    required this.savedPresetCount,
    required this.hasResults,
  });

  final _CalculatorModule activeModule;
  final String jointTypeLabel;
  final String grooveLabel;
  final String processLabel;
  final String drawingModeLabel;
  final String consumableLabel;
  final int savedPresetCount;
  final bool hasResults;

  @override
  Widget build(BuildContext context) {
    final branchMode = activeModule == _CalculatorModule.branchConnections;
    final title = branchMode
        ? 'Branch detailing that looks credible to engineers and clear to customers.'
        : 'A web-ready welding estimator that feels technical, polished, and easy to trust.';
    final body = branchMode
        ? 'Develop branch connection visuals in a separate module while preserving the main estimating workflow for daily use.'
        : 'Build estimates from real joint geometry, AWS consumable selection, and a report-grade result layer that can be shown to clients or production teams.';
    final heroSignals = branchMode
        ? const [
            ('Focus', 'Set-on / Set-in / Weldolet'),
            ('Preview', 'Section-first detail'),
            ('Roadmap', '2D now, web 3D later'),
          ]
        : [
            ('Live joint', jointTypeLabel),
            ('Groove', grooveLabel),
            ('Process', processLabel),
          ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF0E3D4A), Color(0xFF205E66), Color(0xFF6C9085)],
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
                  branchMode
                      ? 'ENGINEERING LAB / BRANCH DETAILING'
                      : 'ENGINEERING PRODUCT / ESTIMATING WORKSPACE',
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
                  title,
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
                  body,
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
                    _HeroSignalCard(label: signal.$1, value: signal.$2),
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
                const Text(
                  'Session Snapshot',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 14),
                if (branchMode) ...[
                  const _SnapshotRow(
                    label: 'Workspace',
                    value: 'Branch detailing',
                  ),
                  const _SnapshotRow(
                    label: 'Priority',
                    value: 'Weld-seat clarity',
                  ),
                  const _SnapshotRow(
                    label: 'Visual logic',
                    value: 'Technical section',
                  ),
                  const _SnapshotRow(
                    label: 'Delivery path',
                    value: 'Website-ready module',
                  ),
                ] else ...[
                  _SnapshotRow(label: 'Drawing mode', value: drawingModeLabel),
                  _SnapshotRow(label: 'Consumable', value: consumableLabel),
                  _SnapshotRow(
                    label: 'Saved presets',
                    value: savedPresetCount.toString(),
                  ),
                  _SnapshotRow(
                    label: 'Estimate state',
                    value: hasResults ? 'Calculated' : 'Awaiting run',
                  ),
                ],
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

class _CapabilityStrip extends StatelessWidget {
  const _CapabilityStrip({required this.isBranchMode});

  final bool isBranchMode;

  @override
  Widget build(BuildContext context) {
    final items = isBranchMode
        ? const [
            (
              Icons.architecture_outlined,
              'Section-first clarity',
              'Keep the drawing focused on weld seat, gap, and member geometry before adding heavier 3D workflows.',
            ),
            (
              Icons.zoom_in_map_outlined,
              'Detail enlargement',
              'Promote local weld detail so the user can immediately see where weld metal starts and where the gap remains.',
            ),
            (
              Icons.layers_outlined,
              'Future web 3D path',
              'Leave room for a later preview layer without letting 3D overwhelm the technical explanation.',
            ),
          ]
        : const [
            (
              Icons.calculate_outlined,
              'Daily estimating',
              'Compute weld area, length, volume, weld metal, filler demand, arc-on time, and deposition assumptions in one flow.',
            ),
            (
              Icons.draw_outlined,
              'Technical drawing',
              'Show live groove geometry with visual and engineering modes so the section sketch reinforces the estimate.',
            ),
            (
              Icons.picture_as_pdf_outlined,
              'Report workflow',
              'Turn the live estimate into a PDF-ready result summary with a clear engineering basis and reusable presets.',
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
                child: _CapabilityCard(
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

class _CapabilityCard extends StatelessWidget {
  const _CapabilityCard({
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
            child: Icon(icon, color: const Color(0xFF0F4C5C)),
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

class _HeroSignalCard extends StatelessWidget {
  const _HeroSignalCard({required this.label, required this.value});

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

class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({required this.label, required this.value});

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

class _QuickMetricTile extends StatelessWidget {
  const _QuickMetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFFF7FBFD),
        border: Border.all(color: const Color(0xFFDCE5EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0F4C5C)),
          const SizedBox(height: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF607482),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
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

class _WebsiteReadyFooter extends StatelessWidget {
  const _WebsiteReadyFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFF102B36),
        boxShadow: const [
          BoxShadow(
            color: Color(0x160F3040),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 980;
          final checklist = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _HeroSignalCard(label: 'UX', value: 'Website-grade shell'),
              _HeroSignalCard(label: 'Drawing', value: 'Live technical view'),
              _HeroSignalCard(label: 'Reports', value: 'PDF export path'),
              _HeroSignalCard(label: 'Data', value: 'Reusable presets'),
            ],
          );

          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Morning-ready product shell',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This interface now reads more like a technical product website instead of a raw prototype: stronger hierarchy, clearer control zones, and a better client-facing presentation.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFD3E4E8),
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 16), checklist],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: copy),
              const SizedBox(width: 18),
              Expanded(child: checklist),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyResultsState extends StatelessWidget {
  const _EmptyResultsState({required this.process});

  final WeldingProcess process;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Results',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          process == WeldingProcess.gtawSmaw
              ? 'Choose the joint, then enter GTAW transition depth together with GTAW wire and SMAW electrode diameters before calculating.'
              : 'Choose the joint, review the input parameters, then calculate. Process ${process.label} uses its active deposition efficiency and deposition rate basis.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF607482)),
        ),
      ],
    );
  }
}

class _InputPanelSection extends StatelessWidget {
  const _InputPanelSection({
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
                child: Icon(icon, size: 20, color: const Color(0xFF0F4C5C)),
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

class _PanelNote extends StatelessWidget {
  const _PanelNote({required this.icon, required this.text});

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

class _UserPresetSection extends StatelessWidget {
  const _UserPresetSection({
    required this.presets,
    required this.selectedPresetId,
    required this.selectedPresetName,
    required this.busy,
    required this.onChanged,
    required this.onSavePressed,
    required this.onUpdatePressed,
    required this.onDeletePressed,
  });

  final List<UserWeldPreset> presets;
  final String? selectedPresetId;
  final String? selectedPresetName;
  final bool busy;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onSavePressed;
  final VoidCallback? onUpdatePressed;
  final VoidCallback? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Saved Presets',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Built-in presets are locked. Save the current setup here to reuse, update, or delete it later.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF607482)),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFF4F8FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: const Color(0xFFDCE5EB)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x120F3040),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: DropdownButtonFormField<String?>(
            initialValue: selectedPresetId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Saved Preset',
              helperText: 'Choose one of your editable local presets.',
            ),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('No saved preset selected'),
              ),
              ...presets.map(
                (preset) => DropdownMenuItem<String?>(
                  value: preset.id,
                  child: Text(preset.name, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
            onChanged: busy ? null : onChanged,
          ),
        ),
        const SizedBox(height: 12),
        if (selectedPresetName != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDCE5EB)),
            ),
            child: Text(
              'Selected editable preset: $selectedPresetName',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.tonalIcon(
              onPressed: onSavePressed,
              icon: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Save Current'),
            ),
            OutlinedButton.icon(
              onPressed: onUpdatePressed,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Update Selected'),
            ),
            OutlinedButton.icon(
              onPressed: onDeletePressed,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Selected'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResultsSection extends StatelessWidget {
  const _ResultsSection({
    required this.result,
    required this.basis,
    required this.consumablePreset,
    required this.onPdfPressed,
    required this.pdfBusy,
  });

  final WeldCalculationResult result;
  final List<_CalculationBasisItem> basis;
  final ConsumablePreset consumablePreset;
  final VoidCallback? onPdfPressed;
  final bool pdfBusy;

  @override
  Widget build(BuildContext context) {
    final quantity = _basisNumber('Quantity') ?? 1;
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
    final metrics = [
      (
        'Weld Area',
        _number(result.areaMm2, 2),
        'mm²',
        Icons.square_foot_outlined,
      ),
      (
        'Weld Length',
        _number(result.lengthMm, 2),
        'mm',
        Icons.straighten_outlined,
      ),
      (
        'Weld Metal Volume',
        _number(result.volumeCm3, 3),
        'cm³',
        Icons.view_in_ar_outlined,
      ),
      (
        'Weld Metal Weight',
        _number(result.weldMetalKg, 3),
        'kg',
        Icons.scale_outlined,
      ),
      (
        'Filler Metal Consumption',
        _number(result.fillerKg, 3),
        'kg',
        Icons.inventory_2_outlined,
      ),
      (
        'Estimated Arc-On Time',
        _number(result.arcTimeHours, 3),
        'h',
        Icons.timer_outlined,
      ),
      (
        'Effective Deposition Efficiency',
        _percent(result.depositionEfficiency),
        '',
        Icons.speed_outlined,
      ),
      (
        'Effective Deposition Rate',
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
                'Results',
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
                  : const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: Text(pdfBusy ? 'Preparing PDF...' : 'Export PDF'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Report-grade summary for engineering review, material planning, and consumable comparison.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF607482)),
        ),
        const SizedBox(height: 16),
        _ResultsHighlightBanner(
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
        const SizedBox(height: 22),
        _PlanningInsightsPanel(
          items: [
            _InsightItem(
              label: 'Filler per Meter',
              value: _number(fillerPerMeter, 3),
              unit: 'kg/m',
            ),
            _InsightItem(
              label: 'Weld Metal per Meter',
              value: _number(weldMetalPerMeter, 3),
              unit: 'kg/m',
            ),
            _InsightItem(
              label: 'Arc-On per Meter',
              value: _number(arcMinutesPerMeter, 2),
              unit: 'min/m',
            ),
            _InsightItem(
              label: 'Filler per Joint',
              value: _number(fillerPerJoint, 3),
              unit: 'kg/joint',
            ),
            _InsightItem(
              label: 'Arc-On per Joint',
              value: _number(arcMinutesPerJoint, 2),
              unit: 'min/joint',
            ),
            _InsightItem(
              label: 'Efficiency Loss Basis',
              value: _number(efficiencyLossKg, 3),
              unit: 'kg',
            ),
            _InsightItem(
              label: 'Waste Allowance Basis',
              value: _number(wasteAllowanceKg, 3),
              unit: 'kg',
            ),
            _InsightItem(
              label: 'Consumption Multiplier',
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
            'Process Breakdown',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Distribution of deposited weld metal, filler demand, and arc-on time by process segment.',
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
                  child: _ProcessBreakdownCard(breakdown: breakdown),
                ),
            ],
          ),
        ],
        const SizedBox(height: 22),
        _ReportMethodPanel(
          notes: [
            'Arc-on time covers welding time only. Fit-up, handling, cleaning, repositioning, and inspection are not included.',
            'Filler metal consumption includes deposited weld metal, process deposition efficiency, and the entered waste allowance.',
            'Consumable classification provides material family and density reference. Final project or client requirements should always govern.',
            'This report is suitable for estimation and planning. It is not an approved WPS, PQR, welder qualification, or release document.',
          ],
        ),
        const SizedBox(height: 18),
        _CalculationBasisPanel(
          items: basis,
          consumablePreset: consumablePreset,
          subtitle:
              'Full engineering basis used in this estimate, including geometry, process setup, density, and deposition assumptions.',
        ),
      ],
    );
  }

  double? _basisNumber(String label) {
    for (final item in basis) {
      if (item.label != label) continue;
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

class _ProcessBreakdownCard extends StatelessWidget {
  const _ProcessBreakdownCard({required this.breakdown});

  final ProcessBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
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
              'Area Share ${_ResultsSection._number(breakdown.sharePercent * 100, 1)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF607482),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Weld Metal ${_ResultsSection._number(breakdown.weldMetalKg, 3)} kg',
            ),
            Text(
              'Filler Consumption ${_ResultsSection._number(breakdown.fillerKg, 3)} kg',
            ),
            Text(
              'Arc-On Time ${_ResultsSection._number(breakdown.arcTimeHours, 3)} h',
            ),
            Text(
              'Deposition Rate ${_ResultsSection._number(breakdown.depositionRateKgPerHour, 2)} kg/h',
            ),
            Text(
              'Deposition Efficiency ${_ResultsSection._percent(breakdown.depositionEfficiency)}',
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculationBasisPanel extends StatelessWidget {
  const _CalculationBasisPanel({
    required this.items,
    required this.consumablePreset,
    required this.subtitle,
  });

  final List<_CalculationBasisItem> items;
  final ConsumablePreset consumablePreset;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
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
            'Engineering Basis',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            consumablePreset.description,
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
                          text: '${item.label}: ',
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

class _ResultsHighlightBanner extends StatelessWidget {
  const _ResultsHighlightBanner({
    required this.result,
    required this.fillerPerMeter,
    required this.arcMinutesPerMeter,
  });

  final WeldCalculationResult result;
  final double fillerPerMeter;
  final double arcMinutesPerMeter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4C5C), Color(0xFF1A6670)],
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
            child: const Text(
              'ESTIMATE READY',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Estimated filler metal consumption is ${_ResultsSection._number(result.fillerKg, 3)} kg with ${_ResultsSection._number(result.arcTimeHours, 3)} h of arc-on time.',
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
              _HighlightChip(
                label: 'Effective Rate',
                value:
                    '${_ResultsSection._number(result.depositionRateKgPerHour, 2)} kg/h',
              ),
              _HighlightChip(
                label: 'Filler per Meter',
                value: '${_ResultsSection._number(fillerPerMeter, 3)} kg/m',
              ),
              _HighlightChip(
                label: 'Arc-On per Meter',
                value:
                    '${_ResultsSection._number(arcMinutesPerMeter, 2)} min/m',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HighlightChip extends StatelessWidget {
  const _HighlightChip({required this.label, required this.value});

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

class _PlanningInsightsPanel extends StatelessWidget {
  const _PlanningInsightsPanel({required this.items});

  final List<_InsightItem> items;

  @override
  Widget build(BuildContext context) {
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
            'Planning Indicators',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Normalized indicators that help compare joint options, labor load, and consumable planning basis.',
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

class _ReportMethodPanel extends StatelessWidget {
  const _ReportMethodPanel({required this.notes});

  final List<String> notes;

  @override
  Widget build(BuildContext context) {
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
            'Engineering Notes',
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
                      color: const Color(0xFF0F4C5C),
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

class _InsightItem {
  const _InsightItem({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;
}

enum _CalculatorModule { weldEstimator, branchConnections }

extension on _CalculatorModule {
  String get label => switch (this) {
    _CalculatorModule.weldEstimator => 'Butt & Fillet Estimator',
    _CalculatorModule.branchConnections => 'Branch Connections',
  };
}

enum _FieldKey {
  quantity,
  lengthMm,
  pipeOdMm,
  pipeOdAMm,
  pipeOdBMm,
  thicknessMm,
  thicknessAMm,
  thicknessBMm,
  rootGapMm,
  rootFaceMm,
  bevelAngleDeg,
  secondaryBevelAngleDeg,
  breakHeightMm,
  legSizeMm,
  gtawTransitionMm,
  wireDiameterMm,
  electrodeDiameterMm,
  gtawWireDiameterMm,
  smawElectrodeDiameterMm,
  manualDepositionRateKgPerHour,
  manualGtawRateKgPerHour,
  manualSmawRateKgPerHour,
  density,
  wasteFactor,
}

class _InputFieldSpec {
  const _InputFieldSpec({
    required this.key,
    required this.label,
    required this.helperText,
  }) : diameterOptions = null;

  const _InputFieldSpec.diameter({
    required this.key,
    required this.label,
    required this.helperText,
    required this.diameterOptions,
  });

  final _FieldKey key;
  final String label;
  final String helperText;
  final List<_DiameterPresetOption>? diameterOptions;
}

class _DiameterPresetOption {
  const _DiameterPresetOption({required this.label, required this.value});

  final String label;
  final double value;
}

class _CalculationBasisItem {
  const _CalculationBasisItem(this.label, this.value);

  final String label;
  final String value;
}

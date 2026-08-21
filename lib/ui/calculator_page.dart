import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/weld_calculator.dart';
import '../core/welding_defaults.dart';
import '../models/weld_models.dart';
import '../services/user_preset_store.dart';
import '../services/weld_pdf_report_service.dart';
import 'widgets/weld_drawing_preview.dart';
import 'calculator_page/calculator_page_models.dart';
import 'calculator_page/calculator_page_widgets.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final WeldCalculator _calculator = const WeldCalculator();
  final WeldPdfReportService _pdfReportService = const WeldPdfReportService();
  final UserPresetStore _userPresetStore = const UserPresetStore();
  final ScrollController _pageScrollController = ScrollController();
  final ScrollController _inputColumnScrollController = ScrollController();
  static const _customDiameterValue = 'custom';

  final Map<FieldKey, TextEditingController> _controllers = {
    for (final key in FieldKey.values) key: TextEditingController(),
  };
  final Map<FieldKey, FocusNode> _fieldFocusNodes = {
    for (final key in FieldKey.values) key: FocusNode(),
  };
  final Map<FieldKey, String> _diameterPresetModes = {};

  JointType _jointType = JointType.plateButt;
  GrooveType _grooveType = GrooveType.singleV;
  WeldingProcess _weldingProcess = WeldingProcess.gtaw;
  DepositionRateMode _depositionRateMode = DepositionRateMode.preset;
  DrawingMode _drawingMode = DrawingMode.visual;
  JointGeometryMode _jointGeometryMode = JointGeometryMode.equal;
  JointAlignment _jointAlignment = JointAlignment.centerline;
  ConsumablePreset _consumablePreset = ConsumablePreset.er70s2;
  InputPreset _inputPreset = InputPreset.custom;
  List<UserWeldPreset> _userPresets = const [];
  String? _selectedUserPresetId;
  WeldCalculationResult? _result;
  bool _showResultsScreen = false;
  bool _showIntro = true;
  // TODO: replace with a real StoreKit/RevenueCat entitlement check once
  // the Apple Developer account and App Store Connect subscription product
  // exist. This flag is a local-only stand-in so the paywall UX can be
  // built and demoed before that infrastructure is in place.
  bool _isPremium = false;
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
    _pageScrollController.dispose();
    _inputColumnScrollController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _fieldFocusNodes.values) {
      focusNode.dispose();
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
                      colors: [Color(0x22FF6A35), Color(0x00FF6A35)],
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
                      colors: [Color(0x221B2326), Color(0x001B2326)],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (_showIntro) {
                    return _buildIntroScreen(context);
                  }
                  if (_showResultsScreen) {
                    return _buildResultsScreen(context);
                  }
                  final wide = constraints.maxWidth >= 1120;
                  if (!wide) {
                    return _buildNarrowPage(context);
                  }
                  return _buildWidePage(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Landing screen: the product pitch, capability highlights, and branding
  /// live here instead of above the input form, so the calculator itself
  /// opens straight into Joint Type once the user taps through.
  Widget _buildIntroScreen(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopNavigationBar(),
              const SizedBox(height: 18),
              ExperienceHero(
                jointTypeLabel: _jointType.label,
                grooveLabel: _grooveType.label,
                processLabel: _weldingProcess.label,
                drawingModeLabel: _drawingMode.label,
                consumableLabel: _consumablePreset.label,
                savedPresetCount: _userPresets.length,
                hasResults: _result != null,
              ),
              const SizedBox(height: 18),
              const CapabilityStrip(),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => setState(() => _showIntro = false),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Get Started'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const WebsiteReadyFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidePage(BuildContext context) {
    return SingleChildScrollView(
      controller: _pageScrollController,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: _buildEstimatorWorkspace(context),
        ),
      ),
    );
  }

  /// Mobile layout: the technical drawing stays pinned at the top of the
  /// screen (outside the scroll view) so the weld-groove sketch is always
  /// visible while every other card scrolls underneath it.
  Widget _buildNarrowPage(BuildContext context) {
    final visibleFields = _visibleFieldSpecs;
    final availableConsumables = WeldingDefaults.consumablesFor(
      _weldingProcess,
    );
    final selectedUserPreset = _selectedUserPreset;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: SizedBox(
            height: _narrowDrawingHeight(context),
            child: _buildTechnicalDrawingCard(context, compact: true),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _pageScrollController,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEstimatorControlCard(context),
                const SizedBox(height: 18),
                _buildJointConfigurationCard(context),
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
        ),
      ],
    );
  }

  double _narrowDrawingHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final safeHeight = mediaQuery.size.height - mediaQuery.padding.vertical;
    return (safeHeight * 0.34).clamp(230.0, 340.0);
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
            ],
          );
        }

        final workspaceHeight = _wideEntryWorkspaceHeight(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: workspaceHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildJointConfigurationCard(context),
                        const SizedBox(height: 18),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: _buildTechnicalDrawingCard(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    flex: 6,
                    child: Scrollbar(
                      controller: _inputColumnScrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _inputColumnScrollController,
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  double _wideEntryWorkspaceHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final safeHeight = mediaQuery.size.height - mediaQuery.padding.vertical;
    final targetHeight = safeHeight - 84;
    return targetHeight.clamp(680.0, 860.0);
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
                QuickMetricTile(
                  label: 'Joint',
                  value: _jointType.label,
                  icon: Icons.alt_route_outlined,
                ),
                QuickMetricTile(
                  label: 'Groove',
                  value: _grooveType.label,
                  icon: Icons.change_history_outlined,
                ),
                QuickMetricTile(
                  label: 'Process',
                  value: _weldingProcess.label,
                  icon: Icons.bolt_outlined,
                ),
                QuickMetricTile(
                  label: 'Drawing',
                  value: _drawingMode.label,
                  icon: Icons.draw_outlined,
                ),
                QuickMetricTile(
                  label: 'Efficiency',
                  value: _formatPercent(processEfficiency),
                  icon: Icons.speed_outlined,
                ),
                QuickMetricTile(
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
                  colors: [Color(0xFF1B2326), Color(0xFF0B0F10)],
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

  Widget _buildTechnicalDrawingCard(
    BuildContext context, {
    bool compact = false,
  }) {
    Widget buildDrawingPreviewPanel() {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFFF8FBFD), Color(0xFFEAF1F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(compact ? 8 : 12),
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 760,
              child: WeldDrawingPreview(
                grooveType: _grooveType,
                jointType: _jointType,
                drawingMode: _drawingMode,
                data: _drawingData,
                onFieldTap: _handleDrawingFieldTap,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 22),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hasBoundedHeight = constraints.maxHeight.isFinite;

            return Column(
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
                            style:
                                (compact
                                        ? Theme.of(context).textTheme.titleMedium
                                        : Theme.of(context).textTheme.titleLarge)
                                    ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          if (!compact) ...[
                            const SizedBox(height: 8),
                            Text(
                              _drawingMode == DrawingMode.technical
                                  ? 'Technical mode applies engineering-style line weights, hatch, and dimension annotations.'
                                  : 'Visual mode keeps the sketch softer while still following the live joint geometry.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: const Color(0xFF607482)),
                            ),
                          ],
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
                SizedBox(height: compact ? 10 : 16),
                if (hasBoundedHeight)
                  Expanded(child: buildDrawingPreviewPanel())
                else
                  buildDrawingPreviewPanel(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputParametersCard(
    BuildContext context,
    List<InputFieldSpec> visibleFields,
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
            InputPanelSection(
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
                  PanelNote(
                    icon: Icons.auto_fix_high_outlined,
                    text: _inputPreset.description,
                  ),
                  const SizedBox(height: 14),
                  UserPresetSection(
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
            InputPanelSection(
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
                  PanelNote(
                    icon: Icons.verified_outlined,
                    text:
                        'Selected classification: ${_consumablePreset.awsSpecification} | ${_consumablePreset.label} | ${_consumablePreset.family.label} | Density ${_formatNumber(_consumablePreset.densityGPerCm3, 2)} g/cm3',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            InputPanelSection(
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
                  PanelNote(
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
            InputPanelSection(
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
            ? EmptyResultsState(process: _weldingProcess)
            : ResultsSection(
                result: _result!,
                basis: _buildCalculationBasis(),
                consumablePreset: _consumablePreset,
                onPdfPressed: _isExportingPdf
                    ? null
                    : (_isPremium ? _exportPdf : _showPaywall),
                pdfBusy: _isExportingPdf,
                pdfLocked: !_isPremium,
              ),
      ),
    );
  }

  /// A dedicated results screen the Calculate button transitions to, kept
  /// separate from the input flow so the numbers read as a clear final
  /// step rather than another card in the same long scroll.
  Widget _buildResultsScreen(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () =>
                        setState(() => _showResultsScreen = false),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Edit inputs',
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Results',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildResultsCard(),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _showResultsScreen = false),
                  icon: const Icon(Icons.tune_outlined),
                  label: const Text('Edit Inputs'),
                ),
              ),
            ],
          ),
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
      ? _parsePreviewValue(FieldKey.thicknessAMm)
      : _parsePreviewValue(FieldKey.thicknessMm);

  double? get _thicknessBPreview => _isUnequalGeometry
      ? _parsePreviewValue(FieldKey.thicknessBMm)
      : _parsePreviewValue(FieldKey.thicknessMm);

  double? get _governingThicknessPreview {
    final a = _thicknessAPreview;
    final b = _thicknessBPreview;
    if (a == null && b == null) {
      return _parsePreviewValue(FieldKey.thicknessMm);
    }
    if (a == null) return b;
    if (b == null) return a;
    return a >= b ? a : b;
  }

  double? get _pipeOdAPreview => _isUnequalGeometry
      ? _parsePreviewValue(FieldKey.pipeOdAMm)
      : _parsePreviewValue(FieldKey.pipeOdMm);

  double? get _pipeOdBPreview => _isUnequalGeometry
      ? _parsePreviewValue(FieldKey.pipeOdBMm)
      : _parsePreviewValue(FieldKey.pipeOdMm);

  double? get _governingPipeOdPreview {
    final a = _pipeOdAPreview;
    final b = _pipeOdBPreview;
    if (a == null && b == null) return _parsePreviewValue(FieldKey.pipeOdMm);
    if (a == null) return b;
    if (b == null) return a;
    return a >= b ? a : b;
  }

  List<InputFieldSpec> get _visibleFieldSpecs {
    final specs = <InputFieldSpec>[
      const InputFieldSpec(
        key: FieldKey.quantity,
        label: 'Quantity',
        helperText: 'Number of identical welds.',
      ),
    ];

    if (_jointType == JointType.plateButt || _jointType == JointType.fillet) {
      specs.add(
        const InputFieldSpec(
          key: FieldKey.lengthMm,
          label: 'Weld Length per Piece (mm)',
          helperText: 'Straight weld run length.',
        ),
      );
    }

    if (_jointType == JointType.pipeButt) {
      if (_isUnequalGeometry) {
        specs.addAll(const [
          InputFieldSpec(
            key: FieldKey.pipeOdAMm,
            label: 'Pipe OD A (mm)',
            helperText: 'Outside diameter of member A.',
          ),
          InputFieldSpec(
            key: FieldKey.pipeOdBMm,
            label: 'Pipe OD B (mm)',
            helperText: 'Outside diameter of member B.',
          ),
        ]);
      } else {
        specs.add(
          const InputFieldSpec(
            key: FieldKey.pipeOdMm,
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
          InputFieldSpec(
            key: FieldKey.thicknessAMm,
            label: 'Thickness A (mm)',
            helperText: 'Wall or plate thickness of member A.',
          ),
          InputFieldSpec(
            key: FieldKey.thicknessBMm,
            label: 'Thickness B (mm)',
            helperText: 'Wall or plate thickness of member B.',
          ),
          InputFieldSpec(
            key: FieldKey.rootGapMm,
            label: 'Root Gap (mm)',
            helperText: 'Root opening.',
          ),
        ]);
      } else {
        specs.addAll(const [
          InputFieldSpec(
            key: FieldKey.thicknessMm,
            label: 'Thickness (mm)',
            helperText: 'Base material thickness.',
          ),
          InputFieldSpec(
            key: FieldKey.rootGapMm,
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
        InputFieldSpec(
          key: FieldKey.rootFaceMm,
          label: _grooveType == GrooveType.doubleV
              ? 'Root Face per Side (mm)'
              : 'Root Face (mm)',
          helperText: _grooveType == GrooveType.doubleV
              ? 'Root face on each side of the joint centerline.'
              : 'Root face before the bevel starts.',
        ),
      );
      specs.add(
        const InputFieldSpec(
          key: FieldKey.bevelAngleDeg,
          label: 'Bevel Angle (deg)',
          helperText: 'Included as bevel angle in degrees.',
        ),
      );
    }

    if (_grooveType == GrooveType.compoundV) {
      specs.addAll(const [
        InputFieldSpec(
          key: FieldKey.rootFaceMm,
          label: 'Root Face (mm)',
          helperText: 'Root face before the bevel starts.',
        ),
        InputFieldSpec(
          key: FieldKey.bevelAngleDeg,
          label: 'Primary Angle alpha (deg)',
          helperText: 'Lower bevel angle near the root.',
        ),
        InputFieldSpec(
          key: FieldKey.secondaryBevelAngleDeg,
          label: 'Secondary Angle beta (deg)',
          helperText: 'Upper bevel angle above the break point.',
        ),
        InputFieldSpec(
          key: FieldKey.breakHeightMm,
          label: 'Break Height h (mm)',
          helperText: 'Distance from root face to bevel break point.',
        ),
      ]);
    }

    if (_grooveType == GrooveType.fillet) {
      specs.add(
        const InputFieldSpec(
          key: FieldKey.legSizeMm,
          label: 'Leg Size (mm)',
          helperText: 'Equal leg size of the fillet weld.',
        ),
      );
    }

    if (_weldingProcess == WeldingProcess.gtaw) {
      specs.add(
        const InputFieldSpec.diameter(
          key: FieldKey.wireDiameterMm,
          label: 'GTAW Wire Diameter (mm)',
          helperText: 'Common filler diameters: 1.6, 2.0, 2.4, 3.2 mm.',
          diameterOptions: [
            DiameterPresetOption(label: '1.6 mm', value: 1.6),
            DiameterPresetOption(label: '2.0 mm', value: 2.0),
            DiameterPresetOption(label: '2.4 mm', value: 2.4),
            DiameterPresetOption(label: '3.2 mm', value: 3.2),
          ],
        ),
      );
    }

    if (_weldingProcess == WeldingProcess.smaw) {
      specs.add(
        const InputFieldSpec.diameter(
          key: FieldKey.electrodeDiameterMm,
          label: 'SMAW Electrode Diameter (mm)',
          helperText: 'Common electrode diameters: 2.5, 3.2, 4.0, 5.0 mm.',
          diameterOptions: [
            DiameterPresetOption(label: '2.5 mm', value: 2.5),
            DiameterPresetOption(label: '3.2 mm', value: 3.2),
            DiameterPresetOption(label: '4.0 mm', value: 4.0),
            DiameterPresetOption(label: '5.0 mm', value: 5.0),
          ],
        ),
      );
    }

    if (_weldingProcess == WeldingProcess.gmaw ||
        _weldingProcess == WeldingProcess.fcaw) {
      specs.add(
        InputFieldSpec.diameter(
          key: FieldKey.wireDiameterMm,
          label: _weldingProcess == WeldingProcess.gmaw
              ? 'GMAW Wire Diameter (mm)'
              : 'FCAW Wire Diameter (mm)',
          helperText: _weldingProcess == WeldingProcess.gmaw
              ? 'Common wire diameters: 0.8, 1.0, 1.2, 1.6 mm.'
              : 'Common wire diameters: 1.2, 1.6, 2.0 mm.',
          diameterOptions: _weldingProcess == WeldingProcess.gmaw
              ? const [
                  DiameterPresetOption(label: '0.8 mm', value: 0.8),
                  DiameterPresetOption(label: '1.0 mm', value: 1.0),
                  DiameterPresetOption(label: '1.2 mm', value: 1.2),
                  DiameterPresetOption(label: '1.6 mm', value: 1.6),
                ]
              : const [
                  DiameterPresetOption(label: '1.2 mm', value: 1.2),
                  DiameterPresetOption(label: '1.6 mm', value: 1.6),
                  DiameterPresetOption(label: '2.0 mm', value: 2.0),
                ],
        ),
      );
    }

    if (_weldingProcess == WeldingProcess.gtawSmaw) {
      specs.addAll(const [
        InputFieldSpec(
          key: FieldKey.gtawTransitionMm,
          label: 'GTAW Transition Depth (mm)',
          helperText:
              'Depth deposited by GTAW from the root side before switching to SMAW.',
        ),
        InputFieldSpec.diameter(
          key: FieldKey.gtawWireDiameterMm,
          label: 'GTAW Wire Diameter (mm)',
          helperText: 'Common filler diameters: 1.6, 2.0, 2.4, 3.2 mm.',
          diameterOptions: [
            DiameterPresetOption(label: '1.6 mm', value: 1.6),
            DiameterPresetOption(label: '2.0 mm', value: 2.0),
            DiameterPresetOption(label: '2.4 mm', value: 2.4),
            DiameterPresetOption(label: '3.2 mm', value: 3.2),
          ],
        ),
        InputFieldSpec.diameter(
          key: FieldKey.smawElectrodeDiameterMm,
          label: 'SMAW Electrode Diameter (mm)',
          helperText: 'Common electrode diameters: 2.5, 3.2, 4.0, 5.0 mm.',
          diameterOptions: [
            DiameterPresetOption(label: '2.5 mm', value: 2.5),
            DiameterPresetOption(label: '3.2 mm', value: 3.2),
            DiameterPresetOption(label: '4.0 mm', value: 4.0),
            DiameterPresetOption(label: '5.0 mm', value: 5.0),
          ],
        ),
      ]);
    }

    if (_depositionRateMode == DepositionRateMode.manual) {
      if (_weldingProcess == WeldingProcess.gtawSmaw) {
        specs.addAll(const [
          InputFieldSpec(
            key: FieldKey.manualGtawRateKgPerHour,
            label: 'GTAW Deposition Rate (kg/h)',
            helperText:
                'User-defined deposition rate for the GTAW root portion.',
          ),
          InputFieldSpec(
            key: FieldKey.manualSmawRateKgPerHour,
            label: 'SMAW Deposition Rate (kg/h)',
            helperText:
                'User-defined deposition rate for the SMAW fill and cap portion.',
          ),
        ]);
      } else {
        specs.add(
          const InputFieldSpec(
            key: FieldKey.manualDepositionRateKgPerHour,
            label: 'Deposition Rate (kg/h)',
            helperText:
                'User-defined deposition rate based on shop data, planning value, or WPS assumption.',
          ),
        );
      }
    }

    specs.addAll(const [
      InputFieldSpec(
        key: FieldKey.density,
        label: 'Density (g/cm3)',
        helperText:
            'Bulk weld metal density. Default follows the selected classification.',
      ),
      InputFieldSpec(
        key: FieldKey.wasteFactor,
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
        _parsePreviewValue(FieldKey.wireDiameterMm),
      ),
      WeldingProcess.smaw => WeldingDefaults.smawRateForElectrode(
        _parsePreviewValue(FieldKey.electrodeDiameterMm),
      ),
      WeldingProcess.gtawSmaw => _combinedPreviewRate,
      WeldingProcess.gmaw => WeldingDefaults.gmawRateForWire(
        _parsePreviewValue(FieldKey.wireDiameterMm),
      ),
      WeldingProcess.fcaw => WeldingDefaults.fcawRateForWire(
        _parsePreviewValue(FieldKey.wireDiameterMm),
      ),
    };
  }

  double get _manualPreviewDepositionRate {
    if (_weldingProcess != WeldingProcess.gtawSmaw) {
      return _parsePreviewValue(FieldKey.manualDepositionRateKgPerHour) ??
          WeldingDefaults.depositionRateFor(_weldingProcess);
    }

    final gtawRate =
        _parsePreviewValue(FieldKey.manualGtawRateKgPerHour) ??
        WeldingDefaults.depositionRateFor(WeldingProcess.gtaw);
    final smawRate =
        _parsePreviewValue(FieldKey.manualSmawRateKgPerHour) ??
        WeldingDefaults.depositionRateFor(WeldingProcess.smaw);
    final ratio = _combinedProcessPreviewRatio;
    return (gtawRate * ratio) + (smawRate * (1 - ratio));
  }

  double get _previewEfficiency {
    if (_weldingProcess != WeldingProcess.gtawSmaw) {
      return WeldingDefaults.efficiencyFor(_weldingProcess);
    }

    final gtawMm = _parsePreviewValue(FieldKey.gtawTransitionMm) ?? 3;
    final thickness = _parsePreviewValue(FieldKey.thicknessMm);
    final leg = _parsePreviewValue(FieldKey.legSizeMm);
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
      _parsePreviewValue(FieldKey.gtawWireDiameterMm),
    );
    final smawRate = WeldingDefaults.smawRateForElectrode(
      _parsePreviewValue(FieldKey.smawElectrodeDiameterMm),
    );
    final ratio = _combinedProcessPreviewRatio;
    return (gtawRate * ratio) + (smawRate * (1 - ratio));
  }

  double get _combinedProcessPreviewRatio {
    final gtawMm = _parsePreviewValue(FieldKey.gtawTransitionMm) ?? 3;
    final thickness = _parsePreviewValue(FieldKey.thicknessMm);
    final leg = _parsePreviewValue(FieldKey.legSizeMm);
    final totalHeight = thickness ?? leg ?? gtawMm;
    return totalHeight <= 0 ? 0.5 : (gtawMm / totalHeight).clamp(0.0, 1.0);
  }

  String _processRateSummary(double efficiency, double depositionRate) {
    final sourceText = _depositionRateMode == DepositionRateMode.manual
        ? 'Manual'
        : 'Estimated';

    if (_weldingProcess == WeldingProcess.gtawSmaw) {
      final gtawUpTo = _formatNumber(
        _parsePreviewValue(FieldKey.gtawTransitionMm) ?? 3,
        1,
      );
      final gtawSetting = _depositionRateMode == DepositionRateMode.manual
          ? '${_formatNumber(_parsePreviewValue(FieldKey.manualGtawRateKgPerHour) ?? WeldingDefaults.depositionRateFor(WeldingProcess.gtaw), 2)} kg/h'
          : '${_formatNumber(_parsePreviewValue(FieldKey.gtawWireDiameterMm) ?? 2.4, 1)} mm wire';
      final smawSetting = _depositionRateMode == DepositionRateMode.manual
          ? '${_formatNumber(_parsePreviewValue(FieldKey.manualSmawRateKgPerHour) ?? WeldingDefaults.depositionRateFor(WeldingProcess.smaw), 2)} kg/h'
          : '${_formatNumber(_parsePreviewValue(FieldKey.smawElectrodeDiameterMm) ?? 3.2, 1)} mm electrode';
      return 'Rate basis $sourceText | GTAW transition depth $gtawUpTo mm, then SMAW | Deposition efficiency ${_formatPercent(efficiency)} | Equivalent deposition rate ${_formatNumber(depositionRate, 2)} kg/h | GTAW $gtawSetting | SMAW $smawSetting';
    }

    final detailText = _depositionRateMode == DepositionRateMode.manual
        ? ' | User-defined ${_formatNumber(_parsePreviewValue(FieldKey.manualDepositionRateKgPerHour) ?? WeldingDefaults.depositionRateFor(_weldingProcess), 2)} kg/h'
        : switch (_weldingProcess) {
            WeldingProcess.gtaw =>
              ' | Wire ${_formatNumber(_parsePreviewValue(FieldKey.wireDiameterMm) ?? 2.4, 1)} mm',
            WeldingProcess.smaw =>
              ' | Electrode ${_formatNumber(_parsePreviewValue(FieldKey.electrodeDiameterMm) ?? 3.2, 1)} mm',
            WeldingProcess.gmaw =>
              ' | Wire ${_formatNumber(_parsePreviewValue(FieldKey.wireDiameterMm) ?? 1.2, 1)} mm',
            WeldingProcess.fcaw =>
              ' | Wire ${_formatNumber(_parsePreviewValue(FieldKey.wireDiameterMm) ?? 1.6, 1)} mm',
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

    _setControllerValue(FieldKey.quantity, data.quantity);
    _setControllerValue(FieldKey.lengthMm, data.lengthPerPieceMm);
    _setControllerValue(FieldKey.pipeOdMm, data.pipeOdMm);
    _setControllerValue(FieldKey.pipeOdAMm, data.pipeOdAMm);
    _setControllerValue(FieldKey.pipeOdBMm, data.pipeOdBMm);
    _setControllerValue(FieldKey.thicknessMm, data.thicknessMm);
    _setControllerValue(FieldKey.thicknessAMm, data.thicknessAMm);
    _setControllerValue(FieldKey.thicknessBMm, data.thicknessBMm);
    _setControllerValue(FieldKey.rootGapMm, data.rootGapMm);
    _setControllerValue(FieldKey.rootFaceMm, data.rootFaceMm);
    _setControllerValue(FieldKey.bevelAngleDeg, data.bevelAngleDeg);
    _setControllerValue(
      FieldKey.secondaryBevelAngleDeg,
      data.secondaryBevelAngleDeg,
    );
    _setControllerValue(FieldKey.breakHeightMm, data.breakHeightMm);
    _setControllerValue(FieldKey.legSizeMm, data.legSizeMm);
    _setControllerValue(FieldKey.gtawTransitionMm, data.gtawTransitionMm);
    _setControllerValue(
      FieldKey.manualDepositionRateKgPerHour,
      data.manualDepositionRateKgPerHour,
    );
    _setControllerValue(
      FieldKey.manualGtawRateKgPerHour,
      data.manualGtawRateKgPerHour,
    );
    _setControllerValue(
      FieldKey.manualSmawRateKgPerHour,
      data.manualSmawRateKgPerHour,
    );
    _setControllerValue(FieldKey.wasteFactor, data.wasteFactorPercent);

    _applyDiameterOrValue(
      FieldKey.wireDiameterMm,
      data.wireDiameterMm,
      usePreset: usePresetDiameters,
    );
    _applyDiameterOrValue(
      FieldKey.electrodeDiameterMm,
      data.electrodeDiameterMm,
      usePreset: usePresetDiameters,
    );
    _applyDiameterOrValue(
      FieldKey.gtawWireDiameterMm,
      data.gtawWireDiameterMm,
      usePreset: usePresetDiameters,
    );
    _applyDiameterOrValue(
      FieldKey.smawElectrodeDiameterMm,
      data.smawElectrodeDiameterMm,
      usePreset: usePresetDiameters,
    );

    if (data.densityGPerCm3 != null) {
      _setControllerValue(FieldKey.density, data.densityGPerCm3);
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
    quantity: _parsePresetValue(FieldKey.quantity, 'Quantity') ?? 1,
    wasteFactorPercent:
        _parsePresetValue(FieldKey.wasteFactor, 'Waste allowance') ??
        WeldingDefaults.wasteFactorPercent,
    densityGPerCm3: _parsePresetValue(FieldKey.density, 'Density'),
    lengthPerPieceMm: _parsePresetValue(FieldKey.lengthMm, 'Weld length'),
    pipeOdMm: _parsePresetValue(FieldKey.pipeOdMm, 'Pipe OD'),
    pipeOdAMm: _parsePresetValue(FieldKey.pipeOdAMm, 'Pipe OD A'),
    pipeOdBMm: _parsePresetValue(FieldKey.pipeOdBMm, 'Pipe OD B'),
    thicknessMm: _parsePresetValue(FieldKey.thicknessMm, 'Thickness'),
    thicknessAMm: _parsePresetValue(FieldKey.thicknessAMm, 'Thickness A'),
    thicknessBMm: _parsePresetValue(FieldKey.thicknessBMm, 'Thickness B'),
    rootGapMm: _parsePresetValue(FieldKey.rootGapMm, 'Root gap'),
    rootFaceMm: _parsePresetValue(FieldKey.rootFaceMm, 'Root face'),
    bevelAngleDeg: _parsePresetValue(FieldKey.bevelAngleDeg, 'Bevel angle'),
    secondaryBevelAngleDeg: _parsePresetValue(
      FieldKey.secondaryBevelAngleDeg,
      'Secondary bevel angle',
    ),
    breakHeightMm: _parsePresetValue(FieldKey.breakHeightMm, 'Break height'),
    legSizeMm: _parsePresetValue(FieldKey.legSizeMm, 'Leg size'),
    gtawTransitionMm: _parsePresetValue(
      FieldKey.gtawTransitionMm,
      'GTAW transition depth',
    ),
    wireDiameterMm: _parsePresetValue(FieldKey.wireDiameterMm, 'Wire diameter'),
    electrodeDiameterMm: _parsePresetValue(
      FieldKey.electrodeDiameterMm,
      'Electrode diameter',
    ),
    gtawWireDiameterMm: _parsePresetValue(
      FieldKey.gtawWireDiameterMm,
      'GTAW wire diameter',
    ),
    smawElectrodeDiameterMm: _parsePresetValue(
      FieldKey.smawElectrodeDiameterMm,
      'SMAW electrode diameter',
    ),
    manualDepositionRateKgPerHour: _parsePresetValue(
      FieldKey.manualDepositionRateKgPerHour,
      'Deposition rate',
    ),
    manualGtawRateKgPerHour: _parsePresetValue(
      FieldKey.manualGtawRateKgPerHour,
      'GTAW deposition rate',
    ),
    manualSmawRateKgPerHour: _parsePresetValue(
      FieldKey.manualSmawRateKgPerHour,
      'SMAW deposition rate',
    ),
  );

  double? _parsePresetValue(FieldKey key, String label) {
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
    _controllers[FieldKey.density]!.text = preset.densityGPerCm3
        .toStringAsFixed(2);
  }

  void _applyProcessFieldDefaults() {
    _controllers[FieldKey.manualDepositionRateKgPerHour]!.text =
        WeldingDefaults.depositionRateFor(_weldingProcess).toStringAsFixed(1);
    _controllers[FieldKey.manualGtawRateKgPerHour]!.text =
        WeldingDefaults.depositionRateFor(
          WeldingProcess.gtaw,
        ).toStringAsFixed(1);
    _controllers[FieldKey.manualSmawRateKgPerHour]!.text =
        WeldingDefaults.depositionRateFor(
          WeldingProcess.smaw,
        ).toStringAsFixed(1);

    if (_weldingProcess == WeldingProcess.gtaw) {
      _setDiameterPreset(FieldKey.wireDiameterMm, 2.4);
    } else if (_weldingProcess == WeldingProcess.smaw) {
      _setDiameterPreset(FieldKey.electrodeDiameterMm, 3.2);
    } else if (_weldingProcess == WeldingProcess.gtawSmaw) {
      _controllers[FieldKey.gtawTransitionMm]!.text = '3';
      _setDiameterPreset(FieldKey.gtawWireDiameterMm, 2.4);
      _setDiameterPreset(FieldKey.smawElectrodeDiameterMm, 3.2);
    } else if (_weldingProcess == WeldingProcess.gmaw) {
      _setDiameterPreset(FieldKey.wireDiameterMm, 1.2);
    } else if (_weldingProcess == WeldingProcess.fcaw) {
      _setDiameterPreset(FieldKey.wireDiameterMm, 1.6);
    }
  }

  WeldDrawingData get _drawingData => WeldDrawingData(
    weldingProcess: _weldingProcess,
    geometryMode: _jointGeometryMode,
    alignment: _jointAlignment,
    thicknessMm: _governingThicknessPreview,
    thicknessAMm: _thicknessAPreview,
    thicknessBMm: _thicknessBPreview,
    rootGapMm: _parsePreviewValue(FieldKey.rootGapMm),
    rootFaceMm: _parsePreviewValue(FieldKey.rootFaceMm),
    bevelAngleDeg: _parsePreviewValue(FieldKey.bevelAngleDeg),
    secondaryBevelAngleDeg: _parsePreviewValue(FieldKey.secondaryBevelAngleDeg),
    breakHeightMm: _parsePreviewValue(FieldKey.breakHeightMm),
    legSizeMm: _parsePreviewValue(FieldKey.legSizeMm),
    pipeOdMm: _governingPipeOdPreview,
    pipeOdAMm: _pipeOdAPreview,
    pipeOdBMm: _pipeOdBPreview,
    gtawTransitionMm: _parsePreviewValue(FieldKey.gtawTransitionMm),
  );

  Widget _buildFieldInput(InputFieldSpec field, {bool autofocus = false}) {
    if (field.diameterOptions != null) {
      return _buildDiameterField(field);
    }

    return TextField(
      controller: _controllers[field.key],
      focusNode: _fieldFocusNodes[field.key],
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(
        labelText: field.label,
        helperText: field.helperText,
      ),
      onChanged: (_) => setState(() => _result = null),
    );
  }

  Widget _buildDiameterField(InputFieldSpec field) {
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

  String _resolveDiameterModeFromController(InputFieldSpec field) {
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

  void _setControllerValue(FieldKey key, double? value, {int? digits}) {
    if (value == null) return;
    _controllers[key]!.text = digits == null
        ? value.toString()
        : value.toStringAsFixed(digits);
  }

  void _setDiameterPreset(FieldKey key, double value) {
    final token = _diameterValueToken(value);
    _diameterPresetModes[key] = token;
    _controllers[key]!.text = token;
  }

  void _applyDiameterOrValue(
    FieldKey key,
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
        quantity: _parseRequired(FieldKey.quantity, 'Quantity'),
        densityGPerCm3: _parseRequired(FieldKey.density, 'Density'),
        wasteFactorPercent: _parseRequired(
          FieldKey.wasteFactor,
          'Waste factor',
        ),
        lengthPerPieceMm: _parseOptional(FieldKey.lengthMm),
        pipeOdMm: _resolvePipeOdForCalculation(),
        thicknessMm: _resolveThicknessForCalculation(),
        rootGapMm: _parseOptional(FieldKey.rootGapMm),
        rootFaceMm: _parseOptional(FieldKey.rootFaceMm),
        bevelAngleDeg: _parseOptional(FieldKey.bevelAngleDeg),
        secondaryBevelAngleDeg: _parseOptional(FieldKey.secondaryBevelAngleDeg),
        breakHeightMm: _parseOptional(FieldKey.breakHeightMm),
        legSizeMm: _parseOptional(FieldKey.legSizeMm),
        gtawTransitionMm: _parseOptional(FieldKey.gtawTransitionMm),
        wireDiameterMm: _parseOptional(FieldKey.wireDiameterMm),
        electrodeDiameterMm: _parseOptional(FieldKey.electrodeDiameterMm),
        gtawWireDiameterMm: _parseOptional(FieldKey.gtawWireDiameterMm),
        smawElectrodeDiameterMm: _parseOptional(
          FieldKey.smawElectrodeDiameterMm,
        ),
        manualDepositionRateKgPerHour: _parseOptional(
          FieldKey.manualDepositionRateKgPerHour,
        ),
        manualGtawRateKgPerHour: _parseOptional(
          FieldKey.manualGtawRateKgPerHour,
        ),
        manualSmawRateKgPerHour: _parseOptional(
          FieldKey.manualSmawRateKgPerHour,
        ),
      );

      final result = _calculator.calculate(input);
      setState(() {
        _result = result;
        _showResultsScreen = true;
      });
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

  /// Opens a quick-edit sheet for the dimension the user tapped on the
  /// technical drawing, so the value can be entered right there without
  /// hunting for the matching field further down the page.
  void _handleDrawingFieldTap(FieldKey fieldKey) {
    InputFieldSpec? field;
    for (final candidate in _visibleFieldSpecs) {
      if (candidate.key == fieldKey) {
        field = candidate;
        break;
      }
    }
    if (field == null) return;
    _showQuickEditSheet(field);
  }

  Future<void> _showQuickEditSheet(InputFieldSpec field) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2DCE3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Text(
                  field.label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                _buildFieldInput(field, autofocus: true),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF12191B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Premium paywall shown when a free user taps a gated feature (PDF
  /// export). "Subscribe" here only flips the local [_isPremium] flag so
  /// the unlocked experience can be previewed -- it does not charge
  /// anyone. Swap this for a real StoreKit/RevenueCat purchase flow once
  /// the Apple Developer account and an App Store Connect subscription
  /// product exist, and wire "Restore Purchases" to the real entitlement
  /// check at the same time.
  Future<void> _showPaywall() {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 26),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2DCE3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color(0xFFFF6A35),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.workspace_premium_outlined,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Varyos Weld Premium',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildPaywallBenefit(
                  icon: Icons.picture_as_pdf_outlined,
                  text: 'Client-ready PDF export for every estimate',
                ),
                const SizedBox(height: 10),
                _buildPaywallBenefit(
                  icon: Icons.badge_outlined,
                  text: 'Report-grade layout with engineering basis included',
                ),
                const SizedBox(height: 10),
                _buildPaywallBenefit(
                  icon: Icons.event_repeat_outlined,
                  text: 'Cancel anytime from Settings',
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      setState(() => _isPremium = true);
                      Navigator.of(sheetContext).pop();
                      _showMessage('Premium unlocked for this session.');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF12191B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Subscribe -- \$4.99/month'),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => _showMessage(
                      'Restore Purchases will be available once payments are live.',
                    ),
                    child: const Text('Restore Purchases'),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Auto-renewing subscription. Price shown is a placeholder until the App Store listing is finalized.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8398A5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaywallBenefit({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF12191B)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF33474F)),
          ),
        ),
      ],
    );
  }

  double? _resolveThicknessForCalculation() {
    if (!_isUnequalGeometry) {
      return _parseOptional(FieldKey.thicknessMm);
    }
    final a = _parseOptional(FieldKey.thicknessAMm);
    final b = _parseOptional(FieldKey.thicknessBMm);
    if (a == null && b == null) return null;
    if (a == null) return b;
    if (b == null) return a;
    return a >= b ? a : b;
  }

  double? _resolvePipeOdForCalculation() {
    if (!_isUnequalGeometry) {
      return _parseOptional(FieldKey.pipeOdMm);
    }
    final a = _parseOptional(FieldKey.pipeOdAMm);
    final b = _parseOptional(FieldKey.pipeOdBMm);
    if (a == null && b == null) return null;
    if (a == null) return b;
    if (b == null) return a;
    return a >= b ? a : b;
  }

  void _resetFields() {
    _controllers[FieldKey.quantity]!.text = '1';
    _controllers[FieldKey.lengthMm]!.text = '1000';
    _controllers[FieldKey.pipeOdMm]!.text = '168.3';
    _controllers[FieldKey.pipeOdAMm]!.text = '168.3';
    _controllers[FieldKey.pipeOdBMm]!.text = '168.3';
    _controllers[FieldKey.thicknessMm]!.text = '12';
    _controllers[FieldKey.thicknessAMm]!.text = '12';
    _controllers[FieldKey.thicknessBMm]!.text = '12';
    _controllers[FieldKey.rootGapMm]!.text = '3';
    _controllers[FieldKey.rootFaceMm]!.text = '2';
    _controllers[FieldKey.bevelAngleDeg]!.text = '30';
    _controllers[FieldKey.secondaryBevelAngleDeg]!.text = '10';
    _controllers[FieldKey.breakHeightMm]!.text = '4';
    _controllers[FieldKey.legSizeMm]!.text = '6';
    _controllers[FieldKey.gtawTransitionMm]!.text = '3';
    _controllers[FieldKey.wireDiameterMm]!.text = '2.4';
    _controllers[FieldKey.electrodeDiameterMm]!.text = '3.2';
    _controllers[FieldKey.gtawWireDiameterMm]!.text = '2.4';
    _controllers[FieldKey.smawElectrodeDiameterMm]!.text = '3.2';
    _controllers[FieldKey.manualDepositionRateKgPerHour]!.text = '0.8';
    _controllers[FieldKey.manualGtawRateKgPerHour]!.text = '0.8';
    _controllers[FieldKey.manualSmawRateKgPerHour]!.text = '1.2';
    _controllers[FieldKey.wasteFactor]!.text = WeldingDefaults
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

  double _parseRequired(FieldKey key, String label) {
    final value = _controllers[key]!.text.trim();
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) {
      throw FormatException('$label must be a valid number.');
    }
    return parsed;
  }

  double? _parseOptional(FieldKey key) {
    final value = _controllers[key]!.text.trim();
    if (value.isEmpty) return null;
    return double.tryParse(value.replaceAll(',', '.'));
  }

  double? _parsePreviewValue(FieldKey key) {
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

  List<CalculationBasisItem> _buildCalculationBasis() {
    final items = <CalculationBasisItem>[
      CalculationBasisItem('Process', _weldingProcess.label),
      CalculationBasisItem('Rate Basis', _depositionRateMode.label),
      if (_inputPreset != InputPreset.custom)
        CalculationBasisItem('Input Preset', _inputPreset.label),
      if (_selectedUserPreset != null)
        CalculationBasisItem('Saved Preset', _selectedUserPreset!.name),
      CalculationBasisItem('Joint', _jointType.label),
      if (_supportsUnequalGeometry)
        CalculationBasisItem('Geometry', _jointGeometryMode.label),
      if (_isUnequalGeometry)
        CalculationBasisItem('Alignment', _jointAlignment.label),
      CalculationBasisItem('Groove', _grooveType.label),
      CalculationBasisItem(
        'Classification',
        '${_consumablePreset.awsSpecification} ${_consumablePreset.label}',
      ),
      CalculationBasisItem(
        'Filler Metal Family',
        _consumablePreset.family.label,
      ),
      CalculationBasisItem(
        'Density',
        '${_controllers[FieldKey.density]!.text} g/cm3',
      ),
      CalculationBasisItem(
        'Waste Allowance',
        '${_controllers[FieldKey.wasteFactor]!.text}%',
      ),
      CalculationBasisItem('Quantity', _controllers[FieldKey.quantity]!.text),
    ];

    if (_jointType == JointType.plateButt || _jointType == JointType.fillet) {
      items.add(
        CalculationBasisItem(
          'Weld Length per Piece',
          '${_controllers[FieldKey.lengthMm]!.text} mm',
        ),
      );
    }

    if (_jointType == JointType.pipeButt && !_isUnequalGeometry) {
      items.add(
        CalculationBasisItem(
          'Pipe OD',
          '${_controllers[FieldKey.pipeOdMm]!.text} mm',
        ),
      );
    }

    if (!_isUnequalGeometry &&
        (_jointType == JointType.plateButt ||
            _jointType == JointType.pipeButt)) {
      items.add(
        CalculationBasisItem(
          'Thickness',
          '${_controllers[FieldKey.thicknessMm]!.text} mm',
        ),
      );
    }

    if (_isUnequalGeometry) {
      if (_jointType == JointType.plateButt ||
          _jointType == JointType.pipeButt) {
        items.addAll([
          CalculationBasisItem(
            'Thickness A',
            '${_controllers[FieldKey.thicknessAMm]!.text} mm',
          ),
          CalculationBasisItem(
            'Thickness B',
            '${_controllers[FieldKey.thicknessBMm]!.text} mm',
          ),
          CalculationBasisItem(
            'Controlling Thickness',
            '${_formatNumber(_governingThicknessPreview ?? 0, 1)} mm',
          ),
        ]);
      }
      if (_jointType == JointType.pipeButt) {
        items.addAll([
          CalculationBasisItem(
            'OD A',
            '${_controllers[FieldKey.pipeOdAMm]!.text} mm',
          ),
          CalculationBasisItem(
            'OD B',
            '${_controllers[FieldKey.pipeOdBMm]!.text} mm',
          ),
          CalculationBasisItem(
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
        CalculationBasisItem(
          'Root Gap',
          '${_controllers[FieldKey.rootGapMm]!.text} mm',
        ),
      );
    }

    if (_grooveType == GrooveType.singleV ||
        _grooveType == GrooveType.halfV ||
        _grooveType == GrooveType.doubleV) {
      items.addAll([
        CalculationBasisItem(
          _grooveType == GrooveType.doubleV
              ? 'Root Face per Side'
              : 'Root Face',
          '${_controllers[FieldKey.rootFaceMm]!.text} mm',
        ),
        CalculationBasisItem(
          'Bevel Angle',
          '${_controllers[FieldKey.bevelAngleDeg]!.text} deg',
        ),
      ]);
    }

    if (_grooveType == GrooveType.compoundV) {
      items.addAll([
        CalculationBasisItem(
          'Root Face',
          '${_controllers[FieldKey.rootFaceMm]!.text} mm',
        ),
        CalculationBasisItem(
          'Primary Bevel Angle',
          '${_controllers[FieldKey.bevelAngleDeg]!.text} deg',
        ),
        CalculationBasisItem(
          'Secondary Bevel Angle',
          '${_controllers[FieldKey.secondaryBevelAngleDeg]!.text} deg',
        ),
        CalculationBasisItem(
          'Break Height',
          '${_controllers[FieldKey.breakHeightMm]!.text} mm',
        ),
      ]);
    }

    if (_grooveType == GrooveType.fillet) {
      items.add(
        CalculationBasisItem(
          'Fillet Leg Size',
          '${_controllers[FieldKey.legSizeMm]!.text} mm',
        ),
      );
    }

    if (_weldingProcess == WeldingProcess.gtaw) {
      if (_depositionRateMode == DepositionRateMode.manual) {
        items.add(
          CalculationBasisItem(
            'User-defined Rate',
            '${_controllers[FieldKey.manualDepositionRateKgPerHour]!.text} kg/h',
          ),
        );
      } else {
        items.add(
          CalculationBasisItem(
            'Wire Diameter',
            '${_controllers[FieldKey.wireDiameterMm]!.text} mm',
          ),
        );
      }
    } else if (_weldingProcess == WeldingProcess.smaw) {
      if (_depositionRateMode == DepositionRateMode.manual) {
        items.add(
          CalculationBasisItem(
            'User-defined Rate',
            '${_controllers[FieldKey.manualDepositionRateKgPerHour]!.text} kg/h',
          ),
        );
      } else {
        items.add(
          CalculationBasisItem(
            'Electrode Diameter',
            '${_controllers[FieldKey.electrodeDiameterMm]!.text} mm',
          ),
        );
      }
    } else if (_weldingProcess == WeldingProcess.gmaw ||
        _weldingProcess == WeldingProcess.fcaw) {
      if (_depositionRateMode == DepositionRateMode.manual) {
        items.add(
          CalculationBasisItem(
            'User-defined Rate',
            '${_controllers[FieldKey.manualDepositionRateKgPerHour]!.text} kg/h',
          ),
        );
      } else {
        items.add(
          CalculationBasisItem(
            'Wire Diameter',
            '${_controllers[FieldKey.wireDiameterMm]!.text} mm',
          ),
        );
      }
    } else if (_weldingProcess == WeldingProcess.gtawSmaw) {
      items.addAll([
        CalculationBasisItem(
          'GTAW Transition Depth',
          '${_controllers[FieldKey.gtawTransitionMm]!.text} mm',
        ),
        if (_depositionRateMode == DepositionRateMode.manual)
          CalculationBasisItem(
            'GTAW Deposition Rate',
            '${_controllers[FieldKey.manualGtawRateKgPerHour]!.text} kg/h',
          )
        else
          CalculationBasisItem(
            'GTAW Wire Diameter',
            '${_controllers[FieldKey.gtawWireDiameterMm]!.text} mm',
          ),
        if (_depositionRateMode == DepositionRateMode.manual)
          CalculationBasisItem(
            'SMAW Deposition Rate',
            '${_controllers[FieldKey.manualSmawRateKgPerHour]!.text} kg/h',
          )
        else
          CalculationBasisItem(
            'SMAW Electrode Diameter',
            '${_controllers[FieldKey.smawElectrodeDiameterMm]!.text} mm',
          ),
      ]);
    }

    return items;
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/weld_calculator.dart';
import '../data/base_material_catalog.dart';
import '../data/consumable_catalog.dart';
import '../core/welding_defaults.dart';
import '../l10n/app_language.dart';
import '../l10n/app_locale_scope.dart';
import '../l10n/auth_copy.dart';
import '../l10n/strings.dart';
import '../models/base_material_selection.dart';
import '../models/consumable_selection.dart';
import '../models/custom_material_models.dart';
import '../models/saved_report.dart';
import '../models/weld_models.dart';
import '../services/auth_service.dart';
import '../services/custom_base_material_store.dart';
import '../services/custom_filler_material_store.dart';
import '../services/entitlement_service.dart';
import '../services/pdf_report_exporter.dart';
import '../services/preset_sync_service.dart';
import '../services/saved_report_store.dart';
import '../services/user_account_store.dart';
import '../services/user_preset_store.dart';
import '../services/user_preset_sync.dart';
import '../services/weld_pdf_report_service.dart';
import 'auth/account_prompt_sheet.dart';
import 'auth/auth_flows.dart';
import 'premium_paywall.dart';
import 'user_guide_screen.dart';
import 'widgets/weld_drawing_preview.dart';
import 'calculator_page/calculator_page_models.dart';
import 'calculator_page/calculator_page_widgets.dart';
import 'widgets/field_reveal.dart';
import 'widgets/catalog_labels.dart';
import 'widgets/searchable_picker.dart';
import 'calculator_page/wizard/consumable_step.dart';
import 'calculator_page/wizard/dimensions_step.dart';
import 'calculator_page/wizard/process_selection_step.dart';
import 'calculator_page/wizard/summary_step.dart';
import 'calculator_page/wizard/wizard_step_indicator.dart';

/// Thrown by [_CalculatorPageState._parseRequired] instead of a plain
/// [FormatException] so `_calculate()`'s validation-failure handler knows
/// which [FieldKey] (and therefore which wizard step) to send the user
/// back to, rather than stranding them on the summary step.
class _RequiredFieldMissingException implements Exception {
  const _RequiredFieldMissingException(this.fieldKey, this.message);

  final FieldKey fieldKey;
  final String message;
}

/// Chooses which [L10nStrings] a PDF export renders with. The `pdf` package
/// (v3.13.0) has no Indic complex-script shaping -- no GSUB/GPOS, no
/// matra/vowel-sign reordering -- so Hindi PDF output renders with visibly
/// garbled/reordered glyphs. PDF exports fall back to English for Hindi;
/// the UI itself stays Hindi, since this is a PDF-rendering-limitation
/// workaround, not a translation quality issue. Don't "fix" this by
/// reverting to [uiStrings] for Hindi.
L10nStrings pdfExportStringsFor(AppLanguage language) =>
    language == AppLanguage.hi
    ? stringsFor(AppLanguage.en)
    : stringsFor(language);

class CalculatorPage extends StatefulWidget {
  CalculatorPage({
    super.key,
    this.presetToLoad,
    EntitlementService? entitlementService,
  }) : entitlementService = entitlementService ?? EntitlementService();

  /// When set, skips the intro screen, applies this preset's data the same
  /// way picking it from the (now-removed) inline preset dropdown used to,
  /// and opens straight on the Process wizard step / desktop workspace.
  /// Set by [SavedCalculationsScreen]'s "Load" action.
  final UserWeldPreset? presetToLoad;

  /// Overridable so tests can inject a fake without touching the real
  /// RevenueCat SDK. See lib/services/entitlement_service.dart.
  final EntitlementService entitlementService;

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final WeldCalculator _calculator = const WeldCalculator();
  final WeldPdfReportService _pdfReportService = const WeldPdfReportService();
  final UserPresetStore _userPresetStore = const UserPresetStore();
  final SavedReportStore _savedReportStore = const SavedReportStore();
  final UserAccountStore _accountStore = const UserAccountStore();
  final PresetSyncService _presetSyncService = const PresetSyncService();
  final CustomFillerMaterialStore _fillerMaterialStore =
      const CustomFillerMaterialStore();
  final CustomBaseMaterialStore _baseMaterialStore =
      const CustomBaseMaterialStore();
  final ScrollController _pageScrollController = ScrollController();
  final ScrollController _inputColumnScrollController = ScrollController();
  final ScrollController _drawingColumnScrollController = ScrollController();
  static const _customDiameterValue = 'custom';

  final Map<FieldKey, TextEditingController> _controllers = {
    for (final key in FieldKey.values) key: TextEditingController(),
  };
  final Map<FieldKey, FocusNode> _fieldFocusNodes = {
    for (final key in FieldKey.values) key: FocusNode(),
  };
  // Dimension shown highlighted on the drawing: the one whose quick-edit sheet
  // is open, else the one whose form field has focus.
  FieldKey? _drawingSelection;
  FieldKey? _drawingFocused;
  final Map<FieldKey, String> _diameterPresetModes = {};
  final Map<FieldKey, String> _fieldErrors = {};
  int _capSectionToken = 0;

  JointType _jointType = JointType.plateButt;
  GrooveType _grooveType = GrooveType.singleV;
  WeldingProcess _weldingProcess = WeldingProcess.gtaw;
  DepositionRateMode _depositionRateMode = DepositionRateMode.preset;
  DrawingMode _drawingMode = DrawingMode.visual;
  JointGeometryMode _jointGeometryMode = JointGeometryMode.equal;
  JointAlignment _jointAlignment = JointAlignment.centerline;
  ConsumableSelection _consumableSelection = const BuiltInConsumableSelection(
    ConsumablePreset.er70s2,
  );
  List<CustomFillerMaterial> _customFillerMaterials = const [];
  // False until `_fillerMaterialStore.load()` resolves, so the "(as saved)"
  // label/"My Materials" header can wait for the real library contents
  // instead of judging staleness against the still-empty initial list on
  // frame 1 of every load (see finding #3 of the second reviewer pass).
  bool _fillerMaterialsLoaded = false;
  // Set once, the first time a saved calculation's custom-filler snapshot
  // turns out stale/deleted relative to the loaded library, and never
  // cleared for the life of this screen instance -- so picking a different
  // material to compare doesn't lose the ability to select the original
  // "(as saved)" entry again (see finding #4 / user decision).
  ConsumableSelection? _pinnedStaleCustomSelection;
  // Optional -- unlike _consumableSelection, no base material is required
  // to run a calculation, so `null` ("not specified") is the default and a
  // valid end state, not just a transient loading value.
  BaseMaterialSelection? _baseMaterialSelection;
  List<CustomBaseMaterial> _customBaseMaterials = const [];
  bool _baseMaterialsLoaded = false;
  // Same stale-snapshot pinning as _pinnedStaleCustomSelection above, for
  // the base-material dropdown's own library list.
  BaseMaterialSelection? _pinnedStaleBaseMaterialSelection;
  InputPreset _inputPreset = InputPreset.custom;
  // Bumped whenever a starter-preset process-switch confirmation is
  // cancelled, so the dropdown (keyed on `_inputPreset` + this) remounts
  // back to the unchanged `_inputPreset` instead of keeping the internal
  // FormField state showing the tapped-but-not-applied item.
  int _starterPresetDropdownResetToken = 0;
  List<UserWeldPreset> _userPresets = const [];
  String? _selectedUserPresetId;
  String? _accountEmail;
  WeldCalculationResult? _result;
  bool _showResultsScreen = false;
  bool _showIntro = true;
  // Only the mobile wizard reads this; the results screen's own back path
  // (`_showResultsScreen = false`) never needs to reset it, because
  // Calculate is only reachable from WizardStep.summary, so falling back
  // from results naturally re-lands on summary already.
  WizardStep _wizardStep = WizardStep.process;
  bool _isPremium = false;
  StreamSubscription<bool>? _premiumStatusSubscription;
  bool _isExportingPdf = false;
  bool _isUserPresetBusy = false;

  @override
  void initState() {
    super.initState();
    for (final entry in _fieldFocusNodes.entries) {
      entry.value.addListener(() => _onDimensionFocusChanged(entry.key));
    }
    _resetFields();
    _initUserPresets();
    _initEntitlement();
    _fillerMaterialStore.load().then((materials) {
      if (!mounted) return;
      setState(() {
        _customFillerMaterials = materials;
        _fillerMaterialsLoaded = true;
      });
    });
    _baseMaterialStore.load().then((materials) {
      if (!mounted) return;
      setState(() {
        _customBaseMaterials = materials;
        _baseMaterialsLoaded = true;
      });
    });
    final presetToLoad = widget.presetToLoad;
    if (presetToLoad != null) {
      _showIntro = false;
      // All data is already filled in from the loaded preset, so land on
      // Summary/Review directly instead of making the user tap Continue
      // through steps they don't need to touch -- the per-section Edit
      // buttons there still let them jump back into any step.
      _wizardStep = WizardStep.summary;
      // Mutated directly rather than via setState: initState runs before
      // this element's first build, so these values are already picked up
      // without needing to schedule a rebuild.
      _applyUserPreset(presetToLoad);
    }
  }

  Future<void> _initUserPresets() async {
    _accountEmail = await _accountStore.getEmail();
    await _loadUserPresets();
  }

  Future<void> _initEntitlement() async {
    try {
      final isPremium = await widget.entitlementService.isPremiumActive();
      if (!mounted) return;
      setState(() => _isPremium = isPremium);
    } catch (error) {
      debugPrint('Failed to read entitlement status: $error');
    }
    // Re-check here too: dispose() may have already run while the call
    // above was in flight (it cancels `_premiumStatusSubscription`, but
    // only what's assigned by the time it runs -- subscribing after that
    // point would never get cancelled and leak this State via RevenueCat's
    // retained listener).
    if (!mounted) return;
    _premiumStatusSubscription = widget.entitlementService
        .premiumStatusStream()
        .listen((isPremium) {
          if (!mounted) return;
          setState(() => _isPremium = isPremium);
        });
  }

  // The wizard's step content swaps under the same `_pageScrollController`
  // (only the child of the SingleChildScrollView changes), so without this
  // a new step opens at whatever scroll offset the previous step was left
  // at. Deferred to the next frame because the new step's content hasn't
  // attached to the controller yet at the point `setState` returns.
  void _resetWizardScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageScrollController.hasClients) {
        _pageScrollController.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    _premiumStatusSubscription?.cancel();
    _pageScrollController.dispose();
    _inputColumnScrollController.dispose();
    _drawingColumnScrollController.dispose();
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
                    return _buildWizardFlow(context);
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
    final strings = AppLocaleScope.stringsOf(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackToDashboardButton(),
              const TopNavigationBar(),
              const GuideHowToLink(sectionId: 'filler'),
              const SizedBox(height: 8),
              ExperienceHero(
                jointTypeLabel: _jointType.labelFor(strings),
                grooveLabel: _grooveType.labelFor(strings),
                processLabel: _weldingProcess.label,
                drawingModeLabel: _drawingMode.labelFor(strings),
                consumableLabel: _consumableSelection.label,
                savedPresetCount: _userPresets.length,
                hasResults: _result != null,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _showIntro = false;
                      _wizardStep = WizardStep.process;
                    });
                    _resetWizardScroll();
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(strings.getStarted),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6A35),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const CapabilityStrip(),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackToDashboardButton(),
              _buildEstimatorWorkspace(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Mobile layout: a Back/Continue wizard (Process -> Dimensions ->
  /// Consumable -> Summary) instead of one long scroll, reusing the same
  /// State methods/section builders as the desktop card layout below.
  Widget _buildWizardFlow(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    final availableConsumables = WeldingDefaults.consumablesFor(
      _weldingProcess,
    );

    final Widget stepContent = switch (_wizardStep) {
      WizardStep.process => WizardProcessStep(
        selectedProcess: _weldingProcess,
        onSelected: (value) {
          setState(() {
            _weldingProcess = value;
            _applyProcessFieldDefaults();
            _syncConsumableForProcess();
            // Step 2's starter-template dropdown is filtered to the
            // selected process; a previously applied cross-process template
            // would no longer be a valid item in that filtered list.
            if (_inputPreset.data?.weldingProcess != value) {
              _inputPreset = InputPreset.custom;
            }
            _result = null;
          });
        },
        onContinue: () {
          setState(() => _wizardStep = WizardStep.dimensions);
          _resetWizardScroll();
        },
      ),
      WizardStep.dimensions => WizardDimensionsStep(
        drawingHeader: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
          child: _buildTechnicalDrawingCard(context, compact: true),
        ),
        starterPresetSection: _buildStarterPresetSection(
          context,
          filterByCurrentProcess: true,
        ),
        jointTypeSection: _buildJointTypeSection(context, compactTitle: true),
        memberGeometrySection: _buildMemberGeometrySection(context),
        grooveTypeDropdown: _buildGrooveTypeDropdown(context),
        primaryDimensionFields: [
          for (final field in _primaryDimensionFields(strings))
            _buildFieldInput(field),
        ],
        capDimensionFields: [
          for (final field in _capDimensionFields(strings))
            _buildFieldInput(field),
        ],
        initiallyExpandCapSection: _hasCapDimensionValues,
        capSectionKey: ValueKey('cap-$_capSectionToken'),
        onBack: () {
          setState(() => _wizardStep = WizardStep.process);
          _resetWizardScroll();
        },
        onContinue: () {
          setState(() => _wizardStep = WizardStep.consumable);
          _resetWizardScroll();
        },
      ),
      WizardStep.consumable => WizardConsumableStep(
        consumableClassificationDropdown: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConsumableClassificationSection(
              context,
              availableConsumables,
            ),
            const SizedBox(height: 12),
            PanelNote(
              icon: Icons.science_outlined,
              text: strings.calcTypicalBaseMetalsNote.replaceFirst(
                '{value}',
                _consumableSelection.typicalBaseMetalsTextFor(strings),
              ),
            ),
            const SizedBox(height: 14),
            _buildBaseMaterialSection(context),
          ],
        ),
        rateBasisSection: _buildRateBasisSection(context),
        consumableFields: [
          for (final field in _wizardConsumableFields(strings))
            _buildFieldInput(field),
        ],
        onBack: () {
          setState(() => _wizardStep = WizardStep.dimensions);
          _resetWizardScroll();
        },
        onContinue: () {
          setState(() => _wizardStep = WizardStep.summary);
          _resetWizardScroll();
        },
      ),
      WizardStep.summary => WizardSummaryStep(
        engineeringBasisBanner: _buildEstimatorControlCard(context),
        processSection: _buildRecapChips(_wizardProcessRecapItems),
        dimensionsSection: _buildRecapChips(_wizardDimensionsRecapItems),
        consumableSection: _buildRecapChips(_wizardConsumableRecapItems),
        onEditProcess: () {
          setState(() => _wizardStep = WizardStep.process);
          _resetWizardScroll();
        },
        onEditDimensions: () {
          setState(() => _wizardStep = WizardStep.dimensions);
          _resetWizardScroll();
        },
        onEditConsumable: () {
          setState(() => _wizardStep = WizardStep.consumable);
          _resetWizardScroll();
        },
        onCalculate: _calculate,
        onReset: _resetFields,
        onSaveAsPreset: _isUserPresetBusy ? null : _saveCurrentAsUserPreset,
        saveAsPresetBusy: _isUserPresetBusy,
        saveAsPresetLabel: _saveAsPresetButtonLabel(strings),
      ),
    };

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (Navigator.of(context).canPop())
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton.filledTonal(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: strings.calcBackToDashboardTooltip,
                  ),
                ),
              Expanded(
                child: WizardStepIndicator(
                  currentIndex: WizardStep.values.indexOf(_wizardStep),
                  totalSteps: WizardStep.values.length,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _pageScrollController,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 40),
            child: stepContent,
          ),
        ),
      ],
    );
  }

  Widget _buildEstimatorWorkspace(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    final visibleFields = _visibleFieldSpecs(strings);
    final availableConsumables = WeldingDefaults.consumablesFor(
      _weldingProcess,
    );

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
                    // Scrollable, like the input column, rather than
                    // Expanded+Align: at some widths just above the 1120
                    // wide-mode breakpoint, Joint Configuration's own
                    // internal `narrow < 560` split stacks its two dropdowns
                    // instead of placing them side by side, growing tall
                    // enough that the fixed-height row above left the
                    // drawing almost no room - Expanded silently squeezed it
                    // to a near-zero-height sliver instead of overflowing
                    // visibly. Fixed height + compact/fillAvailableSpace
                    // reuses the same drawing rendering already tuned and
                    // verified for the mobile narrow layout, rather than the
                    // FittedBox(760x400) path, which was never exercised
                    // inside an unbounded-height scroll parent.
                    child: Scrollbar(
                      controller: _drawingColumnScrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _drawingColumnScrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildJointConfigurationCard(context),
                            const SizedBox(height: 18),
                            _buildTechnicalDrawingCard(context, compact: true),
                          ],
                        ),
                      ),
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
    final strings = AppLocaleScope.stringsOf(context);
    final processEfficiency = _previewEfficiency;
    final depositionRate = _previewDepositionRate;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  Text(
                    strings.calcActiveEngineeringBasisTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${_jointType.helperFor(strings)} ${_unequalGeometrySummary(strings)}${_processRateSummary(strings, processEfficiency, depositionRate)}',
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

  /// Extracted so the mobile wizard's dimensions step can reuse the exact
  /// same "Joint Type" chips as the desktop [_buildJointConfigurationCard].
  /// [compactTitle] shrinks the section's own "Joint Type" heading down from
  /// the desktop card's top-level size to `titleMedium` -- used by the mobile
  /// wizard, where this section is now nested under its own larger
  /// "Joint Type & Geometry" group heading and would otherwise tie with it.
  Widget _buildJointTypeSection(
    BuildContext context, {
    bool compactTitle = false,
  }) {
    final strings = AppLocaleScope.stringsOf(context);
    final titleStyle = compactTitle
        ? Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)
        : Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(strings.calcJointTypeSectionTitle, style: titleStyle),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final joint in JointType.values)
              _buildSelectionChip(
                label: joint.labelFor(strings),
                selected: _jointType == joint,
                onSelected: () => _onJointTypeChanged(joint),
              ),
          ],
        ),
      ],
    );
  }

  /// Extracted so the mobile wizard's dimensions step can reuse the exact
  /// same "Member Geometry" chips + alignment dropdown as the desktop
  /// [_buildJointConfigurationCard]. Returns an empty widget when the
  /// current joint type doesn't support unequal geometry, matching the
  /// desktop card's conditional rendering.
  Widget _buildMemberGeometrySection(BuildContext context) {
    if (!_supportsUnequalGeometry) return const SizedBox.shrink();
    final strings = AppLocaleScope.stringsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        Text(
          strings.calcMemberGeometrySectionTitle,
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
                label: mode.labelFor(strings),
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
              decoration: InputDecoration(
                labelText: strings.calcAlignmentReferenceLabel,
                helperText: strings.calcAlignmentReferenceHelper,
              ),
              selectedItemBuilder: (context) => JointAlignment.values
                  .map(
                    (alignment) =>
                        _buildDropdownSelectedText(alignment.labelFor(strings)),
                  )
                  .toList(),
              items: JointAlignment.values
                  .map(
                    (alignment) => DropdownMenuItem(
                      value: alignment,
                      child: Text(
                        alignment.labelFor(strings),
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
    );
  }

  /// Extracted so the mobile wizard's dimensions step can reuse the exact
  /// same "Groove Type" dropdown as the desktop [_buildJointConfigurationCard]
  /// (which pairs it with the process dropdown -- process now lives on the
  /// wizard's own first step, so this dropdown stands alone there).
  Widget _buildGrooveTypeDropdown(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    return _buildDropdownFrame(
      DropdownButtonFormField<GrooveType>(
        initialValue: _grooveType,
        isExpanded: true,
        decoration: InputDecoration(labelText: strings.calcGrooveTypeLabel),
        selectedItemBuilder: (context) => _jointType.supportedGrooves
            .map(
              (groove) => _buildDropdownSelectedText(groove.labelFor(strings)),
            )
            .toList(),
        items: _jointType.supportedGrooves
            .map(
              (groove) => DropdownMenuItem(
                value: groove,
                child: Text(
                  groove.labelFor(strings),
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
  }

  Widget _buildJointConfigurationCard(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildJointTypeSection(context),
            _buildMemberGeometrySection(context),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 560;
                final grooveDropdown = _buildGrooveTypeDropdown(context);
                final processDropdown = _buildDropdownFrame(
                  DropdownButtonFormField<WeldingProcess>(
                    initialValue: _weldingProcess,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: strings.calcWeldingProcessLabel,
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
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalDrawingCard(
    BuildContext context, {
    bool compact = false,
  }) {
    final strings = AppLocaleScope.stringsOf(context);
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
        padding: EdgeInsets.all(compact ? 4 : 12),
        child: compact
            ? SizedBox(
                height: weldDrawingPhoneCanvasHeight(
                  _grooveType,
                  MediaQuery.textScalerOf(context),
                ),
                child: WeldDrawingPreview(
                  grooveType: _grooveType,
                  jointType: _jointType,
                  drawingMode: _drawingMode,
                  data: _drawingData,
                  onFieldTap: _handleDrawingFieldTap,
                  highlightedField: _drawingSelection ?? _drawingFocused,
                  fillAvailableSpace: true,
                  jointTypeLabel: _jointType.labelFor(strings),
                  grooveTypeLabel: _grooveType.labelFor(strings),
                  filletWeldFaceLabel: strings.drawingLabelFilletWeldFace,
                  tJointLabel: strings.drawingLabelTJoint,
                  smawFillCapLabel: strings.drawingLabelSmawFillCap,
                  gtawRootLabel: strings.drawingLabelGtawRoot,
                  capTopLabel: strings.drawingLabelCapTop,
                  capBottomLabel: strings.drawingLabelCapBottom,
                  capOverlapValueLabel: strings.drawingLabelCapOverlapValue,
                  capHeightValueLabel: strings.drawingLabelCapHeightValue,
                ),
              )
            : Center(
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
                      highlightedField: _drawingSelection ?? _drawingFocused,
                      jointTypeLabel: _jointType.labelFor(strings),
                      grooveTypeLabel: _grooveType.labelFor(strings),
                      filletWeldFaceLabel: strings.drawingLabelFilletWeldFace,
                      tJointLabel: strings.drawingLabelTJoint,
                      smawFillCapLabel: strings.drawingLabelSmawFillCap,
                      gtawRootLabel: strings.drawingLabelGtawRoot,
                      capTopLabel: strings.drawingLabelCapTop,
                      capBottomLabel: strings.drawingLabelCapBottom,
                      capOverlapValueLabel: strings.drawingLabelCapOverlapValue,
                      capHeightValueLabel: strings.drawingLabelCapHeightValue,
                    ),
                  ),
                ),
              ),
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 6 : 22),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hasBoundedHeight = constraints.maxHeight.isFinite;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (compact) ...[
                  Text(
                    strings.techDrawingTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final mode in DrawingMode.values) ...[
                        if (mode != DrawingMode.values.first)
                          const SizedBox(width: 8),
                        Expanded(
                          child: _buildCompactModeSegment(
                            label: mode.labelFor(strings),
                            selected: _drawingMode == mode,
                            onSelected: () {
                              setState(() {
                                _drawingMode = mode;
                              });
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.techDrawingTitle,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _drawingMode == DrawingMode.technical
                                  ? strings.techDrawingModeTechnicalDesc
                                  : strings.techDrawingModeVisualDesc,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: const Color(0xFF607482)),
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
                                label: mode.labelFor(strings),
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
                SizedBox(height: compact ? 6 : 16),
                if (hasBoundedHeight && !compact)
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

  /// Extracted so the mobile wizard's dimensions step can reuse the exact
  /// same built-in starter-setup dropdown as the desktop
  /// [_buildInputParametersCard]. The user's own saved presets used to live
  /// in this same section too, but browsing/loading/deleting those now
  /// happens entirely on the dashboard's Saved Calculations screen instead.
  Widget _buildStarterPresetSection(
    BuildContext context, {
    bool filterByCurrentProcess = false,
  }) {
    final strings = AppLocaleScope.stringsOf(context);
    // The mobile wizard already had the user pick a welding process on Step
    // 1, so offering a cross-process template here would either silently
    // fight that choice or trigger the process-switch confirmation mid-flow.
    // The desktop layout has no such earlier step, so it keeps the full list.
    final availablePresets = filterByCurrentProcess
        ? InputPreset.values
              .where(
                (preset) =>
                    preset.data == null ||
                    preset.data!.weldingProcess == _weldingProcess,
              )
              .toList()
        : InputPreset.values;
    // `_inputPreset` can go stale relative to `availablePresets` (e.g. a
    // template applied before the process changed elsewhere -- desktop's own
    // process dropdown at `:900` doesn't reset it). Clamp at render time
    // rather than chasing every mutation site, since `DropdownButtonFormField`
    // throws unless its value is exactly one item in this list.
    final selected = availablePresets.contains(_inputPreset)
        ? _inputPreset
        : InputPreset.custom;
    return InputPanelSection(
      icon: Icons.auto_awesome_outlined,
      title: strings.calcStartingTemplateTitle,
      subtitle: strings.calcStartingTemplateSubtitle,
      trailing: IconButton(
        tooltip: strings.calcStartingTemplateTitle,
        icon: const Icon(Icons.help_outline),
        onPressed: () => showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(strings.calcStartingTemplateTitle),
            content: Text(strings.calcStartingTemplateInfo),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(strings.commonDone),
              ),
            ],
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownFrame(
            DropdownButtonFormField<InputPreset>(
              // Keyed on the applied value so a cancelled process-switch
              // confirmation (which leaves `_inputPreset` unchanged) forces
              // the dropdown to remount back to it, instead of keeping the
              // tapped-but-not-applied item selected via its own internal
              // FormField state.
              key: ValueKey('$selected-$_starterPresetDropdownResetToken'),
              initialValue: selected,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: strings.calcInputPresetLabel,
              ),
              selectedItemBuilder: (context) => availablePresets
                  .map(
                    (preset) =>
                        _buildDropdownSelectedText(preset.labelFor(strings)),
                  )
                  .toList(),
              items: availablePresets
                  .map(
                    (preset) => DropdownMenuItem(
                      value: preset,
                      child: Text(
                        preset.labelFor(strings),
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
                _applyInputPreset(context, value);
              },
            ),
          ),
          const SizedBox(height: 12),
          PanelNote(
            icon: Icons.auto_fix_high_outlined,
            text: selected.descriptionFor(strings),
          ),
        ],
      ),
    );
  }

  /// Extracted so the mobile wizard's consumable step can reuse the exact
  /// same dropdown as the desktop [_buildInputParametersCard]. Custom
  /// filler materials from the library appear under a disabled "My
  /// Materials" header, unfiltered by process (see coder task decision #4).
  Widget _buildConsumableClassificationSection(
    BuildContext context,
    List<ConsumablePreset> availableConsumables,
  ) {
    final strings = AppLocaleScope.stringsOf(context);
    final builtInSelections = availableConsumables
        .map(BuiltInConsumableSelection.new)
        .toList();
    final customSelections = _customFillerMaterials
        .map(CustomConsumableSelection.new)
        .toList();
    // The library list is live and loads asynchronously, so a saved
    // calculation's snapshot may not (yet, or ever again) match any entry
    // in it -- edited/deleted-since-save, or just not loaded on frame 1.
    // `DropdownButtonFormField` throws unless its value equals exactly one
    // item, so the snapshot itself must always be injected as a selectable
    // item even when it's missing from the live library (see finding #1).
    // This membership check alone is unreliable for anything beyond that
    // crash-prevention injection: it's also true on frame 1 of every load
    // (the library hasn't finished loading yet) and it stops being true the
    // moment the user picks something else. Neither the "(as saved)" label
    // nor whether the snapshot survives in the list once deselected should
    // depend on it -- see findings #3 and #4.
    final selectedSnapshot = _consumableSelection;
    final isCurrentSelectionMissing =
        selectedSnapshot is CustomConsumableSelection &&
        !selectedSnapshot.material.id.startsWith(CatalogConsumable.idPrefix) &&
        !customSelections.contains(selectedSnapshot);
    if (_fillerMaterialsLoaded &&
        isCurrentSelectionMissing &&
        _pinnedStaleCustomSelection == null) {
      _pinnedStaleCustomSelection = selectedSnapshot;
    }
    final pinnedSnapshot = _pinnedStaleCustomSelection;
    final displayedCustomSelections = [
      ...customSelections,
      if (isCurrentSelectionMissing && selectedSnapshot != pinnedSnapshot)
        selectedSnapshot,
      if (pinnedSnapshot != null && !customSelections.contains(pinnedSnapshot))
        pinnedSnapshot,
    ];
    String customSelectionLabel(ConsumableSelection selection) =>
        _fillerMaterialsLoaded && selection == pinnedSnapshot
        ? '${selection.label}${strings.calcAsSavedSuffix}'
        : selection.label;
    String consumableSubtitle(ConsumableSelection selection) => [
      if (selection.awsSpecification != null) selection.awsSpecification!,
      selection.family.labelFor(strings),
    ].join(' · ');
    List<PickerOption<ConsumableSelection>> pickerOptions() {
      final groups = <String, List<PickerOption<ConsumableSelection>>>{};
      void add(String group, ConsumableSelection selection, String title) {
        groups
            .putIfAbsent(group, () => [])
            .add(
              PickerOption(
                value: selection,
                title: title,
                subtitle:
                    '${consumableSubtitle(selection)} · '
                    '${selection.descriptionFor(strings)}',
                group: group,
              ),
            );
      }

      for (final selection in builtInSelections) {
        add(selection.awsSpecification!, selection, selection.label);
      }
      for (final entry in ConsumableCatalog.forProcess(_weldingProcess)) {
        add(
          entry.specification,
          CustomConsumableSelection(entry.toFiller()),
          entry.label,
        );
      }
      final ordered = <String>[
        ...ConsumableCatalog.groupOrder.where(groups.containsKey),
        ...groups.keys.where(
          (group) => !ConsumableCatalog.groupOrder.contains(group),
        ),
      ];
      return [
        for (final selection in displayedCustomSelections)
          PickerOption(
            value: selection,
            title: customSelectionLabel(selection),
            subtitle: consumableSubtitle(selection),
            group: strings.calcMyMaterialsHeader,
          ),
        for (final group in ordered) ...?groups[group],
      ];
    }

    return InputPanelSection(
      icon: Icons.inventory_2_outlined,
      title: strings.calcConsumableDensityTitle,
      subtitle: strings.calcConsumableDensitySubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PickerField(
            label: strings.calcConsumableClassificationLabel,
            helper: strings.calcConsumableClassificationHelper,
            title: _consumableSelection is CustomConsumableSelection
                ? customSelectionLabel(_consumableSelection)
                : _consumableSelection.label,
            subtitle: consumableSubtitle(_consumableSelection),
            onTap: () async {
              final picked = await showSearchablePicker<ConsumableSelection>(
                context,
                title: strings.calcConsumableClassificationLabel,
                options: pickerOptions(),
                selected: _consumableSelection,
              );
              if (picked == null || !mounted) return;
              setState(() {
                _consumableSelection = picked.value;
                _applyConsumableSelection(picked.value);
                _result = null;
              });
            },
          ),
          const SizedBox(height: 12),
          PanelNote(
            icon: Icons.verified_outlined,
            text: strings.calcSelectedClassificationNote.replaceFirst(
              '{value}',
              [
                if (_consumableSelection.awsSpecification != null)
                  _consumableSelection.awsSpecification!,
                _consumableSelection.label,
                _consumableSelection.family.labelFor(strings),
                '${strings.basisDensity} ${_formatNumber(_consumableSelection.densityGPerCm3, 2)} g/cm3',
              ].join(' | '),
            ),
          ),
        ],
      ),
    );
  }

  /// Extracted so the mobile wizard's consumable step can reuse the exact
  /// same section as the desktop [_buildInputParametersCard]. Optional --
  /// unlike [_buildConsumableClassificationSection], this app has no
  /// built-in base-material catalog to pick from (confirmed by grep before
  /// this feature was added), so the dropdown only ever offers "Not
  /// specified" plus the user's own library entries. No process/groove
  /// filtering is applied for the same reason custom filler materials
  /// aren't filtered (see coder task decision #4) -- base-metal chemistry
  /// has no meaningful process/groove compatibility dimension in this app.
  Widget _buildBaseMaterialSection(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    final customOptions = _customBaseMaterials
        .map(BaseMaterialSelection.new)
        .toList();
    // Same live-library-vs-saved-snapshot reconciliation as
    // _buildConsumableClassificationSection above -- see its comment for
    // the full reasoning. `null` ("not specified") is always a valid
    // selection and can never go stale, so only a non-null snapshot needs
    // this handling.
    final selectedSnapshot = _baseMaterialSelection;
    final isCurrentSelectionMissing =
        selectedSnapshot != null &&
        !selectedSnapshot.material.id.startsWith(
          CatalogBaseMaterial.idPrefix,
        ) &&
        !customOptions.contains(selectedSnapshot);
    if (_baseMaterialsLoaded &&
        isCurrentSelectionMissing &&
        _pinnedStaleBaseMaterialSelection == null) {
      _pinnedStaleBaseMaterialSelection = selectedSnapshot;
    }
    final pinnedSnapshot = _pinnedStaleBaseMaterialSelection;
    final displayedCustomOptions = [
      ...customOptions,
      if (isCurrentSelectionMissing && selectedSnapshot != pinnedSnapshot)
        selectedSnapshot,
      if (pinnedSnapshot != null && !customOptions.contains(pinnedSnapshot))
        pinnedSnapshot,
    ];
    String optionLabel(BaseMaterialSelection selection) =>
        _baseMaterialsLoaded && selection == pinnedSnapshot
        ? '${selection.label}${strings.calcAsSavedSuffix}'
        : selection.label;

    return InputPanelSection(
      icon: Icons.layers_outlined,
      title: strings.baseMaterialTitle,
      subtitle: strings.calcBaseMaterialSectionSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PickerField(
            label: strings.baseMaterialTitle,
            title: _baseMaterialSelection == null
                ? strings.calcBaseMaterialNotSpecifiedOption
                : optionLabel(_baseMaterialSelection!),
            subtitle: _baseMaterialSelection?.material.designation,
            onTap: () async {
              final catalogByGroup =
                  <String, List<PickerOption<BaseMaterialSelection?>>>{};
              for (final entry in BaseMaterialCatalog.entries) {
                catalogByGroup
                    .putIfAbsent(entry.group, () => [])
                    .add(
                      PickerOption(
                        value: BaseMaterialSelection(entry.toMaterial()),
                        title: entry.name,
                        subtitle: '${entry.standard} · ${entry.description}',
                        group: baseMaterialGroupLabel(strings, entry.group),
                      ),
                    );
              }
              final picked = await showSearchablePicker<BaseMaterialSelection?>(
                context,
                title: strings.baseMaterialTitle,
                selected: _baseMaterialSelection,
                options: [
                  PickerOption(
                    value: null,
                    title: strings.calcBaseMaterialNotSpecifiedOption,
                  ),
                  for (final selection in displayedCustomOptions)
                    PickerOption(
                      value: selection,
                      title: optionLabel(selection),
                      subtitle: selection.material.designation,
                      group: strings.calcMyMaterialsHeader,
                    ),
                  for (final group in BaseMaterialCatalog.groupOrder)
                    ...?catalogByGroup[group],
                ],
              );
              if (picked == null || !mounted) return;
              setState(() => _baseMaterialSelection = picked.value);
            },
          ),
          if (_baseMaterialSelection != null) ...[
            const SizedBox(height: 12),
            PanelNote(
              icon: Icons.verified_outlined,
              text: strings.calcSelectedBaseMaterialNote.replaceFirst(
                '{value}',
                _baseMaterialSelection!.material.designation.trim().isEmpty
                    ? _baseMaterialSelection!.label
                    : '${_baseMaterialSelection!.label} '
                          '(${_baseMaterialSelection!.material.designation})',
              ),
            ),
          ] else if (_baseMaterialsLoaded &&
              displayedCustomOptions.isEmpty) ...[
            const SizedBox(height: 12),
            PanelNote(
              icon: Icons.info_outline,
              text: strings.calcBaseMaterialEmptyLibraryHint,
            ),
          ],
        ],
      ),
    );
  }

  /// Extracted so the mobile wizard's consumable step can reuse the exact
  /// same section as the desktop [_buildInputParametersCard].
  Widget _buildRateBasisSection(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    return InputPanelSection(
      icon: Icons.speed_outlined,
      title: strings.calcRateBasisTitle,
      subtitle: strings.calcRateBasisSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final mode in DepositionRateMode.values)
                _buildSelectionChip(
                  label: mode.labelFor(strings),
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
                ? _manualRateHelperText(strings)
                : _presetRateHelperText(strings),
          ),
        ],
      ),
    );
  }

  Widget _buildInputParametersCard(
    BuildContext context,
    List<InputFieldSpec> visibleFields,
    List<ConsumablePreset> availableConsumables,
  ) {
    final strings = AppLocaleScope.stringsOf(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.calcInputParametersTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              strings.calcInputParametersSubtitle
                  .replaceFirst(
                    '{density}',
                    '${WeldingDefaults.densityGPerCm3}',
                  )
                  .replaceFirst(
                    '{waste}',
                    '${WeldingDefaults.wasteFactorPercent}',
                  ),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF5E7380)),
            ),
            const SizedBox(height: 16),
            _buildStarterPresetSection(context),
            const SizedBox(height: 14),
            _buildConsumableClassificationSection(
              context,
              availableConsumables,
            ),
            const SizedBox(height: 14),
            _buildBaseMaterialSection(context),
            const SizedBox(height: 14),
            _buildRateBasisSection(context),
            const SizedBox(height: 14),
            InputPanelSection(
              icon: Icons.straighten_outlined,
              title: strings.calcDimensionalInputsTitle,
              subtitle: strings.calcDimensionalInputsSubtitle,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 700;
                  final fieldWidth = wide
                      ? (constraints.maxWidth - 16) / 2
                      : constraints.maxWidth;

                  Widget buildFieldsContainer(List<InputFieldSpec> fields) {
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
                          for (final field in fields)
                            SizedBox(
                              width: fieldWidth,
                              child: _buildFieldInput(field),
                            ),
                        ],
                      ),
                    );
                  }

                  final capFields = visibleFields
                      .where(
                        (spec) => _capDimensionFieldKeys.contains(spec.key),
                      )
                      .toList();
                  final otherFields = visibleFields
                      .where(
                        (spec) => !_capDimensionFieldKeys.contains(spec.key),
                      )
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildFieldsContainer(otherFields),
                      if (capFields.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            key: ValueKey('cap-$_capSectionToken'),
                            initiallyExpanded: _hasCapDimensionValues,
                            tilePadding: EdgeInsets.zero,
                            childrenPadding: const EdgeInsets.only(top: 10),
                            title: Text(
                              strings.calcCapDimensionsGroupTitle,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            children: [buildFieldsContainer(capFields)],
                          ),
                        ),
                      ],
                    ],
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
    final strings = AppLocaleScope.stringsOf(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.calcRunEstimateTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              strings.calcRunEstimateSubtitle,
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
                    label: Text(strings.commonCalculate),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetFields,
                    icon: const Icon(Icons.refresh_outlined),
                    label: Text(strings.commonReset),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isUserPresetBusy ? null : _saveCurrentAsUserPreset,
                icon: _isUserPresetBusy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.bookmark_add_outlined),
                label: Text(_saveAsPresetButtonLabel(strings)),
              ),
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
                          ? strings.calcPdfHintBeforeResult
                          : strings.calcPdfHintAfterResult,
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
                consumableSelection: _consumableSelection,
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
    final strings = AppLocaleScope.stringsOf(context);
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
                    onPressed: () => setState(() => _showResultsScreen = false),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: strings.calcEditInputsTooltip,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      strings.calcResultsTitle,
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
                  label: Text(strings.calcEditInputsButton),
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

  // Which of _visibleFieldSpecs' keys belong on the wizard's Dimensions
  // step vs. its Consumable step. Must stay in sync if _visibleFieldSpecs'
  // branching changes -- fields not in this set default to the consumable
  // step (see _wizardConsumableFields), so nothing silently disappears.
  static const Set<FieldKey> _wizardDimensionFieldKeys = {
    FieldKey.quantity,
    FieldKey.lengthMm,
    FieldKey.pipeOdMm,
    FieldKey.pipeOdAMm,
    FieldKey.pipeOdBMm,
    FieldKey.thicknessMm,
    FieldKey.thicknessAMm,
    FieldKey.thicknessBMm,
    FieldKey.rootGapMm,
    FieldKey.rootFaceMm,
    FieldKey.bevelAngleDeg,
    FieldKey.secondaryBevelAngleDeg,
    FieldKey.breakHeightMm,
    FieldKey.capOverlapMm,
    FieldKey.capHeightMm,
    FieldKey.legSizeMm,
  };

  // Plausibility ceilings for the dimension-entry fields above, so an
  // obvious typo (e.g. 500 mm keyed in where 50 mm was meant) is rejected
  // with a clear error instead of silently accepted. Deliberately generous
  // -- each one sits well above the largest values seen in real heavy-
  // industrial welding, so no genuinely unusual-but-real input is blocked.
  static const Map<FieldKey, double> _dimensionMaxBounds = {
    // Large-diameter line pipe/pressure-vessel nozzles run into the 1-2 m
    // range; 3000 mm leaves headroom above that.
    FieldKey.pipeOdMm: 3000,
    FieldKey.pipeOdAMm: 3000,
    FieldKey.pipeOdBMm: 3000,
    // Heavy pressure-vessel/forged wall sections rarely exceed a few
    // hundred mm; 500 mm is roughly 2x that.
    FieldKey.thicknessMm: 500,
    FieldKey.thicknessAMm: 500,
    FieldKey.thicknessBMm: 500,
    // Real root gaps run 0-6 mm; even a generously wide repair-weld
    // fit-up rarely exceeds ~25 mm, so 50 mm already doubles that.
    FieldKey.rootGapMm: 50,
    // Root face (land) is a fraction of thickness; 100 mm covers even
    // very thick-section allowances.
    FieldKey.rootFaceMm: 100,
    // A bevel angle is a physical angle and can never reach/exceed 180
    // degrees. WeldCalculator's groove-specific checks already cap this
    // tighter (<90 deg for V-groove types), but bounding it here too
    // rejects a bad value before any groove-specific math runs.
    FieldKey.bevelAngleDeg: 180,
    FieldKey.secondaryBevelAngleDeg: 180,
    // Bounded by the same reasoning as thickness above -- break height
    // can never exceed the plate-thickness ceiling.
    FieldKey.breakHeightMm: 500,
    // Cap reinforcement passes add a few mm at most; 100 mm is generous.
    FieldKey.capOverlapMm: 100,
    FieldKey.capHeightMm: 100,
    // Heavy structural/shipbuilding fillets can reach several tens of mm;
    // 200 mm leaves ample headroom above that.
    FieldKey.legSizeMm: 200,
  };

  List<InputFieldSpec> _wizardDimensionFields(L10nStrings strings) =>
      _visibleFieldSpecs(
        strings,
      ).where((spec) => _wizardDimensionFieldKeys.contains(spec.key)).toList();

  List<InputFieldSpec> _wizardConsumableFields(L10nStrings strings) =>
      _visibleFieldSpecs(
        strings,
      ).where((spec) => !_wizardDimensionFieldKeys.contains(spec.key)).toList();

  // Cap-pass fields ("Kapak Ölçüleri") get their own collapsible sub-section
  // within the Dimensions step/card -- they're optional and contribute
  // nothing to the calculation when empty, unlike every other dimension.
  static const Set<FieldKey> _capDimensionFieldKeys = {
    FieldKey.capOverlapMm,
    FieldKey.capHeightMm,
  };

  List<InputFieldSpec> _primaryDimensionFields(L10nStrings strings) =>
      _wizardDimensionFields(
        strings,
      ).where((spec) => !_capDimensionFieldKeys.contains(spec.key)).toList();

  List<InputFieldSpec> _capDimensionFields(L10nStrings strings) =>
      _wizardDimensionFields(
        strings,
      ).where((spec) => _capDimensionFieldKeys.contains(spec.key)).toList();

  // Auto-expand the collapsed-by-default cap section when a loaded saved
  // calculation (or a starter template) already carries cap values -- so
  // the user isn't left wondering "where did my cap values go".
  bool get _hasCapDimensionValues =>
      _controllers[FieldKey.capOverlapMm]!.text.trim().isNotEmpty ||
      _controllers[FieldKey.capHeightMm]!.text.trim().isNotEmpty;

  // Which _buildCalculationBasis() labels recap under the wizard's summary
  // "Dimensions" card. Anything not in this set (besides 'Process', which
  // gets its own card) falls through to the "Consumable" recap card -- see
  // _wizardConsumableRecapItems -- so a future basis item is never silently
  // dropped from the summary.
  static const Set<BasisKey> _wizardDimensionBasisKeys = {
    BasisKey.joint,
    BasisKey.geometry,
    BasisKey.alignment,
    BasisKey.groove,
    BasisKey.quantity,
    BasisKey.weldLengthPerPiece,
    BasisKey.pipeOd,
    BasisKey.thickness,
    BasisKey.thicknessA,
    BasisKey.thicknessB,
    BasisKey.controllingThickness,
    BasisKey.odA,
    BasisKey.odB,
    BasisKey.referenceOd,
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
  };

  // Keys that recap under the wizard's "Process" summary card -- these
  // belong there rather than falling through to Consumable because the
  // Preset Workspace UI they describe lives on the Process step.
  static const Set<BasisKey> _wizardProcessBasisKeys = {
    BasisKey.process,
    BasisKey.inputPreset,
    BasisKey.savedPreset,
  };

  List<CalculationBasisItem> get _wizardProcessRecapItems =>
      _buildCalculationBasis()
          .where((item) => _wizardProcessBasisKeys.contains(item.key))
          .toList();

  List<CalculationBasisItem> get _wizardDimensionsRecapItems =>
      _buildCalculationBasis()
          .where((item) => _wizardDimensionBasisKeys.contains(item.key))
          .toList();

  List<CalculationBasisItem> get _wizardConsumableRecapItems =>
      _buildCalculationBasis()
          .where(
            (item) =>
                !_wizardProcessBasisKeys.contains(item.key) &&
                !_wizardDimensionBasisKeys.contains(item.key),
          )
          .toList();

  Widget _buildRecapChips(List<CalculationBasisItem> items) {
    final strings = AppLocaleScope.stringsOf(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final item in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FBFD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDCE5EB)),
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Color(0xFF15232D), fontSize: 13),
                children: [
                  TextSpan(
                    text: '${item.key.labelFor(strings)}: ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: item.localizedValue),
                ],
              ),
            ),
          ),
      ],
    );
  }

  List<InputFieldSpec> _visibleFieldSpecs(L10nStrings strings) {
    final specs = <InputFieldSpec>[
      InputFieldSpec(
        key: FieldKey.quantity,
        label: strings.calcFieldQuantityLabel,
        helperText: strings.calcFieldQuantityHelper,
      ),
    ];

    if (_jointType == JointType.plateButt || _jointType == JointType.fillet) {
      specs.add(
        InputFieldSpec(
          key: FieldKey.lengthMm,
          label: strings.calcFieldWeldLengthLabel,
          helperText: strings.calcFieldWeldLengthHelper,
        ),
      );
    }

    if (_jointType == JointType.pipeButt) {
      if (_isUnequalGeometry) {
        specs.addAll([
          InputFieldSpec(
            key: FieldKey.pipeOdAMm,
            label: strings.calcFieldPipeOdALabel,
            helperText: strings.calcFieldPipeOdAHelper,
          ),
          InputFieldSpec(
            key: FieldKey.pipeOdBMm,
            label: strings.calcFieldPipeOdBLabel,
            helperText: strings.calcFieldPipeOdBHelper,
          ),
        ]);
      } else {
        specs.add(
          InputFieldSpec(
            key: FieldKey.pipeOdMm,
            label: strings.calcFieldPipeOdLabel,
            helperText: strings.calcFieldPipeOdHelper,
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
        specs.addAll([
          InputFieldSpec(
            key: FieldKey.thicknessAMm,
            label: strings.calcFieldThicknessALabel,
            helperText: strings.calcFieldThicknessAHelper,
          ),
          InputFieldSpec(
            key: FieldKey.thicknessBMm,
            label: strings.calcFieldThicknessBLabel,
            helperText: strings.calcFieldThicknessBHelper,
          ),
          InputFieldSpec(
            key: FieldKey.rootGapMm,
            label: strings.calcFieldRootGapLabel,
            helperText: strings.calcFieldRootGapHelper,
          ),
        ]);
      } else {
        specs.addAll([
          InputFieldSpec(
            key: FieldKey.thicknessMm,
            label: strings.calcFieldThicknessLabel,
            helperText: strings.calcFieldThicknessHelper,
          ),
          InputFieldSpec(
            key: FieldKey.rootGapMm,
            label: strings.calcFieldRootGapLabel,
            helperText: strings.calcFieldRootGapHelper,
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
              ? strings.calcFieldRootFacePerSideLabel
              : strings.calcFieldRootFaceLabel,
          helperText: _grooveType == GrooveType.doubleV
              ? strings.calcFieldRootFacePerSideHelper
              : strings.calcFieldRootFaceHelper,
        ),
      );
      specs.add(
        InputFieldSpec(
          key: FieldKey.bevelAngleDeg,
          label: strings.calcFieldBevelAngleLabel,
          helperText: strings.calcFieldBevelAngleHelper,
        ),
      );
    }

    if (_grooveType == GrooveType.compoundV) {
      specs.addAll([
        InputFieldSpec(
          key: FieldKey.rootFaceMm,
          label: strings.calcFieldRootFaceLabel,
          helperText: strings.calcFieldRootFaceHelper,
        ),
        InputFieldSpec(
          key: FieldKey.bevelAngleDeg,
          label: strings.calcFieldPrimaryAngleLabel,
          helperText: strings.calcFieldPrimaryAngleHelper,
        ),
        InputFieldSpec(
          key: FieldKey.secondaryBevelAngleDeg,
          label: strings.calcFieldSecondaryAngleLabel,
          helperText: strings.calcFieldSecondaryAngleHelper,
        ),
        InputFieldSpec(
          key: FieldKey.breakHeightMm,
          label: strings.calcFieldBreakHeightLabel,
          helperText: strings.calcFieldBreakHeightHelper,
        ),
      ]);
    }

    if (_grooveType == GrooveType.square ||
        _grooveType == GrooveType.singleV ||
        _grooveType == GrooveType.halfV ||
        _grooveType == GrooveType.compoundV ||
        _grooveType == GrooveType.doubleV) {
      specs.addAll([
        InputFieldSpec(
          key: FieldKey.capOverlapMm,
          label: strings.calcFieldCapOverlapLabel,
          helperText: _grooveType == GrooveType.doubleV
              ? strings.calcFieldCapOverlapDoubleVHelper
              : strings.calcFieldCapOverlapHelper,
        ),
        InputFieldSpec(
          key: FieldKey.capHeightMm,
          label: strings.calcFieldCapHeightLabel,
          helperText: _grooveType == GrooveType.doubleV
              ? strings.calcFieldCapHeightDoubleVHelper
              : strings.calcFieldCapHeightHelper,
        ),
      ]);
    }

    if (_grooveType == GrooveType.fillet) {
      specs.add(
        InputFieldSpec(
          key: FieldKey.legSizeMm,
          label: strings.calcFieldLegSizeLabel,
          helperText: strings.calcFieldLegSizeHelper,
        ),
      );
    }

    if (_weldingProcess == WeldingProcess.gtaw) {
      specs.add(
        InputFieldSpec.diameter(
          key: FieldKey.wireDiameterMm,
          label: strings.calcFieldGtawWireDiameterLabel,
          helperText: strings.calcFieldGtawWireDiameterHelper,
          diameterOptions: const [
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
        InputFieldSpec.diameter(
          key: FieldKey.electrodeDiameterMm,
          label: strings.calcFieldSmawElectrodeDiameterLabel,
          helperText: strings.calcFieldSmawElectrodeDiameterHelper,
          diameterOptions: const [
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
              ? strings.calcFieldGmawWireDiameterLabel
              : strings.calcFieldFcawWireDiameterLabel,
          helperText: _weldingProcess == WeldingProcess.gmaw
              ? strings.calcFieldGmawWireDiameterHelper
              : strings.calcFieldFcawWireDiameterHelper,
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
      specs.addAll([
        InputFieldSpec(
          key: FieldKey.gtawTransitionMm,
          label: strings.calcFieldGtawTransitionLabel,
          helperText: strings.calcFieldGtawTransitionHelper,
        ),
        InputFieldSpec.diameter(
          key: FieldKey.gtawWireDiameterMm,
          label: strings.calcFieldGtawWireDiameterLabel,
          helperText: strings.calcFieldGtawWireDiameterHelper,
          diameterOptions: const [
            DiameterPresetOption(label: '1.6 mm', value: 1.6),
            DiameterPresetOption(label: '2.0 mm', value: 2.0),
            DiameterPresetOption(label: '2.4 mm', value: 2.4),
            DiameterPresetOption(label: '3.2 mm', value: 3.2),
          ],
        ),
        InputFieldSpec.diameter(
          key: FieldKey.smawElectrodeDiameterMm,
          label: strings.calcFieldSmawElectrodeDiameterLabel,
          helperText: strings.calcFieldSmawElectrodeDiameterHelper,
          diameterOptions: const [
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
        specs.addAll([
          InputFieldSpec(
            key: FieldKey.manualGtawRateKgPerHour,
            label: strings.calcFieldGtawDepositionRateLabel,
            helperText: strings.calcFieldGtawDepositionRateHelper,
          ),
          InputFieldSpec(
            key: FieldKey.manualSmawRateKgPerHour,
            label: strings.calcFieldSmawDepositionRateLabel,
            helperText: strings.calcFieldSmawDepositionRateHelper,
          ),
        ]);
      } else {
        specs.add(
          InputFieldSpec(
            key: FieldKey.manualDepositionRateKgPerHour,
            label: strings.calcFieldDepositionRateLabel,
            helperText: strings.calcFieldDepositionRateHelper,
          ),
        );
      }
    }

    specs.addAll([
      InputFieldSpec(
        key: FieldKey.density,
        label: strings.calcFieldDensityLabel,
        helperText: strings.calcFieldDensityHelper,
      ),
      InputFieldSpec(
        key: FieldKey.wasteFactor,
        label: strings.calcFieldWasteAllowanceLabel,
        helperText: strings.calcFieldWasteAllowanceHelper,
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

  String _processRateSummary(
    L10nStrings strings,
    double efficiency,
    double depositionRate,
  ) {
    final sourceText = _depositionRateMode.labelFor(strings);

    if (_weldingProcess == WeldingProcess.gtawSmaw) {
      final gtawUpTo = _formatNumber(
        _parsePreviewValue(FieldKey.gtawTransitionMm) ?? 3,
        1,
      );
      final gtawSetting = _depositionRateMode == DepositionRateMode.manual
          ? '${_formatNumber(_parsePreviewValue(FieldKey.manualGtawRateKgPerHour) ?? WeldingDefaults.depositionRateFor(WeldingProcess.gtaw), 2)} kg/h'
          : '${_formatNumber(_parsePreviewValue(FieldKey.gtawWireDiameterMm) ?? 2.4, 1)} mm ${strings.calcWireUnitSuffix}';
      final smawSetting = _depositionRateMode == DepositionRateMode.manual
          ? '${_formatNumber(_parsePreviewValue(FieldKey.manualSmawRateKgPerHour) ?? WeldingDefaults.depositionRateFor(WeldingProcess.smaw), 2)} kg/h'
          : '${_formatNumber(_parsePreviewValue(FieldKey.smawElectrodeDiameterMm) ?? 3.2, 1)} mm ${strings.calcElectrodeUnitSuffix}';
      return '${strings.calcRateBasisLabel} $sourceText | ${strings.calcGtawTransitionDepthLabel} $gtawUpTo mm, ${strings.calcThenSmawSuffix} | ${strings.calcDepositionEfficiencyLabel} ${_formatPercent(efficiency)} | ${strings.calcEquivalentDepositionRateLabel} ${_formatNumber(depositionRate, 2)} kg/h | GTAW $gtawSetting | SMAW $smawSetting';
    }

    final detailText = _depositionRateMode == DepositionRateMode.manual
        ? ' | ${strings.calcUserDefinedLabel} ${_formatNumber(_parsePreviewValue(FieldKey.manualDepositionRateKgPerHour) ?? WeldingDefaults.depositionRateFor(_weldingProcess), 2)} kg/h'
        : switch (_weldingProcess) {
            WeldingProcess.gtaw =>
              ' | ${strings.calcWireLabel} ${_formatNumber(_parsePreviewValue(FieldKey.wireDiameterMm) ?? 2.4, 1)} mm',
            WeldingProcess.smaw =>
              ' | ${strings.calcElectrodeLabel} ${_formatNumber(_parsePreviewValue(FieldKey.electrodeDiameterMm) ?? 3.2, 1)} mm',
            WeldingProcess.gmaw =>
              ' | ${strings.calcWireLabel} ${_formatNumber(_parsePreviewValue(FieldKey.wireDiameterMm) ?? 1.2, 1)} mm',
            WeldingProcess.fcaw =>
              ' | ${strings.calcWireLabel} ${_formatNumber(_parsePreviewValue(FieldKey.wireDiameterMm) ?? 1.6, 1)} mm',
            WeldingProcess.gtawSmaw => '',
          };
    return '${strings.calcRateBasisLabel} $sourceText | ${strings.calcDepositionEfficiencyLabel} ${_formatPercent(efficiency)} | ${strings.calcDepositionRateLabel} ${_formatNumber(depositionRate, 2)} kg/h$detailText';
  }

  String _unequalGeometrySummary(L10nStrings strings) {
    if (!_isUnequalGeometry) return '';

    final thickness = _governingThicknessPreview;
    final od = _governingPipeOdPreview;
    final thicknessText = thickness == null
        ? ''
        : '${strings.calcUnequalJointLabel} | ${strings.calcGoverningThicknessLabel} ${_formatNumber(thickness, 1)} mm | ';
    final odText = _jointType == JointType.pipeButt && od != null
        ? '${strings.basisReferenceOd} ${_formatNumber(od, 1)} mm | ${_jointAlignment.labelFor(strings)} | '
        : _jointType == JointType.plateButt
        ? '${_jointAlignment.labelFor(strings)} | '
        : '';
    return '$thicknessText$odText';
  }

  String _presetRateHelperText(L10nStrings strings) {
    if (_weldingProcess == WeldingProcess.gtawSmaw) {
      return strings.calcPresetRateHelperGtawSmaw;
    }

    return strings.calcPresetRateHelperDefault;
  }

  String _manualRateHelperText(L10nStrings strings) {
    if (_weldingProcess == WeldingProcess.gtawSmaw) {
      return strings.calcManualRateHelperGtawSmaw;
    }

    return strings.calcManualRateHelperDefault;
  }

  // Only force-switches away from a built-in selection the new process
  // doesn't support -- a custom material selection is left alone on
  // process change, since custom materials aren't process-filtered (see
  // coder task decision #4).
  void _syncConsumableForProcess() {
    final selection = _consumableSelection;
    if (selection is CustomConsumableSelection) {
      final entry = ConsumableCatalog.byId(selection.material.id);
      if (entry != null && !entry.processes.contains(_weldingProcess)) {
        _consumableSelection = BuiltInConsumableSelection(
          WeldingDefaults.defaultConsumableFor(_weldingProcess),
        );
      }
    }
    if (selection is BuiltInConsumableSelection) {
      final available = WeldingDefaults.consumablesFor(_weldingProcess);
      if (!available.contains(selection.preset)) {
        _consumableSelection = BuiltInConsumableSelection(
          WeldingDefaults.defaultConsumableFor(_weldingProcess),
        );
      }
    }
    _applyConsumableSelection(_consumableSelection);
  }

  /// Single source of truth for whether Save takes the in-place-update
  /// path, shared by the button label and _saveCurrentAsUserPreset's
  /// branch so they can't disagree (see finding #5) -- true once this
  /// state was loaded from (and hasn't been navigated away from) an
  /// existing saved preset that's still resolvable and has an account.
  bool get _isUpdatingSelectedUserPreset =>
      _selectedUserPresetId != null &&
      _selectedUserPreset != null &&
      _accountEmail != null;

  String _saveAsPresetButtonLabel(L10nStrings strings) =>
      _isUpdatingSelectedUserPreset
      ? strings.calcUpdateSavedCalculationLabel
      : strings.calcSaveAsPresetLabel;

  UserWeldPreset? get _selectedUserPreset {
    final presetId = _selectedUserPresetId;
    if (presetId == null) return null;
    for (final preset in _userPresets) {
      if (preset.id == presetId) return preset;
    }
    return null;
  }

  Future<void> _loadUserPresets() async {
    final email = _accountEmail;
    if (email == null) {
      // Guests don't get a preset list -- saving prompts for an email and
      // that turns them into an account (see _saveCurrentAsUserPreset).
      if (!mounted) return;
      setState(() {
        _userPresets = const [];
        _selectedUserPresetId = null;
      });
      return;
    }

    final result = await loadSyncedUserPresets(
      email: email,
      presetSyncService: _presetSyncService,
      userPresetStore: _userPresetStore,
    );
    final presets = result.presets;
    final skippedCount = result.skippedCount;

    if (!mounted) return;
    setState(() {
      _userPresets = presets;
      if (_selectedUserPresetId != null &&
          !_userPresets.any((preset) => preset.id == _selectedUserPresetId)) {
        _selectedUserPresetId = null;
      }
    });
    if (skippedCount > 0) {
      _showMessage(
        AppLocaleScope.stringsOf(context).savedCalculationsSkippedWarning
            .replaceFirst('{count}', '$skippedCount'),
      );
    }
  }

  Future<void> _applyInputPreset(
    BuildContext context,
    InputPreset preset,
  ) async {
    final data = preset.data;
    if (data == null) return;

    if (data.weldingProcess != _weldingProcess) {
      final confirmed = await _confirmPresetProcessSwitch(
        context,
        presetProcess: data.weldingProcess,
        currentProcess: _weldingProcess,
      );
      if (!mounted) return;
      if (confirmed != true) {
        setState(() => _starterPresetDropdownResetToken++);
        return;
      }
    }

    setState(() {
      _inputPreset = preset;
      _selectedUserPresetId = null;
      _applyPresetData(data, usePresetDiameters: true);
      _result = null;
    });
  }

  /// Shown when a starter preset picked from the Dimensions-step dropdown
  /// would silently switch away from the welding process the user already
  /// chose on step 1. Only asked when the preset's process actually
  /// conflicts with the current selection -- see call site.
  Future<bool?> _confirmPresetProcessSwitch(
    BuildContext context, {
    required WeldingProcess presetProcess,
    required WeldingProcess currentProcess,
  }) {
    final strings = AppLocaleScope.stringsOf(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.presetProcessSwitchConfirmTitle),
        content: Text(
          strings.presetProcessSwitchConfirmBody
              .replaceFirst('{presetProcess}', presetProcess.label)
              .replaceFirst('{currentProcess}', currentProcess.label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              strings.presetProcessSwitchConfirmKeepButton.replaceFirst(
                '{currentProcess}',
                currentProcess.label,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              strings.presetProcessSwitchConfirmSwitchButton.replaceFirst(
                '{presetProcess}',
                presetProcess.label,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Only called from initState now that the inline "My Saved Presets"
  // dropdown is gone -- deliberately not wrapped in setState, since
  // initState runs before this element's first build and calling setState
  // there is unsafe (see the call site in initState).
  void _applyUserPreset(UserWeldPreset preset) {
    _inputPreset = InputPreset.custom;
    _selectedUserPresetId = preset.id;
    _applyPresetData(preset.data, usePresetDiameters: false);
    _result = null;
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
    _consumableSelection = data.consumableSelection;
    // Loading a real saved calculation (usePresetDiameters: false, via
    // _applyUserPreset) must fully overwrite the base material -- including
    // clearing it -- to match what the user actually had saved, same as the
    // cap-dimension fields (see _clearCapDimensionFields). A built-in
    // starter TEMPLATE (usePresetDiameters: true) is different: it's a
    // fixed geometry/process catalog entry with no opinion on base metal
    // (its own WeldInputPresetData.baseMaterialSelection is always null),
    // so overwriting here would silently wipe out a base material the user
    // had already picked before applying the template. Preserve it instead.
    if (!usePresetDiameters) {
      _baseMaterialSelection = data.baseMaterialSelection;
    }

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
    // Cap fields are optional/nullable and _setControllerValue no-ops on
    // null, so a preset/template with no cap values (e.g. every built-in
    // InputPreset) must explicitly clear these, or a stale value typed
    // before applying the preset survives onto the "clean" template.
    _clearCapDimensionFields();
    _setControllerValue(FieldKey.capOverlapMm, data.capOverlapMm);
    _setControllerValue(FieldKey.capHeightMm, data.capHeightMm);
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
    if (_isUpdatingSelectedUserPreset) {
      await _updateSelectedUserPreset(
        _accountEmail!,
        _selectedUserPresetId!,
        _selectedUserPreset!.name,
      );
      return;
    }

    var email = _accountEmail;
    String name;

    if (email == null && !AuthServices.instance.available) {
      // No account backend: the preset stays on this device.
      final promptedName = await _promptPresetName();
      if (promptedName == null || promptedName.trim().isEmpty) return;
      name = promptedName.trim();
    } else if (email == null) {
      // A preset needs a verified account (cloud sync is keyed by it).
      final copy = authCopyFor(AppLocaleScope.of(context).language);
      final outcome = await showAccountPrompt(
        context,
        title: copy.saveTitle,
        body: copy.saveBody,
        entitlementService: widget.entitlementService,
      );
      if (!mounted || outcome != AuthOutcome.verified) return;
      email = await _accountStore.getEmail();
      if (email == null || !mounted) return;
      final promptedName = await _promptPresetName();
      if (promptedName == null || promptedName.trim().isEmpty) return;
      name = promptedName.trim();
      _accountEmail = email;
      // No-op (uploads nothing) if the local cache belongs to a different,
      // previously signed-in account -- see the doc comment on
      // migrateLocalPresetsToAccount. A failed upload must not be followed
      // by _loadUserPresets' cloud-authoritative refresh, or the
      // not-yet-uploaded local presets would be wiped by a cloud list that
      // doesn't reflect them yet.
      final migrated = await migrateLocalPresetsToAccount(
        email: email,
        presetSyncService: _presetSyncService,
        userPresetStore: _userPresetStore,
      );
      if (migrated) {
        await _loadUserPresets();
      } else {
        // A failed upload means the cloud list doesn't yet reflect these
        // presets -- seed from the local cache directly (not
        // _loadUserPresets, which would fetch the cloud-authoritative list
        // and wipe out anything not yet uploaded) so the save below
        // preserves what's already on disk instead of overwriting it with
        // just the new preset.
        _userPresets = (await _userPresetStore.load()).presets;
      }
    } else {
      final promptedName = await _promptPresetName();
      if (promptedName == null || promptedName.trim().isEmpty) return;
      name = promptedName.trim();
    }

    try {
      setState(() => _isUserPresetBusy = true);
      final preset = UserWeldPreset(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        data: _captureCurrentPresetData(),
      );
      final presets = [..._userPresets, preset]
        ..sort((a, b) => b.updatedAtEpochMs.compareTo(a.updatedAtEpochMs));
      // Sync failures fall back to a local-only save (mirrors
      // SavedCalculationsScreen._load's local-fallback convention) instead
      // of skipping the local write and losing the preset entirely. A
      // future successful `list()` call overwrites the local cache with
      // the cloud's copy, so a preset saved here without syncing must be
      // flagged to the user -- otherwise it can vanish silently the next
      // time presets are reloaded from the cloud.
      var syncSucceeded = email != null;
      if (email != null) {
        try {
          await _presetSyncService.save(email, preset);
        } catch (_) {
          syncSucceeded = false;
        }
      }
      await _userPresetStore.save(presets);
      if (!mounted) return;
      setState(() {
        _userPresets = presets;
        _selectedUserPresetId = preset.id;
        _inputPreset = InputPreset.custom;
      });
      final strings = AppLocaleScope.stringsOf(context);
      _showMessage(
        syncSucceeded ? strings.presetSaved : strings.presetSavedOffline,
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage(AppLocaleScope.stringsOf(context).presetSaveError);
    } finally {
      if (mounted) {
        setState(() => _isUserPresetBusy = false);
      }
    }
  }

  /// Hitting Save while this state was loaded from an existing saved
  /// calculation updates it in place under its existing name instead of
  /// prompting for a new name and appending a duplicate (see coder task
  /// decision #3 / Feature B).
  Future<void> _updateSelectedUserPreset(
    String email,
    String presetId,
    String name,
  ) async {
    try {
      setState(() => _isUserPresetBusy = true);
      final preset = UserWeldPreset(
        id: presetId,
        name: name,
        updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
        data: _captureCurrentPresetData(),
      );
      var syncSucceeded = true;
      try {
        await _presetSyncService.save(email, preset);
      } catch (_) {
        syncSucceeded = false;
      }
      // If another device deleted this preset while the save above was in
      // flight, `save`'s upsert just recreated it server-side, but the
      // list comprehension below would otherwise match nothing and drop
      // it from the local list silently -- re-add it instead (see
      // finding #4) rather than let it vanish from view.
      final presetStillExists = _userPresets.any(
        (existing) => existing.id == presetId,
      );
      final presets = [
        for (final existing in _userPresets)
          if (existing.id == presetId) preset else existing,
        if (!presetStillExists) preset,
      ]..sort((a, b) => b.updatedAtEpochMs.compareTo(a.updatedAtEpochMs));
      await _userPresetStore.save(presets);
      if (!mounted) return;
      setState(() => _userPresets = presets);
      final strings = AppLocaleScope.stringsOf(context);
      if (!presetStillExists) {
        _showMessage(
          syncSucceeded
              ? strings.presetRestored
              : strings.presetRestoredOffline,
        );
      } else {
        _showMessage(
          syncSucceeded ? strings.presetUpdated : strings.presetUpdatedOffline,
        );
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage(AppLocaleScope.stringsOf(context).presetSaveError);
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
    consumableSelection: _consumableSelection,
    depositionRateMode: _depositionRateMode,
    jointGeometryMode: _jointGeometryMode,
    jointAlignment: _jointAlignment,
    baseMaterialSelection: _baseMaterialSelection,
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
    // Fillet has no cap-reinforcement concept (calculator already zeroes
    // its contribution), but the cap controllers are only hidden -- not
    // cleared -- for Fillet, so avoid persisting stale values into the
    // saved preset JSON.
    capOverlapMm: _grooveType == GrooveType.fillet
        ? null
        : _parsePresetValue(FieldKey.capOverlapMm, 'Cap overlap'),
    capHeightMm: _grooveType == GrooveType.fillet
        ? null
        : _parsePresetValue(FieldKey.capHeightMm, 'Cap height'),
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

  Future<String?> _promptPresetName({String? initialValue}) {
    // The dialog owns its TextEditingController as a StatefulWidget field
    // rather than one disposed here right after showDialog returns --
    // disposing it in the caller races with the dialog's own exit
    // animation, which is still rebuilding that TextField for a frame or
    // two after the awaited Future completes, and crashes the framework
    // with a "used after being disposed" assertion.
    return showDialog<String>(
      context: context,
      builder: (context) => _PresetNameDialog(initialValue: initialValue),
    );
  }

  void _applyConsumableSelection(ConsumableSelection selection) {
    _controllers[FieldKey.density]!.text = selection.densityGPerCm3
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
    capOverlapMm: _parsePreviewValue(FieldKey.capOverlapMm),
    capHeightMm: _parsePreviewValue(FieldKey.capHeightMm),
    legSizeMm: _parsePreviewValue(FieldKey.legSizeMm),
    pipeOdMm: _governingPipeOdPreview,
    pipeOdAMm: _pipeOdAPreview,
    pipeOdBMm: _pipeOdBPreview,
    gtawTransitionMm: _parsePreviewValue(FieldKey.gtawTransitionMm),
  );

  Widget _buildFieldInput(
    InputFieldSpec field, {
    bool autofocus = false,
    bool shareFocusNode = true,
    VoidCallback? onEdited,
  }) {
    if (field.diameterOptions != null) {
      return _buildDiameterField(field);
    }

    return TextField(
      controller: _controllers[field.key],
      focusNode: shareFocusNode ? _fieldFocusNodes[field.key] : null,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(
        labelText: field.label,
        helperText: field.helperText,
        errorText: _fieldErrors[field.key] ?? _liveBoundError(field),
      ),
      onChanged: (_) {
        setState(() {
          _result = null;
          _fieldErrors.remove(field.key);
        });
        onEdited?.call();
      },
    );
  }

  /// Plausibility-ceiling error shown while typing (same message Calculate
  /// would raise), so the user sees it without having to calculate first.
  String? _liveBoundError(InputFieldSpec field) {
    final max = _dimensionMaxBounds[field.key];
    final value = _parseOptional(field.key);
    if (max == null || value == null || value <= max) return null;
    final unit =
        field.key == FieldKey.bevelAngleDeg ||
            field.key == FieldKey.secondaryBevelAngleDeg
        ? '°'
        : ' mm';
    return AppLocaleScope.stringsOf(context).calcFieldOutOfRangeError
        .replaceFirst('{label}', field.label)
        .replaceFirst('{max}', '${max.toStringAsFixed(0)}$unit');
  }

  Widget _buildDiameterField(InputFieldSpec field) {
    final strings = AppLocaleScope.stringsOf(context);
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
              _buildDropdownSelectedText(strings.calcCustomDiameterOption),
            ],
            items: [
              for (final option in field.diameterOptions!)
                DropdownMenuItem(
                  value: _diameterValueToken(option.value),
                  child: Text(option.label, overflow: TextOverflow.ellipsis),
                ),
              DropdownMenuItem(
                value: _customDiameterValue,
                child: Text(strings.calcCustomDiameterOption),
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
            decoration: InputDecoration(
              labelText: strings.calcCustomDiameterLabel,
              helperText: strings.calcCustomDiameterHelper,
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

  Widget _buildCompactModeSegment({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return Material(
      color: selected ? const Color(0xFF12191B) : const Color(0xFFF1F5F7),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onSelected,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xFF12191B)
                  : const Color(0xFFD6E0E6),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF29414D),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
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

  void _clearCapDimensionFields() {
    _controllers[FieldKey.capOverlapMm]!.text = '';
    _controllers[FieldKey.capHeightMm]!.text = '';
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

  // Fields the calculator treats as optional (it falls back to defaults or
  // zero); every other visible field must hold a number to calculate.
  static const _optionalFieldKeys = {
    FieldKey.capOverlapMm,
    FieldKey.capHeightMm,
    FieldKey.wireDiameterMm,
    FieldKey.electrodeDiameterMm,
    FieldKey.gtawWireDiameterMm,
    FieldKey.smawElectrodeDiameterMm,
  };

  /// Marks every visible required field that is blank/unparsable, jumps to
  /// the wizard step of the first one, scrolls it into view, focuses it and
  /// tells the user what is missing. Returns true if anything was missing.
  bool _revealMissingRequiredFields(L10nStrings strings) {
    final missing = <InputFieldSpec>[];
    final errors = <FieldKey, String>{};
    for (final field in _visibleFieldSpecs(strings)) {
      if (_optionalFieldKeys.contains(field.key)) continue;
      final text = _controllers[field.key]!.text.trim();
      if (text.isEmpty) {
        missing.add(field);
        errors[field.key] = strings.fieldRequiredShort;
      } else if (double.tryParse(text.replaceAll(',', '.')) == null) {
        missing.add(field);
        errors[field.key] = strings.materialFieldInvalidNumber;
      }
    }
    if (missing.isEmpty) return false;
    setState(() {
      _result = null;
      _fieldErrors
        ..clear()
        ..addAll(errors);
      _wizardStep = _wizardStepForFieldKey(missing.first.key);
    });
    revealAndFocus(_fieldFocusNodes[missing.first.key]!);
    showMissingFieldsSnack(context, strings, [
      for (final field in missing) field.label,
    ]);
    return true;
  }

  void _calculate() {
    final strings = AppLocaleScope.stringsOf(context);
    if (_revealMissingRequiredFields(strings)) return;
    _fieldErrors.clear();
    try {
      final input = WeldInputData(
        jointType: _jointType,
        grooveType: _grooveType,
        weldingProcess: _weldingProcess,
        depositionRateMode: _depositionRateMode,
        quantity: _parseRequired(
          FieldKey.quantity,
          strings.calcErrorLabelQuantity,
          strings,
        ),
        densityGPerCm3: _parseRequired(
          FieldKey.density,
          strings.calcErrorLabelDensity,
          strings,
        ),
        wasteFactorPercent: _parseRequired(
          FieldKey.wasteFactor,
          strings.calcErrorLabelWasteFactor,
          strings,
        ),
        lengthPerPieceMm: _parseOptional(FieldKey.lengthMm),
        pipeOdMm: _checkDimensionBound(
          _resolvePipeOdForCalculation(),
          FieldKey.pipeOdMm,
          strings.calcFieldPipeOdLabel,
          strings,
        ),
        thicknessMm: _checkDimensionBound(
          _resolveThicknessForCalculation(),
          FieldKey.thicknessMm,
          strings.calcFieldThicknessLabel,
          strings,
        ),
        rootGapMm: _checkDimensionBound(
          _parseOptional(FieldKey.rootGapMm),
          FieldKey.rootGapMm,
          strings.calcFieldRootGapLabel,
          strings,
        ),
        rootFaceMm: _checkDimensionBound(
          _parseOptional(FieldKey.rootFaceMm),
          FieldKey.rootFaceMm,
          strings.calcFieldRootFaceLabel,
          strings,
        ),
        bevelAngleDeg: _checkDimensionBound(
          _parseOptional(FieldKey.bevelAngleDeg),
          FieldKey.bevelAngleDeg,
          strings.calcFieldBevelAngleLabel,
          strings,
        ),
        secondaryBevelAngleDeg: _checkDimensionBound(
          _parseOptional(FieldKey.secondaryBevelAngleDeg),
          FieldKey.secondaryBevelAngleDeg,
          strings.calcFieldSecondaryAngleLabel,
          strings,
        ),
        breakHeightMm: _checkDimensionBound(
          _parseOptional(FieldKey.breakHeightMm),
          FieldKey.breakHeightMm,
          strings.calcFieldBreakHeightLabel,
          strings,
        ),
        capOverlapMm: _checkDimensionBound(
          _parseOptional(FieldKey.capOverlapMm),
          FieldKey.capOverlapMm,
          strings.calcFieldCapOverlapLabel,
          strings,
        ),
        capHeightMm: _checkDimensionBound(
          _parseOptional(FieldKey.capHeightMm),
          FieldKey.capHeightMm,
          strings.calcFieldCapHeightLabel,
          strings,
        ),
        legSizeMm: _checkDimensionBound(
          _parseOptional(FieldKey.legSizeMm),
          FieldKey.legSizeMm,
          strings.calcFieldLegSizeLabel,
          strings,
        ),
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
    } on _RequiredFieldMissingException catch (error) {
      final key = _visibleFieldKeyFor(error.fieldKey);
      setState(() {
        _result = null;
        _wizardStep = _wizardStepForFieldKey(key);
        _fieldErrors[key] = error.message;
        if (_capDimensionFieldKeys.contains(key)) _capSectionToken++;
      });
      revealAndFocus(_fieldFocusNodes[key]!);
      _showMessage(error.message);
    } on InputValidationException catch (error) {
      setState(() => _result = null);
      _showMessage(error.message);
    } on FormatException catch (error) {
      setState(() => _result = null);
      _showMessage(error.message);
    } catch (_) {
      setState(() => _result = null);
      _showMessage(strings.calcCalculationFailedError);
    }
  }

  /// Opens a quick-edit sheet for the dimension the user tapped on the
  /// technical drawing, so the value can be entered right there without
  /// hunting for the matching field further down the page.
  void _onDimensionFocusChanged(FieldKey key) {
    final focused = _fieldFocusNodes[key]!.hasFocus;
    if (focused && _drawingFocused != key) {
      setState(() => _drawingFocused = key);
    } else if (!focused && _drawingFocused == key) {
      setState(() => _drawingFocused = null);
    }
  }

  void _handleDrawingFieldTap(FieldKey fieldKey) {
    final strings = AppLocaleScope.stringsOf(context);
    InputFieldSpec? field;
    for (final candidate in _visibleFieldSpecs(strings)) {
      if (candidate.key == fieldKey) {
        field = candidate;
        break;
      }
    }
    if (field == null) return;
    _showQuickEditSheetKeepingScroll(field);
  }

  // Opening the keyboard for the quick-edit sheet makes the underlying
  // scrollables jump (the sheet's field used to share a FocusNode with the
  // in-page field, which scrolled that field into view), leaving the user
  // away from the drawing once the sheet closes. Snap every page scrollable
  // back to where it was so the drawing is visible again, same zoom/state.
  Future<void> _showQuickEditSheetKeepingScroll(InputFieldSpec field) async {
    final controllers = [
      _pageScrollController,
      _inputColumnScrollController,
      _drawingColumnScrollController,
    ];
    final offsets = [
      for (final c in controllers) c.hasClients ? c.offset : null,
    ];
    setState(() => _drawingSelection = field.key);
    await _showQuickEditSheet(field);
    if (!mounted) return;
    setState(() => _drawingSelection = null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var i = 0; i < controllers.length; i++) {
        final offset = offsets[i];
        final c = controllers[i];
        if (offset == null || !c.hasClients) continue;
        final target = offset.clamp(
          c.position.minScrollExtent,
          c.position.maxScrollExtent,
        );
        if ((c.offset - target).abs() > 0.5) c.jumpTo(target);
      }
    });
  }

  Future<void> _showQuickEditSheet(InputFieldSpec field) {
    final strings = AppLocaleScope.stringsOf(context);
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
                StatefulBuilder(
                  builder: (context, setSheetState) => _buildFieldInput(
                    field,
                    autofocus: true,
                    shareFocusNode: false,
                    onEdited: () => setSheetState(() {}),
                  ),
                ),
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
                    child: Text(strings.commonDone),
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
  /// export). Fetches the RevenueCat `default` offering when opened: if it's
  /// missing the expected monthly/yearly packages (the expected state until
  /// the real API key and an App Store Connect subscription product exist),
  /// the shared paywall shows a retry state instead of purchase buttons.
  Future<void> _showPaywall() {
    return showPremiumPaywall(
      context,
      entitlementService: widget.entitlementService,
      onEntitlementChanged: (isPremium) {
        if (!mounted) return;
        setState(() => _isPremium = isPremium);
      },
      onMessage: _showMessage,
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
    _clearCapDimensionFields();
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
      _pinnedStaleCustomSelection = null;
      _baseMaterialSelection = null;
      _pinnedStaleBaseMaterialSelection = null;
      _applyProcessFieldDefaults();
      _consumableSelection = BuiltInConsumableSelection(
        WeldingDefaults.defaultConsumableFor(_weldingProcess),
      );
      _applyConsumableSelection(_consumableSelection);
      _result = null;
      _wizardStep = WizardStep.process;
    });
    _resetWizardScroll();
  }

  /// Unequal-geometry mode validates the governing (larger) of the A/B
  /// values under the single thickness/OD key, but only the A/B fields are
  /// on screen -- point the error at the one that actually caused it.
  FieldKey _visibleFieldKeyFor(FieldKey key) {
    if (!_isUnequalGeometry) return key;
    final pair = switch (key) {
      FieldKey.thicknessMm => (FieldKey.thicknessAMm, FieldKey.thicknessBMm),
      FieldKey.pipeOdMm => (FieldKey.pipeOdAMm, FieldKey.pipeOdBMm),
      _ => null,
    };
    if (pair == null) return key;
    final a = _parseOptional(pair.$1) ?? double.negativeInfinity;
    final b = _parseOptional(pair.$2) ?? double.negativeInfinity;
    return a >= b ? pair.$1 : pair.$2;
  }

  double _parseRequired(FieldKey key, String label, L10nStrings strings) {
    final value = _controllers[key]!.text.trim();
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) {
      throw _RequiredFieldMissingException(
        key,
        strings.calcFieldRequiredError.replaceFirst('{label}', label),
      );
    }
    return parsed;
  }

  // Same dimensions-vs-consumable split used to build the wizard's step
  // field lists (_wizardDimensionFields / _wizardConsumableFields), reused
  // here so a validation failure can send the user back to the step that
  // actually owns the offending field.
  WizardStep _wizardStepForFieldKey(FieldKey key) =>
      _wizardDimensionFieldKeys.contains(key)
      ? WizardStep.dimensions
      : WizardStep.consumable;

  double? _parseOptional(FieldKey key) {
    final value = _controllers[key]!.text.trim();
    if (value.isEmpty) return null;
    return double.tryParse(value.replaceAll(',', '.'));
  }

  /// Rejects a physically-implausible dimension value against
  /// [_dimensionMaxBounds] instead of silently accepting it -- see that
  /// map's comment for the reasoning behind each ceiling. Fields with no
  /// entry there (or no value at all) pass through unchanged.
  double? _checkDimensionBound(
    double? value,
    FieldKey key,
    String label,
    L10nStrings strings,
  ) {
    final max = _dimensionMaxBounds[key];
    if (value == null || max == null || value <= max) return value;
    final unit =
        key == FieldKey.bevelAngleDeg || key == FieldKey.secondaryBevelAngleDeg
        ? '°'
        : ' mm';
    throw _RequiredFieldMissingException(
      key,
      strings.calcFieldOutOfRangeError
          .replaceFirst('{label}', label)
          .replaceFirst('{max}', '${max.toStringAsFixed(0)}$unit'),
    );
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

  // Guarded here rather than at each call site so every caller -- including
  // the paywall sheet's `onMessage` callback, which can fire after this
  // page's own async work outlives the sheet -- is protected by
  // construction instead of relying on each new call site remembering to
  // check `mounted` itself.
  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _exportPdf() async {
    final result = _result;
    if (result == null || _isExportingPdf) return;

    final strings = AppLocaleScope.stringsOf(context);
    final pdfStrings = pdfExportStringsFor(AppLocaleScope.of(context).language);
    final basisEntries = _buildCalculationBasis(stringsOverride: pdfStrings);

    setState(() => _isExportingPdf = true);
    try {
      final report = await _pdfReportService.buildReport(
        jointType: _jointType,
        grooveType: _grooveType,
        weldingProcess: _weldingProcess,
        consumableSelection: _consumableSelection,
        result: result,
        basisEntries: basisEntries,
        strings: pdfStrings,
      );
      await exportPdfReport(report.bytes, report.fileName);
      // Persisting the report to local history is best-effort and must
      // never turn a successful export into a user-visible failure.
      try {
        await _savedReportStore.add(
          SavedReport(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            fileName: report.fileName,
            generatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
            pdfBytesBase64: base64Encode(report.bytes),
          ),
        );
      } catch (error) {
        debugPrint('Failed to save PDF report to history: $error');
      }
      if (!mounted) return;
      _showMessage(strings.pdfExportSuccessToast);
    } catch (_) {
      if (!mounted) return;
      _showMessage(strings.pdfExportFailureToast);
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

  // [stringsOverride] lets the PDF export path (which falls back to English
  // for Hindi -- the `pdf` package has no Indic complex-script shaping) bake
  // the basis items' localizedValue strings from the override instead of the
  // live UI locale.
  List<CalculationBasisItem> _buildCalculationBasis({
    L10nStrings? stringsOverride,
  }) {
    final strings = stringsOverride ?? AppLocaleScope.stringsOf(context);
    final items = <CalculationBasisItem>[
      // WeldingProcess.label is never localized (GTAW/SMAW/etc. are
      // international AWS process abbreviations) -- no localizedValue needed.
      CalculationBasisItem(BasisKey.process, 'Process', _weldingProcess.label),
      CalculationBasisItem(
        BasisKey.rateBasis,
        'Rate Basis',
        _depositionRateMode.label,
        _depositionRateMode.labelFor(strings),
      ),
      if (_inputPreset != InputPreset.custom)
        CalculationBasisItem(
          BasisKey.inputPreset,
          'Input Preset',
          _inputPreset.label,
          _inputPreset.labelFor(strings),
        ),
      if (_selectedUserPreset != null)
        CalculationBasisItem(
          BasisKey.savedPreset,
          'Saved Preset',
          _selectedUserPreset!.name,
        ),
      CalculationBasisItem(
        BasisKey.joint,
        'Joint',
        _jointType.label,
        _jointType.labelFor(strings),
      ),
      if (_supportsUnequalGeometry)
        CalculationBasisItem(
          BasisKey.geometry,
          'Geometry',
          _jointGeometryMode.label,
          _jointGeometryMode.labelFor(strings),
        ),
      if (_isUnequalGeometry)
        CalculationBasisItem(
          BasisKey.alignment,
          'Alignment',
          _jointAlignment.label,
          _jointAlignment.labelFor(strings),
        ),
      CalculationBasisItem(
        BasisKey.groove,
        'Groove',
        _grooveType.label,
        _grooveType.labelFor(strings),
      ),
      CalculationBasisItem(
        BasisKey.classification,
        'Classification',
        _consumableSelection.awsSpecification == null
            ? _consumableSelection.label
            : '${_consumableSelection.awsSpecification} ${_consumableSelection.label}',
      ),
      CalculationBasisItem(
        BasisKey.fillerMetalFamily,
        'Filler Metal Family',
        _consumableSelection.family.label,
        _consumableSelection.family.labelFor(strings),
      ),
      // Optional -- only shown once a base material is actually attached
      // (see coder task decision on BaseMaterialSelection?/null semantics),
      // unlike Classification/Filler Metal Family above which are always
      // present.
      if (_baseMaterialSelection != null)
        CalculationBasisItem(
          BasisKey.baseMaterial,
          'Base Material',
          _baseMaterialSelection!.material.designation.trim().isEmpty
              ? _baseMaterialSelection!.label
              : '${_baseMaterialSelection!.label} '
                    '(${_baseMaterialSelection!.material.designation})',
        ),
      CalculationBasisItem(
        BasisKey.density,
        'Density',
        '${_controllers[FieldKey.density]!.text} g/cm3',
      ),
      CalculationBasisItem(
        BasisKey.wasteAllowance,
        'Waste Allowance',
        '${_controllers[FieldKey.wasteFactor]!.text}%',
      ),
      CalculationBasisItem(
        BasisKey.quantity,
        'Quantity',
        _controllers[FieldKey.quantity]!.text,
      ),
    ];

    if (_jointType == JointType.plateButt || _jointType == JointType.fillet) {
      items.add(
        CalculationBasisItem(
          BasisKey.weldLengthPerPiece,
          'Weld Length per Piece',
          '${_controllers[FieldKey.lengthMm]!.text} mm',
        ),
      );
    }

    if (_jointType == JointType.pipeButt && !_isUnequalGeometry) {
      items.add(
        CalculationBasisItem(
          BasisKey.pipeOd,
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
          BasisKey.thickness,
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
            BasisKey.thicknessA,
            'Thickness A',
            '${_controllers[FieldKey.thicknessAMm]!.text} mm',
          ),
          CalculationBasisItem(
            BasisKey.thicknessB,
            'Thickness B',
            '${_controllers[FieldKey.thicknessBMm]!.text} mm',
          ),
          CalculationBasisItem(
            BasisKey.controllingThickness,
            'Controlling Thickness',
            '${_formatNumber(_governingThicknessPreview ?? 0, 1)} mm',
          ),
        ]);
      }
      if (_jointType == JointType.pipeButt) {
        items.addAll([
          CalculationBasisItem(
            BasisKey.odA,
            'OD A',
            '${_controllers[FieldKey.pipeOdAMm]!.text} mm',
          ),
          CalculationBasisItem(
            BasisKey.odB,
            'OD B',
            '${_controllers[FieldKey.pipeOdBMm]!.text} mm',
          ),
          CalculationBasisItem(
            BasisKey.referenceOd,
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
          BasisKey.rootGap,
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
              ? BasisKey.rootFacePerSide
              : BasisKey.rootFace,
          _grooveType == GrooveType.doubleV
              ? 'Root Face per Side'
              : 'Root Face',
          '${_controllers[FieldKey.rootFaceMm]!.text} mm',
        ),
        CalculationBasisItem(
          BasisKey.bevelAngle,
          'Bevel Angle',
          '${_controllers[FieldKey.bevelAngleDeg]!.text} deg',
        ),
      ]);
    }

    if (_grooveType == GrooveType.compoundV) {
      items.addAll([
        CalculationBasisItem(
          BasisKey.rootFace,
          'Root Face',
          '${_controllers[FieldKey.rootFaceMm]!.text} mm',
        ),
        CalculationBasisItem(
          BasisKey.primaryBevelAngle,
          'Primary Bevel Angle',
          '${_controllers[FieldKey.bevelAngleDeg]!.text} deg',
        ),
        CalculationBasisItem(
          BasisKey.secondaryBevelAngle,
          'Secondary Bevel Angle',
          '${_controllers[FieldKey.secondaryBevelAngleDeg]!.text} deg',
        ),
        CalculationBasisItem(
          BasisKey.breakHeight,
          'Break Height',
          '${_controllers[FieldKey.breakHeightMm]!.text} mm',
        ),
      ]);
    }

    if (_grooveType == GrooveType.fillet) {
      items.add(
        CalculationBasisItem(
          BasisKey.filletLegSize,
          'Fillet Leg Size',
          '${_controllers[FieldKey.legSizeMm]!.text} mm',
        ),
      );
    }

    if (_grooveType == GrooveType.square ||
        _grooveType == GrooveType.singleV ||
        _grooveType == GrooveType.halfV ||
        _grooveType == GrooveType.doubleV ||
        _grooveType == GrooveType.compoundV) {
      final capOverlap = _parsePreviewValue(FieldKey.capOverlapMm);
      final capHeight = _parsePreviewValue(FieldKey.capHeightMm);
      if (capOverlap != null) {
        items.add(
          CalculationBasisItem(
            BasisKey.capOverlap,
            'Cap Overlap (each edge)',
            '${_controllers[FieldKey.capOverlapMm]!.text} mm',
          ),
        );
      }
      if (capHeight != null) {
        items.add(
          CalculationBasisItem(
            BasisKey.capHeight,
            'Cap Height',
            '${_controllers[FieldKey.capHeightMm]!.text} mm',
          ),
        );
      }
    }

    if (_weldingProcess == WeldingProcess.gtaw) {
      if (_depositionRateMode == DepositionRateMode.manual) {
        items.add(
          CalculationBasisItem(
            BasisKey.userDefinedRate,
            'User-defined Rate',
            '${_controllers[FieldKey.manualDepositionRateKgPerHour]!.text} kg/h',
          ),
        );
      } else {
        items.add(
          CalculationBasisItem(
            BasisKey.wireDiameter,
            'Wire Diameter',
            '${_controllers[FieldKey.wireDiameterMm]!.text} mm',
          ),
        );
      }
    } else if (_weldingProcess == WeldingProcess.smaw) {
      if (_depositionRateMode == DepositionRateMode.manual) {
        items.add(
          CalculationBasisItem(
            BasisKey.userDefinedRate,
            'User-defined Rate',
            '${_controllers[FieldKey.manualDepositionRateKgPerHour]!.text} kg/h',
          ),
        );
      } else {
        items.add(
          CalculationBasisItem(
            BasisKey.electrodeDiameter,
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
            BasisKey.userDefinedRate,
            'User-defined Rate',
            '${_controllers[FieldKey.manualDepositionRateKgPerHour]!.text} kg/h',
          ),
        );
      } else {
        items.add(
          CalculationBasisItem(
            BasisKey.wireDiameter,
            'Wire Diameter',
            '${_controllers[FieldKey.wireDiameterMm]!.text} mm',
          ),
        );
      }
    } else if (_weldingProcess == WeldingProcess.gtawSmaw) {
      items.addAll([
        CalculationBasisItem(
          BasisKey.gtawTransitionDepth,
          'GTAW Transition Depth',
          '${_controllers[FieldKey.gtawTransitionMm]!.text} mm',
        ),
        if (_depositionRateMode == DepositionRateMode.manual)
          CalculationBasisItem(
            BasisKey.gtawDepositionRate,
            'GTAW Deposition Rate',
            '${_controllers[FieldKey.manualGtawRateKgPerHour]!.text} kg/h',
          )
        else
          CalculationBasisItem(
            BasisKey.gtawWireDiameter,
            'GTAW Wire Diameter',
            '${_controllers[FieldKey.gtawWireDiameterMm]!.text} mm',
          ),
        if (_depositionRateMode == DepositionRateMode.manual)
          CalculationBasisItem(
            BasisKey.smawDepositionRate,
            'SMAW Deposition Rate',
            '${_controllers[FieldKey.manualSmawRateKgPerHour]!.text} kg/h',
          )
        else
          CalculationBasisItem(
            BasisKey.smawElectrodeDiameter,
            'SMAW Electrode Diameter',
            '${_controllers[FieldKey.smawElectrodeDiameterMm]!.text} mm',
          ),
      ]);
    }

    return items;
  }
}

/// Asks for a preset name (and, for updates, pre-fills the current one).
/// A dedicated StatefulWidget so its TextEditingController is disposed by
/// the framework itself at the right point in the dialog route's own
/// teardown, rather than by the caller immediately after `showDialog`
/// returns -- disposing it that early races with the dialog's still-running
/// exit transition and crashes with a "used after being disposed" assertion.
class _PresetNameDialog extends StatefulWidget {
  const _PresetNameDialog({this.initialValue});

  final String? initialValue;

  @override
  State<_PresetNameDialog> createState() => _PresetNameDialogState();
}

class _PresetNameDialogState extends State<_PresetNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocaleScope.stringsOf(context);
    final isUpdate = widget.initialValue != null;
    return AlertDialog(
      title: Text(
        isUpdate
            ? strings.calcPresetNameDialogUpdateTitle
            : strings.calcPresetNameDialogSaveTitle,
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: strings.savedCalculationsRenameFieldLabel,
          helperText: strings.calcPresetNameHelper,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.commonCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isUpdate ? strings.commonUpdate : strings.commonSave),
        ),
      ],
    );
  }
}

/// Asks a guest for both an account email and a preset name in one dialog
/// (rather than two `showDialog` calls back to back) -- see the note on
/// [_PresetNameDialog] for why controller disposal has to be owned by the
/// dialog's own State.

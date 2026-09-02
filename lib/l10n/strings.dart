import 'app_language.dart';

/// Static copy for the intro/splash screen, translated into every
/// language the app supports. Deeper, field-by-field calculator copy
/// (input labels, helper text, results, paywall) is still English-only
/// and is intentionally out of scope for this first localization pass.
class L10nStrings {
  const L10nStrings({
    required this.navBrand,
    required this.navSubtitle,
    required this.navPillEstimator,
    required this.navPillPdf,
    required this.navPillAws,
    required this.heroTag,
    required this.heroTitle,
    required this.heroBody,
    required this.heroSignalLiveJoint,
    required this.heroSignalGroove,
    required this.heroSignalProcess,
    required this.snapshotTitle,
    required this.snapshotDrawingMode,
    required this.snapshotConsumable,
    required this.snapshotSavedPresets,
    required this.snapshotEstimateState,
    required this.snapshotCalculated,
    required this.snapshotAwaitingRun,
    required this.capabilityDailyTitle,
    required this.capabilityDailyDesc,
    required this.capabilityDrawingTitle,
    required this.capabilityDrawingDesc,
    required this.capabilityReportTitle,
    required this.capabilityReportDesc,
    required this.getStarted,
    required this.languagePickerTitle,
    required this.emailGateHint,
    required this.emailGateInvalidEmail,
    required this.emailGateError,
    required this.emailGateWelcomeToast,
    required this.authChoiceTitle,
    required this.authChoiceBody,
    required this.authChoiceRegisterButton,
    required this.authChoiceGuestButton,
    required this.authFormTitle,
    required this.authFormFirstNameLabel,
    required this.authFormFirstNameHint,
    required this.authFormLastNameLabel,
    required this.authFormLastNameHint,
    required this.authFormEmailLabel,
    required this.authFormSubmitButton,
    required this.authFormFirstNameError,
    required this.authFormLastNameError,
    required this.dashboardTitle,
    required this.dashboardFillerConsumption,
    required this.dashboardSavedCalculations,
    required this.dashboardBaseMaterial,
    required this.dashboardFillerMaterial,
    required this.dashboardSavedReports,
    required this.commonSave,
    required this.commonCancel,
    required this.commonDelete,
    required this.commonEdit,
    required this.commonNameRequired,
    required this.baseMaterialTitle,
    required this.baseMaterialEmptyState,
    required this.baseMaterialAddButton,
    required this.baseMaterialFieldName,
    required this.baseMaterialFieldDesignation,
    required this.baseMaterialFieldNotes,
    required this.baseMaterialDeleteConfirmTitle,
    required this.baseMaterialDeleteConfirmBody,
    required this.baseMaterialSectionThickness,
    required this.baseMaterialFieldThickness,
    required this.baseMaterialFieldThicknessMin,
    required this.baseMaterialFieldThicknessMax,
    required this.fillerMaterialTitle,
    required this.fillerMaterialEmptyState,
    required this.fillerMaterialAddButton,
    required this.fillerMaterialFieldName,
    required this.fillerMaterialFieldFamily,
    required this.fillerMaterialFieldAws,
    required this.fillerMaterialFieldDensity,
    required this.fillerMaterialFieldNotes,
    required this.fillerMaterialDensityInvalid,
    required this.fillerMaterialDeleteConfirmTitle,
    required this.fillerMaterialDeleteConfirmBody,
    required this.materialSectionProducer,
    required this.materialFieldProducerName,
    required this.materialFieldMaterialId,
    required this.materialSectionComposition,
    required this.materialFieldCarbon,
    required this.materialFieldSilicon,
    required this.materialFieldManganese,
    required this.materialFieldChromium,
    required this.materialFieldMolybdenum,
    required this.materialFieldCopper,
    required this.materialFieldVanadium,
    required this.materialFieldNiobium,
    required this.materialFieldTitanium,
    required this.materialFieldBoron,
    required this.materialFieldNitrogen,
    required this.materialCompositionOrDivider,
    required this.materialFieldCet,
    required this.materialFieldPcm,
    required this.materialFieldInvalidNumber,
    required this.materialFieldOutOfRange,
    required this.consumableFamilyCarbonSteel,
    required this.consumableFamilyStainlessSteel,
    required this.consumableFamilyDissimilar,
    required this.consumableFamilyAluminium,
    required this.consumableFamilyLowAlloySteel,
    required this.consumableFamilyNickelAlloy,
    required this.consumableFamilyCopperAlloy,
    required this.consumableFamilyCastIron,
    required this.savedReportsTitle,
    required this.savedReportsEmptyState,
    required this.savedReportsShareButton,
    required this.savedReportsDeleteButton,
    required this.savedReportsDeleteConfirmTitle,
    required this.savedReportsDeleteConfirmBody,
    required this.savedReportsShareError,
    required this.savedCalculationsTitle,
    required this.savedCalculationsEmptyState,
    required this.savedCalculationsGuestState,
    required this.savedCalculationsLoadButton,
    required this.savedCalculationsRenameTitle,
    required this.savedCalculationsRenameFieldLabel,
    required this.savedCalculationsRenameError,
    required this.savedCalculationsDeleteConfirmTitle,
    required this.savedCalculationsDeleteConfirmBody,
    required this.savedCalculationsDeleteError,
    required this.presetProcessSwitchConfirmTitle,
    required this.presetProcessSwitchConfirmBody,
    required this.presetProcessSwitchConfirmSwitchButton,
    required this.presetProcessSwitchConfirmKeepButton,
    required this.presetSaveError,
    required this.presetSaved,
    required this.presetSavedOffline,
    required this.presetUpdated,
    required this.presetUpdatedOffline,
    required this.presetRestored,
    required this.presetRestoredOffline,
    required this.savedCalculationsSkippedWarning,
    required this.dashboardPreheatCalculator,
    required this.dashboardCoolingTimeCalculator,
    required this.materialFieldNickel,
    required this.preheatScreenTitle,
    required this.preheatScreenSubtitle,
    required this.preheatCompositionCardTitle,
    required this.preheatCompositionCardSubtitle,
    required this.preheatLoadFromLibraryLabel,
    required this.preheatBlankMeansZeroNote,
    required this.preheatWeldMetalCetLabel,
    required this.preheatJointCardTitle,
    required this.preheatThicknessLabel,
    required this.preheatHdLabel,
    required this.preheatYieldStrengthLabel,
    required this.preheatCalculateButton,
    required this.preheatResultLabel,
    required this.preheatNoPreheatRequiredLabel,
    required this.preheatComputedValueBelowAmbientNote,
    required this.preheatSpecialRuleNote,
    required this.preheatWarningCetOutOfRange,
    required this.preheatWarningThicknessOutOfRange,
    required this.preheatWarningHdOutOfRange,
    required this.preheatWarningHeatInputOutOfRange,
    required this.preheatWarningYieldOutOfRange,
    required this.preheatIso15608Note,
    required this.preheatOtherCarbonEquivalentsTitle,
    required this.preheatOtherCarbonEquivalentsCaption,
    required this.preheatUseInCoolingTimeButton,
    required this.coolingScreenTitle,
    required this.coolingScreenSubtitle,
    required this.coolingTempCardTitle,
    required this.coolingT0Label,
    required this.coolingT0InvalidError,
    required this.coolingT0BelowMinError,
    required this.coolingHeatInputCardTitle,
    required this.coolingJointCardTitle,
    required this.coolingJointTypeLabel,
    required this.coolingJointTypeRunOnPlate,
    required this.coolingJointTypeButtBetweenRuns,
    required this.coolingFilletNotSupportedNote,
    required this.coolingThicknessLabel,
    required this.coolingCalculateButton,
    required this.coolingResultLabel,
    required this.coolingRegimeTwoD,
    required this.coolingRegimeThreeD,
    required this.coolingRegimeExplanation,
    required this.coolingWarningHeatInputOutOfRange,
    required this.coolingWarningThicknessOutOfRange,
    required this.heatInputDirectModeLabel,
    required this.heatInputArcParamsModeLabel,
    required this.heatInputQLabel,
    required this.heatInputProcessLabel,
    required this.heatInputProcessSaw,
    required this.heatInputProcessSmaw,
    required this.heatInputProcessGmawMag,
    required this.heatInputVoltageLabel,
    required this.heatInputCurrentLabel,
    required this.heatInputTravelSpeedLabel,
    required this.heatInputComputedLabel,
    required this.heatInputVerifiedProcessesNote,
  });

  final String navBrand;
  final String navSubtitle;
  final String navPillEstimator;
  final String navPillPdf;
  final String navPillAws;
  final String heroTag;
  final String heroTitle;
  final String heroBody;
  final String heroSignalLiveJoint;
  final String heroSignalGroove;
  final String heroSignalProcess;
  final String snapshotTitle;
  final String snapshotDrawingMode;
  final String snapshotConsumable;
  final String snapshotSavedPresets;
  final String snapshotEstimateState;
  final String snapshotCalculated;
  final String snapshotAwaitingRun;
  final String capabilityDailyTitle;
  final String capabilityDailyDesc;
  final String capabilityDrawingTitle;
  final String capabilityDrawingDesc;
  final String capabilityReportTitle;
  final String capabilityReportDesc;
  final String getStarted;
  final String languagePickerTitle;
  final String emailGateHint;
  final String emailGateInvalidEmail;
  final String emailGateError;
  final String emailGateWelcomeToast;
  final String authChoiceTitle;
  final String authChoiceBody;
  final String authChoiceRegisterButton;
  final String authChoiceGuestButton;
  final String authFormTitle;
  final String authFormFirstNameLabel;
  final String authFormFirstNameHint;
  final String authFormLastNameLabel;
  final String authFormLastNameHint;
  final String authFormEmailLabel;
  final String authFormSubmitButton;
  final String authFormFirstNameError;
  final String authFormLastNameError;
  final String dashboardTitle;
  final String dashboardFillerConsumption;
  final String dashboardSavedCalculations;
  final String dashboardBaseMaterial;
  final String dashboardFillerMaterial;
  final String dashboardSavedReports;
  final String commonSave;
  final String commonCancel;
  final String commonDelete;
  final String commonEdit;
  final String commonNameRequired;
  final String baseMaterialTitle;
  final String baseMaterialEmptyState;
  final String baseMaterialAddButton;
  final String baseMaterialFieldName;
  final String baseMaterialFieldDesignation;
  final String baseMaterialFieldNotes;
  final String baseMaterialDeleteConfirmTitle;
  final String baseMaterialDeleteConfirmBody;
  final String baseMaterialSectionThickness;
  final String baseMaterialFieldThickness;
  final String baseMaterialFieldThicknessMin;
  final String baseMaterialFieldThicknessMax;
  final String fillerMaterialTitle;
  final String fillerMaterialEmptyState;
  final String fillerMaterialAddButton;
  final String fillerMaterialFieldName;
  final String fillerMaterialFieldFamily;
  final String fillerMaterialFieldAws;
  final String fillerMaterialFieldDensity;
  final String fillerMaterialFieldNotes;
  final String fillerMaterialDensityInvalid;
  final String fillerMaterialDeleteConfirmTitle;
  final String fillerMaterialDeleteConfirmBody;
  final String materialSectionProducer;
  final String materialFieldProducerName;
  final String materialFieldMaterialId;
  final String materialSectionComposition;
  final String materialFieldCarbon;
  final String materialFieldSilicon;
  final String materialFieldManganese;
  final String materialFieldChromium;
  final String materialFieldMolybdenum;
  final String materialFieldCopper;
  final String materialFieldVanadium;
  final String materialFieldNiobium;
  final String materialFieldTitanium;
  final String materialFieldBoron;
  final String materialFieldNitrogen;
  final String materialCompositionOrDivider;
  final String materialFieldCet;
  final String materialFieldPcm;
  final String materialFieldInvalidNumber;
  final String materialFieldOutOfRange;
  final String consumableFamilyCarbonSteel;
  final String consumableFamilyStainlessSteel;
  final String consumableFamilyDissimilar;
  final String consumableFamilyAluminium;
  final String consumableFamilyLowAlloySteel;
  final String consumableFamilyNickelAlloy;
  final String consumableFamilyCopperAlloy;
  final String consumableFamilyCastIron;
  final String savedReportsTitle;
  final String savedReportsEmptyState;
  final String savedReportsShareButton;
  final String savedReportsDeleteButton;
  final String savedReportsDeleteConfirmTitle;
  final String savedReportsDeleteConfirmBody;
  final String savedReportsShareError;
  final String savedCalculationsTitle;
  final String savedCalculationsEmptyState;
  final String savedCalculationsGuestState;
  final String savedCalculationsLoadButton;
  final String savedCalculationsRenameTitle;
  final String savedCalculationsRenameFieldLabel;
  final String savedCalculationsRenameError;
  final String savedCalculationsDeleteConfirmTitle;
  final String savedCalculationsDeleteConfirmBody;
  final String savedCalculationsDeleteError;
  final String presetProcessSwitchConfirmTitle;
  final String presetProcessSwitchConfirmBody;
  final String presetProcessSwitchConfirmSwitchButton;
  final String presetProcessSwitchConfirmKeepButton;
  final String presetSaveError;
  final String presetSaved;
  final String presetSavedOffline;
  final String presetUpdated;
  final String presetUpdatedOffline;
  final String presetRestored;
  final String presetRestoredOffline;
  final String savedCalculationsSkippedWarning;
  final String dashboardPreheatCalculator;
  final String dashboardCoolingTimeCalculator;
  final String materialFieldNickel;
  final String preheatScreenTitle;
  final String preheatScreenSubtitle;
  final String preheatCompositionCardTitle;
  final String preheatCompositionCardSubtitle;
  final String preheatLoadFromLibraryLabel;
  final String preheatBlankMeansZeroNote;
  final String preheatWeldMetalCetLabel;
  final String preheatJointCardTitle;
  final String preheatThicknessLabel;
  final String preheatHdLabel;
  final String preheatYieldStrengthLabel;
  final String preheatCalculateButton;
  final String preheatResultLabel;
  final String preheatNoPreheatRequiredLabel;
  final String preheatComputedValueBelowAmbientNote;
  final String preheatSpecialRuleNote;
  final String preheatWarningCetOutOfRange;
  final String preheatWarningThicknessOutOfRange;
  final String preheatWarningHdOutOfRange;
  final String preheatWarningHeatInputOutOfRange;
  final String preheatWarningYieldOutOfRange;
  final String preheatIso15608Note;
  final String preheatOtherCarbonEquivalentsTitle;
  final String preheatOtherCarbonEquivalentsCaption;
  final String preheatUseInCoolingTimeButton;
  final String coolingScreenTitle;
  final String coolingScreenSubtitle;
  final String coolingTempCardTitle;
  final String coolingT0Label;
  final String coolingT0InvalidError;
  final String coolingT0BelowMinError;
  final String coolingHeatInputCardTitle;
  final String coolingJointCardTitle;
  final String coolingJointTypeLabel;
  final String coolingJointTypeRunOnPlate;
  final String coolingJointTypeButtBetweenRuns;
  final String coolingFilletNotSupportedNote;
  final String coolingThicknessLabel;
  final String coolingCalculateButton;
  final String coolingResultLabel;
  final String coolingRegimeTwoD;
  final String coolingRegimeThreeD;
  final String coolingRegimeExplanation;
  final String coolingWarningHeatInputOutOfRange;
  final String coolingWarningThicknessOutOfRange;
  final String heatInputDirectModeLabel;
  final String heatInputArcParamsModeLabel;
  final String heatInputQLabel;
  final String heatInputProcessLabel;
  final String heatInputProcessSaw;
  final String heatInputProcessSmaw;
  final String heatInputProcessGmawMag;
  final String heatInputVoltageLabel;
  final String heatInputCurrentLabel;
  final String heatInputTravelSpeedLabel;
  final String heatInputComputedLabel;
  final String heatInputVerifiedProcessesNote;
}

const Map<AppLanguage, L10nStrings> _strings = {
  AppLanguage.en: L10nStrings(
    navBrand: 'Varyos Weld',
    navSubtitle:
        'Professional estimating workspace for weld engineers and client-facing planning.',
    navPillEstimator: 'BUTT & FILLET ESTIMATOR',
    navPillPdf: 'PDF READY',
    navPillAws: 'AWS CONSUMABLE DATA',
    heroTag: 'ENGINEERING PRODUCT / ESTIMATING WORKSPACE',
    heroTitle:
        'A welding estimator that feels technical, polished, and easy to trust.',
    heroBody:
        'Build estimates from real joint geometry, AWS consumable selection, and a report-grade result layer that can be shown to clients or production teams.',
    heroSignalLiveJoint: 'Live joint',
    heroSignalGroove: 'Groove',
    heroSignalProcess: 'Process',
    snapshotTitle: 'Session Snapshot',
    snapshotDrawingMode: 'Drawing mode',
    snapshotConsumable: 'Consumable',
    snapshotSavedPresets: 'Saved presets',
    snapshotEstimateState: 'Estimate state',
    snapshotCalculated: 'Calculated',
    snapshotAwaitingRun: 'Awaiting run',
    capabilityDailyTitle: 'Daily estimating',
    capabilityDailyDesc:
        'Compute weld area, length, volume, weld metal, filler demand, arc-on time, and deposition assumptions in one flow.',
    capabilityDrawingTitle: 'Technical drawing',
    capabilityDrawingDesc:
        'Show live groove geometry with visual and engineering modes so the section sketch reinforces the estimate.',
    capabilityReportTitle: 'Report workflow',
    capabilityReportDesc:
        'Turn the live estimate into a PDF-ready result summary with a clear engineering basis and reusable presets.',
    getStarted: 'Get Started',
    languagePickerTitle: 'Language',
    emailGateHint: 'you@example.com',
    emailGateInvalidEmail: 'Enter a valid email address',
    emailGateError:
        "Couldn't save that right now — you can still continue as a guest.",
    emailGateWelcomeToast: "You're in — check your inbox for a welcome note.",
    authChoiceTitle: 'Welcome to Varyos Weld',
    authChoiceBody:
        'Create an account to save your presets and reports across devices, or jump straight in as a guest.',
    authChoiceRegisterButton: 'Register',
    authChoiceGuestButton: 'Continue as guest',
    authFormTitle: 'Create your account',
    authFormFirstNameLabel: 'First name',
    authFormFirstNameHint: 'Jane',
    authFormLastNameLabel: 'Last name',
    authFormLastNameHint: 'Doe',
    authFormEmailLabel: 'Email',
    authFormSubmitButton: 'Create account',
    authFormFirstNameError: 'Enter your first name',
    authFormLastNameError: 'Enter your last name',
    dashboardTitle: 'Home',
    dashboardFillerConsumption: 'Filler Material Consumption',
    dashboardSavedCalculations: 'Saved Calculations',
    dashboardBaseMaterial: 'Base Material',
    dashboardFillerMaterial: 'Filler Material',
    dashboardSavedReports: 'Saved Reports',
    commonSave: 'Save',
    commonCancel: 'Cancel',
    commonDelete: 'Delete',
    commonEdit: 'Edit',
    commonNameRequired: 'Name is required',
    baseMaterialTitle: 'Base Material',
    baseMaterialEmptyState:
        'No base materials yet. Add one to build your library.',
    baseMaterialAddButton: 'Add Base Material',
    baseMaterialFieldName: 'Name',
    baseMaterialFieldDesignation: 'Designation',
    baseMaterialFieldNotes: 'Notes',
    baseMaterialDeleteConfirmTitle: 'Delete Base Material',
    baseMaterialDeleteConfirmBody:
        'Delete "{name}" from your base material library? This cannot be undone.',
    baseMaterialSectionThickness: 'Sheet Thickness',
    baseMaterialFieldThickness: 'Sheet Thickness (d, mm)',
    baseMaterialFieldThicknessMin: 'Min. Sheet Thickness (dmin, mm)',
    baseMaterialFieldThicknessMax: 'Max. Sheet Thickness (dmax, mm)',
    fillerMaterialTitle: 'Filler Material',
    fillerMaterialEmptyState:
        'No filler materials yet. Add one to build your library.',
    fillerMaterialAddButton: 'Add Filler Material',
    fillerMaterialFieldName: 'Name',
    fillerMaterialFieldFamily: 'Family',
    fillerMaterialFieldAws: 'AWS Specification',
    fillerMaterialFieldDensity: 'Density (g/cm³)',
    fillerMaterialFieldNotes: 'Notes',
    fillerMaterialDensityInvalid: 'Enter a valid density',
    fillerMaterialDeleteConfirmTitle: 'Delete Filler Material',
    fillerMaterialDeleteConfirmBody:
        'Delete "{name}" from your filler material library? This cannot be undone.',
    materialSectionProducer: 'Producer Data',
    materialFieldProducerName: 'Producer Name',
    materialFieldMaterialId: 'Material ID',
    materialSectionComposition: 'Chemical Composition',
    materialFieldCarbon: 'C (%)',
    materialFieldSilicon: 'Si (%)',
    materialFieldManganese: 'Mn (%)',
    materialFieldChromium: 'Cr (%)',
    materialFieldMolybdenum: 'Mo (%)',
    materialFieldCopper: 'Cu (%)',
    materialFieldVanadium: 'V (%)',
    materialFieldNiobium: 'Nb (%)',
    materialFieldTitanium: 'Ti (%)',
    materialFieldBoron: 'B (%)',
    materialFieldNitrogen: 'N (%)',
    materialCompositionOrDivider: 'OR enter CET / Pcm directly',
    materialFieldCet: 'CET (%)',
    materialFieldPcm: 'Pcm (%)',
    materialFieldInvalidNumber: 'Enter a valid number',
    materialFieldOutOfRange: 'Enter a value in the valid range',
    consumableFamilyCarbonSteel: 'Carbon Steel',
    consumableFamilyStainlessSteel: 'Stainless Steel',
    consumableFamilyDissimilar: 'Dissimilar',
    consumableFamilyAluminium: 'Aluminium',
    consumableFamilyLowAlloySteel: 'Low Alloy Steel',
    consumableFamilyNickelAlloy: 'Nickel Alloy',
    consumableFamilyCopperAlloy: 'Copper Alloy',
    consumableFamilyCastIron: 'Cast Iron',
    savedReportsTitle: 'Saved Reports',
    savedReportsEmptyState:
        'No saved reports yet. Export a PDF to see it here.',
    savedReportsShareButton: 'Share',
    savedReportsDeleteButton: 'Delete',
    savedReportsDeleteConfirmTitle: 'Delete Report',
    savedReportsDeleteConfirmBody:
        'Delete "{name}" from your saved reports? This cannot be undone.',
    savedReportsShareError: "Couldn't share the report. Please try again.",
    savedCalculationsTitle: 'Saved Calculations',
    savedCalculationsEmptyState:
        "No saved calculations yet. Save one from the calculator's summary step to see it here.",
    savedCalculationsGuestState:
        'Log in by saving a calculation from the calculator to start building your saved list here.',
    savedCalculationsLoadButton: 'Load',
    savedCalculationsRenameTitle: 'Rename Preset',
    savedCalculationsRenameFieldLabel: 'Preset Name',
    savedCalculationsRenameError:
        "Couldn't rename the preset. Please try again.",
    savedCalculationsDeleteConfirmTitle: 'Delete Preset',
    savedCalculationsDeleteConfirmBody:
        'Delete "{name}" from your saved calculations? This cannot be undone.',
    savedCalculationsDeleteError:
        "Couldn't delete the preset. Please try again.",
    presetProcessSwitchConfirmTitle: 'Switch Welding Process?',
    presetProcessSwitchConfirmBody:
        'This starter template normally uses {presetProcess}. Switch your welding process to match it, or keep {currentProcess}?',
    presetProcessSwitchConfirmSwitchButton: 'Switch to {presetProcess}',
    presetProcessSwitchConfirmKeepButton: 'Keep {currentProcess}',
    presetSaveError: "Couldn't save the preset. Please try again.",
    presetSaved: 'Preset saved.',
    presetSavedOffline:
        'Saved on this device only — will sync once you\'re back online.',
    presetUpdated: 'Saved calculation updated.',
    presetUpdatedOffline:
        'Updated on this device only — will sync once you\'re back online.',
    presetRestored:
        'This saved calculation had been removed elsewhere and was restored.',
    presetRestoredOffline:
        'This saved calculation had been removed elsewhere and was restored on this device only — will sync once you\'re back online.',
    savedCalculationsSkippedWarning:
        "{count} saved calculation(s) couldn't be loaded and were skipped.",
    dashboardPreheatCalculator: 'Preheat Temperature',
    dashboardCoolingTimeCalculator: 'Cooling Time (t8/5)',
    materialFieldNickel: 'Nickel (Ni) %',
    preheatScreenTitle: 'Preheat Temperature Calculator',
    preheatScreenSubtitle: 'EN 1011-2 Method B (CET-based)',
    preheatCompositionCardTitle: 'Parent metal composition',
    preheatCompositionCardSubtitle: 'Enter percent by weight; blank = 0%',
    preheatLoadFromLibraryLabel: 'Load from saved Base Material',
    preheatBlankMeansZeroNote:
        'Leave any element blank if not analyzed or not present — it is treated as 0% in the calculation.',
    preheatWeldMetalCetLabel:
        'Weld metal CET % (optional — for the special rule)',
    preheatJointCardTitle: 'Joint & process',
    preheatThicknessLabel: 'Plate thickness (mm)',
    preheatHdLabel: 'Diffusible hydrogen HD (ml/100g, ISO 3690)',
    preheatYieldStrengthLabel: 'Steel yield strength (N/mm², optional)',
    preheatCalculateButton: 'Calculate preheat temperature',
    preheatResultLabel: 'Recommended preheat temperature',
    preheatNoPreheatRequiredLabel: 'No preheat required',
    preheatComputedValueBelowAmbientNote:
        'Computed Method B value: {value} °C (below the 20 °C ambient reference).',
    preheatSpecialRuleNote:
        "Design CET adjusted to {value}% per EN 1011-2's special rule (weld metal CET + 0.03%).",
    preheatWarningCetOutOfRange:
        "CET is {value}% — outside the standard's validated range of 0.2–0.5%. Treat this result with extra caution.",
    preheatWarningThicknessOutOfRange:
        "Thickness is {value} mm — outside the standard's validated range of 10–90 mm.",
    preheatWarningHdOutOfRange:
        "Diffusible hydrogen is {value} ml/100g — outside the standard's validated range of 1–20 ml/100g.",
    preheatWarningHeatInputOutOfRange:
        "Heat input is {value} kJ/mm — outside the standard's validated range of 0.5–4.0 kJ/mm.",
    preheatWarningYieldOutOfRange:
        "Yield strength is {value} N/mm² — above the standard's validated limit of 1000 N/mm².",
    preheatIso15608Note:
        "This method (EN 1011-2 Annex C.3, Method B) is validated for steel groups 1–4 per ISO/TR 15608 (common structural and pressure-vessel steels). Verify your steel's group separately before relying on this result for high-alloy or exotic grades.",
    preheatOtherCarbonEquivalentsTitle:
        'Other carbon equivalents (reference only)',
    preheatOtherCarbonEquivalentsCaption:
        'Not part of EN 1011-2 — informational only.',
    preheatUseInCoolingTimeButton:
        'Use this preheat temp in the Cooling Time calculator',
    coolingScreenTitle: 'Cooling Time (t8/5) Calculator',
    coolingScreenSubtitle: 'EN 1011-2 Annex D.6',
    coolingTempCardTitle: 'Preheat / interpass temperature',
    coolingT0Label: 'Preheat or interpass temperature T0 (°C)',
    coolingT0InvalidError:
        'Must be below 500°C — the cooling formula is undefined at or above this value.',
    coolingT0BelowMinError:
        'Must be -50°C or above — that is well below any physically plausible preheat or interpass temperature for welding.',
    coolingHeatInputCardTitle: 'Heat input',
    coolingJointCardTitle: 'Joint & thickness',
    coolingJointTypeLabel: 'Joint type',
    coolingJointTypeRunOnPlate: 'Run-on-plate / bead-on-plate',
    coolingJointTypeButtBetweenRuns: 'Butt weld — between runs',
    coolingFilletNotSupportedNote:
        'Fillet weld joints are not yet supported — EN 1011-2 gives only a range (F2 0.45–0.67) with no interpolation rule, so this app does not compute a value for them.',
    coolingThicknessLabel: 'Plate thickness (mm)',
    coolingCalculateButton: 'Calculate cooling time',
    coolingResultLabel: 'Cooling time t8/5',
    coolingRegimeTwoD: '2D thin-plate',
    coolingRegimeThreeD: '3D thick-plate',
    coolingRegimeExplanation:
        'Calculated using the {regime} formula (transition thickness dt = {dt} mm for these inputs).',
    coolingWarningHeatInputOutOfRange:
        'Heat input is {value} kJ/mm — outside the typical 0.5–4.0 kJ/mm range seen in EN 1011-2 worked examples.',
    coolingWarningThicknessOutOfRange:
        'Thickness is {value} mm — outside the typical range for this calculation; double-check your inputs.',
    heatInputDirectModeLabel: 'Enter directly',
    heatInputArcParamsModeLabel: 'Calculate from arc parameters',
    heatInputQLabel: 'Net heat input Q (kJ/mm)',
    heatInputProcessLabel: 'Welding process',
    heatInputProcessSaw: 'SAW',
    heatInputProcessSmaw: 'SMAW',
    heatInputProcessGmawMag: 'GMAW / MAG',
    heatInputVoltageLabel: 'Voltage (V)',
    heatInputCurrentLabel: 'Current (A)',
    heatInputTravelSpeedLabel: 'Travel speed (mm/min)',
    heatInputComputedLabel: 'Computed Q: {value} kJ/mm',
    heatInputVerifiedProcessesNote:
        "Arc thermal efficiency is only verified in EN 1011-2 for SAW, SMAW, and GMAW/MAG. For other processes, switch to 'Enter directly' and provide Q from another source.",
  ),
  AppLanguage.tr: L10nStrings(
    navBrand: 'Varyos Weld',
    navSubtitle:
        'Kaynak mühendisleri ve müşteriyle çalışan ekipler için profesyonel hesaplama çalışma alanı.',
    navPillEstimator: 'ALIN & KÖŞE KAYNAK HESABI',
    navPillPdf: 'PDF HAZIR',
    navPillAws: 'AWS SARF MALZEME VERİSİ',
    heroTag: 'MÜHENDİSLİK ÜRÜNÜ / HESAPLAMA ÇALIŞMA ALANI',
    heroTitle: 'Teknik, özenli ve güvenilir hisseden bir kaynak hesaplayıcı.',
    heroBody:
        'Gerçek kaynak ağzı geometrisinden, AWS sarf malzemesi seçiminden ve müşteriye veya üretime sunulabilecek rapor kalitesinde bir sonuç katmanından hesaplama oluşturun.',
    heroSignalLiveJoint: 'Aktif birleşim',
    heroSignalGroove: 'Ağız',
    heroSignalProcess: 'Yöntem',
    snapshotTitle: 'Oturum Özeti',
    snapshotDrawingMode: 'Çizim modu',
    snapshotConsumable: 'Sarf malzeme',
    snapshotSavedPresets: 'Kayıtlı şablonlar',
    snapshotEstimateState: 'Hesap durumu',
    snapshotCalculated: 'Hesaplandı',
    snapshotAwaitingRun: 'Hesaplama bekleniyor',
    capabilityDailyTitle: 'Günlük hesaplama',
    capabilityDailyDesc:
        'Kaynak alanı, uzunluk, hacim, kaynak metali, dolgu ihtiyacı, ark süresi ve dolgu varsayımlarını tek akışta hesaplayın.',
    capabilityDrawingTitle: 'Teknik çizim',
    capabilityDrawingDesc:
        'Canlı ağız geometrisini görsel ve mühendislik modlarında gösterin, kesit çizimi hesaplamayı desteklesin.',
    capabilityReportTitle: 'Rapor akışı',
    capabilityReportDesc:
        'Canlı hesaplamayı net bir mühendislik dayanağı ve tekrar kullanılabilir şablonlarla PDF\'e hazır bir sonuç özetine dönüştürün.',
    getStarted: 'Başla',
    languagePickerTitle: 'Dil',
    emailGateHint: 'sen@ornek.com',
    emailGateInvalidEmail: 'Geçerli bir mail adresi gir',
    emailGateError:
        'Şu an kaydedemedik — yine de misafir olarak devam edebilirsin.',
    emailGateWelcomeToast:
        'Kaydın alındı — hoş geldin notu için gelen kutunu kontrol et.',
    authChoiceTitle: 'Varyos Weld’e Hoş Geldin',
    authChoiceBody:
        'Şablonlarını ve raporlarını cihazlar arasında saklamak için hesap oluştur, ya da doğrudan misafir olarak devam et.',
    authChoiceRegisterButton: 'Kayıt Ol',
    authChoiceGuestButton: 'Kayıtsız Devam Et',
    authFormTitle: 'Hesabını oluştur',
    authFormFirstNameLabel: 'Ad',
    authFormFirstNameHint: 'Ayşe',
    authFormLastNameLabel: 'Soyad',
    authFormLastNameHint: 'Yılmaz',
    authFormEmailLabel: 'E-posta',
    authFormSubmitButton: 'Hesap Oluştur',
    authFormFirstNameError: 'Adını gir',
    authFormLastNameError: 'Soyadını gir',
    dashboardTitle: 'Ana Sayfa',
    dashboardFillerConsumption: 'Dolgu Malzeme Tüketimi',
    dashboardSavedCalculations: 'Kayıtlı Hesaplamalar',
    dashboardBaseMaterial: 'Ana Malzeme',
    dashboardFillerMaterial: 'Dolgu Malzeme',
    dashboardSavedReports: 'Kayıtlı Raporlar',
    commonSave: 'Kaydet',
    commonCancel: 'Vazgeç',
    commonDelete: 'Sil',
    commonEdit: 'Düzenle',
    commonNameRequired: 'Ad gerekli',
    baseMaterialTitle: 'Ana Malzeme',
    baseMaterialEmptyState:
        'Henüz ana malzeme yok. Kütüphaneni oluşturmak için bir tane ekle.',
    baseMaterialAddButton: 'Ana Malzeme Ekle',
    baseMaterialFieldName: 'Ad',
    baseMaterialFieldDesignation: 'Tanım/Standart',
    baseMaterialFieldNotes: 'Notlar',
    baseMaterialDeleteConfirmTitle: 'Ana Malzemeyi Sil',
    baseMaterialDeleteConfirmBody:
        '"{name}" ana malzeme kütüphanenden silinsin mi? Bu işlem geri alınamaz.',
    baseMaterialSectionThickness: 'Sac Kalınlığı',
    baseMaterialFieldThickness: 'Sac Kalınlığı (d, mm)',
    baseMaterialFieldThicknessMin: 'Min. Sac Kalınlığı (dmin, mm)',
    baseMaterialFieldThicknessMax: 'Maks. Sac Kalınlığı (dmax, mm)',
    fillerMaterialTitle: 'Dolgu Malzeme',
    fillerMaterialEmptyState:
        'Henüz dolgu malzeme yok. Kütüphaneni oluşturmak için bir tane ekle.',
    fillerMaterialAddButton: 'Dolgu Malzeme Ekle',
    fillerMaterialFieldName: 'Ad',
    fillerMaterialFieldFamily: 'Aile',
    fillerMaterialFieldAws: 'AWS Spesifikasyonu',
    fillerMaterialFieldDensity: 'Yoğunluk (g/cm³)',
    fillerMaterialFieldNotes: 'Notlar',
    fillerMaterialDensityInvalid: 'Geçerli bir yoğunluk gir',
    fillerMaterialDeleteConfirmTitle: 'Dolgu Malzemeyi Sil',
    fillerMaterialDeleteConfirmBody:
        '"{name}" dolgu malzeme kütüphanenden silinsin mi? Bu işlem geri alınamaz.',
    materialSectionProducer: 'Üretici Bilgisi',
    materialFieldProducerName: 'Üretici Adı',
    materialFieldMaterialId: 'Malzeme Kodu',
    materialSectionComposition: 'Kimyasal Bileşim',
    materialFieldCarbon: 'C (%)',
    materialFieldSilicon: 'Si (%)',
    materialFieldManganese: 'Mn (%)',
    materialFieldChromium: 'Cr (%)',
    materialFieldMolybdenum: 'Mo (%)',
    materialFieldCopper: 'Cu (%)',
    materialFieldVanadium: 'V (%)',
    materialFieldNiobium: 'Nb (%)',
    materialFieldTitanium: 'Ti (%)',
    materialFieldBoron: 'B (%)',
    materialFieldNitrogen: 'N (%)',
    materialCompositionOrDivider: 'VEYA doğrudan CET / Pcm gir',
    materialFieldCet: 'CET (%)',
    materialFieldPcm: 'Pcm (%)',
    materialFieldInvalidNumber: 'Geçerli bir sayı gir',
    materialFieldOutOfRange: 'Geçerli aralıkta bir değer gir',
    consumableFamilyCarbonSteel: 'Karbon Çeliği',
    consumableFamilyStainlessSteel: 'Paslanmaz Çelik',
    consumableFamilyDissimilar: 'Farklı Metal',
    consumableFamilyAluminium: 'Alüminyum',
    consumableFamilyLowAlloySteel: 'Düşük Alaşımlı Çelik',
    consumableFamilyNickelAlloy: 'Nikel Alaşımı',
    consumableFamilyCopperAlloy: 'Bakır Alaşımı',
    consumableFamilyCastIron: 'Dökme Demir',
    savedReportsTitle: 'Kayıtlı Raporlar',
    savedReportsEmptyState:
        'Henüz kayıtlı rapor yok. Bir PDF dışa aktardığında burada görünecek.',
    savedReportsShareButton: 'Paylaş',
    savedReportsDeleteButton: 'Sil',
    savedReportsDeleteConfirmTitle: 'Raporu Sil',
    savedReportsDeleteConfirmBody:
        '"{name}" kayıtlı raporlarından silinsin mi? Bu işlem geri alınamaz.',
    savedReportsShareError: 'Rapor paylaşılamadı. Lütfen tekrar dene.',
    savedCalculationsTitle: 'Kayıtlı Hesaplamalar',
    savedCalculationsEmptyState:
        'Henüz kayıtlı hesaplama yok. Hesaplayıcının özet adımından birini kaydettiğinde burada görünecek.',
    savedCalculationsGuestState:
        'Kayıtlı listeni oluşturmak için hesaplayıcıda bir hesaplama kaydederek giriş yap.',
    savedCalculationsLoadButton: 'Yükle',
    savedCalculationsRenameTitle: 'Şablonu Yeniden Adlandır',
    savedCalculationsRenameFieldLabel: 'Şablon Adı',
    savedCalculationsRenameError:
        'Şablon yeniden adlandırılamadı. Lütfen tekrar dene.',
    savedCalculationsDeleteConfirmTitle: 'Şablonu Sil',
    savedCalculationsDeleteConfirmBody:
        '"{name}" kayıtlı hesaplamalarından silinsin mi? Bu işlem geri alınamaz.',
    savedCalculationsDeleteError: 'Şablon silinemedi. Lütfen tekrar dene.',
    presetProcessSwitchConfirmTitle: 'Kaynak Yöntemi Değişsin mi?',
    presetProcessSwitchConfirmBody:
        'Bu başlangıç şablonu genellikle {presetProcess} kullanır. Kaynak yöntemini buna göre değiştir, yoksa {currentProcess} olarak mı kalsın?',
    presetProcessSwitchConfirmSwitchButton: '{presetProcess} olarak değiştir',
    presetProcessSwitchConfirmKeepButton: '{currentProcess} olarak kalsın',
    presetSaveError: 'Şablon kaydedilemedi. Lütfen tekrar dene.',
    presetSaved: 'Şablon kaydedildi.',
    presetSavedOffline:
        'Sadece bu cihazda kaydedildi — internete bağlanınca eşitlenecek.',
    presetUpdated: 'Kayıtlı hesaplama güncellendi.',
    presetUpdatedOffline:
        'Sadece bu cihazda güncellendi — internete bağlanınca eşitlenecek.',
    presetRestored:
        'Bu kayıtlı hesaplama başka bir yerde silinmişti ve geri yüklendi.',
    presetRestoredOffline:
        'Bu kayıtlı hesaplama başka bir yerde silinmişti ve sadece bu cihazda geri yüklendi — internete bağlanınca eşitlenecek.',
    savedCalculationsSkippedWarning:
        '{count} kayıtlı hesaplama yüklenemedi ve atlandı.',
    dashboardPreheatCalculator: 'Ön Isıtma Sıcaklığı',
    dashboardCoolingTimeCalculator: 'Soğuma Süresi (t8/5)',
    materialFieldNickel: 'Nikel (Ni) %',
    preheatScreenTitle: 'Ön Isıtma Sıcaklığı Hesaplayıcı',
    preheatScreenSubtitle: 'EN 1011-2 Yöntem B (CET tabanlı)',
    preheatCompositionCardTitle: 'Ana malzeme kimyasal bileşimi',
    preheatCompositionCardSubtitle: 'Ağırlıkça yüzde girin; boş = %0',
    preheatLoadFromLibraryLabel: 'Kayıtlı Ana Malzemeden yükle',
    preheatBlankMeansZeroNote:
        'Analiz edilmemiş veya bulunmayan elementleri boş bırakın — hesaplamada %0 olarak kabul edilir.',
    preheatWeldMetalCetLabel:
        'Kaynak metali CET % (isteğe bağlı — özel kural için)',
    preheatJointCardTitle: 'Bağlantı ve işlem',
    preheatThicknessLabel: 'Sac kalınlığı (mm)',
    preheatHdLabel: 'Difüzyona uğrayabilir hidrojen HD (ml/100g, ISO 3690)',
    preheatYieldStrengthLabel: 'Çelik akma dayanımı (N/mm², isteğe bağlı)',
    preheatCalculateButton: 'Ön ısıtma sıcaklığını hesapla',
    preheatResultLabel: 'Önerilen ön ısıtma sıcaklığı',
    preheatNoPreheatRequiredLabel: 'Ön ısıtma gerekli değil',
    preheatComputedValueBelowAmbientNote:
        'Hesaplanan Yöntem B değeri: {value} °C (20 °C ortam referansının altında).',
    preheatSpecialRuleNote:
        "Tasarım CET değeri EN 1011-2'nin özel kuralına göre %{value} olarak ayarlandı (kaynak metali CET + %0.03).",
    preheatWarningCetOutOfRange:
        'CET %{value} — standardın doğrulanmış %0.2–0.5 aralığının dışında. Bu sonucu ekstra dikkatle değerlendirin.',
    preheatWarningThicknessOutOfRange:
        'Kalınlık {value} mm — standardın doğrulanmış 10–90 mm aralığının dışında.',
    preheatWarningHdOutOfRange:
        'Difüzyona uğrayabilir hidrojen {value} ml/100g — standardın doğrulanmış 1–20 ml/100g aralığının dışında.',
    preheatWarningHeatInputOutOfRange:
        'Isı girdisi {value} kJ/mm — standardın doğrulanmış 0.5–4.0 kJ/mm aralığının dışında.',
    preheatWarningYieldOutOfRange:
        'Akma dayanımı {value} N/mm² — standardın doğrulanmış 1000 N/mm² sınırının üzerinde.',
    preheatIso15608Note:
        "Bu yöntem (EN 1011-2 Ek C.3, Yöntem B) ISO/TR 15608'e göre çelik grupları 1-4 için (yaygın yapısal ve basınçlı kap çelikleri) doğrulanmıştır. Yüksek alaşımlı veya özel çelikler için bu sonuca güvenmeden önce çeliğinizin grubunu ayrıca doğrulayın.",
    preheatOtherCarbonEquivalentsTitle:
        'Diğer karbon eşdeğerleri (yalnızca referans)',
    preheatOtherCarbonEquivalentsCaption:
        "EN 1011-2'nin parçası değildir — yalnızca bilgilendirme amaçlıdır.",
    preheatUseInCoolingTimeButton:
        'Bu ön ısıtma sıcaklığını Soğuma Süresi hesaplayıcısında kullan',
    coolingScreenTitle: 'Soğuma Süresi (t8/5) Hesaplayıcı',
    coolingScreenSubtitle: 'EN 1011-2 Ek D.6',
    coolingTempCardTitle: 'Ön ısıtma / pasolar arası sıcaklık',
    coolingT0Label: 'Ön ısıtma veya pasolar arası sıcaklık T0 (°C)',
    coolingT0InvalidError:
        "500°C'nin altında olmalıdır — soğuma formülü bu değerde ve üzerinde tanımsızdır.",
    coolingT0BelowMinError:
        "-50°C veya üzerinde olmalıdır — bu, kaynak için fiziksel olarak makul herhangi bir ön ısıtma veya pasolar arası sıcaklığın çok altındadır.",
    coolingHeatInputCardTitle: 'Isı girdisi',
    coolingJointCardTitle: 'Bağlantı ve kalınlık',
    coolingJointTypeLabel: 'Bağlantı tipi',
    coolingJointTypeRunOnPlate: 'Levha üzeri paso / plaka üzeri paso',
    coolingJointTypeButtBetweenRuns: 'Alın kaynağı — pasolar arası',
    coolingFilletNotSupportedNote:
        'Köşe kaynağı bağlantıları henüz desteklenmiyor — EN 1011-2 yalnızca bir aralık verir (F2 0.45–0.67) ve enterpolasyon kuralı yoktur, bu yüzden uygulama bunlar için değer hesaplamaz.',
    coolingThicknessLabel: 'Sac kalınlığı (mm)',
    coolingCalculateButton: 'Soğuma süresini hesapla',
    coolingResultLabel: 'Soğuma süresi t8/5',
    coolingRegimeTwoD: '2D ince levha',
    coolingRegimeThreeD: '3D kalın levha',
    coolingRegimeExplanation:
        '{regime} formülü kullanılarak hesaplandı (bu girdiler için geçiş kalınlığı dt = {dt} mm).',
    coolingWarningHeatInputOutOfRange:
        'Isı girdisi {value} kJ/mm — EN 1011-2 örnek hesaplarında görülen tipik 0.5–4.0 kJ/mm aralığının dışında.',
    coolingWarningThicknessOutOfRange:
        'Kalınlık {value} mm — bu hesaplama için tipik aralığın dışında; girdilerinizi kontrol edin.',
    heatInputDirectModeLabel: 'Doğrudan gir',
    heatInputArcParamsModeLabel: 'Ark parametrelerinden hesapla',
    heatInputQLabel: 'Net ısı girdisi Q (kJ/mm)',
    heatInputProcessLabel: 'Kaynak yöntemi',
    heatInputProcessSaw: 'SAW',
    heatInputProcessSmaw: 'SMAW',
    heatInputProcessGmawMag: 'GMAW / MAG',
    heatInputVoltageLabel: 'Gerilim (V)',
    heatInputCurrentLabel: 'Akım (A)',
    heatInputTravelSpeedLabel: 'İlerleme hızı (mm/dk)',
    heatInputComputedLabel: 'Hesaplanan Q: {value} kJ/mm',
    heatInputVerifiedProcessesNote:
        "Ark ısıl verimi EN 1011-2'de yalnızca SAW, SMAW ve GMAW/MAG için doğrulanmıştır. Diğer yöntemler için 'Doğrudan gir' seçeneğine geçip Q değerini başka bir kaynaktan girin.",
  ),
  AppLanguage.ru: L10nStrings(
    navBrand: 'Varyos Weld',
    navSubtitle:
        'Профессиональное рабочее пространство для расчётов сварщиков-инженеров и работы с клиентами.',
    navPillEstimator: 'РАСЧЁТ СТЫКОВЫХ И УГЛОВЫХ ШВОВ',
    navPillPdf: 'ГОТОВ К PDF',
    navPillAws: 'ДАННЫЕ AWS ПО МАТЕРИАЛАМ',
    heroTag: 'ИНЖЕНЕРНЫЙ ПРОДУКТ / РАБОЧЕЕ ПРОСТРАНСТВО ДЛЯ РАСЧЁТОВ',
    heroTitle:
        'Калькулятор сварки, который выглядит технично, аккуратно и вызывает доверие.',
    heroBody:
        'Формируйте расчёты на основе реальной геометрии соединения, выбора присадочного материала по AWS и результата уровня отчёта, который можно показать клиенту или производству.',
    heroSignalLiveJoint: 'Тип соединения',
    heroSignalGroove: 'Разделка',
    heroSignalProcess: 'Процесс',
    snapshotTitle: 'Сводка сессии',
    snapshotDrawingMode: 'Режим чертежа',
    snapshotConsumable: 'Присадочный материал',
    snapshotSavedPresets: 'Сохранённые шаблоны',
    snapshotEstimateState: 'Статус расчёта',
    snapshotCalculated: 'Рассчитано',
    snapshotAwaitingRun: 'Ожидание расчёта',
    capabilityDailyTitle: 'Ежедневные расчёты',
    capabilityDailyDesc:
        'Считайте площадь и длину шва, объём наплавленного металла, расход присадки, время дуги и параметры наплавки в одном потоке.',
    capabilityDrawingTitle: 'Технический чертёж',
    capabilityDrawingDesc:
        'Показывайте геометрию разделки в реальном времени в визуальном и инженерном режимах, чтобы чертёж подтверждал расчёт.',
    capabilityReportTitle: 'Формирование отчёта',
    capabilityReportDesc:
        'Превращайте расчёт в готовый к печати PDF-отчёт с чёткой инженерной основой и повторно используемыми шаблонами.',
    getStarted: 'Начать',
    languagePickerTitle: 'Язык',
    emailGateHint: 'you@example.com',
    emailGateInvalidEmail: 'Введите корректный адрес электронной почты',
    emailGateError:
        'Не удалось сохранить сейчас — вы можете продолжить как гость.',
    emailGateWelcomeToast:
        'Готово — проверьте почту, там приветственное письмо.',
    authChoiceTitle: 'Добро пожаловать в Varyos Weld',
    authChoiceBody:
        'Создайте аккаунт, чтобы сохранять шаблоны и отчёты на всех устройствах, или продолжите как гость.',
    authChoiceRegisterButton: 'Зарегистрироваться',
    authChoiceGuestButton: 'Продолжить как гость',
    authFormTitle: 'Создать аккаунт',
    authFormFirstNameLabel: 'Имя',
    authFormFirstNameHint: 'Иван',
    authFormLastNameLabel: 'Фамилия',
    authFormLastNameHint: 'Иванов',
    authFormEmailLabel: 'Email',
    authFormSubmitButton: 'Создать аккаунт',
    authFormFirstNameError: 'Введите имя',
    authFormLastNameError: 'Введите фамилию',
    dashboardTitle: 'Главная',
    dashboardFillerConsumption: 'Расход присадочного материала',
    dashboardSavedCalculations: 'Сохранённые расчёты',
    dashboardBaseMaterial: 'Основной металл',
    dashboardFillerMaterial: 'Присадочный материал',
    dashboardSavedReports: 'Сохранённые отчёты',
    commonSave: 'Сохранить',
    commonCancel: 'Отмена',
    commonDelete: 'Удалить',
    commonEdit: 'Изменить',
    commonNameRequired: 'Введите название',
    baseMaterialTitle: 'Основной металл',
    baseMaterialEmptyState:
        'Пока нет основного металла. Добавьте, чтобы создать свою библиотеку.',
    baseMaterialAddButton: 'Добавить основной металл',
    baseMaterialFieldName: 'Название',
    baseMaterialFieldDesignation: 'Обозначение',
    baseMaterialFieldNotes: 'Заметки',
    baseMaterialDeleteConfirmTitle: 'Удалить основной металл',
    baseMaterialDeleteConfirmBody:
        'Удалить «{name}» из вашей библиотеки основных металлов? Это действие необратимо.',
    baseMaterialSectionThickness: 'Толщина листа',
    baseMaterialFieldThickness: 'Толщина листа (d, мм)',
    baseMaterialFieldThicknessMin: 'Мин. толщина листа (dmin, мм)',
    baseMaterialFieldThicknessMax: 'Макс. толщина листа (dmax, мм)',
    fillerMaterialTitle: 'Присадочный материал',
    fillerMaterialEmptyState:
        'Пока нет присадочного материала. Добавьте, чтобы создать свою библиотеку.',
    fillerMaterialAddButton: 'Добавить присадочный материал',
    fillerMaterialFieldName: 'Название',
    fillerMaterialFieldFamily: 'Группа',
    fillerMaterialFieldAws: 'Спецификация AWS',
    fillerMaterialFieldDensity: 'Плотность (г/см³)',
    fillerMaterialFieldNotes: 'Заметки',
    fillerMaterialDensityInvalid: 'Введите корректную плотность',
    fillerMaterialDeleteConfirmTitle: 'Удалить присадочный материал',
    fillerMaterialDeleteConfirmBody:
        'Удалить «{name}» из вашей библиотеки присадочных материалов? Это действие необратимо.',
    materialSectionProducer: 'Данные производителя',
    materialFieldProducerName: 'Название производителя',
    materialFieldMaterialId: 'Код материала',
    materialSectionComposition: 'Химический состав',
    materialFieldCarbon: 'C (%)',
    materialFieldSilicon: 'Si (%)',
    materialFieldManganese: 'Mn (%)',
    materialFieldChromium: 'Cr (%)',
    materialFieldMolybdenum: 'Mo (%)',
    materialFieldCopper: 'Cu (%)',
    materialFieldVanadium: 'V (%)',
    materialFieldNiobium: 'Nb (%)',
    materialFieldTitanium: 'Ti (%)',
    materialFieldBoron: 'B (%)',
    materialFieldNitrogen: 'N (%)',
    materialCompositionOrDivider: 'ИЛИ введите CET / Pcm напрямую',
    materialFieldCet: 'CET (%)',
    materialFieldPcm: 'Pcm (%)',
    materialFieldInvalidNumber: 'Введите корректное число',
    materialFieldOutOfRange: 'Введите значение в допустимом диапазоне',
    consumableFamilyCarbonSteel: 'Углеродистая сталь',
    consumableFamilyStainlessSteel: 'Нержавеющая сталь',
    consumableFamilyDissimilar: 'Разнородные металлы',
    consumableFamilyAluminium: 'Алюминий',
    consumableFamilyLowAlloySteel: 'Низколегированная сталь',
    consumableFamilyNickelAlloy: 'Никелевый сплав',
    consumableFamilyCopperAlloy: 'Медный сплав',
    consumableFamilyCastIron: 'Чугун',
    savedReportsTitle: 'Сохранённые отчёты',
    savedReportsEmptyState:
        'Пока нет сохранённых отчётов. Они появятся здесь после экспорта PDF.',
    savedReportsShareButton: 'Поделиться',
    savedReportsDeleteButton: 'Удалить',
    savedReportsDeleteConfirmTitle: 'Удалить отчёт',
    savedReportsDeleteConfirmBody:
        'Удалить «{name}» из сохранённых отчётов? Это действие необратимо.',
    savedReportsShareError:
        'Не удалось поделиться отчётом. Попробуйте ещё раз.',
    savedCalculationsTitle: 'Сохранённые расчёты',
    savedCalculationsEmptyState:
        'Пока нет сохранённых расчётов. Сохраните один на шаге сводки в калькуляторе, чтобы увидеть его здесь.',
    savedCalculationsGuestState:
        'Войдите, сохранив расчёт в калькуляторе, чтобы начать формировать список здесь.',
    savedCalculationsLoadButton: 'Загрузить',
    savedCalculationsRenameTitle: 'Переименовать шаблон',
    savedCalculationsRenameFieldLabel: 'Название шаблона',
    savedCalculationsRenameError:
        'Не удалось переименовать шаблон. Попробуйте ещё раз.',
    savedCalculationsDeleteConfirmTitle: 'Удалить шаблон',
    savedCalculationsDeleteConfirmBody:
        'Удалить «{name}» из сохранённых расчётов? Это действие необратимо.',
    savedCalculationsDeleteError:
        'Не удалось удалить шаблон. Попробуйте ещё раз.',
    presetProcessSwitchConfirmTitle: 'Сменить способ сварки?',
    presetProcessSwitchConfirmBody:
        'Этот стартовый шаблон обычно использует {presetProcess}. Сменить способ сварки, чтобы совпадал, или оставить {currentProcess}?',
    presetProcessSwitchConfirmSwitchButton: 'Сменить на {presetProcess}',
    presetProcessSwitchConfirmKeepButton: 'Оставить {currentProcess}',
    presetSaveError: 'Не удалось сохранить шаблон. Попробуйте ещё раз.',
    presetSaved: 'Шаблон сохранён.',
    presetSavedOffline:
        'Сохранено только на этом устройстве — синхронизируется, когда появится подключение к интернету.',
    presetUpdated: 'Сохранённый расчёт обновлён.',
    presetUpdatedOffline:
        'Обновлено только на этом устройстве — синхронизируется, когда появится подключение к интернету.',
    presetRestored:
        'Этот сохранённый расчёт был удалён в другом месте и был восстановлен.',
    presetRestoredOffline:
        'Этот сохранённый расчёт был удалён в другом месте и восстановлен только на этом устройстве — синхронизируется, когда появится подключение к интернету.',
    savedCalculationsSkippedWarning:
        '{count} сохранённых расчётов не удалось загрузить, они были пропущены.',
    dashboardPreheatCalculator: 'Температура предварительного подогрева',
    dashboardCoolingTimeCalculator: 'Время охлаждения (t8/5)',
    materialFieldNickel: 'Никель (Ni) %',
    preheatScreenTitle: 'Калькулятор температуры предварительного подогрева',
    preheatScreenSubtitle: 'EN 1011-2, метод B (на основе CET)',
    preheatCompositionCardTitle: 'Химический состав основного металла',
    preheatCompositionCardSubtitle: 'Введите процент по массе; пусто = 0%',
    preheatLoadFromLibraryLabel: 'Загрузить из сохранённого основного металла',
    preheatBlankMeansZeroNote:
        'Оставьте элемент пустым, если он не анализировался или отсутствует — в расчёте он принимается за 0%.',
    preheatWeldMetalCetLabel:
        'CET наплавленного металла % (необязательно — для особого правила)',
    preheatJointCardTitle: 'Соединение и процесс',
    preheatThicknessLabel: 'Толщина пластины (мм)',
    preheatHdLabel: 'Диффузионный водород HD (мл/100г, ISO 3690)',
    preheatYieldStrengthLabel: 'Предел текучести стали (Н/мм², необязательно)',
    preheatCalculateButton: 'Рассчитать температуру подогрева',
    preheatResultLabel: 'Рекомендуемая температура предварительного подогрева',
    preheatNoPreheatRequiredLabel: 'Предварительный подогрев не требуется',
    preheatComputedValueBelowAmbientNote:
        'Расчётное значение по методу B: {value} °C (ниже эталонной температуры окружающей среды 20 °C).',
    preheatSpecialRuleNote:
        'Расчётный CET скорректирован до {value}% согласно особому правилу EN 1011-2 (CET наплавленного металла + 0.03%).',
    preheatWarningCetOutOfRange:
        'CET составляет {value}% — вне проверенного диапазона стандарта 0.2–0.5%. Относитесь к этому результату с особой осторожностью.',
    preheatWarningThicknessOutOfRange:
        'Толщина {value} мм — вне проверенного диапазона стандарта 10–90 мм.',
    preheatWarningHdOutOfRange:
        'Диффузионный водород {value} мл/100г — вне проверенного диапазона стандарта 1–20 мл/100г.',
    preheatWarningHeatInputOutOfRange:
        'Погонная энергия {value} кДж/мм — вне проверенного диапазона стандарта 0.5–4.0 кДж/мм.',
    preheatWarningYieldOutOfRange:
        'Предел текучести {value} Н/мм² — выше проверенного предела стандарта 1000 Н/мм².',
    preheatIso15608Note:
        'Этот метод (EN 1011-2, Приложение C.3, метод B) проверен для групп сталей 1–4 по ISO/TR 15608 (обычные конструкционные стали и стали для сосудов под давлением). Отдельно проверьте группу вашей стали, прежде чем полагаться на этот результат для высоколегированных или нестандартных марок.',
    preheatOtherCarbonEquivalentsTitle:
        'Другие углеродные эквиваленты (только для справки)',
    preheatOtherCarbonEquivalentsCaption:
        'Не входит в EN 1011-2 — только информационно.',
    preheatUseInCoolingTimeButton:
        'Использовать эту температуру подогрева в калькуляторе времени охлаждения',
    coolingScreenTitle: 'Калькулятор времени охлаждения (t8/5)',
    coolingScreenSubtitle: 'EN 1011-2, Приложение D.6',
    coolingTempCardTitle:
        'Температура предварительного подогрева / между проходами',
    coolingT0Label: 'Температура подогрева или между проходами T0 (°C)',
    coolingT0InvalidError:
        'Должна быть ниже 500°C — формула охлаждения не определена при этом значении и выше.',
    coolingT0BelowMinError:
        'Должна быть не ниже -50°C — это значительно ниже любой физически правдоподобной температуры подогрева или между проходами при сварке.',
    coolingHeatInputCardTitle: 'Погонная энергия',
    coolingJointCardTitle: 'Соединение и толщина',
    coolingJointTypeLabel: 'Тип соединения',
    coolingJointTypeRunOnPlate: 'Наплавка на пластину / валик на пластине',
    coolingJointTypeButtBetweenRuns: 'Стыковой шов — между проходами',
    coolingFilletNotSupportedNote:
        'Угловые соединения пока не поддерживаются — EN 1011-2 задаёт только диапазон (F2 0.45–0.67) без правила интерполяции, поэтому приложение не рассчитывает для них значение.',
    coolingThicknessLabel: 'Толщина пластины (мм)',
    coolingCalculateButton: 'Рассчитать время охлаждения',
    coolingResultLabel: 'Время охлаждения t8/5',
    coolingRegimeTwoD: '2D тонкая пластина',
    coolingRegimeThreeD: '3D толстая пластина',
    coolingRegimeExplanation:
        'Рассчитано по формуле {regime} (переходная толщина dt = {dt} мм для этих данных).',
    coolingWarningHeatInputOutOfRange:
        'Погонная энергия {value} кДж/мм — вне типичного диапазона 0.5–4.0 кДж/мм, встречающегося в примерах EN 1011-2.',
    coolingWarningThicknessOutOfRange:
        'Толщина {value} мм — вне типичного диапазона для этого расчёта; перепроверьте исходные данные.',
    heatInputDirectModeLabel: 'Ввести напрямую',
    heatInputArcParamsModeLabel: 'Рассчитать по параметрам дуги',
    heatInputQLabel: 'Погонная энергия Q (кДж/мм)',
    heatInputProcessLabel: 'Способ сварки',
    heatInputProcessSaw: 'SAW',
    heatInputProcessSmaw: 'SMAW',
    heatInputProcessGmawMag: 'GMAW / MAG',
    heatInputVoltageLabel: 'Напряжение (В)',
    heatInputCurrentLabel: 'Сила тока (А)',
    heatInputTravelSpeedLabel: 'Скорость сварки (мм/мин)',
    heatInputComputedLabel: 'Расчётная Q: {value} кДж/мм',
    heatInputVerifiedProcessesNote:
        'Тепловой КПД дуги проверен в EN 1011-2 только для SAW, SMAW и GMAW/MAG. Для других процессов переключитесь на «Ввести напрямую» и укажите Q из другого источника.',
  ),
  AppLanguage.de: L10nStrings(
    navBrand: 'Varyos Weld',
    navSubtitle:
        'Professioneller Berechnungs-Arbeitsbereich für Schweißingenieure und die Kundenkommunikation.',
    navPillEstimator: 'STUMPF- & KEHLNAHT-RECHNER',
    navPillPdf: 'PDF BEREIT',
    navPillAws: 'AWS-ZUSATZWERKSTOFFDATEN',
    heroTag: 'TECHNISCHES PRODUKT / BERECHNUNGS-ARBEITSBEREICH',
    heroTitle:
        'Ein Schweißrechner, der technisch, durchdacht und vertrauenswürdig wirkt.',
    heroBody:
        'Erstellen Sie Kalkulationen aus realer Nahtgeometrie, AWS-Zusatzwerkstoffauswahl und einer berichtsfähigen Ergebnisdarstellung für Kunden oder die Fertigung.',
    heroSignalLiveJoint: 'Verbindung',
    heroSignalGroove: 'Nahtform',
    heroSignalProcess: 'Verfahren',
    snapshotTitle: 'Sitzungsübersicht',
    snapshotDrawingMode: 'Zeichnungsmodus',
    snapshotConsumable: 'Zusatzwerkstoff',
    snapshotSavedPresets: 'Gespeicherte Vorlagen',
    snapshotEstimateState: 'Berechnungsstatus',
    snapshotCalculated: 'Berechnet',
    snapshotAwaitingRun: 'Berechnung ausstehend',
    capabilityDailyTitle: 'Tägliche Kalkulation',
    capabilityDailyDesc:
        'Berechnen Sie Nahtfläche, -länge, -volumen, Schweißgut, Zusatzwerkstoffbedarf, Lichtbogenzeit und Abschmelzannahmen in einem Arbeitsschritt.',
    capabilityDrawingTitle: 'Technische Zeichnung',
    capabilityDrawingDesc:
        'Zeigen Sie die Nahtgeometrie live im visuellen und technischen Modus, damit die Schnittzeichnung die Kalkulation stützt.',
    capabilityReportTitle: 'Berichts-Workflow',
    capabilityReportDesc:
        'Wandeln Sie die Live-Kalkulation in ein PDF-fertiges Ergebnis mit klarer technischer Grundlage und wiederverwendbaren Vorlagen um.',
    getStarted: 'Loslegen',
    languagePickerTitle: 'Sprache',
    emailGateHint: 'sie@beispiel.com',
    emailGateInvalidEmail: 'Geben Sie eine gültige E-Mail-Adresse ein',
    emailGateError:
        'Konnte gerade nicht gespeichert werden — Sie können trotzdem als Gast fortfahren.',
    emailGateWelcomeToast:
        'Fertig — prüfen Sie Ihr Postfach für die Willkommensnachricht.',
    authChoiceTitle: 'Willkommen bei Varyos Weld',
    authChoiceBody:
        'Erstellen Sie ein Konto, um Ihre Vorlagen und Berichte geräteübergreifend zu speichern, oder fahren Sie direkt als Gast fort.',
    authChoiceRegisterButton: 'Registrieren',
    authChoiceGuestButton: 'Als Gast fortfahren',
    authFormTitle: 'Konto erstellen',
    authFormFirstNameLabel: 'Vorname',
    authFormFirstNameHint: 'Anna',
    authFormLastNameLabel: 'Nachname',
    authFormLastNameHint: 'Schmidt',
    authFormEmailLabel: 'E-Mail',
    authFormSubmitButton: 'Konto erstellen',
    authFormFirstNameError: 'Geben Sie Ihren Vornamen ein',
    authFormLastNameError: 'Geben Sie Ihren Nachnamen ein',
    dashboardTitle: 'Startseite',
    dashboardFillerConsumption: 'Zusatzwerkstoffverbrauch',
    dashboardSavedCalculations: 'Gespeicherte Berechnungen',
    dashboardBaseMaterial: 'Grundwerkstoff',
    dashboardFillerMaterial: 'Zusatzwerkstoff',
    dashboardSavedReports: 'Gespeicherte Berichte',
    commonSave: 'Speichern',
    commonCancel: 'Abbrechen',
    commonDelete: 'Löschen',
    commonEdit: 'Bearbeiten',
    commonNameRequired: 'Name ist erforderlich',
    baseMaterialTitle: 'Grundwerkstoff',
    baseMaterialEmptyState:
        'Noch kein Grundwerkstoff vorhanden. Fügen Sie einen hinzu, um Ihre Bibliothek aufzubauen.',
    baseMaterialAddButton: 'Grundwerkstoff hinzufügen',
    baseMaterialFieldName: 'Name',
    baseMaterialFieldDesignation: 'Bezeichnung',
    baseMaterialFieldNotes: 'Notizen',
    baseMaterialDeleteConfirmTitle: 'Grundwerkstoff löschen',
    baseMaterialDeleteConfirmBody:
        '„{name}“ aus Ihrer Grundwerkstoff-Bibliothek löschen? Dies kann nicht rückgängig gemacht werden.',
    baseMaterialSectionThickness: 'Blechdicke',
    baseMaterialFieldThickness: 'Blechdicke (d, mm)',
    baseMaterialFieldThicknessMin: 'Min. Blechdicke (dmin, mm)',
    baseMaterialFieldThicknessMax: 'Max. Blechdicke (dmax, mm)',
    fillerMaterialTitle: 'Zusatzwerkstoff',
    fillerMaterialEmptyState:
        'Noch kein Zusatzwerkstoff vorhanden. Fügen Sie einen hinzu, um Ihre Bibliothek aufzubauen.',
    fillerMaterialAddButton: 'Zusatzwerkstoff hinzufügen',
    fillerMaterialFieldName: 'Name',
    fillerMaterialFieldFamily: 'Werkstoffgruppe',
    fillerMaterialFieldAws: 'AWS-Spezifikation',
    fillerMaterialFieldDensity: 'Dichte (g/cm³)',
    fillerMaterialFieldNotes: 'Notizen',
    fillerMaterialDensityInvalid: 'Geben Sie eine gültige Dichte ein',
    fillerMaterialDeleteConfirmTitle: 'Zusatzwerkstoff löschen',
    fillerMaterialDeleteConfirmBody:
        '„{name}“ aus Ihrer Zusatzwerkstoff-Bibliothek löschen? Dies kann nicht rückgängig gemacht werden.',
    materialSectionProducer: 'Herstellerdaten',
    materialFieldProducerName: 'Herstellername',
    materialFieldMaterialId: 'Werkstoffnummer',
    materialSectionComposition: 'Chemische Zusammensetzung',
    materialFieldCarbon: 'C (%)',
    materialFieldSilicon: 'Si (%)',
    materialFieldManganese: 'Mn (%)',
    materialFieldChromium: 'Cr (%)',
    materialFieldMolybdenum: 'Mo (%)',
    materialFieldCopper: 'Cu (%)',
    materialFieldVanadium: 'V (%)',
    materialFieldNiobium: 'Nb (%)',
    materialFieldTitanium: 'Ti (%)',
    materialFieldBoron: 'B (%)',
    materialFieldNitrogen: 'N (%)',
    materialCompositionOrDivider: 'ODER CET / Pcm direkt eingeben',
    materialFieldCet: 'CET (%)',
    materialFieldPcm: 'Pcm (%)',
    materialFieldInvalidNumber: 'Geben Sie eine gültige Zahl ein',
    materialFieldOutOfRange: 'Geben Sie einen Wert im gültigen Bereich ein',
    consumableFamilyCarbonSteel: 'Kohlenstoffstahl',
    consumableFamilyStainlessSteel: 'Nichtrostender Stahl',
    consumableFamilyDissimilar: 'Mischverbindung',
    consumableFamilyAluminium: 'Aluminium',
    consumableFamilyLowAlloySteel: 'Niedriglegierter Stahl',
    consumableFamilyNickelAlloy: 'Nickellegierung',
    consumableFamilyCopperAlloy: 'Kupferlegierung',
    consumableFamilyCastIron: 'Gusseisen',
    savedReportsTitle: 'Gespeicherte Berichte',
    savedReportsEmptyState:
        'Noch keine gespeicherten Berichte. Sie erscheinen hier nach einem PDF-Export.',
    savedReportsShareButton: 'Teilen',
    savedReportsDeleteButton: 'Löschen',
    savedReportsDeleteConfirmTitle: 'Bericht löschen',
    savedReportsDeleteConfirmBody:
        '„{name}“ aus Ihren gespeicherten Berichten löschen? Dies kann nicht rückgängig gemacht werden.',
    savedReportsShareError:
        'Bericht konnte nicht geteilt werden. Bitte versuchen Sie es erneut.',
    savedCalculationsTitle: 'Gespeicherte Berechnungen',
    savedCalculationsEmptyState:
        'Noch keine gespeicherten Berechnungen. Speichern Sie eine im Zusammenfassungsschritt des Rechners, um sie hier zu sehen.',
    savedCalculationsGuestState:
        'Melden Sie sich an, indem Sie eine Berechnung im Rechner speichern, um Ihre Liste hier aufzubauen.',
    savedCalculationsLoadButton: 'Laden',
    savedCalculationsRenameTitle: 'Vorlage umbenennen',
    savedCalculationsRenameFieldLabel: 'Vorlagenname',
    savedCalculationsRenameError:
        'Vorlage konnte nicht umbenannt werden. Bitte versuchen Sie es erneut.',
    savedCalculationsDeleteConfirmTitle: 'Vorlage löschen',
    savedCalculationsDeleteConfirmBody:
        '„{name}“ aus Ihren gespeicherten Berechnungen löschen? Dies kann nicht rückgängig gemacht werden.',
    savedCalculationsDeleteError:
        'Vorlage konnte nicht gelöscht werden. Bitte versuchen Sie es erneut.',
    presetProcessSwitchConfirmTitle: 'Schweißverfahren wechseln?',
    presetProcessSwitchConfirmBody:
        'Diese Startvorlage verwendet normalerweise {presetProcess}. Schweißverfahren entsprechend wechseln oder {currentProcess} beibehalten?',
    presetProcessSwitchConfirmSwitchButton: 'Zu {presetProcess} wechseln',
    presetProcessSwitchConfirmKeepButton: '{currentProcess} beibehalten',
    presetSaveError:
        'Vorlage konnte nicht gespeichert werden. Bitte versuchen Sie es erneut.',
    presetSaved: 'Vorlage gespeichert.',
    presetSavedOffline:
        'Nur auf diesem Gerät gespeichert — wird synchronisiert, sobald Sie wieder online sind.',
    presetUpdated: 'Gespeicherte Berechnung aktualisiert.',
    presetUpdatedOffline:
        'Nur auf diesem Gerät aktualisiert — wird synchronisiert, sobald Sie wieder online sind.',
    presetRestored:
        'Diese gespeicherte Berechnung wurde anderswo entfernt und wurde wiederhergestellt.',
    presetRestoredOffline:
        'Diese gespeicherte Berechnung wurde anderswo entfernt und nur auf diesem Gerät wiederhergestellt — wird synchronisiert, sobald Sie wieder online sind.',
    savedCalculationsSkippedWarning:
        '{count} gespeicherte Berechnung(en) konnten nicht geladen werden und wurden übersprungen.',
    dashboardPreheatCalculator: 'Vorwärmtemperatur',
    dashboardCoolingTimeCalculator: 'Abkühlzeit (t8/5)',
    materialFieldNickel: 'Nickel (Ni) %',
    preheatScreenTitle: 'Vorwärmtemperatur-Rechner',
    preheatScreenSubtitle: 'EN 1011-2 Methode B (CET-basiert)',
    preheatCompositionCardTitle:
        'Chemische Zusammensetzung des Grundwerkstoffs',
    preheatCompositionCardSubtitle: 'Gewichtsprozent eingeben; leer = 0%',
    preheatLoadFromLibraryLabel: 'Aus gespeichertem Grundwerkstoff laden',
    preheatBlankMeansZeroNote:
        'Lassen Sie ein Element leer, wenn es nicht analysiert wurde oder nicht vorhanden ist — es wird in der Berechnung als 0% behandelt.',
    preheatWeldMetalCetLabel:
        'Schweißgut-CET % (optional — für die Sonderregel)',
    preheatJointCardTitle: 'Verbindung & Verfahren',
    preheatThicknessLabel: 'Blechdicke (mm)',
    preheatHdLabel: 'Diffusibler Wasserstoff HD (ml/100g, ISO 3690)',
    preheatYieldStrengthLabel: 'Streckgrenze des Stahls (N/mm², optional)',
    preheatCalculateButton: 'Vorwärmtemperatur berechnen',
    preheatResultLabel: 'Empfohlene Vorwärmtemperatur',
    preheatNoPreheatRequiredLabel: 'Kein Vorwärmen erforderlich',
    preheatComputedValueBelowAmbientNote:
        'Berechneter Methode-B-Wert: {value} °C (unter der Umgebungsreferenz von 20 °C).',
    preheatSpecialRuleNote:
        'Design-CET auf {value}% angepasst gemäß der Sonderregel von EN 1011-2 (Schweißgut-CET + 0,03%).',
    preheatWarningCetOutOfRange:
        'CET beträgt {value}% — außerhalb des validierten Bereichs der Norm von 0,2–0,5%. Behandeln Sie dieses Ergebnis mit besonderer Vorsicht.',
    preheatWarningThicknessOutOfRange:
        'Dicke beträgt {value} mm — außerhalb des validierten Bereichs der Norm von 10–90 mm.',
    preheatWarningHdOutOfRange:
        'Diffusibler Wasserstoff beträgt {value} ml/100g — außerhalb des validierten Bereichs der Norm von 1–20 ml/100g.',
    preheatWarningHeatInputOutOfRange:
        'Streckenenergie beträgt {value} kJ/mm — außerhalb des validierten Bereichs der Norm von 0,5–4,0 kJ/mm.',
    preheatWarningYieldOutOfRange:
        'Streckgrenze beträgt {value} N/mm² — über dem validierten Grenzwert der Norm von 1000 N/mm².',
    preheatIso15608Note:
        'Diese Methode (EN 1011-2 Anhang C.3, Methode B) ist für Stahlgruppen 1–4 nach ISO/TR 15608 validiert (übliche Baustähle und Druckbehälterstähle). Überprüfen Sie die Gruppe Ihres Stahls separat, bevor Sie sich bei hochlegierten oder exotischen Güten auf dieses Ergebnis verlassen.',
    preheatOtherCarbonEquivalentsTitle:
        'Andere Kohlenstoffäquivalente (nur zur Referenz)',
    preheatOtherCarbonEquivalentsCaption:
        'Nicht Teil von EN 1011-2 — nur informativ.',
    preheatUseInCoolingTimeButton:
        'Diese Vorwärmtemperatur im Abkühlzeit-Rechner verwenden',
    coolingScreenTitle: 'Abkühlzeit (t8/5)-Rechner',
    coolingScreenSubtitle: 'EN 1011-2 Anhang D.6',
    coolingTempCardTitle: 'Vorwärm-/Zwischenlagentemperatur',
    coolingT0Label: 'Vorwärm- oder Zwischenlagentemperatur T0 (°C)',
    coolingT0InvalidError:
        'Muss unter 500°C liegen — die Abkühlformel ist bei diesem Wert oder darüber nicht definiert.',
    coolingT0BelowMinError:
        'Muss mindestens -50°C betragen — das liegt weit unter jeder physikalisch plausiblen Vorwärm- oder Zwischenlagentemperatur beim Schweißen.',
    coolingHeatInputCardTitle: 'Streckenenergie',
    coolingJointCardTitle: 'Verbindung & Dicke',
    coolingJointTypeLabel: 'Verbindungsart',
    coolingJointTypeRunOnPlate: 'Auftragslage auf Blech / Raupe auf Blech',
    coolingJointTypeButtBetweenRuns: 'Stumpfnaht — zwischen den Lagen',
    coolingFilletNotSupportedNote:
        'Kehlnahtverbindungen werden noch nicht unterstützt — EN 1011-2 gibt nur einen Bereich an (F2 0,45–0,67) ohne Interpolationsregel, daher berechnet diese App dafür keinen Wert.',
    coolingThicknessLabel: 'Blechdicke (mm)',
    coolingCalculateButton: 'Abkühlzeit berechnen',
    coolingResultLabel: 'Abkühlzeit t8/5',
    coolingRegimeTwoD: '2D dünnes Blech',
    coolingRegimeThreeD: '3D dickes Blech',
    coolingRegimeExplanation:
        'Berechnet mit der {regime}-Formel (Übergangsdicke dt = {dt} mm für diese Eingaben).',
    coolingWarningHeatInputOutOfRange:
        'Streckenenergie beträgt {value} kJ/mm — außerhalb des typischen Bereichs von 0,5–4,0 kJ/mm aus den Rechenbeispielen von EN 1011-2.',
    coolingWarningThicknessOutOfRange:
        'Dicke beträgt {value} mm — außerhalb des typischen Bereichs für diese Berechnung; überprüfen Sie Ihre Eingaben.',
    heatInputDirectModeLabel: 'Direkt eingeben',
    heatInputArcParamsModeLabel: 'Aus Lichtbogenparametern berechnen',
    heatInputQLabel: 'Streckenenergie Q (kJ/mm)',
    heatInputProcessLabel: 'Schweißverfahren',
    heatInputProcessSaw: 'SAW',
    heatInputProcessSmaw: 'SMAW',
    heatInputProcessGmawMag: 'GMAW / MAG',
    heatInputVoltageLabel: 'Spannung (V)',
    heatInputCurrentLabel: 'Strom (A)',
    heatInputTravelSpeedLabel: 'Schweißgeschwindigkeit (mm/min)',
    heatInputComputedLabel: 'Berechnete Q: {value} kJ/mm',
    heatInputVerifiedProcessesNote:
        'Der thermische Lichtbogenwirkungsgrad ist in EN 1011-2 nur für SAW, SMAW und GMAW/MAG verifiziert. Wechseln Sie für andere Verfahren zu "Direkt eingeben" und geben Sie Q aus einer anderen Quelle an.',
  ),
  AppLanguage.hi: L10nStrings(
    navBrand: 'Varyos Weld',
    navSubtitle:
        'वेल्ड इंजीनियरों और क्लाइंट-फेसिंग प्लानिंग के लिए प्रोफेशनल एस्टिमेटिंग वर्कस्पेस।',
    navPillEstimator: 'बट और फिलेट एस्टिमेटर',
    navPillPdf: 'PDF तैयार',
    navPillAws: 'AWS कंज्यूमेबल डेटा',
    heroTag: 'इंजीनियरिंग प्रोडक्ट / एस्टिमेटिंग वर्कस्पेस',
    heroTitle: 'एक वेल्डिंग एस्टिमेटर जो तकनीकी, परिष्कृत और भरोसेमंद लगे।',
    heroBody:
        'वास्तविक जॉइंट ज्यामिति, AWS कंज्यूमेबल चयन और रिपोर्ट-ग्रेड परिणाम से एस्टिमेट बनाएं, जिसे क्लाइंट या प्रोडक्शन टीम को दिखाया जा सके।',
    heroSignalLiveJoint: 'लाइव जॉइंट',
    heroSignalGroove: 'ग्रूव',
    heroSignalProcess: 'प्रोसेस',
    snapshotTitle: 'सेशन स्नैपशॉट',
    snapshotDrawingMode: 'ड्रॉइंग मोड',
    snapshotConsumable: 'कंज्यूमेबल',
    snapshotSavedPresets: 'सेव्ड प्रीसेट',
    snapshotEstimateState: 'एस्टिमेट स्थिति',
    snapshotCalculated: 'गणना पूर्ण',
    snapshotAwaitingRun: 'गणना बाकी',
    capabilityDailyTitle: 'दैनिक एस्टिमेटिंग',
    capabilityDailyDesc:
        'वेल्ड एरिया, लंबाई, वॉल्यूम, वेल्ड मेटल, फिलर आवश्यकता, आर्क-ऑन टाइम और डिपॉज़िशन अनुमान एक ही फ्लो में निकालें।',
    capabilityDrawingTitle: 'टेक्निकल ड्रॉइंग',
    capabilityDrawingDesc:
        'विज़ुअल और इंजीनियरिंग मोड में लाइव ग्रूव ज्यामिति दिखाएं ताकि सेक्शन स्केच एस्टिमेट को सपोर्ट करे।',
    capabilityReportTitle: 'रिपोर्ट वर्कफ़्लो',
    capabilityReportDesc:
        'लाइव एस्टिमेट को स्पष्ट इंजीनियरिंग आधार और पुन: उपयोग योग्य प्रीसेट के साथ PDF-रेडी रिज़ल्ट में बदलें।',
    getStarted: 'शुरू करें',
    languagePickerTitle: 'भाषा',
    emailGateHint: 'aap@example.com',
    emailGateInvalidEmail: 'एक मान्य मेल पता दर्ज करें',
    emailGateError:
        'अभी सेव नहीं हो सका — आप फिर भी गेस्ट के रूप में जारी रख सकते हैं।',
    emailGateWelcomeToast: 'हो गया — वेलकम नोट के लिए अपना इनबॉक्स देखें।',
    authChoiceTitle: 'Varyos Weld में आपका स्वागत है',
    authChoiceBody:
        'अपने प्रीसेट और रिपोर्ट को सभी डिवाइस पर सेव रखने के लिए अकाउंट बनाएं, या सीधे गेस्ट के रूप में आगे बढ़ें।',
    authChoiceRegisterButton: 'रजिस्टर करें',
    authChoiceGuestButton: 'गेस्ट के रूप में जारी रखें',
    authFormTitle: 'अपना अकाउंट बनाएं',
    authFormFirstNameLabel: 'पहला नाम',
    authFormFirstNameHint: 'राज',
    authFormLastNameLabel: 'अंतिम नाम',
    authFormLastNameHint: 'शर्मा',
    authFormEmailLabel: 'ईमेल',
    authFormSubmitButton: 'अकाउंट बनाएं',
    authFormFirstNameError: 'अपना पहला नाम दर्ज करें',
    authFormLastNameError: 'अपना अंतिम नाम दर्ज करें',
    dashboardTitle: 'होम',
    dashboardFillerConsumption: 'फिलर मटेरियल खपत',
    dashboardSavedCalculations: 'सेव्ड कैलकुलेशन',
    dashboardBaseMaterial: 'बेस मटेरियल',
    dashboardFillerMaterial: 'फिलर मटेरियल',
    dashboardSavedReports: 'सेव्ड रिपोर्ट्स',
    commonSave: 'सेव करें',
    commonCancel: 'रद्द करें',
    commonDelete: 'डिलीट करें',
    commonEdit: 'एडिट करें',
    commonNameRequired: 'नाम आवश्यक है',
    baseMaterialTitle: 'बेस मटेरियल',
    baseMaterialEmptyState:
        'अभी तक कोई बेस मटेरियल नहीं है। अपनी लाइब्रेरी बनाने के लिए एक जोड़ें।',
    baseMaterialAddButton: 'बेस मटेरियल जोड़ें',
    baseMaterialFieldName: 'नाम',
    baseMaterialFieldDesignation: 'डेज़िग्नेशन',
    baseMaterialFieldNotes: 'नोट्स',
    baseMaterialDeleteConfirmTitle: 'बेस मटेरियल डिलीट करें',
    baseMaterialDeleteConfirmBody:
        'क्या अपनी बेस मटेरियल लाइब्रेरी से "{name}" डिलीट करें? यह वापस नहीं लिया जा सकता।',
    baseMaterialSectionThickness: 'शीट मोटाई',
    baseMaterialFieldThickness: 'शीट मोटाई (d, mm)',
    baseMaterialFieldThicknessMin: 'न्यूनतम शीट मोटाई (dmin, mm)',
    baseMaterialFieldThicknessMax: 'अधिकतम शीट मोटाई (dmax, mm)',
    fillerMaterialTitle: 'फिलर मटेरियल',
    fillerMaterialEmptyState:
        'अभी तक कोई फिलर मटेरियल नहीं है। अपनी लाइब्रेरी बनाने के लिए एक जोड़ें।',
    fillerMaterialAddButton: 'फिलर मटेरियल जोड़ें',
    fillerMaterialFieldName: 'नाम',
    fillerMaterialFieldFamily: 'फैमिली',
    fillerMaterialFieldAws: 'AWS स्पेसिफिकेशन',
    fillerMaterialFieldDensity: 'डेंसिटी (g/cm³)',
    fillerMaterialFieldNotes: 'नोट्स',
    fillerMaterialDensityInvalid: 'मान्य डेंसिटी दर्ज करें',
    fillerMaterialDeleteConfirmTitle: 'फिलर मटेरियल डिलीट करें',
    fillerMaterialDeleteConfirmBody:
        'क्या अपनी फिलर मटेरियल लाइब्रेरी से "{name}" डिलीट करें? यह वापस नहीं लिया जा सकता।',
    materialSectionProducer: 'निर्माता जानकारी',
    materialFieldProducerName: 'निर्माता का नाम',
    materialFieldMaterialId: 'मटेरियल आईडी',
    materialSectionComposition: 'रासायनिक संरचना',
    materialFieldCarbon: 'C (%)',
    materialFieldSilicon: 'Si (%)',
    materialFieldManganese: 'Mn (%)',
    materialFieldChromium: 'Cr (%)',
    materialFieldMolybdenum: 'Mo (%)',
    materialFieldCopper: 'Cu (%)',
    materialFieldVanadium: 'V (%)',
    materialFieldNiobium: 'Nb (%)',
    materialFieldTitanium: 'Ti (%)',
    materialFieldBoron: 'B (%)',
    materialFieldNitrogen: 'N (%)',
    materialCompositionOrDivider: 'या सीधे CET / Pcm दर्ज करें',
    materialFieldCet: 'CET (%)',
    materialFieldPcm: 'Pcm (%)',
    materialFieldInvalidNumber: 'मान्य संख्या दर्ज करें',
    materialFieldOutOfRange: 'मान्य सीमा में एक मान दर्ज करें',
    consumableFamilyCarbonSteel: 'कार्बन स्टील',
    consumableFamilyStainlessSteel: 'स्टेनलेस स्टील',
    consumableFamilyDissimilar: 'डिसिमिलर मेटल',
    consumableFamilyAluminium: 'एल्युमिनियम',
    consumableFamilyLowAlloySteel: 'लो एलॉय स्टील',
    consumableFamilyNickelAlloy: 'निकल एलॉय',
    consumableFamilyCopperAlloy: 'कॉपर एलॉय',
    consumableFamilyCastIron: 'कास्ट आयरन',
    savedReportsTitle: 'सेव्ड रिपोर्ट्स',
    savedReportsEmptyState:
        'अभी तक कोई सेव्ड रिपोर्ट नहीं है। PDF एक्सपोर्ट करने के बाद यह यहां दिखेगी।',
    savedReportsShareButton: 'शेयर करें',
    savedReportsDeleteButton: 'डिलीट करें',
    savedReportsDeleteConfirmTitle: 'रिपोर्ट डिलीट करें',
    savedReportsDeleteConfirmBody:
        'क्या सेव्ड रिपोर्ट्स से "{name}" डिलीट करें? यह वापस नहीं लिया जा सकता।',
    savedReportsShareError:
        'रिपोर्ट शेयर नहीं हो सकी। कृपया फिर से कोशिश करें।',
    savedCalculationsTitle: 'सेव्ड कैलकुलेशन्स',
    savedCalculationsEmptyState:
        'अभी तक कोई सेव्ड कैलकुलेशन नहीं है। इसे यहां देखने के लिए कैलकुलेटर के समरी स्टेप से एक सेव करें।',
    savedCalculationsGuestState:
        'यहां अपनी लिस्ट बनाना शुरू करने के लिए कैलकुलेटर से एक कैलकुलेशन सेव करके लॉग इन करें।',
    savedCalculationsLoadButton: 'लोड करें',
    savedCalculationsRenameTitle: 'प्रीसेट का नाम बदलें',
    savedCalculationsRenameFieldLabel: 'प्रीसेट का नाम',
    savedCalculationsRenameError:
        'प्रीसेट का नाम नहीं बदला जा सका। कृपया फिर से कोशिश करें।',
    savedCalculationsDeleteConfirmTitle: 'प्रीसेट डिलीट करें',
    savedCalculationsDeleteConfirmBody:
        'क्या सेव्ड कैलकुलेशन्स से "{name}" डिलीट करें? यह वापस नहीं लिया जा सकता।',
    savedCalculationsDeleteError:
        'प्रीसेट डिलीट नहीं हो सका। कृपया फिर से कोशिश करें।',
    presetProcessSwitchConfirmTitle: 'वेल्डिंग प्रोसेस बदलें?',
    presetProcessSwitchConfirmBody:
        'यह स्टार्टर टेम्पलेट आमतौर पर {presetProcess} इस्तेमाल करता है। इसके अनुसार वेल्डिंग प्रोसेस बदलें, या {currentProcess} बनाए रखें?',
    presetProcessSwitchConfirmSwitchButton: '{presetProcess} में बदलें',
    presetProcessSwitchConfirmKeepButton: '{currentProcess} बनाए रखें',
    presetSaveError: 'प्रीसेट सेव नहीं हो सका। कृपया फिर से कोशिश करें।',
    presetSaved: 'प्रीसेट सेव हो गया।',
    presetSavedOffline:
        'सिर्फ इस डिवाइस पर सेव हुआ — इंटरनेट से जुड़ते ही सिंक हो जाएगा।',
    presetUpdated: 'सेव की गई कैलकुलेशन अपडेट हो गई।',
    presetUpdatedOffline:
        'सिर्फ इस डिवाइस पर अपडेट हुआ — इंटरनेट से जुड़ते ही सिंक हो जाएगा।',
    presetRestored:
        'यह सेव की गई कैलकुलेशन कहीं और से हटा दी गई थी और इसे फिर से बहाल कर दिया गया।',
    presetRestoredOffline:
        'यह सेव की गई कैलकुलेशन कहीं और से हटा दी गई थी और सिर्फ इस डिवाइस पर बहाल हुई — इंटरनेट से जुड़ते ही सिंक हो जाएगा।',
    savedCalculationsSkippedWarning:
        '{count} सेव की गई कैलकुलेशन लोड नहीं हो सकीं और उन्हें छोड़ दिया गया।',
    dashboardPreheatCalculator: 'प्रीहीट तापमान',
    dashboardCoolingTimeCalculator: 'कूलिंग टाइम (t8/5)',
    materialFieldNickel: 'निकल (Ni) %',
    preheatScreenTitle: 'प्रीहीट तापमान कैलकुलेटर',
    preheatScreenSubtitle: 'EN 1011-2 मेथड B (CET आधारित)',
    preheatCompositionCardTitle: 'मूल धातु संरचना',
    preheatCompositionCardSubtitle:
        'वज़न के अनुसार प्रतिशत दर्ज करें; खाली = 0%',
    preheatLoadFromLibraryLabel: 'सेव किए गए मूल धातु से लोड करें',
    preheatBlankMeansZeroNote:
        'अगर कोई तत्व विश्लेषित नहीं हुआ या मौजूद नहीं है तो उसे खाली छोड़ दें — गणना में इसे 0% माना जाएगा।',
    preheatWeldMetalCetLabel: 'वेल्ड मेटल CET % (वैकल्पिक — विशेष नियम के लिए)',
    preheatJointCardTitle: 'जॉइंट और प्रोसेस',
    preheatThicknessLabel: 'प्लेट मोटाई (mm)',
    preheatHdLabel: 'डिफ्यूज़िबल हाइड्रोजन HD (ml/100g, ISO 3690)',
    preheatYieldStrengthLabel: 'स्टील यील्ड स्ट्रेंथ (N/mm², वैकल्पिक)',
    preheatCalculateButton: 'प्रीहीट तापमान की गणना करें',
    preheatResultLabel: 'अनुशंसित प्रीहीट तापमान',
    preheatNoPreheatRequiredLabel: 'प्रीहीट की आवश्यकता नहीं',
    preheatComputedValueBelowAmbientNote:
        'गणना किया गया मेथड B मान: {value} °C (20 °C एम्बिएंट संदर्भ से कम)।',
    preheatSpecialRuleNote:
        'EN 1011-2 के विशेष नियम (वेल्ड मेटल CET + 0.03%) के अनुसार डिज़ाइन CET को {value}% पर समायोजित किया गया।',
    preheatWarningCetOutOfRange:
        'CET {value}% है — मानक की मान्य सीमा 0.2–0.5% से बाहर। इस परिणाम को अतिरिक्त सावधानी से लें।',
    preheatWarningThicknessOutOfRange:
        'मोटाई {value} mm है — मानक की मान्य सीमा 10–90 mm से बाहर।',
    preheatWarningHdOutOfRange:
        'डिफ्यूज़िबल हाइड्रोजन {value} ml/100g है — मानक की मान्य सीमा 1–20 ml/100g से बाहर।',
    preheatWarningHeatInputOutOfRange:
        'हीट इनपुट {value} kJ/mm है — मानक की मान्य सीमा 0.5–4.0 kJ/mm से बाहर।',
    preheatWarningYieldOutOfRange:
        'यील्ड स्ट्रेंथ {value} N/mm² है — मानक की मान्य सीमा 1000 N/mm² से अधिक।',
    preheatIso15608Note:
        'यह विधि (EN 1011-2 परिशिष्ट C.3, मेथड B) ISO/TR 15608 के अनुसार स्टील ग्रुप 1–4 (सामान्य संरचनात्मक और प्रेशर-वेसल स्टील) के लिए मान्य है। हाई-अलॉय या असामान्य ग्रेड के लिए इस परिणाम पर भरोसा करने से पहले अपने स्टील का ग्रुप अलग से जांच लें।',
    preheatOtherCarbonEquivalentsTitle:
        'अन्य कार्बन इक्विवैलेंट (केवल संदर्भ हेतु)',
    preheatOtherCarbonEquivalentsCaption:
        'EN 1011-2 का हिस्सा नहीं है — केवल जानकारी हेतु।',
    preheatUseInCoolingTimeButton:
        'इस प्रीहीट तापमान को कूलिंग टाइम कैलकुलेटर में इस्तेमाल करें',
    coolingScreenTitle: 'कूलिंग टाइम (t8/5) कैलकुलेटर',
    coolingScreenSubtitle: 'EN 1011-2 परिशिष्ट D.6',
    coolingTempCardTitle: 'प्रीहीट / इंटरपास तापमान',
    coolingT0Label: 'प्रीहीट या इंटरपास तापमान T0 (°C)',
    coolingT0InvalidError:
        '500°C से कम होना चाहिए — इस मान पर या इससे ऊपर कूलिंग फॉर्मूला अपरिभाषित है।',
    coolingT0BelowMinError:
        '-50°C या उससे अधिक होना चाहिए — यह वेल्डिंग के लिए किसी भी भौतिक रूप से संभव प्रीहीट या इंटरपास तापमान से काफी कम है।',
    coolingHeatInputCardTitle: 'हीट इनपुट',
    coolingJointCardTitle: 'जॉइंट और मोटाई',
    coolingJointTypeLabel: 'जॉइंट टाइप',
    coolingJointTypeRunOnPlate: 'रन-ऑन-प्लेट / बीड-ऑन-प्लेट',
    coolingJointTypeButtBetweenRuns: 'बट वेल्ड — पासों के बीच',
    coolingFilletNotSupportedNote:
        'फिलेट वेल्ड जॉइंट अभी समर्थित नहीं हैं — EN 1011-2 केवल एक रेंज (F2 0.45–0.67) देता है, बिना किसी इंटरपोलेशन नियम के, इसलिए यह ऐप इनके लिए कोई मान नहीं निकालता।',
    coolingThicknessLabel: 'प्लेट मोटाई (mm)',
    coolingCalculateButton: 'कूलिंग टाइम की गणना करें',
    coolingResultLabel: 'कूलिंग टाइम t8/5',
    coolingRegimeTwoD: '2D पतली प्लेट',
    coolingRegimeThreeD: '3D मोटी प्लेट',
    coolingRegimeExplanation:
        '{regime} फॉर्मूला का उपयोग करके गणना की गई (इन इनपुट के लिए ट्रांज़िशन मोटाई dt = {dt} mm)।',
    coolingWarningHeatInputOutOfRange:
        'हीट इनपुट {value} kJ/mm है — EN 1011-2 के उदाहरणों में देखी गई सामान्य 0.5–4.0 kJ/mm रेंज से बाहर।',
    coolingWarningThicknessOutOfRange:
        'मोटाई {value} mm है — इस गणना के लिए सामान्य सीमा से बाहर; अपने इनपुट दोबारा जांचें।',
    heatInputDirectModeLabel: 'सीधे दर्ज करें',
    heatInputArcParamsModeLabel: 'आर्क पैरामीटर से गणना करें',
    heatInputQLabel: 'नेट हीट इनपुट Q (kJ/mm)',
    heatInputProcessLabel: 'वेल्डिंग प्रोसेस',
    heatInputProcessSaw: 'SAW',
    heatInputProcessSmaw: 'SMAW',
    heatInputProcessGmawMag: 'GMAW / MAG',
    heatInputVoltageLabel: 'वोल्टेज (V)',
    heatInputCurrentLabel: 'करंट (A)',
    heatInputTravelSpeedLabel: 'ट्रैवल स्पीड (mm/min)',
    heatInputComputedLabel: 'गणना की गई Q: {value} kJ/mm',
    heatInputVerifiedProcessesNote:
        "आर्क थर्मल एफिशिएंसी EN 1011-2 में केवल SAW, SMAW और GMAW/MAG के लिए वेरिफाई की गई है। अन्य प्रोसेस के लिए 'सीधे दर्ज करें' पर स्विच करें और Q किसी अन्य स्रोत से दर्ज करें।",
  ),
};

L10nStrings stringsFor(AppLanguage language) => _strings[language]!;

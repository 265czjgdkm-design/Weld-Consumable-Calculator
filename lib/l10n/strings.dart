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
    required this.commonBack,
    required this.commonContinue,
    required this.commonCalculate,
    required this.commonReset,
    required this.commonUpdate,
    required this.commonDone,
    required this.jointTypePipeButt,
    required this.jointTypePlateButt,
    required this.jointTypeFillet,
    required this.jointTypeHelperPipeButt,
    required this.jointTypeHelperPlateButt,
    required this.jointTypeHelperFillet,
    required this.grooveSingleV,
    required this.grooveHalfV,
    required this.grooveDoubleV,
    required this.grooveCompoundV,
    required this.grooveSquare,
    required this.grooveFillet,
    required this.depositionRateModePreset,
    required this.depositionRateModeManual,
    required this.jointGeometryEqual,
    required this.jointGeometryUnequal,
    required this.jointAlignmentCenterline,
    required this.jointAlignmentOdMatch,
    required this.jointAlignmentIdMatch,
    required this.drawingModeVisual,
    required this.drawingModeTechnical,
    required this.inputPresetCustom,
    required this.inputPresetCsPipeSingleVGtawSmaw,
    required this.inputPresetCsPipeDoubleVGtawSmaw,
    required this.inputPresetSsPipeSingleVGtaw,
    required this.inputPresetCsPlateSingleVGmaw,
    required this.inputPresetCsPlateDoubleVSmaw,
    required this.inputPresetCsFilletFcaw,
    required this.inputPresetDescCustom,
    required this.inputPresetDescCsPipeSingleVGtawSmaw,
    required this.inputPresetDescCsPipeDoubleVGtawSmaw,
    required this.inputPresetDescSsPipeSingleVGtaw,
    required this.inputPresetDescCsPlateSingleVGmaw,
    required this.inputPresetDescCsPlateDoubleVSmaw,
    required this.inputPresetDescCsFilletFcaw,
    required this.consumablePresetDescEr70s6,
    required this.consumablePresetDescEr70s2,
    required this.consumablePresetDescE7018,
    required this.consumablePresetDescE6010,
    required this.consumablePresetDescE71t1,
    required this.consumablePresetDescEr308l,
    required this.consumablePresetDescE308l16,
    required this.consumablePresetDescEr316l,
    required this.consumablePresetDescEr309l,
    required this.consumablePresetDescE309l16,
    required this.consumablePresetDescEr5356,
    required this.consumablePresetDescGtawRootSmawFill,
    required this.consumablePresetDescE6013,
    required this.consumablePresetDescE7024,
    required this.consumablePresetDescEr70s3,
    required this.consumablePresetDescE7018a1,
    required this.consumablePresetDescE8018c3,
    required this.consumablePresetDescEr80sNi1,
    required this.consumablePresetDescEr80sB2,
    required this.consumablePresetDescE316l16,
    required this.consumablePresetDescEr347,
    required this.consumablePresetDescEr4043,
    required this.consumablePresetDescEr5183,
    required this.consumablePresetDescEniCi,
    required this.consumablePresetDescEnifeCi,
    required this.consumablePresetDescErnicr3,
    required this.consumablePresetDescEnicrfe3,
    required this.consumablePresetDescErcusiA,
    required this.consumablePresetDescEcualA2,
    required this.consumableCustomFallbackDescription,
    required this.consumableCustomNoTypicalBaseMetals,
    required this.calcActiveEngineeringBasisTitle,
    required this.calcJointTypeSectionTitle,
    required this.calcMemberGeometrySectionTitle,
    required this.calcAlignmentReferenceLabel,
    required this.calcAlignmentReferenceHelper,
    required this.calcGrooveTypeLabel,
    required this.calcWeldingProcessLabel,
    required this.calcStartingTemplateTitle,
    required this.calcStartingTemplateSubtitle,
    required this.calcInputPresetLabel,
    required this.calcConsumableDensityTitle,
    required this.calcConsumableDensitySubtitle,
    required this.calcConsumableClassificationLabel,
    required this.calcConsumableClassificationHelper,
    required this.calcMyMaterialsHeader,
    required this.calcAsSavedSuffix,
    required this.drawingLabelFilletWeldFace,
    required this.drawingLabelTJoint,
    required this.drawingLabelSmawFillCap,
    required this.drawingLabelGtawRoot,
    required this.calcSelectedClassificationNote,
    required this.calcTypicalBaseMetalsNote,
    required this.calcRateBasisTitle,
    required this.calcRateBasisSubtitle,
    required this.calcPresetRateHelperDefault,
    required this.calcPresetRateHelperGtawSmaw,
    required this.calcManualRateHelperDefault,
    required this.calcManualRateHelperGtawSmaw,
    required this.calcInputParametersTitle,
    required this.calcInputParametersSubtitle,
    required this.calcDimensionalInputsTitle,
    required this.calcDimensionalInputsSubtitle,
    required this.calcRunEstimateTitle,
    required this.calcRunEstimateSubtitle,
    required this.calcSaveAsPresetLabel,
    required this.calcUpdateSavedCalculationLabel,
    required this.calcPdfHintBeforeResult,
    required this.calcPdfHintAfterResult,
    required this.calcResultsTitle,
    required this.calcEmptyResultsBodyDefault,
    required this.calcEmptyResultsBodyGtawSmaw,
    required this.calcEditInputsTooltip,
    required this.calcEditInputsButton,
    required this.calcBackToDashboardTooltip,
    required this.techDrawingTitle,
    required this.techDrawingModeTechnicalDesc,
    required this.techDrawingModeVisualDesc,
    required this.calcCustomDiameterOption,
    required this.calcCustomDiameterLabel,
    required this.calcCustomDiameterHelper,
    required this.calcPresetNameDialogSaveTitle,
    required this.calcPresetNameDialogUpdateTitle,
    required this.calcPresetNameHelper,
    required this.calcSaveWithAccountTitle,
    required this.calcSaveWithAccountBody,
    required this.calcAccountEmailInvalidError,
    required this.calcCalculationFailedError,
    required this.calcFieldRequiredError,
    required this.calcErrorLabelQuantity,
    required this.calcErrorLabelDensity,
    required this.calcErrorLabelWasteFactor,
    required this.calcFieldQuantityLabel,
    required this.calcFieldQuantityHelper,
    required this.calcFieldWeldLengthLabel,
    required this.calcFieldWeldLengthHelper,
    required this.calcFieldPipeOdALabel,
    required this.calcFieldPipeOdAHelper,
    required this.calcFieldPipeOdBLabel,
    required this.calcFieldPipeOdBHelper,
    required this.calcFieldPipeOdLabel,
    required this.calcFieldPipeOdHelper,
    required this.calcFieldThicknessALabel,
    required this.calcFieldThicknessAHelper,
    required this.calcFieldThicknessBLabel,
    required this.calcFieldThicknessBHelper,
    required this.calcFieldRootGapLabel,
    required this.calcFieldRootGapHelper,
    required this.calcFieldThicknessLabel,
    required this.calcFieldThicknessHelper,
    required this.calcFieldRootFacePerSideLabel,
    required this.calcFieldRootFacePerSideHelper,
    required this.calcFieldRootFaceLabel,
    required this.calcFieldRootFaceHelper,
    required this.calcFieldBevelAngleLabel,
    required this.calcFieldBevelAngleHelper,
    required this.calcFieldPrimaryAngleLabel,
    required this.calcFieldPrimaryAngleHelper,
    required this.calcFieldSecondaryAngleLabel,
    required this.calcFieldSecondaryAngleHelper,
    required this.calcFieldBreakHeightLabel,
    required this.calcFieldBreakHeightHelper,
    required this.calcFieldLegSizeLabel,
    required this.calcFieldLegSizeHelper,
    required this.calcFieldGtawWireDiameterLabel,
    required this.calcFieldGtawWireDiameterHelper,
    required this.calcFieldSmawElectrodeDiameterLabel,
    required this.calcFieldSmawElectrodeDiameterHelper,
    required this.calcFieldGmawWireDiameterLabel,
    required this.calcFieldGmawWireDiameterHelper,
    required this.calcFieldFcawWireDiameterLabel,
    required this.calcFieldFcawWireDiameterHelper,
    required this.calcFieldGtawTransitionLabel,
    required this.calcFieldGtawTransitionHelper,
    required this.calcFieldGtawDepositionRateLabel,
    required this.calcFieldGtawDepositionRateHelper,
    required this.calcFieldSmawDepositionRateLabel,
    required this.calcFieldSmawDepositionRateHelper,
    required this.calcFieldDepositionRateLabel,
    required this.calcFieldDepositionRateHelper,
    required this.calcFieldDensityLabel,
    required this.calcFieldDensityHelper,
    required this.calcFieldWasteAllowanceLabel,
    required this.calcFieldWasteAllowanceHelper,
    required this.basisProcess,
    required this.basisRateBasis,
    required this.basisInputPreset,
    required this.basisSavedPreset,
    required this.basisJoint,
    required this.basisGeometry,
    required this.basisAlignment,
    required this.basisGroove,
    required this.basisClassification,
    required this.basisFillerMetalFamily,
    required this.basisDensity,
    required this.basisWasteAllowance,
    required this.basisQuantity,
    required this.basisWeldLengthPerPiece,
    required this.basisPipeOd,
    required this.basisThickness,
    required this.basisThicknessA,
    required this.basisThicknessB,
    required this.basisControllingThickness,
    required this.basisOdA,
    required this.basisOdB,
    required this.basisReferenceOd,
    required this.basisRootGap,
    required this.basisRootFace,
    required this.basisRootFacePerSide,
    required this.basisBevelAngle,
    required this.basisPrimaryBevelAngle,
    required this.basisSecondaryBevelAngle,
    required this.basisBreakHeight,
    required this.basisFilletLegSize,
    required this.basisUserDefinedRate,
    required this.basisWireDiameter,
    required this.basisElectrodeDiameter,
    required this.basisGtawTransitionDepth,
    required this.basisGtawDepositionRate,
    required this.basisGtawWireDiameter,
    required this.basisSmawDepositionRate,
    required this.basisSmawElectrodeDiameter,
    required this.wizardJointDimensionsTitle,
    required this.wizardConsumableRateTitle,
    required this.wizardProcessStepSubtitle,
    required this.wizardReviewCalculateTitle,
    required this.wizardReviewCalculateSubtitle,
    required this.wizardRecapProcessTitle,
    required this.wizardRecapDimensionsTitle,
    required this.wizardRecapConsumableTitle,
    required this.wizardStepOfLabel,
    required this.resultsSummaryCaption,
    required this.resultsDisclaimer,
    required this.resultsPdfPreparing,
    required this.resultsPdfUnlock,
    required this.resultsPdfExport,
    required this.resultsEstimateReadyBadge,
    required this.resultsHighlightSentence,
    required this.resultsHighlightEffectiveRate,
    required this.resultsHighlightFillerPerMeter,
    required this.resultsHighlightArcOnPerMeter,
    required this.metricWeldArea,
    required this.metricWeldLength,
    required this.metricWeldMetalVolume,
    required this.metricWeldMetalWeight,
    required this.metricFillerMetalConsumption,
    required this.metricEstimatedArcOnTime,
    required this.metricEffectiveDepositionEfficiency,
    required this.metricEffectiveDepositionRate,
    required this.resultsNextStandardLeg,
    required this.insightWeldMetalPerMeter,
    required this.insightFillerPerJoint,
    required this.insightArcOnPerJoint,
    required this.insightEfficiencyLossBasis,
    required this.insightWasteAllowanceBasis,
    required this.insightConsumptionMultiplier,
    required this.processBreakdownTitle,
    required this.processBreakdownSubtitle,
    required this.processBreakdownAreaShare,
    required this.processBreakdownWeldMetal,
    required this.processBreakdownFillerConsumption,
    required this.processBreakdownArcOnTime,
    required this.processBreakdownDepositionRate,
    required this.processBreakdownDepositionEfficiency,
    required this.engineeringBasisTitle,
    required this.engineeringBasisSubtitle,
    required this.planningIndicatorsTitle,
    required this.planningIndicatorsSubtitle,
    required this.engineeringNotesTitle,
    required this.engineeringNote1,
    required this.engineeringNote2,
    required this.engineeringNote3,
    required this.engineeringNote4,
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
  final String commonBack;
  final String commonContinue;
  final String commonCalculate;
  final String commonReset;
  final String commonUpdate;
  final String commonDone;
  final String jointTypePipeButt;
  final String jointTypePlateButt;
  final String jointTypeFillet;
  final String jointTypeHelperPipeButt;
  final String jointTypeHelperPlateButt;
  final String jointTypeHelperFillet;
  final String grooveSingleV;
  final String grooveHalfV;
  final String grooveDoubleV;
  final String grooveCompoundV;
  final String grooveSquare;
  final String grooveFillet;
  final String depositionRateModePreset;
  final String depositionRateModeManual;
  final String jointGeometryEqual;
  final String jointGeometryUnequal;
  final String jointAlignmentCenterline;
  final String jointAlignmentOdMatch;
  final String jointAlignmentIdMatch;
  final String drawingModeVisual;
  final String drawingModeTechnical;
  final String inputPresetCustom;
  final String inputPresetCsPipeSingleVGtawSmaw;
  final String inputPresetCsPipeDoubleVGtawSmaw;
  final String inputPresetSsPipeSingleVGtaw;
  final String inputPresetCsPlateSingleVGmaw;
  final String inputPresetCsPlateDoubleVSmaw;
  final String inputPresetCsFilletFcaw;
  final String inputPresetDescCustom;
  final String inputPresetDescCsPipeSingleVGtawSmaw;
  final String inputPresetDescCsPipeDoubleVGtawSmaw;
  final String inputPresetDescSsPipeSingleVGtaw;
  final String inputPresetDescCsPlateSingleVGmaw;
  final String inputPresetDescCsPlateDoubleVSmaw;
  final String inputPresetDescCsFilletFcaw;
  final String consumablePresetDescEr70s6;
  final String consumablePresetDescEr70s2;
  final String consumablePresetDescE7018;
  final String consumablePresetDescE6010;
  final String consumablePresetDescE71t1;
  final String consumablePresetDescEr308l;
  final String consumablePresetDescE308l16;
  final String consumablePresetDescEr316l;
  final String consumablePresetDescEr309l;
  final String consumablePresetDescE309l16;
  final String consumablePresetDescEr5356;
  final String consumablePresetDescGtawRootSmawFill;
  final String consumablePresetDescE6013;
  final String consumablePresetDescE7024;
  final String consumablePresetDescEr70s3;
  final String consumablePresetDescE7018a1;
  final String consumablePresetDescE8018c3;
  final String consumablePresetDescEr80sNi1;
  final String consumablePresetDescEr80sB2;
  final String consumablePresetDescE316l16;
  final String consumablePresetDescEr347;
  final String consumablePresetDescEr4043;
  final String consumablePresetDescEr5183;
  final String consumablePresetDescEniCi;
  final String consumablePresetDescEnifeCi;
  final String consumablePresetDescErnicr3;
  final String consumablePresetDescEnicrfe3;
  final String consumablePresetDescErcusiA;
  final String consumablePresetDescEcualA2;
  final String consumableCustomFallbackDescription;
  final String consumableCustomNoTypicalBaseMetals;
  final String calcActiveEngineeringBasisTitle;
  final String calcJointTypeSectionTitle;
  final String calcMemberGeometrySectionTitle;
  final String calcAlignmentReferenceLabel;
  final String calcAlignmentReferenceHelper;
  final String calcGrooveTypeLabel;
  final String calcWeldingProcessLabel;
  final String calcStartingTemplateTitle;
  final String calcStartingTemplateSubtitle;
  final String calcInputPresetLabel;
  final String calcConsumableDensityTitle;
  final String calcConsumableDensitySubtitle;
  final String calcConsumableClassificationLabel;
  final String calcConsumableClassificationHelper;
  final String calcMyMaterialsHeader;
  final String calcAsSavedSuffix;
  final String drawingLabelFilletWeldFace;
  final String drawingLabelTJoint;
  final String drawingLabelSmawFillCap;
  final String drawingLabelGtawRoot;
  final String calcSelectedClassificationNote;
  final String calcTypicalBaseMetalsNote;
  final String calcRateBasisTitle;
  final String calcRateBasisSubtitle;
  final String calcPresetRateHelperDefault;
  final String calcPresetRateHelperGtawSmaw;
  final String calcManualRateHelperDefault;
  final String calcManualRateHelperGtawSmaw;
  final String calcInputParametersTitle;
  final String calcInputParametersSubtitle;
  final String calcDimensionalInputsTitle;
  final String calcDimensionalInputsSubtitle;
  final String calcRunEstimateTitle;
  final String calcRunEstimateSubtitle;
  final String calcSaveAsPresetLabel;
  final String calcUpdateSavedCalculationLabel;
  final String calcPdfHintBeforeResult;
  final String calcPdfHintAfterResult;
  final String calcResultsTitle;
  final String calcEmptyResultsBodyDefault;
  final String calcEmptyResultsBodyGtawSmaw;
  final String calcEditInputsTooltip;
  final String calcEditInputsButton;
  final String calcBackToDashboardTooltip;
  final String techDrawingTitle;
  final String techDrawingModeTechnicalDesc;
  final String techDrawingModeVisualDesc;
  final String calcCustomDiameterOption;
  final String calcCustomDiameterLabel;
  final String calcCustomDiameterHelper;
  final String calcPresetNameDialogSaveTitle;
  final String calcPresetNameDialogUpdateTitle;
  final String calcPresetNameHelper;
  final String calcSaveWithAccountTitle;
  final String calcSaveWithAccountBody;
  final String calcAccountEmailInvalidError;
  final String calcCalculationFailedError;
  final String calcFieldRequiredError;
  final String calcErrorLabelQuantity;
  final String calcErrorLabelDensity;
  final String calcErrorLabelWasteFactor;
  final String calcFieldQuantityLabel;
  final String calcFieldQuantityHelper;
  final String calcFieldWeldLengthLabel;
  final String calcFieldWeldLengthHelper;
  final String calcFieldPipeOdALabel;
  final String calcFieldPipeOdAHelper;
  final String calcFieldPipeOdBLabel;
  final String calcFieldPipeOdBHelper;
  final String calcFieldPipeOdLabel;
  final String calcFieldPipeOdHelper;
  final String calcFieldThicknessALabel;
  final String calcFieldThicknessAHelper;
  final String calcFieldThicknessBLabel;
  final String calcFieldThicknessBHelper;
  final String calcFieldRootGapLabel;
  final String calcFieldRootGapHelper;
  final String calcFieldThicknessLabel;
  final String calcFieldThicknessHelper;
  final String calcFieldRootFacePerSideLabel;
  final String calcFieldRootFacePerSideHelper;
  final String calcFieldRootFaceLabel;
  final String calcFieldRootFaceHelper;
  final String calcFieldBevelAngleLabel;
  final String calcFieldBevelAngleHelper;
  final String calcFieldPrimaryAngleLabel;
  final String calcFieldPrimaryAngleHelper;
  final String calcFieldSecondaryAngleLabel;
  final String calcFieldSecondaryAngleHelper;
  final String calcFieldBreakHeightLabel;
  final String calcFieldBreakHeightHelper;
  final String calcFieldLegSizeLabel;
  final String calcFieldLegSizeHelper;
  final String calcFieldGtawWireDiameterLabel;
  final String calcFieldGtawWireDiameterHelper;
  final String calcFieldSmawElectrodeDiameterLabel;
  final String calcFieldSmawElectrodeDiameterHelper;
  final String calcFieldGmawWireDiameterLabel;
  final String calcFieldGmawWireDiameterHelper;
  final String calcFieldFcawWireDiameterLabel;
  final String calcFieldFcawWireDiameterHelper;
  final String calcFieldGtawTransitionLabel;
  final String calcFieldGtawTransitionHelper;
  final String calcFieldGtawDepositionRateLabel;
  final String calcFieldGtawDepositionRateHelper;
  final String calcFieldSmawDepositionRateLabel;
  final String calcFieldSmawDepositionRateHelper;
  final String calcFieldDepositionRateLabel;
  final String calcFieldDepositionRateHelper;
  final String calcFieldDensityLabel;
  final String calcFieldDensityHelper;
  final String calcFieldWasteAllowanceLabel;
  final String calcFieldWasteAllowanceHelper;
  final String basisProcess;
  final String basisRateBasis;
  final String basisInputPreset;
  final String basisSavedPreset;
  final String basisJoint;
  final String basisGeometry;
  final String basisAlignment;
  final String basisGroove;
  final String basisClassification;
  final String basisFillerMetalFamily;
  final String basisDensity;
  final String basisWasteAllowance;
  final String basisQuantity;
  final String basisWeldLengthPerPiece;
  final String basisPipeOd;
  final String basisThickness;
  final String basisThicknessA;
  final String basisThicknessB;
  final String basisControllingThickness;
  final String basisOdA;
  final String basisOdB;
  final String basisReferenceOd;
  final String basisRootGap;
  final String basisRootFace;
  final String basisRootFacePerSide;
  final String basisBevelAngle;
  final String basisPrimaryBevelAngle;
  final String basisSecondaryBevelAngle;
  final String basisBreakHeight;
  final String basisFilletLegSize;
  final String basisUserDefinedRate;
  final String basisWireDiameter;
  final String basisElectrodeDiameter;
  final String basisGtawTransitionDepth;
  final String basisGtawDepositionRate;
  final String basisGtawWireDiameter;
  final String basisSmawDepositionRate;
  final String basisSmawElectrodeDiameter;
  final String wizardJointDimensionsTitle;
  final String wizardConsumableRateTitle;
  final String wizardProcessStepSubtitle;
  final String wizardReviewCalculateTitle;
  final String wizardReviewCalculateSubtitle;
  final String wizardRecapProcessTitle;
  final String wizardRecapDimensionsTitle;
  final String wizardRecapConsumableTitle;
  final String wizardStepOfLabel;
  final String resultsSummaryCaption;
  final String resultsDisclaimer;
  final String resultsPdfPreparing;
  final String resultsPdfUnlock;
  final String resultsPdfExport;
  final String resultsEstimateReadyBadge;
  final String resultsHighlightSentence;
  final String resultsHighlightEffectiveRate;
  final String resultsHighlightFillerPerMeter;
  final String resultsHighlightArcOnPerMeter;
  final String metricWeldArea;
  final String metricWeldLength;
  final String metricWeldMetalVolume;
  final String metricWeldMetalWeight;
  final String metricFillerMetalConsumption;
  final String metricEstimatedArcOnTime;
  final String metricEffectiveDepositionEfficiency;
  final String metricEffectiveDepositionRate;
  final String resultsNextStandardLeg;
  final String insightWeldMetalPerMeter;
  final String insightFillerPerJoint;
  final String insightArcOnPerJoint;
  final String insightEfficiencyLossBasis;
  final String insightWasteAllowanceBasis;
  final String insightConsumptionMultiplier;
  final String processBreakdownTitle;
  final String processBreakdownSubtitle;
  final String processBreakdownAreaShare;
  final String processBreakdownWeldMetal;
  final String processBreakdownFillerConsumption;
  final String processBreakdownArcOnTime;
  final String processBreakdownDepositionRate;
  final String processBreakdownDepositionEfficiency;
  final String engineeringBasisTitle;
  final String engineeringBasisSubtitle;
  final String planningIndicatorsTitle;
  final String planningIndicatorsSubtitle;
  final String engineeringNotesTitle;
  final String engineeringNote1;
  final String engineeringNote2;
  final String engineeringNote3;
  final String engineeringNote4;
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
    commonBack: 'Back',
    commonContinue: 'Continue',
    commonCalculate: 'Calculate',
    commonReset: 'Reset',
    commonUpdate: 'Update',
    commonDone: 'Done',
    jointTypePipeButt: 'Pipe Butt Weld',
    jointTypePlateButt: 'Plate Butt Weld',
    jointTypeFillet: 'Fillet Weld',
    jointTypeHelperPipeButt:
        'Total weld length is calculated from pipe outside diameter x quantity.',
    jointTypeHelperPlateButt:
        'Total weld length is calculated from weld run length x quantity.',
    jointTypeHelperFillet:
        'Fillet weld area is based on equal-leg geometry and entered weld length.',
    grooveSingleV: 'Single V',
    grooveHalfV: 'Half V',
    grooveDoubleV: 'Double V',
    grooveCompoundV: 'Compound V',
    grooveSquare: 'Square',
    grooveFillet: 'Fillet',
    depositionRateModePreset: 'Estimated',
    depositionRateModeManual: 'Manual',
    jointGeometryEqual: 'Equal',
    jointGeometryUnequal: 'Unequal',
    jointAlignmentCenterline: 'Centerline Match',
    jointAlignmentOdMatch: 'OD Match',
    jointAlignmentIdMatch: 'ID Match',
    drawingModeVisual: 'Visual',
    drawingModeTechnical: 'Technical',
    inputPresetCustom: 'Custom',
    inputPresetCsPipeSingleVGtawSmaw: 'CS Pipe Single V / GTAW + SMAW',
    inputPresetCsPipeDoubleVGtawSmaw: 'CS Pipe Double V / GTAW + SMAW',
    inputPresetSsPipeSingleVGtaw: 'SS Pipe Single V / GTAW',
    inputPresetCsPlateSingleVGmaw: 'CS Plate Single V / GMAW',
    inputPresetCsPlateDoubleVSmaw: 'CS Plate Double V / SMAW',
    inputPresetCsFilletFcaw: 'CS Fillet / FCAW',
    inputPresetDescCustom: 'Manual setup with no preset assumptions applied.',
    inputPresetDescCsPipeSingleVGtawSmaw:
        'Carbon steel pipe root-pass plus fill-pass starter setup.',
    inputPresetDescCsPipeDoubleVGtawSmaw:
        'Heavy-wall carbon steel pipe double-V starter setup.',
    inputPresetDescSsPipeSingleVGtaw: 'Stainless pipe GTAW-only starter setup.',
    inputPresetDescCsPlateSingleVGmaw:
        'Carbon steel plate single-V production starter setup.',
    inputPresetDescCsPlateDoubleVSmaw:
        'Carbon steel plate double-V manual welding starter setup.',
    inputPresetDescCsFilletFcaw:
        'Carbon steel structural fillet starter setup.',
    consumablePresetDescEr70s6: 'Carbon steel solid wire or filler metal',
    consumablePresetDescEr70s2: 'Carbon steel GTAW filler metal',
    consumablePresetDescE7018: 'Low-hydrogen carbon steel covered electrode',
    consumablePresetDescE6010: 'Cellulosic carbon steel root electrode',
    consumablePresetDescE71t1: 'Carbon steel flux-cored wire',
    consumablePresetDescEr308l: '308L stainless steel filler metal',
    consumablePresetDescE308l16: '308L stainless steel covered electrode',
    consumablePresetDescEr316l: '316L stainless steel filler metal',
    consumablePresetDescEr309l: '309L filler metal for dissimilar welds',
    consumablePresetDescE309l16: '309L covered electrode for dissimilar welds',
    consumablePresetDescEr5356: '5356 aluminium filler metal',
    consumablePresetDescGtawRootSmawFill:
        'Typical carbon steel pipe root and fill combination',
    consumablePresetDescE6013:
        'Rutile, easy-to-use general-purpose electrode, AC/DC',
    consumablePresetDescE7024:
        'Iron-powder electrode, high deposition rate, flat/horizontal fillets',
    consumablePresetDescEr70s3:
        'General-purpose solid GMAW wire for carbon steel',
    consumablePresetDescE7018a1:
        'Low-hydrogen electrode for 0.5% Mo alloy steel piping',
    consumablePresetDescE8018c3:
        'Low-hydrogen electrode for nickel-bearing low-temperature steel (~1% Ni)',
    consumablePresetDescEr80sNi1:
        'Nickel-bearing low-alloy steel filler for low-temperature service',
    consumablePresetDescEr80sB2:
        'Chrome-moly filler for elevated-temperature piping',
    consumablePresetDescE316l16: 'SMAW electrode counterpart to ER316L',
    consumablePresetDescEr347:
        'Niobium-stabilized stainless filler for high-temperature/carbide-precipitation-resistant service',
    consumablePresetDescEr4043:
        'General-purpose 5% silicon aluminum filler, good flow/crack resistance',
    consumablePresetDescEr5183:
        'High-magnesium filler for marine and high-strength aluminum structures',
    consumablePresetDescEniCi:
        'Near-pure-nickel electrode for cast iron repair welding',
    consumablePresetDescEnifeCi:
        'Nickel-iron electrode for higher-strength cast iron repairs',
    consumablePresetDescErnicr3:
        'Nickel-chromium bare filler wire for Inconel and dissimilar-metal welds',
    consumablePresetDescEnicrfe3:
        'Nickel-chromium-iron electrode, SMAW counterpart use-case to ERNiCr-3',
    consumablePresetDescErcusiA:
        'Silicon bronze filler for copper and braze-welding applications',
    consumablePresetDescEcualA2:
        'Aluminum bronze electrode for wear-resistant overlays and dissimilar joints',
    consumableCustomFallbackDescription:
        'Custom filler material from your library.',
    consumableCustomNoTypicalBaseMetals:
        'No typical base metals recorded for this custom material.',
    calcActiveEngineeringBasisTitle: 'Active Engineering Basis',
    calcJointTypeSectionTitle: 'Joint Type',
    calcMemberGeometrySectionTitle: 'Member Geometry',
    calcAlignmentReferenceLabel: 'Alignment Reference',
    calcAlignmentReferenceHelper:
        'Defines how unequal members are aligned in the section sketch.',
    calcGrooveTypeLabel: 'Groove Type',
    calcWeldingProcessLabel: 'Welding Process',
    calcStartingTemplateTitle: 'Starting Template',
    calcStartingTemplateSubtitle:
        'Loads a full example setup, including joint, dimensions, and '
        'welding process, that you can then adjust.',
    calcInputPresetLabel: 'Input Preset',
    calcConsumableDensityTitle: 'Consumable & Density',
    calcConsumableDensitySubtitle:
        'AWS filler selection, family information, and weld metal density basis.',
    calcConsumableClassificationLabel: 'Consumable Classification',
    calcConsumableClassificationHelper:
        'Select an AWS filler metal classification. Density is populated automatically and can still be adjusted.',
    calcMyMaterialsHeader: 'My Materials',
    calcAsSavedSuffix: ' (as saved)',
    drawingLabelFilletWeldFace: 'fillet weld face',
    drawingLabelTJoint: 'T-joint',
    drawingLabelSmawFillCap: 'SMAW fill / cap',
    drawingLabelGtawRoot: 'GTAW root',
    calcSelectedClassificationNote: 'Selected classification: {value}',
    calcTypicalBaseMetalsNote: 'Typical base metals: {value}',
    calcRateBasisTitle: 'Rate Basis',
    calcRateBasisSubtitle:
        'Choose whether deposition rate comes from estimated process defaults or manual planning data.',
    calcPresetRateHelperDefault:
        'Estimated mode derives deposition rate from process and filler diameter. Use it for preliminary estimating, not qualification-level planning.',
    calcPresetRateHelperGtawSmaw:
        'Estimated mode derives GTAW and SMAW deposition rates from the selected filler diameters, then combines them using the GTAW transition depth.',
    calcManualRateHelperDefault:
        'Manual mode overrides the estimated rate with a measured shop value, project planning value, or WPS assumption.',
    calcManualRateHelperGtawSmaw:
        'Manual mode lets you enter separate GTAW and SMAW deposition rates so arc time follows the planned root, fill, and cap sequence.',
    calcInputParametersTitle: 'Input Parameters',
    calcInputParametersSubtitle:
        'Default assumptions: density {density} g/cm3, waste allowance {waste}%',
    calcDimensionalInputsTitle: 'Dimensional Inputs',
    calcDimensionalInputsSubtitle:
        'Enter weld geometry, member size, process diameter, and calculation assumptions.',
    calcRunEstimateTitle: 'Run Estimate',
    calcRunEstimateSubtitle:
        'Use calculate for live estimate refresh. Reset restores the default engineering starter values.',
    calcSaveAsPresetLabel: 'Save as Preset',
    calcUpdateSavedCalculationLabel: 'Update Saved Calculation',
    calcPdfHintBeforeResult:
        'PDF export activates after a successful estimate so the report always reflects the current engineering basis.',
    calcPdfHintAfterResult:
        'The report panel is ready for polished PDF output once the estimate looks correct.',
    calcResultsTitle: 'Results',
    calcEmptyResultsBodyDefault:
        'Choose the joint, review the input parameters, then calculate. Process {process} uses its active deposition efficiency and deposition rate basis.',
    calcEmptyResultsBodyGtawSmaw:
        'Choose the joint, then enter GTAW transition depth together with GTAW wire and SMAW electrode diameters before calculating.',
    calcEditInputsTooltip: 'Edit inputs',
    calcEditInputsButton: 'Edit Inputs',
    calcBackToDashboardTooltip: 'Back to Dashboard',
    techDrawingTitle: 'Technical Drawing',
    techDrawingModeTechnicalDesc:
        'Technical mode applies engineering-style line weights, hatch, and dimension annotations.',
    techDrawingModeVisualDesc:
        'Visual mode keeps the sketch softer while still following the live joint geometry.',
    calcCustomDiameterOption: 'Custom diameter',
    calcCustomDiameterLabel: 'Custom Diameter (mm)',
    calcCustomDiameterHelper: 'Enter an exact diameter value.',
    calcPresetNameDialogSaveTitle: 'Save Preset',
    calcPresetNameDialogUpdateTitle: 'Update Preset',
    calcPresetNameHelper: 'Use a short technical reference name.',
    calcSaveWithAccountTitle: 'Save with an Account',
    calcSaveWithAccountBody:
        'Enter your email to save this preset. Use the same '
        'email on any device to get it back later.',
    calcAccountEmailInvalidError: 'Enter a valid email.',
    calcCalculationFailedError: 'Calculation failed. Please review the inputs.',
    calcFieldRequiredError: '{label} must be a valid number.',
    calcErrorLabelQuantity: 'Quantity',
    calcErrorLabelDensity: 'Density',
    calcErrorLabelWasteFactor: 'Waste factor',
    calcFieldQuantityLabel: 'Quantity',
    calcFieldQuantityHelper: 'Number of identical welds.',
    calcFieldWeldLengthLabel: 'Weld Length per Piece (mm)',
    calcFieldWeldLengthHelper: 'Straight weld run length.',
    calcFieldPipeOdALabel: 'Pipe OD A (mm)',
    calcFieldPipeOdAHelper: 'Outside diameter of member A.',
    calcFieldPipeOdBLabel: 'Pipe OD B (mm)',
    calcFieldPipeOdBHelper: 'Outside diameter of member B.',
    calcFieldPipeOdLabel: 'Pipe OD (mm)',
    calcFieldPipeOdHelper:
        'Outside diameter used for circumference calculation.',
    calcFieldThicknessALabel: 'Thickness A (mm)',
    calcFieldThicknessAHelper: 'Wall or plate thickness of member A.',
    calcFieldThicknessBLabel: 'Thickness B (mm)',
    calcFieldThicknessBHelper: 'Wall or plate thickness of member B.',
    calcFieldRootGapLabel: 'Root Gap (mm)',
    calcFieldRootGapHelper: 'Root opening.',
    calcFieldThicknessLabel: 'Thickness (mm)',
    calcFieldThicknessHelper: 'Base material thickness.',
    calcFieldRootFacePerSideLabel: 'Root Face per Side (mm)',
    calcFieldRootFacePerSideHelper:
        'Root face on each side of the joint centerline.',
    calcFieldRootFaceLabel: 'Root Face (mm)',
    calcFieldRootFaceHelper: 'Root face before the bevel starts.',
    calcFieldBevelAngleLabel: 'Bevel Angle (deg)',
    calcFieldBevelAngleHelper: 'Included as bevel angle in degrees.',
    calcFieldPrimaryAngleLabel: 'Primary Angle alpha (deg)',
    calcFieldPrimaryAngleHelper: 'Lower bevel angle near the root.',
    calcFieldSecondaryAngleLabel: 'Secondary Angle beta (deg)',
    calcFieldSecondaryAngleHelper: 'Upper bevel angle above the break point.',
    calcFieldBreakHeightLabel: 'Break Height h (mm)',
    calcFieldBreakHeightHelper: 'Distance from root face to bevel break point.',
    calcFieldLegSizeLabel: 'Leg Size (mm)',
    calcFieldLegSizeHelper: 'Equal leg size of the fillet weld.',
    calcFieldGtawWireDiameterLabel: 'GTAW Wire Diameter (mm)',
    calcFieldGtawWireDiameterHelper:
        'Common filler diameters: 1.6, 2.0, 2.4, 3.2 mm.',
    calcFieldSmawElectrodeDiameterLabel: 'SMAW Electrode Diameter (mm)',
    calcFieldSmawElectrodeDiameterHelper:
        'Common electrode diameters: 2.5, 3.2, 4.0, 5.0 mm.',
    calcFieldGmawWireDiameterLabel: 'GMAW Wire Diameter (mm)',
    calcFieldGmawWireDiameterHelper:
        'Common wire diameters: 0.8, 1.0, 1.2, 1.6 mm.',
    calcFieldFcawWireDiameterLabel: 'FCAW Wire Diameter (mm)',
    calcFieldFcawWireDiameterHelper: 'Common wire diameters: 1.2, 1.6, 2.0 mm.',
    calcFieldGtawTransitionLabel: 'GTAW Transition Depth (mm)',
    calcFieldGtawTransitionHelper:
        'Depth deposited by GTAW from the root side before switching to SMAW.',
    calcFieldGtawDepositionRateLabel: 'GTAW Deposition Rate (kg/h)',
    calcFieldGtawDepositionRateHelper:
        'User-defined deposition rate for the GTAW root portion.',
    calcFieldSmawDepositionRateLabel: 'SMAW Deposition Rate (kg/h)',
    calcFieldSmawDepositionRateHelper:
        'User-defined deposition rate for the SMAW fill and cap portion.',
    calcFieldDepositionRateLabel: 'Deposition Rate (kg/h)',
    calcFieldDepositionRateHelper:
        'User-defined deposition rate based on shop data, planning value, or WPS assumption.',
    calcFieldDensityLabel: 'Density (g/cm3)',
    calcFieldDensityHelper:
        'Bulk weld metal density. Default follows the selected classification.',
    calcFieldWasteAllowanceLabel: 'Waste Allowance (%)',
    calcFieldWasteAllowanceHelper:
        'Allowance for stub loss, cut-off, spatter, and handling.',
    basisProcess: 'Process',
    basisRateBasis: 'Rate Basis',
    basisInputPreset: 'Input Preset',
    basisSavedPreset: 'Saved Preset',
    basisJoint: 'Joint',
    basisGeometry: 'Geometry',
    basisAlignment: 'Alignment',
    basisGroove: 'Groove',
    basisClassification: 'Classification',
    basisFillerMetalFamily: 'Filler Metal Family',
    basisDensity: 'Density',
    basisWasteAllowance: 'Waste Allowance',
    basisQuantity: 'Quantity',
    basisWeldLengthPerPiece: 'Weld Length per Piece',
    basisPipeOd: 'Pipe OD',
    basisThickness: 'Thickness',
    basisThicknessA: 'Thickness A',
    basisThicknessB: 'Thickness B',
    basisControllingThickness: 'Controlling Thickness',
    basisOdA: 'OD A',
    basisOdB: 'OD B',
    basisReferenceOd: 'Reference OD',
    basisRootGap: 'Root Gap',
    basisRootFace: 'Root Face',
    basisRootFacePerSide: 'Root Face per Side',
    basisBevelAngle: 'Bevel Angle',
    basisPrimaryBevelAngle: 'Primary Bevel Angle',
    basisSecondaryBevelAngle: 'Secondary Bevel Angle',
    basisBreakHeight: 'Break Height',
    basisFilletLegSize: 'Fillet Leg Size',
    basisUserDefinedRate: 'User-defined Rate',
    basisWireDiameter: 'Wire Diameter',
    basisElectrodeDiameter: 'Electrode Diameter',
    basisGtawTransitionDepth: 'GTAW Transition Depth',
    basisGtawDepositionRate: 'GTAW Deposition Rate',
    basisGtawWireDiameter: 'GTAW Wire Diameter',
    basisSmawDepositionRate: 'SMAW Deposition Rate',
    basisSmawElectrodeDiameter: 'SMAW Electrode Diameter',
    wizardJointDimensionsTitle: 'Joint & Dimensions',
    wizardConsumableRateTitle: 'Consumable & Rate',
    wizardProcessStepSubtitle:
        'Choose the process used for this weld. This sets the deposition defaults and filler options for the next steps.',
    wizardReviewCalculateTitle: 'Review & Calculate',
    wizardReviewCalculateSubtitle:
        'Confirm the setup below, then calculate. Edit any step to change it.',
    wizardRecapProcessTitle: 'Process',
    wizardRecapDimensionsTitle: 'Dimensions',
    wizardRecapConsumableTitle: 'Consumable',
    wizardStepOfLabel: 'Step {current} of {total}',
    resultsSummaryCaption:
        'Report-grade summary for engineering review, material planning, and consumable comparison.',
    resultsDisclaimer:
        'This is a first-pass planning estimate — confirm against your qualified WPS and a test coupon before production use.',
    resultsPdfPreparing: 'Preparing PDF...',
    resultsPdfUnlock: 'Unlock PDF',
    resultsPdfExport: 'Export PDF',
    resultsEstimateReadyBadge: 'ESTIMATE READY',
    resultsHighlightSentence:
        'Estimated filler metal consumption is {filler} kg with {arcTime} h of arc-on time.',
    resultsHighlightEffectiveRate: 'Effective Rate',
    resultsHighlightFillerPerMeter: 'Filler per Meter',
    resultsHighlightArcOnPerMeter: 'Arc-On per Meter',
    metricWeldArea: 'Weld Area',
    metricWeldLength: 'Weld Length',
    metricWeldMetalVolume: 'Weld Metal Volume',
    metricWeldMetalWeight: 'Weld Metal Weight',
    metricFillerMetalConsumption: 'Filler Metal Consumption',
    metricEstimatedArcOnTime: 'Estimated Arc-On Time',
    metricEffectiveDepositionEfficiency: 'Effective Deposition Efficiency',
    metricEffectiveDepositionRate: 'Effective Deposition Rate',
    resultsNextStandardLeg:
        'Next standard leg size up ({size}mm) costs ~{percent}% more filler.',
    insightWeldMetalPerMeter: 'Weld Metal per Meter',
    insightFillerPerJoint: 'Filler per Joint',
    insightArcOnPerJoint: 'Arc-On per Joint',
    insightEfficiencyLossBasis: 'Efficiency Loss Basis',
    insightWasteAllowanceBasis: 'Waste Allowance Basis',
    insightConsumptionMultiplier: 'Consumption Multiplier',
    processBreakdownTitle: 'Process Breakdown',
    processBreakdownSubtitle:
        'Distribution of deposited weld metal, filler demand, and arc-on time by process segment.',
    processBreakdownAreaShare: 'Area Share {value}%',
    processBreakdownWeldMetal: 'Weld Metal {value} kg',
    processBreakdownFillerConsumption: 'Filler Consumption {value} kg',
    processBreakdownArcOnTime: 'Arc-On Time {value} h',
    processBreakdownDepositionRate: 'Deposition Rate {value} kg/h',
    processBreakdownDepositionEfficiency: 'Deposition Efficiency {value}',
    engineeringBasisTitle: 'Engineering Basis',
    engineeringBasisSubtitle:
        'Full engineering basis used in this estimate, including geometry, process setup, density, and deposition assumptions.',
    planningIndicatorsTitle: 'Planning Indicators',
    planningIndicatorsSubtitle:
        'Normalized indicators that help compare joint options, labor load, and consumable planning basis.',
    engineeringNotesTitle: 'Engineering Notes',
    engineeringNote1:
        'Arc-on time covers welding time only. Fit-up, handling, cleaning, repositioning, and inspection are not included.',
    engineeringNote2:
        'Filler metal consumption includes deposited weld metal, process deposition efficiency, and the entered waste allowance.',
    engineeringNote3:
        'Consumable classification provides material family and density reference. Final project or client requirements should always govern.',
    engineeringNote4:
        'This report is suitable for estimation and planning. It is not an approved WPS, PQR, welder qualification, or release document.',
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
    commonBack: 'Geri',
    commonContinue: 'Devam Et',
    commonCalculate: 'Hesapla',
    commonReset: 'Sıfırla',
    commonUpdate: 'Güncelle',
    commonDone: 'Tamam',
    jointTypePipeButt: 'Boru Alın Kaynağı',
    jointTypePlateButt: 'Sac Alın Kaynağı',
    jointTypeFillet: 'Köşe Kaynağı',
    jointTypeHelperPipeButt:
        'Toplam kaynak uzunluğu, boru dış çapı x adet üzerinden hesaplanır.',
    jointTypeHelperPlateButt:
        'Toplam kaynak uzunluğu, kaynak dikişi uzunluğu x adet üzerinden hesaplanır.',
    jointTypeHelperFillet:
        'Köşe kaynağı alanı, eşit kenar geometrisine ve girilen kaynak uzunluğuna dayanır.',
    grooveSingleV: 'Tek V',
    grooveHalfV: 'Yarım V',
    grooveDoubleV: 'Çift V',
    grooveCompoundV: 'Bileşik V',
    grooveSquare: 'Küt (Kare)',
    grooveFillet: 'Köşe',
    depositionRateModePreset: 'Tahmini',
    depositionRateModeManual: 'Manuel',
    jointGeometryEqual: 'Eşit',
    jointGeometryUnequal: 'Eşit Değil',
    jointAlignmentCenterline: 'Merkez Hattı Hizalama',
    jointAlignmentOdMatch: 'Dış Çap Hizalama',
    jointAlignmentIdMatch: 'İç Çap Hizalama',
    drawingModeVisual: 'Görsel',
    drawingModeTechnical: 'Teknik',
    inputPresetCustom: 'Özel',
    inputPresetCsPipeSingleVGtawSmaw: 'CS Boru Tek V / GTAW + SMAW',
    inputPresetCsPipeDoubleVGtawSmaw: 'CS Boru Çift V / GTAW + SMAW',
    inputPresetSsPipeSingleVGtaw: 'SS Boru Tek V / GTAW',
    inputPresetCsPlateSingleVGmaw: 'CS Sac Tek V / GMAW',
    inputPresetCsPlateDoubleVSmaw: 'CS Sac Çift V / SMAW',
    inputPresetCsFilletFcaw: 'CS Köşe / FCAW',
    inputPresetDescCustom:
        'Herhangi bir şablon varsayımı uygulanmamış manuel kurulum.',
    inputPresetDescCsPipeSingleVGtawSmaw:
        'Karbon çeliği boru kök pasosu artı dolgu pasosu başlangıç kurulumu.',
    inputPresetDescCsPipeDoubleVGtawSmaw:
        'Kalın çeperli karbon çeliği boru çift V başlangıç kurulumu.',
    inputPresetDescSsPipeSingleVGtaw:
        'Yalnızca GTAW ile paslanmaz boru başlangıç kurulumu.',
    inputPresetDescCsPlateSingleVGmaw:
        'Karbon çeliği sac tek V üretim başlangıç kurulumu.',
    inputPresetDescCsPlateDoubleVSmaw:
        'Karbon çeliği sac çift V manuel kaynak başlangıç kurulumu.',
    inputPresetDescCsFilletFcaw:
        'Karbon çeliği yapısal köşe kaynağı başlangıç kurulumu.',
    consumablePresetDescEr70s6: 'Karbon çeliği masif tel veya dolgu metali',
    consumablePresetDescEr70s2: 'Karbon çeliği GTAW dolgu metali',
    consumablePresetDescE7018: 'Düşük hidrojenli karbon çeliği kaplı elektrot',
    consumablePresetDescE6010: 'Selülozik karbon çeliği kök elektrodu',
    consumablePresetDescE71t1: 'Karbon çeliği özlü tel (flux-cored)',
    consumablePresetDescEr308l: '308L paslanmaz çelik dolgu metali',
    consumablePresetDescE308l16: '308L paslanmaz çelik kaplı elektrot',
    consumablePresetDescEr316l: '316L paslanmaz çelik dolgu metali',
    consumablePresetDescEr309l:
        'Farklı metal kaynakları için 309L dolgu metali',
    consumablePresetDescE309l16:
        'Farklı metal kaynakları için 309L kaplı elektrot',
    consumablePresetDescEr5356: '5356 alüminyum dolgu metali',
    consumablePresetDescGtawRootSmawFill:
        'Tipik karbon çeliği boru kök ve dolgu kombinasyonu',
    consumablePresetDescE6013:
        'Rutil, kullanımı kolay genel amaçlı elektrot, AC/DC',
    consumablePresetDescE7024:
        'Demir tozlu elektrot, yüksek dolgu hızı, düz/yatay köşe kaynakları',
    consumablePresetDescEr70s3:
        'Karbon çeliği için genel amaçlı masif GMAW teli',
    consumablePresetDescE7018a1:
        '%0.5 Mo alaşımlı çelik borular için düşük hidrojenli elektrot',
    consumablePresetDescE8018c3:
        'Nikel içerikli düşük sıcaklık çeliği için düşük hidrojenli elektrot (~%1 Ni)',
    consumablePresetDescEr80sNi1:
        'Düşük sıcaklık hizmeti için nikel içerikli düşük alaşımlı çelik dolgu',
    consumablePresetDescEr80sB2:
        'Yüksek sıcaklık boruları için krom-molibden dolgu',
    consumablePresetDescE316l16: "ER316L'nin SMAW karşılığı",
    consumablePresetDescEr347:
        'Yüksek sıcaklık/karbür çökelmesine dirençli hizmet için niyobyumla stabilize paslanmaz dolgu',
    consumablePresetDescEr4043:
        'İyi akış/çatlak direncine sahip genel amaçlı %5 silisyum alüminyum dolgu',
    consumablePresetDescEr5183:
        'Deniz ve yüksek mukavemetli alüminyum yapılar için yüksek magnezyumlu dolgu',
    consumablePresetDescEniCi:
        'Dökme demir onarım kaynağı için saf nikele yakın elektrot',
    consumablePresetDescEnifeCi:
        'Daha yüksek mukavemetli dökme demir onarımları için nikel-demir elektrot',
    consumablePresetDescErnicr3:
        'Inconel ve farklı metal kaynakları için nikel-krom çıplak dolgu teli',
    consumablePresetDescEnicrfe3:
        "Nikel-krom-demir elektrot, ERNiCr-3'ün SMAW karşılığı kullanım durumu",
    consumablePresetDescErcusiA:
        'Bakır ve lehim-kaynak uygulamaları için silisyum bronz dolgu',
    consumablePresetDescEcualA2:
        'Aşınmaya dayanıklı kaplamalar ve farklı metal birleşimleri için alüminyum bronz elektrot',
    consumableCustomFallbackDescription:
        'Kütüphanenizden özel dolgu malzemesi.',
    consumableCustomNoTypicalBaseMetals:
        'Bu özel malzeme için tipik ana malzeme kaydedilmemiş.',
    calcActiveEngineeringBasisTitle: 'Aktif Mühendislik Dayanağı',
    calcJointTypeSectionTitle: 'Birleşim Tipi',
    calcMemberGeometrySectionTitle: 'Eleman Geometrisi',
    calcAlignmentReferenceLabel: 'Hizalama Referansı',
    calcAlignmentReferenceHelper:
        'Eşit olmayan elemanların kesit çiziminde nasıl hizalandığını tanımlar.',
    calcGrooveTypeLabel: 'Ağız Tipi',
    calcWeldingProcessLabel: 'Kaynak Yöntemi',
    calcStartingTemplateTitle: 'Başlangıç Şablonu',
    calcStartingTemplateSubtitle:
        'Birleşim, ölçüler ve kaynak yöntemi dahil tam bir örnek kurulum '
        'yükler; ardından bunu düzenleyebilirsiniz.',
    calcInputPresetLabel: 'Giriş Şablonu',
    calcConsumableDensityTitle: 'Sarf Malzeme ve Yoğunluk',
    calcConsumableDensitySubtitle:
        'AWS dolgu seçimi, aile bilgisi ve kaynak metali yoğunluk esası.',
    calcConsumableClassificationLabel: 'Sarf Malzeme Sınıflandırması',
    calcConsumableClassificationHelper:
        'Bir AWS dolgu metali sınıflandırması seçin. Yoğunluk otomatik olarak doldurulur ve yine de ayarlanabilir.',
    calcMyMaterialsHeader: 'Malzemelerim',
    calcAsSavedSuffix: ' (kayıtlı haliyle)',
    drawingLabelFilletWeldFace: 'köşe kaynağı yüzeyi',
    drawingLabelTJoint: 'T-birleşimi',
    drawingLabelSmawFillCap: 'SMAW dolgu / kapak',
    drawingLabelGtawRoot: 'GTAW kök',
    calcSelectedClassificationNote: 'Seçilen sınıflandırma: {value}',
    calcTypicalBaseMetalsNote: 'Tipik ana malzemeler: {value}',
    calcRateBasisTitle: 'Hız Esası',
    calcRateBasisSubtitle:
        'Dolgu hızının tahmini yöntem varsayılanlarından mı yoksa manuel planlama verisinden mi geleceğini seçin.',
    calcPresetRateHelperDefault:
        'Tahmini mod, dolgu hızını yöntem ve dolgu çapından türetir. Ön hesaplama için kullanın, kalifikasyon seviyesinde planlama için değil.',
    calcPresetRateHelperGtawSmaw:
        'Tahmini mod, GTAW ve SMAW dolgu hızlarını seçilen dolgu çaplarından türetir, ardından bunları GTAW geçiş derinliğini kullanarak birleştirir.',
    calcManualRateHelperDefault:
        'Manuel mod, tahmini hızı ölçülen bir atölye değeri, proje planlama değeri veya WPS varsayımıyla geçersiz kılar.',
    calcManualRateHelperGtawSmaw:
        'Manuel mod, ark süresinin planlanan kök, dolgu ve kapak sırasını izlemesi için ayrı GTAW ve SMAW dolgu hızları girmenizi sağlar.',
    calcInputParametersTitle: 'Giriş Parametreleri',
    calcInputParametersSubtitle:
        'Varsayılan kabuller: yoğunluk {density} g/cm3, fire payı %{waste}',
    calcDimensionalInputsTitle: 'Boyutsal Girişler',
    calcDimensionalInputsSubtitle:
        'Kaynak geometrisi, eleman boyutu, yöntem çapı ve hesaplama kabullerini girin.',
    calcRunEstimateTitle: 'Hesaplamayı Çalıştır',
    calcRunEstimateSubtitle:
        "Canlı tahmini yenilemek için Hesapla'yı kullanın. Sıfırla, varsayılan mühendislik başlangıç değerlerini geri yükler.",
    calcSaveAsPresetLabel: 'Şablon Olarak Kaydet',
    calcUpdateSavedCalculationLabel: 'Kayıtlı Hesaplamayı Güncelle',
    calcPdfHintBeforeResult:
        'PDF dışa aktarma, başarılı bir tahminden sonra etkinleşir; böylece rapor her zaman güncel mühendislik dayanağını yansıtır.',
    calcPdfHintAfterResult:
        'Tahmin doğru göründüğünde rapor paneli, düzenli PDF çıktısı için hazırdır.',
    calcResultsTitle: 'Sonuçlar',
    calcEmptyResultsBodyDefault:
        '{process} yöntemi kendi aktif dolgu verimini ve dolgu hızı esasını kullanır. Birleşimi seçin, giriş parametrelerini gözden geçirin, ardından hesaplayın.',
    calcEmptyResultsBodyGtawSmaw:
        'Birleşimi seçin, ardından hesaplamadan önce GTAW geçiş derinliğini, GTAW tel çapı ve SMAW elektrot çapıyla birlikte girin.',
    calcEditInputsTooltip: 'Girişleri düzenle',
    calcEditInputsButton: 'Girişleri Düzenle',
    calcBackToDashboardTooltip: 'Ana Sayfaya Dön',
    techDrawingTitle: 'Teknik Çizim',
    techDrawingModeTechnicalDesc:
        'Teknik mod, mühendislik tarzı çizgi kalınlıkları, tarama ve ölçü açıklamaları uygular.',
    techDrawingModeVisualDesc:
        'Görsel mod, canlı birleşim geometrisini izlemeye devam ederken çizimi daha yumuşak tutar.',
    calcCustomDiameterOption: 'Özel çap',
    calcCustomDiameterLabel: 'Özel Çap (mm)',
    calcCustomDiameterHelper: 'Tam bir çap değeri girin.',
    calcPresetNameDialogSaveTitle: 'Şablonu Kaydet',
    calcPresetNameDialogUpdateTitle: 'Şablonu Güncelle',
    calcPresetNameHelper: 'Kısa bir teknik referans adı kullanın.',
    calcSaveWithAccountTitle: 'Bir Hesapla Kaydet',
    calcSaveWithAccountBody:
        'Bu şablonu kaydetmek için e-postanızı girin. Daha sonra geri almak '
        'için herhangi bir cihazda aynı e-postayı kullanın.',
    calcAccountEmailInvalidError: 'Geçerli bir e-posta girin.',
    calcCalculationFailedError:
        'Hesaplama başarısız oldu. Lütfen girişleri gözden geçirin.',
    calcFieldRequiredError: '{label} geçerli bir sayı olmalıdır.',
    calcErrorLabelQuantity: 'Adet',
    calcErrorLabelDensity: 'Yoğunluk',
    calcErrorLabelWasteFactor: 'Fire payı',
    calcFieldQuantityLabel: 'Adet',
    calcFieldQuantityHelper: 'Aynı kaynakların sayısı.',
    calcFieldWeldLengthLabel: 'Parça Başına Kaynak Uzunluğu (mm)',
    calcFieldWeldLengthHelper: 'Düz kaynak dikişi uzunluğu.',
    calcFieldPipeOdALabel: 'Boru Dış Çapı A (mm)',
    calcFieldPipeOdAHelper: 'A elemanının dış çapı.',
    calcFieldPipeOdBLabel: 'Boru Dış Çapı B (mm)',
    calcFieldPipeOdBHelper: 'B elemanının dış çapı.',
    calcFieldPipeOdLabel: 'Boru Dış Çapı (mm)',
    calcFieldPipeOdHelper: 'Çevre hesaplamasında kullanılan dış çap.',
    calcFieldThicknessALabel: 'Kalınlık A (mm)',
    calcFieldThicknessAHelper: 'A elemanının çeper veya sac kalınlığı.',
    calcFieldThicknessBLabel: 'Kalınlık B (mm)',
    calcFieldThicknessBHelper: 'B elemanının çeper veya sac kalınlığı.',
    calcFieldRootGapLabel: 'Kök Aralığı (mm)',
    calcFieldRootGapHelper: 'Kök açıklığı.',
    calcFieldThicknessLabel: 'Kalınlık (mm)',
    calcFieldThicknessHelper: 'Ana malzeme kalınlığı.',
    calcFieldRootFacePerSideLabel: 'Taraf Başına Kök Yüzü (mm)',
    calcFieldRootFacePerSideHelper:
        'Birleşim merkez hattının her iki tarafındaki kök yüzü.',
    calcFieldRootFaceLabel: 'Kök Yüzü (mm)',
    calcFieldRootFaceHelper: 'Pah başlamadan önceki kök yüzü.',
    calcFieldBevelAngleLabel: 'Pah Açısı (°)',
    calcFieldBevelAngleHelper:
        'Derece cinsinden pah açısı olarak dahil edilir.',
    calcFieldPrimaryAngleLabel: 'Birincil Açı alfa (°)',
    calcFieldPrimaryAngleHelper: 'Köke yakın alt pah açısı.',
    calcFieldSecondaryAngleLabel: 'İkincil Açı beta (°)',
    calcFieldSecondaryAngleHelper:
        'Kırılma noktasının üzerindeki üst pah açısı.',
    calcFieldBreakHeightLabel: 'Kırılma Yüksekliği h (mm)',
    calcFieldBreakHeightHelper:
        'Kök yüzünden pah kırılma noktasına olan mesafe.',
    calcFieldLegSizeLabel: 'Kenar Ölçüsü (mm)',
    calcFieldLegSizeHelper: 'Köşe kaynağının eşit kenar ölçüsü.',
    calcFieldGtawWireDiameterLabel: 'GTAW Tel Çapı (mm)',
    calcFieldGtawWireDiameterHelper:
        'Yaygın dolgu çapları: 1.6, 2.0, 2.4, 3.2 mm.',
    calcFieldSmawElectrodeDiameterLabel: 'SMAW Elektrot Çapı (mm)',
    calcFieldSmawElectrodeDiameterHelper:
        'Yaygın elektrot çapları: 2.5, 3.2, 4.0, 5.0 mm.',
    calcFieldGmawWireDiameterLabel: 'GMAW Tel Çapı (mm)',
    calcFieldGmawWireDiameterHelper:
        'Yaygın tel çapları: 0.8, 1.0, 1.2, 1.6 mm.',
    calcFieldFcawWireDiameterLabel: 'FCAW Tel Çapı (mm)',
    calcFieldFcawWireDiameterHelper: 'Yaygın tel çapları: 1.2, 1.6, 2.0 mm.',
    calcFieldGtawTransitionLabel: 'GTAW Geçiş Derinliği (mm)',
    calcFieldGtawTransitionHelper:
        "SMAW'a geçmeden önce kök tarafından GTAW ile biriktirilen derinlik.",
    calcFieldGtawDepositionRateLabel: 'GTAW Dolgu Hızı (kg/h)',
    calcFieldGtawDepositionRateHelper:
        'GTAW kök bölümü için kullanıcı tanımlı dolgu hızı.',
    calcFieldSmawDepositionRateLabel: 'SMAW Dolgu Hızı (kg/h)',
    calcFieldSmawDepositionRateHelper:
        'SMAW dolgu ve kapak bölümü için kullanıcı tanımlı dolgu hızı.',
    calcFieldDepositionRateLabel: 'Dolgu Hızı (kg/h)',
    calcFieldDepositionRateHelper:
        'Atölye verisine, planlama değerine veya WPS varsayımına dayalı kullanıcı tanımlı dolgu hızı.',
    calcFieldDensityLabel: 'Yoğunluk (g/cm3)',
    calcFieldDensityHelper:
        'Kaynak metali yığın yoğunluğu. Varsayılan, seçilen sınıflandırmayı izler.',
    calcFieldWasteAllowanceLabel: 'Fire Payı (%)',
    calcFieldWasteAllowanceHelper:
        'Uç kaybı, kesme, sıçrama ve elleçleme için pay.',
    basisProcess: 'Yöntem',
    basisRateBasis: 'Hız Esası',
    basisInputPreset: 'Giriş Şablonu',
    basisSavedPreset: 'Kayıtlı Şablon',
    basisJoint: 'Birleşim',
    basisGeometry: 'Geometri',
    basisAlignment: 'Hizalama',
    basisGroove: 'Ağız',
    basisClassification: 'Sınıflandırma',
    basisFillerMetalFamily: 'Dolgu Metali Ailesi',
    basisDensity: 'Yoğunluk',
    basisWasteAllowance: 'Fire Payı',
    basisQuantity: 'Adet',
    basisWeldLengthPerPiece: 'Parça Başına Kaynak Uzunluğu',
    basisPipeOd: 'Boru Dış Çapı',
    basisThickness: 'Kalınlık',
    basisThicknessA: 'Kalınlık A',
    basisThicknessB: 'Kalınlık B',
    basisControllingThickness: 'Belirleyici Kalınlık',
    basisOdA: 'Dış Çap A',
    basisOdB: 'Dış Çap B',
    basisReferenceOd: 'Referans Dış Çap',
    basisRootGap: 'Kök Aralığı',
    basisRootFace: 'Kök Yüzü',
    basisRootFacePerSide: 'Taraf Başına Kök Yüzü',
    basisBevelAngle: 'Pah Açısı',
    basisPrimaryBevelAngle: 'Birincil Pah Açısı',
    basisSecondaryBevelAngle: 'İkincil Pah Açısı',
    basisBreakHeight: 'Kırılma Yüksekliği',
    basisFilletLegSize: 'Köşe Kaynağı Kenar Ölçüsü',
    basisUserDefinedRate: 'Kullanıcı Tanımlı Hız',
    basisWireDiameter: 'Tel Çapı',
    basisElectrodeDiameter: 'Elektrot Çapı',
    basisGtawTransitionDepth: 'GTAW Geçiş Derinliği',
    basisGtawDepositionRate: 'GTAW Dolgu Hızı',
    basisGtawWireDiameter: 'GTAW Tel Çapı',
    basisSmawDepositionRate: 'SMAW Dolgu Hızı',
    basisSmawElectrodeDiameter: 'SMAW Elektrot Çapı',
    wizardJointDimensionsTitle: 'Birleşim ve Ölçüler',
    wizardConsumableRateTitle: 'Sarf Malzeme ve Hız',
    wizardProcessStepSubtitle:
        'Bu kaynak için kullanılacak yöntemi seçin. Bu, sonraki adımlar için dolgu varsayılanlarını ve dolgu seçeneklerini belirler.',
    wizardReviewCalculateTitle: 'Gözden Geçir ve Hesapla',
    wizardReviewCalculateSubtitle:
        'Aşağıdaki kurulumu onaylayın, ardından hesaplayın. Değiştirmek için herhangi bir adımı düzenleyin.',
    wizardRecapProcessTitle: 'Yöntem',
    wizardRecapDimensionsTitle: 'Ölçüler',
    wizardRecapConsumableTitle: 'Sarf Malzeme',
    wizardStepOfLabel: 'Adım {current} / {total}',
    resultsSummaryCaption:
        'Mühendislik incelemesi, malzeme planlaması ve sarf malzeme karşılaştırması için rapor kalitesinde özet.',
    resultsDisclaimer:
        "Bu ilk aşama bir planlama tahminidir — üretime geçmeden önce kalifiye WPS'inize ve bir test kuponuna göre doğrulayın.",
    resultsPdfPreparing: 'PDF hazırlanıyor...',
    resultsPdfUnlock: 'PDF Kilidini Aç',
    resultsPdfExport: 'PDF Dışa Aktar',
    resultsEstimateReadyBadge: 'TAHMİN HAZIR',
    resultsHighlightSentence:
        'Tahmini dolgu metali tüketimi {filler} kg, ark süresi {arcTime} h.',
    resultsHighlightEffectiveRate: 'Etkin Hız',
    resultsHighlightFillerPerMeter: 'Metre Başına Dolgu',
    resultsHighlightArcOnPerMeter: 'Metre Başına Ark Süresi',
    metricWeldArea: 'Kaynak Alanı',
    metricWeldLength: 'Kaynak Uzunluğu',
    metricWeldMetalVolume: 'Kaynak Metali Hacmi',
    metricWeldMetalWeight: 'Kaynak Metali Ağırlığı',
    metricFillerMetalConsumption: 'Dolgu Metali Tüketimi',
    metricEstimatedArcOnTime: 'Tahmini Ark Süresi',
    metricEffectiveDepositionEfficiency: 'Etkin Dolgu Verimi',
    metricEffectiveDepositionRate: 'Etkin Dolgu Hızı',
    resultsNextStandardLeg:
        'Bir üst standart kenar ölçüsü ({size}mm), yaklaşık %{percent} daha fazla dolgu gerektirir.',
    insightWeldMetalPerMeter: 'Metre Başına Kaynak Metali',
    insightFillerPerJoint: 'Birleşim Başına Dolgu',
    insightArcOnPerJoint: 'Birleşim Başına Ark Süresi',
    insightEfficiencyLossBasis: 'Verim Kaybı Esası',
    insightWasteAllowanceBasis: 'Fire Payı Esası',
    insightConsumptionMultiplier: 'Tüketim Çarpanı',
    processBreakdownTitle: 'Yöntem Dağılımı',
    processBreakdownSubtitle:
        'Biriken kaynak metali, dolgu ihtiyacı ve ark süresinin yöntem segmentine göre dağılımı.',
    processBreakdownAreaShare: 'Alan Payı %{value}',
    processBreakdownWeldMetal: 'Kaynak Metali {value} kg',
    processBreakdownFillerConsumption: 'Dolgu Tüketimi {value} kg',
    processBreakdownArcOnTime: 'Ark Süresi {value} h',
    processBreakdownDepositionRate: 'Dolgu Hızı {value} kg/h',
    processBreakdownDepositionEfficiency: 'Dolgu Verimi {value}',
    engineeringBasisTitle: 'Mühendislik Dayanağı',
    engineeringBasisSubtitle:
        'Geometri, yöntem kurulumu, yoğunluk ve dolgu varsayımları dahil bu tahminde kullanılan tam mühendislik dayanağı.',
    planningIndicatorsTitle: 'Planlama Göstergeleri',
    planningIndicatorsSubtitle:
        'Birleşim seçeneklerini, iş yükünü ve sarf malzeme planlama esasını karşılaştırmaya yardımcı normalize edilmiş göstergeler.',
    engineeringNotesTitle: 'Mühendislik Notları',
    engineeringNote1:
        'Ark süresi yalnızca kaynak süresini kapsar. Montaj, elleçleme, temizlik, yeniden konumlandırma ve muayene dahil değildir.',
    engineeringNote2:
        'Dolgu metali tüketimi, biriken kaynak metalini, yöntem dolgu verimini ve girilen fire payını içerir.',
    engineeringNote3:
        'Sarf malzeme sınıflandırması, malzeme ailesi ve yoğunluk referansı sağlar. Nihai proje veya müşteri gereksinimleri her zaman esas alınmalıdır.',
    engineeringNote4:
        'Bu rapor tahmin ve planlama için uygundur. Onaylı bir WPS, PQR, kaynakçı kalifikasyonu veya serbest bırakma belgesi değildir.',
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
    commonBack: 'Назад',
    commonContinue: 'Далее',
    commonCalculate: 'Рассчитать',
    commonReset: 'Сбросить',
    commonUpdate: 'Обновить',
    commonDone: 'Готово',
    jointTypePipeButt: 'Стыковой шов трубы',
    jointTypePlateButt: 'Стыковой шов листа',
    jointTypeFillet: 'Угловой шов',
    jointTypeHelperPipeButt:
        'Общая длина шва рассчитывается по наружному диаметру трубы, умноженному на количество.',
    jointTypeHelperPlateButt:
        'Общая длина шва рассчитывается по длине сварного шва, умноженной на количество.',
    jointTypeHelperFillet:
        'Площадь углового шва рассчитывается исходя из геометрии с равными катетами и введённой длины шва.',
    grooveSingleV: 'V-образная разделка',
    grooveHalfV: 'Скос одной кромки',
    grooveDoubleV: 'X-образная разделка',
    grooveCompoundV: 'Комбинированная V-разделка',
    grooveSquare: 'Без скоса кромок',
    grooveFillet: 'Угловой шов',
    depositionRateModePreset: 'Расчётный',
    depositionRateModeManual: 'Ручной',
    jointGeometryEqual: 'Равные',
    jointGeometryUnequal: 'Неравные',
    jointAlignmentCenterline: 'Выравнивание по осевой линии',
    jointAlignmentOdMatch: 'Выравнивание по наружному диаметру',
    jointAlignmentIdMatch: 'Выравнивание по внутреннему диаметру',
    drawingModeVisual: 'Наглядный',
    drawingModeTechnical: 'Технический',
    inputPresetCustom: 'Свой вариант',
    inputPresetCsPipeSingleVGtawSmaw: 'CS Труба, V-разделка / GTAW + SMAW',
    inputPresetCsPipeDoubleVGtawSmaw: 'CS Труба, X-разделка / GTAW + SMAW',
    inputPresetSsPipeSingleVGtaw: 'SS Труба, V-разделка / GTAW',
    inputPresetCsPlateSingleVGmaw: 'CS Лист, V-разделка / GMAW',
    inputPresetCsPlateDoubleVSmaw: 'CS Лист, X-разделка / SMAW',
    inputPresetCsFilletFcaw: 'CS Угловой шов / FCAW',
    inputPresetDescCustom: 'Ручная настройка без применения готовых допущений.',
    inputPresetDescCsPipeSingleVGtawSmaw:
        'Начальная настройка для корневого и заполняющего прохода трубы из углеродистой стали.',
    inputPresetDescCsPipeDoubleVGtawSmaw:
        'Начальная настройка для толстостенной трубы из углеродистой стали с X-образной разделкой.',
    inputPresetDescSsPipeSingleVGtaw:
        'Начальная настройка для трубы из нержавеющей стали только на GTAW.',
    inputPresetDescCsPlateSingleVGmaw:
        'Начальная производственная настройка для листа из углеродистой стали с V-разделкой.',
    inputPresetDescCsPlateDoubleVSmaw:
        'Начальная настройка ручной сварки листа из углеродистой стали с X-образной разделкой.',
    inputPresetDescCsFilletFcaw:
        'Начальная настройка для конструкционного углового шва из углеродистой стали.',
    consumablePresetDescEr70s6:
        'Сплошная проволока или присадочный металл из углеродистой стали',
    consumablePresetDescEr70s2:
        'Присадочный металл для GTAW из углеродистой стали',
    consumablePresetDescE7018:
        'Низководородный покрытый электрод из углеродистой стали',
    consumablePresetDescE6010:
        'Целлюлозный корневой электрод из углеродистой стали',
    consumablePresetDescE71t1: 'Порошковая проволока из углеродистой стали',
    consumablePresetDescEr308l: 'Присадочный металл из нержавеющей стали 308L',
    consumablePresetDescE308l16: 'Покрытый электрод из нержавеющей стали 308L',
    consumablePresetDescEr316l: 'Присадочный металл из нержавеющей стали 316L',
    consumablePresetDescEr309l:
        'Присадочный металл 309L для сварки разнородных металлов',
    consumablePresetDescE309l16:
        'Покрытый электрод 309L для сварки разнородных металлов',
    consumablePresetDescEr5356:
        'Присадочный металл из алюминиевого сплава 5356',
    consumablePresetDescGtawRootSmawFill:
        'Типичное сочетание корня и заполнения для трубы из углеродистой стали',
    consumablePresetDescE6013:
        'Рутиловый, простой в использовании универсальный электрод, AC/DC',
    consumablePresetDescE7024:
        'Электрод с железным порошком, высокая скорость наплавки, нижнее/горизонтальное положение угловых швов',
    consumablePresetDescEr70s3:
        'Универсальная сплошная проволока GMAW для углеродистой стали',
    consumablePresetDescE7018a1:
        'Низководородный электрод для труб из низколегированной стали с 0,5% Mo',
    consumablePresetDescE8018c3:
        'Низководородный электрод для низкотемпературной стали с никелем (~1% Ni)',
    consumablePresetDescEr80sNi1:
        'Присадочный металл из никельсодержащей низколегированной стали для низкотемпературной эксплуатации',
    consumablePresetDescEr80sB2:
        'Хромомолибденовый присадочный металл для труб, работающих при повышенной температуре',
    consumablePresetDescE316l16: 'Электрод SMAW, аналог ER316L',
    consumablePresetDescEr347:
        'Присадочный металл из нержавеющей стали, стабилизированной ниобием, для высокотемпературной службы, устойчивой к выпадению карбидов',
    consumablePresetDescEr4043:
        'Универсальный алюминиевый присадочный металл с 5% кремния, хорошая текучесть и стойкость к трещинам',
    consumablePresetDescEr5183:
        'Высокомагниевый присадочный металл для морских и высокопрочных алюминиевых конструкций',
    consumablePresetDescEniCi:
        'Электрод из почти чистого никеля для ремонтной сварки чугуна',
    consumablePresetDescEnifeCi:
        'Никель-железный электрод для ремонта чугуна повышенной прочности',
    consumablePresetDescErnicr3:
        'Никель-хромовая присадочная проволока для Inconel и сварки разнородных металлов',
    consumablePresetDescEnicrfe3:
        'Никель-хром-железный электрод, вариант применения SMAW, аналогичный ERNiCr-3',
    consumablePresetDescErcusiA:
        'Кремнисто-бронзовый присадочный металл для меди и пайкосварки',
    consumablePresetDescEcualA2:
        'Алюминиево-бронзовый электрод для износостойкой наплавки и соединений разнородных металлов',
    consumableCustomFallbackDescription:
        'Пользовательский присадочный материал из вашей библиотеки.',
    consumableCustomNoTypicalBaseMetals:
        'Для этого пользовательского материала типичные основные металлы не указаны.',
    calcActiveEngineeringBasisTitle: 'Текущая инженерная основа',
    calcJointTypeSectionTitle: 'Тип соединения',
    calcMemberGeometrySectionTitle: 'Геометрия элементов',
    calcAlignmentReferenceLabel: 'Опорное выравнивание',
    calcAlignmentReferenceHelper:
        'Определяет, как неравные элементы выравниваются на эскизе сечения.',
    calcGrooveTypeLabel: 'Тип разделки',
    calcWeldingProcessLabel: 'Способ сварки',
    calcStartingTemplateTitle: 'Начальный шаблон',
    calcStartingTemplateSubtitle:
        'Загружает полный пример настройки, включая соединение, размеры и '
        'способ сварки, который затем можно изменить.',
    calcInputPresetLabel: 'Шаблон ввода',
    calcConsumableDensityTitle: 'Присадочный материал и плотность',
    calcConsumableDensitySubtitle:
        'Выбор присадочного металла по AWS, информация о группе и основа плотности наплавленного металла.',
    calcConsumableClassificationLabel: 'Классификация присадочного материала',
    calcConsumableClassificationHelper:
        'Выберите классификацию присадочного металла по AWS. Плотность заполняется автоматически, но её можно изменить.',
    calcMyMaterialsHeader: 'Мои материалы',
    calcAsSavedSuffix: ' (как сохранено)',
    drawingLabelFilletWeldFace: 'поверхность углового шва',
    drawingLabelTJoint: 'Т-образное соединение',
    drawingLabelSmawFillCap: 'SMAW заполнение / облицовка',
    drawingLabelGtawRoot: 'GTAW корень',
    calcSelectedClassificationNote: 'Выбранная классификация: {value}',
    calcTypicalBaseMetalsNote: 'Типичные основные металлы: {value}',
    calcRateBasisTitle: 'Основа скорости наплавки',
    calcRateBasisSubtitle:
        'Выберите, откуда берётся скорость наплавки — из расчётных значений по умолчанию для процесса или из введённых вручную данных планирования.',
    calcPresetRateHelperDefault:
        'В расчётном режиме скорость наплавки определяется процессом и диаметром присадки. Используйте его для предварительной оценки, а не для планирования уровня квалификации.',
    calcPresetRateHelperGtawSmaw:
        'В расчётном режиме скорости наплавки GTAW и SMAW определяются по выбранным диаметрам присадки, а затем объединяются с учётом глубины перехода GTAW.',
    calcManualRateHelperDefault:
        'В ручном режиме расчётная скорость заменяется измеренным значением цеха, плановым значением проекта или допущением WPS.',
    calcManualRateHelperGtawSmaw:
        'Ручной режим позволяет ввести отдельные скорости наплавки GTAW и SMAW, чтобы время дуги соответствовало запланированной последовательности корня, заполнения и облицовки.',
    calcInputParametersTitle: 'Параметры ввода',
    calcInputParametersSubtitle:
        'Допущения по умолчанию: плотность {density} г/см³, припуск на потери {waste}%',
    calcDimensionalInputsTitle: 'Размерные параметры',
    calcDimensionalInputsSubtitle:
        'Введите геометрию шва, размер элемента, диаметр для процесса и допущения расчёта.',
    calcRunEstimateTitle: 'Выполнить расчёт',
    calcRunEstimateSubtitle:
        'Используйте «Рассчитать» для обновления расчёта. «Сбросить» восстанавливает исходные инженерные значения по умолчанию.',
    calcSaveAsPresetLabel: 'Сохранить как шаблон',
    calcUpdateSavedCalculationLabel: 'Обновить сохранённый расчёт',
    calcPdfHintBeforeResult:
        'Экспорт в PDF становится доступен после успешного расчёта, чтобы отчёт всегда отражал актуальную инженерную основу.',
    calcPdfHintAfterResult:
        'Панель отчёта готова к аккуратному выводу в PDF, как только расчёт выглядит корректным.',
    calcResultsTitle: 'Результаты',
    calcEmptyResultsBodyDefault:
        'Способ {process} использует свой активный КПД наплавки и основу скорости наплавки. Выберите соединение, проверьте параметры ввода, затем выполните расчёт.',
    calcEmptyResultsBodyGtawSmaw:
        'Выберите соединение, затем перед расчётом введите глубину перехода GTAW вместе с диаметрами проволоки GTAW и электрода SMAW.',
    calcEditInputsTooltip: 'Изменить параметры',
    calcEditInputsButton: 'Изменить параметры',
    calcBackToDashboardTooltip: 'Назад на главную',
    techDrawingTitle: 'Техническое изображение',
    techDrawingModeTechnicalDesc:
        'Технический режим применяет инженерные толщины линий, штриховку и размерные обозначения.',
    techDrawingModeVisualDesc:
        'Наглядный режим делает эскиз более простым, сохраняя при этом текущую геометрию соединения.',
    calcCustomDiameterOption: 'Свой диаметр',
    calcCustomDiameterLabel: 'Свой диаметр (мм)',
    calcCustomDiameterHelper: 'Введите точное значение диаметра.',
    calcPresetNameDialogSaveTitle: 'Сохранить шаблон',
    calcPresetNameDialogUpdateTitle: 'Обновить шаблон',
    calcPresetNameHelper: 'Используйте короткое техническое название.',
    calcSaveWithAccountTitle: 'Сохранить с учётной записью',
    calcSaveWithAccountBody:
        'Введите свой email, чтобы сохранить этот шаблон. Используйте тот '
        'же email на любом устройстве, чтобы получить его снова.',
    calcAccountEmailInvalidError: 'Введите корректный email.',
    calcCalculationFailedError:
        'Расчёт не выполнен. Пожалуйста, проверьте введённые данные.',
    calcFieldRequiredError: '{label} должно быть корректным числом.',
    calcErrorLabelQuantity: 'Количество',
    calcErrorLabelDensity: 'Плотность',
    calcErrorLabelWasteFactor: 'Припуск на потери',
    calcFieldQuantityLabel: 'Количество',
    calcFieldQuantityHelper: 'Количество одинаковых швов.',
    calcFieldWeldLengthLabel: 'Длина шва на деталь (мм)',
    calcFieldWeldLengthHelper: 'Длина прямого участка шва.',
    calcFieldPipeOdALabel: 'Наружный диаметр трубы A (мм)',
    calcFieldPipeOdAHelper: 'Наружный диаметр элемента A.',
    calcFieldPipeOdBLabel: 'Наружный диаметр трубы B (мм)',
    calcFieldPipeOdBHelper: 'Наружный диаметр элемента B.',
    calcFieldPipeOdLabel: 'Наружный диаметр трубы (мм)',
    calcFieldPipeOdHelper:
        'Наружный диаметр, используемый для расчёта длины окружности.',
    calcFieldThicknessALabel: 'Толщина A (мм)',
    calcFieldThicknessAHelper: 'Толщина стенки или листа элемента A.',
    calcFieldThicknessBLabel: 'Толщина B (мм)',
    calcFieldThicknessBHelper: 'Толщина стенки или листа элемента B.',
    calcFieldRootGapLabel: 'Зазор корня (мм)',
    calcFieldRootGapHelper: 'Раскрытие корня.',
    calcFieldThicknessLabel: 'Толщина (мм)',
    calcFieldThicknessHelper: 'Толщина основного материала.',
    calcFieldRootFacePerSideLabel: 'Притупление на сторону (мм)',
    calcFieldRootFacePerSideHelper:
        'Притупление корня с каждой стороны от осевой линии соединения.',
    calcFieldRootFaceLabel: 'Притупление корня (мм)',
    calcFieldRootFaceHelper: 'Притупление корня перед началом скоса.',
    calcFieldBevelAngleLabel: 'Угол скоса (°)',
    calcFieldBevelAngleHelper: 'Учитывается как угол скоса в градусах.',
    calcFieldPrimaryAngleLabel: 'Первичный угол альфа (°)',
    calcFieldPrimaryAngleHelper: 'Нижний угол скоса у корня.',
    calcFieldSecondaryAngleLabel: 'Вторичный угол бета (°)',
    calcFieldSecondaryAngleHelper: 'Верхний угол скоса выше точки излома.',
    calcFieldBreakHeightLabel: 'Высота излома h (мм)',
    calcFieldBreakHeightHelper:
        'Расстояние от притупления корня до точки излома скоса.',
    calcFieldLegSizeLabel: 'Катет шва (мм)',
    calcFieldLegSizeHelper: 'Равный катет углового шва.',
    calcFieldGtawWireDiameterLabel: 'Диаметр проволоки GTAW (мм)',
    calcFieldGtawWireDiameterHelper:
        'Распространённые диаметры присадки: 1.6, 2.0, 2.4, 3.2 мм.',
    calcFieldSmawElectrodeDiameterLabel: 'Диаметр электрода SMAW (мм)',
    calcFieldSmawElectrodeDiameterHelper:
        'Распространённые диаметры электрода: 2.5, 3.2, 4.0, 5.0 мм.',
    calcFieldGmawWireDiameterLabel: 'Диаметр проволоки GMAW (мм)',
    calcFieldGmawWireDiameterHelper:
        'Распространённые диаметры проволоки: 0.8, 1.0, 1.2, 1.6 мм.',
    calcFieldFcawWireDiameterLabel: 'Диаметр проволоки FCAW (мм)',
    calcFieldFcawWireDiameterHelper:
        'Распространённые диаметры проволоки: 1.2, 1.6, 2.0 мм.',
    calcFieldGtawTransitionLabel: 'Глубина перехода GTAW (мм)',
    calcFieldGtawTransitionHelper:
        'Глубина, наплавляемая GTAW со стороны корня перед переходом на SMAW.',
    calcFieldGtawDepositionRateLabel: 'Скорость наплавки GTAW (кг/ч)',
    calcFieldGtawDepositionRateHelper:
        'Заданная пользователем скорость наплавки для корневой части GTAW.',
    calcFieldSmawDepositionRateLabel: 'Скорость наплавки SMAW (кг/ч)',
    calcFieldSmawDepositionRateHelper:
        'Заданная пользователем скорость наплавки для заполняющей и облицовочной части SMAW.',
    calcFieldDepositionRateLabel: 'Скорость наплавки (кг/ч)',
    calcFieldDepositionRateHelper:
        'Заданная пользователем скорость наплавки на основе цеховых данных, планового значения или допущения WPS.',
    calcFieldDensityLabel: 'Плотность (г/см³)',
    calcFieldDensityHelper:
        'Объёмная плотность наплавленного металла. По умолчанию соответствует выбранной классификации.',
    calcFieldWasteAllowanceLabel: 'Припуск на потери (%)',
    calcFieldWasteAllowanceHelper:
        'Припуск на огарки, обрезки, разбрызгивание и обращение с материалом.',
    basisProcess: 'Способ сварки',
    basisRateBasis: 'Основа скорости наплавки',
    basisInputPreset: 'Шаблон ввода',
    basisSavedPreset: 'Сохранённый шаблон',
    basisJoint: 'Соединение',
    basisGeometry: 'Геометрия',
    basisAlignment: 'Выравнивание',
    basisGroove: 'Разделка',
    basisClassification: 'Классификация',
    basisFillerMetalFamily: 'Группа присадочного металла',
    basisDensity: 'Плотность',
    basisWasteAllowance: 'Припуск на потери',
    basisQuantity: 'Количество',
    basisWeldLengthPerPiece: 'Длина шва на деталь',
    basisPipeOd: 'Наружный диаметр трубы',
    basisThickness: 'Толщина',
    basisThicknessA: 'Толщина A',
    basisThicknessB: 'Толщина B',
    basisControllingThickness: 'Определяющая толщина',
    basisOdA: 'Наружный диаметр A',
    basisOdB: 'Наружный диаметр B',
    basisReferenceOd: 'Опорный наружный диаметр',
    basisRootGap: 'Зазор корня',
    basisRootFace: 'Притупление корня',
    basisRootFacePerSide: 'Притупление на сторону',
    basisBevelAngle: 'Угол скоса',
    basisPrimaryBevelAngle: 'Первичный угол скоса',
    basisSecondaryBevelAngle: 'Вторичный угол скоса',
    basisBreakHeight: 'Высота излома',
    basisFilletLegSize: 'Катет углового шва',
    basisUserDefinedRate: 'Заданная пользователем скорость',
    basisWireDiameter: 'Диаметр проволоки',
    basisElectrodeDiameter: 'Диаметр электрода',
    basisGtawTransitionDepth: 'Глубина перехода GTAW',
    basisGtawDepositionRate: 'Скорость наплавки GTAW',
    basisGtawWireDiameter: 'Диаметр проволоки GTAW',
    basisSmawDepositionRate: 'Скорость наплавки SMAW',
    basisSmawElectrodeDiameter: 'Диаметр электрода SMAW',
    wizardJointDimensionsTitle: 'Соединение и размеры',
    wizardConsumableRateTitle: 'Присадка и скорость наплавки',
    wizardProcessStepSubtitle:
        'Выберите способ сварки для этого шва. Он задаёт параметры наплавки по умолчанию и варианты присадки для следующих шагов.',
    wizardReviewCalculateTitle: 'Проверка и расчёт',
    wizardReviewCalculateSubtitle:
        'Проверьте настройку ниже, затем выполните расчёт. Чтобы изменить любой шаг, отредактируйте его.',
    wizardRecapProcessTitle: 'Способ сварки',
    wizardRecapDimensionsTitle: 'Размеры',
    wizardRecapConsumableTitle: 'Присадка',
    wizardStepOfLabel: 'Шаг {current} из {total}',
    resultsSummaryCaption:
        'Сводка отчётного качества для инженерного анализа, планирования материалов и сравнения присадочных материалов.',
    resultsDisclaimer:
        'Это предварительная плановая оценка — перед запуском в производство сверьтесь с квалифицированной технологической картой (WPS) и контрольным образцом.',
    resultsPdfPreparing: 'Подготовка PDF...',
    resultsPdfUnlock: 'Разблокировать PDF',
    resultsPdfExport: 'Экспорт в PDF',
    resultsEstimateReadyBadge: 'РАСЧЁТ ГОТОВ',
    resultsHighlightSentence:
        'Расчётный расход присадочного металла составляет {filler} кг при времени горения дуги {arcTime} ч.',
    resultsHighlightEffectiveRate: 'Фактическая скорость',
    resultsHighlightFillerPerMeter: 'Присадка на метр',
    resultsHighlightArcOnPerMeter: 'Время дуги на метр',
    metricWeldArea: 'Площадь шва',
    metricWeldLength: 'Длина шва',
    metricWeldMetalVolume: 'Объём наплавленного металла',
    metricWeldMetalWeight: 'Масса наплавленного металла',
    metricFillerMetalConsumption: 'Расход присадочного металла',
    metricEstimatedArcOnTime: 'Расчётное время горения дуги',
    metricEffectiveDepositionEfficiency: 'Фактический КПД наплавки',
    metricEffectiveDepositionRate: 'Фактическая скорость наплавки',
    resultsNextStandardLeg:
        'Следующий стандартный катет ({size} мм) требует примерно на {percent}% больше присадки.',
    insightWeldMetalPerMeter: 'Наплавленный металл на метр',
    insightFillerPerJoint: 'Присадка на соединение',
    insightArcOnPerJoint: 'Время дуги на соединение',
    insightEfficiencyLossBasis: 'Основа потерь на КПД',
    insightWasteAllowanceBasis: 'Основа припуска на потери',
    insightConsumptionMultiplier: 'Коэффициент расхода',
    processBreakdownTitle: 'Разбивка по способам сварки',
    processBreakdownSubtitle:
        'Распределение наплавленного металла, потребности в присадке и времени дуги по сегментам процесса.',
    processBreakdownAreaShare: 'Доля площади {value}%',
    processBreakdownWeldMetal: 'Наплавленный металл {value} кг',
    processBreakdownFillerConsumption: 'Расход присадки {value} кг',
    processBreakdownArcOnTime: 'Время дуги {value} ч',
    processBreakdownDepositionRate: 'Скорость наплавки {value} кг/ч',
    processBreakdownDepositionEfficiency: 'КПД наплавки {value}',
    engineeringBasisTitle: 'Инженерная основа',
    engineeringBasisSubtitle:
        'Полная инженерная основа, использованная в этой оценке, включая геометрию, настройку процесса, плотность и допущения по наплавке.',
    planningIndicatorsTitle: 'Плановые показатели',
    planningIndicatorsSubtitle:
        'Нормализованные показатели, помогающие сравнивать варианты соединений, трудозатраты и основу планирования присадочных материалов.',
    engineeringNotesTitle: 'Инженерные примечания',
    engineeringNote1:
        'Время горения дуги учитывает только время сварки. Сборка, обращение с деталями, очистка, перепозиционирование и контроль не включены.',
    engineeringNote2:
        'Расход присадочного металла включает наплавленный металл, КПД наплавки процесса и введённый припуск на потери.',
    engineeringNote3:
        'Классификация присадочного материала даёт справочную информацию о группе материала и плотности. Итоговые требования проекта или заказчика всегда имеют приоритет.',
    engineeringNote4:
        'Этот отчёт подходит для оценки и планирования. Он не является утверждённой технологической картой (WPS), протоколом аттестации (PQR), документом аттестации сварщика или разрешительным документом.',
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
    commonBack: 'Zurück',
    commonContinue: 'Weiter',
    commonCalculate: 'Berechnen',
    commonReset: 'Zurücksetzen',
    commonUpdate: 'Aktualisieren',
    commonDone: 'Fertig',
    jointTypePipeButt: 'Rohr-Stumpfnaht',
    jointTypePlateButt: 'Blech-Stumpfnaht',
    jointTypeFillet: 'Kehlnaht',
    jointTypeHelperPipeButt:
        'Die Gesamtschweißnahtlänge wird aus dem Rohraußendurchmesser x Anzahl berechnet.',
    jointTypeHelperPlateButt:
        'Die Gesamtschweißnahtlänge wird aus der Schweißnahtlänge x Anzahl berechnet.',
    jointTypeHelperFillet:
        'Die Kehlnahtfläche basiert auf gleichschenkliger Geometrie und der eingegebenen Schweißnahtlänge.',
    grooveSingleV: 'V-Naht',
    grooveHalfV: 'HV-Naht',
    grooveDoubleV: 'Doppel-V-Naht',
    grooveCompoundV: 'Verbund-V-Naht',
    grooveSquare: 'I-Naht',
    grooveFillet: 'Kehlnaht',
    depositionRateModePreset: 'Geschätzt',
    depositionRateModeManual: 'Manuell',
    jointGeometryEqual: 'Gleich',
    jointGeometryUnequal: 'Ungleich',
    jointAlignmentCenterline: 'Mittellinien-Ausrichtung',
    jointAlignmentOdMatch: 'Außendurchmesser-Ausrichtung',
    jointAlignmentIdMatch: 'Innendurchmesser-Ausrichtung',
    drawingModeVisual: 'Visuell',
    drawingModeTechnical: 'Technisch',
    inputPresetCustom: 'Benutzerdefiniert',
    inputPresetCsPipeSingleVGtawSmaw: 'CS-Rohr V-Naht / GTAW + SMAW',
    inputPresetCsPipeDoubleVGtawSmaw: 'CS-Rohr Doppel-V-Naht / GTAW + SMAW',
    inputPresetSsPipeSingleVGtaw: 'SS-Rohr V-Naht / GTAW',
    inputPresetCsPlateSingleVGmaw: 'CS-Blech V-Naht / GMAW',
    inputPresetCsPlateDoubleVSmaw: 'CS-Blech Doppel-V-Naht / SMAW',
    inputPresetCsFilletFcaw: 'CS-Kehlnaht / FCAW',
    inputPresetDescCustom:
        'Manuelle Einrichtung ohne angewendete Vorlagenannahmen.',
    inputPresetDescCsPipeSingleVGtawSmaw:
        'Ausgangseinrichtung für Wurzel- und Fülllage bei Kohlenstoffstahlrohr.',
    inputPresetDescCsPipeDoubleVGtawSmaw:
        'Ausgangseinrichtung für dickwandiges Kohlenstoffstahlrohr mit Doppel-V-Naht.',
    inputPresetDescSsPipeSingleVGtaw:
        'Ausgangseinrichtung für Edelstahlrohr, nur GTAW.',
    inputPresetDescCsPlateSingleVGmaw:
        'Produktions-Ausgangseinrichtung für Kohlenstoffstahlblech mit V-Naht.',
    inputPresetDescCsPlateDoubleVSmaw:
        'Ausgangseinrichtung für manuelles Schweißen von Kohlenstoffstahlblech mit Doppel-V-Naht.',
    inputPresetDescCsFilletFcaw:
        'Ausgangseinrichtung für strukturelle Kehlnaht aus Kohlenstoffstahl.',
    consumablePresetDescEr70s6:
        'Massivdraht oder Zusatzwerkstoff aus Kohlenstoffstahl',
    consumablePresetDescEr70s2: 'GTAW-Zusatzwerkstoff aus Kohlenstoffstahl',
    consumablePresetDescE7018:
        'Wasserstoffarme umhüllte Elektrode aus Kohlenstoffstahl',
    consumablePresetDescE6010: 'Zellulose-Wurzelelektrode aus Kohlenstoffstahl',
    consumablePresetDescE71t1: 'Fülldraht aus Kohlenstoffstahl',
    consumablePresetDescEr308l: 'Zusatzwerkstoff aus 308L-Edelstahl',
    consumablePresetDescE308l16: 'Umhüllte Elektrode aus 308L-Edelstahl',
    consumablePresetDescEr316l: 'Zusatzwerkstoff aus 316L-Edelstahl',
    consumablePresetDescEr309l: 'Zusatzwerkstoff 309L für Mischverbindungen',
    consumablePresetDescE309l16:
        'Umhüllte Elektrode 309L für Mischverbindungen',
    consumablePresetDescEr5356: 'Zusatzwerkstoff aus Aluminiumlegierung 5356',
    consumablePresetDescGtawRootSmawFill:
        'Typische Kombination aus Wurzel und Füllung für Kohlenstoffstahlrohr',
    consumablePresetDescE6013:
        'Rutil-Elektrode, einfach zu verwenden, Allzweck, AC/DC',
    consumablePresetDescE7024:
        'Eisenpulver-Elektrode, hohe Abschmelzleistung, Wannen-/Horizontalkehlnähte',
    consumablePresetDescEr70s3:
        'Allzweck-Massivdraht für GMAW an Kohlenstoffstahl',
    consumablePresetDescE7018a1:
        'Wasserstoffarme Elektrode für 0,5%-Mo-legierte Stahlrohre',
    consumablePresetDescE8018c3:
        'Wasserstoffarme Elektrode für nickelhaltigen Tieftemperaturstahl (~1% Ni)',
    consumablePresetDescEr80sNi1:
        'Nickelhaltiger niedriglegierter Stahl-Zusatzwerkstoff für Tieftemperatureinsatz',
    consumablePresetDescEr80sB2:
        'Chrom-Molybdän-Zusatzwerkstoff für Rohrleitungen bei erhöhter Temperatur',
    consumablePresetDescE316l16: 'SMAW-Elektrode als Gegenstück zu ER316L',
    consumablePresetDescEr347:
        'Niob-stabilisierter Edelstahl-Zusatzwerkstoff für hochtemperatur- und karbidausscheidungsbeständigen Einsatz',
    consumablePresetDescEr4043:
        'Allzweck-Aluminium-Zusatzwerkstoff mit 5% Silizium, gute Fließfähigkeit/Rissbeständigkeit',
    consumablePresetDescEr5183:
        'Hochmagnesium-Zusatzwerkstoff für Meeres- und hochfeste Aluminiumkonstruktionen',
    consumablePresetDescEniCi:
        'Elektrode aus nahezu reinem Nickel für Gusseisen-Reparaturschweißung',
    consumablePresetDescEnifeCi:
        'Nickel-Eisen-Elektrode für höherfeste Gusseisenreparaturen',
    consumablePresetDescErnicr3:
        'Nickel-Chrom-Blankdraht für Inconel und Mischmetallverbindungen',
    consumablePresetDescEnicrfe3:
        'Nickel-Chrom-Eisen-Elektrode, SMAW-Gegenstück zu ERNiCr-3',
    consumablePresetDescErcusiA:
        'Silizium-Bronze-Zusatzwerkstoff für Kupfer und Lötschweißanwendungen',
    consumablePresetDescEcualA2:
        'Aluminiumbronze-Elektrode für verschleißfeste Auftragsschweißungen und Mischverbindungen',
    consumableCustomFallbackDescription:
        'Benutzerdefinierter Zusatzwerkstoff aus Ihrer Bibliothek.',
    consumableCustomNoTypicalBaseMetals:
        'Für dieses benutzerdefinierte Material sind keine typischen Grundwerkstoffe hinterlegt.',
    calcActiveEngineeringBasisTitle: 'Aktive technische Grundlage',
    calcJointTypeSectionTitle: 'Verbindungsart',
    calcMemberGeometrySectionTitle: 'Bauteilgeometrie',
    calcAlignmentReferenceLabel: 'Ausrichtungsreferenz',
    calcAlignmentReferenceHelper:
        'Legt fest, wie ungleiche Bauteile in der Querschnittsskizze ausgerichtet werden.',
    calcGrooveTypeLabel: 'Nahtform',
    calcWeldingProcessLabel: 'Schweißverfahren',
    calcStartingTemplateTitle: 'Ausgangsvorlage',
    calcStartingTemplateSubtitle:
        'Lädt eine vollständige Beispieleinrichtung inklusive Verbindung, '
        'Abmessungen und Schweißverfahren, die Sie anschließend anpassen können.',
    calcInputPresetLabel: 'Eingabevorlage',
    calcConsumableDensityTitle: 'Zusatzwerkstoff & Dichte',
    calcConsumableDensitySubtitle:
        'AWS-Zusatzwerkstoffauswahl, Werkstoffgruppe und Dichtegrundlage des Schweißguts.',
    calcConsumableClassificationLabel: 'Zusatzwerkstoffklassifizierung',
    calcConsumableClassificationHelper:
        'Wählen Sie eine AWS-Zusatzwerkstoffklassifizierung. Die Dichte wird automatisch übernommen und kann weiterhin angepasst werden.',
    calcMyMaterialsHeader: 'Meine Materialien',
    calcAsSavedSuffix: ' (wie gespeichert)',
    drawingLabelFilletWeldFace: 'Kehlnahtoberfläche',
    drawingLabelTJoint: 'T-Verbindung',
    drawingLabelSmawFillCap: 'SMAW Füllung / Decklage',
    drawingLabelGtawRoot: 'GTAW Wurzel',
    calcSelectedClassificationNote: 'Ausgewählte Klassifizierung: {value}',
    calcTypicalBaseMetalsNote: 'Typische Grundwerkstoffe: {value}',
    calcRateBasisTitle: 'Abschmelzgrundlage',
    calcRateBasisSubtitle:
        'Wählen Sie, ob die Abschmelzleistung aus geschätzten Verfahrensvorgaben oder aus manuellen Planungsdaten stammt.',
    calcPresetRateHelperDefault:
        'Der geschätzte Modus leitet die Abschmelzleistung aus Verfahren und Zusatzwerkstoffdurchmesser ab. Verwenden Sie ihn für Vorabschätzungen, nicht für Planungen auf Qualifikationsniveau.',
    calcPresetRateHelperGtawSmaw:
        'Der geschätzte Modus leitet GTAW- und SMAW-Abschmelzleistungen aus den gewählten Zusatzwerkstoffdurchmessern ab und kombiniert sie anhand der GTAW-Übergangstiefe.',
    calcManualRateHelperDefault:
        'Der manuelle Modus überschreibt die geschätzte Leistung mit einem gemessenen Werkstattwert, einem Projektplanungswert oder einer WPS-Annahme.',
    calcManualRateHelperGtawSmaw:
        'Im manuellen Modus können Sie getrennte GTAW- und SMAW-Abschmelzleistungen eingeben, damit die Brennzeit der geplanten Wurzel-, Füll- und Decklagenfolge folgt.',
    calcInputParametersTitle: 'Eingabeparameter',
    calcInputParametersSubtitle:
        'Standardannahmen: Dichte {density} g/cm3, Verschnittzuschlag {waste}%',
    calcDimensionalInputsTitle: 'Maßliche Eingaben',
    calcDimensionalInputsSubtitle:
        'Geben Sie Nahtgeometrie, Bauteilgröße, Verfahrensdurchmesser und Berechnungsannahmen ein.',
    calcRunEstimateTitle: 'Schätzung ausführen',
    calcRunEstimateSubtitle:
        'Verwenden Sie Berechnen, um die Live-Schätzung zu aktualisieren. Zurücksetzen stellt die technischen Standardausgangswerte wieder her.',
    calcSaveAsPresetLabel: 'Als Vorlage speichern',
    calcUpdateSavedCalculationLabel: 'Gespeicherte Berechnung aktualisieren',
    calcPdfHintBeforeResult:
        'Der PDF-Export wird nach einer erfolgreichen Schätzung aktiviert, damit der Bericht stets die aktuelle technische Grundlage widerspiegelt.',
    calcPdfHintAfterResult:
        'Das Berichtspanel ist bereit für einen ausgearbeiteten PDF-Export, sobald die Schätzung korrekt aussieht.',
    calcResultsTitle: 'Ergebnisse',
    calcEmptyResultsBodyDefault:
        'Wählen Sie die Verbindung, prüfen Sie die Eingabeparameter und berechnen Sie dann. Das Verfahren {process} verwendet seinen aktiven Abschmelzwirkungsgrad und seine Abschmelzgrundlage.',
    calcEmptyResultsBodyGtawSmaw:
        'Wählen Sie die Verbindung und geben Sie vor der Berechnung die GTAW-Übergangstiefe zusammen mit den Durchmessern von GTAW-Draht und SMAW-Elektrode ein.',
    calcEditInputsTooltip: 'Eingaben bearbeiten',
    calcEditInputsButton: 'Eingaben bearbeiten',
    calcBackToDashboardTooltip: 'Zurück zum Dashboard',
    techDrawingTitle: 'Technische Zeichnung',
    techDrawingModeTechnicalDesc:
        'Der technische Modus verwendet ingenieurmäßige Linienstärken, Schraffuren und Maßangaben.',
    techDrawingModeVisualDesc:
        'Der visuelle Modus hält die Skizze weicher und folgt dennoch der aktuellen Verbindungsgeometrie.',
    calcCustomDiameterOption: 'Eigener Durchmesser',
    calcCustomDiameterLabel: 'Eigener Durchmesser (mm)',
    calcCustomDiameterHelper: 'Geben Sie einen genauen Durchmesserwert ein.',
    calcPresetNameDialogSaveTitle: 'Vorlage speichern',
    calcPresetNameDialogUpdateTitle: 'Vorlage aktualisieren',
    calcPresetNameHelper:
        'Verwenden Sie einen kurzen technischen Referenznamen.',
    calcSaveWithAccountTitle: 'Mit einem Konto speichern',
    calcSaveWithAccountBody:
        'Geben Sie Ihre E-Mail-Adresse ein, um diese Vorlage zu speichern. '
        'Verwenden Sie dieselbe E-Mail-Adresse auf jedem Gerät, um sie später wiederzuerhalten.',
    calcAccountEmailInvalidError: 'Geben Sie eine gültige E-Mail-Adresse ein.',
    calcCalculationFailedError:
        'Berechnung fehlgeschlagen. Bitte überprüfen Sie die Eingaben.',
    calcFieldRequiredError: '{label} muss eine gültige Zahl sein.',
    calcErrorLabelQuantity: 'Anzahl',
    calcErrorLabelDensity: 'Dichte',
    calcErrorLabelWasteFactor: 'Verschnittfaktor',
    calcFieldQuantityLabel: 'Anzahl',
    calcFieldQuantityHelper: 'Anzahl identischer Schweißnähte.',
    calcFieldWeldLengthLabel: 'Nahtlänge pro Werkstück (mm)',
    calcFieldWeldLengthHelper: 'Länge der geraden Schweißnaht.',
    calcFieldPipeOdALabel: 'Rohraußendurchmesser A (mm)',
    calcFieldPipeOdAHelper: 'Außendurchmesser von Bauteil A.',
    calcFieldPipeOdBLabel: 'Rohraußendurchmesser B (mm)',
    calcFieldPipeOdBHelper: 'Außendurchmesser von Bauteil B.',
    calcFieldPipeOdLabel: 'Rohraußendurchmesser (mm)',
    calcFieldPipeOdHelper:
        'Für die Umfangsberechnung verwendeter Außendurchmesser.',
    calcFieldThicknessALabel: 'Dicke A (mm)',
    calcFieldThicknessAHelper: 'Wand- oder Blechdicke von Bauteil A.',
    calcFieldThicknessBLabel: 'Dicke B (mm)',
    calcFieldThicknessBHelper: 'Wand- oder Blechdicke von Bauteil B.',
    calcFieldRootGapLabel: 'Wurzelspalt (mm)',
    calcFieldRootGapHelper: 'Wurzelöffnung.',
    calcFieldThicknessLabel: 'Dicke (mm)',
    calcFieldThicknessHelper: 'Grundwerkstoffdicke.',
    calcFieldRootFacePerSideLabel: 'Steg je Seite (mm)',
    calcFieldRootFacePerSideHelper:
        'Steg auf jeder Seite der Verbindungsmittellinie.',
    calcFieldRootFaceLabel: 'Steg (mm)',
    calcFieldRootFaceHelper: 'Steg, bevor die Fase beginnt.',
    calcFieldBevelAngleLabel: 'Anfaswinkel (°)',
    calcFieldBevelAngleHelper: 'Wird als Anfaswinkel in Grad einbezogen.',
    calcFieldPrimaryAngleLabel: 'Primärwinkel alpha (°)',
    calcFieldPrimaryAngleHelper: 'Unterer Anfaswinkel nahe der Wurzel.',
    calcFieldSecondaryAngleLabel: 'Sekundärwinkel beta (°)',
    calcFieldSecondaryAngleHelper:
        'Oberer Anfaswinkel oberhalb des Knickpunkts.',
    calcFieldBreakHeightLabel: 'Knickhöhe h (mm)',
    calcFieldBreakHeightHelper: 'Abstand vom Steg zum Anfasenknickpunkt.',
    calcFieldLegSizeLabel: 'Schenkellänge (mm)',
    calcFieldLegSizeHelper: 'Gleichschenklige Schenkellänge der Kehlnaht.',
    calcFieldGtawWireDiameterLabel: 'GTAW-Drahtdurchmesser (mm)',
    calcFieldGtawWireDiameterHelper:
        'Gängige Zusatzwerkstoffdurchmesser: 1.6, 2.0, 2.4, 3.2 mm.',
    calcFieldSmawElectrodeDiameterLabel: 'SMAW-Elektrodendurchmesser (mm)',
    calcFieldSmawElectrodeDiameterHelper:
        'Gängige Elektrodendurchmesser: 2.5, 3.2, 4.0, 5.0 mm.',
    calcFieldGmawWireDiameterLabel: 'GMAW-Drahtdurchmesser (mm)',
    calcFieldGmawWireDiameterHelper:
        'Gängige Drahtdurchmesser: 0.8, 1.0, 1.2, 1.6 mm.',
    calcFieldFcawWireDiameterLabel: 'FCAW-Drahtdurchmesser (mm)',
    calcFieldFcawWireDiameterHelper:
        'Gängige Drahtdurchmesser: 1.2, 1.6, 2.0 mm.',
    calcFieldGtawTransitionLabel: 'GTAW-Übergangstiefe (mm)',
    calcFieldGtawTransitionHelper:
        'Von der Wurzelseite mit GTAW abgeschmolzene Tiefe, bevor auf SMAW gewechselt wird.',
    calcFieldGtawDepositionRateLabel: 'GTAW-Abschmelzleistung (kg/h)',
    calcFieldGtawDepositionRateHelper:
        'Benutzerdefinierte Abschmelzleistung für den GTAW-Wurzelanteil.',
    calcFieldSmawDepositionRateLabel: 'SMAW-Abschmelzleistung (kg/h)',
    calcFieldSmawDepositionRateHelper:
        'Benutzerdefinierte Abschmelzleistung für den SMAW-Füll- und Decklagenanteil.',
    calcFieldDepositionRateLabel: 'Abschmelzleistung (kg/h)',
    calcFieldDepositionRateHelper:
        'Benutzerdefinierte Abschmelzleistung basierend auf Werkstattdaten, Planungswert oder WPS-Annahme.',
    calcFieldDensityLabel: 'Dichte (g/cm3)',
    calcFieldDensityHelper:
        'Schüttdichte des Schweißguts. Der Standardwert folgt der ausgewählten Klassifizierung.',
    calcFieldWasteAllowanceLabel: 'Verschnittzuschlag (%)',
    calcFieldWasteAllowanceHelper:
        'Zuschlag für Stummelverlust, Abschnitt, Spritzer und Handhabung.',
    basisProcess: 'Verfahren',
    basisRateBasis: 'Abschmelzgrundlage',
    basisInputPreset: 'Eingabevorlage',
    basisSavedPreset: 'Gespeicherte Vorlage',
    basisJoint: 'Verbindung',
    basisGeometry: 'Geometrie',
    basisAlignment: 'Ausrichtung',
    basisGroove: 'Nahtform',
    basisClassification: 'Klassifizierung',
    basisFillerMetalFamily: 'Zusatzwerkstoffgruppe',
    basisDensity: 'Dichte',
    basisWasteAllowance: 'Verschnittzuschlag',
    basisQuantity: 'Anzahl',
    basisWeldLengthPerPiece: 'Nahtlänge pro Werkstück',
    basisPipeOd: 'Rohraußendurchmesser',
    basisThickness: 'Dicke',
    basisThicknessA: 'Dicke A',
    basisThicknessB: 'Dicke B',
    basisControllingThickness: 'Maßgebende Dicke',
    basisOdA: 'Außendurchmesser A',
    basisOdB: 'Außendurchmesser B',
    basisReferenceOd: 'Referenzaußendurchmesser',
    basisRootGap: 'Wurzelspalt',
    basisRootFace: 'Steg',
    basisRootFacePerSide: 'Steg je Seite',
    basisBevelAngle: 'Anfaswinkel',
    basisPrimaryBevelAngle: 'Primärer Anfaswinkel',
    basisSecondaryBevelAngle: 'Sekundärer Anfaswinkel',
    basisBreakHeight: 'Knickhöhe',
    basisFilletLegSize: 'Kehlnahtschenkellänge',
    basisUserDefinedRate: 'Benutzerdefinierte Leistung',
    basisWireDiameter: 'Drahtdurchmesser',
    basisElectrodeDiameter: 'Elektrodendurchmesser',
    basisGtawTransitionDepth: 'GTAW-Übergangstiefe',
    basisGtawDepositionRate: 'GTAW-Abschmelzleistung',
    basisGtawWireDiameter: 'GTAW-Drahtdurchmesser',
    basisSmawDepositionRate: 'SMAW-Abschmelzleistung',
    basisSmawElectrodeDiameter: 'SMAW-Elektrodendurchmesser',
    wizardJointDimensionsTitle: 'Verbindung & Abmessungen',
    wizardConsumableRateTitle: 'Zusatzwerkstoff & Leistung',
    wizardProcessStepSubtitle:
        'Wählen Sie das für diese Schweißnaht verwendete Verfahren. Dies legt die Abschmelzvorgaben und Zusatzwerkstoffoptionen für die nächsten Schritte fest.',
    wizardReviewCalculateTitle: 'Prüfen & Berechnen',
    wizardReviewCalculateSubtitle:
        'Bestätigen Sie die Einrichtung unten und berechnen Sie dann. Bearbeiten Sie einen Schritt, um ihn zu ändern.',
    wizardRecapProcessTitle: 'Verfahren',
    wizardRecapDimensionsTitle: 'Abmessungen',
    wizardRecapConsumableTitle: 'Zusatzwerkstoff',
    wizardStepOfLabel: 'Schritt {current} von {total}',
    resultsSummaryCaption:
        'Zusammenfassung in Berichtsqualität für technische Prüfung, Materialplanung und Zusatzwerkstoffvergleich.',
    resultsDisclaimer:
        'Dies ist eine erste Planungsschätzung — überprüfen Sie sie vor dem Produktionseinsatz anhand Ihres qualifizierten WPS und eines Prüfstücks.',
    resultsPdfPreparing: 'PDF wird vorbereitet...',
    resultsPdfUnlock: 'PDF freischalten',
    resultsPdfExport: 'PDF exportieren',
    resultsEstimateReadyBadge: 'SCHÄTZUNG BEREIT',
    resultsHighlightSentence:
        'Der geschätzte Zusatzwerkstoffverbrauch beträgt {filler} kg bei {arcTime} h Lichtbogenbrennzeit.',
    resultsHighlightEffectiveRate: 'Effektive Leistung',
    resultsHighlightFillerPerMeter: 'Zusatzwerkstoff pro Meter',
    resultsHighlightArcOnPerMeter: 'Brennzeit pro Meter',
    metricWeldArea: 'Nahtfläche',
    metricWeldLength: 'Nahtlänge',
    metricWeldMetalVolume: 'Schweißgutvolumen',
    metricWeldMetalWeight: 'Schweißgutgewicht',
    metricFillerMetalConsumption: 'Zusatzwerkstoffverbrauch',
    metricEstimatedArcOnTime: 'Geschätzte Lichtbogenbrennzeit',
    metricEffectiveDepositionEfficiency: 'Effektiver Abschmelzwirkungsgrad',
    metricEffectiveDepositionRate: 'Effektive Abschmelzleistung',
    resultsNextStandardLeg:
        'Die nächstgrößere Standardschenkellänge ({size}mm) benötigt ca. {percent}% mehr Zusatzwerkstoff.',
    insightWeldMetalPerMeter: 'Schweißgut pro Meter',
    insightFillerPerJoint: 'Zusatzwerkstoff pro Verbindung',
    insightArcOnPerJoint: 'Brennzeit pro Verbindung',
    insightEfficiencyLossBasis: 'Wirkungsgradverlust-Grundlage',
    insightWasteAllowanceBasis: 'Verschnittzuschlag-Grundlage',
    insightConsumptionMultiplier: 'Verbrauchsfaktor',
    processBreakdownTitle: 'Verfahrensaufteilung',
    processBreakdownSubtitle:
        'Verteilung von abgeschiedenem Schweißgut, Zusatzwerkstoffbedarf und Brennzeit nach Verfahrensabschnitt.',
    processBreakdownAreaShare: 'Flächenanteil {value}%',
    processBreakdownWeldMetal: 'Schweißgut {value} kg',
    processBreakdownFillerConsumption: 'Zusatzwerkstoffverbrauch {value} kg',
    processBreakdownArcOnTime: 'Brennzeit {value} h',
    processBreakdownDepositionRate: 'Abschmelzleistung {value} kg/h',
    processBreakdownDepositionEfficiency: 'Abschmelzwirkungsgrad {value}',
    engineeringBasisTitle: 'Technische Grundlage',
    engineeringBasisSubtitle:
        'Vollständige technische Grundlage dieser Schätzung, einschließlich Geometrie, Verfahrenseinrichtung, Dichte und Abschmelzannahmen.',
    planningIndicatorsTitle: 'Planungskennzahlen',
    planningIndicatorsSubtitle:
        'Normalisierte Kennzahlen, die beim Vergleich von Verbindungsoptionen, Arbeitsaufwand und Zusatzwerkstoffplanungsgrundlage helfen.',
    engineeringNotesTitle: 'Technische Hinweise',
    engineeringNote1:
        'Die Brennzeit umfasst nur die Schweißzeit. Zusammenbau, Handhabung, Reinigung, Umpositionierung und Prüfung sind nicht enthalten.',
    engineeringNote2:
        'Der Zusatzwerkstoffverbrauch umfasst das abgeschiedene Schweißgut, den Abschmelzwirkungsgrad des Verfahrens und den eingegebenen Verschnittzuschlag.',
    engineeringNote3:
        'Die Zusatzwerkstoffklassifizierung liefert Werkstoffgruppen- und Dichtereferenz. Endgültige Projekt- oder Kundenanforderungen sind stets maßgeblich.',
    engineeringNote4:
        'Dieser Bericht eignet sich für Schätzung und Planung. Er ist kein freigegebenes WPS, PQR, keine Schweißerqualifikation und kein Freigabedokument.',
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
    commonBack: 'वापस',
    commonContinue: 'जारी रखें',
    commonCalculate: 'गणना करें',
    commonReset: 'रीसेट करें',
    commonUpdate: 'अपडेट करें',
    commonDone: 'हो गया',
    jointTypePipeButt: 'पाइप बट वेल्ड',
    jointTypePlateButt: 'प्लेट बट वेल्ड',
    jointTypeFillet: 'फिलेट वेल्ड',
    jointTypeHelperPipeButt:
        'कुल वेल्ड लंबाई पाइप के बाहरी व्यास x मात्रा से गणना की जाती है।',
    jointTypeHelperPlateButt:
        'कुल वेल्ड लंबाई वेल्ड रन लंबाई x मात्रा से गणना की जाती है।',
    jointTypeHelperFillet:
        'फिलेट वेल्ड क्षेत्रफल समान-लेग ज्यामिति और दर्ज की गई वेल्ड लंबाई पर आधारित है।',
    grooveSingleV: 'सिंगल V',
    grooveHalfV: 'हाफ V',
    grooveDoubleV: 'डबल V',
    grooveCompoundV: 'कंपाउंड V',
    grooveSquare: 'स्क्वेयर',
    grooveFillet: 'फिलेट',
    depositionRateModePreset: 'अनुमानित',
    depositionRateModeManual: 'मैनुअल',
    jointGeometryEqual: 'समान',
    jointGeometryUnequal: 'असमान',
    jointAlignmentCenterline: 'सेंटरलाइन मिलान',
    jointAlignmentOdMatch: 'OD मिलान',
    jointAlignmentIdMatch: 'ID मिलान',
    drawingModeVisual: 'विज़ुअल',
    drawingModeTechnical: 'टेक्निकल',
    inputPresetCustom: 'कस्टम',
    inputPresetCsPipeSingleVGtawSmaw: 'CS पाइप सिंगल V / GTAW + SMAW',
    inputPresetCsPipeDoubleVGtawSmaw: 'CS पाइप डबल V / GTAW + SMAW',
    inputPresetSsPipeSingleVGtaw: 'SS पाइप सिंगल V / GTAW',
    inputPresetCsPlateSingleVGmaw: 'CS प्लेट सिंगल V / GMAW',
    inputPresetCsPlateDoubleVSmaw: 'CS प्लेट डबल V / SMAW',
    inputPresetCsFilletFcaw: 'CS फिलेट / FCAW',
    inputPresetDescCustom: 'बिना किसी प्रीसेट असम्पशन के मैनुअल सेटअप।',
    inputPresetDescCsPipeSingleVGtawSmaw:
        'कार्बन स्टील पाइप रूट-पास और फिल-पास स्टार्टर सेटअप।',
    inputPresetDescCsPipeDoubleVGtawSmaw:
        'हैवी-वॉल कार्बन स्टील पाइप डबल-V स्टार्टर सेटअप।',
    inputPresetDescSsPipeSingleVGtaw:
        'केवल GTAW वाला स्टेनलेस पाइप स्टार्टर सेटअप।',
    inputPresetDescCsPlateSingleVGmaw:
        'कार्बन स्टील प्लेट सिंगल-V प्रोडक्शन स्टार्टर सेटअप।',
    inputPresetDescCsPlateDoubleVSmaw:
        'कार्बन स्टील प्लेट डबल-V मैनुअल वेल्डिंग स्टार्टर सेटअप।',
    inputPresetDescCsFilletFcaw:
        'कार्बन स्टील स्ट्रक्चरल फिलेट स्टार्टर सेटअप।',
    consumablePresetDescEr70s6: 'कार्बन स्टील सॉलिड वायर या फिलर मेटल',
    consumablePresetDescEr70s2: 'कार्बन स्टील GTAW फिलर मेटल',
    consumablePresetDescE7018: 'लो-हाइड्रोजन कार्बन स्टील कवर्ड इलेक्ट्रोड',
    consumablePresetDescE6010: 'सेल्युलोसिक कार्बन स्टील रूट इलेक्ट्रोड',
    consumablePresetDescE71t1: 'कार्बन स्टील फ्लक्स-कोर्ड वायर',
    consumablePresetDescEr308l: '308L स्टेनलेस स्टील फिलर मेटल',
    consumablePresetDescE308l16: '308L स्टेनलेस स्टील कवर्ड इलेक्ट्रोड',
    consumablePresetDescEr316l: '316L स्टेनलेस स्टील फिलर मेटल',
    consumablePresetDescEr309l: 'डिसिमिलर वेल्ड के लिए 309L फिलर मेटल',
    consumablePresetDescE309l16: 'डिसिमिलर वेल्ड के लिए 309L कवर्ड इलेक्ट्रोड',
    consumablePresetDescEr5356: '5356 एल्युमिनियम फिलर मेटल',
    consumablePresetDescGtawRootSmawFill:
        'सामान्य कार्बन स्टील पाइप रूट और फिल कॉम्बिनेशन',
    consumablePresetDescE6013:
        'रूटाइल, उपयोग में आसान जनरल-पर्पस इलेक्ट्रोड, AC/DC',
    consumablePresetDescE7024:
        'आयरन-पाउडर इलेक्ट्रोड, हाई डिपॉज़िशन रेट, फ्लैट/हॉरिज़ॉन्टल फिलेट',
    consumablePresetDescEr70s3:
        'कार्बन स्टील के लिए जनरल-पर्पस सॉलिड GMAW वायर',
    consumablePresetDescE7018a1:
        '0.5% Mo एलॉय स्टील पाइपिंग के लिए लो-हाइड्रोजन इलेक्ट्रोड',
    consumablePresetDescE8018c3:
        'निकल-युक्त लो-टेम्परेचर स्टील के लिए लो-हाइड्रोजन इलेक्ट्रोड (~1% Ni)',
    consumablePresetDescEr80sNi1:
        'लो-टेम्परेचर सर्विस के लिए निकल-युक्त लो-एलॉय स्टील फिलर',
    consumablePresetDescEr80sB2: 'हाई-टेम्परेचर पाइपिंग के लिए क्रोम-मोली फिलर',
    consumablePresetDescE316l16: 'ER316L का SMAW काउंटरपार्ट',
    consumablePresetDescEr347:
        'हाई-टेम्परेचर/कार्बाइड-प्रेसिपिटेशन-रेसिस्टेंट सर्विस के लिए नियोबियम-स्टेबिलाइज़्ड स्टेनलेस फिलर',
    consumablePresetDescEr4043:
        'अच्छे फ्लो/क्रैक रेसिस्टेंस वाला जनरल-पर्पस 5% सिलिकॉन एल्युमिनियम फिलर',
    consumablePresetDescEr5183:
        'मरीन और हाई-स्ट्रेंथ एल्युमिनियम स्ट्रक्चर के लिए हाई-मैग्नीशियम फिलर',
    consumablePresetDescEniCi:
        'कास्ट आयरन रिपेयर वेल्डिंग के लिए नियर-प्योर-निकल इलेक्ट्रोड',
    consumablePresetDescEnifeCi:
        'हायर-स्ट्रेंथ कास्ट आयरन रिपेयर के लिए निकल-आयरन इलेक्ट्रोड',
    consumablePresetDescErnicr3:
        'Inconel और डिसिमिलर-मेटल वेल्ड के लिए निकल-क्रोमियम बेयर फिलर वायर',
    consumablePresetDescEnicrfe3:
        'निकल-क्रोमियम-आयरन इलेक्ट्रोड, ERNiCr-3 का SMAW काउंटरपार्ट यूज़-केस',
    consumablePresetDescErcusiA:
        'कॉपर और ब्रेज़-वेल्डिंग एप्लिकेशन के लिए सिलिकॉन ब्रॉन्ज़ फिलर',
    consumablePresetDescEcualA2:
        'वियर-रेसिस्टेंट ओवरले और डिसिमिलर जॉइंट के लिए एल्युमिनियम ब्रॉन्ज़ इलेक्ट्रोड',
    consumableCustomFallbackDescription:
        'आपकी लाइब्रेरी से कस्टम फिलर मटीरियल।',
    consumableCustomNoTypicalBaseMetals:
        'इस कस्टम मटीरियल के लिए कोई टिपिकल बेस मेटल दर्ज नहीं है।',
    calcActiveEngineeringBasisTitle: 'एक्टिव इंजीनियरिंग बेसिस',
    calcJointTypeSectionTitle: 'जॉइंट टाइप',
    calcMemberGeometrySectionTitle: 'मेंबर ज्यामिति',
    calcAlignmentReferenceLabel: 'अलाइनमेंट रेफरेंस',
    calcAlignmentReferenceHelper:
        'यह परिभाषित करता है कि असमान मेंबर सेक्शन स्केच में कैसे अलाइन होते हैं।',
    calcGrooveTypeLabel: 'ग्रूव टाइप',
    calcWeldingProcessLabel: 'वेल्डिंग प्रोसेस',
    calcStartingTemplateTitle: 'स्टार्टिंग टेम्पलेट',
    calcStartingTemplateSubtitle:
        'जॉइंट, डाइमेंशन और वेल्डिंग प्रोसेस सहित एक पूरा उदाहरण सेटअप '
        'लोड करता है, जिसे आप बाद में एडजस्ट कर सकते हैं।',
    calcInputPresetLabel: 'इनपुट प्रीसेट',
    calcConsumableDensityTitle: 'कंज़्यूमेबल और डेंसिटी',
    calcConsumableDensitySubtitle:
        'AWS फिलर सिलेक्शन, फैमिली जानकारी, और वेल्ड मेटल डेंसिटी बेसिस।',
    calcConsumableClassificationLabel: 'कंज़्यूमेबल क्लासिफिकेशन',
    calcConsumableClassificationHelper:
        'एक AWS फिलर मेटल क्लासिफिकेशन चुनें। डेंसिटी अपने आप भर जाती है और फिर भी एडजस्ट की जा सकती है।',
    calcMyMaterialsHeader: 'मेरी मटीरियल',
    calcAsSavedSuffix: ' (सेव किए अनुसार)',
    drawingLabelFilletWeldFace: 'फिलेट वेल्ड फेस',
    drawingLabelTJoint: 'T-जॉइंट',
    drawingLabelSmawFillCap: 'SMAW फिल / कैप',
    drawingLabelGtawRoot: 'GTAW रूट',
    calcSelectedClassificationNote: 'चयनित क्लासिफिकेशन: {value}',
    calcTypicalBaseMetalsNote: 'टिपिकल बेस मेटल: {value}',
    calcRateBasisTitle: 'रेट बेसिस',
    calcRateBasisSubtitle:
        'चुनें कि डिपॉज़िशन रेट अनुमानित प्रोसेस डिफॉल्ट से आए या मैनुअल प्लानिंग डेटा से।',
    calcPresetRateHelperDefault:
        'अनुमानित मोड प्रोसेस और फिलर डायमीटर से डिपॉज़िशन रेट निकालता है। इसे प्रारंभिक अनुमान के लिए इस्तेमाल करें, क्वालिफिकेशन-लेवल प्लानिंग के लिए नहीं।',
    calcPresetRateHelperGtawSmaw:
        'अनुमानित मोड चुने गए फिलर डायमीटर से GTAW और SMAW डिपॉज़िशन रेट निकालता है, फिर GTAW ट्रांज़िशन डेप्थ का उपयोग करके उन्हें जोड़ता है।',
    calcManualRateHelperDefault:
        'मैनुअल मोड अनुमानित रेट को किसी मापे गए शॉप वैल्यू, प्रोजेक्ट प्लानिंग वैल्यू, या WPS असम्पशन से ओवरराइड करता है।',
    calcManualRateHelperGtawSmaw:
        'मैनुअल मोड आपको अलग GTAW और SMAW डिपॉज़िशन रेट दर्ज करने देता है ताकि आर्क टाइम प्लान की गई रूट, फिल और कैप सीक्वेंस को फॉलो करे।',
    calcInputParametersTitle: 'इनपुट पैरामीटर',
    calcInputParametersSubtitle:
        'डिफॉल्ट असम्पशन: डेंसिटी {density} g/cm3, वेस्ट अलाउंस {waste}%',
    calcDimensionalInputsTitle: 'डाइमेंशनल इनपुट',
    calcDimensionalInputsSubtitle:
        'वेल्ड ज्यामिति, मेंबर साइज़, प्रोसेस डायमीटर, और कैलकुलेशन असम्पशन दर्ज करें।',
    calcRunEstimateTitle: 'एस्टिमेट चलाएं',
    calcRunEstimateSubtitle:
        'लाइव एस्टिमेट रिफ्रेश के लिए गणना करें का उपयोग करें। रीसेट डिफॉल्ट इंजीनियरिंग स्टार्टर वैल्यू को वापस लाता है।',
    calcSaveAsPresetLabel: 'प्रीसेट के रूप में सेव करें',
    calcUpdateSavedCalculationLabel: 'सेव्ड कैलकुलेशन अपडेट करें',
    calcPdfHintBeforeResult:
        'सफल एस्टिमेट के बाद PDF एक्सपोर्ट एक्टिवेट होता है, ताकि रिपोर्ट हमेशा मौजूदा इंजीनियरिंग बेसिस को दर्शाए।',
    calcPdfHintAfterResult:
        'एस्टिमेट सही दिखने पर रिपोर्ट पैनल पॉलिश्ड PDF आउटपुट के लिए तैयार है।',
    calcResultsTitle: 'रिज़ल्ट',
    calcEmptyResultsBodyDefault:
        'जॉइंट चुनें, इनपुट पैरामीटर देखें, फिर गणना करें। {process} प्रोसेस अपनी एक्टिव डिपॉज़िशन एफिशिएंसी और डिपॉज़िशन रेट बेसिस का उपयोग करता है।',
    calcEmptyResultsBodyGtawSmaw:
        'जॉइंट चुनें, फिर गणना करने से पहले GTAW ट्रांज़िशन डेप्थ को GTAW वायर और SMAW इलेक्ट्रोड डायमीटर के साथ दर्ज करें।',
    calcEditInputsTooltip: 'इनपुट एडिट करें',
    calcEditInputsButton: 'इनपुट एडिट करें',
    calcBackToDashboardTooltip: 'डैशबोर्ड पर वापस जाएं',
    techDrawingTitle: 'टेक्निकल ड्रॉइंग',
    techDrawingModeTechnicalDesc:
        'टेक्निकल मोड इंजीनियरिंग-स्टाइल लाइन वेट, हैच, और डाइमेंशन एनोटेशन लागू करता है।',
    techDrawingModeVisualDesc:
        'विज़ुअल मोड लाइव जॉइंट ज्यामिति को फॉलो करते हुए स्केच को नरम रखता है।',
    calcCustomDiameterOption: 'कस्टम डायमीटर',
    calcCustomDiameterLabel: 'कस्टम डायमीटर (mm)',
    calcCustomDiameterHelper: 'एक सटीक डायमीटर वैल्यू दर्ज करें।',
    calcPresetNameDialogSaveTitle: 'प्रीसेट सेव करें',
    calcPresetNameDialogUpdateTitle: 'प्रीसेट अपडेट करें',
    calcPresetNameHelper: 'एक छोटा टेक्निकल रेफरेंस नाम इस्तेमाल करें।',
    calcSaveWithAccountTitle: 'अकाउंट के साथ सेव करें',
    calcSaveWithAccountBody:
        'इस प्रीसेट को सेव करने के लिए अपना ईमेल दर्ज करें। इसे बाद में '
        'वापस पाने के लिए किसी भी डिवाइस पर वही ईमेल इस्तेमाल करें।',
    calcAccountEmailInvalidError: 'एक मान्य ईमेल दर्ज करें।',
    calcCalculationFailedError: 'गणना विफल रही। कृपया इनपुट की समीक्षा करें।',
    calcFieldRequiredError: '{label} एक मान्य संख्या होनी चाहिए।',
    calcErrorLabelQuantity: 'मात्रा',
    calcErrorLabelDensity: 'डेंसिटी',
    calcErrorLabelWasteFactor: 'वेस्ट फैक्टर',
    calcFieldQuantityLabel: 'मात्रा',
    calcFieldQuantityHelper: 'समान वेल्ड की संख्या।',
    calcFieldWeldLengthLabel: 'प्रति पीस वेल्ड लंबाई (mm)',
    calcFieldWeldLengthHelper: 'सीधे वेल्ड रन की लंबाई।',
    calcFieldPipeOdALabel: 'पाइप OD A (mm)',
    calcFieldPipeOdAHelper: 'मेंबर A का बाहरी व्यास।',
    calcFieldPipeOdBLabel: 'पाइप OD B (mm)',
    calcFieldPipeOdBHelper: 'मेंबर B का बाहरी व्यास।',
    calcFieldPipeOdLabel: 'पाइप OD (mm)',
    calcFieldPipeOdHelper:
        'सर्कमफ़्रेंस कैलकुलेशन के लिए इस्तेमाल होने वाला बाहरी व्यास।',
    calcFieldThicknessALabel: 'मोटाई A (mm)',
    calcFieldThicknessAHelper: 'मेंबर A की वॉल या प्लेट मोटाई।',
    calcFieldThicknessBLabel: 'मोटाई B (mm)',
    calcFieldThicknessBHelper: 'मेंबर B की वॉल या प्लेट मोटाई।',
    calcFieldRootGapLabel: 'रूट गैप (mm)',
    calcFieldRootGapHelper: 'रूट ओपनिंग।',
    calcFieldThicknessLabel: 'मोटाई (mm)',
    calcFieldThicknessHelper: 'बेस मटीरियल मोटाई।',
    calcFieldRootFacePerSideLabel: 'प्रति साइड रूट फेस (mm)',
    calcFieldRootFacePerSideHelper: 'जॉइंट सेंटरलाइन के हर तरफ रूट फेस।',
    calcFieldRootFaceLabel: 'रूट फेस (mm)',
    calcFieldRootFaceHelper: 'बेवल शुरू होने से पहले का रूट फेस।',
    calcFieldBevelAngleLabel: 'बेवल एंगल (°)',
    calcFieldBevelAngleHelper: 'डिग्री में बेवल एंगल के रूप में शामिल।',
    calcFieldPrimaryAngleLabel: 'प्राइमरी एंगल alpha (°)',
    calcFieldPrimaryAngleHelper: 'रूट के पास निचला बेवल एंगल।',
    calcFieldSecondaryAngleLabel: 'सेकेंडरी एंगल beta (°)',
    calcFieldSecondaryAngleHelper: 'ब्रेक पॉइंट के ऊपर वाला बेवल एंगल।',
    calcFieldBreakHeightLabel: 'ब्रेक हाइट h (mm)',
    calcFieldBreakHeightHelper: 'रूट फेस से बेवल ब्रेक पॉइंट तक की दूरी।',
    calcFieldLegSizeLabel: 'लेग साइज़ (mm)',
    calcFieldLegSizeHelper: 'फिलेट वेल्ड का समान लेग साइज़।',
    calcFieldGtawWireDiameterLabel: 'GTAW वायर डायमीटर (mm)',
    calcFieldGtawWireDiameterHelper:
        'सामान्य फिलर डायमीटर: 1.6, 2.0, 2.4, 3.2 mm.',
    calcFieldSmawElectrodeDiameterLabel: 'SMAW इलेक्ट्रोड डायमीटर (mm)',
    calcFieldSmawElectrodeDiameterHelper:
        'सामान्य इलेक्ट्रोड डायमीटर: 2.5, 3.2, 4.0, 5.0 mm.',
    calcFieldGmawWireDiameterLabel: 'GMAW वायर डायमीटर (mm)',
    calcFieldGmawWireDiameterHelper:
        'सामान्य वायर डायमीटर: 0.8, 1.0, 1.2, 1.6 mm.',
    calcFieldFcawWireDiameterLabel: 'FCAW वायर डायमीटर (mm)',
    calcFieldFcawWireDiameterHelper: 'सामान्य वायर डायमीटर: 1.2, 1.6, 2.0 mm.',
    calcFieldGtawTransitionLabel: 'GTAW ट्रांज़िशन डेप्थ (mm)',
    calcFieldGtawTransitionHelper:
        'SMAW पर स्विच करने से पहले रूट साइड से GTAW द्वारा डिपॉज़िट की गई डेप्थ।',
    calcFieldGtawDepositionRateLabel: 'GTAW डिपॉज़िशन रेट (kg/h)',
    calcFieldGtawDepositionRateHelper:
        'GTAW रूट पोर्शन के लिए यूज़र-डिफाइंड डिपॉज़िशन रेट।',
    calcFieldSmawDepositionRateLabel: 'SMAW डिपॉज़िशन रेट (kg/h)',
    calcFieldSmawDepositionRateHelper:
        'SMAW फिल और कैप पोर्शन के लिए यूज़र-डिफाइंड डिपॉज़िशन रेट।',
    calcFieldDepositionRateLabel: 'डिपॉज़िशन रेट (kg/h)',
    calcFieldDepositionRateHelper:
        'शॉप डेटा, प्लानिंग वैल्यू, या WPS असम्पशन पर आधारित यूज़र-डिफाइंड डिपॉज़िशन रेट।',
    calcFieldDensityLabel: 'डेंसिटी (g/cm3)',
    calcFieldDensityHelper:
        'बल्क वेल्ड मेटल डेंसिटी। डिफॉल्ट चयनित क्लासिफिकेशन को फॉलो करता है।',
    calcFieldWasteAllowanceLabel: 'वेस्ट अलाउंस (%)',
    calcFieldWasteAllowanceHelper:
        'स्टब लॉस, कट-ऑफ, स्पैटर, और हैंडलिंग के लिए अलाउंस।',
    basisProcess: 'प्रोसेस',
    basisRateBasis: 'रेट बेसिस',
    basisInputPreset: 'इनपुट प्रीसेट',
    basisSavedPreset: 'सेव्ड प्रीसेट',
    basisJoint: 'जॉइंट',
    basisGeometry: 'ज्यामिति',
    basisAlignment: 'अलाइनमेंट',
    basisGroove: 'ग्रूव',
    basisClassification: 'क्लासिफिकेशन',
    basisFillerMetalFamily: 'फिलर मेटल फैमिली',
    basisDensity: 'डेंसिटी',
    basisWasteAllowance: 'वेस्ट अलाउंस',
    basisQuantity: 'मात्रा',
    basisWeldLengthPerPiece: 'प्रति पीस वेल्ड लंबाई',
    basisPipeOd: 'पाइप OD',
    basisThickness: 'मोटाई',
    basisThicknessA: 'मोटाई A',
    basisThicknessB: 'मोटाई B',
    basisControllingThickness: 'कंट्रोलिंग मोटाई',
    basisOdA: 'OD A',
    basisOdB: 'OD B',
    basisReferenceOd: 'रेफरेंस OD',
    basisRootGap: 'रूट गैप',
    basisRootFace: 'रूट फेस',
    basisRootFacePerSide: 'प्रति साइड रूट फेस',
    basisBevelAngle: 'बेवल एंगल',
    basisPrimaryBevelAngle: 'प्राइमरी बेवल एंगल',
    basisSecondaryBevelAngle: 'सेकेंडरी बेवल एंगल',
    basisBreakHeight: 'ब्रेक हाइट',
    basisFilletLegSize: 'फिलेट लेग साइज़',
    basisUserDefinedRate: 'यूज़र-डिफाइंड रेट',
    basisWireDiameter: 'वायर डायमीटर',
    basisElectrodeDiameter: 'इलेक्ट्रोड डायमीटर',
    basisGtawTransitionDepth: 'GTAW ट्रांज़िशन डेप्थ',
    basisGtawDepositionRate: 'GTAW डिपॉज़िशन रेट',
    basisGtawWireDiameter: 'GTAW वायर डायमीटर',
    basisSmawDepositionRate: 'SMAW डिपॉज़िशन रेट',
    basisSmawElectrodeDiameter: 'SMAW इलेक्ट्रोड डायमीटर',
    wizardJointDimensionsTitle: 'जॉइंट और डाइमेंशन',
    wizardConsumableRateTitle: 'कंज़्यूमेबल और रेट',
    wizardProcessStepSubtitle:
        'इस वेल्ड के लिए इस्तेमाल होने वाला प्रोसेस चुनें। यह अगले स्टेप के लिए डिपॉज़िशन डिफॉल्ट और फिलर ऑप्शन तय करता है।',
    wizardReviewCalculateTitle: 'रिव्यू करें और गणना करें',
    wizardReviewCalculateSubtitle:
        'नीचे दिए गए सेटअप की पुष्टि करें, फिर गणना करें। बदलने के लिए किसी भी स्टेप को एडिट करें।',
    wizardRecapProcessTitle: 'प्रोसेस',
    wizardRecapDimensionsTitle: 'डाइमेंशन',
    wizardRecapConsumableTitle: 'कंज़्यूमेबल',
    wizardStepOfLabel: 'स्टेप {current} / {total}',
    resultsSummaryCaption:
        'इंजीनियरिंग रिव्यू, मटीरियल प्लानिंग, और कंज़्यूमेबल तुलना के लिए रिपोर्ट-ग्रेड समरी।',
    resultsDisclaimer:
        'यह एक पहली-पास प्लानिंग एस्टिमेट है — प्रोडक्शन उपयोग से पहले अपने क्वालिफाइड WPS और एक टेस्ट कूपन से इसकी पुष्टि करें।',
    resultsPdfPreparing: 'PDF तैयार हो रहा है...',
    resultsPdfUnlock: 'PDF अनलॉक करें',
    resultsPdfExport: 'PDF एक्सपोर्ट करें',
    resultsEstimateReadyBadge: 'एस्टिमेट तैयार है',
    resultsHighlightSentence:
        'अनुमानित फिलर मेटल कंज़म्पशन {filler} kg है, साथ में {arcTime} h आर्क-ऑन टाइम।',
    resultsHighlightEffectiveRate: 'इफेक्टिव रेट',
    resultsHighlightFillerPerMeter: 'प्रति मीटर फिलर',
    resultsHighlightArcOnPerMeter: 'प्रति मीटर आर्क-ऑन',
    metricWeldArea: 'वेल्ड एरिया',
    metricWeldLength: 'वेल्ड लंबाई',
    metricWeldMetalVolume: 'वेल्ड मेटल वॉल्यूम',
    metricWeldMetalWeight: 'वेल्ड मेटल वेट',
    metricFillerMetalConsumption: 'फिलर मेटल कंज़म्पशन',
    metricEstimatedArcOnTime: 'अनुमानित आर्क-ऑन टाइम',
    metricEffectiveDepositionEfficiency: 'इफेक्टिव डिपॉज़िशन एफिशिएंसी',
    metricEffectiveDepositionRate: 'इफेक्टिव डिपॉज़िशन रेट',
    resultsNextStandardLeg:
        'अगला स्टैंडर्ड लेग साइज़ ({size}mm) लगभग {percent}% ज़्यादा फिलर लेता है।',
    insightWeldMetalPerMeter: 'प्रति मीटर वेल्ड मेटल',
    insightFillerPerJoint: 'प्रति जॉइंट फिलर',
    insightArcOnPerJoint: 'प्रति जॉइंट आर्क-ऑन',
    insightEfficiencyLossBasis: 'एफिशिएंसी लॉस बेसिस',
    insightWasteAllowanceBasis: 'वेस्ट अलाउंस बेसिस',
    insightConsumptionMultiplier: 'कंज़म्पशन मल्टीप्लायर',
    processBreakdownTitle: 'प्रोसेस ब्रेकडाउन',
    processBreakdownSubtitle:
        'डिपॉज़िट किए गए वेल्ड मेटल, फिलर डिमांड, और आर्क-ऑन टाइम का प्रोसेस सेगमेंट के अनुसार वितरण।',
    processBreakdownAreaShare: 'एरिया शेयर {value}%',
    processBreakdownWeldMetal: 'वेल्ड मेटल {value} kg',
    processBreakdownFillerConsumption: 'फिलर कंज़म्पशन {value} kg',
    processBreakdownArcOnTime: 'आर्क-ऑन टाइम {value} h',
    processBreakdownDepositionRate: 'डिपॉज़िशन रेट {value} kg/h',
    processBreakdownDepositionEfficiency: 'डिपॉज़िशन एफिशिएंसी {value}',
    engineeringBasisTitle: 'इंजीनियरिंग बेसिस',
    engineeringBasisSubtitle:
        'ज्यामिति, प्रोसेस सेटअप, डेंसिटी, और डिपॉज़िशन असम्पशन सहित इस एस्टिमेट में इस्तेमाल की गई पूरी इंजीनियरिंग बेसिस।',
    planningIndicatorsTitle: 'प्लानिंग इंडिकेटर',
    planningIndicatorsSubtitle:
        'नॉर्मलाइज़्ड इंडिकेटर जो जॉइंट ऑप्शन, लेबर लोड, और कंज़्यूमेबल प्लानिंग बेसिस की तुलना में मदद करते हैं।',
    engineeringNotesTitle: 'इंजीनियरिंग नोट्स',
    engineeringNote1:
        'आर्क-ऑन टाइम केवल वेल्डिंग टाइम को कवर करता है। फिट-अप, हैंडलिंग, क्लीनिंग, रीपोज़िशनिंग, और इंस्पेक्शन शामिल नहीं हैं।',
    engineeringNote2:
        'फिलर मेटल कंज़म्पशन में डिपॉज़िट किया गया वेल्ड मेटल, प्रोसेस डिपॉज़िशन एफिशिएंसी, और दर्ज किया गया वेस्ट अलाउंस शामिल है।',
    engineeringNote3:
        'कंज़्यूमेबल क्लासिफिकेशन मटीरियल फैमिली और डेंसिटी रेफरेंस देता है। फाइनल प्रोजेक्ट या क्लाइंट रिक्वायरमेंट हमेशा गवर्न करनी चाहिए।',
    engineeringNote4:
        'यह रिपोर्ट एस्टिमेशन और प्लानिंग के लिए उपयुक्त है। यह कोई अप्रूव्ड WPS, PQR, वेल्डर क्वालिफिकेशन, या रिलीज़ डॉक्यूमेंट नहीं है।',
  ),
};

L10nStrings stringsFor(AppLanguage language) => _strings[language]!;

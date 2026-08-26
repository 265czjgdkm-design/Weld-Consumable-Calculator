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
    required this.footerTitle,
    required this.footerBody,
    required this.footerWorkflowLabel,
    required this.footerWorkflowValue,
    required this.footerDrawingLabel,
    required this.footerDrawingValue,
    required this.footerReportsLabel,
    required this.footerReportsValue,
    required this.footerDataLabel,
    required this.footerDataValue,
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
  final String footerTitle;
  final String footerBody;
  final String footerWorkflowLabel;
  final String footerWorkflowValue;
  final String footerDrawingLabel;
  final String footerDrawingValue;
  final String footerReportsLabel;
  final String footerReportsValue;
  final String footerDataLabel;
  final String footerDataValue;
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
    footerTitle: 'Built for real job planning',
    footerBody:
        'Estimate a joint, check the drawing against the print, and hand a client-ready PDF straight from the same session.',
    footerWorkflowLabel: 'Workflow',
    footerWorkflowValue: 'Guided, step by step',
    footerDrawingLabel: 'Drawing',
    footerDrawingValue: 'Live technical view',
    footerReportsLabel: 'Reports',
    footerReportsValue: 'PDF export path',
    footerDataLabel: 'Data',
    footerDataValue: 'Reusable presets',
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
    savedCalculationsRenameError: "Couldn't rename the preset. Please try again.",
    savedCalculationsDeleteConfirmTitle: 'Delete Preset',
    savedCalculationsDeleteConfirmBody:
        'Delete "{name}" from your saved calculations? This cannot be undone.',
    savedCalculationsDeleteError: "Couldn't delete the preset. Please try again.",
    presetProcessSwitchConfirmTitle: 'Switch Welding Process?',
    presetProcessSwitchConfirmBody:
        'This starter preset uses {presetProcess}. Continue and switch the welding process, or keep {currentProcess}?',
    presetProcessSwitchConfirmSwitchButton: 'Switch to {presetProcess}',
    presetProcessSwitchConfirmKeepButton: 'Keep {currentProcess}',
    presetSaveError: "Couldn't save the preset. Please try again.",
    presetSaved: 'Preset saved.',
    presetSavedOffline:
        'Saved on this device only — will sync once you\'re back online.',
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
    footerTitle: 'Gerçek iş planlaması için tasarlandı',
    footerBody:
        'Bir birleşimi hesaplayın, çizimi teknik resimle karşılaştırın ve aynı oturumdan müşteriye hazır bir PDF verin.',
    footerWorkflowLabel: 'Akış',
    footerWorkflowValue: 'Adım adım rehberli',
    footerDrawingLabel: 'Çizim',
    footerDrawingValue: 'Canlı teknik görünüm',
    footerReportsLabel: 'Raporlar',
    footerReportsValue: 'PDF dışa aktarma',
    footerDataLabel: 'Veri',
    footerDataValue: 'Tekrar kullanılabilir şablonlar',
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
    savedCalculationsRenameError: 'Şablon yeniden adlandırılamadı. Lütfen tekrar dene.',
    savedCalculationsDeleteConfirmTitle: 'Şablonu Sil',
    savedCalculationsDeleteConfirmBody:
        '"{name}" kayıtlı hesaplamalarından silinsin mi? Bu işlem geri alınamaz.',
    savedCalculationsDeleteError: 'Şablon silinemedi. Lütfen tekrar dene.',
    presetProcessSwitchConfirmTitle: 'Kaynak Yöntemi Değişsin mi?',
    presetProcessSwitchConfirmBody:
        'Bu başlangıç şablonu {presetProcess} kullanıyor. Devam edip kaynak yöntemini değiştir, yoksa {currentProcess} olarak mı kalsın?',
    presetProcessSwitchConfirmSwitchButton: '{presetProcess} olarak değiştir',
    presetProcessSwitchConfirmKeepButton: '{currentProcess} olarak kalsın',
    presetSaveError: 'Şablon kaydedilemedi. Lütfen tekrar dene.',
    presetSaved: 'Şablon kaydedildi.',
    presetSavedOffline:
        'Sadece bu cihazda kaydedildi — internete bağlanınca eşitlenecek.',
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
    footerTitle: 'Создано для реального планирования работ',
    footerBody:
        'Рассчитайте соединение, сверьте чертёж с чертежом проекта и передайте клиенту готовый PDF в рамках одной сессии.',
    footerWorkflowLabel: 'Процесс',
    footerWorkflowValue: 'Пошаговое руководство',
    footerDrawingLabel: 'Чертёж',
    footerDrawingValue: 'Живой технический вид',
    footerReportsLabel: 'Отчёты',
    footerReportsValue: 'Экспорт в PDF',
    footerDataLabel: 'Данные',
    footerDataValue: 'Повторно используемые шаблоны',
    languagePickerTitle: 'Язык',
    emailGateHint: 'you@example.com',
    emailGateInvalidEmail: 'Введите корректный адрес электронной почты',
    emailGateError:
        'Не удалось сохранить сейчас — вы можете продолжить как гость.',
    emailGateWelcomeToast: 'Готово — проверьте почту, там приветственное письмо.',
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
    savedReportsShareError: 'Не удалось поделиться отчётом. Попробуйте ещё раз.',
    savedCalculationsTitle: 'Сохранённые расчёты',
    savedCalculationsEmptyState:
        'Пока нет сохранённых расчётов. Сохраните один на шаге сводки в калькуляторе, чтобы увидеть его здесь.',
    savedCalculationsGuestState:
        'Войдите, сохранив расчёт в калькуляторе, чтобы начать формировать список здесь.',
    savedCalculationsLoadButton: 'Загрузить',
    savedCalculationsRenameTitle: 'Переименовать шаблон',
    savedCalculationsRenameFieldLabel: 'Название шаблона',
    savedCalculationsRenameError: 'Не удалось переименовать шаблон. Попробуйте ещё раз.',
    savedCalculationsDeleteConfirmTitle: 'Удалить шаблон',
    savedCalculationsDeleteConfirmBody:
        'Удалить «{name}» из сохранённых расчётов? Это действие необратимо.',
    savedCalculationsDeleteError: 'Не удалось удалить шаблон. Попробуйте ещё раз.',
    presetProcessSwitchConfirmTitle: 'Сменить способ сварки?',
    presetProcessSwitchConfirmBody:
        'В этом стартовом шаблоне используется {presetProcess}. Продолжить и сменить способ сварки или оставить {currentProcess}?',
    presetProcessSwitchConfirmSwitchButton: 'Сменить на {presetProcess}',
    presetProcessSwitchConfirmKeepButton: 'Оставить {currentProcess}',
    presetSaveError: 'Не удалось сохранить шаблон. Попробуйте ещё раз.',
    presetSaved: 'Шаблон сохранён.',
    presetSavedOffline:
        'Сохранено только на этом устройстве — синхронизируется, когда появится подключение к интернету.',
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
    footerTitle: 'Für reale Arbeitsplanung entwickelt',
    footerBody:
        'Berechnen Sie eine Verbindung, prüfen Sie die Zeichnung gegen den Plan und übergeben Sie ein kundenfertiges PDF aus derselben Sitzung.',
    footerWorkflowLabel: 'Ablauf',
    footerWorkflowValue: 'Schritt für Schritt geführt',
    footerDrawingLabel: 'Zeichnung',
    footerDrawingValue: 'Live-Technikansicht',
    footerReportsLabel: 'Berichte',
    footerReportsValue: 'PDF-Export',
    footerDataLabel: 'Daten',
    footerDataValue: 'Wiederverwendbare Vorlagen',
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
    savedReportsShareError: 'Bericht konnte nicht geteilt werden. Bitte versuchen Sie es erneut.',
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
        'Diese Startvorlage verwendet {presetProcess}. Fortfahren und das Schweißverfahren wechseln oder {currentProcess} beibehalten?',
    presetProcessSwitchConfirmSwitchButton: 'Zu {presetProcess} wechseln',
    presetProcessSwitchConfirmKeepButton: '{currentProcess} beibehalten',
    presetSaveError:
        'Vorlage konnte nicht gespeichert werden. Bitte versuchen Sie es erneut.',
    presetSaved: 'Vorlage gespeichert.',
    presetSavedOffline:
        'Nur auf diesem Gerät gespeichert — wird synchronisiert, sobald Sie wieder online sind.',
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
    footerTitle: 'वास्तविक जॉब प्लानिंग के लिए बनाया गया',
    footerBody:
        'एक जॉइंट का एस्टिमेट लगाएं, ड्रॉइंग को प्रिंट से मिलाएं, और उसी सेशन से क्लाइंट-रेडी PDF सौंपें।',
    footerWorkflowLabel: 'वर्कफ़्लो',
    footerWorkflowValue: 'स्टेप-बाय-स्टेप गाइडेड',
    footerDrawingLabel: 'ड्रॉइंग',
    footerDrawingValue: 'लाइव टेक्निकल व्यू',
    footerReportsLabel: 'रिपोर्ट्स',
    footerReportsValue: 'PDF एक्सपोर्ट',
    footerDataLabel: 'डेटा',
    footerDataValue: 'पुन: उपयोग योग्य प्रीसेट',
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
    savedReportsShareError: 'रिपोर्ट शेयर नहीं हो सकी। कृपया फिर से कोशिश करें।',
    savedCalculationsTitle: 'सेव्ड कैलकुलेशन्स',
    savedCalculationsEmptyState:
        'अभी तक कोई सेव्ड कैलकुलेशन नहीं है। इसे यहां देखने के लिए कैलकुलेटर के समरी स्टेप से एक सेव करें।',
    savedCalculationsGuestState:
        'यहां अपनी लिस्ट बनाना शुरू करने के लिए कैलकुलेटर से एक कैलकुलेशन सेव करके लॉग इन करें।',
    savedCalculationsLoadButton: 'लोड करें',
    savedCalculationsRenameTitle: 'प्रीसेट का नाम बदलें',
    savedCalculationsRenameFieldLabel: 'प्रीसेट का नाम',
    savedCalculationsRenameError: 'प्रीसेट का नाम नहीं बदला जा सका। कृपया फिर से कोशिश करें।',
    savedCalculationsDeleteConfirmTitle: 'प्रीसेट डिलीट करें',
    savedCalculationsDeleteConfirmBody:
        'क्या सेव्ड कैलकुलेशन्स से "{name}" डिलीट करें? यह वापस नहीं लिया जा सकता।',
    savedCalculationsDeleteError: 'प्रीसेट डिलीट नहीं हो सका। कृपया फिर से कोशिश करें।',
    presetProcessSwitchConfirmTitle: 'वेल्डिंग प्रोसेस बदलें?',
    presetProcessSwitchConfirmBody:
        'यह स्टार्टर प्रीसेट {presetProcess} इस्तेमाल करता है। आगे बढ़कर वेल्डिंग प्रोसेस बदलें, या {currentProcess} बनाए रखें?',
    presetProcessSwitchConfirmSwitchButton: '{presetProcess} में बदलें',
    presetProcessSwitchConfirmKeepButton: '{currentProcess} बनाए रखें',
    presetSaveError: 'प्रीसेट सेव नहीं हो सका। कृपया फिर से कोशिश करें।',
    presetSaved: 'प्रीसेट सेव हो गया।',
    presetSavedOffline:
        'सिर्फ इस डिवाइस पर सेव हुआ — इंटरनेट से जुड़ते ही सिंक हो जाएगा।',
  ),
};

L10nStrings stringsFor(AppLanguage language) => _strings[language]!;

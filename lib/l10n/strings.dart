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
  ),
};

L10nStrings stringsFor(AppLanguage language) => _strings[language]!;

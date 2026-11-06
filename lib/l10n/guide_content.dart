import 'app_language.dart';

/// Offline copy for the in-app user guide, one entry per section id in
/// [guideSectionIds] for every [AppLanguage]. Numbers and formulas mirror
/// lib/core/weld_formulas.dart, welding_defaults.dart and en1011_formulas.dart;
/// change them together.
const guideSectionIds = [
  'start',
  'filler',
  'preheat',
  'cooling',
  'heatinput',
  'library',
  'presets',
  'pdf',
  'ai',
  'premium',
  'account',
  'faq',
];

class GuideEntry {
  const GuideEntry(this.title, this.body);

  final String title;

  /// Paragraphs separated by a blank line; lines starting with "• " are
  /// bullets.
  final String body;
}

class GuideCopy {
  const GuideCopy({
    required this.screenTitle,
    required this.searchHint,
    required this.noResults,
    required this.sections,
  });

  final String screenTitle;
  final String searchHint;
  final String noResults;
  final Map<String, GuideEntry> sections;
}

GuideCopy guideCopyFor(AppLanguage language) => switch (language) {
  AppLanguage.tr => _tr,
  AppLanguage.en => _en,
  AppLanguage.ru => _ru,
  AppLanguage.de => _de,
  AppLanguage.hi => _hi,
};

const _en = GuideCopy(
  screenTitle: 'User guide',
  searchHint: 'Search the guide',
  noResults: 'Nothing found.',
  sections: {
    'start': GuideEntry(
      'Getting started',
      'Home lists the calculators (filler consumption, preheat temperature, cooling time t8/5), the Base and Filler material libraries, and your saved calculations and reports. All calculators work offline and are free.\n\n'
          '• Guest: no sign-in needed. Everything is stored on this device only.\n'
          '• Account: sign in with just an email (no password). Your saved calculations then sync to any device where you sign in with the same email.\n'
          '• Language: use the language button at the top right of the header (Turkish, English, Russian, German, Hindi).\n\n'
          'Premium (PDF export and AI assistant) is optional and can be bought without an account.',
    ),
    'filler': GuideEntry(
      'Filler material consumption',
      'Estimates how much filler metal (kg) and arc time (h) a weld needs, from the joint geometry.\n\n'
          'Inputs\n'
          '• Joint type and groove: pipe butt, plate butt or fillet; single V, half V, double V, compound V or square.\n'
          '• Quantity: number of identical welds.\n'
          '• Weld length (mm, per piece) for plates, or Pipe OD (mm) for pipes: the length is π × OD × quantity.\n'
          '• Thickness, Root gap, Root face (mm); Bevel angle (deg) is per side. Compound V also needs primary angle α, secondary angle β and break height h.\n'
          '• Cap overlap and cap height (mm, optional): the cap adds (groove top width + 2 × overlap) × height to the area.\n'
          '• Fillet: leg size (mm); area = leg² / 2.\n'
          '• Process: GTAW, SMAW, GTAW root + SMAW fill, GMAW, FCAW, then consumable and wire/electrode diameter.\n'
          '• Deposition rate (kg/h): preset by process and diameter, or your own value.\n'
          '• Density (g/cm³, default 7.85 for carbon steel; follows the chosen classification) and Waste allowance (%, default 10).\n\n'
          'How it is calculated\n'
          '• Volume (cm³) = area (mm²) × length (mm) / 1000\n'
          '• Weld metal (kg) = volume × density / 1000\n'
          '• Filler (kg) = weld metal / deposition efficiency × (1 + waste / 100)\n'
          '• Arc time (h) = filler / deposition rate\n'
          'Deposition efficiency: GTAW 0.95, SMAW 0.65, GMAW 0.90, FCAW 0.85. For GTAW root + SMAW fill each part uses its own value. Preset deposition rates run from 0.5 to 1.3 kg/h (GTAW), 0.8 to 2.8 (SMAW), 2.2 to 4.8 (GMAW) and 3.4 to 5.4 (FCAW), depending on diameter.\n\n'
          'Pitfalls\n'
          '• This is a theoretical estimate from the drawn geometry; real shop use depends on fit-up, technique and position.\n'
          '• Bevel angle is per side, not the included angle.\n'
          '• Weld length is per piece; set Quantity for the number of pieces.\n'
          '• For double V the thickness is split in half and the cap values apply to both faces.\n'
          '• Deposition efficiency here (metal transfer) is not the arc thermal efficiency used for heat input.',
    ),
    'preheat': GuideEntry(
      'Preheat temperature (EN 1011-2)',
      'Computes the recommended minimum preheat temperature for non-alloy and fine-grain steels with EN 1011-2 Annex C.3, Method B (CET based).\n\n'
          'Inputs\n'
          '• Composition of the parent metal in % by weight: C, Si, Mn, Cr, Mo, Ni, Cu, V, B. Blank counts as 0. You can load it from a saved Base Material.\n'
          '• Weld metal CET % (optional), used for the special rule below.\n'
          '• Plate thickness d (mm): use the thicker plate for dissimilar thicknesses.\n'
          '• Diffusible hydrogen HD (ml/100 g deposited metal, ISO 3690).\n'
          '• Net heat input Q (kJ/mm), entered directly or computed from arc parameters (see Heat input).\n'
          '• Steel yield strength (N/mm², optional): only used for the range check.\n\n'
          'How it is calculated\n'
          '• CET = C + (Mn + Mo)/10 + (Cr + Cu)/20 + Ni/40\n'
          '• Tp = 697·CET + 160·tanh(d/35) + 62·HD^0.35 + (53·CET − 32)·Q − 328 (°C)\n'
          '• Special rule: if the parent CET exceeds the weld metal CET by less than 0.03, the design CET becomes weld metal CET + 0.03.\n\n'
          'Reading the result\n'
          '• A value at or below 20 °C is shown as "No preheat required".\n'
          '• Warnings (the result is still shown) appear outside the validated ranges: CET 0.2–0.5 %, thickness 10–90 mm, HD 1–20 ml/100 g, Q 0.5–4.0 kJ/mm, yield strength up to 1000 N/mm².\n'
          '• The method is validated for steel groups 1–4 of ISO/TR 15608. CEV (IIW) and Pcm are shown for reference only; they are not part of EN 1011-2.\n'
          '• "Use in Cooling Time" passes the preheat to the t8/5 calculator.\n\n'
          'Pitfalls: HD and heat input swing the result a lot, so use real values from your consumable data sheet and WPS. Treat the result as a guide and confirm with your WPS and procedure qualification.',
    ),
    'cooling': GuideEntry(
      'Cooling time t8/5 (EN 1011-2)',
      'Computes the time the weld and heat-affected zone take to cool from 800 °C to 500 °C (EN 1011-2 Annex D.6). Shorter times mean harder microstructure; longer times mean lower toughness in some steels.\n\n'
          'Inputs\n'
          '• Preheat or interpass temperature T0 (°C): must be below 500 °C (and at least −50 °C).\n'
          '• Net heat input Q (kJ/mm).\n'
          '• Joint type: run-on-plate (shape factor 1.0) or butt weld between runs (0.9). Fillet joints are not supported.\n'
          '• Plate thickness d (mm).\n\n'
          'How it is calculated\n'
          '• 3D (thick plate): t8/5 = (6700 − 5·T0) · Q · [1/(500 − T0) − 1/(800 − T0)] · F3\n'
          '• 2D (thin plate): t8/5 = (4300 − 4.3·T0) · 10⁵ · (Q²/d²) · [1/(500 − T0)² − 1/(800 − T0)²] · F2\n'
          '• The app finds the transition thickness dt for your T0 and Q: thinner than dt uses 2D, otherwise 3D. The result card names the regime used.\n\n'
          'Pitfalls: use the same T0 you really weld at; a warning appears for Q outside 0.5–4.0 kJ/mm or thickness outside 3–150 mm.',
    ),
    'heatinput': GuideEntry(
      'Heat input (Q)',
      'Both EN 1011-2 calculators need the net heat input Q in kJ/mm. Choose "Enter directly" if you know it, or "Calculate from arc parameters".\n\n'
          '• Q = k × U × I × 60 / (travel speed × 1000)\n'
          '• U in volts, I in amperes, travel speed in mm/min.\n'
          '• Arc thermal efficiency k (EN 1011-1): SMAW 0.8, GMAW/MAG 0.8, SAW 1.0.\n\n'
          'Pitfalls: travel speed is mm per minute, not mm per second. For multi-pass welds use the speed of the pass you are assessing. GTAW/TIG (k = 0.6, EN 1011-1) is not a process option here: choose "Enter directly" and compute Q with k = 0.6.',
    ),
    'library': GuideEntry(
      'Material library',
      'Library holds your own Base Materials (name, designation, composition, thickness, CET and Pcm) and Filler Materials (family, density, AWS specification, composition).\n\n'
          '• Saved base materials can be loaded into the preheat calculator, so composition is typed once.\n'
          '• Saved filler materials appear as consumable choices in the filler consumption calculator, with their density.\n'
          '• Library entries are stored on this device.',
    ),
    'presets': GuideEntry(
      'Presets and saved calculations',
      'The filler calculator offers starter templates (for example carbon steel pipe single V, GTAW root + SMAW fill) and lets you save your own inputs as a preset.\n\n'
          '• Saved Calculations lists your presets: reopen, rename or delete them.\n'
          '• Saved calculations belong to an account: as a guest the list stays empty and saving asks for your email. Once you sign in, presets sync by email and appear on every device where you sign in with it.\n'
          '• Saved Reports lists the PDF reports you exported.',
    ),
    'pdf': GuideEntry(
      'PDF report',
      'After calculating, Premium users can export a client-ready PDF with the inputs, the results and the engineering basis (formulas and values used). Exported reports are kept in Saved Reports. Without Premium the Export button opens the Premium screen instead.',
    ),
    'ai': GuideEntry(
      'AI assistant',
      'A chat assistant for welding questions and for understanding your results. It is a Premium feature.\n\n'
          '• Consent: before the first chat you are asked to confirm that your messages are sent to a third-party AI service to produce an answer. You can withdraw consent any time in Account.\n'
          '• It needs an internet connection and there is a message length and rate limit.\n'
          '• It can explain terms, standards and your numbers. It cannot replace a qualified welding engineer, your WPS or the applicable code, and it can be wrong: verify anything safety-critical.\n'
          '• Do not type personal or confidential information.',
    ),
    'premium': GuideEntry(
      'Premium',
      'Premium unlocks PDF export and the AI assistant. Calculators, libraries and saved calculations stay free.\n\n'
          '• Plans: monthly or yearly. The exact price is shown by the App Store on the Premium screen.\n'
          '• Premium belongs to your Apple ID, not to the app account. On another device with the same Apple ID, install the app and tap Restore Purchases (Account screen).\n'
          '• Manage or cancel in your Apple ID subscription settings (Account has a shortcut). Deleting the app account does not cancel the subscription.\n'
          '• The Account screen has a Premium status card: plan, active or expired, and renewal or end date.\n'
          '• You can optionally link Premium to your email by signing in.',
    ),
    'account': GuideEntry(
      'Account and data deletion',
      'There are no passwords: your email identifies your account. Signing out removes the account from this device; your saved calculations are hidden until you sign in again with the same email.\n\n'
          'Delete account (Account screen) permanently removes your email and saved calculations from this device and from our servers. It cannot be undone and does not cancel an Apple subscription.\n\n'
          'When you sign in, an anonymous identifier derived from your email (a one-way hash, not the email) is used so your Premium purchase can follow your account.',
    ),
    'faq': GuideEntry(
      'FAQ',
      '• Do I need an account? No. Guests can use every calculator and buy Premium.\n'
          '• Do the calculators work offline? Yes. The AI assistant, sync, purchases and Restore need internet.\n'
          '• My Premium is missing on a new phone. Use the same Apple ID and tap Restore Purchases in Account.\n'
          '• Why does the filler result differ from my shop data? The tool is a theoretical estimate; adjust the waste allowance and deposition rate to your real practice.\n'
          '• Why "No preheat required"? The computed Tp is at or below 20 °C. The calculated value is shown under the result.\n'
          '• How do I change language? Use the language button in the header.',
    ),
  },
);

const _tr = GuideCopy(
  screenTitle: 'Kullanım Kılavuzu',
  searchHint: 'Kılavuzda ara',
  noResults: 'Sonuç bulunamadı.',
  sections: {
    'start': GuideEntry(
      'Başlarken',
      'Ana ekranda hesaplayıcılar (ilave metal sarfiyatı, ön ısıtma sıcaklığı, soğuma süresi t8/5), Ana Malzeme ve İlave Malzeme kütüphaneleri ile kayıtlı hesaplamalarınız ve raporlarınız bulunur. Tüm hesaplayıcılar çevrimdışı çalışır ve ücretsizdir.\n\n'
          '• Misafir: giriş gerekmez. Her şey yalnızca bu cihazda saklanır.\n'
          '• Hesap: yalnızca e-posta ile giriş (şifre yok). Kayıtlı hesaplamalarınız aynı e-postayla giriş yaptığınız her cihaza eşitlenir.\n'
          '• Dil: başlığın sağ üstündeki dil düğmesi (Türkçe, İngilizce, Rusça, Almanca, Hintçe).\n\n'
          'Premium (PDF dışa aktarma ve yapay zekâ asistanı) isteğe bağlıdır ve hesap olmadan satın alınabilir.',
    ),
    'filler': GuideEntry(
      'İlave metal sarfiyatı',
      'Birleşim geometrisinden, bir kaynak için gereken ilave metal miktarını (kg) ve ark süresini (saat) tahmin eder.\n\n'
          'Girdiler\n'
          '• Birleşim ve kaynak ağzı: boru alın, sac alın veya köşe; tek V, yarım V, çift V, bileşik V veya kare.\n'
          '• Adet: aynı kaynaktan kaç tane.\n'
          '• Sac için Kaynak uzunluğu (mm, parça başına), boru için Boru dış çapı (mm): uzunluk = π × OD × adet.\n'
          '• Kalınlık, Kök aralığı, Kök yüzü (mm); Pah açısı (derece) her bir taraf içindir. Bileşik V için ayrıca birincil açı α, ikincil açı β ve kırılma yüksekliği h gerekir.\n'
          '• Kapak taşması ve kapak yüksekliği (mm, isteğe bağlı): kapak alana (ağız üst genişliği + 2 × taşma) × yükseklik ekler.\n'
          '• Köşe kaynağı: kenar boyu (mm); alan = kenar² / 2.\n'
          '• Proses: GTAW, SMAW, GTAW kök + SMAW dolgu, GMAW, FCAW; ardından ilave malzeme ve tel/elektrot çapı.\n'
          '• Yığma hızı (kg/sa): proses ve çapa göre hazır değer veya kendi değeriniz.\n'
          '• Yoğunluk (g/cm³, karbon çeliği için varsayılan 7,85; seçilen sınıfa göre değişir) ve Fire payı (%, varsayılan 10).\n\n'
          'Nasıl hesaplanır\n'
          '• Hacim (cm³) = alan (mm²) × uzunluk (mm) / 1000\n'
          '• Kaynak metali (kg) = hacim × yoğunluk / 1000\n'
          '• İlave metal (kg) = kaynak metali / yığma verimi × (1 + fire / 100)\n'
          '• Ark süresi (sa) = ilave metal / yığma hızı\n'
          'Yığma verimi: GTAW 0,95, SMAW 0,65, GMAW 0,90, FCAW 0,85. GTAW kök + SMAW dolguda her bölüm kendi değerini kullanır. Hazır yığma hızları çapa göre GTAW 0,5–1,3 kg/sa, SMAW 0,8–2,8, GMAW 2,2–4,8 ve FCAW 3,4–5,4 arasındadır.\n\n'
          'Dikkat edilecekler\n'
          '• Bu, çizilen geometriden teorik bir tahmindir; gerçek tüketim montaj, teknik ve pozisyona bağlıdır.\n'
          '• Pah açısı her bir taraf içindir, toplam açı değildir.\n'
          '• Kaynak uzunluğu parça başınadır; parça sayısını Adet ile girin.\n'
          '• Çift V\'de kalınlık ikiye bölünür, kapak değerleri iki yüze de uygulanır.\n'
          '• Buradaki yığma verimi (metal transferi), ısı girdisindeki ark ısıl verimi ile aynı şey değildir.',
    ),
    'preheat': GuideEntry(
      'Ön ısıtma sıcaklığı (EN 1011-2)',
      'Alaşımsız ve ince taneli çelikler için EN 1011-2 Ek C.3, Yöntem B (CET tabanlı) ile önerilen asgari ön ısıtma sıcaklığını hesaplar.\n\n'
          'Girdiler\n'
          '• Ana metal bileşimi, ağırlıkça %: C, Si, Mn, Cr, Mo, Ni, Cu, V, B. Boş bırakılan 0 sayılır. Kayıtlı bir Ana Malzemeden yükleyebilirsiniz.\n'
          '• Kaynak metali CET % (isteğe bağlı), aşağıdaki özel kural için.\n'
          '• Levha kalınlığı d (mm): farklı kalınlıklarda kalın olanı girin.\n'
          '• Difüze hidrojen HD (ml/100 g kaynak metali, ISO 3690).\n'
          '• Net ısı girdisi Q (kJ/mm): doğrudan girilir veya ark parametrelerinden hesaplanır (bkz. Isı girdisi).\n'
          '• Çelik akma dayanımı (N/mm², isteğe bağlı): yalnızca aralık kontrolünde kullanılır.\n\n'
          'Nasıl hesaplanır\n'
          '• CET = C + (Mn + Mo)/10 + (Cr + Cu)/20 + Ni/40\n'
          '• Tp = 697·CET + 160·tanh(d/35) + 62·HD^0,35 + (53·CET − 32)·Q − 328 (°C)\n'
          '• Özel kural: ana metal CET\'i kaynak metali CET\'ini 0,03\'ten az aşıyorsa tasarım CET\'i = kaynak metali CET + 0,03.\n\n'
          'Sonucu okuma\n'
          '• 20 °C ve altındaki değer "Ön ısıtma gerekmez" olarak gösterilir.\n'
          '• Doğrulanmış aralıkların dışında uyarı çıkar (sonuç yine gösterilir): CET %0,2–0,5, kalınlık 10–90 mm, HD 1–20 ml/100 g, Q 0,5–4,0 kJ/mm, akma dayanımı en çok 1000 N/mm².\n'
          '• Yöntem ISO/TR 15608 çelik grupları 1–4 için geçerlidir. CEV (IIW) ve Pcm yalnızca bilgi içindir; EN 1011-2\'nin parçası değildir.\n'
          '• "Soğuma süresinde kullan" ön ısıtmayı t8/5 hesaplayıcısına aktarır.\n\n'
          'Dikkat: HD ve ısı girdisi sonucu çok etkiler; ilave malzeme veri sayfanızdan ve WPS\'ten gerçek değerleri kullanın. Sonucu yol gösterici kabul edin, WPS ve prosedür kalifikasyonunuzla doğrulayın.',
    ),
    'cooling': GuideEntry(
      'Soğuma süresi t8/5 (EN 1011-2)',
      'Kaynak ve ısıdan etkilenen bölgenin 800 °C\'den 500 °C\'ye soğuma süresini hesaplar (EN 1011-2 Ek D.6). Kısa süre daha sert mikroyapı, uzun süre bazı çeliklerde düşük tokluk demektir.\n\n'
          'Girdiler\n'
          '• Ön ısıtma veya pasolar arası sıcaklık T0 (°C): 500 °C\'nin altında (en az −50 °C) olmalı.\n'
          '• Net ısı girdisi Q (kJ/mm).\n'
          '• Birleşim tipi: levha üstüne paso (şekil faktörü 1,0) veya pasolar arası alın kaynağı (0,9). Köşe birleşimler desteklenmez.\n'
          '• Levha kalınlığı d (mm).\n\n'
          'Nasıl hesaplanır\n'
          '• 3B (kalın levha): t8/5 = (6700 − 5·T0) · Q · [1/(500 − T0) − 1/(800 − T0)] · F3\n'
          '• 2B (ince levha): t8/5 = (4300 − 4,3·T0) · 10⁵ · (Q²/d²) · [1/(500 − T0)² − 1/(800 − T0)²] · F2\n'
          '• Uygulama T0 ve Q için geçiş kalınlığı dt\'yi bulur: dt\'den ince ise 2B, değilse 3B. Sonuç kartı kullanılan rejimi belirtir.\n\n'
          'Dikkat: gerçekte kaynak yaptığınız T0\'ı girin; Q 0,5–4,0 kJ/mm veya kalınlık 3–150 mm dışındaysa uyarı çıkar.',
    ),
    'heatinput': GuideEntry(
      'Isı girdisi (Q)',
      'EN 1011-2 hesaplayıcılarının ikisi de kJ/mm cinsinden net ısı girdisi Q ister. Biliyorsanız "Doğrudan gir", bilmiyorsanız "Ark parametrelerinden hesapla" seçin.\n\n'
          '• Q = k × U × I × 60 / (ilerleme hızı × 1000)\n'
          '• U volt, I amper, ilerleme hızı mm/dak.\n'
          '• Ark ısıl verimi k (EN 1011-1): SMAW 0,8, GMAW/MAG 0,8, SAW 1,0.\n\n'
          'Dikkat: ilerleme hızı mm/saniye değil mm/dakikadır. Çok pasolu kaynakta değerlendirdiğiniz pasonun hızını kullanın. GTAW/TIG (k = 0,6, EN 1011-1) işlem seçeneklerinde yoktur: "Doğrudan gir" seçip Q\'yu k = 0,6 ile kendiniz hesaplayın.',
    ),
    'library': GuideEntry(
      'Malzeme kütüphanesi',
      'Kütüphane kendi Ana Malzemelerinizi (ad, tanım, bileşim, kalınlık, CET ve Pcm) ve İlave Malzemelerinizi (aile, yoğunluk, AWS şartnamesi, bileşim) tutar.\n\n'
          '• Kayıtlı ana malzemeleri ön ısıtma hesaplayıcısına yükleyebilirsiniz; bileşimi bir kez yazarsınız.\n'
          '• Kayıtlı ilave malzemeler, yoğunluklarıyla birlikte ilave metal sarfiyatı hesaplayıcısında seçenek olarak görünür.\n'
          '• Kütüphane kayıtları bu cihazda saklanır.',
    ),
    'presets': GuideEntry(
      'Hazır ayarlar ve kayıtlı hesaplamalar',
      'İlave metal hesaplayıcısı başlangıç şablonları sunar (örneğin karbon çeliği boru tek V, GTAW kök + SMAW dolgu) ve girdilerinizi hazır ayar olarak kaydetmenizi sağlar.\n\n'
          '• Kayıtlı Hesaplamalar hazır ayarlarınızı listeler: açın, yeniden adlandırın veya silin.\n'
          '• Kayıtlı hesaplamalar bir hesaba aittir: misafirken liste boştur ve kaydetmek e-posta ister. Giriş yaptığınızda hazır ayarlar e-posta üzerinden eşitlenir ve aynı e-postayla giriş yaptığınız her cihazda görünür.\n'
          '• Kayıtlı Raporlar dışa aktardığınız PDF raporları listeler.',
    ),
    'pdf': GuideEntry(
      'PDF rapor',
      'Hesaplamadan sonra Premium kullanıcılar girdileri, sonuçları ve mühendislik dayanağını (kullanılan formüller ve değerler) içeren müşteriye hazır bir PDF dışa aktarabilir. Dışa aktarılan raporlar Kayıtlı Raporlar\'da saklanır. Premium yoksa dışa aktar düğmesi Premium ekranını açar.',
    ),
    'ai': GuideEntry(
      'Yapay zekâ asistanı',
      'Kaynak soruları ve sonuçlarınızı anlamak için bir sohbet asistanıdır. Premium özelliğidir.\n\n'
          '• Onay: ilk sohbetten önce mesajlarınızın cevap üretmek için üçüncü taraf bir yapay zekâ hizmetine gönderildiğini onaylamanız istenir. Onayı istediğiniz zaman Hesap ekranından geri çekebilirsiniz.\n'
          '• İnternet gerekir; mesaj uzunluğu ve hız sınırı vardır.\n'
          '• Terimleri, standartları ve sayılarınızı açıklayabilir. Yetkin bir kaynak mühendisinin, WPS\'in veya ilgili standardın yerini tutmaz ve yanılabilir: güvenliği ilgilendiren her şeyi doğrulayın.\n'
          '• Kişisel veya gizli bilgi yazmayın.',
    ),
    'premium': GuideEntry(
      'Premium',
      'Premium, PDF dışa aktarmayı ve yapay zekâ asistanını açar. Hesaplayıcılar, kütüphaneler ve kayıtlı hesaplamalar ücretsiz kalır.\n\n'
          '• Planlar: aylık veya yıllık. Kesin fiyatı App Store Premium ekranında gösterir.\n'
          '• Premium uygulama hesabınıza değil Apple Kimliğinize aittir. Aynı Apple Kimliğiyle başka bir cihazda uygulamayı yükleyip Hesap ekranında Satın Alımları Geri Yükle\'ye dokunun.\n'
          '• Apple Kimliği abonelik ayarlarından yönetin veya iptal edin (Hesap ekranında kısayol var). Uygulama hesabını silmek aboneliği iptal etmez.\n'
          '• Hesap ekranındaki Premium durumu kartı planı, aktif/süresi doldu bilgisini ve yenileme veya bitiş tarihini gösterir.\n'
          '• İsterseniz giriş yaparak Premium\'unuzu e-postanıza bağlayabilirsiniz.',
    ),
    'account': GuideEntry(
      'Hesap ve veri silme',
      'Şifre yoktur: hesabınızı e-postanız tanımlar. Çıkış yapmak hesabı bu cihazdan kaldırır; kayıtlı hesaplamalarınız aynı e-postayla tekrar giriş yapana kadar görünmez.\n\n'
          'Hesabı sil (Hesap ekranı) e-postanızı ve kayıtlı hesaplamalarınızı bu cihazdan ve sunucularımızdan kalıcı olarak siler. Geri alınamaz ve Apple aboneliğini iptal etmez.\n\n'
          'Giriş yaptığınızda, Premium satın alımınızın hesabınızı takip edebilmesi için e-postanızdan türetilmiş anonim bir tanımlayıcı (tek yönlü özet; e-postanın kendisi değil) kullanılır.',
    ),
    'faq': GuideEntry(
      'SSS',
      '• Hesap gerekli mi? Hayır. Misafirler tüm hesaplayıcıları kullanabilir ve Premium satın alabilir.\n'
          '• Hesaplayıcılar çevrimdışı çalışır mı? Evet. Yapay zekâ asistanı, eşitleme, satın alma ve geri yükleme internet ister.\n'
          '• Yeni telefonda Premium\'um yok. Aynı Apple Kimliğini kullanın ve Hesap\'ta Satın Alımları Geri Yükle\'ye dokunun.\n'
          '• İlave metal sonucu atölye verilerimden neden farklı? Araç teorik bir tahmindir; fire payını ve yığma hızını kendi uygulamanıza göre ayarlayın.\n'
          '• Neden "Ön ısıtma gerekmez"? Hesaplanan Tp 20 °C veya altındadır. Hesaplanan değer sonucun altında gösterilir.\n'
          '• Dili nasıl değiştiririm? Başlıktaki dil düğmesini kullanın.',
    ),
  },
);

const _ru = GuideCopy(
  screenTitle: 'Руководство',
  searchHint: 'Поиск по руководству',
  noResults: 'Ничего не найдено.',
  sections: {
    'start': GuideEntry(
      'Начало работы',
      'На главном экране: калькуляторы (расход присадки, температура предварительного подогрева, время охлаждения t8/5), библиотеки основных и присадочных материалов, сохранённые расчёты и отчёты. Все калькуляторы работают офлайн и бесплатны.\n\n'
          '• Гость: вход не нужен. Все данные хранятся только на этом устройстве.\n'
          '• Аккаунт: вход только по e-mail (без пароля). Сохранённые расчёты синхронизируются на любом устройстве с тем же e-mail.\n'
          '• Язык: кнопка языка вверху справа (турецкий, английский, русский, немецкий, хинди).\n\n'
          'Premium (экспорт PDF и ИИ-ассистент) необязателен и покупается без аккаунта.',
    ),
    'filler': GuideEntry(
      'Расход присадочного металла',
      'Оценивает массу присадки (кг) и время горения дуги (ч) для сварного шва по геометрии соединения.\n\n'
          'Входные данные\n'
          '• Тип соединения и разделки: стык труб, стык листов или угловое; V-образная разделка, скос одной кромки, X-образная разделка, комбинированная V-разделка или без скоса кромок.\n'
          '• Количество одинаковых швов.\n'
          '• Длина шва (мм, на деталь) для листов или наружный диаметр трубы (мм): длина = π × OD × количество.\n'
          '• Толщина, зазор, притупление (мм); угол скоса (град) указывается на одну сторону. Для compound V нужны также угол α, угол β и высота излома h.\n'
          '• Свес и высота усиления (мм, необязательно): усиление добавляет к площади (ширина разделки сверху + 2 × свес) × высота.\n'
          '• Угловой шов: катет (мм); площадь = катет² / 2.\n'
          '• Процесс: GTAW, SMAW, GTAW корень + SMAW заполнение, GMAW, FCAW; затем материал и диаметр проволоки/электрода.\n'
          '• Скорость наплавки (кг/ч): по процессу и диаметру или своя.\n'
          '• Плотность (г/см³, по умолчанию 7,85 для углеродистой стали; зависит от класса) и припуск на потери (%, по умолчанию 10).\n\n'
          'Как считается\n'
          '• Объём (см³) = площадь (мм²) × длина (мм) / 1000\n'
          '• Наплавленный металл (кг) = объём × плотность / 1000\n'
          '• Присадка (кг) = наплавленный металл / КПД наплавки × (1 + потери / 100)\n'
          '• Время дуги (ч) = присадка / скорость наплавки\n'
          'КПД наплавки: GTAW 0,95, SMAW 0,65, GMAW 0,90, FCAW 0,85. Для GTAW корень + SMAW заполнение каждая часть берёт своё значение. Типовые скорости наплавки в зависимости от диаметра: GTAW 0,5–1,3 кг/ч, SMAW 0,8–2,8, GMAW 2,2–4,8, FCAW 3,4–5,4.\n\n'
          'На что обратить внимание\n'
          '• Это теоретическая оценка по заданной геометрии; реальный расход зависит от сборки, техники и положения.\n'
          '• Угол скоса задаётся на одну сторону, а не суммарный.\n'
          '• Длина шва указывается на одну деталь; число деталей задайте в поле «Количество».\n'
          '• Для double V толщина делится пополам, значения усиления относятся к обеим сторонам.\n'
          '• КПД наплавки (перенос металла) — не то же самое, что тепловой КПД дуги для погонной энергии.',
    ),
    'preheat': GuideEntry(
      'Температура подогрева (EN 1011-2)',
      'Вычисляет рекомендуемую минимальную температуру предварительного подогрева нелегированных и мелкозернистых сталей по EN 1011-2, приложение C.3, метод B (на основе CET).\n\n'
          'Входные данные\n'
          '• Состав основного металла, % по массе: C, Si, Mn, Cr, Mo, Ni, Cu, V, B. Пустое поле считается 0. Можно загрузить из сохранённого основного материала.\n'
          '• CET наплавленного металла, % (необязательно) — для особого правила ниже.\n'
          '• Толщина d (мм): при разной толщине берите большую.\n'
          '• Диффузионный водород HD (мл/100 г наплавленного металла, ISO 3690).\n'
          '• Погонная энергия Q (кДж/мм): вводится напрямую или считается по параметрам дуги (см. «Погонная энергия»).\n'
          '• Предел текучести стали (Н/мм², необязательно): только для проверки диапазона.\n\n'
          'Как считается\n'
          '• CET = C + (Mn + Mo)/10 + (Cr + Cu)/20 + Ni/40\n'
          '• Tp = 697·CET + 160·tanh(d/35) + 62·HD^0,35 + (53·CET − 32)·Q − 328 (°C)\n'
          '• Особое правило: если CET основного металла превышает CET наплавленного менее чем на 0,03, расчётный CET = CET наплавленного + 0,03.\n\n'
          'Как читать результат\n'
          '• Значение 20 °C и ниже показывается как «Подогрев не требуется».\n'
          '• Вне проверенных диапазонов выводится предупреждение (результат всё равно показывается): CET 0,2–0,5 %, толщина 10–90 мм, HD 1–20 мл/100 г, Q 0,5–4,0 кДж/мм, предел текучести до 1000 Н/мм².\n'
          '• Метод проверен для групп сталей 1–4 по ISO/TR 15608. CEV (IIW) и Pcm приведены справочно и не входят в EN 1011-2.\n'
          '• «Использовать в расчёте охлаждения» передаёт подогрев в калькулятор t8/5.\n\n'
          'Важно: HD и погонная энергия сильно влияют на результат, берите реальные значения из паспорта материала и WPS. Считайте результат ориентиром и подтверждайте его по WPS и аттестации процедуры.',
    ),
    'cooling': GuideEntry(
      'Время охлаждения t8/5 (EN 1011-2)',
      'Вычисляет время охлаждения шва и зоны термического влияния с 800 °C до 500 °C (EN 1011-2, приложение D.6). Малое время даёт более твёрдую структуру, большое у некоторых сталей снижает вязкость.\n\n'
          'Входные данные\n'
          '• Температура подогрева или межпроходная T0 (°C): ниже 500 °C (не меньше −50 °C).\n'
          '• Погонная энергия Q (кДж/мм).\n'
          '• Тип соединения: валик на пластине (коэффициент формы 1,0) или стыковой шов между проходами (0,9). Угловые соединения не поддерживаются.\n'
          '• Толщина d (мм).\n\n'
          'Как считается\n'
          '• 3D (толстая пластина): t8/5 = (6700 − 5·T0) · Q · [1/(500 − T0) − 1/(800 − T0)] · F3\n'
          '• 2D (тонкая пластина): t8/5 = (4300 − 4,3·T0) · 10⁵ · (Q²/d²) · [1/(500 − T0)² − 1/(800 − T0)²] · F2\n'
          '• Приложение находит переходную толщину dt для ваших T0 и Q: тоньше dt — 2D, иначе 3D. Карточка результата показывает режим.\n\n'
          'Важно: вводите реальную T0; предупреждение появляется при Q вне 0,5–4,0 кДж/мм или толщине вне 3–150 мм.',
    ),
    'heatinput': GuideEntry(
      'Погонная энергия (Q)',
      'Оба калькулятора EN 1011-2 требуют погонную энергию Q в кДж/мм. Выберите «Ввести напрямую» или «Рассчитать по параметрам дуги».\n\n'
          '• Q = k × U × I × 60 / (скорость сварки × 1000)\n'
          '• U в вольтах, I в амперах, скорость в мм/мин.\n'
          '• Тепловой КПД дуги k (EN 1011-1): SMAW 0,8, GMAW/MAG 0,8, SAW 1,0.\n\n'
          'Важно: скорость в мм в минуту, а не в секунду. При многопроходной сварке берите скорость оцениваемого прохода. GTAW/TIG (k = 0,6, EN 1011-1) в списке процессов отсутствует: выберите «Ввести напрямую» и посчитайте Q с k = 0,6.',
    ),
    'library': GuideEntry(
      'Библиотека материалов',
      'В библиотеке хранятся ваши основные материалы (название, обозначение, состав, толщина, CET и Pcm) и присадочные материалы (семейство, плотность, спецификация AWS, состав).\n\n'
          '• Сохранённый основной материал можно загрузить в калькулятор подогрева — состав вводится один раз.\n'
          '• Сохранённые присадочные материалы появляются как варианты в калькуляторе расхода вместе с плотностью.\n'
          '• Записи библиотеки хранятся на этом устройстве.',
    ),
    'presets': GuideEntry(
      'Пресеты и сохранённые расчёты',
      'Калькулятор расхода предлагает стартовые шаблоны (например, труба из углеродистой стали V, GTAW корень + SMAW заполнение) и позволяет сохранять свои данные как пресет.\n\n'
          '• «Сохранённые расчёты» — список пресетов: открыть, переименовать, удалить.\n'
          '• Сохранённые расчёты принадлежат аккаунту: у гостя список пуст, а при сохранении запрашивается e-mail. После входа пресеты синхронизируются по e-mail и видны на каждом устройстве с этим e-mail.\n'
          '• «Сохранённые отчёты» — список экспортированных PDF.',
    ),
    'pdf': GuideEntry(
      'PDF-отчёт',
      'После расчёта пользователи Premium могут экспортировать готовый для клиента PDF с исходными данными, результатами и инженерным обоснованием (формулы и значения). Отчёты сохраняются в «Сохранённых отчётах». Без Premium кнопка экспорта открывает экран Premium.',
    ),
    'ai': GuideEntry(
      'ИИ-ассистент',
      'Чат-ассистент для вопросов по сварке и разбора результатов. Функция Premium.\n\n'
          '• Согласие: перед первым чатом нужно подтвердить, что сообщения отправляются сторонней ИИ-службе для формирования ответа. Согласие можно отозвать в разделе «Аккаунт».\n'
          '• Нужен интернет; есть ограничения длины сообщения и частоты запросов.\n'
          '• Объясняет термины, стандарты и ваши числа. Не заменяет квалифицированного инженера-сварщика, WPS или действующий стандарт и может ошибаться: проверяйте всё, что связано с безопасностью.\n'
          '• Не вводите личные и конфиденциальные данные.',
    ),
    'premium': GuideEntry(
      'Premium',
      'Premium открывает экспорт PDF и ИИ-ассистента. Калькуляторы, библиотеки и сохранённые расчёты остаются бесплатными.\n\n'
          '• Планы: месячный или годовой. Точную цену показывает App Store на экране Premium.\n'
          '• Premium принадлежит вашему Apple ID, а не аккаунту приложения. На другом устройстве с тем же Apple ID установите приложение и нажмите «Восстановить покупки» (экран «Аккаунт»).\n'
          '• Управлять подпиской и отменять её можно в настройках подписок Apple ID (в «Аккаунте» есть ссылка). Удаление аккаунта приложения подписку не отменяет.\n'
          '• Карточка «Статус Premium» в «Аккаунте» показывает план, активна или истекла, дату продления или окончания.\n'
          '• По желанию можно привязать Premium к e-mail, выполнив вход.',
    ),
    'account': GuideEntry(
      'Аккаунт и удаление данных',
      'Паролей нет: аккаунт определяется вашим e-mail. Выход убирает аккаунт с этого устройства; сохранённые расчёты скрыты, пока вы снова не войдёте с тем же e-mail.\n\n'
          '«Удалить аккаунт» (экран «Аккаунт») безвозвратно удаляет e-mail и сохранённые расчёты с устройства и с наших серверов. Это нельзя отменить, и подписка Apple не отменяется.\n\n'
          'При входе используется анонимный идентификатор, полученный из e-mail (односторонний хеш, а не сам e-mail), чтобы покупка Premium следовала за аккаунтом.',
    ),
    'faq': GuideEntry(
      'Вопросы и ответы',
      '• Нужен ли аккаунт? Нет. Гости могут пользоваться всеми калькуляторами и покупать Premium.\n'
          '• Работают ли калькуляторы офлайн? Да. ИИ-ассистенту, синхронизации, покупкам и восстановлению нужен интернет.\n'
          '• На новом телефоне нет Premium. Используйте тот же Apple ID и нажмите «Восстановить покупки» в «Аккаунте».\n'
          '• Почему расход отличается от моих данных? Это теоретическая оценка; подберите припуск на потери и скорость наплавки под вашу практику.\n'
          '• Почему «Подогрев не требуется»? Расчётное Tp не выше 20 °C. Расчётное значение показано под результатом.\n'
          '• Как сменить язык? Кнопкой языка в шапке.',
    ),
  },
);

const _de = GuideCopy(
  screenTitle: 'Benutzerhandbuch',
  searchHint: 'Im Handbuch suchen',
  noResults: 'Nichts gefunden.',
  sections: {
    'start': GuideEntry(
      'Erste Schritte',
      'Die Startseite zeigt die Rechner (Zusatzwerkstoffverbrauch, Vorwärmtemperatur, Abkühlzeit t8/5), die Bibliotheken für Grund- und Zusatzwerkstoffe sowie gespeicherte Berechnungen und Berichte. Alle Rechner arbeiten offline und sind kostenlos.\n\n'
          '• Gast: keine Anmeldung nötig. Alles bleibt nur auf diesem Gerät.\n'
          '• Konto: Anmeldung nur mit E-Mail (ohne Passwort). Gespeicherte Berechnungen werden auf jedem Gerät mit derselben E-Mail synchronisiert.\n'
          '• Sprache: Sprachschaltfläche oben rechts im Kopfbereich (Türkisch, Englisch, Russisch, Deutsch, Hindi).\n\n'
          'Premium (PDF-Export und KI-Assistent) ist optional und ohne Konto erhältlich.',
    ),
    'filler': GuideEntry(
      'Zusatzwerkstoffverbrauch',
      'Schätzt aus der Nahtgeometrie die benötigte Zusatzwerkstoffmenge (kg) und die Lichtbogenzeit (h) einer Schweißnaht.\n\n'
          'Eingaben\n'
          '• Stoßart und Nahtform: Rohr-Stumpfstoß, Blech-Stumpfstoß oder Kehlnaht; Einzel-V, Halb-V, Doppel-V, Compound-V oder I-Naht.\n'
          '• Anzahl gleicher Nähte.\n'
          '• Nahtlänge (mm, je Teil) bei Blechen oder Rohr-Außendurchmesser (mm): Länge = π × OD × Anzahl.\n'
          '• Dicke, Stegabstand, Steghöhe (mm); der Fugenwinkel (Grad) gilt je Seite. Compound-V braucht zusätzlich Primärwinkel α, Sekundärwinkel β und Knickhöhe h.\n'
          '• Deckenüberstand und Deckhöhe (mm, optional): die Decklage addiert (Fugenbreite oben + 2 × Überstand) × Höhe zur Fläche.\n'
          '• Kehlnaht: Schenkellänge (mm); Fläche = Schenkel² / 2.\n'
          '• Verfahren: GTAW, SMAW, GTAW-Wurzel + SMAW-Füllung, GMAW, FCAW; dann Zusatzwerkstoff und Draht-/Elektrodendurchmesser.\n'
          '• Abschmelzleistung (kg/h): Vorgabe nach Verfahren und Durchmesser oder eigener Wert.\n'
          '• Dichte (g/cm³, Standard 7,85 für Kohlenstoffstahl; folgt der gewählten Klasse) und Verlustzuschlag (%, Standard 10).\n\n'
          'Berechnung\n'
          '• Volumen (cm³) = Fläche (mm²) × Länge (mm) / 1000\n'
          '• Schweißgut (kg) = Volumen × Dichte / 1000\n'
          '• Zusatzwerkstoff (kg) = Schweißgut / Ausbringung × (1 + Verlust / 100)\n'
          '• Lichtbogenzeit (h) = Zusatzwerkstoff / Abschmelzleistung\n'
          'Ausbringung: GTAW 0,95, SMAW 0,65, GMAW 0,90, FCAW 0,85. Bei GTAW-Wurzel + SMAW-Füllung hat jeder Teil seinen eigenen Wert. Die Vorgabe-Abschmelzleistungen liegen je nach Durchmesser bei 0,5–1,3 kg/h (GTAW), 0,8–2,8 (SMAW), 2,2–4,8 (GMAW) und 3,4–5,4 (FCAW).\n\n'
          'Fallstricke\n'
          '• Es ist eine theoretische Schätzung aus der gezeichneten Geometrie; der reale Verbrauch hängt von Passung, Technik und Position ab.\n'
          '• Der Fugenwinkel gilt je Seite, nicht als Öffnungswinkel.\n'
          '• Die Nahtlänge gilt je Teil; die Teilezahl steht unter Anzahl.\n'
          '• Bei Doppel-V wird die Dicke halbiert, die Deckwerte gelten für beide Seiten.\n'
          '• Die Ausbringung (Werkstoffübergang) ist nicht der thermische Lichtbogenwirkungsgrad der Wärmeeinbringung.',
    ),
    'preheat': GuideEntry(
      'Vorwärmtemperatur (EN 1011-2)',
      'Berechnet die empfohlene Mindest-Vorwärmtemperatur für unlegierte und Feinkornstähle nach EN 1011-2 Anhang C.3, Verfahren B (CET-basiert).\n\n'
          'Eingaben\n'
          '• Zusammensetzung des Grundwerkstoffs in Masse-%: C, Si, Mn, Cr, Mo, Ni, Cu, V, B. Leer zählt als 0. Laden aus einem gespeicherten Grundwerkstoff ist möglich.\n'
          '• CET des Schweißguts in % (optional) für die Sonderregel unten.\n'
          '• Blechdicke d (mm): bei ungleichen Dicken die größere.\n'
          '• Diffusibler Wasserstoff HD (ml/100 g Schweißgut, ISO 3690).\n'
          '• Wärmeeinbringung Q (kJ/mm): direkt eingeben oder aus Lichtbogenparametern berechnen (siehe Wärmeeinbringung).\n'
          '• Streckgrenze (N/mm², optional): nur für die Bereichsprüfung.\n\n'
          'Berechnung\n'
          '• CET = C + (Mn + Mo)/10 + (Cr + Cu)/20 + Ni/40\n'
          '• Tp = 697·CET + 160·tanh(d/35) + 62·HD^0,35 + (53·CET − 32)·Q − 328 (°C)\n'
          '• Sonderregel: Übersteigt der CET des Grundwerkstoffs den des Schweißguts um weniger als 0,03, wird der Bemessungs-CET = CET Schweißgut + 0,03.\n\n'
          'Ergebnis lesen\n'
          '• Werte bis 20 °C werden als „Keine Vorwärmung erforderlich“ angezeigt.\n'
          '• Außerhalb der gültigen Bereiche erscheinen Warnungen (das Ergebnis wird trotzdem gezeigt): CET 0,2–0,5 %, Dicke 10–90 mm, HD 1–20 ml/100 g, Q 0,5–4,0 kJ/mm, Streckgrenze bis 1000 N/mm².\n'
          '• Das Verfahren gilt für Stahlgruppen 1–4 nach ISO/TR 15608. CEV (IIW) und Pcm dienen nur zur Information und gehören nicht zu EN 1011-2.\n'
          '• „In Abkühlzeit verwenden“ übergibt die Vorwärmung an den t8/5-Rechner.\n\n'
          'Fallstricke: HD und Wärmeeinbringung beeinflussen das Ergebnis stark; nutzen Sie reale Werte aus Datenblatt und WPS. Betrachten Sie das Ergebnis als Orientierung und bestätigen Sie es mit Ihrer WPS und Verfahrensprüfung.',
    ),
    'cooling': GuideEntry(
      'Abkühlzeit t8/5 (EN 1011-2)',
      'Berechnet die Zeit, in der Schweißgut und Wärmeeinflusszone von 800 °C auf 500 °C abkühlen (EN 1011-2 Anhang D.6). Kurze Zeiten bedeuten ein härteres Gefüge, lange Zeiten bei manchen Stählen geringere Zähigkeit.\n\n'
          'Eingaben\n'
          '• Vorwärm- oder Zwischenlagentemperatur T0 (°C): unter 500 °C (mindestens −50 °C).\n'
          '• Wärmeeinbringung Q (kJ/mm).\n'
          '• Stoßart: Auftragraupe auf Blech (Formfaktor 1,0) oder Stumpfnaht zwischen Lagen (0,9). Kehlnähte werden nicht unterstützt.\n'
          '• Blechdicke d (mm).\n\n'
          'Berechnung\n'
          '• 3D (dickes Blech): t8/5 = (6700 − 5·T0) · Q · [1/(500 − T0) − 1/(800 − T0)] · F3\n'
          '• 2D (dünnes Blech): t8/5 = (4300 − 4,3·T0) · 10⁵ · (Q²/d²) · [1/(500 − T0)² − 1/(800 − T0)²] · F2\n'
          '• Die App bestimmt die Übergangsdicke dt für Ihr T0 und Q: dünner als dt gilt 2D, sonst 3D. Die Ergebniskarte nennt den verwendeten Bereich.\n\n'
          'Fallstricke: Geben Sie das reale T0 ein; Warnungen erscheinen bei Q außerhalb 0,5–4,0 kJ/mm oder Dicke außerhalb 3–150 mm.',
    ),
    'heatinput': GuideEntry(
      'Wärmeeinbringung (Q)',
      'Beide EN-1011-2-Rechner brauchen die Wärmeeinbringung Q in kJ/mm. Wählen Sie „Direkt eingeben“ oder „Aus Lichtbogenparametern berechnen“.\n\n'
          '• Q = k × U × I × 60 / (Schweißgeschwindigkeit × 1000)\n'
          '• U in Volt, I in Ampere, Geschwindigkeit in mm/min.\n'
          '• Thermischer Lichtbogenwirkungsgrad k (EN 1011-1): SMAW 0,8, GMAW/MAG 0,8, SAW 1,0.\n\n'
          'Fallstricke: Die Geschwindigkeit ist in mm pro Minute, nicht pro Sekunde. Bei Mehrlagenschweißung die Geschwindigkeit der betrachteten Lage verwenden. GTAW/WIG (k = 0,6, EN 1011-1) ist keine Verfahrensoption: „Direkt eingeben“ wählen und Q mit k = 0,6 selbst berechnen.',
    ),
    'library': GuideEntry(
      'Werkstoffbibliothek',
      'Die Bibliothek enthält Ihre Grundwerkstoffe (Name, Bezeichnung, Zusammensetzung, Dicke, CET und Pcm) und Zusatzwerkstoffe (Familie, Dichte, AWS-Spezifikation, Zusammensetzung).\n\n'
          '• Gespeicherte Grundwerkstoffe lassen sich in den Vorwärmrechner laden; die Zusammensetzung tippen Sie nur einmal.\n'
          '• Gespeicherte Zusatzwerkstoffe erscheinen mit ihrer Dichte als Auswahl im Verbrauchsrechner.\n'
          '• Bibliothekseinträge liegen auf diesem Gerät.',
    ),
    'presets': GuideEntry(
      'Vorgaben und gespeicherte Berechnungen',
      'Der Verbrauchsrechner bietet Startvorlagen (z. B. Kohlenstoffstahl-Rohr Einzel-V, GTAW-Wurzel + SMAW-Füllung) und speichert Ihre Eingaben als Vorgabe.\n\n'
          '• „Gespeicherte Berechnungen“ listet Ihre Vorgaben: öffnen, umbenennen, löschen.\n'
          '• Gespeicherte Berechnungen gehören zu einem Konto: Als Gast bleibt die Liste leer und das Speichern fragt nach Ihrer E-Mail. Nach der Anmeldung werden Vorgaben per E-Mail synchronisiert und erscheinen auf jedem Gerät mit dieser E-Mail.\n'
          '• „Gespeicherte Berichte“ listet die exportierten PDF-Berichte.',
    ),
    'pdf': GuideEntry(
      'PDF-Bericht',
      'Nach der Berechnung können Premium-Nutzer ein kundenfertiges PDF mit Eingaben, Ergebnissen und technischer Grundlage (verwendete Formeln und Werte) exportieren. Exportierte Berichte liegen unter „Gespeicherte Berichte“. Ohne Premium öffnet die Export-Schaltfläche den Premium-Bildschirm.',
    ),
    'ai': GuideEntry(
      'KI-Assistent',
      'Ein Chat-Assistent für Schweißfragen und zum Verständnis Ihrer Ergebnisse. Eine Premium-Funktion.\n\n'
          '• Einwilligung: Vor dem ersten Chat bestätigen Sie, dass Ihre Nachrichten zur Antworterstellung an einen KI-Dienst eines Dritten gesendet werden. Sie können die Einwilligung jederzeit im Konto widerrufen.\n'
          '• Internet ist nötig; es gibt Grenzen für Nachrichtenlänge und Anfragerate.\n'
          '• Er erklärt Begriffe, Normen und Ihre Zahlen. Er ersetzt weder eine Schweißfachkraft noch Ihre WPS oder die gültige Norm und kann irren: Prüfen Sie alles Sicherheitsrelevante.\n'
          '• Geben Sie keine persönlichen oder vertraulichen Daten ein.',
    ),
    'premium': GuideEntry(
      'Premium',
      'Premium schaltet PDF-Export und den KI-Assistenten frei. Rechner, Bibliotheken und gespeicherte Berechnungen bleiben kostenlos.\n\n'
          '• Tarife: monatlich oder jährlich. Den genauen Preis zeigt der App Store im Premium-Bildschirm.\n'
          '• Premium gehört zu Ihrer Apple-ID, nicht zum App-Konto. Auf einem anderen Gerät mit derselben Apple-ID installieren Sie die App und tippen im Konto auf „Käufe wiederherstellen“.\n'
          '• Verwalten oder kündigen Sie in den Abonnement-Einstellungen Ihrer Apple-ID (im Konto gibt es eine Verknüpfung). Das Löschen des App-Kontos kündigt das Abonnement nicht.\n'
          '• Die Karte „Premium-Status“ im Konto zeigt Tarif, aktiv oder abgelaufen sowie Verlängerungs- oder Enddatum.\n'
          '• Optional können Sie Premium durch Anmeldung mit Ihrer E-Mail verknüpfen.',
    ),
    'account': GuideEntry(
      'Konto und Datenlöschung',
      'Es gibt keine Passwörter: Ihre E-Mail identifiziert Ihr Konto. Abmelden entfernt das Konto von diesem Gerät; gespeicherte Berechnungen sind erst nach erneuter Anmeldung mit derselben E-Mail wieder sichtbar.\n\n'
          '„Konto löschen“ (Kontobildschirm) entfernt E-Mail und gespeicherte Berechnungen dauerhaft von diesem Gerät und von unseren Servern. Das ist unumkehrbar und kündigt kein Apple-Abonnement.\n\n'
          'Bei der Anmeldung wird eine aus Ihrer E-Mail abgeleitete anonyme Kennung (Einweg-Hash, nicht die E-Mail) genutzt, damit Ihr Premium-Kauf Ihrem Konto folgen kann.',
    ),
    'faq': GuideEntry(
      'Häufige Fragen',
      '• Brauche ich ein Konto? Nein. Gäste nutzen alle Rechner und können Premium kaufen.\n'
          '• Arbeiten die Rechner offline? Ja. KI-Assistent, Synchronisierung, Käufe und Wiederherstellen brauchen Internet.\n'
          '• Auf dem neuen Handy fehlt Premium. Dieselbe Apple-ID verwenden und im Konto „Käufe wiederherstellen“ tippen.\n'
          '• Warum weicht das Ergebnis von meinen Werkstattdaten ab? Es ist eine theoretische Schätzung; passen Sie Verlustzuschlag und Abschmelzleistung an Ihre Praxis an.\n'
          '• Warum „Keine Vorwärmung erforderlich“? Der berechnete Tp liegt bei oder unter 20 °C. Der berechnete Wert steht unter dem Ergebnis.\n'
          '• Wie ändere ich die Sprache? Mit der Sprachschaltfläche im Kopfbereich.',
    ),
  },
);

const _hi = GuideCopy(
  screenTitle: 'उपयोग गाइड',
  searchHint: 'गाइड में खोजें',
  noResults: 'कुछ नहीं मिला।',
  sections: {
    'start': GuideEntry(
      'शुरुआत',
      'होम पर कैलकुलेटर (फिलर खपत, प्रीहीट तापमान, कूलिंग समय t8/5), बेस और फिलर मटेरियल लाइब्रेरी, तथा आपकी सहेजी गणनाएँ और रिपोर्ट दिखती हैं। सभी कैलकुलेटर ऑफ़लाइन चलते हैं और मुफ़्त हैं।\n\n'
          '• गेस्ट: साइन-इन ज़रूरी नहीं। सब कुछ केवल इसी डिवाइस पर रहता है।\n'
          '• खाता: केवल ईमेल से साइन-इन (पासवर्ड नहीं)। सहेजी गणनाएँ उसी ईमेल वाले हर डिवाइस पर सिंक होती हैं।\n'
          '• भाषा: हेडर में ऊपर दाईं ओर भाषा बटन (तुर्की, अंग्रेज़ी, रूसी, जर्मन, हिन्दी)।\n\n'
          'Premium (PDF एक्सपोर्ट और AI सहायक) वैकल्पिक है और खाते के बिना खरीदा जा सकता है।',
    ),
    'filler': GuideEntry(
      'फिलर मेटल खपत',
      'जोड़ की ज्यामिति से एक वेल्ड के लिए ज़रूरी फिलर मेटल (किग्रा) और आर्क समय (घंटे) का अनुमान लगाता है।\n\n'
          'इनपुट\n'
          '• जोड़ और ग्रूव: पाइप बट, प्लेट बट या फ़िलेट; सिंगल V, हाफ V, डबल V, कंपाउंड V या स्क्वेयर।\n'
          '• मात्रा: एक जैसे वेल्ड की संख्या।\n'
          '• प्लेट के लिए वेल्ड लंबाई (मिमी, प्रति पीस) या पाइप के लिए पाइप बाहरी व्यास (मिमी): लंबाई = π × OD × मात्रा।\n'
          '• मोटाई, रूट गैप, रूट फेस (मिमी); बेवल कोण (डिग्री) प्रति पक्ष होता है। कंपाउंड V के लिए प्राथमिक कोण α, द्वितीयक कोण β और ब्रेक ऊँचाई h भी चाहिए।\n'
          '• कैप ओवरलैप और कैप ऊँचाई (मिमी, वैकल्पिक): कैप क्षेत्रफल में (ग्रूव ऊपरी चौड़ाई + 2 × ओवरलैप) × ऊँचाई जोड़ता है।\n'
          '• फ़िलेट: लेग साइज़ (मिमी); क्षेत्रफल = लेग² / 2।\n'
          '• प्रक्रिया: GTAW, SMAW, GTAW रूट + SMAW फ़िल, GMAW, FCAW; फिर कंज़्यूमेबल और तार/इलेक्ट्रोड व्यास।\n'
          '• डिपॉज़िशन दर (किग्रा/घंटा): प्रक्रिया और व्यास के अनुसार प्रीसेट या आपकी अपनी।\n'
          '• घनत्व (ग्राम/सेमी³, कार्बन स्टील के लिए डिफ़ॉल्ट 7.85; चुनी श्रेणी के अनुसार) और अपव्यय भत्ता (%, डिफ़ॉल्ट 10)।\n\n'
          'गणना कैसे होती है\n'
          '• आयतन (सेमी³) = क्षेत्रफल (मिमी²) × लंबाई (मिमी) / 1000\n'
          '• वेल्ड मेटल (किग्रा) = आयतन × घनत्व / 1000\n'
          '• फिलर (किग्रा) = वेल्ड मेटल / डिपॉज़िशन दक्षता × (1 + अपव्यय / 100)\n'
          '• आर्क समय (घंटे) = फिलर / डिपॉज़िशन दर\n'
          'डिपॉज़िशन दक्षता: GTAW 0.95, SMAW 0.65, GMAW 0.90, FCAW 0.85। GTAW रूट + SMAW फ़िल में हर हिस्सा अपना मान लेता है। व्यास के अनुसार प्रीसेट दरें GTAW 0.5–1.3 किग्रा/घंटा, SMAW 0.8–2.8, GMAW 2.2–4.8 और FCAW 3.4–5.4 के बीच हैं।\n\n'
          'सावधानियाँ\n'
          '• यह बनाई गई ज्यामिति से सैद्धांतिक अनुमान है; वास्तविक खपत फ़िट-अप, तकनीक और पोज़िशन पर निर्भर करती है।\n'
          '• बेवल कोण प्रति पक्ष है, कुल कोण नहीं।\n'
          '• वेल्ड लंबाई प्रति पीस है; पीस की संख्या मात्रा में दें।\n'
          '• डबल V में मोटाई आधी बाँटी जाती है और कैप मान दोनों तरफ़ लगते हैं।\n'
          '• यहाँ की डिपॉज़िशन दक्षता (मेटल ट्रांसफ़र) हीट इनपुट वाली आर्क थर्मल दक्षता नहीं है।',
    ),
    'preheat': GuideEntry(
      'प्रीहीट तापमान (EN 1011-2)',
      'EN 1011-2 अनुलग्नक C.3, विधि B (CET आधारित) से नॉन-अलॉय और फ़ाइन-ग्रेन स्टील के लिए सुझाया गया न्यूनतम प्रीहीट तापमान निकालता है।\n\n'
          'इनपुट\n'
          '• बेस मेटल संरचना, भार के अनुसार %: C, Si, Mn, Cr, Mo, Ni, Cu, V, B। खाली को 0 माना जाता है। सहेजी बेस मटेरियल से लोड कर सकते हैं।\n'
          '• वेल्ड मेटल CET % (वैकल्पिक), नीचे के विशेष नियम के लिए।\n'
          '• प्लेट मोटाई d (मिमी): अलग मोटाई हो तो मोटी वाली लें।\n'
          '• डिफ़्यूज़ेबल हाइड्रोजन HD (मिली/100 ग्राम वेल्ड मेटल, ISO 3690)।\n'
          '• नेट हीट इनपुट Q (kJ/मिमी): सीधे दें या आर्क पैरामीटर से निकालें (हीट इनपुट देखें)।\n'
          '• स्टील यील्ड स्ट्रेंथ (N/मिमी², वैकल्पिक): केवल सीमा जाँच में उपयोग होती है।\n\n'
          'गणना कैसे होती है\n'
          '• CET = C + (Mn + Mo)/10 + (Cr + Cu)/20 + Ni/40\n'
          '• Tp = 697·CET + 160·tanh(d/35) + 62·HD^0.35 + (53·CET − 32)·Q − 328 (°C)\n'
          '• विशेष नियम: यदि बेस मेटल CET वेल्ड मेटल CET से 0.03 से कम अधिक है तो डिज़ाइन CET = वेल्ड मेटल CET + 0.03।\n\n'
          'परिणाम पढ़ना\n'
          '• 20 °C या उससे कम मान "प्रीहीट आवश्यक नहीं" के रूप में दिखता है।\n'
          '• मान्य सीमाओं से बाहर चेतावनी आती है (परिणाम फिर भी दिखता है): CET 0.2–0.5 %, मोटाई 10–90 मिमी, HD 1–20 मिली/100 ग्राम, Q 0.5–4.0 kJ/मिमी, यील्ड स्ट्रेंथ 1000 N/मिमी² तक।\n'
          '• विधि ISO/TR 15608 के स्टील समूह 1–4 के लिए मान्य है। CEV (IIW) और Pcm केवल जानकारी के लिए हैं; वे EN 1011-2 का हिस्सा नहीं हैं।\n'
          '• "कूलिंग समय में उपयोग करें" प्रीहीट को t8/5 कैलकुलेटर में भेजता है।\n\n'
          'सावधानी: HD और हीट इनपुट परिणाम को बहुत बदलते हैं; कंज़्यूमेबल डेटा शीट और WPS से वास्तविक मान लें। परिणाम को मार्गदर्शन मानें और अपनी WPS तथा प्रक्रिया योग्यता से पुष्टि करें।',
    ),
    'cooling': GuideEntry(
      'कूलिंग समय t8/5 (EN 1011-2)',
      'वेल्ड और ताप-प्रभावित क्षेत्र के 800 °C से 500 °C तक ठंडा होने का समय निकालता है (EN 1011-2 अनुलग्नक D.6)। कम समय से कठोर सूक्ष्म संरचना बनती है, अधिक समय से कुछ स्टील में टफ़नेस घटती है।\n\n'
          'इनपुट\n'
          '• प्रीहीट या इंटरपास तापमान T0 (°C): 500 °C से कम (कम से कम −50 °C)।\n'
          '• नेट हीट इनपुट Q (kJ/मिमी)।\n'
          '• जोड़ का प्रकार: प्लेट पर बीड (आकार गुणक 1.0) या रनों के बीच बट वेल्ड (0.9)। फ़िलेट जोड़ समर्थित नहीं हैं।\n'
          '• प्लेट मोटाई d (मिमी)।\n\n'
          'गणना कैसे होती है\n'
          '• 3D (मोटी प्लेट): t8/5 = (6700 − 5·T0) · Q · [1/(500 − T0) − 1/(800 − T0)] · F3\n'
          '• 2D (पतली प्लेट): t8/5 = (4300 − 4.3·T0) · 10⁵ · (Q²/d²) · [1/(500 − T0)² − 1/(800 − T0)²] · F2\n'
          '• ऐप आपके T0 और Q के लिए संक्रमण मोटाई dt निकालता है: dt से पतली हो तो 2D, वरना 3D। परिणाम कार्ड उपयोग हुआ तरीका बताता है।\n\n'
          'सावधानी: जिस T0 पर वास्तव में वेल्ड करते हैं वही दें; Q 0.5–4.0 kJ/मिमी या मोटाई 3–150 मिमी से बाहर हो तो चेतावनी आती है।',
    ),
    'heatinput': GuideEntry(
      'हीट इनपुट (Q)',
      'दोनों EN 1011-2 कैलकुलेटर को kJ/मिमी में नेट हीट इनपुट Q चाहिए। "सीधे दर्ज करें" या "आर्क पैरामीटर से गणना करें" चुनें।\n\n'
          '• Q = k × U × I × 60 / (यात्रा गति × 1000)\n'
          '• U वोल्ट में, I एम्पीयर में, यात्रा गति मिमी/मिनट में।\n'
          '• आर्क थर्मल दक्षता k (EN 1011-1): SMAW 0.8, GMAW/MAG 0.8, SAW 1.0।\n\n'
          'सावधानी: गति मिमी प्रति मिनट है, प्रति सेकंड नहीं। मल्टी-पास वेल्ड में उस पास की गति लें जिसे आँक रहे हैं। GTAW/TIG (k = 0.6, EN 1011-1) प्रक्रिया विकल्प में नहीं है: "सीधे दर्ज करें" चुनें और Q को k = 0.6 से स्वयं निकालें।',
    ),
    'library': GuideEntry(
      'मटेरियल लाइब्रेरी',
      'लाइब्रेरी में आपकी बेस मटेरियल (नाम, पदनाम, संरचना, मोटाई, CET और Pcm) और फिलर मटेरियल (परिवार, घनत्व, AWS विनिर्देश, संरचना) रहती हैं।\n\n'
          '• सहेजी बेस मटेरियल प्रीहीट कैलकुलेटर में लोड हो सकती हैं; संरचना एक बार ही लिखनी पड़ती है।\n'
          '• सहेजी फिलर मटेरियल अपने घनत्व के साथ फिलर खपत कैलकुलेटर में विकल्प के रूप में दिखती हैं।\n'
          '• लाइब्रेरी प्रविष्टियाँ इसी डिवाइस पर रहती हैं।',
    ),
    'presets': GuideEntry(
      'प्रीसेट और सहेजी गणनाएँ',
      'फिलर कैलकुलेटर स्टार्टर टेम्पलेट देता है (जैसे कार्बन स्टील पाइप सिंगल V, GTAW रूट + SMAW फ़िल) और आपके इनपुट को प्रीसेट के रूप में सहेजने देता है।\n\n'
          '• "सहेजी गणनाएँ" आपके प्रीसेट दिखाती है: खोलें, नाम बदलें या हटाएँ।\n'
          '• सहेजी गणनाएँ खाते की होती हैं: गेस्ट के लिए सूची खाली रहती है और सहेजने पर ईमेल माँगा जाता है। साइन-इन के बाद प्रीसेट ईमेल से सिंक होते हैं और उसी ईमेल वाले हर डिवाइस पर दिखते हैं।\n'
          '• "सहेजी रिपोर्ट" आपके एक्सपोर्ट किए PDF दिखाती है।',
    ),
    'pdf': GuideEntry(
      'PDF रिपोर्ट',
      'गणना के बाद Premium उपयोगकर्ता इनपुट, परिणाम और इंजीनियरिंग आधार (प्रयुक्त सूत्र और मान) सहित क्लाइंट-तैयार PDF एक्सपोर्ट कर सकते हैं। एक्सपोर्ट की गई रिपोर्ट "सहेजी रिपोर्ट" में रहती हैं। Premium के बिना एक्सपोर्ट बटन Premium स्क्रीन खोलता है।',
    ),
    'ai': GuideEntry(
      'AI सहायक',
      'वेल्डिंग प्रश्नों और अपने परिणाम समझने के लिए चैट सहायक। यह Premium सुविधा है।\n\n'
          '• सहमति: पहली चैट से पहले आपको पुष्टि करनी होती है कि जवाब बनाने के लिए आपके संदेश किसी तीसरे पक्ष की AI सेवा को भेजे जाते हैं। सहमति कभी भी खाता स्क्रीन में वापस ले सकते हैं।\n'
          '• इंटरनेट चाहिए; संदेश लंबाई और दर की सीमा है।\n'
          '• यह शब्द, मानक और आपकी संख्याएँ समझा सकता है। यह योग्य वेल्डिंग इंजीनियर, आपकी WPS या लागू कोड की जगह नहीं ले सकता और गलत भी हो सकता है: सुरक्षा से जुड़ी हर बात जाँचें।\n'
          '• निजी या गोपनीय जानकारी न लिखें।',
    ),
    'premium': GuideEntry(
      'Premium',
      'Premium PDF एक्सपोर्ट और AI सहायक खोलता है। कैलकुलेटर, लाइब्रेरी और सहेजी गणनाएँ मुफ़्त रहती हैं।\n\n'
          '• प्लान: मासिक या वार्षिक। सटीक कीमत App Store Premium स्क्रीन पर दिखाता है।\n'
          '• Premium आपकी Apple ID का है, ऐप खाते का नहीं। उसी Apple ID वाले दूसरे डिवाइस पर ऐप इंस्टॉल करके खाता स्क्रीन में "खरीदारी पुनर्स्थापित करें" दबाएँ।\n'
          '• Apple ID की सदस्यता सेटिंग में प्रबंधित या रद्द करें (खाता स्क्रीन में शॉर्टकट है)। ऐप खाता हटाने से सदस्यता रद्द नहीं होती।\n'
          '• खाता स्क्रीन का Premium स्थिति कार्ड प्लान, सक्रिय/समाप्त और नवीनीकरण या समाप्ति तिथि दिखाता है।\n'
          '• चाहें तो साइन-इन करके Premium को अपने ईमेल से जोड़ सकते हैं।',
    ),
    'account': GuideEntry(
      'खाता और डेटा हटाना',
      'कोई पासवर्ड नहीं है: आपका ईमेल आपके खाते की पहचान है। साइन-आउट खाते को इस डिवाइस से हटाता है; सहेजी गणनाएँ उसी ईमेल से दोबारा साइन-इन करने तक छिपी रहती हैं।\n\n'
          'खाता हटाएँ (खाता स्क्रीन) आपका ईमेल और सहेजी गणनाएँ इस डिवाइस और हमारे सर्वर से स्थायी रूप से हटा देता है। इसे पलटा नहीं जा सकता और यह Apple सदस्यता रद्द नहीं करता।\n\n'
          'साइन-इन करने पर आपके ईमेल से बनी एक अनाम पहचान (वन-वे हैश, ईमेल नहीं) उपयोग होती है ताकि आपकी Premium खरीद आपके खाते के साथ चल सके।',
    ),
    'faq': GuideEntry(
      'अक्सर पूछे सवाल',
      '• क्या खाता ज़रूरी है? नहीं। गेस्ट सभी कैलकुलेटर इस्तेमाल कर सकते हैं और Premium खरीद सकते हैं।\n'
          '• क्या कैलकुलेटर ऑफ़लाइन चलते हैं? हाँ। AI सहायक, सिंक, खरीदारी और पुनर्स्थापना को इंटरनेट चाहिए।\n'
          '• नए फ़ोन पर मेरा Premium नहीं दिख रहा। वही Apple ID इस्तेमाल करें और खाता स्क्रीन में "खरीदारी पुनर्स्थापित करें" दबाएँ।\n'
          '• फिलर परिणाम मेरे शॉप डेटा से अलग क्यों है? यह सैद्धांतिक अनुमान है; अपव्यय भत्ता और डिपॉज़िशन दर अपने अभ्यास के अनुसार बदलें।\n'
          '• "प्रीहीट आवश्यक नहीं" क्यों? गणना किया Tp 20 °C या उससे कम है। गणना किया मान परिणाम के नीचे दिखता है।\n'
          '• भाषा कैसे बदलूँ? हेडर में भाषा बटन से।',
    ),
  },
);

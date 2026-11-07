/**
 * Varyos Weld -- COMPLETE replacement for Kod.gs (the only file) of the
 * Apps Script project "Adsız proje" (script.google.com, owner account),
 * whose web-app deployment is SignupConfig.presetApiUrl and whose
 * installable trigger "From form - On form submit" calls onFormSubmit.
 * Verbatim copy of the LIVE code (deployment version 4, 21 Oct 2026):
 * docs/apps_script/live_backup_2026-11-07/Kod.gs (local only, git-ignored).
 * Deploy steps: docs/apps_script/DEPLOY_STEPS_1.0.1.md.
 *
 * WHY: the /exec URL is public. Up to 1.0 the client sent a bare email, so
 * anyone could read, overwrite or delete anyone's presets and wipe anyone's
 * account. From 1.0.1 the client sends a Firebase ID token (`idToken`) in
 * the POST body; this file verifies it with Google (identitytoolkit
 * accounts:lookup, script property FIREBASE_WEB_API_KEY) and uses only the
 * VERIFIED email. A bare `email` is never trusted.
 *
 * OLD 1.0 CLIENTS (App Store) send no token and get
 * {"ok":false,"error":"update_required"} for everything (GET list, POST
 * save/delete/deleteAccount). The 1.0 app treats that as an ordinary
 * failure: presets fall back to the device copy, saves are kept locally
 * ("saved offline"), rename/delete show their error snackbar, account
 * deletion shows "Deletion not confirmed" (with Retry/Close) after clearing
 * local data. No crash. The welcome mail is unaffected (Form trigger).
 *
 * FUNCTION MAP (T = needs a verified Firebase ID token)
 *   doGet                  no auth; always {error:'update_required'}
 *   doPost                 T for every action (auth runs BEFORE the lock)
 *     action listPresets   T  reads this email's rows      {ok,presets}
 *     action save          T  upserts (email, preset.id)   {ok}
 *     action delete        T  removes (email, presetId)    {ok}
 *     action deleteAccount T  signup rows + presets + Form responses
 *   errors: update_required (no token), invalid_token, email_not_verified,
 *           auth_unavailable (Google 429/5xx/network), server_misconfigured
 *           (FIREBASE_WEB_API_KEY missing / 403), bad_request, unknown action
 *   onFormSubmit           no auth; Form trigger -> sendWelcomeEmail
 *   buildWelcomeEmailHtml  ORIGINAL live mail (verbatim)
 *   buildWelcomeEmail_     localized templates (+ English fallback)
 *   testAuthenticateRequest / testWelcomeEmail / testDeleteAccount
 *                          editor-only checks (no mail is sent)
 *
 * DIFFERENCES vs live v4: GET listPresets and every bare-email POST now
 * return update_required; listPresets moved to POST; identity = verified
 * token email; lock wait failure returns JSON instead of throwing; one
 * unreadable DataJson row no longer fails the whole list; welcome mail can
 * be localized. Sheets, columns, IDs, Resend sender and deletion logic are
 * unchanged.
 */

// ---------------------------------------------------------------- welcome
//
// Form submit trigger (installable, runs the HEAD code, not a deployment
// version). LIVE behaviour kept: the email comes from the 'E-posta' question
// (fallback: the first answer), the mail goes out through Resend from
// team@varyosweld.com with RESEND_API_KEY.
//
// NEW (optional): if the Form gets "First name" and "Locale" short-answer
// questions, the mail is personalised and localized from WELCOME_TEMPLATES_
// (en/tr/de/ru/hi, unknown locale -> en). While the Form has only the email
// question, the ORIGINAL live English mail (buildWelcomeEmailHtml, verbatim
// from live version 4) is sent unchanged.

function onFormSubmit(e) {
  var email = '';
  var firstName = '';
  var locale = '';
  if (e && e.response) {
    var itemResponses = e.response.getItemResponses();
    for (var i = 0; i < itemResponses.length; i++) {
      var title = String(itemResponses[i].getItem().getTitle()).trim();
      var answer = itemResponses[i].getResponse();
      if (title === 'E-posta') {
        if (!email) email = answer;
      } else if (/^first ?name$/i.test(title)) {
        firstName = answer;
      } else if (/^locale$/i.test(title)) {
        locale = answer;
      }
    }
    if (!email && itemResponses.length > 0) {
      email = itemResponses[0].getResponse();
    }
  }
  email = (email || '').toString().trim();
  if (!email) return;
  sendWelcomeEmail(email, (firstName || '').toString().trim(), (locale || '').toString().trim());
}

function sendWelcomeEmail(email, firstName, locale) {
  var apiKey = PropertiesService.getScriptProperties().getProperty('RESEND_API_KEY');
  var mail = buildWelcomeEmail_(firstName, locale);
  var payload = {
    from: 'Varyos Weld <team@varyosweld.com>',
    to: [email],
    subject: mail.subject,
    html: mail.html
  };
  var options = {
    method: 'post',
    contentType: 'application/json',
    headers: { Authorization: 'Bearer ' + apiKey },
    payload: JSON.stringify(payload),
    muteHttpExceptions: true
  };
  var response = UrlFetchApp.fetch('https://api.resend.com/emails', options);
  Logger.log(response.getResponseCode() + ' ' + response.getContentText());
}

function escapeHtml_(value) {
  return String(value).replace(/[&<>"']/g, function (c) {
    return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
  });
}

/** 'tr', 'tr-TR', 'TR_tr' -> 'tr'; anything unknown -> 'en'. */
function welcomeLocale_(locale) {
  var code = String(locale || '').trim().toLowerCase().split(/[-_]/)[0];
  return Object.prototype.hasOwnProperty.call(WELCOME_TEMPLATES_, code) ? code : 'en';
}

/**
 * @return {{subject:string, html:string}}
 */
function buildWelcomeEmail_(firstName, locale) {
  // Form still has only the email question: the original live mail.
  if (!firstName && !locale) {
    return { subject: 'Welcome to Varyos Weld!', html: buildWelcomeEmailHtml() };
  }
  var template = WELCOME_TEMPLATES_[welcomeLocale_(locale)];
  var subjectMatch = template.match(/^<!--\s*Subject:\s*([\s\S]*?)\s*-->/);
  var subject = subjectMatch ? subjectMatch[1] : 'Welcome to Varyos Weld!';
  // Drop the leading instruction comments; the mail starts at <!DOCTYPE>.
  var html = template.replace(/^(\s*<!--[\s\S]*?-->\s*)+/, '');
  var name = String(firstName || '').replace(/[\r\n\t]+/g, ' ').trim().slice(0, 60);
  if (name) {
    subject = subject.replace(/\{\{firstName\}\}/g, name);
    html = html.replace(/\{\{firstName\}\}/g, escapeHtml_(name));
  } else {
    // "Hi {{firstName}}," -> "Hi,"; "Здравствуйте, {{firstName}}!" -> "Здравствуйте!"
    subject = subject.replace(/[ ,]*\{\{firstName\}\}/g, '');
    html = html.replace(/[ ,]*\{\{firstName\}\}/g, '');
  }
  return { subject: subject, html: html };
}

/** ORIGINAL live welcome mail (live version 4, verbatim). */
function buildWelcomeEmailHtml() {
  return ''
    + '<html>'
    + '<body style="margin:0;padding:0;background-color:#111111;font-family:Helvetica,Arial,sans-serif;">'
    + '<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color:#111111;padding:40px 0;">'
    + '<tr><td align="center">'
    + '<table role="presentation" width="480" cellpadding="0" cellspacing="0" style="background-color:#1a1a1a;border-radius:8px;overflow:hidden;">'
    + '<tr><td style="padding:40px 32px 24px 32px;text-align:center;">'
    + '<div style="font-size:22px;font-weight:bold;letter-spacing:4px;color:#ffffff;">VARYOS</div>'
    + '<div style="font-size:14px;font-weight:bold;letter-spacing:6px;color:#ff6a1a;margin-top:2px;">WELD</div>'
    + '</td></tr>'
    + '<tr><td style="padding:0 32px;">'
    + '<hr style="border:none;border-top:1px solid #333333;margin:0 0 24px 0;">'
    + '</td></tr>'
    + '<tr><td style="padding:0 32px 8px 32px;">'
    + '<p style="color:#ffffff;font-size:18px;font-weight:bold;margin:0 0 16px 0;">Welcome! 👋</p>'
    + '<p style="color:#cccccc;font-size:15px;line-height:1.6;margin:0 0 16px 0;">'
    + 'Thank you for joining Varyos Weld. You can now calculate your welding consumables '
    + 'quickly and accurately, all in one place.'
    + '</p>'
    + '<p style="color:#cccccc;font-size:15px;line-height:1.6;margin:0 0 24px 0;">'
    + 'If you have any questions or feedback, just reply to this email — we would love to hear from you.'
    + '</p>'
    + '<p style="color:#ffffff;font-size:15px;line-height:1.6;margin:0 0 4px 0;">Cheers,</p>'
    + '<p style="color:#ff6a1a;font-size:15px;font-weight:bold;margin:0;">The Varyos Weld Team</p>'
    + '</td></tr>'
    + '<tr><td style="padding:32px 32px 32px 32px;">'
    + '<hr style="border:none;border-top:1px solid #333333;margin:0 0 16px 0;">'
    + '<p style="color:#666666;font-size:12px;line-height:1.5;margin:0;text-align:center;">'
    + 'You received this email because you signed up via varyosweld.com.'
    + '</p>'
    + '</td></tr>'
    + '</table>'
    + '</td></tr>'
    + '</table>'
    + '</body>'
    + '</html>';
}

// Generated verbatim from docs/apps_script/welcome_email_templates/*.html
// (keep in sync if a template changes). First line = subject comment.
var WELCOME_TEMPLATES_ = {
  en: "<!-- Subject: Welcome to Varyos Weld, {{firstName}} -->\n<!-- Placeholder: {{firstName}} is replaced by the Apps Script (HTML-escaped). -->\n<!DOCTYPE html>\n<html lang=\"en\">\n<body style=\"margin:0;padding:0;background:#f3f6f8;font-family:-apple-system,Helvetica,Arial,sans-serif;color:#17303c\">\n  <div style=\"max-width:560px;margin:0 auto;padding:24px\">\n    <div style=\"background:#12191b;border-radius:16px 16px 0 0;padding:24px;color:#fff\">\n      <div style=\"font-size:13px;letter-spacing:2px;color:#ff6a35;font-weight:700\">VARYOS WELD</div>\n      <div style=\"font-size:24px;font-weight:800;margin-top:6px\">Welcome aboard!</div>\n    </div>\n    <div style=\"background:#fff;border-radius:0 0 16px 16px;padding:24px;line-height:1.5;font-size:15px\">\n      <p>Hi {{firstName}},</p>\n      <p>Thanks for creating your Varyos Weld account. Everything you need for weld calculations, in one place:</p>\n      <ul style=\"padding-left:20px\">\n        <li style=\"margin-bottom:8px\"><b>Filler consumption:</b> electrode/wire quantity and cost estimate by joint type, groove and process.</li>\n        <li style=\"margin-bottom:8px\"><b>Preheat (EN 1011-2):</b> preheat temperature from material, thickness and hydrogen level.</li>\n        <li style=\"margin-bottom:8px\"><b>t8/5 cooling time:</b> time to cool from 800 to 500 °C.</li>\n        <li style=\"margin-bottom:8px\"><b>Heat input:</b> heat input (kJ/mm) from current, voltage and travel speed.</li>\n      </ul>\n      <p><b>User guide:</b> open it from the Account screen to see how each calculation works, step by step.</p>\n      <p><b>AI assistant:</b> ask welding questions and get a second look at your numbers (Premium).</p>\n      <p><b>Premium:</b> PDF reports and the AI assistant. Premium follows your verified account, so just sign in on a new phone to get it back.</p>\n      <p>Questions or ideas? Write to <a href=\"mailto:team@varyosweld.com\">team@varyosweld.com</a> - we read everything.</p>\n      <p style=\"margin-top:24px\">Happy welding,<br>The Varyos Weld team</p>\n    </div>\n  </div>\n</body>\n</html>\n",
  tr: "<!-- Subject: Varyos Weld'e hoş geldin, {{firstName}} -->\n<!-- Placeholder: {{firstName}} is replaced by the Apps Script (HTML-escaped). -->\n<!DOCTYPE html>\n<html lang=\"tr\">\n<body style=\"margin:0;padding:0;background:#f3f6f8;font-family:-apple-system,Helvetica,Arial,sans-serif;color:#17303c\">\n  <div style=\"max-width:560px;margin:0 auto;padding:24px\">\n    <div style=\"background:#12191b;border-radius:16px 16px 0 0;padding:24px;color:#fff\">\n      <div style=\"font-size:13px;letter-spacing:2px;color:#ff6a35;font-weight:700\">VARYOS WELD</div>\n      <div style=\"font-size:24px;font-weight:800;margin-top:6px\">Hoş geldin!</div>\n    </div>\n    <div style=\"background:#fff;border-radius:0 0 16px 16px;padding:24px;line-height:1.5;font-size:15px\">\n      <p>Merhaba {{firstName}},</p>\n      <p>Varyos Weld hesabını oluşturduğun için teşekkürler. Saha ve ofis için kaynak hesaplarını tek yerde topladık:</p>\n      <ul style=\"padding-left:20px\">\n        <li style=\"margin-bottom:8px\"><b>Dolgu malzemesi tüketimi:</b> bağlantı tipi, kaynak ağzı ve prosese göre elektrot/tel miktarı ve maliyet tahmini.</li>\n        <li style=\"margin-bottom:8px\"><b>Ön ısıtma (EN 1011-2):</b> malzeme, kalınlık ve hidrojen seviyesine göre ön ısıtma sıcaklığı.</li>\n        <li style=\"margin-bottom:8px\"><b>t8/5 soğuma süresi:</b> 800-500 °C arası soğuma süresi hesabı.</li>\n        <li style=\"margin-bottom:8px\"><b>Isı girdisi:</b> akım, gerilim ve ilerleme hızından ısı girdisi (kJ/mm).</li>\n      </ul>\n      <p><b>Kullanım Kılavuzu:</b> uygulamada Hesap ekranından kılavuza ulaşabilir, her hesaplamanın nasıl yapıldığını adım adım görebilirsin.</p>\n      <p><b>Yapay zekâ asistanı:</b> kaynak sorularını sor, hesapların için ikinci bir bakış al (Premium).</p>\n      <p><b>Premium:</b> PDF rapor çıktısı ve yapay zekâ asistanı. Premium'un doğrulanmış hesabına bağlıdır; yeni telefonda aynı hesapla giriş yapman yeterli.</p>\n      <p>Sorun ya da önerin mi var? <a href=\"mailto:team@varyosweld.com\">team@varyosweld.com</a> adresine yaz, okuyoruz.</p>\n      <p style=\"margin-top:24px\">İyi kaynaklar,<br>Varyos Weld ekibi</p>\n    </div>\n  </div>\n</body>\n</html>\n",
  de: "<!-- Subject: Willkommen bei Varyos Weld, {{firstName}} -->\n<!-- Placeholder: {{firstName}} is replaced by the Apps Script (HTML-escaped). -->\n<!DOCTYPE html>\n<html lang=\"de\">\n<body style=\"margin:0;padding:0;background:#f3f6f8;font-family:-apple-system,Helvetica,Arial,sans-serif;color:#17303c\">\n  <div style=\"max-width:560px;margin:0 auto;padding:24px\">\n    <div style=\"background:#12191b;border-radius:16px 16px 0 0;padding:24px;color:#fff\">\n      <div style=\"font-size:13px;letter-spacing:2px;color:#ff6a35;font-weight:700\">VARYOS WELD</div>\n      <div style=\"font-size:24px;font-weight:800;margin-top:6px\">Willkommen an Bord!</div>\n    </div>\n    <div style=\"background:#fff;border-radius:0 0 16px 16px;padding:24px;line-height:1.5;font-size:15px\">\n      <p>Hallo {{firstName}},</p>\n      <p>Danke für Ihr Varyos-Weld-Konto. Alles für Schweißberechnungen an einem Ort:</p>\n      <ul style=\"padding-left:20px\">\n        <li style=\"margin-bottom:8px\"><b>Zusatzwerkstoffverbrauch:</b> Menge an Elektroden/Draht und Kostenschätzung nach Verbindungsart, Nahtform und Verfahren.</li>\n        <li style=\"margin-bottom:8px\"><b>Vorwärmen (EN 1011-2):</b> Vorwärmtemperatur nach Werkstoff, Dicke und Wasserstoffgehalt.</li>\n        <li style=\"margin-bottom:8px\"><b>Abkühlzeit t8/5:</b> Abkühlzeit von 800 auf 500 °C.</li>\n        <li style=\"margin-bottom:8px\"><b>Wärmeeinbringung:</b> Wärmeeinbringung (kJ/mm) aus Strom, Spannung und Schweißgeschwindigkeit.</li>\n      </ul>\n      <p><b>Benutzerhandbuch:</b> Im Konto-Bildschirm öffnen und jede Berechnung Schritt für Schritt nachvollziehen.</p>\n      <p><b>KI-Assistent:</b> Schweißfragen stellen und die eigenen Werte gegenprüfen (Premium).</p>\n      <p><b>Premium:</b> PDF-Berichte und KI-Assistent. Premium folgt Ihrem bestätigten Konto - auf einem neuen Telefon einfach anmelden.</p>\n      <p>Fragen oder Ideen? Schreiben Sie an <a href=\"mailto:team@varyosweld.com\">team@varyosweld.com</a> - wir lesen alles.</p>\n      <p style=\"margin-top:24px\">Gutes Schweißen,<br>Ihr Varyos-Weld-Team</p>\n    </div>\n  </div>\n</body>\n</html>\n",
  ru: "<!-- Subject: Добро пожаловать в Varyos Weld, {{firstName}} -->\n<!-- Placeholder: {{firstName}} is replaced by the Apps Script (HTML-escaped). -->\n<!DOCTYPE html>\n<html lang=\"ru\">\n<body style=\"margin:0;padding:0;background:#f3f6f8;font-family:-apple-system,Helvetica,Arial,sans-serif;color:#17303c\">\n  <div style=\"max-width:560px;margin:0 auto;padding:24px\">\n    <div style=\"background:#12191b;border-radius:16px 16px 0 0;padding:24px;color:#fff\">\n      <div style=\"font-size:13px;letter-spacing:2px;color:#ff6a35;font-weight:700\">VARYOS WELD</div>\n      <div style=\"font-size:24px;font-weight:800;margin-top:6px\">Добро пожаловать!</div>\n    </div>\n    <div style=\"background:#fff;border-radius:0 0 16px 16px;padding:24px;line-height:1.5;font-size:15px\">\n      <p>Здравствуйте, {{firstName}}!</p>\n      <p>Спасибо за создание аккаунта Varyos Weld. Все сварочные расчёты в одном месте:</p>\n      <ul style=\"padding-left:20px\">\n        <li style=\"margin-bottom:8px\"><b>Расход присадочных материалов:</b> количество электродов/проволоки и оценка стоимости по типу соединения, разделке и процессу.</li>\n        <li style=\"margin-bottom:8px\"><b>Предварительный подогрев (EN 1011-2):</b> температура подогрева по материалу, толщине и уровню водорода.</li>\n        <li style=\"margin-bottom:8px\"><b>Время охлаждения t8/5:</b> время охлаждения от 800 до 500 °C.</li>\n        <li style=\"margin-bottom:8px\"><b>Погонная энергия:</b> погонная энергия (кДж/мм) по току, напряжению и скорости сварки.</li>\n      </ul>\n      <p><b>Руководство:</b> откройте его на экране аккаунта, чтобы пошагово увидеть, как выполняется каждый расчёт.</p>\n      <p><b>ИИ-ассистент:</b> задавайте вопросы по сварке и перепроверяйте расчёты (Premium).</p>\n      <p><b>Premium:</b> PDF-отчёты и ИИ-ассистент. Premium привязан к подтверждённому аккаунту: на новом телефоне достаточно войти.</p>\n      <p>Вопросы или идеи? Пишите на <a href=\"mailto:team@varyosweld.com\">team@varyosweld.com</a> - мы читаем всё.</p>\n      <p style=\"margin-top:24px\">Хорошей сварки,<br>Команда Varyos Weld</p>\n    </div>\n  </div>\n</body>\n</html>\n",
  hi: "<!-- Subject: Varyos Weld में स्वागत है, {{firstName}} -->\n<!-- Placeholder: {{firstName}} is replaced by the Apps Script (HTML-escaped). -->\n<!DOCTYPE html>\n<html lang=\"hi\">\n<body style=\"margin:0;padding:0;background:#f3f6f8;font-family:-apple-system,Helvetica,Arial,sans-serif;color:#17303c\">\n  <div style=\"max-width:560px;margin:0 auto;padding:24px\">\n    <div style=\"background:#12191b;border-radius:16px 16px 0 0;padding:24px;color:#fff\">\n      <div style=\"font-size:13px;letter-spacing:2px;color:#ff6a35;font-weight:700\">VARYOS WELD</div>\n      <div style=\"font-size:24px;font-weight:800;margin-top:6px\">स्वागत है!</div>\n    </div>\n    <div style=\"background:#fff;border-radius:0 0 16px 16px;padding:24px;line-height:1.5;font-size:15px\">\n      <p>नमस्ते {{firstName}},</p>\n      <p>Varyos Weld खाता बनाने के लिए धन्यवाद। वेल्डिंग गणनाओं के लिए सब कुछ एक जगह:</p>\n      <ul style=\"padding-left:20px\">\n        <li style=\"margin-bottom:8px\"><b>फिलर खपत:</b> जॉइंट प्रकार, ग्रूव और प्रक्रिया के अनुसार इलेक्ट्रोड/तार की मात्रा और लागत का अनुमान।</li>\n        <li style=\"margin-bottom:8px\"><b>प्रीहीट (EN 1011-2):</b> सामग्री, मोटाई और हाइड्रोजन स्तर के अनुसार प्रीहीट तापमान।</li>\n        <li style=\"margin-bottom:8px\"><b>t8/5 कूलिंग समय:</b> 800 से 500 °C तक ठंडा होने का समय।</li>\n        <li style=\"margin-bottom:8px\"><b>हीट इनपुट:</b> करंट, वोल्टेज और गति से हीट इनपुट (kJ/mm)।</li>\n      </ul>\n      <p><b>उपयोग गाइड:</b> खाता स्क्रीन से खोलें और देखें कि हर गणना चरण-दर-चरण कैसे होती है।</p>\n      <p><b>AI सहायक:</b> वेल्डिंग के सवाल पूछें और अपनी गणनाओं की दोबारा जाँच करें (Premium)।</p>\n      <p><b>Premium:</b> PDF रिपोर्ट और AI सहायक। Premium आपके सत्यापित खाते के साथ चलता है - नए फ़ोन पर बस साइन इन करें।</p>\n      <p>सवाल या सुझाव? <a href=\"mailto:team@varyosweld.com\">team@varyosweld.com</a> पर लिखें - हम सब पढ़ते हैं।</p>\n      <p style=\"margin-top:24px\">शुभ वेल्डिंग,<br>Varyos Weld टीम</p>\n    </div>\n  </div>\n</body>\n</html>\n"
};

// ---------------------------------------------------------------- presets

function _getPresetsSheet() {
  var props = PropertiesService.getScriptProperties();
  var sheetId = props.getProperty('PRESETS_SHEET_ID');
  var ss = null;
  if (sheetId) {
    try {
      ss = SpreadsheetApp.openById(sheetId);
    } catch (err) {
      ss = null;
    }
  }
  if (!ss) {
    ss = SpreadsheetApp.create('Varyos Weld - Presets');
    props.setProperty('PRESETS_SHEET_ID', ss.getId());
  }
  var sheet = ss.getSheetByName('Presets');
  if (!sheet) {
    sheet = ss.insertSheet('Presets');
    sheet.appendRow(['Email', 'PresetId', 'Name', 'DataJson', 'UpdatedAtEpochMs']);
  }
  return sheet;
}

function _jsonResponse(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}

function normalizeEmail_(value) {
  return String(value).trim().toLowerCase();
}

function listPresetsFor_(email) {
  var values = _getPresetsSheet().getDataRange().getValues();
  var presets = [];
  for (var i = 1; i < values.length; i++) {
    if (normalizeEmail_(values[i][0] || '') !== email) continue;
    var data = {};
    try { data = JSON.parse(values[i][3] || '{}'); } catch (err) { data = {}; }
    presets.push({
      id: String(values[i][1]),
      name: String(values[i][2] || ''),
      updatedAtEpochMs: Number(values[i][4]) || 0,
      data: data
    });
  }
  return { ok: true, presets: presets };
}

function savePresetFor_(email, preset) {
  if (!preset || !preset.id) return { ok: false, error: 'preset required' };
  var sheet = _getPresetsSheet();
  var values = sheet.getDataRange().getValues();
  var rowIndex = -1;
  for (var i = 1; i < values.length; i++) {
    if (normalizeEmail_(values[i][0] || '') === email &&
        String(values[i][1]) === String(preset.id)) {
      rowIndex = i + 1;
      break;
    }
  }
  var rowData = [
    email,
    preset.id,
    preset.name || '',
    JSON.stringify(preset.data || {}),
    preset.updatedAtEpochMs || Date.now()
  ];
  if (rowIndex > 0) {
    sheet.getRange(rowIndex, 1, 1, rowData.length).setValues([rowData]);
  } else {
    sheet.appendRow(rowData);
  }
  return { ok: true };
}

function deletePresetFor_(email, presetId) {
  if (!presetId) return { ok: false, error: 'presetId required' };
  var sheet = _getPresetsSheet();
  var values = sheet.getDataRange().getValues();
  for (var i = values.length - 1; i >= 1; i--) {
    if (normalizeEmail_(values[i][0] || '') === email &&
        String(values[i][1]) === String(presetId)) {
      sheet.deleteRow(i + 1);
    }
  }
  return { ok: true };
}

// ---------------------------------------------------------------- entry points

/** Old 1.0 clients listed presets via GET + bare email: tell them to update. */
function doGet(e) {
  return _jsonResponse({ ok: false, error: 'update_required' });
}

function doPost(e) {
  var payload = {};
  try {
    payload = JSON.parse(e.postData.contents);
  } catch (parseErr) {
    return _jsonResponse({ ok: false, error: 'bad_request' });
  }
  // Authenticate BEFORE taking the lock: the Google round trip must not hold
  // every other request (and a slow/failed lookup must not block saves).
  var auth = authenticateRequest_(payload);
  if (!auth.ok) return _jsonResponse(auth);
  var email = auth.email; // verified, lowercased -- the ONLY identity used

  var lock = LockService.getScriptLock();
  try {
    lock.waitLock(30000);
  } catch (lockErr) {
    return _jsonResponse({ ok: false, error: 'Server busy, please retry.' });
  }
  try {
    switch (payload.action) {
      case 'listPresets':
        return _jsonResponse(listPresetsFor_(email));
      case 'save':
        return _jsonResponse(savePresetFor_(email, payload.preset));
      case 'delete':
        return _jsonResponse(deletePresetFor_(email, payload.presetId));
      case 'deleteAccount':
        return _jsonResponse(handleDeleteAccount_(email));
      default:
        return _jsonResponse({ ok: false, error: 'unknown action' });
    }
  } catch (err) {
    return _jsonResponse({ ok: false, error: String((err && err.message) || err) });
  } finally {
    lock.releaseLock();
  }
}

// ---------------------------------------------------------------- auth

var AUTH_MAX_TOKEN_LENGTH_ = 4096;
var AUTH_MAX_CACHE_SECONDS_ = 21600; // CacheService hard limit (6 h)
var AUTH_JWT_SHAPE_ = /^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/;

function sha256Hex_(text) {
  var bytes = Utilities.computeDigest(Utilities.DigestAlgorithm.SHA_256, text);
  return bytes.map(function (b) {
    return ('0' + (b & 0xff).toString(16)).slice(-2);
  }).join('');
}

/** The (unverified) exp claim in seconds, only used to size the cache TTL. */
function jwtExpiry_(token) {
  try {
    var part = token.split('.')[1];
    var json = Utilities.newBlob(Utilities.base64DecodeWebSafe(part)).getDataAsString();
    return Number(JSON.parse(json).exp) || 0;
  } catch (err) {
    return 0;
  }
}

/**
 * @param {Object} params parsed POST body.
 * @return {{ok:true,email:string,uid:string}|{ok:false,error:string}}
 */
function authenticateRequest_(params) {
  var idToken = params && params.idToken;
  if (!idToken) {
    // Old 1.0 clients send a bare email; they must update.
    return { ok: false, error: 'update_required' };
  }
  idToken = String(idToken);
  // Cheap rejects BEFORE any network call (quota / abuse protection).
  if (idToken.length > AUTH_MAX_TOKEN_LENGTH_ || !AUTH_JWT_SHAPE_.test(idToken)) {
    return { ok: false, error: 'invalid_token' };
  }
  var cache = CacheService.getScriptCache();
  var cacheKey = 'auth_' + sha256Hex_(idToken);
  var cached = cache.get(cacheKey);
  if (cached) {
    try {
      var hit = JSON.parse(cached);
      if (hit && hit.email) return { ok: true, email: hit.email, uid: hit.uid };
    } catch (err) { /* fall through to a real lookup */ }
  }

  var apiKey = PropertiesService.getScriptProperties().getProperty('FIREBASE_WEB_API_KEY');
  if (!apiKey) return { ok: false, error: 'server_misconfigured' };
  var response;
  try {
    response = UrlFetchApp.fetch(
      'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=' +
        encodeURIComponent(apiKey),
      {
        method: 'post',
        contentType: 'application/json',
        payload: JSON.stringify({ idToken: idToken }),
        muteHttpExceptions: true
      }
    );
  } catch (err) {
    return { ok: false, error: 'auth_unavailable' };
  }
  var code = response.getResponseCode();
  // Google throttling / outage: the client says "try later", not "sign in".
  if (code === 429 || code >= 500) return { ok: false, error: 'auth_unavailable' };
  if (code === 403) return { ok: false, error: 'server_misconfigured' };
  if (code !== 200) return { ok: false, error: 'invalid_token' };

  var body;
  try {
    body = JSON.parse(response.getContentText());
  } catch (err) {
    return { ok: false, error: 'auth_unavailable' };
  }
  var user = body && body.users && body.users[0];
  if (!user || !user.email) return { ok: false, error: 'invalid_token' };
  if (user.emailVerified !== true) return { ok: false, error: 'email_not_verified' };

  var result = {
    ok: true,
    email: normalizeEmail_(user.email),
    uid: user.localId
  };
  var ttl = Math.min(jwtExpiry_(idToken) - Math.floor(Date.now() / 1000), AUTH_MAX_CACHE_SECONDS_);
  if (ttl >= 30) {
    cache.put(cacheKey, JSON.stringify({ email: result.email, uid: result.uid }), ttl);
  }
  return result;
}

function testAuthenticateRequest() {
  Logger.log(JSON.stringify(authenticateRequest_({ email: 'a@b.co' })));
  Logger.log(JSON.stringify(authenticateRequest_({ idToken: 'bad' })));
  Logger.log(JSON.stringify(authenticateRequest_({ idToken: 'a.b.c' })));
}

/** Editor check: logs subjects/lengths only, sends nothing. */
function testWelcomeEmail() {
  var cases = [['', ''], ['Ayse', 'tr'], ['', 'ru'], ['<b>X</b>', 'xx'], ['Max', 'de-DE']];
  for (var i = 0; i < cases.length; i++) {
    var mail = buildWelcomeEmail_(cases[i][0], cases[i][1]);
    Logger.log(JSON.stringify(cases[i]) + ' -> ' + mail.subject + ' (' + mail.html.length + ' chars)');
  }
}

// ---------------------------------------------------------------- account deletion

/** From live: harmless check, no such account exists. */
function testDeleteAccount() {
  Logger.log(JSON.stringify(handleDeleteAccount_('nobody-test@example.com')));
}

var DELETE_ACCOUNT_IDS = {
  SIGNUP_SPREADSHEET_ID: '11htQFYKQQh2DxKsLb6O66-9lNe7JtELYbrqqgElJf60',
  SIGNUP_SHEET_NAME: 'Form Yanıtları 1',
  PRESETS_SPREADSHEET_ID: '14U4zIJitFKBJhSZ3CbU2Df4EMSrW1PmtiDAoZRKcCTQ',
  PRESETS_SHEET_NAME: 'Presets',
  FORM_ID: '11u33WAjqnwWUWaDsmRlsZtIJTz0xpePrtTMWLkntFdk'
};

var DELETE_ACCOUNT_EMAIL_HEADER = /e-?mail|e-?posta/i;

/** Called from doPost (which already holds the script lock). */
function handleDeleteAccount_(email) {
  var target = String(email || '').trim().toLowerCase();
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(target)) {
    return { ok: false, error: 'A valid email is required.' };
  }
  try {
    var ids = DELETE_ACCOUNT_IDS;
    var signupSheet = openSheetOrThrow_(ids.SIGNUP_SPREADSHEET_ID, ids.SIGNUP_SHEET_NAME);
    var presetsSheet = openSheetOrThrow_(ids.PRESETS_SPREADSHEET_ID, ids.PRESETS_SHEET_NAME);
    var form = FormApp.openById(ids.FORM_ID);

    var signupCol = findEmailColumnOrThrow_(signupSheet);
    var presetsCol = findEmailColumnOrThrow_(presetsSheet);

    var sheetRows = deleteRowsForEmail_(signupSheet, signupCol, target) +
        deleteRowsForEmail_(presetsSheet, presetsCol, target);
    var formResponses = deleteFormResponsesForEmail_(form, target);
    SpreadsheetApp.flush();
    return { ok: true, deletedSheetRows: sheetRows, deletedFormResponses: formResponses };
  } catch (err) {
    return { ok: false, error: String((err && err.message) || err) };
  }
}

function openSheetOrThrow_(spreadsheetId, sheetName) {
  var spreadsheet = SpreadsheetApp.openById(spreadsheetId);
  var sheet = spreadsheet.getSheetByName(sheetName);
  if (!sheet) {
    throw new Error('Sheet "' + sheetName + '" not found in ' + spreadsheetId);
  }
  return sheet;
}

/** 1-based column index of the first header matching the email pattern. */
function findEmailColumnOrThrow_(sheet) {
  var lastCol = sheet.getLastColumn();
  if (lastCol < 1) {
    throw new Error('Sheet "' + sheet.getName() + '" has no columns.');
  }
  var headers = sheet.getRange(1, 1, 1, lastCol).getValues()[0];
  for (var c = 0; c < headers.length; c++) {
    if (DELETE_ACCOUNT_EMAIL_HEADER.test(String(headers[c]))) return c + 1;
  }
  throw new Error('No email column in sheet "' + sheet.getName() + '".');
}

/** Deletes matching rows bottom-up; re-checks each row right before delete. */
function deleteRowsForEmail_(sheet, emailCol, target) {
  var lastRow = sheet.getLastRow();
  if (lastRow < 2) return 0;
  var cells = sheet.getRange(2, emailCol, lastRow - 1, 1).getValues();
  var deleted = 0;
  for (var i = cells.length - 1; i >= 0; i--) {
    if (normalizeEmail_(cells[i][0]) !== target) continue;
    var row = i + 2;
    if (normalizeEmail_(sheet.getRange(row, emailCol).getValue()) !== target) continue;
    sheet.deleteRow(row);
    deleted++;
  }
  return deleted;
}

/** Deletes Form responses where any text answer (or the respondent email) matches. */
function deleteFormResponsesForEmail_(form, target) {
  var responses = form.getResponses();
  var deleted = 0;
  for (var i = 0; i < responses.length; i++) {
    var response = responses[i];
    var matches = false;
    var respondent = response.getRespondentEmail && response.getRespondentEmail();
    if (respondent && normalizeEmail_(respondent) === target) matches = true;
    var items = response.getItemResponses();
    for (var j = 0; j < items.length && !matches; j++) {
      var answer = items[j].getResponse();
      var text = Array.isArray(answer) ? answer.join(',') : answer;
      if (normalizeEmail_(text) === target) matches = true;
    }
    if (matches) {
      form.deleteResponse(response.getId());
      deleted++;
    }
  }
  return deleted;
}

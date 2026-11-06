/**
 * Varyos Weld -- COMPLETE replacement for the whole Kod.gs of the Apps Script
 * project behind SignupConfig.presetApiUrl (and bound to the signup Form).
 * Paste this ONE file over everything in Kod.gs (delete the separate
 * delete_account file if you added it earlier: its code is included below).
 *
 * WHY: the /exec URL is public. Until 1.0 the client sent a bare email, so
 * anyone could read or delete anyone's presets. From 1.0.1 the client sends
 * a Firebase ID token (`idToken`) in the POST body; this file verifies it
 * with Google and derives the email from the VERIFIED token. A bare `email`
 * is ignored/rejected.
 *
 * ======================== DEPLOY STEPS (manager) ========================
 * 1. Firebase console > Project settings > General > "Web API Key" (public
 *    client identifier, not a secret).
 * 2. Apps Script > Project settings > Script properties: keep the existing
 *    RESEND_API_KEY and PRESETS_SHEET_ID, ADD FIREBASE_WEB_API_KEY = <key>.
 *    Never paste keys into code or commit them.
 * 3. Make a backup copy of the current Kod.gs (Ctrl+A, copy to a note).
 * 4. Replace the whole Kod.gs with this file. The editor will ask for the
 *    new "external request" permission (already granted for Resend) -- run
 *    testAuthenticateRequest_ once and approve.
 * 5. Deploy > Manage deployments > pencil on the EXISTING deployment >
 *    Version: New version > Deploy (do NOT create a new deployment).
 * 6. Verify with curl:
 *      curl -sL -X POST '<presetApiUrl>' -d '{"action":"listPresets","email":"a@b.co"}'
 *        -> {"ok":false,"error":"update_required"}      (old 1.0 clients)
 *      curl -sL -X POST '<presetApiUrl>' -d '{"action":"listPresets","idToken":"bad"}'
 *        -> {"ok":false,"error":"invalid_token"}
 *    Then in the 1.0.1 app (signed in + verified): save, list and delete a
 *    preset; an unverified account must get {"error":"email_not_verified"}.
 *
 * FUNCTION MAP (T = needs a verified Firebase ID token)
 *   doGet                  no auth; always {error:'update_required'} (old
 *                          1.0 clients listed presets via GET + bare email)
 *   doPost                 T for every action below (checked BEFORE the lock)
 *     action listPresets   T  reads this email's rows
 *     action save          T  upserts (email, preset.id)
 *     action delete        T  removes (email, presetId)
 *     action deleteAccount T  wipes signup rows + presets + Form responses
 *   authenticateRequest_   token check (JWT shape, size cap, cache, lookup)
 *   onFormSubmit           no auth; Form trigger (welcome mail)
 *   sendWelcomeEmail / buildWelcomeEmailHtml   no auth; Resend mail
 *   _getPresetsSheet, _jsonResponse, deletion helpers   internal
 *
 * RECOVERY NOTES (what was reconstructed): the repo never contained Kod.gs.
 * onFormSubmit, sendWelcomeEmail, _getPresetsSheet, _jsonResponse and the
 * deleteAccount block are the original code. doGet/doPostInner_ (list, save,
 * delete) were only partly recoverable and are REWRITTEN here from the
 * client contract (columns Email, PresetId, Name, DataJson,
 * UpdatedAtEpochMs). buildWelcomeEmailHtml's original body (old lines 41-86)
 * was NOT recoverable: a new English HTML is inlined below -- if you prefer
 * the old text, paste your backed-up function body over it.
 * NOTE: `listPresets` is now a POST so no token ever appears in a URL.
 * =======================================================================
 */

// ---------------------------------------------------------------- welcome

function onFormSubmit(e) {
  var email = '';
  var firstName = '';
  if (e && e.response) {
    var itemResponses = e.response.getItemResponses();
    for (var i = 0; i < itemResponses.length; i++) {
      var title = itemResponses[i].getItem().getTitle();
      if (title === 'E-posta' && !email) {
        email = itemResponses[i].getResponse();
      } else if (title === 'First name') {
        firstName = itemResponses[i].getResponse();
      }
    }
    if (!email && itemResponses.length > 0) {
      email = itemResponses[0].getResponse();
    }
  }
  email = (email || '').toString().trim();
  if (!email) return;
  sendWelcomeEmail(email, (firstName || '').toString().trim());
}

function sendWelcomeEmail(email, firstName) {
  var apiKey = PropertiesService.getScriptProperties().getProperty('RESEND_API_KEY');
  var html = buildWelcomeEmailHtml(firstName);
  var payload = {
    from: 'Varyos Weld <team@varyosweld.com>',
    to: [email],
    subject: 'Welcome to Varyos Weld!',
    html: html
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

// Replace with your previous body if you want the old text back.
function buildWelcomeEmailHtml(firstName) {
  var name = firstName ? escapeHtml_(firstName) : 'there';
  return '<div style="font-family:-apple-system,Helvetica,Arial,sans-serif;max-width:560px;margin:0 auto;color:#17303c;line-height:1.5">' +
    '<h2 style="color:#ff6a35">Welcome to Varyos Weld, ' + name + '!</h2>' +
    '<p>Everything for weld calculations in one place:</p>' +
    '<ul>' +
    '<li><b>Filler consumption</b> by joint type, groove and process.</li>' +
    '<li><b>Preheat (EN 1011-2)</b> from material, thickness and hydrogen level.</li>' +
    '<li><b>t8/5 cooling time</b> from 800 to 500 &deg;C.</li>' +
    '<li><b>Heat input</b> (kJ/mm) from current, voltage and travel speed.</li>' +
    '</ul>' +
    '<p>Open the <b>user guide</b> from the Account screen. <b>Premium</b> adds PDF reports and the AI assistant and follows your verified account.</p>' +
    '<p>Questions? Write to <a href="mailto:team@varyosweld.com">team@varyosweld.com</a>.</p>' +
    '<p>Happy welding,<br>The Varyos Weld team</p></div>';
}

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

function testAuthenticateRequest_() {
  Logger.log(JSON.stringify(authenticateRequest_({ email: 'a@b.co' })));
  Logger.log(JSON.stringify(authenticateRequest_({ idToken: 'bad' })));
  Logger.log(JSON.stringify(authenticateRequest_({ idToken: 'a.b.c' })));
}

// ---------------------------------------------------------------- account deletion

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

/**
 * Varyos Weld -- `deleteAccount` action for the existing Apps Script Web App.
 * Varyos Weld -- mevcut Apps Script Web App icin `deleteAccount` islemi.
 *
 * ======================== INSTRUCTIONS (EN) ========================
 * 1. Open the Apps Script project behind the Web App /exec URL
 *    (SignupConfig.presetApiUrl in lib/services/signup_config.dart).
 * 2. Add a new script file (+ > Script), name it delete_account, and paste
 *    this ENTIRE file into it. Do not edit the IDs below.
 * 3. In the existing doPost(e): wrap its whole body in the SAME lock this
 *    file uses, so a save/delete cannot interleave with an account deletion:
 *
 *      function doPost(e) {
 *        var lock = LockService.getScriptLock();
 *        if (!lock.tryLock(25000)) {
 *          return ContentService.createTextOutput(JSON.stringify(
 *            {ok: false, error: 'Server busy, please retry.'}))
 *            .setMimeType(ContentService.MimeType.JSON);
 *        }
 *        try {
 *          ... your existing code ...
 *        } finally {
 *          lock.releaseLock();
 *        }
 *      }
 *
 *    (Script locks are not re-entrant across callers, so handleDeleteAccount_
 *    below does NOT take the lock itself -- doPost must hold it.)
 * 4. Inside doPost, after the JSON body is parsed (variable shown as `data`;
 *    use your own name) and BEFORE the "unknown action" fallback, add:
 *
 *      if (data.action === 'deleteAccount') {
 *        return ContentService
 *          .createTextOutput(JSON.stringify(handleDeleteAccount_(data.email)))
 *          .setMimeType(ContentService.MimeType.JSON);
 *      }
 *
 * 5. In the editor run this once and approve the permission prompts
 *    (Spreadsheet + Forms access):
 *
 *      function testDeleteAccount() {
 *        Logger.log(JSON.stringify(handleDeleteAccount_('nobody@example.com')));
 *      }
 *
 *    Expected: {"ok":true,"deletedSheetRows":0,"deletedFormResponses":0}.
 *    If it says ok:false, read the error: a sheet/column/form was not found.
 * 6. Deploy > Manage deployments > pencil on the EXISTING deployment >
 *    Version: New version > Deploy. Do NOT create a new deployment (the
 *    /exec URL the app uses would change).
 * 7. Test with an email you signed up with:
 *      curl -sL -X POST '<presetApiUrl>' \
 *        -d '{"action":"deleteAccount","email":"you@example.com"}'
 *    Then confirm the email is gone from BOTH spreadsheets AND from the
 *    Google Form's Responses tab.
 *
 * ======================== TALIMATLAR (TR) ========================
 * 1. Web App /exec adresinin arkasindaki Apps Script projesini acin
 *    (lib/services/signup_config.dart icindeki presetApiUrl).
 * 2. Yeni bir dosya ekleyin (+ > Komut dosyasi), adi delete_account olsun ve
 *    bu dosyanin TAMAMINI yapistirin. Asagidaki ID'leri degistirmeyin.
 * 3. Mevcut doPost(e) fonksiyonunun TUM govdesini, bu dosyadaki ile ayni
 *    kilitle (LockService.getScriptLock) sarin; boylece kaydetme/silme
 *    islemleri hesap silme ile ic ice gecmez. Ornek yukaridaki (EN) 3.
 *    maddede. handleDeleteAccount_ kilidi KENDISI almaz; doPost tutmalidir.
 * 4. doPost icinde, JSON govde ayristirildiktan sonra ve "bilinmeyen islem"
 *    kosulundan ONCE, yukaridaki (EN) 4. maddedeki
 *    `if (data.action === 'deleteAccount') {...}` blogunu ekleyin
 *    (degisken adiniz `data` degilse kendi adinizi kullanin).
 * 5. Duzenleyicide testDeleteAccount fonksiyonunu bir kez calistirin ve
 *    istenen izinleri (Tablolar + Formlar) onaylayin. Beklenen sonuc:
 *    {"ok":true,"deletedSheetRows":0,"deletedFormResponses":0}.
 *    ok:false donerse hata mesajini okuyun (sayfa/sutun/form bulunamadi).
 * 6. Dagit > Dagitimlari yonet > MEVCUT dagitimin kalem simgesi > Surum:
 *    Yeni surum > Dagit. Yeni dagitim OLUSTURMAYIN (uygulamadaki /exec
 *    adresi degisir).
 * 7. Kayit oldugunuz bir e-posta ile curl testi yapin (yukaridaki EN 7) ve
 *    e-postanin IKI tablodan ve Google Form'un Yanitlar sekmesinden de
 *    silindigini kontrol edin.
 * ==================================================================
 *
 * WHAT IT DELETES (all matched case-insensitively on the trimmed email):
 *   - rows in sheet "Form Yanitlari 1" of the signup spreadsheet,
 *   - rows in sheet "Presets" of the presets spreadsheet,
 *   - the matching responses stored in the Google Form itself (deleting a
 *     sheet row does NOT remove the Form's own copy).
 * It returns {ok:false} -- never ok:true -- if either spreadsheet, either
 * sheet, either email column or the Form cannot be found/opened, or if
 * anything throws. "Found nothing to scan" is never reported as success.
 */

var DELETE_ACCOUNT_IDS = {
  SIGNUP_SPREADSHEET_ID: '11htQFYKQQh2DxKsLb6O66-9lNe7JtELYbrqqgElJf60',
  SIGNUP_SHEET_NAME: 'Form Yanıtları 1',
  PRESETS_SPREADSHEET_ID: '14U4zIJitFKBJhSZ3CbU2Df4EMSrW1PmtiDAoZRKcCTQ',
  PRESETS_SHEET_NAME: 'Presets',
  FORM_ID: '11u33WAjqnwWUWaDsmRlsZtIJTz0xpePrtTMWLkntFdk'
};

var DELETE_ACCOUNT_EMAIL_HEADER = /e-?mail|e-?posta/i;

/** Called from doPost (which must already hold the script lock). */
function handleDeleteAccount_(email) {
  var target = String(email || '').trim().toLowerCase();
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(target)) {
    return { ok: false, error: 'A valid email is required.' };
  }
  try {
    var ids = DELETE_ACCOUNT_IDS;
    var signupSheet = openSheetOrThrow_(
        ids.SIGNUP_SPREADSHEET_ID, ids.SIGNUP_SHEET_NAME);
    var presetsSheet = openSheetOrThrow_(
        ids.PRESETS_SPREADSHEET_ID, ids.PRESETS_SHEET_NAME);
    var form = FormApp.openById(ids.FORM_ID);

    var signupCol = findEmailColumnOrThrow_(signupSheet);
    var presetsCol = findEmailColumnOrThrow_(presetsSheet);

    var sheetRows = deleteRowsForEmail_(signupSheet, signupCol, target) +
        deleteRowsForEmail_(presetsSheet, presetsCol, target);
    var formResponses = deleteFormResponsesForEmail_(form, target);
    SpreadsheetApp.flush();
    return {
      ok: true,
      deletedSheetRows: sheetRows,
      deletedFormResponses: formResponses
    };
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

function normalizeEmail_(value) {
  return String(value).trim().toLowerCase();
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
    // Rows may have shifted/changed since the snapshot: confirm again.
    if (normalizeEmail_(sheet.getRange(row, emailCol).getValue()) !== target) {
      continue;
    }
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

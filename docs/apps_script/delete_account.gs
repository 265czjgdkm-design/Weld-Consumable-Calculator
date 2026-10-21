/**
 * Varyos Weld -- `deleteAccount` action for the existing Apps Script Web App.
 *
 * The Web App's own source (Kod.gs: doGet/doPost for listPresets/save/delete,
 * plus the welcome-email trigger) is NOT in any local repo, so this file is a
 * self-contained addition to paste into that same Apps Script project.
 *
 * WHAT IT DOES
 *   Given {"action":"deleteAccount","email":"user@example.com"} it removes,
 *   case-insensitively, every row for that email from
 *     1. the signup sheet (the Google Form's linked response sheet, i.e. the
 *        spreadsheet this script is bound to), and
 *     2. the presets sheet ("Varyos Weld - Presets" spreadsheet).
 *   and returns {"ok":true,"deletedRows":N}. On any problem it returns
 *   {"ok":false,"error":"..."} -- the app only shows "deleted" on ok:true.
 *
 * HOW ROWS ARE MATCHED
 *   For every sheet in those spreadsheets, a column counts as the email
 *   column if its header (row 1) contains "email" (case-insensitive), e.g.
 *   "Email", "Email Address", "email". A row is deleted when ANY such column
 *   equals the email (trimmed, lowercased). If a sheet has no such header,
 *   it is left alone and reported in the log -- set EMAIL_COLUMN_OVERRIDES
 *   below if your presets sheet uses a header without the word "email".
 *
 * PASTE INSTRUCTIONS: see the bottom of this file.
 */

var DELETE_ACCOUNT_CONFIG = {
  // Name of the presets spreadsheet (created lazily by the existing script).
  PRESETS_SPREADSHEET_NAME: 'Varyos Weld - Presets',
  // Optional: {'<sheet name>': <1-based column index>} to force the email
  // column for a sheet whose header does not contain "email".
  EMAIL_COLUMN_OVERRIDES: {}
};

/** Entry point called from doPost. Always returns a plain object. */
function handleDeleteAccount_(email) {
  var target = String(email || '').trim().toLowerCase();
  if (!target || target.indexOf('@') < 1) {
    return { ok: false, error: 'A valid email is required.' };
  }

  // Serialise against the existing save/delete handlers' writes.
  var lock = LockService.getScriptLock();
  if (!lock.tryLock(20000)) {
    return { ok: false, error: 'Server busy, please retry.' };
  }
  try {
    var deleted = 0;
    var spreadsheets = [];

    var bound = SpreadsheetApp.getActiveSpreadsheet();
    if (bound) spreadsheets.push(bound);

    var files = DriveApp.getFilesByName(
      DELETE_ACCOUNT_CONFIG.PRESETS_SPREADSHEET_NAME);
    while (files.hasNext()) {
      var presets = SpreadsheetApp.open(files.next());
      var alreadyListed = bound && presets.getId() === bound.getId();
      if (!alreadyListed) spreadsheets.push(presets);
    }

    for (var i = 0; i < spreadsheets.length; i++) {
      var sheets = spreadsheets[i].getSheets();
      for (var j = 0; j < sheets.length; j++) {
        deleted += deleteRowsForEmail_(sheets[j], target);
      }
    }
    SpreadsheetApp.flush();
    return { ok: true, deletedRows: deleted };
  } catch (err) {
    return { ok: false, error: String(err && err.message || err) };
  } finally {
    lock.releaseLock();
  }
}

/** Deletes matching rows (bottom-up) in one sheet; returns how many. */
function deleteRowsForEmail_(sheet, target) {
  var lastRow = sheet.getLastRow();
  var lastCol = sheet.getLastColumn();
  if (lastRow < 2 || lastCol < 1) return 0;

  var emailCols = [];
  var override = DELETE_ACCOUNT_CONFIG.EMAIL_COLUMN_OVERRIDES[sheet.getName()];
  if (override) {
    emailCols.push(override - 1);
  } else {
    var headers = sheet.getRange(1, 1, 1, lastCol).getValues()[0];
    for (var c = 0; c < headers.length; c++) {
      if (String(headers[c]).toLowerCase().indexOf('email') !== -1) {
        emailCols.push(c);
      }
    }
  }
  if (emailCols.length === 0) {
    console.log('deleteAccount: no email column in sheet "' +
        sheet.getName() + '", skipped.');
    return 0;
  }

  // Values are compared as strings: Sheets may coerce cells to other types
  // (the same coercion class that once made preset deletes silently no-op).
  var values = sheet.getRange(2, 1, lastRow - 1, lastCol).getValues();
  var deleted = 0;
  for (var r = values.length - 1; r >= 0; r--) {
    for (var k = 0; k < emailCols.length; k++) {
      var cell = String(values[r][emailCols[k]]).trim().toLowerCase();
      if (cell === target) {
        sheet.deleteRow(r + 2);
        deleted++;
        break;
      }
    }
  }
  return deleted;
}

/*
 * ===================== PASTE INSTRUCTIONS =====================
 * 1. Open the Apps Script project that backs the Web App (the one whose
 *    /exec URL is SignupConfig.presetApiUrl in lib/services/signup_config.dart;
 *    script.google.com -> the project bound to the signup Google Sheet, or
 *    Extensions -> Apps Script from that sheet).
 * 2. Add a new file (+ -> Script), name it delete_account, paste this whole
 *    file in.
 * 3. In the existing doPost(e), after the JSON body is parsed (variable name
 *    may differ; here it is `data`) and BEFORE the "unknown action" fallback,
 *    add:
 *
 *      if (data.action === 'deleteAccount') {
 *        return ContentService
 *          .createTextOutput(JSON.stringify(handleDeleteAccount_(data.email)))
 *          .setMimeType(ContentService.MimeType.JSON);
 *      }
 *
 *    (Match however the existing handlers build their JSON response -- the
 *    app only requires a JSON body with "ok": true on success.)
 * 4. Run handleDeleteAccount_ once manually from the editor (e.g. via a
 *    throwaway wrapper: function t(){ Logger.log(handleDeleteAccount_(
 *    'nobody@example.com')); }) and approve the new Drive permission prompt
 *    (DriveApp is used to find the presets spreadsheet by name). Expect
 *    {"ok":true,"deletedRows":0}.
 * 5. Deploy -> Manage deployments -> edit the EXISTING deployment -> Version:
 *    New version -> Deploy. Do NOT create a new deployment: that would change
 *    the /exec URL the app is hard-coded to.
 * 6. Verify end to end with a test email you signed up with:
 *      curl -sL -X POST '<presetApiUrl>' \
 *        -d '{"action":"deleteAccount","email":"you@example.com"}'
 *    -> {"ok":true,"deletedRows":N}; check the sheets no longer contain it.
 *    Until step 5 is done, the app's Delete Account shows the failure +
 *    Retry dialog (an old script answers ok:false / unknown action).
 * ==============================================================
 */

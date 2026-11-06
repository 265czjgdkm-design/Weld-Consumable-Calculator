/**
 * Varyos Weld -- server-side identity check for the preset / account API.
 *
 * WHY: the /exec URL is public. Until now the client sent a bare email, so
 * anyone could read or delete anyone's presets. From 1.0.1 the client sends
 * a Firebase ID token (`idToken`); this file verifies it with Google and
 * derives the email from the VERIFIED token. A bare `email` is rejected.
 *
 * ======================== DEPLOY STEPS (manager) ========================
 * 1. Firebase console > Project settings > General > "Web API Key" (it is a
 *    public client identifier, not a secret). If there is no Web app yet,
 *    add one (Project settings > Your apps > </>) or read the key from the
 *    Authentication settings.
 * 2. Apps Script project behind SignupConfig.presetApiUrl > Project settings
 *    > Script properties > Add: FIREBASE_WEB_API_KEY = <that key>.
 *    (Never paste it into code or commit it.)
 * 3. Add a script file named Kod_auth and paste this ENTIRE file.
 * 4. In the existing doGet(e), at the very top (before reading e.parameter
 *    for the email), add:
 *
 *      var authGet = authenticateRequest_(e.parameter);
 *      if (!authGet.ok) { return jsonOut_(authGet); }
 *      e.parameter.email = authGet.email;   // verified, lowercased
 *
 * 5. In the existing doPost(e), inside the lock, right after the JSON body is
 *    parsed (variable `data`), add BEFORE any action handling:
 *
 *      var authPost = authenticateRequest_(data);
 *      if (!authPost.ok) { return jsonOut_(authPost); }
 *      data.email = authPost.email;         // verified, lowercased
 *
 *    The existing save / delete / deleteAccount / listPresets code keeps using
 *    `email` unchanged -- it is now trustworthy. Make sure NO code path reads
 *    an email that did not come from this step.
 * 6. Run testAuthenticateRequest_ once in the editor and approve the
 *    "external service" (UrlFetchApp) permission.
 * 7. Deploy > Manage deployments > pencil on the EXISTING deployment >
 *    Version: New version > Deploy (do NOT create a new deployment).
 * 8. Verify with curl:
 *      curl -sL -X POST '<presetApiUrl>' -d '{"action":"deleteAccount","email":"a@b.co"}'
 *        -> {"ok":false,"error":"update_required"}      (old 1.0 clients)
 *      curl -sL -X POST '<presetApiUrl>' -d '{"action":"deleteAccount","idToken":"bad"}'
 *        -> {"ok":false,"error":"invalid_token"}
 *    Then check in the 1.0.1 app (signed in, verified) that saving a preset
 *    and listing it works, and that an unverified account is refused
 *    ({"error":"email_not_verified"}).
 *
 * NOTE: `listPresets` is a GET, so its short-lived (1 h) ID token travels in
 * the query string. Acceptable for a short-lived token; move listPresets to
 * POST later if you want it out of URLs.
 * =======================================================================
 */

function jsonOut_(obj) {
  return ContentService.createTextOutput(JSON.stringify(obj)).setMimeType(
    ContentService.MimeType.JSON
  );
}

/**
 * @param {Object} params parsed request (GET e.parameter or POST body).
 * @return {{ok:true,email:string,uid:string}|{ok:false,error:string}}
 */
function authenticateRequest_(params) {
  var idToken = params && params.idToken;
  if (!idToken) {
    // Old 1.0 clients send a bare email; they must update.
    return { ok: false, error: 'update_required' };
  }
  var apiKey = PropertiesService.getScriptProperties().getProperty(
    'FIREBASE_WEB_API_KEY'
  );
  if (!apiKey) {
    return { ok: false, error: 'server_misconfigured' };
  }
  var response;
  try {
    response = UrlFetchApp.fetch(
      'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=' +
        encodeURIComponent(apiKey),
      {
        method: 'post',
        contentType: 'application/json',
        payload: JSON.stringify({ idToken: String(idToken) }),
        muteHttpExceptions: true,
      }
    );
  } catch (err) {
    return { ok: false, error: 'auth_unavailable' };
  }
  if (response.getResponseCode() !== 200) {
    return { ok: false, error: 'invalid_token' };
  }
  var body;
  try {
    body = JSON.parse(response.getContentText());
  } catch (err) {
    return { ok: false, error: 'invalid_token' };
  }
  var user = body && body.users && body.users[0];
  if (!user || !user.email) {
    return { ok: false, error: 'invalid_token' };
  }
  if (user.emailVerified !== true) {
    return { ok: false, error: 'email_not_verified' };
  }
  return {
    ok: true,
    email: String(user.email).trim().toLowerCase(),
    uid: user.localId,
  };
}

function testAuthenticateRequest_() {
  Logger.log(JSON.stringify(authenticateRequest_({ email: 'a@b.co' })));
  Logger.log(JSON.stringify(authenticateRequest_({ idToken: 'bad' })));
}

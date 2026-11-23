# Apps Script deploy (1.0.1+ auth server)

Project: script.google.com > "Adsız proje" (only file: `Kod.gs`), script id
in `scripts/deploy_apps_script.sh`. Live web app: deployment "Adsız" (URL =
`SignupConfig.presetApiUrl`, must never change). Rollback target: **version 4**
(21 Oct 2026). Trigger: `onFormSubmit` (form submit, Head).

Updated 2026-11-23: `Kod_auth.gs` verifies Firebase ID tokens itself (Google
securetoken JWKs, RS256, aud/iss `varyos-weld`, exp, email_verified). No
`FIREBASE_WEB_API_KEY` property is needed any more. Keep `RESEND_API_KEY` and
`PRESETS_SHEET_ID` as they are.

## English

0. **One-time (human)**: `clasp login` (browser > Allow);
   https://script.google.com/home/usersettings > Google Apps Script API: On;
   editor > select `testAuthenticateRequest` > Run > Allow (script scopes).
   Expected log: `update_required`, `invalid_token`, `invalid_token`.
1. **Deploy (CLI, preferred)**: `scripts/deploy_apps_script.sh`
   - pulls the project to `~/.config/varyos/apps_script_weld`, keeps the
     manifest (forces webapp `USER_DEPLOYING` / `ANYONE_ANONYMOUS`), pushes
     `Kod_auth.gs` as `Kod`, redeploys the SAME deployment with a new version,
     runs the two curl checks and rolls back to v4 automatically if they fail.
   - Manual rollback: `scripts/deploy_apps_script.sh --rollback`.
2. **Deploy (editor, fallback)**: paste `Kod_auth.gs` into `Kod.gs` > Save >
   Deploy > Manage deployments > "Adsız" > pencil > Version: **New version** >
   Deploy. Never "New deployment" (new URL).
3. **Test**:
   - `curl -sL '<presetApiUrl>?action=listPresets&email=a@b.co'`
     -> `{"ok":false,"error":"update_required"}`
   - `curl -sL -H 'Content-Type: text/plain' '<presetApiUrl>' -d '{"action":"listPresets","idToken":"bad"}'`
     -> `{"ok":false,"error":"invalid_token"}` (do not use `-X POST` with
     `-L`: the redirect must become a GET)
   - App, verified account: save, list, rename, delete a preset. Unverified
     account: cloud sync asks to verify. Signup form test: welcome mail arrives.
4. **Rollback (editor)**: Manage deployments > "Adsız" > pencil > Version: **4**
   > Deploy. Trigger code: Project history > Version 4 > restore (or paste the
   local backup `live_backup_2026-11-07/Kod.gs`, not in git).

## Türkçe (basit)

0. **Tek seferlik (insan)**: `clasp login` (tarayıcıda İzin ver);
   script.google.com/home/usersettings > Google Apps Script API: Açık;
   düzenleyicide `testAuthenticateRequest` > Çalıştır > İzin ver.
1. **Yayınla**: `scripts/deploy_apps_script.sh` (aynı URL'ye yeni sürüm,
   curl testleri, başarısızsa otomatik sürüm 4'e dönüş).
   Elle geri dönüş: `scripts/deploy_apps_script.sh --rollback`.
2. **Düzenleyiciden (yedek yol)**: Dağıt > Dağıtımları yönet > "Adsız" >
   kalem > Sürüm: **Yeni sürüm** > Dağıt. "Yeni dağıtım" KULLANMA.
3. **Test**: yukarıdaki iki curl; uygulamada hazır ayar kaydet/listele/sil;
   kayıt formu test maili.
4. **Geri al**: aynı ekranda Sürüm: **4** > Dağıt.

## Later (not done, server side)

- Google Form: add short-answer questions "First name" and "Locale" (not
  required), put their `entry.NNN` ids in `SignupConfig.firstNameEntryField`
  / `localeEntryField`. `Kod_auth.gs` already reads those titles and sends the
  localized template (en fallback); until then the original mail is sent.
- Privacy policy: Firebase Authentication (Google) as processor; first name
  stored (Form/Sheet); RevenueCat app user id = Firebase uid; Firebase sends
  verification and password-reset emails; account deletion now also deletes
  the Firebase user (plus Sheet rows and Form responses).
- Optional hardening: the Sheet/Form IDs in `DELETE_ACCOUNT_IDS` are already
  public in git history (access still needs the owner's Google login); they
  could move to script properties later.

# Apps Script deploy for 1.0.1

Project: script.google.com > "Adsız proje" (only file: `Kod.gs`).
Live web app: deployment "Adsız", **version 4** (21 Oct 2026), URL =
`SignupConfig.presetApiUrl`. Trigger: `onFormSubmit` (form submit, Head).

Do this **when 1.0.1 is approved / about to go live** (after deploy, the 1.0
app's cloud sync stops: it shows "update" style errors and keeps data on the
phone; see the header of `Kod_auth.gs`).

## English

1. **Backup**: a verbatim copy of the live code is in
   `docs/apps_script/live_backup_2026-11-07/Kod.gs` (local, not in git).
   Version 4 also stays in Apps Script itself.
2. **Key**: Firebase console > varyos-weld > Project settings > General >
   copy "Web API Key". Apps Script > Project Settings (gear) > Script
   Properties > Add > name `FIREBASE_WEB_API_KEY`, value = that key > Save.
   Keep `RESEND_API_KEY` and `PRESETS_SHEET_ID` as they are.
3. **Paste**: Editor > `Kod.gs` > select all > paste the whole
   `docs/apps_script/Kod_auth.gs` > Save (Cmd+S).
   Note: the form trigger uses the saved code right away (welcome mail stays
   the same English mail); the app API does not change until step 5.
4. **Editor test**: choose `testWelcomeEmail` > Run (approve permissions if
   asked) > log shows 5 lines, no mail is sent. Then `testAuthenticateRequest`
   > Run > log shows `update_required`, `invalid_token`, `invalid_token`.
   `server_misconfigured` means the key in step 2 is missing or wrong.
5. **Deploy, same URL**: Deploy > Manage deployments > select "Adsız"
   (active) > pencil > Version: **New version** > Deploy.
   Do NOT use "New deployment" (that makes a new URL).
6. **Test**:
   - Terminal: `curl -sL '<presetApiUrl>?action=listPresets&email=a@b.co'`
     -> `{"ok":false,"error":"update_required"}`
   - `curl -sL -X POST '<presetApiUrl>' -d '{"action":"listPresets","idToken":"bad"}'`
     -> `{"ok":false,"error":"invalid_token"}`
   - 1.0.1 app, verified account: save, list, rename, delete a preset.
     Unverified account: cloud sync asks to verify.
   - Submit the signup Form once with a test email: welcome mail arrives.
7. **Rollback** (if something breaks): Deploy > Manage deployments >
   "Adsız" > pencil > Version: **4** > Deploy. For the trigger code also:
   Project history > "Version 4" > restore (or paste the backup `Kod.gs`)
   > Save.

## Türkçe (basit)

1. **Yedek**: Canlı kodun birebir kopyası
   `docs/apps_script/live_backup_2026-11-07/Kod.gs` içinde (sadece bilgisayarda,
   git'te yok). Sürüm 4 Apps Script içinde de duruyor.
2. **Anahtar**: Firebase konsolu > varyos-weld > Proje ayarları > Genel >
   "Web API Key" değerini kopyala. Apps Script > Proje Ayarları (çark) >
   Komut Dosyası Özellikleri > Ekle > ad `FIREBASE_WEB_API_KEY`, değer = bu
   anahtar > Kaydet. `RESEND_API_KEY` ve `PRESETS_SHEET_ID`'ye dokunma.
3. **Yapıştır**: Düzenleyici > `Kod.gs` > hepsini seç > `Kod_auth.gs`
   dosyasının tamamını yapıştır > Kaydet (Cmd+S).
   Not: form tetikleyicisi kaydedilen kodu hemen kullanır (hoş geldin maili
   aynı İngilizce mail kalır); uygulama API'si 5. adıma kadar değişmez.
4. **Düzenleyicide test**: `testWelcomeEmail` seç > Çalıştır (izin isterse
   onayla) > günlükte 5 satır çıkar, mail gitmez. Sonra
   `testAuthenticateRequest` > Çalıştır > `update_required`, `invalid_token`,
   `invalid_token` görünmeli. `server_misconfigured` çıkarsa 2. adımdaki
   anahtar eksik/yanlış.
5. **Dağıt, aynı URL**: Dağıt > Dağıtımları yönet > "Adsız" (etkin) seç >
   kalem > Sürüm: **Yeni sürüm** > Dağıt.
   "Yeni dağıtım" KULLANMA (yeni URL oluşturur).
6. **Test et**:
   - Terminal: `curl -sL '<presetApiUrl>?action=listPresets&email=a@b.co'`
     -> `{"ok":false,"error":"update_required"}`
   - `curl -sL -X POST '<presetApiUrl>' -d '{"action":"listPresets","idToken":"bad"}'`
     -> `{"ok":false,"error":"invalid_token"}`
   - 1.0.1 uygulama, doğrulanmış hesap: hazır ayar kaydet, listele, adını
     değiştir, sil. Doğrulanmamış hesap: doğrulama ister.
   - Kayıt formunu bir test mailiyle bir kez gönder: hoş geldin maili gelmeli.
7. **Geri al** (sorun olursa): Dağıt > Dağıtımları yönet > "Adsız" > kalem >
   Sürüm: **4** > Dağıt. Tetikleyici kodu için de: Proje geçmişi >
   "Sürüm 4" > geri yükle (veya yedek `Kod.gs`'yi yapıştır) > Kaydet.

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

# Firebase Auth setup (manual steps)

1.0.1 offers first-party email/password accounts only (no Sign in with Apple,
so Apple guideline 4.8 does not apply and no Apple token revocation is needed
for account deletion).

The app compiles and runs without Firebase config: accounts are then
unavailable (guest only, presets stay on the device).

1. Firebase console (project `varyos-weld`, Spark): Email/Password provider
   enabled; add the iOS app with bundle id
   `com.muhammetyigit.weldConsumableCalculator`; download
   `GoogleService-Info.plist` to `ios/Runner/GoogleService-Info.plist`
   (git-ignored; an Xcode build phase copies it into the app).
2. Authentication > Templates: set the verification / password-reset mail
   language and sender name.
3. Deploy the server-side token check: see the header of
   `docs/apps_script/Kod_auth.gs` (a complete replacement for the whole Kod.gs; it also contains the old delete_account code, which is removed from the repo). Until it is deployed, cloud sync from the
   1.0.1 client fails (presets stay local) and old 1.0 clients keep working.

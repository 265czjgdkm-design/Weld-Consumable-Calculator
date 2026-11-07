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
3. Deploy the server-side token check: follow
   `docs/apps_script/DEPLOY_STEPS_1.0.1.md` (paste `docs/apps_script/Kod_auth.gs`
   over the live `Kod.gs`, add the `FIREBASE_WEB_API_KEY` script property,
   new version on the SAME deployment). Until it is deployed, cloud sync from
   the 1.0.1 client fails (presets stay local) and old 1.0 clients keep
   working; after it, 1.0 clients get `update_required` (handled as a normal
   sync failure, no crash).

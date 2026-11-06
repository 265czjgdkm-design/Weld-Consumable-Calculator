# Firebase Auth setup (manual steps)

The app compiles and runs without Firebase config: sign-in is then disabled
(`createAuthService` returns the unavailable service). To enable it:

1. Firebase console (Spark plan): create the project, add the iOS app with the
   bundle id `com.muhammetyigit.weldConsumableCalculator`, download
   `GoogleService-Info.plist` to `ios/Runner/GoogleService-Info.plist`
   (git-ignored; an Xcode build phase copies it into the app).
2. Authentication > Sign-in method: enable Email/Password and Apple. For
   Apple on iOS no service id / key is needed.
3. Authentication > Templates: set the verification and password-reset mail
   language / sender name; add `varyosweld.com` as an authorized domain if
   custom links are used.
4. Apple Developer > Identifiers > the App ID: enable the "Sign in with Apple"
   capability, then regenerate the provisioning profile (Xcode automatic
   signing does this). `Runner.entitlements` is already wired in.

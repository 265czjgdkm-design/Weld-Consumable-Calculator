# App Store Submission Guide — Varyos Weld (iOS)

Prepared 2026-10-21. Steps only the account owner can do; code-side items are already in the repo.

## 1. Apple Developer / App Store Connect (one time)
1. developer.apple.com → Certificates, IDs & Profiles → Identifiers → register App ID
   `com.muhammetyigit.weldConsumableCalculator` (cannot change after the app record exists).
2. App Store Connect → Business: accept the **Paid Applications Agreement**, add bank account and
   tax form (W-8BEN, Türkiye). Subscriptions cannot be sold until this is "Active".
3. App Store Connect → Apps → **+ New App**: platform iOS, name "Varyos Weld", primary language
   English (add Turkish localization), bundle ID above, SKU `varyosweld-ios-1`.
4. Xcode → Runner target → Signing & Capabilities → select your Team (sets `DEVELOPMENT_TEAM`),
   add the **In-App Purchase** capability.

## 2. Subscriptions
App Store Connect → the app → Subscriptions → create group "Varyos Premium":

| Reference name | Product ID | Duration | Suggested price |
|---|---|---|---|
| Premium Monthly | `varyos_premium_monthly` | 1 month | Tier ≈ $2.99 |
| Premium Yearly  | `varyos_premium_yearly`  | 1 year  | Tier ≈ $19.99 |

For each: display name + description (EN/TR), a review screenshot of the paywall, and review notes.
The app reads the real localized price from the store, so prices can be changed here freely.

## 3. RevenueCat
1. app.revenuecat.com → new project → add App Store app (bundle ID above), upload the
   App Store Connect **In-App Purchase key** (.p8) for receipt validation.
2. Products: import both product IDs. Entitlement: `premium` → attach both products.
3. Offerings: `default` (set as Current) with packages `varyos_premium_monthly` and
   `varyos_premium_yearly` (custom package identifiers, matching `lib/services/purchases_config.dart`).
4. Project Settings → API Keys → copy the **Apple public key (`appl_…`)** into
   `lib/services/purchases_config.dart` → `appleApiKey`. Test a sandbox purchase on a device.

## 4. App Information
- **Category:** Primary *Utilities*, secondary *Productivity* (alt: Reference).
- **Privacy Policy URL:** https://varyosweld.com/privacy.html
- **Support URL:** https://varyosweld.com  (needs a working contact: team@varyosweld.com must receive mail)
- **Terms / EULA:** leave Apple's Standard EULA; add to the description:
  `Terms of Use: https://varyosweld.com/terms.html` and
  `EULA: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/`
- **Copyright:** `2026 Muhammet Yiğit`
- **Availability:** all storefronts **except the 27 EU countries** (user decision 2026-10-18: no DSA trader
  status for now). Pricing and Availability → Edit → deselect EU countries.
- **Devices:** iPhone only (iPad disabled in the project), so only 6.9" (or 6.5") iPhone screenshots are required.

## 5. App Privacy (nutrition label)
"Do you or your third-party partners collect data?" → **Yes**. Tracking → **No** for every type.

| Data type | Collected | Use | Linked to identity |
|---|---|---|---|
| Contact Info → Email Address | Yes | App Functionality; Developer's Advertising or Marketing (launch/product emails) | Yes |
| User Content → Other User Content (synced presets, AI chat text) | Yes | App Functionality | Yes |
| Identifiers → Device ID (random AI rate-limit ID) | Yes | App Functionality | No |
| Purchases → Purchase History (RevenueCat) | Yes | App Functionality | No |
| Name, Location, Diagnostics, Usage Data, everything else | No | — | — |

Name is NOT collected (kept on device only).

## 6. Age Rating (questionnaire)
All content categories: **None**. Unrestricted Web Access: No. User-generated content / messaging
between users: No (the AI chat is not user-to-user). Advertising: No. Result: **4+**.
(Optionally choose 13+ manually because of the free-text AI assistant.)

## 7. Export Compliance
Already answered in Info.plist (`ITSAppUsesNonExemptEncryption = false`, HTTPS only) — no prompt per build.

## 8. App Review notes (paste into "Notes")
```
Varyos Weld is a welding engineering calculator (filler consumption, EN 1011-2 preheat via CET,
and t8/5 cooling time). No login is required: tap "Continue as guest" on the first screen.
Registration (email) is optional and only enables preset sync; in-app account deletion is on
Home > Account card > Delete Account.

Premium (auto-renewable, monthly/yearly) unlocks PDF report export and the AI assistant.
Please use a Sandbox account to test the purchase; Restore Purchases is on the paywall.

AI assistant: before first use the app shows a consent screen naming the provider
(Cloudflare Workers AI, Meta Llama 3.3 70B) and what is sent; nothing is sent unless the user taps
"Agree & continue". The assistant only answers questions about the app's own calculators and
refuses unrelated requests. Consent can be withdrawn on the Account screen.
```

## 9. Store listing text (EN)
**Subtitle (30):** `Weld filler, preheat & t8/5`
**Keywords (100):** `welding,weld,filler,electrode,preheat,CET,t8/5,EN 1011-2,GTAW,SMAW,GMAW,FCAW,consumable,WPS,engineer`
**Description:**
```
Varyos Weld is a fast, offline-first calculator for welding engineers, inspectors and fabricators.

• Filler / consumable calculator — weld metal mass, filler needed and arc time from joint geometry
  (single/double/compound V, half V, square, fillet; pipe or plate) for GTAW, SMAW, GTAW+SMAW,
  GMAW and FCAW, with technical cross-section drawings.
• Preheat calculator — EN 1011-2 (Method B) carbon equivalent CET and recommended minimum preheat.
• Cooling time calculator — EN 1011-2 t8/5 from heat input or arc parameters, 2D/3D.
• Saved presets, custom filler and base materials, optional cloud sync.
• Premium: branded PDF reports and an AI assistant that explains the calculators' fields and results.

Results are estimates for planning and do not replace an approved WPS or a qualified engineer.

Premium is an auto-renewable subscription (monthly or yearly). Payment is charged to your Apple ID
at confirmation; it renews unless cancelled at least 24 hours before the period ends. Manage it in
your Apple ID settings.
Terms of Use: https://varyosweld.com/terms.html
Privacy Policy: https://varyosweld.com/privacy.html
EULA: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
```

## 10. Build & upload
```
flutter build ipa --release
open build/ios/archive/Runner.xcarchive   # Xcode Organizer → Distribute App → App Store Connect
```
Then in App Store Connect: select the build, attach both subscriptions to the version
("In-App Purchases and Subscriptions" section), add screenshots, submit for review.

## 11. Pre-submit checklist
- [ ] Real RevenueCat `appl_` key in `purchases_config.dart`; sandbox purchase + restore tested
- [ ] Apps Script `deleteAccount` action deployed (see `docs/apps_script/`), in-app delete tested
- [ ] In-app delete confirmed on a physical iPhone (check both sheets and Form responses)
- [ ] team@varyosweld.com receives mail (Squarespace → Domains → Email forwarding → Gmail)
- [ ] Landing repo pushed so varyosweld.com/privacy.html and /terms.html show the 2026-10-21 version
- [ ] Worker redeployed (`cd ~/Documents/Projects/worker && npx wrangler deploy`)
- [ ] Screenshots (iPhone 6.9"), app icon, review notes, privacy label, age rating, EU excluded

#!/bin/zsh
# Build the store archive and upload it to App Store Connect (TestFlight)
# using an App Store Connect API key, with no Xcode Apple Account needed.
#
# One-time setup (outside the repo, never committed):
#   ~/.appstoreconnect/private_keys/AuthKey_<KEY_ID>.p8   (downloaded from ASC)
#   ~/.appstoreconnect/asc_api.env containing:
#       ASC_KEY_ID=XXXXXXXXXX
#       ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
#
# Usage: scripts/upload_testflight.sh            (build + upload)
#        scripts/upload_testflight.sh --no-build (upload existing archive)
set -euo pipefail
cd "$(dirname "$0")/.."

ENV_FILE="$HOME/.appstoreconnect/asc_api.env"
[[ -f "$ENV_FILE" ]] || { echo "Missing $ENV_FILE"; exit 1; }
source "$ENV_FILE"
KEY_PATH="$HOME/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8"
[[ -f "$KEY_PATH" ]] || { echo "Missing $KEY_PATH"; exit 1; }

if [[ "${1:-}" != "--no-build" ]]; then
  # Store build: never pass TESTER_PREMIUM here.
  flutter build ipa --release || true   # export step fails without an Xcode account; archive is what we need
fi

ARCHIVE="build/ios/archive/Runner.xcarchive"
[[ -d "$ARCHIVE" ]] || { echo "No archive at $ARCHIVE"; exit 1; }
/usr/libexec/PlistBuddy -c "Print :ApplicationProperties:CFBundleShortVersionString" \
  -c "Print :ApplicationProperties:CFBundleVersion" "$ARCHIVE/Info.plist"

# Signing: dedicated CI keychain + manual App Store profile (no Xcode account,
# no Mac password). Setup lives in ~/.appstoreconnect/signing (see agent baglanti-sorumlusu).
SIGN_DIR="$HOME/.appstoreconnect/signing"
source "$SIGN_DIR/kc.env"
security unlock-keychain -p "$KC_PASS" "$SIGN_DIR/varyos-ci.keychain-db"

rm -rf build/ios/ipa_local
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE" \
  -exportOptionsPlist "$SIGN_DIR/weld_export.plist" \
  -exportPath "build/ios/ipa_local"

IPA="$(ls build/ios/ipa_local/*.ipa | head -1)"
xcrun altool --upload-app -f "$IPA" -t ios --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"

echo "Uploaded. TestFlight processing takes ~10-30 min."

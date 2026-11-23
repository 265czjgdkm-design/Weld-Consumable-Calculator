#!/bin/bash
# Deploys docs/apps_script/Kod_auth.gs to the live "Adsız" web app deployment
# as a NEW VERSION of the SAME deployment (URL unchanged), then verifies with
# curl and rolls back to version 4 if the checks fail.
#
# One-time prerequisites (human):
#   1. `clasp login` (browser > Allow)                      -> ~/.clasprc.json
#   2. https://script.google.com/home/usersettings > Google Apps Script API: On
#   3. Editor: run testAuthenticateRequest once > Allow (script scopes consent)
#
# Usage: scripts/deploy_apps_script.sh [--rollback]
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_ID="1lMnGm-f1PPttDWfrn7cJf9zJSTZr7Wgu-l9kU5q4c_3HAmTP49EzOeZ2"
ROLLBACK_VERSION=4
WORK="$HOME/.config/varyos/apps_script_weld"
SRC="$REPO/docs/apps_script/Kod_auth.gs"

URL="$(grep -A1 'presetApiUrl =' "$REPO/lib/services/signup_config.dart" | grep -oE "https://script.google.com/macros/s/[A-Za-z0-9_-]+/exec")"
DEP_ID="$(echo "$URL" | sed -E 's#.*/macros/s/([^/]+)/exec#\1#')"
[ -n "$DEP_ID" ] || { echo "deployment id not found"; exit 1; }

clasp show-authorized-user >/dev/null 2>&1 || { echo "NOT LOGGED IN: run 'clasp login'"; exit 2; }

if [ "${1:-}" = "--rollback" ]; then
  mkdir -p "$WORK"; cd "$WORK"
  [ -f .clasp.json ] || clasp clone "$SCRIPT_ID" >/dev/null
  clasp redeploy "$DEP_ID" -V "$ROLLBACK_VERSION" -d "rollback to v$ROLLBACK_VERSION"
  exit 0
fi

mkdir -p "$WORK"; cd "$WORK"
if [ -f .clasp.json ]; then clasp pull >/dev/null; else clasp clone "$SCRIPT_ID" >/dev/null; fi

echo "== deployments"; clasp deployments | sed -E "s/$DEP_ID/<LIVE>/"
clasp deployments | grep -q "$DEP_ID" || { echo "live deployment not in this project"; exit 1; }

# Manifest: keep scopes/runtime, make sure the web app section matches live.
python3 -I - appsscript.json <<'PY'
import json, sys
p = sys.argv[1]; m = json.load(open(p))
want = {"executeAs": "USER_DEPLOYING", "access": "ANYONE_ANONYMOUS"}
if m.get("webapp") != want:
    print("manifest webapp was", m.get("webapp"), "-> set", want)
    m["webapp"] = want
    json.dump(m, open(p, "w"), indent=2)
print("runtime:", m.get("runtimeVersion"), "scopes:", m.get("oauthScopes", "(auto)"))
PY

CODE_FILE="$(ls Kod.js Kod.gs 2>/dev/null | head -1)"; CODE_FILE="${CODE_FILE:-Kod.js}"
cp "$SRC" "$CODE_FILE"
clasp push --force

echo "== deploy new version to same deployment"
clasp deploy -i "$DEP_ID" -d "Firebase ID token auth (Kod_auth.gs)" | sed -E "s/$DEP_ID/<LIVE>/"

sleep 5
G="$(curl -sL "$URL?action=listPresets&email=a@b.co")"
P="$(curl -sL -H 'Content-Type: text/plain' "$URL" -d '{"action":"listPresets","idToken":"bad"}')"
echo "GET  -> $G"; echo "POST -> $P"
if [ "$G" = '{"ok":false,"error":"update_required"}' ] && [ "$P" = '{"ok":false,"error":"invalid_token"}' ]; then
  echo "OK: deployed and verified"
else
  echo "CHECK FAILED -> rolling back to v$ROLLBACK_VERSION"
  clasp redeploy "$DEP_ID" -V "$ROLLBACK_VERSION" -d "rollback to v$ROLLBACK_VERSION" | sed -E "s/$DEP_ID/<LIVE>/"
  exit 3
fi

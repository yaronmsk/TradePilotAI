#!/usr/bin/env bash
set -euo pipefail

OUT="${1:-/tmp/tradepilot-macos-ca-bundle.pem}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "ERROR: macOS Keychain CA export is only supported on macOS." >&2
  exit 1
fi

if ! command -v security >/dev/null 2>&1; then
  echo "ERROR: macOS security command was not found." >&2
  exit 1
fi

TMP="${OUT}.tmp"
rm -f "$TMP"
touch "$TMP"
chmod 600 "$TMP"

append_keychain() {
  local keychain="$1"
  if [[ -f "$keychain" ]]; then
    security find-certificate -a -p "$keychain" >>"$TMP" 2>/dev/null || true
  fi
}

append_keychain "/System/Library/Keychains/SystemRootCertificates.keychain"
append_keychain "/Library/Keychains/System.keychain"
append_keychain "$HOME/Library/Keychains/login.keychain-db"

if ! grep -q "BEGIN CERTIFICATE" "$TMP"; then
  rm -f "$TMP"
  echo "ERROR: no public certificates could be exported from macOS Keychain." >&2
  exit 1
fi

mv "$TMP" "$OUT"
chmod 600 "$OUT"

COUNT="$(grep -c "BEGIN CERTIFICATE" "$OUT" || true)"
echo "$OUT"
echo "Exported $COUNT public CA/certificate entries from macOS Keychain."
echo "No private keys were exported."

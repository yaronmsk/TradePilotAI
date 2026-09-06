#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

if [[ -z "${TWELVE_DATA_API_KEY:-}" ]]; then
  echo "Enter Twelve Data API key (input hidden):"
  read -rs TWELVE_DATA_API_KEY
  echo
  export TWELVE_DATA_API_KEY
fi

if [[ "$(uname -s)" == "Darwin" && -z "${SSL_CERT_FILE:-}" ]]; then
  CA_BUNDLE="/tmp/tradepilot-macos-ca-bundle.pem"
  "$ROOT/tools/prepare-macos-ca-bundle.sh" "$CA_BUNDLE"
  export SSL_CERT_FILE="$CA_BUNDLE"
  echo "Using macOS Keychain-derived CA bundle for verified HTTPS."
fi

echo "Starting TradePilot Data Gateway at http://127.0.0.1:8787"
echo "Keep this terminal open while the Flutter live app is running."

PYTHONPATH="$ROOT/gateway" exec python3 gateway/run.py

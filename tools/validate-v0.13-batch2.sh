#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "=== TradePilot AI v0.13 Batch 2 validation ==="
echo

echo "=== Gateway compile ==="
PYTHONPATH="$ROOT/gateway" python3 -m compileall -q gateway

echo
echo "=== Gateway unit tests ==="
PYTHONPATH="$ROOT/gateway" python3 -m unittest discover -s gateway/tests -v

echo
echo "=== Flutter analyzer ==="
cd mobile
flutter analyze

echo
echo "=== Flutter live-foundation regression ==="
flutter test \
  test/core/data/data_provenance_test.dart \
  test/core/network/tradepilot_gateway_client_test.dart \
  test/features/market/providers/gateway_market_data_provider_test.dart \
  test/features/market/providers/gateway_market_history_provider_test.dart

echo
echo "=== Full Flutter suite ==="
flutter test

cd "$ROOT"

echo
echo "=== Secret scan ==="
SECRET_SCAN_FAILED=0

# Catch obvious URL/query/header literals that embed an actual-looking key.
if grep -RniE \
  --exclude='*.md' \
  --exclude='*.sh' \
  --exclude='*.pyc' \
  'apikey[=:][[:space:]]*["'\'']?[A-Za-z0-9_-]{12,}' \
  gateway mobile/lib; then
  SECRET_SCAN_FAILED=1
fi

# Catch direct hard-coded environment-key assignments such as:
# TWELVE_DATA_API_KEY = "actual-secret"
# but deliberately ignore references/variable names like:
# twelve_data_api_key=api_key
if grep -RniE \
  --exclude='*.md' \
  --exclude='*.sh' \
  --exclude='*.pyc' \
  'TWELVE_DATA_API_KEY[[:space:]]*=[[:space:]]*["'\''][^"'\'']{8,}["'\'']' \
  gateway mobile/lib; then
  SECRET_SCAN_FAILED=1
fi

if [[ "$SECRET_SCAN_FAILED" -ne 0 ]]; then
  echo "ERROR: possible committed provider credential literal detected."
  exit 1
fi

echo "No obvious provider credential literals found."

echo
echo "=== Diff checks ==="
git diff --check
git diff --stat
git status --short

echo
echo "v0.13 Batch 2 validation completed successfully."
echo "Next: run ./tools/smoke-v0.13-batch2-live.sh with TWELVE_DATA_API_KEY set."

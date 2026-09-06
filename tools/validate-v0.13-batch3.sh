#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "=== TradePilot AI v0.13 Batch 3 validation ==="

echo
echo "=== Gateway regression ==="
PYTHONPATH="$ROOT/gateway" python3 -m unittest discover -s gateway/tests -v

echo
echo "=== Flutter format ==="
cd mobile
dart format lib test

echo
echo "=== Flutter analyzer ==="
flutter analyze

echo
echo "=== macOS network entitlement ==="
grep -n "com.apple.security.network.client" macos/Runner/DebugProfile.entitlements
grep -n "com.apple.security.network.client" macos/Runner/Release.entitlements

echo
echo "=== Runtime composition tests ==="
flutter test test/app/runtime/tradepilot_runtime_composition_test.dart

echo
echo "=== Existing live-provider tests ==="
flutter test \
  test/core/data/data_provenance_test.dart \
  test/core/network/tradepilot_gateway_client_test.dart \
  test/features/market/providers/gateway_market_data_provider_test.dart \
  test/features/market/providers/gateway_market_history_provider_test.dart

echo
echo "=== Market regression ==="
flutter test test/features/market

echo
echo "=== Dashboard/widget regression ==="
flutter test \
  test/features/dashboard/dashboard_strategy_orchestration_test.dart \
  test/widget_test.dart

echo
echo "=== Recommendation regression ==="
flutter test test/features/recommendation

echo
echo "=== Full Flutter suite ==="
flutter test

echo
echo "=== Web build ==="
flutter build web

cd "$ROOT"

echo
echo "=== No provider key in Flutter ==="
if grep -RniE \
  --include='*.dart' \
  'TWELVE_DATA_API_KEY|apikey[=:][[:space:]]*["'\''][A-Za-z0-9_-]{8,}' \
  mobile/lib; then
  echo "ERROR: provider credential reference detected in Flutter source."
  exit 1
fi
echo "Flutter source contains no Twelve Data credential handling."

echo
echo "=== Diff checks ==="
git diff --check
git diff --stat
git status --short

echo
echo "v0.13 Batch 3 validation completed successfully."

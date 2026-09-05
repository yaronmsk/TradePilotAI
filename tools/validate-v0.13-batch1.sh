#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "=== TradePilot AI v0.13 Batch 1 validation ==="
echo

grep -nF "http: ^1.6.0" mobile/pubspec.yaml
grep -nF 'android.permission.INTERNET' mobile/android/app/src/main/AndroidManifest.xml
grep -Rni --include='*.dart' 'DataProvenance' \
  mobile/lib/core/data \
  mobile/lib/features/market/models \
  mobile/lib/features/market/providers | head -40

cd mobile

echo
echo "=== Dependencies ==="
flutter pub get

echo
echo "=== Formatting ==="
dart format --output=none --set-exit-if-changed lib test

echo
echo "=== Analyzer ==="
flutter analyze

echo
echo "=== Batch 1 focused tests ==="
flutter test \
  test/core/data/data_provenance_test.dart \
  test/core/network/tradepilot_gateway_client_test.dart \
  test/features/market/providers/gateway_market_data_provider_test.dart \
  test/features/market/providers/gateway_market_history_provider_test.dart

echo
echo "=== Existing market regression tests ==="
flutter test test/features/market

echo
echo "=== Recommendation regression tests ==="
flutter test test/features/recommendation

echo
echo "=== Full suite ==="
flutter test

echo
echo "=== Web build ==="
flutter build web

cd "$ROOT"

echo
echo "=== Diff checks ==="
git diff --check
git diff --stat
git status --short

echo
echo "v0.13 Batch 1 validation completed successfully."

#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "=== TradePilot AI v0.13 Batch 3A validation ==="

echo
echo "=== Flutter format ==="
cd mobile
dart format \
  lib/features/dashboard/dashboard_page.dart \
  lib/features/recommendation/widgets/strategy_summary_card.dart \
  test/features/dashboard/dashboard_strategy_orchestration_test.dart \
  test/features/recommendation/widgets/strategy_summary_card_test.dart \
  test/widget_test.dart

echo
echo "=== Flutter analyzer ==="
flutter analyze

echo
echo "=== Manual-refresh focused tests ==="
flutter test \
  test/features/dashboard/dashboard_strategy_orchestration_test.dart \
  test/features/recommendation/widgets/strategy_summary_card_test.dart \
  test/widget_test.dart

echo
echo "=== Full Flutter regression ==="
flutter test

echo
echo "=== Web build ==="
flutter build web

cd "$ROOT"

echo
echo "=== Recommendation-brain drift guard ==="
if git diff --name-only | grep -E '^mobile/lib/features/recommendation/(providers|services|strategy|consensus|history|investor)/'; then
  echo "ERROR: Batch 3A must not modify recommendation-brain files."
  exit 1
fi
echo "No recommendation-brain implementation files changed."

echo
echo "=== Secret guard ==="
if grep -RniE \
  --include='*.dart' \
  'TWELVE_DATA_API_KEY|apikey[=:][[:space:]]*["'\'''][A-Za-z0-9_-]{8,}' \
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
echo "v0.13 Batch 3A validation completed successfully."

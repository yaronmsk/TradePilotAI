#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "=== TradePilot AI v0.13 Batch 3B1 validation ==="

echo
echo "=== Gateway regression ==="
PYTHONPATH="$ROOT/gateway" python3 -m unittest discover -s gateway/tests -v

echo
echo "=== Flutter format ==="
cd mobile
dart format \
  lib/features/dashboard/controllers/dashboard_controller.dart \
  lib/features/dashboard/dashboard_page.dart \
  lib/features/recommendation/models/evidence_result.dart \
  lib/features/recommendation/services/recommendation_service.dart \
  lib/features/recommendation/engines/consensus_engine.dart \
  test/features/dashboard/dashboard_strategy_orchestration_test.dart \
  test/features/recommendation/engines/consensus_engine_test.dart

echo
echo "=== Flutter analyzer ==="
flutter analyze

echo
echo "=== Batch 3A refresh regression ==="
flutter test \
  test/features/recommendation/widgets/strategy_summary_card_test.dart \
  test/widget_test.dart

echo
echo "=== Batch 3B1 focused correctness ==="
flutter test \
  test/features/dashboard/dashboard_strategy_orchestration_test.dart \
  test/features/recommendation/engines/consensus_engine_test.dart

echo
echo "=== Recommendation regression ==="
flutter test test/features/recommendation

echo
echo "=== Full Flutter regression ==="
flutter test

echo
echo "=== Web build ==="
flutter build web

cd "$ROOT"

echo
echo "=== No action-threshold drift ==="
if ! git diff --quiet -- mobile/lib/features/recommendation/strategy/recommendation_strategy_policy.dart; then
  echo "ERROR: Batch 3B1 must not change Buy/Sell recommendation thresholds."
  git diff -- mobile/lib/features/recommendation/strategy/recommendation_strategy_policy.dart
  exit 1
fi
echo "Recommendation action thresholds unchanged."

echo
echo "=== Secret guard ==="
if grep -RniE \
  --include='*.dart' \
  "TWELVE_DATA_API_KEY|apikey[=:][[:space:]]*['\\\"][A-Za-z0-9_-]{8,}" \
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
echo "v0.13 Batch 3B1 validation completed successfully."

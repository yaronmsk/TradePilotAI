#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "=== TradePilot AI v0.13 Batch 3B2 validation ==="

echo
echo "=== Gateway regression ==="
PYTHONPATH="$ROOT/gateway" python3 -m unittest discover -s gateway/tests -v

echo
echo "=== Flutter format ==="
cd mobile
dart format \
  lib/features/recommendation/strategy/strategy_analysis_policy_catalog.dart \
  lib/features/recommendation/strategy/candle_trend_strategy_policy.dart \
  lib/features/recommendation/providers/candle_trend_evidence_provider.dart \
  lib/features/recommendation/providers/relative_volume_evidence_provider.dart \
  lib/features/recommendation/providers/volume_confirmation_evidence_provider.dart \
  lib/features/recommendation/providers/vwap_position_evidence_provider.dart \
  lib/features/recommendation/context/stock_behavior_profile.dart \
  lib/features/recommendation/context/stock_behavior_profile_service.dart \
  lib/features/recommendation/context/contextual_evidence_adjuster.dart \
  lib/features/recommendation/widgets/stock_behavior_card.dart \
  lib/features/recommendation/widgets/analysis_context_card.dart \
  lib/features/recommendation/models/stock_behavior_explainability_catalog.dart \
  test/features/recommendation/strategy/strategy_analysis_policy_catalog_test.dart \
  test/features/recommendation/trader_live_timeframe_calibration_test.dart

echo
echo "=== Flutter analyzer ==="
flutter analyze

echo
echo "=== Batch 3B2 focused calibration ==="
flutter test \
  test/features/recommendation/trader_live_timeframe_calibration_test.dart \
  test/features/recommendation/strategy/strategy_analysis_policy_catalog_test.dart \
  test/features/recommendation/providers/candle_trend_evidence_provider_test.dart \
  test/features/recommendation/providers/relative_volume_evidence_provider_test.dart \
  test/features/recommendation/providers/volume_confirmation_evidence_provider_test.dart \
  test/features/recommendation/providers/vwap_position_evidence_provider_test.dart \
  test/features/recommendation/context/stock_behavior_profile_service_test.dart

echo
echo "=== Batch 3B1 regression ==="
flutter test \
  test/features/dashboard/dashboard_strategy_orchestration_test.dart \
  test/features/recommendation/engines/consensus_engine_test.dart \
  test/features/recommendation/widgets/strategy_summary_card_test.dart \
  test/widget_test.dart

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
echo "=== Recommendation action thresholds unchanged ==="
if ! git diff --quiet -- mobile/lib/features/recommendation/strategy/recommendation_strategy_policy.dart; then
  echo "ERROR: Batch 3B2 must not change recommendation action thresholds."
  git diff -- mobile/lib/features/recommendation/strategy/recommendation_strategy_policy.dart
  exit 1
fi
echo "Recommendation action thresholds unchanged."

echo
echo "=== Diff checks ==="
git diff --check
git diff --stat
git status --short

echo
echo "v0.13 Batch 3B2 validation completed successfully."

import '../history/historical_setup_validation.dart';
import '../models/evidence_report.dart';
import '../models/recommendation.dart';
import '../models/scoring_result.dart';
import '../models/strategy_summary.dart';
import '../strategy/recommendation_strategy_policy.dart';

class RecommendationEngine {
  const RecommendationEngine();

  Recommendation create({
    required ScoringResult scoringResult,
    required EvidenceReport evidenceReport,
    required String timeframe,
    required int candleCount,
    required DateTime analysisTime,
    StrategyType strategy = StrategyType.trader,
    HistoricalSetupValidation historicalValidation =
        const HistoricalSetupValidation.unavailable(),
  }) {
    final policy = RecommendationStrategyPolicy.forStrategy(strategy);

    if (policy == null) {
      throw StateError(
        '${strategy.title} recommendation policy is not active yet.',
      );
    }

    if (scoringResult.coverage < policy.minimumProviderCoverage) {
      return _build(
        type: RecommendationType.wait,
        scoringResult: scoringResult,
        evidenceReport: evidenceReport,
        timeframe: timeframe,
        candleCount: candleCount,
        analysisTime: analysisTime,
        historicalValidation: historicalValidation,
        explanation:
            'There is not enough reliable evidence coverage for a clear recommendation.',
      );
    }

    final directionScore = _resolveDirectionScore(scoringResult);

    final confidence = scoringResult.confidence;

    final hasActionBreadth =
        scoringResult.independentFamilyCount >=
        policy.minimumIndependentFamiliesForAction;

    if (policy.holdOnMaterialConflict &&
        scoringResult.conflict >= policy.materialConflictThreshold) {
      return _build(
        type: RecommendationType.hold,
        scoringResult: scoringResult,
        evidenceReport: evidenceReport,
        timeframe: timeframe,
        candleCount: candleCount,
        analysisTime: analysisTime,
        historicalValidation: historicalValidation,
        explanation:
            'Independent evidence families are materially conflicted, so the current Swing setup does not have a sufficiently clear directional edge.',
      );
    }

    if (directionScore >= policy.strongDirectionThreshold &&
        confidence >= policy.strongActionConfidence &&
        hasActionBreadth) {
      return _build(
        type: RecommendationType.strongBuy,
        scoringResult: scoringResult,
        evidenceReport: evidenceReport,
        timeframe: timeframe,
        candleCount: candleCount,
        analysisTime: analysisTime,
        historicalValidation: historicalValidation,
        explanation:
            'Independent evidence families strongly align bullish with high confidence.',
      );
    }

    if (directionScore >= policy.actionDirectionThreshold &&
        confidence >= policy.minimumActionConfidence &&
        hasActionBreadth) {
      return _build(
        type: RecommendationType.buy,
        scoringResult: scoringResult,
        evidenceReport: evidenceReport,
        timeframe: timeframe,
        candleCount: candleCount,
        analysisTime: analysisTime,
        historicalValidation: historicalValidation,
        explanation:
            'Bullish evidence leads across the available independent evidence families.',
      );
    }

    if (directionScore <= -policy.strongDirectionThreshold &&
        confidence >= policy.strongActionConfidence &&
        hasActionBreadth) {
      return _build(
        type: RecommendationType.strongSell,
        scoringResult: scoringResult,
        evidenceReport: evidenceReport,
        timeframe: timeframe,
        candleCount: candleCount,
        analysisTime: analysisTime,
        historicalValidation: historicalValidation,
        explanation:
            'Independent evidence families strongly align bearish with high confidence.',
      );
    }

    if (directionScore <= -policy.actionDirectionThreshold &&
        confidence >= policy.minimumActionConfidence &&
        hasActionBreadth) {
      return _build(
        type: RecommendationType.sell,
        scoringResult: scoringResult,
        evidenceReport: evidenceReport,
        timeframe: timeframe,
        candleCount: candleCount,
        analysisTime: analysisTime,
        historicalValidation: historicalValidation,
        explanation:
            'Bearish evidence leads across the available independent evidence families.',
      );
    }

    if (directionScore.abs() <= policy.holdDirectionThreshold) {
      return _build(
        type: RecommendationType.hold,
        scoringResult: scoringResult,
        evidenceReport: evidenceReport,
        timeframe: timeframe,
        candleCount: candleCount,
        analysisTime: analysisTime,
        historicalValidation: historicalValidation,
        explanation: scoringResult.conflict >= 0.60
            ? 'Bullish and bearish evidence families are materially conflicted, leaving no clear directional edge.'
            : 'The current independent evidence families are broadly neutral.',
      );
    }

    final breadthExplanation = hasActionBreadth
        ? ''
        : ' Independent-family confirmation is still too limited for an actionable recommendation.';

    return _build(
      type: RecommendationType.wait,
      scoringResult: scoringResult,
      evidenceReport: evidenceReport,
      timeframe: timeframe,
      candleCount: candleCount,
      analysisTime: analysisTime,
      historicalValidation: historicalValidation,
      explanation:
          'A directional bias exists, but confidence or cross-family agreement is not yet strong enough to act on it.$breadthExplanation',
    );
  }

  Recommendation _build({
    required RecommendationType type,
    required ScoringResult scoringResult,
    required EvidenceReport evidenceReport,
    required String timeframe,
    required int candleCount,
    required DateTime analysisTime,
    required HistoricalSetupValidation historicalValidation,
    required String explanation,
  }) {
    return Recommendation(
      type: type,
      evidenceScore: scoringResult.confidence,
      consensus: scoringResult,
      oneLineExplanation: explanation,
      timeframe: timeframe,
      candleCount: candleCount,
      analysisTime: analysisTime,
      evidenceReport: evidenceReport,
      historicalValidation: historicalValidation,
    );
  }

  double _resolveDirectionScore(ScoringResult result) {
    if (result.directionScore != null) {
      return result.directionScore!.clamp(-100.0, 100.0);
    }

    final directionalWeight = result.bullishWeight + result.bearishWeight;

    if (directionalWeight <= 0) {
      return 0;
    }

    return (((result.bullishWeight - result.bearishWeight) /
                directionalWeight) *
            100)
        .clamp(-100.0, 100.0);
  }
}

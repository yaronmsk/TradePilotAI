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
        decisionReasons: const [
          RecommendationDecisionReason.insufficientCoverage,
        ],
        explanation:
            'There is not enough reliable evidence yet to make a clear recommendation.',
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
        decisionReasons: const [RecommendationDecisionReason.materialConflict],
        explanation:
            'Bullish and bearish evidence currently conflict, so there is no clear recommendation.',
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
        decisionReasons: const [
          RecommendationDecisionReason.strongBullishAction,
        ],
        explanation:
            'Bullish evidence strongly aligns across independent evidence groups with high confidence.',
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
        decisionReasons: const [RecommendationDecisionReason.bullishAction],
        explanation:
            'Bullish evidence leads across enough independent evidence groups with sufficient confidence.',
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
        decisionReasons: const [
          RecommendationDecisionReason.strongBearishAction,
        ],
        explanation:
            'Bearish evidence strongly aligns across independent evidence groups with high confidence.',
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
        decisionReasons: const [RecommendationDecisionReason.bearishAction],
        explanation:
            'Bearish evidence leads across enough independent evidence groups with sufficient confidence.',
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
        decisionReasons: [
          if (scoringResult.conflict >= 0.60)
            RecommendationDecisionReason.materialConflict
          else
            RecommendationDecisionReason.neutralEvidence,
        ],
        explanation: scoringResult.conflict >= 0.60
            ? 'Bullish and bearish evidence currently conflict, so there is no clear recommendation.'
            : 'Current evidence is broadly balanced, with no meaningful bullish or bearish advantage.',
      );
    }

    final waitReasons = <RecommendationDecisionReason>[
      if (directionScore.abs() < policy.actionDirectionThreshold)
        RecommendationDecisionReason.insufficientDirectionalStrength,
      if (confidence < policy.minimumActionConfidence)
        RecommendationDecisionReason.insufficientConfidence,
      if (!hasActionBreadth)
        RecommendationDecisionReason.insufficientFamilyBreadth,
    ];

    return _build(
      type: RecommendationType.wait,
      scoringResult: scoringResult,
      evidenceReport: evidenceReport,
      timeframe: timeframe,
      candleCount: candleCount,
      analysisTime: analysisTime,
      historicalValidation: historicalValidation,
      decisionReasons: waitReasons,
      explanation: _waitExplanation(
        directionScore: directionScore,
        confidence: confidence,
        hasActionBreadth: hasActionBreadth,
        actionDirectionThreshold: policy.actionDirectionThreshold,
        minimumActionConfidence: policy.minimumActionConfidence,
      ),
    );
  }

  String _waitExplanation({
    required double directionScore,
    required double confidence,
    required bool hasActionBreadth,
    required double actionDirectionThreshold,
    required double minimumActionConfidence,
  }) {
    final isBullish = directionScore >= 0;
    final directionLabel = isBullish ? 'bullish' : 'bearish';
    final actionLabel = isBullish ? 'Buy' : 'Sell';
    final blockers = <String>[
      if (directionScore.abs() < actionDirectionThreshold)
        'the directional edge is not yet strong enough',
      if (confidence < minimumActionConfidence)
        'confidence is still below the level required for a $actionLabel recommendation',
      if (!hasActionBreadth)
        'too few independent evidence groups currently confirm it',
    ];

    if (blockers.isEmpty) {
      return 'A $directionLabel direction is forming, but confirmation is not yet strong enough for an actionable recommendation.';
    }

    return 'A $directionLabel direction is forming, but ${_joinWithAnd(blockers)}.';
  }

  String _joinWithAnd(List<String> parts) {
    if (parts.length == 1) {
      return parts.single;
    }

    if (parts.length == 2) {
      return '${parts[0]} and ${parts[1]}';
    }

    return '${parts.sublist(0, parts.length - 1).join(', ')}, and ${parts.last}';
  }

  Recommendation _build({
    required RecommendationType type,
    required ScoringResult scoringResult,
    required EvidenceReport evidenceReport,
    required String timeframe,
    required int candleCount,
    required DateTime analysisTime,
    required HistoricalSetupValidation historicalValidation,
    required List<RecommendationDecisionReason> decisionReasons,
    required String explanation,
  }) {
    return Recommendation(
      type: type,
      evidenceScore: scoringResult.confidence,
      consensus: scoringResult,
      decisionReasons: List<RecommendationDecisionReason>.unmodifiable(
        decisionReasons,
      ),
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

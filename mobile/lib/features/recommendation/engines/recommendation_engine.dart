import '../models/evidence_report.dart';
import '../models/recommendation.dart';
import '../models/scoring_result.dart';

class RecommendationEngine {
  const RecommendationEngine();

  Recommendation create({
    required ScoringResult scoringResult,
    required EvidenceReport evidenceReport,
    required String timeframe,
    required int candleCount,
    required DateTime analysisTime,
  }) {
    if (!scoringResult.hasSufficientCoverage) {
      return _build(
        type: RecommendationType.wait,
        scoringResult: scoringResult,
        evidenceReport: evidenceReport,
        timeframe: timeframe,
        candleCount: candleCount,
        analysisTime: analysisTime,
        explanation:
            'There is not enough reliable evidence coverage for a clear recommendation.',
      );
    }

    final directionScore = _resolveDirectionScore(scoringResult);
    final confidence = scoringResult.confidence;

    if (directionScore >= 65 && confidence >= 80) {
      return _build(
        type: RecommendationType.strongBuy,
        scoringResult: scoringResult,
        evidenceReport: evidenceReport,
        timeframe: timeframe,
        candleCount: candleCount,
        analysisTime: analysisTime,
        explanation:
            'Independent evidence families strongly align bullish with high confidence.',
      );
    }

    if (directionScore >= 30 && confidence >= 55) {
      return _build(
        type: RecommendationType.buy,
        scoringResult: scoringResult,
        evidenceReport: evidenceReport,
        timeframe: timeframe,
        candleCount: candleCount,
        analysisTime: analysisTime,
        explanation:
            'Bullish evidence leads across the available independent evidence families.',
      );
    }

    if (directionScore <= -65 && confidence >= 80) {
      return _build(
        type: RecommendationType.strongSell,
        scoringResult: scoringResult,
        evidenceReport: evidenceReport,
        timeframe: timeframe,
        candleCount: candleCount,
        analysisTime: analysisTime,
        explanation:
            'Independent evidence families strongly align bearish with high confidence.',
      );
    }

    if (directionScore <= -30 && confidence >= 55) {
      return _build(
        type: RecommendationType.sell,
        scoringResult: scoringResult,
        evidenceReport: evidenceReport,
        timeframe: timeframe,
        candleCount: candleCount,
        analysisTime: analysisTime,
        explanation:
            'Bearish evidence leads across the available independent evidence families.',
      );
    }

    if (directionScore.abs() <= 20) {
      return _build(
        type: RecommendationType.hold,
        scoringResult: scoringResult,
        evidenceReport: evidenceReport,
        timeframe: timeframe,
        candleCount: candleCount,
        analysisTime: analysisTime,
        explanation: scoringResult.conflict >= 0.60
            ? 'Bullish and bearish evidence families are materially conflicted, leaving no clear directional edge.'
            : 'The current independent evidence families are broadly neutral.',
      );
    }

    return _build(
      type: RecommendationType.wait,
      scoringResult: scoringResult,
      evidenceReport: evidenceReport,
      timeframe: timeframe,
      candleCount: candleCount,
      analysisTime: analysisTime,
      explanation:
          'A directional bias exists, but confidence or cross-family agreement is not yet strong enough to act on it.',
    );
  }

  Recommendation _build({
    required RecommendationType type,
    required ScoringResult scoringResult,
    required EvidenceReport evidenceReport,
    required String timeframe,
    required int candleCount,
    required DateTime analysisTime,
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

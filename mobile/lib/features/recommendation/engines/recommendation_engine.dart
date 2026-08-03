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
      return Recommendation(
        type: RecommendationType.wait,
        evidenceScore: scoringResult.score,
        oneLineExplanation:
            'There is not enough reliable evidence for a clear recommendation.',
        timeframe: timeframe,
        candleCount: candleCount,
        analysisTime: analysisTime,
        evidenceReport: evidenceReport,
      );
    }

    final bullishWeight = scoringResult.bullishWeight;
    final bearishWeight = scoringResult.bearishWeight;
    final neutralWeight = scoringResult.neutralWeight;
    final directionalWeight = bullishWeight + bearishWeight;

    if (directionalWeight == 0) {
      return Recommendation(
        type: RecommendationType.hold,
        evidenceScore: scoringResult.score,
        oneLineExplanation:
            'The available evidence is mostly neutral and does not indicate a clear direction.',
        timeframe: timeframe,
        candleCount: candleCount,
        analysisTime: analysisTime,
        evidenceReport: evidenceReport,
      );
    }

    final bullishShare = bullishWeight / directionalWeight;
    final bearishShare = bearishWeight / directionalWeight;
    final score = scoringResult.score;

    if (bullishShare >= 0.70) {
      return Recommendation(
        type: score >= 80
            ? RecommendationType.strongBuy
            : score >= 55
            ? RecommendationType.buy
            : RecommendationType.hold,
        evidenceScore: score,
        oneLineExplanation: score >= 80
            ? 'Strong bullish evidence is supported by broad agreement between the available indicators.'
            : score >= 55
            ? 'Bullish evidence currently outweighs bearish signals.'
            : 'Bullish signals exist, but the evidence is not strong enough for a buy recommendation.',
        timeframe: timeframe,
        candleCount: candleCount,
        analysisTime: analysisTime,
        evidenceReport: evidenceReport,
      );
    }

    if (bearishShare >= 0.70) {
      return Recommendation(
        type: score >= 80
            ? RecommendationType.strongSell
            : score >= 55
            ? RecommendationType.sell
            : RecommendationType.hold,
        evidenceScore: score,
        oneLineExplanation: score >= 80
            ? 'Strong bearish evidence is supported by broad agreement between the available indicators.'
            : score >= 55
            ? 'Bearish evidence currently outweighs bullish signals.'
            : 'Bearish signals exist, but the evidence is not strong enough for a sell recommendation.',
        timeframe: timeframe,
        candleCount: candleCount,
        analysisTime: analysisTime,
        evidenceReport: evidenceReport,
      );
    }

    final neutralDominates =
        neutralWeight >= bullishWeight && neutralWeight >= bearishWeight;

    return Recommendation(
      type: neutralDominates
          ? RecommendationType.hold
          : RecommendationType.wait,
      evidenceScore: score,
      oneLineExplanation: neutralDominates
          ? 'The current evidence is mostly neutral.'
          : 'The available evidence is mixed and does not support a clear direction.',
      timeframe: timeframe,
      candleCount: candleCount,
      analysisTime: analysisTime,
      evidenceReport: evidenceReport,
    );
  }
}

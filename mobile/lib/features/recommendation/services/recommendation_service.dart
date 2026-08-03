import '../../market/models/market_snapshot.dart';
import '../engines/recommendation_engine.dart';
import '../engines/scoring_engine.dart';
import '../models/evidence_report.dart';
import '../models/evidence_result.dart';
import '../models/recommendation.dart';
import '../providers/evidence_provider.dart';

class RecommendationService {
  const RecommendationService({
    required List<EvidenceProvider> providers,
    this.scoringEngine = const ScoringEngine(),
    this.recommendationEngine = const RecommendationEngine(),
  }) : _providers = providers;

  final List<EvidenceProvider> _providers;
  final ScoringEngine scoringEngine;
  final RecommendationEngine recommendationEngine;

  List<EvidenceProvider> get providers =>
      List<EvidenceProvider>.unmodifiable(_providers);

  List<EvidenceResult> collectEvidence(MarketSnapshot snapshot) {
    return _providers
        .map((provider) => provider.evaluate(snapshot))
        .toList(growable: false);
  }

  Recommendation analyze(MarketSnapshot snapshot) {
    final evidenceResults = collectEvidence(snapshot);

    final evidenceReport = EvidenceReport.fromResults(
      results: evidenceResults,
      expectedProviderCount: _providers.length,
    );

    final scoringResult = scoringEngine.calculate(evidenceReport);

    return recommendationEngine.create(
      scoringResult: scoringResult,
      evidenceReport: evidenceReport,
      timeframe: snapshot.timeframe,
      candleCount: snapshot.candleCount,
      analysisTime: snapshot.timestamp,
    );
  }
}

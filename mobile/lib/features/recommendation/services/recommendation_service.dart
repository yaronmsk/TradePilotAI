import '../../market/models/market_snapshot.dart';
import '../context/contextual_evidence_adjuster.dart';
import '../context/stock_behavior_profile.dart';
import '../context/stock_behavior_profile_service.dart';
import '../engines/consensus_engine.dart';
import '../engines/recommendation_engine.dart';
import '../models/evidence_report.dart';
import '../models/evidence_result.dart';
import '../models/recommendation.dart';
import '../providers/evidence_provider.dart';

class RecommendationService {
  const RecommendationService({
    required List<EvidenceProvider> providers,
    this.stockBehaviorProfileService = const StockBehaviorProfileService(),
    this.contextualEvidenceAdjuster = const ContextualEvidenceAdjuster(),
    this.consensusEngine = const ConsensusEngine(),
    this.recommendationEngine = const RecommendationEngine(),
  }) : _providers = providers;

  final List<EvidenceProvider> _providers;
  final StockBehaviorProfileService stockBehaviorProfileService;
  final ContextualEvidenceAdjuster contextualEvidenceAdjuster;
  final ConsensusEngine consensusEngine;
  final RecommendationEngine recommendationEngine;

  List<EvidenceProvider> get providers =>
      List<EvidenceProvider>.unmodifiable(_providers);

  List<EvidenceResult> collectEvidence(MarketSnapshot snapshot) {
    return _providers
        .map((provider) => provider.evaluate(snapshot))
        .toList(growable: false);
  }

  List<EvidenceResult> collectContextualEvidence(MarketSnapshot snapshot) {
    final rawResults = collectEvidence(snapshot);
    final profile = stockBehaviorProfileService.evaluate(snapshot);

    return contextualEvidenceAdjuster.adjust(
      results: rawResults,
      profile: profile,
    );
  }

  Recommendation analyze(
    MarketSnapshot snapshot, {
    StockBehaviorProfile? profile,
  }) {
    final resolvedProfile =
        profile ?? stockBehaviorProfileService.evaluate(snapshot);
    final rawResults = collectEvidence(snapshot);
    final evidenceResults = contextualEvidenceAdjuster.adjust(
      results: rawResults,
      profile: resolvedProfile,
    );

    final evidenceReport = EvidenceReport.fromResults(
      results: evidenceResults,
      expectedProviderCount: _providers.length,
    );

    final consensusResult = consensusEngine.calculate(evidenceReport);

    return recommendationEngine.create(
      scoringResult: consensusResult,
      evidenceReport: evidenceReport,
      timeframe: snapshot.timeframe,
      candleCount: snapshot.candleCount,
      analysisTime: snapshot.timestamp,
    );
  }
}

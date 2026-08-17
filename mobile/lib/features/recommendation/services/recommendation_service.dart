import '../../market/models/market_candle.dart';
import '../../market/models/market_snapshot.dart';
import '../context/contextual_evidence_adjuster.dart';
import '../context/recommendation_analysis_context.dart';
import '../context/stock_behavior_profile.dart';
import '../context/stock_behavior_profile_service.dart';
import '../engines/consensus_engine.dart';
import '../engines/recommendation_engine.dart';
import '../models/evidence_report.dart';
import '../models/evidence_result.dart';
import '../models/recommendation.dart';
import '../providers/evidence_provider.dart';
import '../providers/market_context_evidence_provider.dart';
import '../providers/multi_timeframe_trend_evidence_provider.dart';

class RecommendationService {
  const RecommendationService({
    required List<EvidenceProvider> providers,
    this.stockBehaviorProfileService = const StockBehaviorProfileService(),
    this.contextualEvidenceAdjuster = const ContextualEvidenceAdjuster(),
    this.multiTimeframeTrendEvidenceProvider =
        const MultiTimeframeTrendEvidenceProvider(),
    this.marketContextEvidenceProvider = const MarketContextEvidenceProvider(),
    this.consensusEngine = const ConsensusEngine(),
    this.recommendationEngine = const RecommendationEngine(),
  }) : _providers = providers;

  final List<EvidenceProvider> _providers;
  final StockBehaviorProfileService stockBehaviorProfileService;
  final ContextualEvidenceAdjuster contextualEvidenceAdjuster;
  final MultiTimeframeTrendEvidenceProvider multiTimeframeTrendEvidenceProvider;
  final MarketContextEvidenceProvider marketContextEvidenceProvider;
  final ConsensusEngine consensusEngine;
  final RecommendationEngine recommendationEngine;

  List<EvidenceProvider> get providers =>
      List<EvidenceProvider>.unmodifiable(_providers);

  List<EvidenceResult> collectEvidence(MarketSnapshot snapshot) {
    return _providers
        .map((provider) => provider.evaluate(snapshot))
        .toList(growable: false);
  }

  List<EvidenceResult> collectContextualEvidence(
    MarketSnapshot snapshot, {
    List<MarketCandle> historicalDailyCandles = const [],
    RecommendationAnalysisContext? analysisContext,
  }) {
    final rawResults = collectEvidence(snapshot);
    final profile = stockBehaviorProfileService.evaluate(
      snapshot,
      historicalDailyCandles: historicalDailyCandles,
    );

    final adjusted = contextualEvidenceAdjuster.adjust(
      results: rawResults,
      profile: profile,
    );

    if (analysisContext == null) {
      return adjusted;
    }

    return List<EvidenceResult>.unmodifiable([
      ...adjusted,
      multiTimeframeTrendEvidenceProvider.evaluate(
        analysisContext.multiTimeframeProfile,
      ),
      marketContextEvidenceProvider.evaluate(
        analysisContext.marketContextProfile,
      ),
    ]);
  }

  Recommendation analyze(
    MarketSnapshot snapshot, {
    StockBehaviorProfile? profile,
    List<MarketCandle> historicalDailyCandles = const [],
    RecommendationAnalysisContext? analysisContext,
  }) {
    final resolvedProfile =
        profile ??
        stockBehaviorProfileService.evaluate(
          snapshot,
          historicalDailyCandles: historicalDailyCandles,
        );

    final rawResults = collectEvidence(snapshot);
    final adjustedBaseResults = contextualEvidenceAdjuster.adjust(
      results: rawResults,
      profile: resolvedProfile,
    );

    final contextResults = analysisContext == null
        ? const <EvidenceResult>[]
        : <EvidenceResult>[
            multiTimeframeTrendEvidenceProvider.evaluate(
              analysisContext.multiTimeframeProfile,
            ),
            marketContextEvidenceProvider.evaluate(
              analysisContext.marketContextProfile,
            ),
          ];

    final evidenceResults = <EvidenceResult>[
      ...adjustedBaseResults,
      ...contextResults,
    ];

    final evidenceReport = EvidenceReport.fromResults(
      results: evidenceResults,
      expectedProviderCount: _providers.length + contextResults.length,
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

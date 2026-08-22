import '../../market/models/market_candle.dart';
import '../../market/models/market_snapshot.dart';
import '../context/contextual_evidence_adjuster.dart';
import '../context/event_risk_confidence_adjuster.dart';
import '../context/recommendation_analysis_context.dart';
import '../context/stock_behavior_profile.dart';
import '../context/stock_behavior_profile_service.dart';
import '../engines/consensus_engine.dart';
import '../history/historical_confidence_adjuster.dart';
import '../history/historical_setup_validation.dart';
import '../engines/recommendation_engine.dart';
import '../models/evidence_report.dart';
import '../models/evidence_result.dart';
import '../models/recommendation.dart';
import '../providers/evidence_provider.dart';
import '../providers/market_breadth_evidence_provider.dart';
import '../providers/market_context_evidence_provider.dart';
import '../providers/multi_timeframe_trend_evidence_provider.dart';
import '../providers/news_sentiment_evidence_provider.dart';

class RecommendationService {
  const RecommendationService({
    required List<EvidenceProvider> providers,
    this.stockBehaviorProfileService = const StockBehaviorProfileService(),
    this.contextualEvidenceAdjuster = const ContextualEvidenceAdjuster(),
    this.multiTimeframeTrendEvidenceProvider =
        const MultiTimeframeTrendEvidenceProvider(),
    this.marketContextEvidenceProvider = const MarketContextEvidenceProvider(),
    this.marketBreadthEvidenceProvider = const MarketBreadthEvidenceProvider(),
    this.newsSentimentEvidenceProvider = const NewsSentimentEvidenceProvider(),
    this.eventRiskConfidenceAdjuster = const EventRiskConfidenceAdjuster(),
    this.consensusEngine = const ConsensusEngine(),
    this.recommendationEngine = const RecommendationEngine(),
    this.historicalConfidenceAdjuster = const HistoricalConfidenceAdjuster(),
  }) : _providers = providers;

  final List<EvidenceProvider> _providers;
  final StockBehaviorProfileService stockBehaviorProfileService;
  final ContextualEvidenceAdjuster contextualEvidenceAdjuster;
  final MultiTimeframeTrendEvidenceProvider multiTimeframeTrendEvidenceProvider;
  final MarketContextEvidenceProvider marketContextEvidenceProvider;
  final MarketBreadthEvidenceProvider marketBreadthEvidenceProvider;
  final NewsSentimentEvidenceProvider newsSentimentEvidenceProvider;
  final EventRiskConfidenceAdjuster eventRiskConfidenceAdjuster;
  final ConsensusEngine consensusEngine;
  final RecommendationEngine recommendationEngine;
  final HistoricalConfidenceAdjuster historicalConfidenceAdjuster;

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
      marketBreadthEvidenceProvider.evaluate(
        analysisContext.externalContextProfile.marketBreadth,
      ),
      newsSentimentEvidenceProvider.evaluate(
        analysisContext.externalContextProfile.newsSentiment,
      ),
    ]);
  }

  Recommendation applyHistoricalValidation({
    required Recommendation recommendation,
    required HistoricalSetupValidation validation,
  }) {
    final adjustedScoring = historicalConfidenceAdjuster.apply(
      scoringResult: recommendation.consensus,
      validation: validation,
    );

    return recommendationEngine.create(
      scoringResult: adjustedScoring,
      evidenceReport: recommendation.evidenceReport,
      timeframe: recommendation.timeframe,
      candleCount: recommendation.candleCount,
      analysisTime: recommendation.analysisTime ?? DateTime.now(),
      historicalValidation: validation,
    );
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
            marketBreadthEvidenceProvider.evaluate(
              analysisContext.externalContextProfile.marketBreadth,
            ),
            newsSentimentEvidenceProvider.evaluate(
              analysisContext.externalContextProfile.newsSentiment,
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
    final contextAdjustedResult = analysisContext == null
        ? consensusResult
        : eventRiskConfidenceAdjuster.apply(
            scoringResult: consensusResult,
            eventRisk: analysisContext.externalContextProfile.eventRisk,
          );

    return recommendationEngine.create(
      scoringResult: contextAdjustedResult,
      evidenceReport: evidenceReport,
      timeframe: snapshot.timeframe,
      candleCount: snapshot.candleCount,
      analysisTime: snapshot.timestamp,
    );
  }
}

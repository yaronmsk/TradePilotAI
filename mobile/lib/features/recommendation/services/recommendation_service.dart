import '../../market/models/market_candle.dart';
import '../../market/models/market_snapshot.dart';
import '../context/contextual_evidence_adjuster.dart';
import '../context/event_risk_confidence_adjuster.dart';
import '../context/recommendation_analysis_context.dart';
import '../context/stock_behavior_profile.dart';
import '../context/stock_behavior_profile_service.dart';
import '../engines/consensus_engine.dart';
import '../engines/recommendation_engine.dart';
import '../history/historical_confidence_adjuster.dart';
import '../history/historical_setup_validation.dart';
import '../models/evidence_report.dart';
import '../models/evidence_result.dart';
import '../models/recommendation.dart';
import '../models/strategy_summary.dart';
import '../providers/evidence_provider.dart';
import '../providers/market_breadth_evidence_provider.dart';
import '../providers/market_context_evidence_provider.dart';
import '../providers/multi_timeframe_trend_evidence_provider.dart';
import '../providers/news_sentiment_evidence_provider.dart';
import '../strategy/strategy_evidence_selector.dart';

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
    this.strategyEvidenceSelector = const StrategyEvidenceSelector(),
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

  final StrategyEvidenceSelector strategyEvidenceSelector;

  List<EvidenceProvider> get providers =>
      List<EvidenceProvider>.unmodifiable(_providers);

  List<EvidenceResult> collectEvidence(
    MarketSnapshot snapshot, {
    StrategyType strategy = StrategyType.trader,
  }) {
    final selectedProviders = strategyEvidenceSelector.selectProviders(
      providers: _providers,
      strategy: strategy,
    );

    return selectedProviders
        .map(
          (provider) => _evaluateProvider(
            provider: provider,
            snapshot: snapshot,
            strategy: strategy,
          ),
        )
        .toList(growable: false);
  }

  EvidenceResult _evaluateProvider({
    required EvidenceProvider provider,
    required MarketSnapshot snapshot,
    required StrategyType strategy,
  }) {
    if (strategy == StrategyType.trader) {
      return provider.evaluate(snapshot);
    }

    if (provider is StrategyAwareEvidenceProvider) {
      return provider.evaluateForStrategy(snapshot, strategy: strategy);
    }

    throw StateError(
      '${provider.name} is not strategy-aware for ${strategy.title}.',
    );
  }

  List<EvidenceResult> collectContextualEvidence(
    MarketSnapshot snapshot, {
    List<MarketCandle> historicalDailyCandles = const [],
    RecommendationAnalysisContext? analysisContext,
    StrategyType strategy = StrategyType.trader,
  }) {
    final rawResults = collectEvidence(snapshot, strategy: strategy);

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

    final contextResults = _collectContextEvidence(
      analysisContext: analysisContext,
      strategy: strategy,
    );

    return List<EvidenceResult>.unmodifiable([...adjusted, ...contextResults]);
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
    StrategyType strategy = StrategyType.trader,
  }) {
    final strategyPolicy = strategyEvidenceSelector.policyFor(strategy);

    if (!strategyPolicy.isRecommendationActive) {
      throw StateError(
        '${strategy.title} recommendation is not active yet. '
        'Its strategy-specific evidence calibration and recommendation '
        'orchestration must be completed before analysis can run.',
      );
    }

    final resolvedProfile =
        profile ??
        stockBehaviorProfileService.evaluate(
          snapshot,
          historicalDailyCandles: historicalDailyCandles,
        );

    final rawResults = collectEvidence(snapshot, strategy: strategy);

    final adjustedBaseResults = contextualEvidenceAdjuster.adjust(
      results: rawResults,
      profile: resolvedProfile,
    );

    final contextResults = analysisContext == null
        ? const <EvidenceResult>[]
        : _collectContextEvidence(
            analysisContext: analysisContext,
            strategy: strategy,
          );

    final evidenceResults = <EvidenceResult>[
      ...adjustedBaseResults,
      ...contextResults,
    ];

    final evidenceReport = EvidenceReport.fromResults(
      results: evidenceResults,
      expectedProviderCount: evidenceResults.length,
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

  List<EvidenceResult> _collectContextEvidence({
    required RecommendationAnalysisContext analysisContext,
    required StrategyType strategy,
  }) {
    final results = <EvidenceResult>[];

    if (strategyEvidenceSelector.allowsDefinition(
      definition: MultiTimeframeTrendEvidenceProvider.kDefinition,
      strategy: strategy,
    )) {
      results.add(
        multiTimeframeTrendEvidenceProvider.evaluate(
          analysisContext.multiTimeframeProfile,
          strategy: strategy,
        ),
      );
    }

    if (strategyEvidenceSelector.allowsDefinition(
      definition: MarketContextEvidenceProvider.kDefinition,
      strategy: strategy,
    )) {
      results.add(
        marketContextEvidenceProvider.evaluate(
          analysisContext.marketContextProfile,
          strategy: strategy,
        ),
      );
    }

    if (strategyEvidenceSelector.allowsDefinition(
      definition: MarketBreadthEvidenceProvider.kDefinition,
      strategy: strategy,
    )) {
      results.add(
        marketBreadthEvidenceProvider.evaluate(
          analysisContext.externalContextProfile.marketBreadth,
        ),
      );
    }

    if (strategyEvidenceSelector.allowsDefinition(
      definition: NewsSentimentEvidenceProvider.kDefinition,
      strategy: strategy,
    )) {
      results.add(
        newsSentimentEvidenceProvider.evaluate(
          analysisContext.externalContextProfile.newsSentiment,
        ),
      );
    }

    return List<EvidenceResult>.unmodifiable(results);
  }
}

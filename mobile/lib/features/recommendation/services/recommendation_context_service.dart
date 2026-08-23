import '../../market/models/market_snapshot.dart';
import '../../market/services/market_service.dart';
import '../context/external_context_profile.dart';
import '../context/external_context_provider.dart';
import '../context/market_context_profile.dart';
import '../context/market_context_profile_service.dart';
import '../context/market_context_target.dart';
import '../context/mock_external_context_provider.dart';
import '../context/mock_security_context_resolver.dart';
import '../context/multi_timeframe_profile.dart';
import '../context/multi_timeframe_profile_service.dart';
import '../context/recommendation_analysis_context.dart';
import '../context/security_context_resolver.dart';
import '../context/strategy_timeframe_plan.dart';
import '../models/strategy_summary.dart';

class RecommendationContextService {
  const RecommendationContextService({
    required this.marketService,
    this.securityContextResolver = const MockSecurityContextResolver(),
    this.multiTimeframeProfileService = const MultiTimeframeProfileService(),
    this.marketContextProfileService = const MarketContextProfileService(),
    this.externalContextProvider = const MockExternalContextProvider(),
  });

  final MarketService marketService;
  final SecurityContextResolver securityContextResolver;
  final MultiTimeframeProfileService multiTimeframeProfileService;
  final MarketContextProfileService marketContextProfileService;
  final ExternalContextProvider externalContextProvider;

  Future<RecommendationAnalysisContext> loadTraderContext(
    MarketSnapshot primarySnapshot, {
    StrategyTimeframePlan plan = StrategyTimeframePlan.trader,
  }) {
    return loadContext(
      primarySnapshot,
      plan: plan,
      strategy: StrategyType.trader,
    );
  }

  Future<RecommendationAnalysisContext> loadSwingContext(
    MarketSnapshot primarySnapshot, {
    StrategyTimeframePlan plan = StrategyTimeframePlan.swing,
  }) {
    return loadContext(
      primarySnapshot,
      plan: plan,
      strategy: StrategyType.swing,
    );
  }

  Future<RecommendationAnalysisContext> loadContext(
    MarketSnapshot primarySnapshot, {
    required StrategyTimeframePlan plan,
    required StrategyType strategy,
  }) async {
    final target = securityContextResolver.resolve(primarySnapshot.symbol);

    final externalContextFuture = _safeLoadExternalContext(
      symbol: primarySnapshot.symbol,
      strategy: strategy,
      primaryTimeframe: plan.primaryTimeframe,
      target: target,
    );

    final futures = <Future<MarketSnapshot?>>[
      _safeLoad(
        symbol: primarySnapshot.symbol,
        timeframe: plan.confirmationTimeframe,
        candleCount: plan.confirmationCandleCount,
      ),
      _safeLoad(
        symbol: primarySnapshot.symbol,
        timeframe: plan.regimeTimeframe,
        candleCount: plan.regimeCandleCount,
      ),
      _safeLoad(
        symbol: target.marketSymbol,
        timeframe: plan.confirmationTimeframe,
        candleCount: plan.confirmationCandleCount,
      ),
      _safeLoad(
        symbol: target.marketSymbol,
        timeframe: plan.regimeTimeframe,
        candleCount: plan.regimeCandleCount,
      ),
      _safeLoad(
        symbol: target.sectorSymbol,
        timeframe: plan.confirmationTimeframe,
        candleCount: plan.confirmationCandleCount,
      ),
      _safeLoad(
        symbol: target.sectorSymbol,
        timeframe: plan.regimeTimeframe,
        candleCount: plan.regimeCandleCount,
      ),
    ];

    final loaded = await Future.wait(futures);
    final externalContext = await externalContextFuture;

    final stockConfirmation = loaded[0];
    final stockRegime = loaded[1];
    final marketConfirmation = loaded[2];
    final marketRegime = loaded[3];
    final sectorConfirmation = loaded[4];
    final sectorRegime = loaded[5];

    final multiTimeframeProfile =
        stockConfirmation != null && stockRegime != null
        ? multiTimeframeProfileService.evaluate(
            primary: primarySnapshot,
            confirmation: stockConfirmation,
            regime: stockRegime,
            plan: plan,
            strategy: strategy,
          )
        : MultiTimeframeProfile.unknown(plan: plan);

    final marketContextProfile =
        stockConfirmation != null &&
            stockRegime != null &&
            marketConfirmation != null &&
            marketRegime != null &&
            sectorConfirmation != null &&
            sectorRegime != null
        ? marketContextProfileService.evaluate(
            target: target,
            stockConfirmation: stockConfirmation,
            stockRegime: stockRegime,
            marketConfirmation: marketConfirmation,
            marketRegime: marketRegime,
            sectorConfirmation: sectorConfirmation,
            sectorRegime: sectorRegime,
          )
        : MarketContextProfile.unknown(target: target);

    return RecommendationAnalysisContext(
      multiTimeframeProfile: multiTimeframeProfile,
      marketContextProfile: marketContextProfile,
      externalContextProfile: externalContext,
    );
  }

  Future<MarketSnapshot?> _safeLoad({
    required String symbol,
    required String timeframe,
    required int candleCount,
  }) async {
    try {
      return await marketService.loadSnapshot(
        symbol: symbol,
        timeframe: timeframe,
        candleCount: candleCount,
      );
    } catch (_) {
      return null;
    }
  }

  Future<ExternalContextProfile> _safeLoadExternalContext({
    required String symbol,
    required StrategyType strategy,
    required String primaryTimeframe,
    required MarketContextTarget target,
  }) async {
    try {
      return await externalContextProvider.load(
        symbol: symbol,
        strategy: strategy,
        primaryTimeframe: primaryTimeframe,
        target: target,
      );
    } catch (_) {
      return const ExternalContextProfile.unavailable();
    }
  }
}

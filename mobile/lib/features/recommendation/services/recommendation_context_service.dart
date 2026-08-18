import '../../market/models/market_snapshot.dart';
import '../../market/services/market_service.dart';
import '../context/market_context_profile.dart';
import '../context/market_context_profile_service.dart';
import '../context/mock_security_context_resolver.dart';
import '../context/multi_timeframe_profile.dart';
import '../context/multi_timeframe_profile_service.dart';
import '../context/recommendation_analysis_context.dart';
import '../context/security_context_resolver.dart';
import '../context/strategy_timeframe_plan.dart';

class RecommendationContextService {
  const RecommendationContextService({
    required this.marketService,
    this.securityContextResolver = const MockSecurityContextResolver(),
    this.multiTimeframeProfileService = const MultiTimeframeProfileService(),
    this.marketContextProfileService = const MarketContextProfileService(),
  });

  final MarketService marketService;
  final SecurityContextResolver securityContextResolver;
  final MultiTimeframeProfileService multiTimeframeProfileService;
  final MarketContextProfileService marketContextProfileService;

  Future<RecommendationAnalysisContext> loadTraderContext(
    MarketSnapshot primarySnapshot, {
    StrategyTimeframePlan plan = StrategyTimeframePlan.trader,
  }) {
    return loadContext(primarySnapshot, plan: plan);
  }

  Future<RecommendationAnalysisContext> loadContext(
    MarketSnapshot primarySnapshot, {
    required StrategyTimeframePlan plan,
  }) async {
    final target = securityContextResolver.resolve(primarySnapshot.symbol);

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
}

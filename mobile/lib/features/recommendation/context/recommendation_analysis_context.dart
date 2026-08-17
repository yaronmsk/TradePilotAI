import 'market_context_profile.dart';
import 'market_context_target.dart';
import 'multi_timeframe_profile.dart';

class RecommendationAnalysisContext {
  const RecommendationAnalysisContext({
    required this.multiTimeframeProfile,
    required this.marketContextProfile,
  });

  RecommendationAnalysisContext.unknown()
    : multiTimeframeProfile = MultiTimeframeProfile.unknown(),
      marketContextProfile = MarketContextProfile.unknown(
        target: const MarketContextTarget(
          marketSymbol: 'SPY',
          sectorSymbol: 'SPY',
          sectorName: 'Sector benchmark unavailable',
          hasSectorBenchmark: false,
        ),
      );

  final MultiTimeframeProfile multiTimeframeProfile;
  final MarketContextProfile marketContextProfile;

  bool get hasAnyContext =>
      multiTimeframeProfile.hasSufficientData ||
      marketContextProfile.hasSufficientData;
}

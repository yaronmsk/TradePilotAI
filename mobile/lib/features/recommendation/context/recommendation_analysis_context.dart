import 'external_context_profile.dart';
import 'market_context_profile.dart';
import 'market_context_target.dart';
import 'multi_timeframe_profile.dart';

class RecommendationAnalysisContext {
  const RecommendationAnalysisContext({
    required this.multiTimeframeProfile,
    required this.marketContextProfile,
    this.externalContextProfile = const ExternalContextProfile.unavailable(),
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
      ),
      externalContextProfile = const ExternalContextProfile.unavailable();

  final MultiTimeframeProfile multiTimeframeProfile;
  final MarketContextProfile marketContextProfile;
  final ExternalContextProfile externalContextProfile;

  bool get hasAnyContext =>
      multiTimeframeProfile.hasSufficientData ||
      marketContextProfile.hasSufficientData ||
      externalContextProfile.hasAnyContext;
}

import 'market_context_target.dart';

enum MarketBackdrop { unknown, supportive, neutral, challenging }

enum RelativeStrengthState { unknown, outperforming, inLine, underperforming }

class MarketContextProfile {
  const MarketContextProfile({
    required this.target,
    required this.backdrop,
    required this.relativeStrength,
    required this.directionScore,
    required this.reliability,
    required this.stockVsMarketPercent,
    required this.stockVsSectorPercent,
    required this.sectorVsMarketPercent,
    required this.marketCompositeReturnPercent,
    required this.sectorCompositeReturnPercent,
  });

  MarketContextProfile.unknown({required this.target})
    : backdrop = MarketBackdrop.unknown,
      relativeStrength = RelativeStrengthState.unknown,
      directionScore = 0,
      reliability = 0,
      stockVsMarketPercent = 0,
      stockVsSectorPercent = 0,
      sectorVsMarketPercent = 0,
      marketCompositeReturnPercent = 0,
      sectorCompositeReturnPercent = 0;

  final MarketContextTarget target;
  final MarketBackdrop backdrop;
  final RelativeStrengthState relativeStrength;

  /// Signed context contribution from -100 to +100.
  final double directionScore;

  final double reliability;
  final double stockVsMarketPercent;
  final double stockVsSectorPercent;
  final double sectorVsMarketPercent;
  final double marketCompositeReturnPercent;
  final double sectorCompositeReturnPercent;

  bool get hasContextConflict =>
      (relativeStrength == RelativeStrengthState.outperforming &&
          backdrop == MarketBackdrop.challenging) ||
      (relativeStrength == RelativeStrengthState.underperforming &&
          backdrop == MarketBackdrop.supportive);

  bool get hasSufficientData => reliability > 0;
}

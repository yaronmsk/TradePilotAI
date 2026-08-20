import '../context/market_context_profile.dart';
import '../context/stock_behavior_profile.dart';
import '../models/evidence_family.dart';
import '../models/strategy_summary.dart';

class HistoricalSetupFingerprint {
  HistoricalSetupFingerprint({
    required this.strategy,
    required this.primaryTimeframe,
    required this.stockBehaviorType,
    required this.volatilityRegime,
    required this.marketBackdrop,
    required this.relativeStrengthState,
    required Map<EvidenceFamily, double> familyDirectionScores,
    required Map<EvidenceFamily, double> familyStrengthScores,
    required Map<EvidenceFamily, double> familyImportanceWeights,
  }) : familyDirectionScores = Map.unmodifiable(familyDirectionScores),
       familyStrengthScores = Map.unmodifiable(familyStrengthScores),
       familyImportanceWeights = Map.unmodifiable(familyImportanceWeights);

  final StrategyType strategy;
  final String primaryTimeframe;
  final StockBehaviorType stockBehaviorType;
  final VolatilityRegime volatilityRegime;
  final MarketBackdrop marketBackdrop;
  final RelativeStrengthState relativeStrengthState;

  /// Family-level direction on the same -100..+100 scale used by consensus.
  final Map<EvidenceFamily, double> familyDirectionScores;

  /// Family-level evidence strength from 0..100.
  final Map<EvidenceFamily, double> familyStrengthScores;

  /// Relative importance of each family in this specific current setup.
  /// Values are normalized to sum to 1 when directional influence exists.
  final Map<EvidenceFamily, double> familyImportanceWeights;

  double directionScoreFor(EvidenceFamily family) =>
      familyDirectionScores[family] ?? 0;

  double strengthScoreFor(EvidenceFamily family) =>
      familyStrengthScores[family] ?? 0;

  double importanceFor(EvidenceFamily family) =>
      familyImportanceWeights[family] ?? 0;
}

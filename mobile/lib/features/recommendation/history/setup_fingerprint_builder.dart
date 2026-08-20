import '../context/market_context_profile.dart';
import '../context/recommendation_analysis_context.dart';
import '../context/stock_behavior_profile.dart';
import '../models/evidence_family.dart';
import '../models/recommendation.dart';
import '../models/strategy_summary.dart';
import 'historical_setup_fingerprint.dart';

class SetupFingerprintBuilder {
  const SetupFingerprintBuilder();

  HistoricalSetupFingerprint build({
    required Recommendation recommendation,
    required StrategyType strategy,
    required StockBehaviorProfile stockBehaviorProfile,
    RecommendationAnalysisContext? analysisContext,
  }) {
    final familyDirectionScores = <EvidenceFamily, double>{};
    final familyStrengthScores = <EvidenceFamily, double>{};

    for (final family in recommendation.consensus.familySummaries) {
      familyDirectionScores[family.family] = family.directionScore;
      familyStrengthScores[family.family] = family.strengthScore;
    }

    final rawImportance = <EvidenceFamily, double>{};

    for (final contribution in recommendation.consensus.familyContributions) {
      rawImportance[contribution.family] = contribution.directionShare;
    }

    final importanceTotal = rawImportance.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );

    final normalizedImportance = <EvidenceFamily, double>{};

    if (importanceTotal > 0) {
      for (final entry in rawImportance.entries) {
        normalizedImportance[entry.key] = entry.value / importanceTotal;
      }
    } else if (familyDirectionScores.isNotEmpty) {
      final equalWeight = 1 / familyDirectionScores.length;
      for (final family in familyDirectionScores.keys) {
        normalizedImportance[family] = equalWeight;
      }
    }

    final marketProfile = analysisContext?.marketContextProfile;

    return HistoricalSetupFingerprint(
      strategy: strategy,
      primaryTimeframe: recommendation.timeframe,
      stockBehaviorType: stockBehaviorProfile.behaviorType,
      volatilityRegime: stockBehaviorProfile.volatilityRegime,
      marketBackdrop: marketProfile?.backdrop ?? MarketBackdrop.unknown,
      relativeStrengthState:
          marketProfile?.relativeStrength ?? RelativeStrengthState.unknown,
      familyDirectionScores: familyDirectionScores,
      familyStrengthScores: familyStrengthScores,
      familyImportanceWeights: normalizedImportance,
    );
  }
}

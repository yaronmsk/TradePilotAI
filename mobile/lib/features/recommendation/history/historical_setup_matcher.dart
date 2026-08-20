import 'dart:math' as math;

import '../models/evidence_family.dart';
import 'historical_setup_case.dart';
import 'historical_setup_fingerprint.dart';
import 'historical_setup_match.dart';

class HistoricalSetupMatcher {
  const HistoricalSetupMatcher({
    this.minimumSimilarity = 0.56,
    this.maximumMatches = 40,
    this.sameSymbolWeightBoost = 1.12,
  });

  final double minimumSimilarity;
  final int maximumMatches;
  final double sameSymbolWeightBoost;

  List<HistoricalSetupMatch> match({
    required String currentSymbol,
    required HistoricalSetupFingerprint current,
    required List<HistoricalSetupCase> candidates,
  }) {
    final matches = <HistoricalSetupMatch>[];

    for (final candidate in candidates) {
      if (candidate.fingerprint.strategy != current.strategy ||
          candidate.fingerprint.primaryTimeframe != current.primaryTimeframe ||
          candidate.fingerprint.stockBehaviorType !=
              current.stockBehaviorType) {
        continue;
      }

      final similarity = similarityBetween(current, candidate.fingerprint);

      if (similarity < minimumSimilarity) {
        continue;
      }

      final sameSymbol =
          candidate.symbol.toUpperCase() == currentSymbol.toUpperCase();
      final statisticalWeight =
          math.pow(similarity, 2).toDouble() *
          (sameSymbol ? sameSymbolWeightBoost : 1.0);

      matches.add(
        HistoricalSetupMatch(
          setupCase: candidate,
          similarity: similarity,
          weight: statisticalWeight,
        ),
      );
    }

    matches.sort((a, b) => b.similarity.compareTo(a.similarity));

    return List<HistoricalSetupMatch>.unmodifiable(
      matches.take(maximumMatches),
    );
  }

  double similarityBetween(
    HistoricalSetupFingerprint current,
    HistoricalSetupFingerprint candidate,
  ) {
    final families = <EvidenceFamily>{
      ...current.familyDirectionScores.keys,
      ...candidate.familyDirectionScores.keys,
    };

    double familySimilarity = 1;

    if (families.isNotEmpty) {
      double weightedSimilarity = 0;
      double totalWeight = 0;

      for (final family in families) {
        final currentDirection = current.directionScoreFor(family);
        final candidateDirection = candidate.directionScoreFor(family);
        final directionSimilarity =
            (1 - ((currentDirection - candidateDirection).abs() / 200)).clamp(
              0.0,
              1.0,
            );

        final currentStrength = current.strengthScoreFor(family);
        final candidateStrength = candidate.strengthScoreFor(family);
        final strengthSimilarity =
            (1 - ((currentStrength - candidateStrength).abs() / 100)).clamp(
              0.0,
              1.0,
            );

        final dimensionSimilarity =
            (directionSimilarity * 0.75) + (strengthSimilarity * 0.25);

        final currentImportance = current.importanceFor(family);
        final weight = currentImportance > 0
            ? currentImportance
            : 1 / families.length;

        weightedSimilarity += dimensionSimilarity * weight;
        totalWeight += weight;
      }

      familySimilarity = totalWeight == 0
          ? 1
          : (weightedSimilarity / totalWeight).clamp(0.0, 1.0);
    }

    // Stock Profile is a hard eligibility gate in match(); once a candidate
    // reaches similarity scoring it is already profile-compatible.
    const stockTypeSimilarity = 1.0;
    final volatilitySimilarity =
        current.volatilityRegime == candidate.volatilityRegime ? 1.0 : 0.62;
    final marketBackdropSimilarity =
        current.marketBackdrop == candidate.marketBackdrop ? 1.0 : 0.55;
    final relativeStrengthSimilarity =
        current.relativeStrengthState == candidate.relativeStrengthState
        ? 1.0
        : 0.55;

    return ((familySimilarity * 0.70) +
            (stockTypeSimilarity * 0.12) +
            (volatilitySimilarity * 0.08) +
            (marketBackdropSimilarity * 0.05) +
            (relativeStrengthSimilarity * 0.05))
        .clamp(0.0, 1.0);
  }
}

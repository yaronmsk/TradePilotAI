import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/stock_behavior_profile.dart';
import 'package:mobile/features/recommendation/history/historical_validation_scoring_policy.dart';

void main() {
  const policy = HistoricalValidationScoringPolicy();

  const profile = StockBehaviorProfile(
    behaviorType: StockBehaviorType.balanced,
    volatilityRegime: VolatilityRegime.normal,
    averageVolume: 1000000,
    relativeVolume: 1.2,
    atrPercent: 1.2,
    baselineAtrPercent: 1.1,
    volatilityRatio: 1.1,
    trendEfficiency: 0.7,
    sampleSize: 48,
  );

  test(
    'historical outcome dimensions use explicit unequal weights summing to one',
    () {
      expect(policy.edgeVsControlWeight, 0.40);
      expect(policy.followThroughWeight, 0.20);
      expect(policy.outcomeMagnitudeWeight, 0.20);
      expect(policy.excursionQualityWeight, 0.20);

      final total =
          policy.edgeVsControlWeight +
          policy.followThroughWeight +
          policy.outcomeMagnitudeWeight +
          policy.excursionQualityWeight;

      expect(total, closeTo(1, 0.0001));
    },
  );

  test(
    'better reward versus adverse excursion improves historical quality',
    () {
      final efficient = policy.evaluate(
        alignedOutcomeRate: 0.68,
        controlAlignedOutcomeRate: 0.50,
        medianDirectionalReturnPercent: 1.1,
        medianFavorableExcursionPercent: 2.2,
        medianAdverseExcursionPercent: -0.4,
        effectiveSampleSize: 28,
        averageSimilarity: 0.82,
        stockBehaviorProfile: profile,
      );

      final painful = policy.evaluate(
        alignedOutcomeRate: 0.68,
        controlAlignedOutcomeRate: 0.50,
        medianDirectionalReturnPercent: 1.1,
        medianFavorableExcursionPercent: 2.2,
        medianAdverseExcursionPercent: -2.8,
        effectiveSampleSize: 28,
        averageSimilarity: 0.82,
        stockBehaviorProfile: profile,
      );

      expect(
        efficient.excursionQualityScore,
        greaterThan(painful.excursionQualityScore),
      );
      expect(
        efficient.weightedOutcomeScore,
        greaterThan(painful.weightedOutcomeScore),
      );
    },
  );

  test(
    'reliability is a weakest-link gate rather than another weighted vote',
    () {
      final weakSample = policy.evaluate(
        alignedOutcomeRate: 0.70,
        controlAlignedOutcomeRate: 0.50,
        medianDirectionalReturnPercent: 1.2,
        medianFavorableExcursionPercent: 1.8,
        medianAdverseExcursionPercent: -0.5,
        effectiveSampleSize: 12,
        averageSimilarity: 0.90,
        stockBehaviorProfile: profile,
      );

      expect(
        weakSample.appliedReliability,
        closeTo(weakSample.effectiveSampleReliability, 0.0001),
      );
      expect(
        weakSample.appliedReliability,
        lessThan(weakSample.matchQualityReliability),
      );
    },
  );

  test(
    'matched setups must beat control before history can add confidence',
    () {
      final result = policy.evaluate(
        alignedOutcomeRate: 0.68,
        controlAlignedOutcomeRate: 0.76,
        medianDirectionalReturnPercent: 1.4,
        medianFavorableExcursionPercent: 2.0,
        medianAdverseExcursionPercent: -0.4,
        effectiveSampleSize: 28,
        averageSimilarity: 0.82,
        stockBehaviorProfile: profile,
      );

      expect(result.confidenceEligibleScore, lessThanOrEqualTo(0));
      expect(
        policy.confidenceImpact(breakdown: result, maximumConfidenceImpact: 8),
        lessThanOrEqualTo(0),
      );
    },
  );

  test(
    'historical confidence impact remains bounded by the configured cap',
    () {
      final result = policy.evaluate(
        alignedOutcomeRate: 1,
        controlAlignedOutcomeRate: 0,
        medianDirectionalReturnPercent: 10,
        medianFavorableExcursionPercent: 10,
        medianAdverseExcursionPercent: -0.01,
        effectiveSampleSize: 100,
        averageSimilarity: 1,
        stockBehaviorProfile: profile,
      );

      final impact = policy.confidenceImpact(
        breakdown: result,
        maximumConfidenceImpact: 8,
      );

      expect(impact, lessThanOrEqualTo(8));
      expect(impact, greaterThanOrEqualTo(-8));
    },
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/contextual_evidence_adjuster.dart';
import 'package:mobile/features/recommendation/context/stock_behavior_profile.dart';
import 'package:mobile/features/recommendation/models/evidence_definition.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';

void main() {
  const adjuster = ContextualEvidenceAdjuster();

  EvidenceResult createEvidence(EvidenceKind kind) {
    return EvidenceResult(
      providerName: kind.name,
      definition: EvidenceDefinition(
        kind: kind,
        name: kind.name,
        description: 'Test',
        whyItMatters: 'Test',
        calculation: 'Test',
      ),
      status: EvidenceStatus.available,
      direction: EvidenceDirection.bullish,
      strength: EvidenceStrength.strong,
      score: 80,
      baseWeight: 1,
      dynamicWeight: 1,
      reliability: 1,
      currentValue: '1',
      baselineValue: '1',
      relativeValue: '1',
      explanation: 'Original explanation.',
    );
  }

  const volatileProfile = StockBehaviorProfile(
    behaviorType: StockBehaviorType.volatile,
    volatilityRegime: VolatilityRegime.normal,
    averageVolume: 1000000,
    relativeVolume: 1,
    atrPercent: 1.5,
    baselineAtrPercent: 1.5,
    volatilityRatio: 1,
    trendEfficiency: 0.8,
    sampleSize: 48,
  );

  test('discounts RSI in a strongly trending volatile stock', () {
    final adjusted = adjuster.adjust(
      results: [createEvidence(EvidenceKind.rsi)],
      profile: volatileProfile,
    );

    expect(adjusted.single.dynamicWeight, lessThan(1));
    expect(adjusted.single.explanation, contains('Context adjustment'));
  });

  test('boosts trend evidence in a directional volatile stock', () {
    final adjusted = adjuster.adjust(
      results: [createEvidence(EvidenceKind.candleTrend)],
      profile: volatileProfile,
    );

    expect(adjusted.single.dynamicWeight, greaterThan(1));
  });

  test('boosts relative volume when activity is exceptional', () {
    const profile = StockBehaviorProfile(
      behaviorType: StockBehaviorType.balanced,
      volatilityRegime: VolatilityRegime.normal,
      averageVolume: 1000000,
      relativeVolume: 2.2,
      atrPercent: 0.8,
      baselineAtrPercent: 0.8,
      volatilityRatio: 1,
      trendEfficiency: 0.5,
      sampleSize: 48,
    );

    final adjusted = adjuster.adjust(
      results: [createEvidence(EvidenceKind.relativeVolume)],
      profile: profile,
    );

    expect(adjusted.single.dynamicWeight, 1.3);
  });

  test(
    'discounts RSI further when long-term Stock DNA confirms volatility',
    () {
      const historicalVolatileProfile = StockBehaviorProfile(
        behaviorType: StockBehaviorType.volatile,
        volatilityRegime: VolatilityRegime.elevated,
        averageVolume: 1000000,
        relativeVolume: 1.1,
        atrPercent: 1.5,
        baselineAtrPercent: 1.2,
        volatilityRatio: 1.25,
        trendEfficiency: 0.8,
        sampleSize: 48,
        baselineSource: StockBaselineSource.oneYearDailyHistory,
        historicalSampleSize: 252,
        typicalDailyAtrPercent: 3.4,
        recentRealizedVolatilityPercent: 68,
        typicalRealizedVolatilityPercent: 52,
        volatilityPercentile: 88,
        volumeVariability: 0.7,
      );

      final adjusted = adjuster.adjust(
        results: [createEvidence(EvidenceKind.rsi)],
        profile: historicalVolatileProfile,
      );

      final legacyAdjusted = adjuster.adjust(
        results: [createEvidence(EvidenceKind.rsi)],
        profile: volatileProfile,
      );

      expect(
        adjusted.single.dynamicWeight,
        lessThan(legacyAdjusted.single.dynamicWeight),
      );
      expect(adjusted.single.explanation, contains('Stock DNA'));
    },
  );

  test(
    'stable historical volume makes a large volume expansion more important',
    () {
      const stableVolumeProfile = StockBehaviorProfile(
        behaviorType: StockBehaviorType.steady,
        volatilityRegime: VolatilityRegime.normal,
        averageVolume: 1000000,
        relativeVolume: 1.6,
        atrPercent: 0.5,
        baselineAtrPercent: 0.5,
        volatilityRatio: 1,
        trendEfficiency: 0.5,
        sampleSize: 48,
        baselineSource: StockBaselineSource.oneYearDailyHistory,
        historicalSampleSize: 252,
        typicalDailyAtrPercent: 1.2,
        recentRealizedVolatilityPercent: 18,
        typicalRealizedVolatilityPercent: 19,
        volatilityPercentile: 50,
        volumeVariability: 0.15,
      );

      final adjusted = adjuster.adjust(
        results: [createEvidence(EvidenceKind.relativeVolume)],
        profile: stableVolumeProfile,
      );

      expect(adjusted.single.dynamicWeight, greaterThan(1.15));
      expect(adjusted.single.explanation, contains('usually stable'));
    },
  );

  test('erratic historical volume discounts a moderate volume spike', () {
    const erraticVolumeProfile = StockBehaviorProfile(
      behaviorType: StockBehaviorType.volatile,
      volatilityRegime: VolatilityRegime.normal,
      averageVolume: 1000000,
      relativeVolume: 1.6,
      atrPercent: 1.2,
      baselineAtrPercent: 1.2,
      volatilityRatio: 1,
      trendEfficiency: 0.5,
      sampleSize: 48,
      baselineSource: StockBaselineSource.oneYearDailyHistory,
      historicalSampleSize: 252,
      typicalDailyAtrPercent: 3.2,
      recentRealizedVolatilityPercent: 48,
      typicalRealizedVolatilityPercent: 50,
      volatilityPercentile: 50,
      volumeVariability: 0.75,
    );

    final adjusted = adjuster.adjust(
      results: [createEvidence(EvidenceKind.relativeVolume)],
      profile: erraticVolumeProfile,
    );

    expect(adjusted.single.dynamicWeight, lessThan(1.15));
    expect(adjusted.single.explanation, contains('highly variable volume'));
  });

  test('applies the same trend-context discipline to EMA structure', () {
    final adjusted = adjuster.adjust(
      results: [createEvidence(EvidenceKind.emaStructure)],
      profile: volatileProfile,
    );

    expect(adjusted.single.dynamicWeight, greaterThan(1));
  });

  test('boosts MACD when momentum sits inside a clean directional move', () {
    final adjusted = adjuster.adjust(
      results: [createEvidence(EvidenceKind.macdMomentum)],
      profile: volatileProfile,
    );

    expect(adjusted.single.dynamicWeight, greaterThan(1));
  });

  test('volume confirmation inherits stock-specific volume weighting', () {
    const profile = StockBehaviorProfile(
      behaviorType: StockBehaviorType.balanced,
      volatilityRegime: VolatilityRegime.normal,
      averageVolume: 1000000,
      relativeVolume: 2.1,
      atrPercent: 0.8,
      baselineAtrPercent: 0.8,
      volatilityRatio: 1,
      trendEfficiency: 0.5,
      sampleSize: 48,
    );

    final adjusted = adjuster.adjust(
      results: [createEvidence(EvidenceKind.volumeConfirmation)],
      profile: profile,
    );

    expect(adjusted.single.dynamicWeight, 1.3);
  });

  test('discounts extension risk slightly inside a very clean trend', () {
    final adjusted = adjuster.adjust(
      results: [createEvidence(EvidenceKind.priceExtension)],
      profile: volatileProfile,
    );

    expect(adjusted.single.dynamicWeight, lessThan(1));
  });
}

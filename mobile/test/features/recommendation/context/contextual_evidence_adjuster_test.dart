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
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/evidence_definition.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_report.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/recommendation.dart';
import 'package:mobile/features/recommendation/models/strategy_recommendation.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/services/swing_decision_helper_service.dart';

const priceExtensionDefinition = EvidenceDefinition(
  kind: EvidenceKind.priceExtension,
  family: EvidenceFamily.volatility,
  name: 'Price Extension',
  description: 'Price extension test evidence.',
  whyItMatters: 'Entry timing.',
  calculation: 'Test fixture.',
);

const supportResistanceDefinition = EvidenceDefinition(
  kind: EvidenceKind.supportResistance,
  family: EvidenceFamily.priceStructure,
  name: 'Support & Resistance',
  description: 'Structure test evidence.',
  whyItMatters: 'Entry structure.',
  calculation: 'Test fixture.',
);

void main() {
  const service = SwingDecisionHelperService();

  test('is Swing-only and does not create a Trader helper', () {
    final result = service.build(
      StrategyRecommendation(
        strategy: StrategyType.trader,
        recommendation: recommendation(
          type: RecommendationType.buy,
          results: const [],
        ),
      ),
    );

    expect(result, isNull);
  });

  test('shows favorable entry when stretch is normal and structure aligns', () {
    final result = service.build(
      StrategyRecommendation(
        strategy: StrategyType.swing,
        recommendation: recommendation(
          type: RecommendationType.buy,
          results: [
            extension(strength: EvidenceStrength.moderate, score: 78),
            structure(
              direction: EvidenceDirection.bullish,
              strength: EvidenceStrength.moderate,
            ),
          ],
        ),
      ),
    )!;

    expect(result.entryQuality.value, 'Favorable');
    expect(result.priceStretch.value, 'Normal');
    expect(result.structureWatch.value, 'Bullish structure confirmed');
  });

  test('uses caution for an extended entry without inventing direction', () {
    final result = service.build(
      StrategyRecommendation(
        strategy: StrategyType.swing,
        recommendation: recommendation(
          type: RecommendationType.buy,
          results: [
            extension(strength: EvidenceStrength.weak, score: 48),
            structure(
              direction: EvidenceDirection.neutral,
              strength: EvidenceStrength.weak,
            ),
          ],
        ),
      ),
    )!;

    expect(result.entryQuality.value, 'Caution');
    expect(result.priceStretch.value, 'Extended');
    expect(result.structureWatch.value, 'Near key level');
  });

  test('preserves SELL parity for aligned bearish structure', () {
    final result = service.build(
      StrategyRecommendation(
        strategy: StrategyType.swing,
        recommendation: recommendation(
          type: RecommendationType.sell,
          results: [
            extension(strength: EvidenceStrength.moderate, score: 78),
            structure(
              direction: EvidenceDirection.bearish,
              strength: EvidenceStrength.strong,
            ),
          ],
        ),
      ),
    )!;

    expect(result.entryQuality.value, 'Favorable');
    expect(result.structureWatch.value, 'Bearish structure confirmed');
  });

  test('does not manufacture an entry helper for HOLD', () {
    final result = service.build(
      StrategyRecommendation(
        strategy: StrategyType.swing,
        recommendation: recommendation(
          type: RecommendationType.hold,
          results: [extension(strength: EvidenceStrength.moderate, score: 78)],
        ),
      ),
    )!;

    expect(result.entryQuality.value, 'Wait');
    expect(
      result.entryQuality.explainability.boundedImpact,
      contains('0 direction points'),
    );
  });

  test(
    'reports missing source evidence instead of fabricating a helper value',
    () {
      final result = service.build(
        StrategyRecommendation(
          strategy: StrategyType.swing,
          recommendation: recommendation(
            type: RecommendationType.buy,
            results: const [],
          ),
        ),
      )!;

      expect(result.entryQuality.value, 'Not enough data');
      expect(result.priceStretch.value, 'Not enough data');
      expect(result.structureWatch.value, 'Not enough data');
    },
  );
}

Recommendation recommendation({
  required RecommendationType type,
  required List<EvidenceResult> results,
}) {
  return Recommendation(
    type: type,
    evidenceScore: 70,
    oneLineExplanation: 'Test recommendation.',
    timeframe: '1d',
    candleCount: 60,
    analysisTime: DateTime(2026, 8, 31, 12),
    evidenceReport: EvidenceReport.fromResults(
      results: results,
      expectedProviderCount: results.length,
    ),
  );
}

EvidenceResult extension({
  required EvidenceStrength strength,
  required double score,
}) {
  return EvidenceResult(
    providerName: 'Price Extension',
    definition: priceExtensionDefinition,
    status: EvidenceStatus.available,
    direction: EvidenceDirection.neutral,
    strength: strength,
    score: score,
    baseWeight: 0.55,
    dynamicWeight: 1,
    reliability: 0.85,
    currentValue: '+1.10 ATR',
    baselineValue: 'EMA 20 · ATR 2.00',
    relativeValue: 'Test extension',
    explanation: 'Test extension explanation.',
  );
}

EvidenceResult structure({
  required EvidenceDirection direction,
  required EvidenceStrength strength,
}) {
  return EvidenceResult(
    providerName: 'Support & Resistance',
    definition: supportResistanceDefinition,
    status: EvidenceStatus.available,
    direction: direction,
    strength: strength,
    score: direction == EvidenceDirection.neutral ? 50 : 78,
    baseWeight: 0.80,
    dynamicWeight: 1,
    reliability: 0.85,
    currentValue: 'Price 100.00',
    baselineValue: 'Support 95 · Resistance 105',
    relativeValue: 'Between structure levels',
    explanation: 'Test structure explanation.',
  );
}

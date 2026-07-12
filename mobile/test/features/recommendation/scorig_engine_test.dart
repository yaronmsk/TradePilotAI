import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/engines/scoring_engine.dart';
import 'package:mobile/features/recommendation/models/evidence_report.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';

void main() {
  const engine = ScoringEngine();

  test('returns high score for strong bullish evidence', () {
    const results = [
      EvidenceResult(
        providerName: 'Volume',
        status: EvidenceStatus.available,
        direction: EvidenceDirection.bullish,
        strength: EvidenceStrength.strong,
        score: 90,
        baseWeight: 1,
        dynamicWeight: 1,
        reliability: 1,
        currentValue: '180% of typical',
        baselineValue: '30-day average',
        relativeValue: '1.80',
        explanation: 'Volume is much higher than typical.',
      ),
      EvidenceResult(
        providerName: 'Trend',
        status: EvidenceStatus.available,
        direction: EvidenceDirection.bullish,
        strength: EvidenceStrength.strong,
        score: 80,
        baseWeight: 1,
        dynamicWeight: 1,
        reliability: 0.9,
        currentValue: 'Bullish',
        baselineValue: 'Recent trend',
        relativeValue: 'Positive',
        explanation: 'Price trend is bullish.',
      ),
    ];

    final report = EvidenceReport.fromResults(
      results: results,
      expectedProviderCount: 2,
    );

    final result = engine.calculate(report);

    expect(result.score, greaterThan(80));
    expect(result.coverage, 1);
    expect(result.bullishWeight, greaterThan(0));
    expect(result.bearishWeight, 0);
    expect(result.warnings, isEmpty);
  });

  test('returns warning when evidence coverage is insufficient', () {
    const results = [
      EvidenceResult(
        providerName: 'Volume',
        status: EvidenceStatus.available,
        direction: EvidenceDirection.neutral,
        strength: EvidenceStrength.moderate,
        score: 50,
        baseWeight: 1,
        dynamicWeight: 1,
        reliability: 1,
        currentValue: 'Normal',
        baselineValue: '30-day average',
        relativeValue: '1.00',
        explanation: 'Volume is near its typical level.',
      ),
    ];

    final report = EvidenceReport.fromResults(
      results: results,
      expectedProviderCount: 4,
    );

    final result = engine.calculate(report);

    expect(result.coverage, 0.25);
    expect(result.hasSufficientCoverage, isFalse);
    expect(result.warnings, isNotEmpty);
  });

  test('handles report with no available evidence', () {
    final report = EvidenceReport.fromResults(
      results: const [],
      expectedProviderCount: 4,
    );

    final result = engine.calculate(report);

    expect(result.score, 0);
    expect(result.bullishWeight, 0);
    expect(result.bearishWeight, 0);
    expect(result.warnings, contains('No usable evidence is available.'));
  });
}
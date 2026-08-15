import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/engines/scoring_engine.dart';
import 'package:mobile/features/recommendation/models/evidence_definition.dart';
import 'package:mobile/features/recommendation/models/evidence_report.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';

void main() {
  const engine = ScoringEngine();

  const testDefinition = EvidenceDefinition(
    name: 'Test Evidence',
    description: 'Evidence used for scoring tests.',
    whyItMatters: 'Allows deterministic scoring tests.',
    calculation: 'Uses predetermined test values.',
  );

  EvidenceResult createEvidence({
    required String providerName,
    required EvidenceDirection direction,
    required double score,
    double reliability = 1,
    EvidenceStatus status = EvidenceStatus.available,
  }) {
    return EvidenceResult(
      providerName: providerName,
      definition: testDefinition,
      status: status,
      direction: direction,
      strength: EvidenceStrength.strong,
      score: score,
      baseWeight: 1,
      dynamicWeight: 1,
      reliability: reliability,
      currentValue: score.toStringAsFixed(0),
      baselineValue: '50',
      relativeValue: '0',
      explanation: 'Test evidence.',
    );
  }

  group('ScoringEngine', () {
    test('calculates score from balanced opposing evidence', () {
      final results = <EvidenceResult>[
        createEvidence(
          providerName: 'Bullish',
          direction: EvidenceDirection.bullish,
          score: 90,
        ),
        createEvidence(
          providerName: 'Bearish',
          direction: EvidenceDirection.bearish,
          score: 70,
        ),
      ];

      final report = EvidenceReport.fromResults(
        results: results,
        expectedProviderCount: 2,
      );

      final result = engine.calculate(report);

      expect(result.coverage, 1);
      expect(result.bullishWeight, 1);
      expect(result.bearishWeight, 1);
      expect(result.score, 40);
    });

    test('accounts for reliability and evidence coverage', () {
      final results = <EvidenceResult>[
        createEvidence(
          providerName: 'Bullish',
          direction: EvidenceDirection.bullish,
          score: 80,
          reliability: 0.5,
        ),
      ];

      final report = EvidenceReport.fromResults(
        results: results,
        expectedProviderCount: 2,
      );

      final result = engine.calculate(report);

      expect(result.coverage, 0.5);
      expect(result.bullishWeight, 0.5);
      expect(result.bearishWeight, 0);
      expect(result.score, 40);
    });
  });
}

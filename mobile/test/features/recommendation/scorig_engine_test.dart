import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/engines/scoring_engine.dart';
import 'package:mobile/features/recommendation/models/evidence_definition.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_report.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';

void main() {
  const engine = ScoringEngine();

  EvidenceResult createEvidence({
    required String providerName,
    required EvidenceFamily family,
    required EvidenceDirection direction,
    required double score,
    double reliability = 1,
    EvidenceStatus status = EvidenceStatus.available,
  }) {
    return EvidenceResult(
      providerName: providerName,
      definition: EvidenceDefinition(
        family: family,
        name: providerName,
        description: 'Evidence used for scoring tests.',
        whyItMatters: 'Allows deterministic scoring tests.',
        calculation: 'Uses predetermined test values.',
      ),
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

  group('ScoringEngine consensus facade', () {
    test('preserves direction and conflict across independent families', () {
      final report = EvidenceReport.fromResults(
        results: [
          createEvidence(
            providerName: 'Trend',
            family: EvidenceFamily.trend,
            direction: EvidenceDirection.bullish,
            score: 90,
          ),
          createEvidence(
            providerName: 'Momentum',
            family: EvidenceFamily.momentum,
            direction: EvidenceDirection.bearish,
            score: 70,
          ),
        ],
        expectedProviderCount: 2,
      );

      final result = engine.calculate(report);

      expect(result.coverage, 1);
      expect(result.independentFamilyCount, 2);
      expect(result.directionScore, closeTo(10, 0.001));
      expect(result.conflict, closeTo(0.875, 0.001));
      expect(result.score, closeTo(69.5, 0.01));
    });

    test('accounts for reliability and provider coverage', () {
      final available = createEvidence(
        providerName: 'Trend',
        family: EvidenceFamily.trend,
        direction: EvidenceDirection.bullish,
        score: 80,
        reliability: 0.5,
      );

      final unavailable = createEvidence(
        providerName: 'Momentum',
        family: EvidenceFamily.momentum,
        direction: EvidenceDirection.unknown,
        score: 0,
        reliability: 0,
        status: EvidenceStatus.insufficientData,
      );

      final report = EvidenceReport.fromResults(
        results: [available, unavailable],
        expectedProviderCount: 2,
      );

      final result = engine.calculate(report);

      expect(result.coverage, 0.5);
      expect(result.familyCoverage, 0.5);
      expect(result.independentFamilyCount, 1);
      expect(result.score, closeTo(50.32, 0.01));
    });
  });
}

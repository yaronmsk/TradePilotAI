import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/engines/consensus_engine.dart';
import 'package:mobile/features/recommendation/models/evidence_definition.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_report.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';

void main() {
  const engine = ConsensusEngine();

  EvidenceResult evidence({
    required String name,
    required EvidenceFamily family,
    required EvidenceDirection direction,
    double score = 80,
    double baseWeight = 1,
    double dynamicWeight = 1,
    double reliability = 1,
    EvidenceStatus status = EvidenceStatus.available,
  }) {
    return EvidenceResult(
      providerName: name,
      definition: EvidenceDefinition(
        family: family,
        name: name,
        description: 'Test evidence.',
        whyItMatters: 'Test evidence.',
        calculation: 'Predetermined values.',
      ),
      status: status,
      direction: direction,
      strength: EvidenceStrength.strong,
      score: score,
      baseWeight: baseWeight,
      dynamicWeight: dynamicWeight,
      reliability: reliability,
      currentValue: 'test',
      baselineValue: 'test',
      relativeValue: 'test',
      explanation: 'test',
    );
  }

  EvidenceReport report(List<EvidenceResult> results) {
    return EvidenceReport.fromResults(
      results: results,
      expectedProviderCount: results.length,
    );
  }

  test('single bullish family produces bullish direction', () {
    final result = engine.calculate(
      report([
        evidence(
          name: 'Trend',
          family: EvidenceFamily.trend,
          direction: EvidenceDirection.bullish,
          score: 90,
        ),
      ]),
    );

    expect(result.directionScore, closeTo(90, 0.001));
    expect(result.confidence, closeTo(90, 0.001));
    expect(result.bullishSupportPercent, 100);
    expect(result.bearishSupportPercent, 0);
    expect(result.independentFamilyCount, 1);
  });

  test('duplicate same-family evidence does not multiply family influence', () {
    final single = engine.calculate(
      report([
        evidence(
          name: 'Trend A',
          family: EvidenceFamily.trend,
          direction: EvidenceDirection.bullish,
        ),
      ]),
    );

    final duplicated = engine.calculate(
      report([
        evidence(
          name: 'Trend A',
          family: EvidenceFamily.trend,
          direction: EvidenceDirection.bullish,
        ),
        evidence(
          name: 'Trend B',
          family: EvidenceFamily.trend,
          direction: EvidenceDirection.bullish,
        ),
      ]),
    );

    expect(duplicated.independentFamilyCount, 1);
    expect(duplicated.bullishWeight, closeTo(single.bullishWeight, 0.001));
    expect(duplicated.directionScore, closeTo(single.directionScore!, 0.001));
    expect(duplicated.confidence, closeTo(single.confidence, 0.001));
  });

  test('opposing independent families create explicit conflict', () {
    final result = engine.calculate(
      report([
        evidence(
          name: 'Trend',
          family: EvidenceFamily.trend,
          direction: EvidenceDirection.bullish,
          score: 80,
        ),
        evidence(
          name: 'Momentum',
          family: EvidenceFamily.momentum,
          direction: EvidenceDirection.bearish,
          score: 80,
        ),
      ]),
    );

    expect(result.directionScore, closeTo(0, 0.001));
    expect(result.agreement, closeTo(0.5, 0.001));
    expect(result.conflict, closeTo(1, 0.001));
    expect(result.independentFamilyCount, 2);
  });

  test('missing an expected family reduces family coverage and confidence', () {
    final full = engine.calculate(
      report([
        evidence(
          name: 'Trend',
          family: EvidenceFamily.trend,
          direction: EvidenceDirection.bullish,
        ),
        evidence(
          name: 'Momentum',
          family: EvidenceFamily.momentum,
          direction: EvidenceDirection.bullish,
        ),
      ]),
    );

    final partial = engine.calculate(
      report([
        evidence(
          name: 'Trend',
          family: EvidenceFamily.trend,
          direction: EvidenceDirection.bullish,
        ),
        evidence(
          name: 'Momentum',
          family: EvidenceFamily.momentum,
          direction: EvidenceDirection.unknown,
          score: 0,
          reliability: 0,
          status: EvidenceStatus.insufficientData,
        ),
      ]),
    );

    expect(partial.familyCoverage, 0.5);
    expect(partial.coverage, 0.5);
    expect(partial.confidence, lessThan(full.confidence));
  });

  test('neutral family tempers direction without becoming opposition', () {
    final result = engine.calculate(
      report([
        evidence(
          name: 'Trend',
          family: EvidenceFamily.trend,
          direction: EvidenceDirection.bullish,
          score: 80,
        ),
        evidence(
          name: 'Participation',
          family: EvidenceFamily.participation,
          direction: EvidenceDirection.neutral,
          score: 50,
        ),
      ]),
    );

    expect(result.directionScore, closeTo(40, 0.001));
    expect(result.bearishSupportPercent, 0);
    expect(result.neutralWeight, greaterThan(0));
  });
}

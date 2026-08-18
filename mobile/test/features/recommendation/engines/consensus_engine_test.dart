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

  test(
    'family attribution reconciles exactly to final direction and confidence',
    () {
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
            score: 40,
          ),
        ]),
      );

      final directionTotal = result.familyContributions.fold<double>(
        0,
        (sum, contribution) => sum + contribution.directionImpactPoints,
      );
      final confidenceTotal = result.familyContributions.fold<double>(
        0,
        (sum, contribution) => sum + contribution.confidenceContributionPoints,
      );
      final directionShareTotal = result.familyContributions.fold<double>(
        0,
        (sum, contribution) => sum + contribution.directionShare,
      );
      final confidenceShareTotal = result.familyContributions.fold<double>(
        0,
        (sum, contribution) => sum + contribution.confidenceShare,
      );

      expect(directionTotal, closeTo(result.directionScore!, 0.001));
      expect(confidenceTotal, closeTo(result.confidence, 0.001));
      expect(directionShareTotal, closeTo(1, 0.001));
      expect(confidenceShareTotal, closeTo(1, 0.001));

      final trend = result.familyContributions.firstWhere(
        (item) => item.family == EvidenceFamily.trend,
      );
      final momentum = result.familyContributions.firstWhere(
        (item) => item.family == EvidenceFamily.momentum,
      );

      expect(trend.directionImpactPoints, closeTo(40, 0.001));
      expect(momentum.directionImpactPoints, closeTo(-20, 0.001));
      expect(trend.directionShare, closeTo(2 / 3, 0.001));
      expect(momentum.directionShare, closeTo(1 / 3, 0.001));
    },
  );

  test('provider attribution respects the evidence-family cap', () {
    final single = engine.calculate(
      report([
        evidence(
          name: 'Trend A',
          family: EvidenceFamily.trend,
          direction: EvidenceDirection.bullish,
          score: 80,
        ),
      ]),
    );

    final duplicated = engine.calculate(
      report([
        evidence(
          name: 'Trend A',
          family: EvidenceFamily.trend,
          direction: EvidenceDirection.bullish,
          score: 80,
        ),
        evidence(
          name: 'Trend B',
          family: EvidenceFamily.trend,
          direction: EvidenceDirection.bullish,
          score: 80,
        ),
      ]),
    );

    expect(
      single.familyContributions.single.directionImpactPoints,
      closeTo(80, 0.001),
    );
    expect(
      duplicated.familyContributions.single.directionImpactPoints,
      closeTo(80, 0.001),
    );
    expect(duplicated.providerContributions, hasLength(2));
    expect(
      duplicated.providerContributions
          .map((item) => item.directionImpactPoints)
          .reduce((a, b) => a + b),
      closeTo(80, 0.001),
    );
    expect(
      duplicated.providerContributions.first.directionShareWithinFamily,
      closeTo(0.5, 0.001),
    );
    expect(
      duplicated.providerContributions.last.directionShareWithinFamily,
      closeTo(0.5, 0.001),
    );
  });

  test(
    'confidence modifiers reconcile evidence strength to final confidence',
    () {
      final result = engine.calculate(
        report([
          evidence(
            name: 'Trend',
            family: EvidenceFamily.trend,
            direction: EvidenceDirection.bullish,
            score: 80,
            reliability: 0.8,
          ),
          evidence(
            name: 'Momentum',
            family: EvidenceFamily.momentum,
            direction: EvidenceDirection.bearish,
            score: 40,
            reliability: 0.8,
          ),
        ]),
      );

      final modifierImpact = result.confidenceModifiers.fold<double>(
        0,
        (sum, modifier) => sum + modifier.impactPoints,
      );

      expect(
        result.baseEvidenceStrength + modifierImpact,
        closeTo(result.confidence, 0.001),
      );
      expect(result.confidenceModifiers, hasLength(4));
      expect(
        result.confidenceModifiers.every((modifier) => modifier.factor <= 1),
        isTrue,
      );
    },
  );
}

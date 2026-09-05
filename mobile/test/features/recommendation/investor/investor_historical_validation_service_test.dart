import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/investor/engines/investor_recommendation_engine.dart';
import 'package:mobile/features/recommendation/investor/history/investor_historical_validation_service.dart';
import 'package:mobile/features/recommendation/investor/models/investor_historical_validation_case.dart';
import 'package:mobile/features/recommendation/investor/models/investor_metric_assessment.dart';
import 'package:mobile/features/recommendation/investor/providers/investor_data_providers.dart';
import 'package:mobile/features/recommendation/investor/providers/mock_investor_historical_data_provider.dart';
import 'package:mobile/features/recommendation/investor/strategy/investor_recommendation_policy.dart';
import 'package:mobile/features/recommendation/models/evidence_definition.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/history/historical_setup_validation.dart';

void main() {
  const recommendationEngine = InvestorRecommendationEngine();
  final analysisTime = DateTime(2026, 9, 4);

  InvestorEvidenceAssessment assessment(
    EvidenceFamily family,
    EvidenceDirection direction,
    double score,
  ) {
    return InvestorEvidenceAssessment(
      evidence: EvidenceResult(
        providerName: 'Test ${family.name}',
        definition: EvidenceDefinition(
          family: family,
          name: family.name,
          description: 'Test',
          whyItMatters: 'Test',
          calculation: 'Test',
        ),
        status: EvidenceStatus.available,
        direction: direction,
        strength: EvidenceStrength.strong,
        score: score,
        baseWeight: 1,
        dynamicWeight: 1,
        reliability: 1,
        currentValue: 'Test',
        baselineValue: 'Test',
        relativeValue: 'Test',
        explanation: 'Test',
      ),
      metrics: const [],
    );
  }

  InvestorRecommendationAnalysis analysis(
    EvidenceDirection direction, {
    double score = 70,
  }) {
    return recommendationEngine.create(
      assessments: [
        for (final family
            in InvestorRecommendationPolicy.breadthEligibleCoreFamilies)
          assessment(family, direction, score),
      ],
      analysisTime: analysisTime,
    );
  }

  test(
    'supportive point-in-time history adds bounded confidence only',
    () async {
      final service = InvestorHistoricalValidationService(
        provider: const MockInvestorHistoricalDataProvider(),
      );

      final result = await service.validate(
        symbol: 'IVBULL',
        analysis: analysis(EvidenceDirection.bullish),
      );

      expect(result.validation.status, HistoricalValidationStatus.available);
      expect(result.validation.verdict, HistoricalValidationVerdict.supports);
      expect(result.validation.confidenceImpactPoints, greaterThan(0));
      expect(
        result.validation.confidenceImpactPoints,
        lessThanOrEqualTo(
          HistoricalSetupValidation.maximumConfidenceImpactPoints,
        ),
      );
      expect(result.horizons.length, 3);
    },
  );

  test('opposing history can reduce confidence but not direction', () async {
    final service = InvestorHistoricalValidationService(
      provider: const MockInvestorHistoricalDataProvider(),
    );
    final current = analysis(EvidenceDirection.bullish);
    final beforeDirection = current.recommendation.directionScore;

    final result = await service.validate(
      symbol: 'IVOPPOSE',
      analysis: current,
    );

    expect(result.validation.status, HistoricalValidationStatus.available);
    expect(result.validation.verdict, HistoricalValidationVerdict.opposes);
    expect(result.validation.confidenceImpactPoints, lessThan(0));

    final adjusted = recommendationEngine.applyHistoricalValidation(
      analysis: current,
      validation: result.validation,
    );

    expect(
      adjusted.recommendation.directionScore,
      closeTo(beforeDirection, 0.000001),
    );
  });

  test('bearish Investor history is evaluated symmetrically', () async {
    final service = InvestorHistoricalValidationService(
      provider: const MockInvestorHistoricalDataProvider(),
    );

    final result = await service.validate(
      symbol: 'IVBEAR',
      analysis: analysis(EvidenceDirection.bearish),
    );

    expect(result.validation.status, HistoricalValidationStatus.available);
    expect(result.validation.verdict, HistoricalValidationVerdict.supports);
    expect(result.validation.confidenceImpactPoints, greaterThan(0));
  });

  test('neutral Investor direction receives zero historical impact', () async {
    final service = InvestorHistoricalValidationService(
      provider: const MockInvestorHistoricalDataProvider(),
    );

    final current = recommendationEngine.create(
      assessments: [
        for (final family
            in InvestorRecommendationPolicy.breadthEligibleCoreFamilies)
          assessment(family, EvidenceDirection.neutral, 20),
      ],
      analysisTime: analysisTime,
    );

    final result = await service.validate(symbol: 'IVBULL', analysis: current);

    expect(result.validation.status, HistoricalValidationStatus.neutralSignal);
    expect(result.validation.confidenceImpactPoints, 0);
  });

  test(
    '12-month horizon is mandatory and at least two horizons are required',
    () async {
      final service = InvestorHistoricalValidationService(
        provider: _SixMonthOnlyProvider(),
      );

      final result = await service.validate(
        symbol: 'SHORT',
        analysis: analysis(EvidenceDirection.bullish),
      );

      expect(
        result.validation.status,
        HistoricalValidationStatus.insufficientData,
      );
      expect(result.validation.confidenceImpactPoints, 0);
    },
  );

  test('future-known setup fingerprints are rejected', () async {
    final service = InvestorHistoricalValidationService(
      provider: _LookAheadProvider(),
    );

    final result = await service.validate(
      symbol: 'LOOKAHEAD',
      analysis: analysis(EvidenceDirection.bullish),
    );

    expect(
      result.validation.status,
      HistoricalValidationStatus.insufficientData,
    );
    expect(result.validation.matchedCases, 0);
    expect(result.validation.confidenceImpactPoints, 0);
  });

  test('horizon weights collapse to one shared ±8 overlay', () async {
    final service = InvestorHistoricalValidationService(
      provider: const MockInvestorHistoricalDataProvider(),
    );

    final result = await service.validate(
      symbol: 'IVBULL',
      analysis: analysis(EvidenceDirection.bullish),
    );

    expect(result.horizons.length, 3);
    expect(
      result.horizons.fold<double>(
        0,
        (sum, horizon) => sum + horizon.horizon.policyWeight,
      ),
      1,
    );
    expect(
      result.validation.confidenceImpactPoints.abs(),
      lessThanOrEqualTo(8),
    );
  });
}

class _SixMonthOnlyProvider implements InvestorHistoricalDataProvider {
  const _SixMonthOnlyProvider();

  @override
  Future<List<InvestorHistoricalValidationCase>> loadValidationCases({
    required String symbol,
    required DateTime asOf,
  }) async {
    final base = await const MockInvestorHistoricalDataProvider()
        .loadValidationCases(symbol: 'IVBULL', asOf: asOf);

    return [
      for (final historicalCase in base)
        InvestorHistoricalValidationCase(
          symbol: symbol,
          setupTime: historicalCase.setupTime,
          setupAvailableAt: historicalCase.setupAvailableAt,
          familySignedScores: historicalCase.familySignedScores,
          directionScore: historicalCase.directionScore,
          confidence: historicalCase.confidence,
          coreFamilyCount: historicalCase.coreFamilyCount,
          outcomes: {
            InvestorHistoricalHorizon.sixMonths:
                ?historicalCase.outcomes[InvestorHistoricalHorizon.sixMonths],
          },
          isSynthetic: true,
          sourceLabel: 'Synthetic 6m-only history',
        ),
    ];
  }
}

class _LookAheadProvider implements InvestorHistoricalDataProvider {
  const _LookAheadProvider();

  @override
  Future<List<InvestorHistoricalValidationCase>> loadValidationCases({
    required String symbol,
    required DateTime asOf,
  }) async {
    final base = await const MockInvestorHistoricalDataProvider()
        .loadValidationCases(symbol: 'IVBULL', asOf: asOf);

    return [
      for (final historicalCase in base.take(20))
        InvestorHistoricalValidationCase(
          symbol: symbol,
          setupTime: historicalCase.setupTime,
          setupAvailableAt: historicalCase.setupTime.add(
            const Duration(days: 1),
          ),
          familySignedScores: historicalCase.familySignedScores,
          directionScore: historicalCase.directionScore,
          confidence: historicalCase.confidence,
          coreFamilyCount: historicalCase.coreFamilyCount,
          outcomes: historicalCase.outcomes,
          isSynthetic: true,
          sourceLabel: 'Synthetic look-ahead history',
        ),
    ];
  }
}

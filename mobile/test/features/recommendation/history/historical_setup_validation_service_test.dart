import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/market_context_profile.dart';
import 'package:mobile/features/recommendation/context/stock_behavior_profile.dart';
import 'package:mobile/features/recommendation/history/historical_setup_case.dart';
import 'package:mobile/features/recommendation/history/historical_setup_fingerprint.dart';
import 'package:mobile/features/recommendation/history/historical_setup_provider.dart';
import 'package:mobile/features/recommendation/history/historical_setup_validation.dart';
import 'package:mobile/features/recommendation/history/historical_setup_validation_service.dart';
import 'package:mobile/features/recommendation/models/evidence_contribution.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_family_summary.dart';
import 'package:mobile/features/recommendation/models/evidence_report.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/recommendation.dart';
import 'package:mobile/features/recommendation/models/scoring_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';

void main() {
  const profile = StockBehaviorProfile(
    behaviorType: StockBehaviorType.balanced,
    volatilityRegime: VolatilityRegime.normal,
    averageVolume: 1000000,
    relativeVolume: 1.3,
    atrPercent: 1.2,
    baselineAtrPercent: 1.1,
    volatilityRatio: 1.1,
    trendEfficiency: 0.7,
    sampleSize: 48,
  );

  Recommendation bullishRecommendation() {
    const familySummary = EvidenceFamilySummary(
      family: EvidenceFamily.trend,
      direction: EvidenceDirection.bullish,
      directionScore: 72,
      strengthScore: 82,
      effectiveWeight: 1,
      reliability: 0.9,
      agreement: 1,
      evidenceCount: 1,
    );

    const familyContribution = EvidenceFamilyContribution(
      family: EvidenceFamily.trend,
      direction: EvidenceDirection.bullish,
      directionImpactPoints: 72,
      directionShare: 1,
      confidenceContributionPoints: 70,
      confidenceShare: 1,
      providers: [],
    );

    final scoring = ScoringResult(
      score: 70,
      coverage: 1,
      bullishWeight: 1,
      bearishWeight: 0,
      neutralWeight: 0,
      warnings: const [],
      directionScore: 72,
      familyCoverage: 1,
      agreement: 1,
      conflict: 0,
      bullishSupportPercent: 100,
      bearishSupportPercent: 0,
      independentFamilyCount: 1,
      familySummaries: const [familySummary],
      baseEvidenceStrength: 82,
      evidenceConfidence: 70,
      familyContributions: const [familyContribution],
    );

    return Recommendation(
      type: RecommendationType.buy,
      evidenceScore: scoring.confidence,
      oneLineExplanation: 'Bullish test setup.',
      timeframe: '5m',
      candleCount: 48,
      analysisTime: DateTime.utc(2026, 8, 20),
      evidenceReport: EvidenceReport.fromResults(
        results: const [],
        expectedProviderCount: 0,
      ),
      consensus: scoring,
    );
  }

  test(
    'supportive analogs produce a positive bounded confidence impact',
    () async {
      final service = HistoricalSetupValidationService(
        provider: _FixedOutcomeProvider(
          caseReturns: const [
            1.2,
            1.0,
            0.8,
            1.4,
            0.6,
            1.1,
            0.7,
            0.9,
            1.3,
            0.5,
            1.0,
            0.8,
            1.2,
            0.6,
            1.1,
            -0.4,
            -0.6,
            -0.3,
            0.7,
            0.9,
            1.2,
            0.8,
            1.0,
            -0.2,
            0.6,
            1.1,
            0.9,
            0.5,
            1.3,
            0.7,
          ],
          controlReturns: const [
            0.4,
            -0.4,
            0.3,
            -0.3,
            0.2,
            -0.2,
            0.1,
            -0.1,
            0.5,
            -0.5,
            0.6,
            -0.6,
            0.2,
            -0.2,
            0.3,
            -0.3,
          ],
        ),
      );

      final result = await service.validate(
        symbol: 'AAPL',
        strategy: StrategyType.trader,
        recommendation: bullishRecommendation(),
        stockBehaviorProfile: profile,
      );

      expect(result.status, HistoricalValidationStatus.available);
      expect(result.verdict, HistoricalValidationVerdict.supports);
      expect(result.alignedOutcomeRate, greaterThan(0.70));
      expect(result.edgeVsControlPercentagePoints, greaterThan(15));
      expect(result.confidenceImpactPoints, greaterThan(0));
      expect(
        result.confidenceImpactPoints,
        lessThanOrEqualTo(
          HistoricalSetupValidation.maximumConfidenceImpactPoints,
        ),
      );
      expect(result.comparisonCases, 16);
      expect(result.scoringBreakdown.edgeVsControlWeight, 0.40);
      expect(result.scoringBreakdown.followThroughWeight, 0.20);
      expect(result.scoringBreakdown.outcomeMagnitudeWeight, 0.20);
      expect(result.scoringBreakdown.excursionQualityWeight, 0.20);
      expect(result.scoringBreakdown.appliedReliability, greaterThan(0));
    },
  );

  test(
    'opposing analogs reduce confidence rather than flipping direction',
    () async {
      final service = HistoricalSetupValidationService(
        provider: _FixedOutcomeProvider(
          caseReturns: const [
            -1.2,
            -1.0,
            -0.8,
            -1.4,
            -0.6,
            -1.1,
            -0.7,
            -0.9,
            -1.3,
            -0.5,
            -1.0,
            -0.8,
            -1.2,
            -0.6,
            -1.1,
            0.4,
            0.6,
            -0.3,
            -0.7,
            -0.9,
            -1.2,
            -0.8,
            -1.0,
            0.2,
            -0.6,
            -1.1,
            -0.9,
            -0.5,
            -1.3,
            -0.7,
          ],
          controlReturns: const [
            0.4,
            -0.4,
            0.3,
            -0.3,
            0.2,
            -0.2,
            0.1,
            -0.1,
            0.5,
            -0.5,
            0.6,
            -0.6,
            0.2,
            -0.2,
            0.3,
            -0.3,
          ],
        ),
      );

      final result = await service.validate(
        symbol: 'AAPL',
        strategy: StrategyType.trader,
        recommendation: bullishRecommendation(),
        stockBehaviorProfile: profile,
      );

      expect(result.verdict, HistoricalValidationVerdict.opposes);
      expect(result.confidenceImpactPoints, lessThan(0));
      expect(result.medianDirectionalReturnPercent, lessThan(0));
    },
  );

  test(
    'matched outcomes must beat the context-matched stock baseline to earn positive confidence',
    () async {
      final service = HistoricalSetupValidationService(
        provider: _FixedOutcomeProvider(
          caseReturns: const [
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            -1,
            -1,
            -1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            -1,
            -1,
            -1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            -1,
            -1,
            -1,
          ],
          controlReturns: const [
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            -1,
            -1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            1,
            -1,
            -1,
          ],
        ),
      );

      final result = await service.validate(
        symbol: 'AAPL',
        strategy: StrategyType.trader,
        recommendation: bullishRecommendation(),
        stockBehaviorProfile: profile,
      );

      expect(result.alignedOutcomeRate, greaterThan(0.5));
      expect(
        result.alignedOutcomeRate,
        lessThan(result.controlAlignedOutcomeRate),
      );
      expect(result.confidenceImpactPoints, lessThanOrEqualTo(0));
    },
  );

  test('insufficient matches cannot influence confidence', () async {
    final service = HistoricalSetupValidationService(
      provider: _FixedOutcomeProvider(
        caseReturns: const [1, 1, 1, 1, 1],
        controlReturns: const [1, -1, 1, -1],
      ),
    );

    final result = await service.validate(
      symbol: 'AAPL',
      strategy: StrategyType.trader,
      recommendation: bullishRecommendation(),
      stockBehaviorProfile: profile,
    );

    expect(result.status, HistoricalValidationStatus.insufficientData);
    expect(result.confidenceImpactPoints, 0);
    expect(result.canInfluenceConfidence, isFalse);
  });

  test(
    'same-stock baseline ignores observations from different surrounding conditions',
    () async {
      final service = HistoricalSetupValidationService(
        provider: const _ContextMixProvider(),
      );

      final result = await service.validate(
        symbol: 'AAPL',
        strategy: StrategyType.trader,
        recommendation: bullishRecommendation(),
        stockBehaviorProfile: profile,
      );

      expect(result.status, HistoricalValidationStatus.available);
      expect(result.comparisonCases, 16);
      expect(result.controlAlignedOutcomeRate, closeTo(0.50, 0.001));
    },
  );
}

class _FixedOutcomeProvider implements HistoricalSetupProvider {
  const _FixedOutcomeProvider({
    required this.caseReturns,
    required this.controlReturns,
  });

  final List<double> caseReturns;
  final List<double> controlReturns;

  @override
  Future<HistoricalSetupDataset> loadDataset({
    required String symbol,
    required StrategyType strategy,
    required String primaryTimeframe,
    required HistoricalSetupFingerprint currentFingerprint,
    required int forwardBars,
  }) async {
    final cases = <HistoricalSetupCase>[];

    for (var index = 0; index < caseReturns.length; index++) {
      final value = caseReturns[index];
      cases.add(
        HistoricalSetupCase(
          symbol: index.isEven ? symbol : 'MSFT',
          occurredAt: DateTime.utc(2025, 1, 1).add(Duration(days: index * 5)),
          fingerprint: currentFingerprint,
          forwardReturnPercent: value,
          maxFavorableExcursionPercent: value > 0 ? value + 0.4 : 0.5,
          maxAdverseExcursionPercent: value < 0 ? value - 0.3 : -0.4,
        ),
      );
    }

    return HistoricalSetupDataset(
      cases: cases,
      comparisonObservations: [
        for (var index = 0; index < controlReturns.length; index++)
          HistoricalComparisonObservation(
            symbol: symbol,
            occurredAt: DateTime.utc(2024, 1, 1).add(Duration(days: index * 3)),
            fingerprint: currentFingerprint,
            forwardReturnPercent: controlReturns[index],
          ),
      ],
      isSynthetic: false,
      sourceLabel: 'test',
    );
  }
}

class _ContextMixProvider implements HistoricalSetupProvider {
  const _ContextMixProvider();

  @override
  Future<HistoricalSetupDataset> loadDataset({
    required String symbol,
    required StrategyType strategy,
    required String primaryTimeframe,
    required HistoricalSetupFingerprint currentFingerprint,
    required int forwardBars,
  }) async {
    final cases = [
      for (var index = 0; index < 30; index++)
        HistoricalSetupCase(
          symbol: index.isEven ? symbol : 'MSFT',
          occurredAt: DateTime.utc(2025, 1, 1).add(Duration(days: index)),
          fingerprint: currentFingerprint,
          forwardReturnPercent: index < 22 ? 1 : -1,
          maxFavorableExcursionPercent: 1.4,
          maxAdverseExcursionPercent: -0.4,
        ),
    ];

    HistoricalSetupFingerprint withBackdrop(MarketBackdrop backdrop) {
      return HistoricalSetupFingerprint(
        strategy: currentFingerprint.strategy,
        primaryTimeframe: currentFingerprint.primaryTimeframe,
        stockBehaviorType: currentFingerprint.stockBehaviorType,
        volatilityRegime: currentFingerprint.volatilityRegime,
        marketBackdrop: backdrop,
        relativeStrengthState: currentFingerprint.relativeStrengthState,
        familyDirectionScores: currentFingerprint.familyDirectionScores,
        familyStrengthScores: currentFingerprint.familyStrengthScores,
        familyImportanceWeights: currentFingerprint.familyImportanceWeights,
      );
    }

    final comparison = <HistoricalComparisonObservation>[
      for (var index = 0; index < 16; index++)
        HistoricalComparisonObservation(
          symbol: symbol,
          occurredAt: DateTime.utc(2024, 1, 1).add(Duration(days: index)),
          fingerprint: currentFingerprint,
          forwardReturnPercent: index.isEven ? 1 : -1,
        ),
      // These are deliberately all bullish. If the service accidentally uses
      // them despite the different market environment, the baseline would be
      // much higher than 50% and this test would fail.
      for (var index = 0; index < 20; index++)
        HistoricalComparisonObservation(
          symbol: symbol,
          occurredAt: DateTime.utc(2023, 1, 1).add(Duration(days: index)),
          fingerprint: withBackdrop(MarketBackdrop.challenging),
          forwardReturnPercent: 1,
        ),
    ];

    return HistoricalSetupDataset(
      cases: cases,
      comparisonObservations: comparison,
      isSynthetic: false,
      sourceLabel: 'test',
    );
  }
}

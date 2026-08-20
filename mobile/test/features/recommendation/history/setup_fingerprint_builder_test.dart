import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/market_context_profile.dart';
import 'package:mobile/features/recommendation/context/market_context_target.dart';
import 'package:mobile/features/recommendation/context/multi_timeframe_profile.dart';
import 'package:mobile/features/recommendation/context/recommendation_analysis_context.dart';
import 'package:mobile/features/recommendation/context/stock_behavior_profile.dart';
import 'package:mobile/features/recommendation/history/setup_fingerprint_builder.dart';
import 'package:mobile/features/recommendation/models/evidence_contribution.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_family_summary.dart';
import 'package:mobile/features/recommendation/models/evidence_report.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/recommendation.dart';
import 'package:mobile/features/recommendation/models/scoring_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';

void main() {
  test(
    'captures family, stock DNA and market context without provider duplication',
    () {
      const trend = EvidenceFamilySummary(
        family: EvidenceFamily.trend,
        direction: EvidenceDirection.bullish,
        directionScore: 70,
        strengthScore: 80,
        effectiveWeight: 1,
        reliability: 0.9,
        agreement: 1,
        evidenceCount: 3,
      );
      const momentum = EvidenceFamilySummary(
        family: EvidenceFamily.momentum,
        direction: EvidenceDirection.bearish,
        directionScore: -35,
        strengthScore: 60,
        effectiveWeight: 0.7,
        reliability: 0.8,
        agreement: 1,
        evidenceCount: 2,
      );

      const trendContribution = EvidenceFamilyContribution(
        family: EvidenceFamily.trend,
        direction: EvidenceDirection.bullish,
        directionImpactPoints: 50,
        directionShare: 0.7,
        confidenceContributionPoints: 42,
        confidenceShare: 0.7,
        providers: [],
      );
      const momentumContribution = EvidenceFamilyContribution(
        family: EvidenceFamily.momentum,
        direction: EvidenceDirection.bearish,
        directionImpactPoints: -21,
        directionShare: 0.3,
        confidenceContributionPoints: 18,
        confidenceShare: 0.3,
        providers: [],
      );

      final recommendation = Recommendation(
        type: RecommendationType.buy,
        evidenceScore: 60,
        oneLineExplanation: 'test',
        timeframe: '15m',
        candleCount: 48,
        analysisTime: DateTime.utc(2026, 8, 20),
        evidenceReport: EvidenceReport.fromResults(
          results: const [],
          expectedProviderCount: 0,
        ),
        consensus: const ScoringResult(
          score: 60,
          coverage: 1,
          bullishWeight: 1,
          bearishWeight: 0.4,
          neutralWeight: 0,
          warnings: [],
          directionScore: 29,
          familySummaries: [trend, momentum],
          familyContributions: [trendContribution, momentumContribution],
        ),
      );

      const profile = StockBehaviorProfile(
        behaviorType: StockBehaviorType.volatile,
        volatilityRegime: VolatilityRegime.elevated,
        averageVolume: 1,
        relativeVolume: 1,
        atrPercent: 1,
        baselineAtrPercent: 1,
        volatilityRatio: 1,
        trendEfficiency: 0.6,
        sampleSize: 48,
      );

      final analysisContext = RecommendationAnalysisContext(
        multiTimeframeProfile: MultiTimeframeProfile.unknown(),
        marketContextProfile: MarketContextProfile(
          target: const MarketContextTarget(
            marketSymbol: 'SPY',
            sectorSymbol: 'XLK',
            sectorName: 'Technology',
            hasSectorBenchmark: true,
          ),
          backdrop: MarketBackdrop.supportive,
          relativeStrength: RelativeStrengthState.outperforming,
          directionScore: 60,
          reliability: 0.9,
          stockVsMarketPercent: 2,
          stockVsSectorPercent: 1,
          sectorVsMarketPercent: 1,
          marketCompositeReturnPercent: 1,
          sectorCompositeReturnPercent: 2,
        ),
      );

      const builder = SetupFingerprintBuilder();
      final fingerprint = builder.build(
        recommendation: recommendation,
        strategy: StrategyType.trader,
        stockBehaviorProfile: profile,
        analysisContext: analysisContext,
      );

      expect(fingerprint.primaryTimeframe, '15m');
      expect(fingerprint.stockBehaviorType, StockBehaviorType.volatile);
      expect(fingerprint.volatilityRegime, VolatilityRegime.elevated);
      expect(fingerprint.marketBackdrop, MarketBackdrop.supportive);
      expect(
        fingerprint.relativeStrengthState,
        RelativeStrengthState.outperforming,
      );
      expect(fingerprint.directionScoreFor(EvidenceFamily.trend), 70);
      expect(fingerprint.strengthScoreFor(EvidenceFamily.momentum), 60);
      expect(
        fingerprint.importanceFor(EvidenceFamily.trend),
        closeTo(0.7, 0.001),
      );
      expect(
        fingerprint.familyDirectionScores.keys,
        containsAll([EvidenceFamily.trend, EvidenceFamily.momentum]),
      );
    },
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/market_context_profile.dart';
import 'package:mobile/features/recommendation/context/market_context_target.dart';
import 'package:mobile/features/recommendation/context/multi_timeframe_profile.dart';
import 'package:mobile/features/recommendation/context/strategy_timeframe_plan.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/providers/market_context_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/multi_timeframe_trend_evidence_provider.dart';

void main() {
  test('multi-timeframe evidence remains inside the Trend family', () {
    const provider = MultiTimeframeTrendEvidenceProvider();
    final profile = MultiTimeframeProfile(
      plan: StrategyTimeframePlan.trader,
      primary: const TimeframeTrendSignal(
        role: TimeframeRole.primary,
        timeframe: '5m',
        direction: EvidenceDirection.bullish,
        movePercent: 2,
        strengthScore: 70,
        trendEfficiency: 0.8,
        sampleSize: 48,
      ),
      confirmation: const TimeframeTrendSignal(
        role: TimeframeRole.confirmation,
        timeframe: '1h',
        direction: EvidenceDirection.bullish,
        movePercent: 5,
        strengthScore: 80,
        trendEfficiency: 0.85,
        sampleSize: 48,
      ),
      regime: const TimeframeTrendSignal(
        role: TimeframeRole.regime,
        timeframe: '1d',
        direction: EvidenceDirection.bullish,
        movePercent: 10,
        strengthScore: 90,
        trendEfficiency: 0.9,
        sampleSize: 48,
      ),
      alignment: TimeframeAlignment.aligned,
      directionScore: 78,
      agreement: 1,
      reliability: 0.92,
    );

    final result = provider.evaluate(profile);

    expect(result.isAvailable, isTrue);
    expect(result.definition.family, EvidenceFamily.trend);
    expect(result.direction, EvidenceDirection.bullish);
  });

  test('market context is an independent evidence family', () {
    const provider = MarketContextEvidenceProvider();
    final profile = MarketContextProfile(
      target: const MarketContextTarget(
        marketSymbol: 'SPY',
        sectorSymbol: 'XLK',
        sectorName: 'Technology',
        hasSectorBenchmark: true,
      ),
      backdrop: MarketBackdrop.supportive,
      relativeStrength: RelativeStrengthState.outperforming,
      directionScore: 68,
      reliability: 0.9,
      stockVsMarketPercent: 5,
      stockVsSectorPercent: 3,
      sectorVsMarketPercent: 2,
      marketCompositeReturnPercent: 3,
      sectorCompositeReturnPercent: 5,
    );

    final result = provider.evaluate(profile);

    expect(result.definition.family, EvidenceFamily.marketContext);
    expect(result.direction, EvidenceDirection.bullish);
    expect(result.isAvailable, isTrue);
  });
  test('Swing Market Context discounts mixed benchmark conflict', () {
    const provider = MarketContextEvidenceProvider();

    final profile = MarketContextProfile(
      target: const MarketContextTarget(
        marketSymbol: 'SPY',
        sectorSymbol: 'XLK',
        sectorName: 'Technology',
        hasSectorBenchmark: true,
      ),
      backdrop: MarketBackdrop.challenging,
      relativeStrength: RelativeStrengthState.outperforming,
      directionScore: 24,
      reliability: 0.90,
      stockVsMarketPercent: 4,
      stockVsSectorPercent: 3,
      sectorVsMarketPercent: -2,
      marketCompositeReturnPercent: -4,
      sectorCompositeReturnPercent: -3,
    );

    final result = provider.evaluate(profile, strategy: StrategyType.swing);

    expect(result.direction, EvidenceDirection.neutral);
    expect(result.baseWeight, 0.75);
    expect(result.dynamicWeight, 0.70);
    expect(result.explanation, contains('conflict'));
  });

  test(
    'strong Swing leadership can survive conflict with reduced influence',
    () {
      const provider = MarketContextEvidenceProvider();

      final profile = MarketContextProfile(
        target: const MarketContextTarget(
          marketSymbol: 'SPY',
          sectorSymbol: 'XLK',
          sectorName: 'Technology',
          hasSectorBenchmark: true,
        ),
        backdrop: MarketBackdrop.challenging,
        relativeStrength: RelativeStrengthState.outperforming,
        directionScore: 55,
        reliability: 0.90,
        stockVsMarketPercent: 8,
        stockVsSectorPercent: 7,
        sectorVsMarketPercent: -2,
        marketCompositeReturnPercent: -4,
        sectorCompositeReturnPercent: -2,
      );

      final result = provider.evaluate(profile, strategy: StrategyType.swing);

      expect(result.direction, EvidenceDirection.bullish);
      expect(result.dynamicWeight, 0.70);
    },
  );

  test('Swing Market Context preserves bullish and bearish parity', () {
    const provider = MarketContextEvidenceProvider();

    MarketContextProfile profile(double score) => MarketContextProfile(
      target: const MarketContextTarget(
        marketSymbol: 'SPY',
        sectorSymbol: 'XLK',
        sectorName: 'Technology',
        hasSectorBenchmark: true,
      ),
      backdrop: score > 0
          ? MarketBackdrop.supportive
          : MarketBackdrop.challenging,
      relativeStrength: score > 0
          ? RelativeStrengthState.outperforming
          : RelativeStrengthState.underperforming,
      directionScore: score,
      reliability: 0.90,
      stockVsMarketPercent: score > 0 ? 5 : -5,
      stockVsSectorPercent: score > 0 ? 4 : -4,
      sectorVsMarketPercent: score > 0 ? 2 : -2,
      marketCompositeReturnPercent: score > 0 ? 3 : -3,
      sectorCompositeReturnPercent: score > 0 ? 4 : -4,
    );

    final bullish = provider.evaluate(
      profile(50),
      strategy: StrategyType.swing,
    );

    final bearish = provider.evaluate(
      profile(-50),
      strategy: StrategyType.swing,
    );

    expect(bullish.direction, EvidenceDirection.bullish);
    expect(bearish.direction, EvidenceDirection.bearish);
    expect(bullish.score, bearish.score);
    expect(bullish.baseWeight, bearish.baseWeight);
    expect(bullish.dynamicWeight, bearish.dynamicWeight);
  });
}

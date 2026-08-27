import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/market_context_target.dart';
import 'package:mobile/features/recommendation/context/mock_external_context_provider.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';

void main() {
  const provider = MockExternalContextProvider();

  const target = MarketContextTarget(
    marketSymbol: 'SPY',
    sectorSymbol: 'XLK',
    sectorName: 'Technology',
    hasSectorBenchmark: true,
  );

  test(
    'returns deterministic breadth event and news context for Trader',
    () async {
      final context = await provider.load(
        symbol: 'NVDA',
        strategy: StrategyType.trader,
        primaryTimeframe: '5m',
        target: target,
      );

      expect(context.marketBreadth.isAvailable, isTrue);
      expect(context.eventRisk.isAvailable, isTrue);
      expect(context.newsSentiment.isAvailable, isTrue);

      expect(context.newsSentiment.sentimentScore, 52);
      expect(context.newsSentiment.independentStoryCount, isNotNull);

      expect(
        context.newsSentiment.independentStoryCount!,
        greaterThanOrEqualTo(2),
      );

      expect(
        context.newsSentiment.independentStoryCount!,
        lessThanOrEqualTo(context.newsSentiment.sourceCount),
      );

      expect(context.eventRisk.earningsHoursAway, 28);
      expect(context.isSynthetic, isTrue);
    },
  );

  test('preserves Trader interval-sensitive event simulation', () async {
    final oneMinute = await provider.load(
      symbol: 'AAPL',
      strategy: StrategyType.trader,
      primaryTimeframe: '1m',
      target: target,
    );

    final oneHour = await provider.load(
      symbol: 'AAPL',
      strategy: StrategyType.trader,
      primaryTimeframe: '1h',
      target: target,
    );

    expect(oneMinute.eventRisk.macroEventHoursAway, 9);
    expect(oneHour.eventRisk.macroEventHoursAway, 36);

    expect(
      oneMinute.eventRisk.confidencePenaltyPoints,
      greaterThan(oneHour.eventRisk.confidencePenaltyPoints),
    );
  });

  test('Swing uses the longer event relevance policy', () async {
    final trader = await provider.load(
      symbol: 'NVDA',
      strategy: StrategyType.trader,
      primaryTimeframe: '1h',
      target: target,
    );

    final swing = await provider.load(
      symbol: 'NVDA',
      strategy: StrategyType.swing,
      primaryTimeframe: '1d',
      target: target,
    );

    expect(trader.eventRisk.earningsHoursAway, 28);
    expect(swing.eventRisk.earningsHoursAway, 28);

    expect(trader.eventRisk.macroEventHoursAway, 36);
    expect(swing.eventRisk.macroEventHoursAway, 36);

    expect(swing.eventRisk.confidencePenaltyPoints, 11);

    expect(
      swing.eventRisk.confidencePenaltyPoints,
      greaterThan(trader.eventRisk.confidencePenaltyPoints),
    );
  });

  test(
    'Swing Event Risk is consistent across its 4H and 1D primary plans',
    () async {
      final fourHour = await provider.load(
        symbol: 'NVDA',
        strategy: StrategyType.swing,
        primaryTimeframe: '4h',
        target: target,
      );

      final daily = await provider.load(
        symbol: 'NVDA',
        strategy: StrategyType.swing,
        primaryTimeframe: '1d',
        target: target,
      );

      expect(
        fourHour.eventRisk.macroEventHoursAway,
        daily.eventRisk.macroEventHoursAway,
      );

      expect(
        fourHour.eventRisk.confidencePenaltyPoints,
        daily.eventRisk.confidencePenaltyPoints,
      );
    },
  );

  test('Investor Event Risk remains unavailable in v0.11', () async {
    final context = await provider.load(
      symbol: 'NVDA',
      strategy: StrategyType.investor,
      primaryTimeframe: '1d',
      target: target,
    );

    expect(context.eventRisk.isAvailable, isFalse);
  });
}

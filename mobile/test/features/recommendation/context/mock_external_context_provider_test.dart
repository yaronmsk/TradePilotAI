import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/mock_external_context_provider.dart';
import 'package:mobile/features/recommendation/context/market_context_target.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';

void main() {
  const provider = MockExternalContextProvider();
  const target = MarketContextTarget(
    marketSymbol: 'SPY',
    sectorSymbol: 'XLK',
    sectorName: 'Technology',
    hasSectorBenchmark: true,
  );

  test('returns deterministic breadth event and news context', () async {
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
    expect(context.eventRisk.earningsHoursAway, 28);
    expect(context.isSynthetic, isTrue);
  });

  test('changes event-risk horizon with Trader interval', () async {
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
}

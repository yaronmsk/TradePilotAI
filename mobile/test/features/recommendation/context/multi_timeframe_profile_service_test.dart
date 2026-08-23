import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/context/multi_timeframe_profile.dart';
import 'package:mobile/features/recommendation/context/multi_timeframe_profile_service.dart';
import 'package:mobile/features/recommendation/context/strategy_timeframe_plan.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';

void main() {
  const service = MultiTimeframeProfileService();

  MarketSnapshot buildSnapshot({
    required String timeframe,
    required double start,
    required double end,
    int count = 48,
  }) {
    final candles = <MarketCandle>[];

    for (var index = 0; index < count; index++) {
      final progress = count == 1 ? 0.0 : index / (count - 1);
      final close = start + ((end - start) * progress);

      candles.add(
        MarketCandle(
          timestamp: DateTime(2026, 1, 1).add(Duration(minutes: index * 5)),
          open: close - 0.05,
          high: close + 0.20,
          low: close - 0.20,
          close: close,
          volume: 1000000 + (index * 1000),
        ),
      );
    }

    return MarketSnapshot(
      symbol: 'TEST',
      timeframe: timeframe,
      timestamp: candles.last.timestamp,
      currentPrice: candles.last.close,
      currentVolume: candles.last.volume,
      candles: candles,
    );
  }

  test('preserves aligned bullish Trader context', () {
    final profile = service.evaluate(
      primary: buildSnapshot(timeframe: '5m', start: 100, end: 103),
      confirmation: buildSnapshot(timeframe: '1h', start: 100, end: 108),
      regime: buildSnapshot(timeframe: '1d', start: 100, end: 115),
    );

    expect(profile.hasSufficientData, isTrue);
    expect(profile.alignment, TimeframeAlignment.aligned);
    expect(profile.primary.direction, EvidenceDirection.bullish);
    expect(profile.confirmation.direction, EvidenceDirection.bullish);
    expect(profile.regime.direction, EvidenceDirection.bullish);
    expect(profile.directionScore, greaterThan(0));
    expect(profile.agreement, 1);
  });

  test('preserves Trader detection of higher-timeframe opposition', () {
    final profile = service.evaluate(
      primary: buildSnapshot(timeframe: '5m', start: 100, end: 104),
      confirmation: buildSnapshot(timeframe: '1h', start: 105, end: 98),
      regime: buildSnapshot(timeframe: '1d', start: 115, end: 95),
    );

    expect(profile.alignment, TimeframeAlignment.opposed);
    expect(profile.primary.direction, EvidenceDirection.bullish);
    expect(profile.confirmation.direction, EvidenceDirection.bearish);
    expect(profile.regime.direction, EvidenceDirection.bearish);
    expect(profile.agreement, lessThan(1));
  });

  test('Swing aligned broader trends fully confirm the primary setup', () {
    final profile = service.evaluate(
      primary: buildSnapshot(timeframe: '1d', start: 100, end: 112, count: 90),
      confirmation: buildSnapshot(
        timeframe: '1w',
        start: 100,
        end: 120,
        count: 78,
      ),
      regime: buildSnapshot(timeframe: '1mo', start: 100, end: 130, count: 60),
      plan: StrategyTimeframePlan.swing,
      strategy: StrategyType.swing,
    );

    expect(profile.hasSufficientData, isTrue);
    expect(profile.alignment, TimeframeAlignment.aligned);
    expect(profile.primary.direction, EvidenceDirection.bullish);
    expect(profile.directionScore, greaterThan(0));
    expect(profile.agreement, 1);
  });

  test(
    'Swing broader opposition weakens but cannot reverse primary direction',
    () {
      final profile = service.evaluate(
        primary: buildSnapshot(
          timeframe: '1d',
          start: 100,
          end: 112,
          count: 90,
        ),
        confirmation: buildSnapshot(
          timeframe: '1w',
          start: 120,
          end: 95,
          count: 78,
        ),
        regime: buildSnapshot(timeframe: '1mo', start: 130, end: 90, count: 60),
        plan: StrategyTimeframePlan.swing,
        strategy: StrategyType.swing,
      );

      expect(profile.hasSufficientData, isTrue);
      expect(profile.alignment, TimeframeAlignment.opposed);

      expect(profile.primary.direction, EvidenceDirection.bullish);
      expect(profile.confirmation.direction, EvidenceDirection.bearish);
      expect(profile.regime.direction, EvidenceDirection.bearish);

      // Higher timeframes can reduce the primary Swing setup toward neutral,
      // but cannot manufacture the opposite direction by themselves.
      expect(profile.directionScore, greaterThanOrEqualTo(0));
      expect(profile.agreement, 0);
    },
  );

  test('Investor timeframe calculation remains unavailable in v0.11', () {
    final profile = service.evaluate(
      primary: buildSnapshot(timeframe: '1w', start: 100, end: 110),
      confirmation: buildSnapshot(timeframe: '1mo', start: 100, end: 120),
      regime: buildSnapshot(timeframe: '3mo', start: 100, end: 130),
      plan: StrategyTimeframePlan.investor,
      strategy: StrategyType.investor,
    );

    expect(profile.hasSufficientData, isFalse);
    expect(profile.alignment, TimeframeAlignment.unknown);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/context/multi_timeframe_profile.dart';
import 'package:mobile/features/recommendation/context/multi_timeframe_profile_service.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';

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

  test('reports aligned bullish context when all Trader timeframes agree', () {
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

  test('detects higher-timeframe opposition to the active Trader signal', () {
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
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/providers/vwap_position_evidence_provider.dart';

void main() {
  const provider = VwapPositionEvidenceProvider();

  MarketSnapshot createSnapshot({required double latestClose}) {
    final candles = List<MarketCandle>.generate(20, (index) {
      final close = index == 19 ? latestClose : 100.0;
      return MarketCandle(
        timestamp: DateTime(2026, 8, 18, 10).add(Duration(minutes: index * 5)),
        open: close,
        high: close + 0.2,
        low: close - 0.2,
        close: close,
        volume: 1000000,
      );
    });

    return MarketSnapshot(
      symbol: 'TEST',
      timeframe: '5m',
      timestamp: candles.last.timestamp,
      currentPrice: latestClose,
      currentVolume: candles.last.volume,
      candles: candles,
    );
  }

  test('returns bullish evidence when price is materially above VWAP', () {
    final result = provider.evaluate(createSnapshot(latestClose: 103));

    expect(result.direction, EvidenceDirection.bullish);
    expect(result.definition.family, EvidenceFamily.priceStructure);
  });

  test('returns bearish evidence when price is materially below VWAP', () {
    final result = provider.evaluate(createSnapshot(latestClose: 97));

    expect(result.direction, EvidenceDirection.bearish);
  });

  test('returns neutral evidence when price is close to VWAP', () {
    final result = provider.evaluate(createSnapshot(latestClose: 100));

    expect(result.direction, EvidenceDirection.neutral);
  });
}

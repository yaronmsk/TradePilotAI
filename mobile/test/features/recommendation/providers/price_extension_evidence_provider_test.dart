import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/providers/price_extension_evidence_provider.dart';

void main() {
  const provider = PriceExtensionEvidenceProvider();

  MarketSnapshot createSnapshot({required double latestClose}) {
    final candles = List<MarketCandle>.generate(30, (index) {
      final close = index == 29 ? latestClose : 100 + ((index % 3) * 0.05);
      return MarketCandle(
        timestamp: DateTime(2026, 8, 18, 10).add(Duration(minutes: index * 5)),
        open: close - 0.05,
        high: close + 0.5,
        low: close - 0.5,
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

  test('opposes chasing when price is extremely extended upward', () {
    final result = provider.evaluate(createSnapshot(latestClose: 106));

    expect(result.direction, EvidenceDirection.bearish);
    expect(result.definition.family, EvidenceFamily.volatility);
    expect(result.explanation, contains('chase risk'));
  });

  test('opposes chasing further downside when price is extended downward', () {
    final result = provider.evaluate(createSnapshot(latestClose: 94));

    expect(result.direction, EvidenceDirection.bullish);
  });

  test('stays neutral when price is near its ATR-adjusted equilibrium', () {
    final result = provider.evaluate(createSnapshot(latestClose: 100.3));

    expect(result.direction, EvidenceDirection.neutral);
  });
}

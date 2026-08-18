import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/providers/support_resistance_evidence_provider.dart';

void main() {
  const provider = SupportResistanceEvidenceProvider();

  MarketSnapshot createSnapshot({required double latestClose}) {
    final candles = List<MarketCandle>.generate(20, (index) {
      final isLast = index == 19;
      final close = isLast ? latestClose : 100 + ((index % 4) * 0.3);
      return MarketCandle(
        timestamp: DateTime(2026, 8, 18, 10).add(Duration(minutes: index * 5)),
        open: close - 0.1,
        high: isLast ? close + 0.4 : 102,
        low: isLast ? close - 0.4 : 98,
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

  test('returns bullish evidence after a clear resistance breakout', () {
    final result = provider.evaluate(createSnapshot(latestClose: 103));

    expect(result.direction, EvidenceDirection.bullish);
    expect(result.definition.family, EvidenceFamily.priceStructure);
    expect(result.explanation, contains('broken above'));
  });

  test('returns bearish evidence after a clear support breakdown', () {
    final result = provider.evaluate(createSnapshot(latestClose: 97));

    expect(result.direction, EvidenceDirection.bearish);
    expect(result.explanation, contains('broken below'));
  });

  test('returns neutral evidence when price sits between levels', () {
    final result = provider.evaluate(createSnapshot(latestClose: 100));

    expect(result.direction, EvidenceDirection.neutral);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/providers/relative_volume_evidence_provider.dart';

void main() {
  const provider = RelativeVolumeEvidenceProvider();

  MarketSnapshot createSnapshot({
    required double currentVolume,
    required bool bullishLatest,
    int candleCount = 21,
    String timeframe = '5m',
  }) {
    final candles = List<MarketCandle>.generate(candleCount, (index) {
      final isLast = index == candleCount - 1;
      final open = 100.0;
      final close = isLast ? (bullishLatest ? 101.0 : 99.0) : 100.2;

      return MarketCandle(
        timestamp: timeframe.toLowerCase() == '1d'
            ? DateTime(2026, 7, 1).add(Duration(days: index))
            : timeframe.toLowerCase() == '4h'
            ? DateTime(2026, 8, 1, 10).add(Duration(hours: index * 4))
            : DateTime(2026, 8, 16, 10).add(Duration(minutes: index * 5)),
        open: open,
        high: 102,
        low: 98,
        close: close,
        volume: isLast ? currentVolume : 1000000,
      );
    }, growable: false);

    return MarketSnapshot(
      symbol: 'TEST',
      timeframe: timeframe,
      timestamp: candles.last.timestamp,
      currentPrice: candles.last.close,
      currentVolume: currentVolume,
      candles: candles,
    );
  }

  test('returns bullish evidence for exceptional volume on an up candle', () {
    final result = provider.evaluate(
      createSnapshot(currentVolume: 2200000, bullishLatest: true),
    );

    expect(result.status, EvidenceStatus.available);
    expect(result.direction, EvidenceDirection.bullish);
    expect(result.strength, EvidenceStrength.exceptional);
    expect(result.currentValue, '2.20x');
  });

  test('returns bearish evidence for exceptional volume on a down candle', () {
    final result = provider.evaluate(
      createSnapshot(currentVolume: 2200000, bullishLatest: false),
    );

    expect(result.direction, EvidenceDirection.bearish);
  });

  test('returns neutral evidence when volume is near average', () {
    final result = provider.evaluate(
      createSnapshot(currentVolume: 1000000, bullishLatest: true),
    );

    expect(result.direction, EvidenceDirection.neutral);
    expect(result.relativeValue, '0% above average');
  });

  test('returns insufficient data with fewer than three candles', () {
    final result = provider.evaluate(
      createSnapshot(
        currentVolume: 1000000,
        bullishLatest: true,
        candleCount: 2,
      ),
    );

    expect(result.status, EvidenceStatus.insufficientData);
    expect(result.isAvailable, isFalse);
  });
  group('Swing Relative Volume', () {
    test('Trader behavior remains unchanged through strategy interface', () {
      final snapshot = createSnapshot(
        currentVolume: 2200000,
        bullishLatest: true,
      );

      final legacy = provider.evaluate(snapshot);

      final strategyResult = provider.evaluateForStrategy(
        snapshot,
        strategy: StrategyType.trader,
      );

      expect(strategyResult.direction, legacy.direction);
      expect(strategyResult.score, legacy.score);
      expect(strategyResult.currentValue, legacy.currentValue);
    });

    test('1D Swing uses prior daily volume as a valid baseline', () {
      final result = provider.evaluateForStrategy(
        createSnapshot(
          timeframe: '1d',
          currentVolume: 2200000,
          bullishLatest: true,
          candleCount: 21,
        ),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.bullish);
      expect(result.strength, EvidenceStrength.exceptional);
      expect(result.currentValue, '2.20x');
      expect(result.baselineValue, contains('20-day average'));
      expect(result.relativeValue, contains('daily average'));
    });

    test('1D Swing preserves bullish and bearish participation parity', () {
      final bullish = provider.evaluateForStrategy(
        createSnapshot(
          timeframe: '1d',
          currentVolume: 1600000,
          bullishLatest: true,
        ),
        strategy: StrategyType.swing,
      );

      final bearish = provider.evaluateForStrategy(
        createSnapshot(
          timeframe: '1d',
          currentVolume: 1600000,
          bullishLatest: false,
        ),
        strategy: StrategyType.swing,
      );

      expect(bullish.direction, EvidenceDirection.bullish);
      expect(bearish.direction, EvidenceDirection.bearish);
      expect(bullish.score, bearish.score);
      expect(bullish.reliability, bearish.reliability);
    });

    test(
      'weak 1D participation stays neutral instead of reversing direction',
      () {
        final result = provider.evaluateForStrategy(
          createSnapshot(
            timeframe: '1d',
            currentVolume: 600000,
            bullishLatest: true,
          ),
          strategy: StrategyType.swing,
        );

        expect(result.status, EvidenceStatus.available);
        expect(result.direction, EvidenceDirection.neutral);
        expect(result.score, 35);
      },
    );

    test('1D Swing requires sufficient historical daily volume', () {
      final result = provider.evaluateForStrategy(
        createSnapshot(
          timeframe: '1d',
          currentVolume: 1500000,
          bullishLatest: true,
          candleCount: 10,
        ),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.insufficientData);
      expect(result.direction, EvidenceDirection.unknown);
    });

    test('4H Swing refuses ordinary sequential candles as RVOL baseline', () {
      final result = provider.evaluateForStrategy(
        createSnapshot(
          timeframe: '4h',
          currentVolume: 2200000,
          bullishLatest: true,
          candleCount: 21,
        ),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.unavailable);
      expect(result.direction, EvidenceDirection.unknown);
      expect(result.unavailableReason, contains('same session position'));
    });

    test('unsupported Swing timeframe and Investor remain unavailable', () {
      final unsupported = provider.evaluateForStrategy(
        createSnapshot(
          timeframe: '1h',
          currentVolume: 2200000,
          bullishLatest: true,
        ),
        strategy: StrategyType.swing,
      );

      final investor = provider.evaluateForStrategy(
        createSnapshot(
          timeframe: '1d',
          currentVolume: 2200000,
          bullishLatest: true,
        ),
        strategy: StrategyType.investor,
      );

      expect(unsupported.status, EvidenceStatus.unavailable);
      expect(unsupported.direction, EvidenceDirection.unknown);
      expect(investor.status, EvidenceStatus.unavailable);
      expect(investor.direction, EvidenceDirection.unknown);
    });
  });
}

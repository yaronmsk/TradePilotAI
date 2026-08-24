import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/providers/macd_momentum_evidence_provider.dart';

void main() {
  const provider = MacdMomentumEvidenceProvider();

  MarketSnapshot snapshotFromCloses(
    List<double> closes, {
    String timeframe = '5m',
  }) {
    final candles = List<MarketCandle>.generate(closes.length, (index) {
      final close = closes[index];
      return MarketCandle(
        timestamp: DateTime(2026, 8, 18, 10).add(Duration(minutes: index * 5)),
        open: close - 0.1,
        high: close + 0.5,
        low: close - 0.5,
        close: close,
        volume: 1000000,
      );
    });

    return MarketSnapshot(
      symbol: 'TEST',
      timeframe: timeframe,
      timestamp: candles.last.timestamp,
      currentPrice: candles.last.close,
      currentVolume: candles.last.volume,
      candles: candles,
    );
  }

  test(
    'returns bullish momentum when recent price acceleration is positive',
    () {
      final closes = List<double>.generate(48, (index) {
        final acceleration = index < 28
            ? index * 0.05
            : 1.4 + ((index - 28) * 0.55);
        return 100 + acceleration;
      });

      final result = provider.evaluate(snapshotFromCloses(closes));

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.bullish);
      expect(result.definition.family, EvidenceFamily.momentum);
      expect(result.relativeValue, contains('Histogram'));
    },
  );

  test(
    'returns bearish momentum when recent price acceleration is negative',
    () {
      final closes = List<double>.generate(48, (index) {
        final acceleration = index < 28
            ? index * -0.05
            : -1.4 - ((index - 28) * 0.55);
        return 120 + acceleration;
      });

      final result = provider.evaluate(snapshotFromCloses(closes));

      expect(result.direction, EvidenceDirection.bearish);
    },
  );

  test('returns insufficient data with fewer than required candles', () {
    final result = provider.evaluate(snapshotFromCloses(List.filled(20, 100)));

    expect(result.status, EvidenceStatus.insufficientData);
  });
  group('Swing MACD Momentum', () {
    test('Trader path remains unchanged', () {
      final closes = List<double>.generate(48, (index) => 100 + (index * 0.3));

      final snapshot = snapshotFromCloses(closes);

      final legacy = provider.evaluate(snapshot);

      final strategyResult = provider.evaluateForStrategy(
        snapshot,
        strategy: StrategyType.trader,
      );

      expect(strategyResult.direction, legacy.direction);
      expect(strategyResult.score, legacy.score);
      expect(strategyResult.currentValue, legacy.currentValue);
    });

    test(
      'accelerating Swing structures preserve bullish and bearish symmetry',
      () {
        final bullish = provider.evaluateForStrategy(
          snapshotFromCloses(
            List<double>.generate(60, (index) => 100 + (0.02 * index * index)),
            timeframe: '1d',
          ),
          strategy: StrategyType.swing,
        );

        final bearish = provider.evaluateForStrategy(
          snapshotFromCloses(
            List<double>.generate(60, (index) => 150 - (0.02 * index * index)),
            timeframe: '1d',
          ),
          strategy: StrategyType.swing,
        );

        expect(bullish.direction, EvidenceDirection.bullish);
        expect(bearish.direction, EvidenceDirection.bearish);
        expect(bullish.score, bearish.score);
        expect(bullish.reliability, closeTo(bearish.reliability, 0.001));
        expect(bullish.relativeValue, contains('× ATR'));
      },
    );

    test(
      'fresh bullish crossover below zero is an early bullish transition',
      () {
        final closes = List<double>.generate(
          57,
          (index) => 120 - (index * 0.3),
        );

        var value = closes.last;

        for (var index = 0; index < 3; index++) {
          value += 1;
          closes.add(value);
        }

        final result = provider.evaluateForStrategy(
          snapshotFromCloses(closes, timeframe: '1d'),
          strategy: StrategyType.swing,
        );

        expect(result.direction, EvidenceDirection.bullish);
        expect(result.relativeValue, contains('fresh bullish crossover'));
        expect(result.relativeValue, contains('below zero line'));
        expect(result.dynamicWeight, lessThan(1));
      },
    );

    test('fresh bearish crossover above zero is symmetric', () {
      final closes = List<double>.generate(57, (index) => 100 + (index * 0.3));

      var value = closes.last;

      for (var index = 0; index < 3; index++) {
        value -= 1;
        closes.add(value);
      }

      final result = provider.evaluateForStrategy(
        snapshotFromCloses(closes, timeframe: '1d'),
        strategy: StrategyType.swing,
      );

      expect(result.direction, EvidenceDirection.bearish);
      expect(result.relativeValue, contains('fresh bearish crossover'));
      expect(result.relativeValue, contains('above zero line'));
      expect(result.dynamicWeight, lessThan(1));
    });

    test(
      'weakening bullish momentum keeps direction but reduces influence',
      () {
        final closes = List<double>.generate(
          50,
          (index) => 100 + (index * 0.4),
        );

        var value = closes.last;

        for (var index = 0; index < 10; index++) {
          value += 0.4;
          closes.add(value);
        }

        final result = provider.evaluateForStrategy(
          snapshotFromCloses(closes, timeframe: '1d'),
          strategy: StrategyType.swing,
        );

        expect(result.direction, EvidenceDirection.bullish);
        expect(result.relativeValue, contains('weakening'));
        expect(result.dynamicWeight, lessThan(1));
      },
    );

    test('4H Swing MACD is supported', () {
      final result = provider.evaluateForStrategy(
        snapshotFromCloses(
          List<double>.generate(60, (index) => 100 + (0.02 * index * index)),
          timeframe: '4h',
        ),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.bullish);
      expect(result.relativeValue, contains('× ATR'));
    });

    test('unsupported Swing timeframe and Investor remain unavailable', () {
      final closes = List<double>.generate(60, (index) => 100 + (index * 0.3));

      final unsupported = provider.evaluateForStrategy(
        snapshotFromCloses(closes, timeframe: '1h'),
        strategy: StrategyType.swing,
      );

      final investor = provider.evaluateForStrategy(
        snapshotFromCloses(closes, timeframe: '1d'),
        strategy: StrategyType.investor,
      );

      expect(unsupported.status, EvidenceStatus.unavailable);
      expect(unsupported.direction, EvidenceDirection.unknown);

      expect(investor.status, EvidenceStatus.unavailable);
      expect(investor.direction, EvidenceDirection.unknown);
    });
  });
}

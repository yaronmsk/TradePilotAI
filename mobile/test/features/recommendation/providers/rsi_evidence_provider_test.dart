import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/providers/rsi_evidence_provider.dart';

void main() {
  const provider = RsiEvidenceProvider();

  MarketSnapshot createSnapshot({
    required List<double> closes,
    String timeframe = '5m',
  }) {
    final candles = List<MarketCandle>.generate(closes.length, (index) {
      final close = closes[index];

      return MarketCandle(
        timestamp: DateTime(2026, 8, 14, 10).add(Duration(minutes: index * 5)),
        open: close,
        high: close,
        low: close,
        close: close,
        volume: 1000000,
      );
    }, growable: false);

    return MarketSnapshot(
      symbol: 'TEST',
      timeframe: timeframe,
      timestamp: candles.isEmpty
          ? DateTime(2026, 8, 14)
          : candles.last.timestamp,
      currentPrice: candles.isEmpty ? 0 : candles.last.close,
      currentVolume: candles.isEmpty ? 0 : candles.last.volume,
      candles: candles,
    );
  }

  group('RsiEvidenceProvider', () {
    test('exposes its definition', () {
      expect(provider.name, 'RSI');
      expect(provider.definition.name, 'RSI');
    });

    test('returns insufficient data when fewer than 15 candles exist', () {
      final result = provider.evaluate(
        createSnapshot(
          closes: List<double>.generate(14, (index) => 100 + index.toDouble()),
        ),
      );

      expect(result.status, EvidenceStatus.insufficientData);
      expect(result.isAvailable, isFalse);
      expect(result.reliability, 0);
    });

    test('returns bearish evidence for strongly rising prices', () {
      final result = provider.evaluate(
        createSnapshot(
          closes: List<double>.generate(20, (index) => 100 + index.toDouble()),
        ),
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.bearish);
      expect(result.currentValue, '100.00');
      expect(result.relativeValue, 'Overbought');
    });

    test('returns bullish evidence for strongly falling prices', () {
      final result = provider.evaluate(
        createSnapshot(
          closes: List<double>.generate(20, (index) => 120 - index.toDouble()),
        ),
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.bullish);
      expect(result.currentValue, '0.00');
      expect(result.relativeValue, 'Oversold');
    });

    test('returns neutral evidence for alternating prices', () {
      final closes = List<double>.generate(
        20,
        (index) => index.isEven ? 100 : 101,
      );

      final result = provider.evaluate(createSnapshot(closes: closes));

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.neutral);
      expect(result.relativeValue, 'Neutral');
    });

    test('reliability does not exceed 90 percent', () {
      final result = provider.evaluate(
        createSnapshot(
          closes: List<double>.generate(60, (index) => 100 + (index * 0.1)),
        ),
      );

      expect(result.reliability, lessThanOrEqualTo(0.90));
    });
  });
  group('Swing RSI', () {
    test('Trader behavior remains unchanged through strategy interface', () {
      final snapshot = createSnapshot(
        closes: List<double>.generate(20, (index) => 100 + index.toDouble()),
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

    test(
      'strong rising Swing trend does not turn RSI 100 into SELL evidence',
      () {
        final result = provider.evaluateForStrategy(
          createSnapshot(
            timeframe: '1d',
            closes: List<double>.generate(80, (index) => 100 + (index * 0.5)),
          ),
          strategy: StrategyType.swing,
        );

        expect(result.status, EvidenceStatus.available);
        expect(result.direction, EvidenceDirection.bullish);
        expect(result.currentValue, 'RSI 100.00');
        expect(result.relativeValue, contains('extended'));
        expect(result.dynamicWeight, lessThan(1));
        expect(
          result.explanation,
          contains('does not convert this condition into automatic bearish'),
        );
      },
    );

    test(
      'strong falling Swing trend does not turn RSI 0 into BUY evidence',
      () {
        final result = provider.evaluateForStrategy(
          createSnapshot(
            timeframe: '1d',
            closes: List<double>.generate(80, (index) => 140 - (index * 0.5)),
          ),
          strategy: StrategyType.swing,
        );

        expect(result.status, EvidenceStatus.available);
        expect(result.direction, EvidenceDirection.bearish);
        expect(result.currentValue, 'RSI 0.00');
        expect(result.relativeValue, contains('extended'));
        expect(result.dynamicWeight, lessThan(1));
        expect(
          result.explanation,
          contains('does not convert this condition into automatic bullish'),
        );
      },
    );

    test(
      'moderate bullish RSI confirms established bullish Swing structure',
      () {
        final closes = <double>[];

        for (var index = 0; index < 66; index++) {
          closes.add(100 + (index * 0.5));
        }

        var value = closes.last;

        for (var index = 0; index < 14; index++) {
          value += index.isEven ? 1.0 : -0.5;
          closes.add(value);
        }

        final result = provider.evaluateForStrategy(
          createSnapshot(timeframe: '1d', closes: closes),
          strategy: StrategyType.swing,
        );

        expect(result.direction, EvidenceDirection.bullish);
        expect(
          result.relativeValue,
          anyOf(
            contains('Bullish momentum confirmation'),
            contains('Moderate bullish momentum'),
          ),
        );
        expect(
          result.explanation,
          contains('does not create another Trend-family vote'),
        );
      },
    );

    test(
      'moderate bearish RSI confirms established bearish Swing structure',
      () {
        final closes = <double>[];

        for (var index = 0; index < 66; index++) {
          closes.add(140 - (index * 0.5));
        }

        var value = closes.last;

        for (var index = 0; index < 14; index++) {
          value += index.isEven ? -1.0 : 0.5;
          closes.add(value);
        }

        final result = provider.evaluateForStrategy(
          createSnapshot(timeframe: '1d', closes: closes),
          strategy: StrategyType.swing,
        );

        expect(result.direction, EvidenceDirection.bearish);
        expect(
          result.relativeValue,
          anyOf(
            contains('Bearish momentum confirmation'),
            contains('Moderate bearish momentum'),
          ),
        );
      },
    );

    test('4H Swing RSI is supported', () {
      final result = provider.evaluateForStrategy(
        createSnapshot(
          timeframe: '4h',
          closes: List<double>.generate(60, (index) => 100 + (index * 0.3)),
        ),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.bullish);
    });

    test('unsupported Swing timeframe and Investor remain unavailable', () {
      final closes = List<double>.generate(80, (index) => 100 + (index * 0.2));

      final unsupported = provider.evaluateForStrategy(
        createSnapshot(timeframe: '1h', closes: closes),
        strategy: StrategyType.swing,
      );

      final investor = provider.evaluateForStrategy(
        createSnapshot(timeframe: '1d', closes: closes),
        strategy: StrategyType.investor,
      );

      expect(unsupported.status, EvidenceStatus.unavailable);
      expect(unsupported.direction, EvidenceDirection.unknown);
      expect(investor.status, EvidenceStatus.unavailable);
      expect(investor.direction, EvidenceDirection.unknown);
    });
  });
}

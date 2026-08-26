import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/providers/price_extension_evidence_provider.dart';

void main() {
  const provider = PriceExtensionEvidenceProvider();

  MarketSnapshot createSnapshot({
    required double latestClose,
    String timeframe = '5m',
    int candleCount = 30,
  }) {
    final candles = List<MarketCandle>.generate(candleCount, (index) {
      final isLast = index == candleCount - 1;

      final close = isLast ? latestClose : 100 + ((index % 3) * 0.05);

      final timestamp = switch (timeframe.toLowerCase()) {
        '1d' => DateTime(2026, 6, 1).add(Duration(days: index)),
        '4h' => DateTime(2026, 6, 1, 10).add(Duration(hours: index * 4)),
        _ => DateTime(2026, 8, 18, 10).add(Duration(minutes: index * 5)),
      };

      return MarketCandle(
        timestamp: timestamp,
        open: close - 0.05,
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
      currentPrice: latestClose,
      currentVolume: candles.last.volume,
      candles: candles,
    );
  }

  group('Trader Price Extension regression', () {
    test('opposes chasing when price is extremely extended upward', () {
      final result = provider.evaluate(createSnapshot(latestClose: 106));

      expect(result.direction, EvidenceDirection.bearish);
      expect(result.definition.family, EvidenceFamily.volatility);
      expect(result.explanation, contains('chase risk'));
    });

    test(
      'opposes chasing further downside when price is extended downward',
      () {
        final result = provider.evaluate(createSnapshot(latestClose: 94));

        expect(result.direction, EvidenceDirection.bullish);
      },
    );

    test('stays neutral when price is near its ATR-adjusted equilibrium', () {
      final result = provider.evaluate(createSnapshot(latestClose: 100.3));

      expect(result.direction, EvidenceDirection.neutral);
    });

    test('strategy-aware Trader path preserves legacy result', () {
      final snapshot = createSnapshot(latestClose: 106);

      final legacy = provider.evaluate(snapshot);

      final strategyResult = provider.evaluateForStrategy(
        snapshot,
        strategy: StrategyType.trader,
      );

      expect(strategyResult.direction, legacy.direction);
      expect(strategyResult.strength, legacy.strength);
      expect(strategyResult.score, legacy.score);
      expect(strategyResult.currentValue, legacy.currentValue);
      expect(strategyResult.relativeValue, legacy.relativeValue);
    });
  });

  group('Swing Price Extension', () {
    test('large positive extension stays directionally neutral', () {
      final result = provider.evaluateForStrategy(
        createSnapshot(latestClose: 106, timeframe: '1d', candleCount: 50),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.neutral);
      expect(result.relativeValue, contains('Very extended'));
      expect(
        result.explanation,
        contains('cannot create or flip BUY/SELL direction'),
      );
    });

    test('large negative extension also stays directionally neutral', () {
      final result = provider.evaluateForStrategy(
        createSnapshot(latestClose: 94, timeframe: '1d', candleCount: 50),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.neutral);
      expect(result.relativeValue, contains('Very extended'));
    });

    test('positive and negative extension preserve risk parity', () {
      final above = provider.evaluateForStrategy(
        createSnapshot(latestClose: 106, timeframe: '1d', candleCount: 50),
        strategy: StrategyType.swing,
      );

      final below = provider.evaluateForStrategy(
        createSnapshot(latestClose: 94, timeframe: '1d', candleCount: 50),
        strategy: StrategyType.swing,
      );

      expect(above.direction, EvidenceDirection.neutral);
      expect(below.direction, EvidenceDirection.neutral);
      expect(above.strength, below.strength);
      expect(above.score, below.score);
      expect(above.reliability, below.reliability);
    });

    test('entry-quality score decreases as extension increases', () {
      final normal = provider.evaluateForStrategy(
        createSnapshot(latestClose: 100.3, timeframe: '1d', candleCount: 50),
        strategy: StrategyType.swing,
      );

      final elevated = provider.evaluateForStrategy(
        createSnapshot(latestClose: 102, timeframe: '1d', candleCount: 50),
        strategy: StrategyType.swing,
      );

      final extended = provider.evaluateForStrategy(
        createSnapshot(latestClose: 103, timeframe: '1d', candleCount: 50),
        strategy: StrategyType.swing,
      );

      final veryExtended = provider.evaluateForStrategy(
        createSnapshot(latestClose: 106, timeframe: '1d', candleCount: 50),
        strategy: StrategyType.swing,
      );

      expect(normal.score, greaterThan(elevated.score));
      expect(elevated.score, greaterThan(extended.score));
      expect(extended.score, greaterThan(veryExtended.score));

      expect(normal.direction, EvidenceDirection.neutral);
      expect(elevated.direction, EvidenceDirection.neutral);
      expect(extended.direction, EvidenceDirection.neutral);
      expect(veryExtended.direction, EvidenceDirection.neutral);
    });

    test('4H uses its own Swing extension policy', () {
      final result = provider.evaluateForStrategy(
        createSnapshot(latestClose: 106, timeframe: '4h', candleCount: 60),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.neutral);
      expect(result.baselineValue, contains('EMA 20'));
      expect(result.relativeValue, contains('Very extended'));
    });

    test('Swing requires strategy-specific history', () {
      final result = provider.evaluateForStrategy(
        createSnapshot(latestClose: 106, timeframe: '1d', candleCount: 20),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.insufficientData);

      expect(result.direction, EvidenceDirection.unknown);
    });

    test('unsupported Swing interval and Investor remain unavailable', () {
      final unsupported = provider.evaluateForStrategy(
        createSnapshot(latestClose: 106, timeframe: '1h', candleCount: 50),
        strategy: StrategyType.swing,
      );

      final investor = provider.evaluateForStrategy(
        createSnapshot(latestClose: 106, timeframe: '1d', candleCount: 50),
        strategy: StrategyType.investor,
      );

      expect(unsupported.status, EvidenceStatus.unavailable);

      expect(unsupported.direction, EvidenceDirection.unknown);

      expect(investor.status, EvidenceStatus.unavailable);

      expect(investor.direction, EvidenceDirection.unknown);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/market/models/market_candle.dart';
import 'package:mobile/features/market/models/market_snapshot.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/providers/support_resistance_evidence_provider.dart';

void main() {
  const provider = SupportResistanceEvidenceProvider();

  MarketSnapshot createTraderSnapshot({required double latestClose}) {
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

  MarketSnapshot createSwingSnapshot({
    required String scenario,
    String timeframe = '1d',
  }) {
    final isFourHour = timeframe.toLowerCase() == '4h';

    final referenceCount = isFourHour ? 60 : 40;
    final confirmationCount = isFourHour ? 3 : 2;

    final candles = <MarketCandle>[];

    for (var index = 0; index < referenceCount; index++) {
      candles.add(
        MarketCandle(
          timestamp: isFourHour
              ? DateTime(2026, 6, 1).add(Duration(hours: index * 4))
              : DateTime(2026, 6, 1).add(Duration(days: index)),
          open: 100,
          high: 101,
          low: 99,
          close: 100,
          volume: 1000000,
        ),
      );
    }

    for (var index = 0; index < confirmationCount; index++) {
      final isLast = index == confirmationCount - 1;

      double open;
      double high;
      double low;
      double close;

      switch (scenario) {
        case 'breakout':
          close = 101.60 + (index * 0.10);
          open = close - 0.20;
          high = close + 0.20;
          low = close - 0.20;

        case 'breakdown':
          close = 98.40 - (index * 0.10);
          open = close + 0.20;
          high = close + 0.20;
          low = close - 0.20;

        case 'nearResistance':
          close = 100.80;
          open = close;
          high = 101.00;
          low = 100.50;

        case 'nearSupport':
          close = 99.20;
          open = close;
          high = 99.50;
          low = 99.00;

        case 'rejectResistance':
          if (isLast) {
            open = 100.90;
            high = 101.10;
            low = 100.20;
            close = 100.40;
          } else {
            open = 100.50;
            high = 100.70;
            low = 100.30;
            close = 100.50;
          }

        case 'rejectSupport':
          if (isLast) {
            open = 99.10;
            high = 99.80;
            low = 98.90;
            close = 99.60;
          } else {
            open = 99.50;
            high = 99.70;
            low = 99.30;
            close = 99.50;
          }

        default:
          throw ArgumentError('Unknown scenario: $scenario');
      }

      final absoluteIndex = referenceCount + index;

      candles.add(
        MarketCandle(
          timestamp: isFourHour
              ? DateTime(2026, 6, 1).add(Duration(hours: absoluteIndex * 4))
              : DateTime(2026, 6, 1).add(Duration(days: absoluteIndex)),
          open: open,
          high: high,
          low: low,
          close: close,
          volume: 1000000,
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

  group('Trader Support & Resistance regression', () {
    test('returns bullish evidence after a clear resistance breakout', () {
      final result = provider.evaluate(createTraderSnapshot(latestClose: 103));

      expect(result.direction, EvidenceDirection.bullish);
      expect(result.definition.family, EvidenceFamily.priceStructure);
      expect(result.explanation, contains('broken above'));
    });

    test('returns bearish evidence after a clear support breakdown', () {
      final result = provider.evaluate(createTraderSnapshot(latestClose: 97));

      expect(result.direction, EvidenceDirection.bearish);
      expect(result.explanation, contains('broken below'));
    });

    test('returns neutral evidence when price sits between levels', () {
      final result = provider.evaluate(createTraderSnapshot(latestClose: 100));

      expect(result.direction, EvidenceDirection.neutral);
    });

    test('strategy-aware Trader path preserves legacy behavior', () {
      final snapshot = createTraderSnapshot(latestClose: 103);

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

  group('Swing Support & Resistance', () {
    test('proximity to resistance alone is directionally neutral', () {
      final result = provider.evaluateForStrategy(
        createSwingSnapshot(scenario: 'nearResistance'),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.neutral);
      expect(result.explanation, contains('entry/risk context'));
    });

    test('proximity to support alone is directionally neutral', () {
      final result = provider.evaluateForStrategy(
        createSwingSnapshot(scenario: 'nearSupport'),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.neutral);
      expect(result.explanation, contains('entry/risk context'));
    });

    test('confirmed breakout and breakdown preserve direction parity', () {
      final breakout = provider.evaluateForStrategy(
        createSwingSnapshot(scenario: 'breakout'),
        strategy: StrategyType.swing,
      );

      final breakdown = provider.evaluateForStrategy(
        createSwingSnapshot(scenario: 'breakdown'),
        strategy: StrategyType.swing,
      );

      expect(breakout.direction, EvidenceDirection.bullish);
      expect(breakdown.direction, EvidenceDirection.bearish);
      expect(breakout.score, breakdown.score);
      expect(breakout.explanation, contains('confirming a Swing breakout'));
      expect(breakdown.explanation, contains('confirming a Swing breakdown'));
    });

    test('support and resistance rejections preserve direction parity', () {
      final supportHold = provider.evaluateForStrategy(
        createSwingSnapshot(scenario: 'rejectSupport'),
        strategy: StrategyType.swing,
      );

      final resistanceReject = provider.evaluateForStrategy(
        createSwingSnapshot(scenario: 'rejectResistance'),
        strategy: StrategyType.swing,
      );

      expect(supportHold.direction, EvidenceDirection.bullish);
      expect(resistanceReject.direction, EvidenceDirection.bearish);
      expect(supportHold.score, resistanceReject.score);
      expect(supportHold.explanation, contains('rejection/hold'));
      expect(resistanceReject.explanation, contains('rejection'));
    });

    test('4H uses its longer confirmation requirement', () {
      final result = provider.evaluateForStrategy(
        createSwingSnapshot(scenario: 'breakout', timeframe: '4h'),
        strategy: StrategyType.swing,
      );

      expect(result.status, EvidenceStatus.available);
      expect(result.direction, EvidenceDirection.bullish);
      expect(result.explanation, contains('3 consecutive'));
      expect(result.baselineValue, contains('60-candle structure'));
    });

    test('unsupported Swing interval and Investor remain unavailable', () {
      final base = createSwingSnapshot(scenario: 'breakout');

      final unsupported = MarketSnapshot(
        symbol: base.symbol,
        timeframe: '1h',
        timestamp: base.timestamp,
        currentPrice: base.currentPrice,
        currentVolume: base.currentVolume,
        candles: base.candles,
      );

      final swingResult = provider.evaluateForStrategy(
        unsupported,
        strategy: StrategyType.swing,
      );

      final investorResult = provider.evaluateForStrategy(
        base,
        strategy: StrategyType.investor,
      );

      expect(swingResult.status, EvidenceStatus.unavailable);
      expect(swingResult.direction, EvidenceDirection.unknown);
      expect(investorResult.status, EvidenceStatus.unavailable);
      expect(investorResult.direction, EvidenceDirection.unknown);
    });
  });
}

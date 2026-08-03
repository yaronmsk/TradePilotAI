import '../models/market_candle.dart';
import '../models/market_snapshot.dart';
import 'market_data_provider.dart';

class MockMarketDataProvider implements MarketDataProvider {
  const MockMarketDataProvider();

  @override
  Future<MarketSnapshot> fetchSnapshot({
    required String symbol,
    required String timeframe,
    required int candleCount,
  }) async {
    final normalizedSymbol = symbol.trim().toUpperCase();

    if (normalizedSymbol.isEmpty) {
      throw ArgumentError.value(symbol, 'symbol', 'Symbol cannot be empty.');
    }

    if (candleCount <= 0) {
      throw ArgumentError.value(
        candleCount,
        'candleCount',
        'Candle count must be greater than zero.',
      );
    }

    final intervalMinutes = _intervalMinutes(timeframe);
    final now = DateTime.now();
    final behavior = _behaviorForSymbol(normalizedSymbol);

    final candles = List<MarketCandle>.generate(candleCount, (index) {
      final timestamp = now.subtract(
        Duration(minutes: intervalMinutes * (candleCount - index - 1)),
      );

      final progress = candleCount == 1 ? 0.0 : index / (candleCount - 1);

      final basePrice =
          behavior.startPrice + (behavior.totalPriceChange * progress);

      final variation = _variationForIndex(index, behavior.volatility);

      final open = basePrice + variation;
      final close =
          basePrice + _closeAdjustmentForIndex(index, behavior.closeBias);

      final high = (open > close ? open : close) + behavior.rangePadding;
      final low = (open < close ? open : close) - behavior.rangePadding;

      final volume = behavior.baseVolume + (index * behavior.volumeStep);

      return MarketCandle(
        timestamp: timestamp,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      );
    }, growable: false);

    final latestCandle = candles.last;

    return MarketSnapshot(
      symbol: normalizedSymbol,
      timeframe: timeframe,
      timestamp: latestCandle.timestamp,
      currentPrice: latestCandle.close,
      currentVolume: latestCandle.volume,
      candles: List<MarketCandle>.unmodifiable(candles),
    );
  }

  _MockMarketBehavior _behaviorForSymbol(String symbol) {
    switch (symbol) {
      case 'NVDA':
        return const _MockMarketBehavior(
          startPrice: 100,
          totalPriceChange: 12,
          volatility: 0.35,
          closeBias: 0.80,
          rangePadding: 0.45,
          baseVolume: 1800000,
          volumeStep: 35000,
        );

      case 'AMD':
        return const _MockMarketBehavior(
          startPrice: 95,
          totalPriceChange: 3,
          volatility: 0.30,
          closeBias: 0.40,
          rangePadding: 0.40,
          baseVolume: 1400000,
          volumeStep: 25000,
        );

      case 'TSLA':
        return const _MockMarketBehavior(
          startPrice: 110,
          totalPriceChange: -10,
          volatility: 0.45,
          closeBias: -0.70,
          rangePadding: 0.50,
          baseVolume: 1700000,
          volumeStep: 30000,
        );

      case 'PLTR':
        return const _MockMarketBehavior(
          startPrice: 80,
          totalPriceChange: -3,
          volatility: 0.40,
          closeBias: -0.35,
          rangePadding: 0.45,
          baseVolume: 1200000,
          volumeStep: 22000,
        );

      case 'AAPL':
        return const _MockMarketBehavior(
          startPrice: 100,
          totalPriceChange: 0.8,
          volatility: 0.20,
          closeBias: 0.05,
          rangePadding: 0.30,
          baseVolume: 1000000,
          volumeStep: 15000,
        );

      case 'MSFT':
        return const _MockMarketBehavior(
          startPrice: 105,
          totalPriceChange: 1.2,
          volatility: 0.20,
          closeBias: 0.10,
          rangePadding: 0.30,
          baseVolume: 1100000,
          volumeStep: 17000,
        );

      case 'GOOG':
        return const _MockMarketBehavior(
          startPrice: 102,
          totalPriceChange: -0.6,
          volatility: 0.20,
          closeBias: -0.05,
          rangePadding: 0.30,
          baseVolume: 1050000,
          volumeStep: 16000,
        );

      default:
        return _behaviorFromSymbolHash(symbol);
    }
  }

  _MockMarketBehavior _behaviorFromSymbolHash(String symbol) {
    final hash = symbol.codeUnits.fold<int>(
      0,
      (value, element) => value + element,
    );

    final directionIndex = hash % 5;

    final totalPriceChange = switch (directionIndex) {
      0 => 7.0,
      1 => 3.0,
      2 => 0.5,
      3 => -3.0,
      _ => -7.0,
    };

    return _MockMarketBehavior(
      startPrice: 90 + (hash % 30).toDouble(),
      totalPriceChange: totalPriceChange,
      volatility: 0.25 + ((hash % 4) * 0.05),
      closeBias: totalPriceChange == 0
          ? 0
          : totalPriceChange > 0
          ? 0.25
          : -0.25,
      rangePadding: 0.35,
      baseVolume: 900000 + ((hash % 10) * 50000),
      volumeStep: 18000 + ((hash % 5) * 3000),
    );
  }

  double _variationForIndex(int index, double volatility) {
    final pattern = switch (index % 4) {
      0 => -1.0,
      1 => 0.4,
      2 => 1.0,
      _ => -0.3,
    };

    return pattern * volatility;
  }

  double _closeAdjustmentForIndex(int index, double closeBias) {
    final alternatingAdjustment = index.isEven ? closeBias : closeBias * 0.55;

    return alternatingAdjustment;
  }

  int _intervalMinutes(String timeframe) {
    switch (timeframe) {
      case '1m':
        return 1;
      case '5m':
        return 5;
      case '10m':
        return 10;
      case '15m':
        return 15;
      case '1h':
        return 60;
      case '1d':
        return 1440;
      default:
        throw ArgumentError.value(
          timeframe,
          'timeframe',
          'Unsupported timeframe.',
        );
    }
  }
}

class _MockMarketBehavior {
  const _MockMarketBehavior({
    required this.startPrice,
    required this.totalPriceChange,
    required this.volatility,
    required this.closeBias,
    required this.rangePadding,
    required this.baseVolume,
    required this.volumeStep,
  });

  final double startPrice;
  final double totalPriceChange;
  final double volatility;
  final double closeBias;
  final double rangePadding;
  final double baseVolume;
  final double volumeStep;
}

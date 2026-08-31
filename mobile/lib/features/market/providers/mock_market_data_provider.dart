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
    final behavior = _behaviorForSymbol(normalizedSymbol, timeframe);

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

  _MockMarketBehavior _behaviorForSymbol(String symbol, String timeframe) {
    switch (symbol) {
      case 'BULL':
        // Explicit development-only bullish fixture used to exercise the
        // complete Swing BUY presentation path. It does not bypass any
        // recommendation threshold or scoring rule.
        return _MockMarketBehavior(
          startPrice: 100,
          totalPriceChange: _timeframeMove(
            timeframe,
            shortTerm: 16,
            confirmation: 14,
            regime: 24,
          ),
          volatility: 0.28,
          closeBias: 0.90,
          rangePadding: 0.40,
          baseVolume: 2100000,
          volumeStep: 50000,
        );

      case 'NVDA':
        return _MockMarketBehavior(
          startPrice: 100,
          totalPriceChange: _timeframeMove(
            timeframe,
            shortTerm: 12,
            confirmation: 7,
            regime: 18,
          ),
          volatility: 0.35,
          closeBias: 0.80,
          rangePadding: 0.45,
          baseVolume: 1800000,
          volumeStep: 35000,
        );

      case 'AMD':
        return _MockMarketBehavior(
          startPrice: 95,
          totalPriceChange: _timeframeMove(
            timeframe,
            shortTerm: 3,
            confirmation: 4,
            regime: 9,
          ),
          volatility: 0.30,
          closeBias: 0.40,
          rangePadding: 0.40,
          baseVolume: 1400000,
          volumeStep: 25000,
        );

      case 'TSLA':
        return _MockMarketBehavior(
          startPrice: 110,
          totalPriceChange: _timeframeMove(
            timeframe,
            shortTerm: -10,
            confirmation: -6,
            regime: 4,
          ),
          volatility: 0.45,
          closeBias: -0.70,
          rangePadding: 0.50,
          baseVolume: 1700000,
          volumeStep: 30000,
        );

      case 'PLTR':
        return _MockMarketBehavior(
          startPrice: 80,
          totalPriceChange: _timeframeMove(
            timeframe,
            shortTerm: -3,
            confirmation: 4,
            regime: 15,
          ),
          volatility: 0.40,
          closeBias: -0.35,
          rangePadding: 0.45,
          baseVolume: 1200000,
          volumeStep: 22000,
        );

      case 'AAPL':
        return _MockMarketBehavior(
          startPrice: 100,
          totalPriceChange: _timeframeMove(
            timeframe,
            shortTerm: 0.8,
            confirmation: 2.4,
            regime: 4.5,
          ),
          volatility: 0.20,
          closeBias: 0.05,
          rangePadding: 0.30,
          baseVolume: 1000000,
          volumeStep: 15000,
        );

      case 'MSFT':
        return _MockMarketBehavior(
          startPrice: 105,
          totalPriceChange: _timeframeMove(
            timeframe,
            shortTerm: 1.2,
            confirmation: 2.2,
            regime: 5.5,
          ),
          volatility: 0.20,
          closeBias: 0.10,
          rangePadding: 0.30,
          baseVolume: 1100000,
          volumeStep: 17000,
        );

      case 'GOOG':
        return _MockMarketBehavior(
          startPrice: 102,
          totalPriceChange: _timeframeMove(
            timeframe,
            shortTerm: -0.6,
            confirmation: -2,
            regime: 2.5,
          ),
          volatility: 0.20,
          closeBias: -0.05,
          rangePadding: 0.30,
          baseVolume: 1050000,
          volumeStep: 16000,
        );

      case 'SPY':
        return _MockMarketBehavior(
          startPrice: 100,
          totalPriceChange: _timeframeMove(
            timeframe,
            shortTerm: 0.7,
            confirmation: 1.5,
            regime: 4,
          ),
          volatility: 0.14,
          closeBias: 0.08,
          rangePadding: 0.22,
          baseVolume: 2500000,
          volumeStep: 12000,
        );

      case 'XLK':
        return _MockMarketBehavior(
          startPrice: 100,
          totalPriceChange: _timeframeMove(
            timeframe,
            shortTerm: 1,
            confirmation: 2.8,
            regime: 7,
          ),
          volatility: 0.18,
          closeBias: 0.12,
          rangePadding: 0.25,
          baseVolume: 1400000,
          volumeStep: 10000,
        );

      case 'XLC':
        return _MockMarketBehavior(
          startPrice: 100,
          totalPriceChange: _timeframeMove(
            timeframe,
            shortTerm: -0.2,
            confirmation: 0.8,
            regime: 3,
          ),
          volatility: 0.16,
          closeBias: 0.04,
          rangePadding: 0.24,
          baseVolume: 900000,
          volumeStep: 7000,
        );

      case 'XLY':
        return _MockMarketBehavior(
          startPrice: 100,
          totalPriceChange: _timeframeMove(
            timeframe,
            shortTerm: -0.8,
            confirmation: -1.5,
            regime: 1,
          ),
          volatility: 0.20,
          closeBias: -0.05,
          rangePadding: 0.28,
          baseVolume: 850000,
          volumeStep: 7500,
        );

      default:
        return _behaviorFromSymbolHash(symbol, timeframe);
    }
  }

  _MockMarketBehavior _behaviorFromSymbolHash(String symbol, String timeframe) {
    final hash = symbol.codeUnits.fold<int>(
      0,
      (value, element) => value + element,
    );

    final directionIndex = hash % 5;

    final shortTermMove = switch (directionIndex) {
      0 => 7.0,
      1 => 3.0,
      2 => 0.5,
      3 => -3.0,
      _ => -7.0,
    };

    final confirmationMove = shortTermMove * (0.6 + ((hash % 3) * 0.2));
    final regimeMove = shortTermMove * (0.8 + ((hash % 4) * 0.25));

    return _MockMarketBehavior(
      startPrice: 90 + (hash % 30).toDouble(),
      totalPriceChange: _timeframeMove(
        timeframe,
        shortTerm: shortTermMove,
        confirmation: confirmationMove,
        regime: regimeMove,
      ),
      volatility: 0.25 + ((hash % 4) * 0.05),
      closeBias: shortTermMove == 0
          ? 0
          : shortTermMove > 0
          ? 0.25
          : -0.25,
      rangePadding: 0.35,
      baseVolume: 900000 + ((hash % 10) * 50000),
      volumeStep: 18000 + ((hash % 5) * 3000),
    );
  }

  double _timeframeMove(
    String timeframe, {
    required double shortTerm,
    required double confirmation,
    required double regime,
  }) {
    switch (timeframe) {
      case '1h':
      case '4h':
        return confirmation;
      case '1d':
      case '1w':
      case '1mo':
      case '3mo':
        return regime;
      default:
        return shortTerm;
    }
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
      case '30m':
        return 30;
      case '1h':
        return 60;
      case '4h':
        return 240;
      case '1d':
        return 1440;
      case '1w':
        return 10080;
      case '1mo':
        return 43200;
      case '3mo':
        return 129600;
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

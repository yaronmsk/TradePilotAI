import '../models/strategy_summary.dart';

class StrategyTimeframePlan {
  const StrategyTimeframePlan({
    required this.primaryTimeframe,
    required this.confirmationTimeframe,
    required this.regimeTimeframe,
    required this.primaryCandleCount,
    required this.confirmationCandleCount,
    required this.regimeCandleCount,
  });

  static const trader = StrategyTimeframePlan(
    primaryTimeframe: '5m',
    confirmationTimeframe: '1h',
    regimeTimeframe: '1d',
    primaryCandleCount: 48,
    confirmationCandleCount: 48,
    regimeCandleCount: 48,
  );

  static const swing = StrategyTimeframePlan(
    primaryTimeframe: '1d',
    confirmationTimeframe: '1w',
    regimeTimeframe: '1mo',
    primaryCandleCount: 90,
    confirmationCandleCount: 78,
    regimeCandleCount: 60,
  );

  static const investor = StrategyTimeframePlan(
    primaryTimeframe: '1w',
    confirmationTimeframe: '1mo',
    regimeTimeframe: '3mo',
    primaryCandleCount: 104,
    confirmationCandleCount: 60,
    regimeCandleCount: 40,
  );

  static const List<String> traderPrimaryTimeframes = <String>[
    '1m',
    '5m',
    '15m',
    '30m',
    '1h',
  ];

  static const List<String> swingPrimaryTimeframes = <String>['4h', '1d'];

  static const List<String> investorPrimaryTimeframes = <String>['1d', '1w'];

  final String primaryTimeframe;
  final String confirmationTimeframe;
  final String regimeTimeframe;
  final int primaryCandleCount;
  final int confirmationCandleCount;
  final int regimeCandleCount;

  static List<String> primaryTimeframesFor(StrategyType strategy) {
    switch (strategy) {
      case StrategyType.trader:
        return traderPrimaryTimeframes;
      case StrategyType.swing:
        return swingPrimaryTimeframes;
      case StrategyType.investor:
        return investorPrimaryTimeframes;
    }
  }

  static String defaultPrimaryTimeframeFor(StrategyType strategy) {
    switch (strategy) {
      case StrategyType.trader:
        return trader.primaryTimeframe;
      case StrategyType.swing:
        return swing.primaryTimeframe;
      case StrategyType.investor:
        return investor.primaryTimeframe;
    }
  }

  static StrategyTimeframePlan forStrategy(
    StrategyType strategy, {
    String? primaryTimeframe,
  }) {
    final resolvedPrimary =
        primaryTimeframe ?? defaultPrimaryTimeframeFor(strategy);

    switch (strategy) {
      case StrategyType.trader:
        return traderForPrimary(resolvedPrimary);
      case StrategyType.swing:
        return swingForPrimary(resolvedPrimary);
      case StrategyType.investor:
        return investorForPrimary(resolvedPrimary);
    }
  }

  static StrategyTimeframePlan traderForPrimary(String primaryTimeframe) {
    switch (primaryTimeframe) {
      case '1m':
        return const StrategyTimeframePlan(
          primaryTimeframe: '1m',
          confirmationTimeframe: '5m',
          regimeTimeframe: '1h',
          primaryCandleCount: 60,
          confirmationCandleCount: 48,
          regimeCandleCount: 48,
        );
      case '5m':
        return trader;
      case '15m':
        return const StrategyTimeframePlan(
          primaryTimeframe: '15m',
          confirmationTimeframe: '1h',
          regimeTimeframe: '1d',
          primaryCandleCount: 48,
          confirmationCandleCount: 48,
          regimeCandleCount: 48,
        );
      case '30m':
        return const StrategyTimeframePlan(
          primaryTimeframe: '30m',
          confirmationTimeframe: '4h',
          regimeTimeframe: '1d',
          primaryCandleCount: 48,
          confirmationCandleCount: 48,
          regimeCandleCount: 48,
        );
      case '1h':
        return const StrategyTimeframePlan(
          primaryTimeframe: '1h',
          confirmationTimeframe: '4h',
          regimeTimeframe: '1d',
          primaryCandleCount: 48,
          confirmationCandleCount: 48,
          regimeCandleCount: 48,
        );
      default:
        throw ArgumentError.value(
          primaryTimeframe,
          'primaryTimeframe',
          'Unsupported Trader primary timeframe.',
        );
    }
  }

  static StrategyTimeframePlan swingForPrimary(String primaryTimeframe) {
    switch (primaryTimeframe) {
      case '4h':
        return const StrategyTimeframePlan(
          primaryTimeframe: '4h',
          confirmationTimeframe: '1d',
          regimeTimeframe: '1w',
          primaryCandleCount: 60,
          confirmationCandleCount: 90,
          regimeCandleCount: 52,
        );
      case '1d':
        return swing;
      default:
        throw ArgumentError.value(
          primaryTimeframe,
          'primaryTimeframe',
          'Unsupported Swing primary timeframe.',
        );
    }
  }

  static StrategyTimeframePlan investorForPrimary(String primaryTimeframe) {
    switch (primaryTimeframe) {
      case '1d':
        return const StrategyTimeframePlan(
          primaryTimeframe: '1d',
          confirmationTimeframe: '1w',
          regimeTimeframe: '1mo',
          primaryCandleCount: 120,
          confirmationCandleCount: 104,
          regimeCandleCount: 60,
        );
      case '1w':
        return investor;
      default:
        throw ArgumentError.value(
          primaryTimeframe,
          'primaryTimeframe',
          'Unsupported Investor primary timeframe.',
        );
    }
  }

  static String timeframeDescription(String timeframe) {
    switch (timeframe) {
      case '1m':
        return '1-minute candles';
      case '5m':
        return '5-minute candles';
      case '15m':
        return '15-minute candles';
      case '30m':
        return '30-minute candles';
      case '1h':
        return '1-hour candles';
      case '4h':
        return '4-hour candles';
      case '1d':
        return '1-day candles';
      case '1w':
        return '1-week candles';
      case '1mo':
        return '1-month candles';
      case '3mo':
        return '3-month candles';
      default:
        return '$timeframe candles';
    }
  }
}

import 'market_candle.dart';
import 'market_history_range.dart';

enum MarketHistoryStatus { initial, loading, loaded, error }

class MarketHistoryState {
  const MarketHistoryState({
    this.status = MarketHistoryStatus.initial,
    this.range = MarketHistoryRange.oneDay,
    this.candles = const [],
    this.errorMessage,
  });

  final MarketHistoryStatus status;
  final MarketHistoryRange range;
  final List<MarketCandle> candles;
  final String? errorMessage;

  bool get isLoading => status == MarketHistoryStatus.loading;

  bool get isLoaded => status == MarketHistoryStatus.loaded;

  MarketHistoryState copyWith({
    MarketHistoryStatus? status,
    MarketHistoryRange? range,
    List<MarketCandle>? candles,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MarketHistoryState(
      status: status ?? this.status,
      range: range ?? this.range,
      candles: candles ?? this.candles,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

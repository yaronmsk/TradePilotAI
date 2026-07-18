import 'market_snapshot.dart';

enum MarketStatus {
  initial,
  loading,
  loaded,
  error,
}

class MarketState {
  const MarketState({
    this.status = MarketStatus.initial,
    this.snapshot,
    this.errorMessage,
  });

  final MarketStatus status;
  final MarketSnapshot? snapshot;
  final String? errorMessage;

  bool get isInitial => status == MarketStatus.initial;
  bool get isLoading => status == MarketStatus.loading;
  bool get isLoaded => status == MarketStatus.loaded;
  bool get hasError => status == MarketStatus.error;

  MarketState copyWith({
    MarketStatus? status,
    MarketSnapshot? snapshot,
    String? errorMessage,
    bool clearSnapshot = false,
    bool clearError = false,
  }) {
    return MarketState(
      status: status ?? this.status,
      snapshot: clearSnapshot ? null : snapshot ?? this.snapshot,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
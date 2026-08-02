import 'package:mobile/features/watchlist/models/watchlist_item.dart';

enum WatchlistStatus { initial, loading, loaded, error }

class WatchlistState {
  const WatchlistState({
    this.status = WatchlistStatus.initial,
    this.items = const [],
    this.selectedSymbol,
    this.errorMessage,
  });

  final WatchlistStatus status;
  final List<WatchlistItem> items;
  final String? selectedSymbol;
  final String? errorMessage;

  WatchlistItem? get selectedItem {
    if (selectedSymbol == null) {
      return null;
    }

    for (final item in items) {
      if (item.symbol == selectedSymbol) {
        return item;
      }
    }

    return null;
  }

  bool containsSymbol(String symbol) {
    final normalizedSymbol = symbol.trim().toUpperCase();

    return items.any((item) => item.symbol.toUpperCase() == normalizedSymbol);
  }

  WatchlistState copyWith({
    WatchlistStatus? status,
    List<WatchlistItem>? items,
    String? selectedSymbol,
    bool clearSelectedSymbol = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return WatchlistState(
      status: status ?? this.status,
      items: items ?? this.items,
      selectedSymbol: clearSelectedSymbol
          ? null
          : selectedSymbol ?? this.selectedSymbol,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/watchlist_item.dart';
import '../models/watchlist_state.dart';
import '../repositories/watchlist_repository.dart';

class WatchlistController extends ChangeNotifier {
  WatchlistController({
    WatchlistRepository? repository,
    List<WatchlistItem> initialItems = const [],
    String? initialSelectedSymbol,
  }) : _repository = repository,
       _state = WatchlistState(
         status: WatchlistStatus.loaded,
         items: List<WatchlistItem>.unmodifiable(initialItems),
         selectedSymbol: _resolveInitialSelection(
           initialItems,
           initialSelectedSymbol,
         ),
       );

  final WatchlistRepository? _repository;

  WatchlistState _state;

  WatchlistState get state => _state;

  Future<void> initialize() async {
    final repository = _repository;

    if (repository == null) {
      return;
    }

    _setState(
      _state.copyWith(status: WatchlistStatus.loading, clearErrorMessage: true),
      persist: false,
    );

    try {
      final savedState = await repository.load();

      if (savedState == null) {
        _setState(
          _state.copyWith(status: WatchlistStatus.loaded),
          persist: true,
        );
        return;
      }

      _setState(
        savedState.copyWith(
          status: WatchlistStatus.loaded,
          clearErrorMessage: true,
        ),
        persist: false,
      );
    } catch (_) {
      _setState(
        _state.copyWith(
          status: WatchlistStatus.error,
          errorMessage: 'Unable to restore the saved watchlist.',
        ),
        persist: false,
      );
    }
  }

  void addItem(WatchlistItem item) {
    final normalizedItem = WatchlistItem(
      symbol: _normalizeSymbol(item.symbol),
      displayName: item.displayName.trim(),
      isNotificationsEnabled: item.isNotificationsEnabled,
    );

    if (normalizedItem.symbol.isEmpty) {
      _setError('Symbol cannot be empty.');
      return;
    }

    if (_state.containsSymbol(normalizedItem.symbol)) {
      _setError('${normalizedItem.symbol} is already in the watchlist.');
      return;
    }

    final updatedItems = List<WatchlistItem>.unmodifiable([
      ..._state.items,
      normalizedItem,
    ]);

    _setState(
      _state.copyWith(
        status: WatchlistStatus.loaded,
        items: updatedItems,
        selectedSymbol: _state.selectedSymbol ?? normalizedItem.symbol,
        clearErrorMessage: true,
      ),
    );
  }

  void removeItem(String symbol) {
    final normalizedSymbol = _normalizeSymbol(symbol);

    if (!_state.containsSymbol(normalizedSymbol)) {
      _setError('$normalizedSymbol is not in the watchlist.');
      return;
    }

    final updatedItems = List<WatchlistItem>.unmodifiable(
      _state.items.where(
        (item) => item.symbol.toUpperCase() != normalizedSymbol,
      ),
    );

    final wasSelected = _state.selectedSymbol == normalizedSymbol;

    final nextSelectedSymbol = wasSelected && updatedItems.isNotEmpty
        ? updatedItems.first.symbol
        : _state.selectedSymbol;

    _setState(
      _state.copyWith(
        status: WatchlistStatus.loaded,
        items: updatedItems,
        selectedSymbol: nextSelectedSymbol,
        clearSelectedSymbol: updatedItems.isEmpty,
        clearErrorMessage: true,
      ),
    );
  }

  void selectSymbol(String symbol) {
    final normalizedSymbol = _normalizeSymbol(symbol);

    if (!_state.containsSymbol(normalizedSymbol)) {
      _setError('$normalizedSymbol is not in the watchlist.');
      return;
    }

    if (_state.selectedSymbol == normalizedSymbol) {
      return;
    }

    _setState(
      _state.copyWith(
        status: WatchlistStatus.loaded,
        selectedSymbol: normalizedSymbol,
        clearErrorMessage: true,
      ),
    );
  }

  void toggleNotifications(String symbol) {
    final normalizedSymbol = _normalizeSymbol(symbol);

    if (!_state.containsSymbol(normalizedSymbol)) {
      _setError('$normalizedSymbol is not in the watchlist.');
      return;
    }

    final updatedItems = List<WatchlistItem>.unmodifiable(
      _state.items.map((item) {
        if (item.symbol.toUpperCase() != normalizedSymbol) {
          return item;
        }

        return item.copyWith(
          isNotificationsEnabled: !item.isNotificationsEnabled,
        );
      }),
    );

    _setState(
      _state.copyWith(
        status: WatchlistStatus.loaded,
        items: updatedItems,
        clearErrorMessage: true,
      ),
    );
  }

  void clearError() {
    if (_state.errorMessage == null) {
      return;
    }

    _setState(
      _state.copyWith(status: WatchlistStatus.loaded, clearErrorMessage: true),
      persist: false,
    );
  }

  void _setError(String message) {
    _setState(
      _state.copyWith(status: WatchlistStatus.error, errorMessage: message),
      persist: false,
    );
  }

  void _setState(WatchlistState newState, {bool persist = true}) {
    _state = newState;
    notifyListeners();

    if (persist && _repository != null) {
      unawaited(_saveState());
    }
  }

  Future<void> _saveState() async {
    try {
      await _repository!.save(_state);
    } catch (_) {
      _state = _state.copyWith(
        status: WatchlistStatus.error,
        errorMessage: 'Unable to save the watchlist.',
      );

      notifyListeners();
    }
  }

  static String _normalizeSymbol(String symbol) {
    return symbol.trim().toUpperCase();
  }

  static String? _resolveInitialSelection(
    List<WatchlistItem> items,
    String? requestedSymbol,
  ) {
    if (items.isEmpty) {
      return null;
    }

    if (requestedSymbol == null) {
      return items.first.symbol.trim().toUpperCase();
    }

    final normalizedRequestedSymbol = requestedSymbol.trim().toUpperCase();

    final exists = items.any(
      (item) => item.symbol.trim().toUpperCase() == normalizedRequestedSymbol,
    );

    return exists
        ? normalizedRequestedSymbol
        : items.first.symbol.trim().toUpperCase();
  }
}

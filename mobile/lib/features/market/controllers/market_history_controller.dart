import 'package:flutter/foundation.dart';

import '../models/market_history_range.dart';
import '../models/market_history_state.dart';
import '../services/market_history_service.dart';

class MarketHistoryController extends ChangeNotifier {
  MarketHistoryController(this._service);

  final MarketHistoryService _service;

  MarketHistoryState _state = const MarketHistoryState();

  MarketHistoryState get state => _state;

  String? _symbol;
  double? _endPrice;
  int _requestId = 0;

  Future<void> load({required String symbol, required double endPrice}) async {
    _symbol = symbol.trim().toUpperCase();
    _endPrice = endPrice;

    await _loadCurrentRange();
  }

  Future<void> selectRange(MarketHistoryRange range) async {
    if (_state.range == range && _state.status == MarketHistoryStatus.loaded) {
      return;
    }

    _state = _state.copyWith(range: range, clearError: true);

    notifyListeners();

    if (_symbol == null || _endPrice == null) {
      return;
    }

    await _loadCurrentRange();
  }

  void reset() {
    _requestId++;
    _symbol = null;
    _endPrice = null;
    _state = const MarketHistoryState();
    notifyListeners();
  }

  Future<void> _loadCurrentRange() async {
    final symbol = _symbol;
    final endPrice = _endPrice;

    if (symbol == null || endPrice == null) {
      return;
    }

    final requestId = ++_requestId;

    _state = _state.copyWith(
      status: MarketHistoryStatus.loading,
      clearError: true,
    );

    notifyListeners();

    try {
      final candles = await _service.loadHistory(
        symbol: symbol,
        range: _state.range,
        endPrice: endPrice,
      );

      if (requestId != _requestId) {
        return;
      }

      _state = MarketHistoryState(
        status: MarketHistoryStatus.loaded,
        range: _state.range,
        candles: candles,
      );
    } catch (error) {
      if (requestId != _requestId) {
        return;
      }

      _state = MarketHistoryState(
        status: MarketHistoryStatus.error,
        range: _state.range,
        errorMessage: 'Unable to load market history: $error',
      );
    }

    notifyListeners();
  }
}

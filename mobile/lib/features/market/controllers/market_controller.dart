import 'package:flutter/foundation.dart';

import '../models/market_state.dart';
import '../services/market_service.dart';

class MarketController extends ChangeNotifier {
  MarketController(this._service);

  final MarketService _service;

  MarketState _state = const MarketState();
  int _requestId = 0;

  MarketState get state => _state;

  Future<void> loadSnapshot({
    required String symbol,
    required String timeframe,
    required int candleCount,
  }) async {
    final requestId = ++_requestId;

    _state = _state.copyWith(status: MarketStatus.loading, clearError: true);
    notifyListeners();

    try {
      final snapshot = await _service.loadSnapshot(
        symbol: symbol,
        timeframe: timeframe,
        candleCount: candleCount,
      );

      if (requestId != _requestId) {
        return;
      }

      _state = MarketState(status: MarketStatus.loaded, snapshot: snapshot);
    } catch (error) {
      if (requestId != _requestId) {
        return;
      }

      _state = MarketState(
        status: MarketStatus.error,
        errorMessage: error.toString(),
      );
    }

    notifyListeners();
  }

  void reset() {
    _requestId++;
    _state = const MarketState();
    notifyListeners();
  }
}

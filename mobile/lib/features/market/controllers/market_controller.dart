import 'package:flutter/foundation.dart';

import '../models/market_state.dart';
import '../services/market_service.dart';

class MarketController extends ChangeNotifier {
  MarketController(this._service);

  final MarketService _service;

  MarketState _state = const MarketState();

  MarketState get state => _state;

  Future<void> loadSnapshot({
    required String symbol,
    required String timeframe,
    required int candleCount,
  }) async {
    _state = _state.copyWith(
      status: MarketStatus.loading,
      clearError: true,
    );
    notifyListeners();

    try {
      final snapshot = await _service.loadSnapshot(
        symbol: symbol,
        timeframe: timeframe,
        candleCount: candleCount,
      );

      _state = MarketState(
        status: MarketStatus.loaded,
        snapshot: snapshot,
      );
    } catch (error) {
      _state = MarketState(
        status: MarketStatus.error,
        errorMessage: error.toString(),
      );
    }

    notifyListeners();
  }

  void reset() {
    _state = const MarketState();
    notifyListeners();
  }
}
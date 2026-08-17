import 'package:flutter/foundation.dart';

import '../../market/models/market_candle.dart';
import '../../market/models/market_snapshot.dart';
import '../models/recommendation_state.dart';
import '../services/recommendation_service.dart';

class RecommendationController extends ChangeNotifier {
  RecommendationController(this._service);

  final RecommendationService _service;

  RecommendationState _state = const RecommendationState();

  RecommendationState get state => _state;

  void analyze(
    MarketSnapshot snapshot, {
    List<MarketCandle> historicalDailyCandles = const [],
  }) {
    _state = _state.copyWith(
      status: RecommendationStatus.analyzing,
      clearError: true,
    );
    notifyListeners();

    try {
      final profile = _service.stockBehaviorProfileService.evaluate(
        snapshot,
        historicalDailyCandles: historicalDailyCandles,
      );
      final recommendation = _service.analyze(
        snapshot,
        profile: profile,
        historicalDailyCandles: historicalDailyCandles,
      );

      _state = RecommendationState(
        status: RecommendationStatus.ready,
        recommendation: recommendation,
        stockBehaviorProfile: profile,
      );
    } catch (error) {
      _state = RecommendationState(
        status: RecommendationStatus.error,
        errorMessage: error.toString(),
      );
    }

    notifyListeners();
  }

  void reset() {
    _state = const RecommendationState();
    notifyListeners();
  }
}

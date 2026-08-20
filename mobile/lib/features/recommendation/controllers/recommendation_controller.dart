import 'package:flutter/foundation.dart';

import '../../market/models/market_candle.dart';
import '../../market/models/market_snapshot.dart';
import '../context/recommendation_analysis_context.dart';
import '../history/historical_setup_validation.dart';
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
    RecommendationAnalysisContext? analysisContext,
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
        analysisContext: analysisContext,
      );

      _state = RecommendationState(
        status: RecommendationStatus.ready,
        recommendation: recommendation,
        stockBehaviorProfile: profile,
        analysisContext: analysisContext,
      );
    } catch (error) {
      _state = RecommendationState(
        status: RecommendationStatus.error,
        errorMessage: error.toString(),
      );
    }

    notifyListeners();
  }

  void applyHistoricalValidation(HistoricalSetupValidation validation) {
    final recommendation = _state.recommendation;

    if (recommendation == null) {
      return;
    }

    try {
      final adjusted = _service.applyHistoricalValidation(
        recommendation: recommendation,
        validation: validation,
      );

      _state = _state.copyWith(
        status: RecommendationStatus.ready,
        recommendation: adjusted,
        clearError: true,
      );
      notifyListeners();
    } catch (_) {
      // Historical validation is optional. Preserve the already-ready current
      // recommendation if the validation overlay cannot be applied.
    }
  }

  void reset() {
    _state = const RecommendationState();
    notifyListeners();
  }
}

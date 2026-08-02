import 'package:flutter/foundation.dart';
import 'package:mobile/features/market/controllers/market_controller.dart';
import 'package:mobile/features/watchlist/controllers/watchlist_controller.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({
    required this.marketController,
    required this.watchlistController,
    this.defaultTimeframe = '5m',
    this.defaultCandleCount = 48,
  });

  final MarketController marketController;
  final WatchlistController watchlistController;

  final String defaultTimeframe;
  final int defaultCandleCount;

  Future<void> selectSymbol(String symbol) async {
    watchlistController.selectSymbol(symbol);

    await marketController.loadSnapshot(
      symbol: symbol,
      timeframe: defaultTimeframe,
      candleCount: defaultCandleCount,
    );

    notifyListeners();
  }
}
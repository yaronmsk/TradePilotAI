import '../models/watchlist_state.dart';

abstract interface class WatchlistRepository {
  Future<WatchlistState?> load();

  Future<void> save(WatchlistState state);

  Future<void> clear();
}

import 'dart:convert';

import '../../../core/storage/storage_keys.dart';
import '../../../core/storage/storage_service.dart';
import '../models/watchlist_item.dart';
import '../models/watchlist_state.dart';
import 'watchlist_repository.dart';

class LocalWatchlistRepository implements WatchlistRepository {
  LocalWatchlistRepository(this._storage);

  final StorageService _storage;

  @override
  Future<void> clear() async {
    await _storage.remove(StorageKeys.watchlist);
    await _storage.remove(StorageKeys.selectedSymbol);
  }

  @override
  Future<WatchlistState?> load() async {
    final jsonString = await _storage.getString(StorageKeys.watchlist);

    if (jsonString == null) {
      return null;
    }

    final decoded = jsonDecode(jsonString);

    if (decoded is! List) {
      throw const FormatException('Stored watchlist must be a JSON list.');
    }

    final items = decoded
        .map(
          (entry) =>
              WatchlistItem.fromJson(Map<String, dynamic>.from(entry as Map)),
        )
        .toList(growable: false);

    final selectedSymbol = await _storage.getString(StorageKeys.selectedSymbol);

    final validSelectedSymbol =
        selectedSymbol != null &&
            items.any((item) => item.symbol == selectedSymbol)
        ? selectedSymbol
        : items.isNotEmpty
        ? items.first.symbol
        : null;

    return WatchlistState(
      status: WatchlistStatus.loaded,
      items: items,
      selectedSymbol: validSelectedSymbol,
    );
  }

  @override
  Future<void> save(WatchlistState state) async {
    final jsonString = jsonEncode(
      state.items.map((item) => item.toJson()).toList(growable: false),
    );

    await _storage.setString(StorageKeys.watchlist, jsonString);

    final selectedSymbol = state.selectedSymbol;

    if (selectedSymbol == null) {
      await _storage.remove(StorageKeys.selectedSymbol);
    } else {
      await _storage.setString(StorageKeys.selectedSymbol, selectedSymbol);
    }
  }
}

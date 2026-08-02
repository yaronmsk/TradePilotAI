import 'package:shared_preferences/shared_preferences.dart';

import 'storage_service.dart';

class SharedPreferencesStorageService implements StorageService {
  SharedPreferences? _preferences;

  SharedPreferences get _prefs {
    final prefs = _preferences;

    if (prefs == null) {
      throw StateError('StorageService.initialize() was not called.');
    }

    return prefs;
  }

  @override
  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }
}

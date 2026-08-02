abstract interface class StorageService {
  Future<void> initialize();

  Future<bool> containsKey(String key);

  Future<void> remove(String key);

  Future<void> clear();

  Future<void> setString(String key, String value);

  Future<String?> getString(String key);

  Future<void> setInt(String key, int value);

  Future<int?> getInt(String key);

  Future<void> setBool(String key, bool value);

  Future<bool?> getBool(String key);
}

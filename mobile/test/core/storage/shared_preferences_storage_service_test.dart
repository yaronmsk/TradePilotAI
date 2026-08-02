import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/storage/shared_preferences_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferencesStorageService', () {
    late SharedPreferencesStorageService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});

      service = SharedPreferencesStorageService();
      await service.initialize();
    });

    test('stores and retrieves string', () async {
      await service.setString('name', 'TradePilot');

      expect(await service.getString('name'), 'TradePilot');
    });

    test('stores and retrieves bool', () async {
      await service.setBool('enabled', true);

      expect(await service.getBool('enabled'), true);
    });

    test('stores and retrieves int', () async {
      await service.setInt('version', 1);

      expect(await service.getInt('version'), 1);
    });

    test('remove deletes value', () async {
      await service.setString('key', 'value');

      await service.remove('key');

      expect(await service.getString('key'), isNull);
    });
  });
}

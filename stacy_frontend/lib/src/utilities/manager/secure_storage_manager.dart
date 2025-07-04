import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageManager {
  static final SecureStorageManager _instance =
      SecureStorageManager._internal();

  factory SecureStorageManager() {
    return _instance;
  }

  SecureStorageManager._internal();

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> setBearerToken(String token) async {
    await _secureStorage.write(key: 'bearerToken', value: token);
  }

  Future<String?> getBearerToken() async {
    return await _secureStorage.read(key: 'bearerToken');
  }
}

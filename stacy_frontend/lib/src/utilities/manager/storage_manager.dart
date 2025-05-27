import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacy_frontend/src/services/logger.dart' show log;

class StorageManager {
  static final StorageManager _instance = StorageManager._internal();

  factory StorageManager() {
    return _instance;
  }

  StorageManager._internal();

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  Future<void> setString(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  Future<void> remove(String key) async {
    final prefs = await _prefs;
    await prefs.remove(key);
  }

  Future<bool> isLoggedIn() async {
    return await getString('uid').then((value) {
      return value != null;
    }).catchError((error) {
      log.warning('Error checking login status: $error');
      return false;
    });
  }
}

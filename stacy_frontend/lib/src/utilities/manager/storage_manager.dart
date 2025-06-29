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

  Future<void> logoutUser() async {
    final prefs = await _prefs;
    if (prefs.containsKey('uid')) {
      await prefs.remove('uid');
      log.info('User logged out successfully.');
    } else {
      log.warning('No user is currently logged in.');
    }
  }

  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.clear();
    log.info('User logged out and storage cleared.');
  }
}

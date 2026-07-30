import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 🚀 Added 'static' here
  static Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  // 🚀 Added 'static' here
  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }
}

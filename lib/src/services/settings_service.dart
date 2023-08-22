import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  final encrypter = Encrypter(AES(Key.fromUtf8('your-secret-key-here-protoX')));

  Future<void> saveValue(String key, String value,
      {bool encrypt = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (encrypt) {
      final encryptedValue = encrypter.encrypt(value).base64;
      await prefs.setString(key, encryptedValue);
    } else {
      await prefs.setString(key, value);
    }
  }

  Future<String?> getValue(String key, {bool decrypt = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    if (value != null && decrypt) {
      return encrypter.decrypt64(value);
    }
    return value;
  }

  Future<void> saveBoolValue(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool?> getBoolValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }
}

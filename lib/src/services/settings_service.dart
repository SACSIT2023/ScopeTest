import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._();

  final encrypter = Encrypter(AES(Key.fromUtf8('your-secret-key-here-protoX')));

  // Private constructor
  SettingsService._();

  // Factory constructor
  factory SettingsService() {
    return _instance;
  }

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
}

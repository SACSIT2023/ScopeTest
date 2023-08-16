import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class AuthProvider {
  String? _token;
  String? get token => _token;
  void setToken(String token) {
    _token = token;
  }

  final key = encrypt.Key.fromLength(32);
  final iv = encrypt.IV.fromLength(16);

  Future<void> toggleRememberMe(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isRememberMeChecked', value);
  }

  Future<bool> isRememberMeChecked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isRememberMeChecked') ?? false;
  }

  Future<void> saveUserCredentials(String email, String password) async {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encryptedPassword = encrypter.encrypt(password, iv: iv);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userEmail_$email', email);
    prefs.setString('userPassword_$email', encryptedPassword.base64);
  }

  Future<String?> retrieveUserPassword(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final encryptedPassword = prefs.getString('userPassword_$email');

    if (encryptedPassword != null) {
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final decryptedPassword = encrypter.decrypt64(encryptedPassword, iv: iv);
      return decryptedPassword;
    }
    return null;
  }
}

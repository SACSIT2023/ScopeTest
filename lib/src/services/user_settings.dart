import 'package:scope_test/src/services/settings_service.dart';

class UserSettings {
  static final UserSettings _instance = UserSettings._();
  final SettingsService _settingsService = SettingsService();

  factory UserSettings() {
    return _instance;
  }

  UserSettings._();

  Future<void> toggleRememberMe(bool value) async {
    await _settingsService.saveValue('isRememberMeChecked', value.toString());
  }

  Future<bool> isRememberMeChecked() async {
    String? value = await _settingsService.getValue('isRememberMeChecked');
    return value == 'true';
  }

  Future<void> saveUserCredentials(String email, String password) async {
    await _settingsService.saveValue('userEmail', email);
    await _settingsService.saveValue('userPassword', password, encrypt: true);
  }

  Future<Map<String, String?>> retrieveUserCredentials() async {
    String? email = await _settingsService.getValue('userEmail');
    String? password =
        await _settingsService.getValue('userPassword', decrypt: true);

    email ??= '';
    password ??= '';

    return {'email': email, 'password': password};
  }
}

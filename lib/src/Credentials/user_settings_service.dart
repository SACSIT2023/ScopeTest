import 'package:get_it/get_it.dart';

import '../services/settings_service.dart';

class UserSettingsService {
  final SettingsService _settingsService = GetIt.instance<SettingsService>();

  Future<void> forgetMe(String? email) async {
    if (email != null && email.isNotEmpty) {
      await _settingsService.saveValue('userEmail', '');
      await _settingsService.saveValue('userPassword_$email', '');
      await saveRememberMe(false);
    }
  }

  Future<void> saveRememberMe(bool value) async {
    await _settingsService.saveBoolValue('isRememberMeChecked', value);
  }

  Future<bool> getRememberMe() async {
    bool? value = await _settingsService.getBoolValue('isRememberMeChecked');
    return value ?? false;
  }

  Future<void> saveUserCredentials(String email, String password) async {
    await _settingsService.saveValue('userEmail', email);
    await _settingsService.saveValue('userPassword_$email', password,
        encrypt: true);
  }

  Future<Map<String, String?>> retrieveUserCredentials() async {
    String email = await _settingsService.getValue('userEmail') ?? '';
    String password =
        await _settingsService.getValue('userPassword_$email', decrypt: true) ??
            '';
    return {'email': email, 'password': password};
  }
}

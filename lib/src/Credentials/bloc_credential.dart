import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scope_test/src/Credentials/validator_credential.dart';

import '../../main_data.dart';
import '../services/auth_tocken_service.dart';

import 'http_credential.dart';
import 'user_settings_service.dart';

class BlocCredential extends ValidatorCredential {
  final AuthTockenService _authService = GetIt.instance<AuthTockenService>();
  final HttpCredential _httpCredential = GetIt.instance<HttpCredential>();
  final UserSettingsService _userSettings =
      GetIt.instance<UserSettingsService>();
  final MainData _mainData = GetIt.instance<MainData>();

  BlocCredential();

  final BehaviorSubject<String> _email = BehaviorSubject<String>();
  final BehaviorSubject<String> _password = BehaviorSubject<String>();
  final _isLoading = BehaviorSubject<bool>.seeded(false);
  final _errorMessage = BehaviorSubject<String?>.seeded(null);

  // Add data to stream
  Stream<String> get email => _email.stream.transform(validateEmail);
  Stream<String> get password => _password.stream.transform(validatePassword);
  Stream<bool> get isLoading => _isLoading.stream;
  Stream<String?> get errorMessage => _errorMessage.stream;

  // Change data
  Function(String) get changeEmail => (email) {
        _email.sink.add(email);
      };
  Function(String) get changePassword => (password) {
        _password.sink.add(password);
      };

  void setErrorMessage(String? message) {
    _errorMessage.sink.add(message);
  }

  Stream<bool> get isValid => Rx.combineLatest2(
      email,
      password,
      (String email, String password) =>
          email.isNotEmpty && password.isNotEmpty && password.length > 3);

// business logic
  Future<bool> authenticateUser() async {
    String? currentEmail = _email.value;
    String? currentPassword = _password.value;

    _isLoading.sink.add(true);
    _errorMessage.sink.add(null);

    if (currentEmail.isNotEmpty && currentPassword.isNotEmpty) {
      final response =
          await _httpCredential.userLogin(currentEmail, currentPassword);
      String? token = response['item1'];

      if (token != null) {
        _mainData.setuserEmail(currentEmail);
        _authService.setToken(token);
        await _userSettings.saveUserCredentials(currentEmail, currentPassword);
        _isLoading.sink.add(false);
        return true;
      } else {
        _errorMessage.sink.add('Incorrect email or password.');
      }
    }
    _isLoading.sink.add(false);
    return false;
  }

  Future<bool> registerUser(
      String company, String firstName, String lastName) async {
    String? currentEmail = _email.value;
    String? currentPassword = _password.value;

    if (currentEmail.isNotEmpty && currentPassword.isNotEmpty) {
      final response = await _httpCredential.userSignup(
          company, firstName, lastName, currentEmail, currentPassword);
      String? token = response['item1'];

      if (token != null) {
        _mainData.setuserEmail(currentEmail);
        _authService.setToken(token);
        await _userSettings.saveUserCredentials(currentEmail, currentPassword);
        return true;
      }
    }
    return false;
  }

  Future<bool> signoutUser(String email) async {
    String? currentEmail = _email.value;

    if (currentEmail.isNotEmpty) {
      final response = await _httpCredential.userLogout(email);
      if (response.isNotEmpty) {
        _authService.setToken('');
        _mainData.setuserEmail('');
        return true;
      }
    }
    return false;
  }

  // Close stream
  // when? within the dispose method of a StatefulWidget that uses the BlocCredential
  void dispose() {
    _email.close();
    _password.close();
    _isLoading.close();
    _errorMessage.close();
  }
}

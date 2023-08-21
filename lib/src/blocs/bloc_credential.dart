import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:scope_test/src/validators/validator_credential.dart';

import '../services/auth_service.dart';
import '../controllers/http_controller.dart';
import '../services/user_settings.dart';

class BlocCredential extends ValidatorCredential {
  final AuthProvider authService;
  final HttpController httpController;
  final _userSettings = UserSettings();

  BlocCredential(this.authService, this.httpController);

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
          await httpController.userLogin(currentEmail, currentPassword);
      String? token = response['item1'];

      if (token != null) {
        authService.setToken(token);
        await _userSettings.saveUserCredentials(currentEmail, currentPassword);
        return true;
      } else {
        _errorMessage.sink.add('Incorrect email or password.');
      }
      _isLoading.sink.add(false);
    }
    return false;
  }

  Future<bool> registerUser(
      String company, String firstName, String lastName) async {
    String? currentEmail = _email.value;
    String? currentPassword = _password.value;

    if (currentEmail.isNotEmpty && currentPassword.isNotEmpty) {
      final response = await httpController.userSignup(
          company, firstName, lastName, currentEmail, currentPassword);
      String? token = response['item1'];

      if (token != null) {
        authService.setToken(token);
        await _userSettings.saveUserCredentials(currentEmail, currentPassword);
        return true;
      }
    }
    return false;
  }

  Future<bool> signoutUser(String email) async {
    String? currentEmail = _email.value;

    if (currentEmail.isNotEmpty) {
      final response = await httpController.userLogout(email);
      if (response.isNotEmpty) {
        authService.setToken('');
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

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

  final _email = StreamController<String>();
  final _password = StreamController<String>();

  String? _latestEmail = "";
  String? _latestPassword = "";

  // Add data to stream
  Stream<String> get email => _email.stream.transform(validateEmail);
  Stream<String> get password => _password.stream.transform(validatePassword);

  // Change data
  Function(String) get changeEmail => (email) {
        _latestEmail = email;
        _email.sink.add(email);
      };
  Function(String) get changePassword => (password) {
        _latestPassword = password;
        _password.sink.add(password);
      };

  Stream<bool> get isValid => Rx.combineLatest2(
      email,
      password,
      (String email, String password) =>
          email.isNotEmpty && password.isNotEmpty && password.length > 3);

// business logic
  Future<bool> authenticateUser() async {
    if (_latestEmail != null &&
        _latestEmail != '' &&
        _latestPassword != null &&
        _latestPassword != '') {
      final response =
          await httpController.userLogin(_latestEmail!, _latestPassword!);
      String? token = response['item1'];

      if (token != null) {
        authService.setToken(token);
        await _userSettings.saveUserCredentials(
            _latestEmail!, _latestPassword!);
        return true;
      }
    }
    return false;
  }

  Future<bool> registerUser(
      String company, String firstName, String lastName) async {
    if (_latestEmail != null &&
        _latestEmail != '' &&
        _latestPassword != null &&
        _latestPassword != '') {
      final response = await httpController.userSignup(
          company, firstName, lastName, _latestEmail!, _latestPassword!);
      String? token = response['item1'];
      if (token != null) {
        authService.setToken(token);
        await _userSettings.saveUserCredentials(
            _latestEmail!, _latestPassword!);
        return true;
      }
    }
    return false;
  }

  Future<bool> signoutUser(String email) async {
    if (_latestEmail != null && _latestEmail != '') {
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
  }
}

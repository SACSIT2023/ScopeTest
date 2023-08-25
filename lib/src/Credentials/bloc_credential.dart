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

  final BehaviorSubject<String> _rePassword = BehaviorSubject<String>();
  final BehaviorSubject<bool> _isCompany = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<String> _company = BehaviorSubject<String>();
  final BehaviorSubject<String> _firstName = BehaviorSubject<String>();
  final BehaviorSubject<String> _lastName = BehaviorSubject<String>();

  // Add data to stream
  Stream<String> get email => _email.stream.transform(validateEmail);
  Stream<String> get password => _password.stream.transform(validatePassword);
  Stream<bool> get isLoading => _isLoading.stream;
  Stream<String?> get errorMessage => _errorMessage.stream;

  Stream<String> get rePassword =>
      _rePassword.stream.transform(validatePassword);
  Stream<bool> get isCompany => _isCompany.stream;
  Stream<String> get company => _company.stream;
  Stream<String> get firstName => _firstName.stream;
  Stream<String> get lastName => _lastName.stream;

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

  Stream<bool> get isValidSignIn => Rx.combineLatest2(
      email,
      password,
      (String email, String password) =>
          email.isNotEmpty && password.isNotEmpty && password.length > 3);

  Function(String) get changeRePassword => _rePassword.sink.add;

  Function(bool?) get changeIsCompany => (bool? value) {
        if (value != null) {
          _isCompany.sink.add(value);
        }
      };

  Function(String) get changeCompany => _company.sink.add;
  Function(String) get changeFirstName => _firstName.sink.add;
  Function(String) get changeLastName => _lastName.sink.add;

  Stream<bool> get isValidSignUp {
    return Rx.combineLatest7(
        email, password, rePassword, isCompany, company, firstName, lastName, (
      String email,
      String password,
      String rePassword,
      bool isCompany,
      String companyName,
      String firstName,
      String lastName,
    ) {
      bool baseCondition = email.isNotEmpty &&
          password.isNotEmpty &&
          password.length > 3 &&
          password == rePassword;

      if (!baseCondition) return false;

      if (isCompany) {
        return companyName.length >= 2;
      } else {
        return firstName.length >= 2 && lastName.length >= 2;
      }
    });
  }

// business logic

  Future<bool> authenticateUser() async {
    String? currentEmail = _email.value;
    String? currentPassword = _password.value;

    _isLoading.sink.add(true);
    _errorMessage.sink.add(null);

    if (currentEmail.isNotEmpty && currentPassword.isNotEmpty) {
      try {
        final UserLoginResponse response =
            await _httpCredential.userLogin(currentEmail, currentPassword);
        String? token = response.token;

        if (token != null) {
          _mainData.setuserEmail(currentEmail);
          _authService.setToken(token);
          await _userSettings.saveUserCredentials(
              currentEmail, currentPassword);
          _isLoading.sink.add(false);
          return true;
        } else {
          _errorMessage.sink.add(response.errorMessage);
        }
      } catch (e) {
        _errorMessage.sink.add(e.toString());
      }
    }
    _isLoading.sink.add(false);
    return false;
  }

  // a dialog must indicate error in case of exception
  Future<bool> registerUser() async {
    String? currentEmail = _email.value;
    String? currentPassword = _password.value;

    bool? isitacompany = _isCompany.value;
    String? companyName = _company.value;
    String? fn = _firstName.value;
    String? ln = _lastName.value;

    if (currentEmail.isNotEmpty && currentPassword.isNotEmpty) {
      try {
        final UserSignupResponse response = await _httpCredential.userSignup(
            isitacompany, companyName, fn, ln, currentEmail, currentPassword);
        String? token = response.token;

        if (token != null) {
          _mainData.setuserEmail(currentEmail);
          _authService.setToken(token);
          await _userSettings.saveUserCredentials(
              currentEmail, currentPassword);
          _isLoading.sink.add(false);
          return true;
        } else {
          _errorMessage.sink.add(response.errorMessage);
        }
      } catch (e) {
        _errorMessage.sink.add(e.toString());
      }
    }
    _isLoading.sink.add(false);
    return false;
  }

  // a dialog must indicate error in case of exception
  Future signoutUser(String email) async {
    String? currentEmail = _email.value;

    if (currentEmail.isNotEmpty) {
      try {
        final response = await _httpCredential.userLogout(email);
        if (response.isNotEmpty) {
          _authService.setToken('');
          _mainData.setuserEmail('');
        } else {
          throw Exception('Failed to logout, no answer from server');
        }
      } catch (e) {
        throw Exception(e.toString());
      }
    }
  }

  // Close stream
  // when? within the dispose method of a StatefulWidget that uses the BlocCredential
  void dispose() {
    _email.close();
    _password.close();
    _isLoading.close();
    _errorMessage.close();

    _rePassword.close();
    _isCompany.close();
    _company.close();
    _firstName.close();
    _lastName.close();
  }
}

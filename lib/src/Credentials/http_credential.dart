import 'dart:js_interop';

import 'package:connectivity/connectivity.dart';
import 'package:get_it/get_it.dart';

import '../services/device_info_service.dart';
import '../services/http_controller.dart';
import '../services/logger_service.dart';

class HttpCredential {
  final HttpController _httpController = GetIt.instance<HttpController>();
  final DeviceInfoService _deviceInfoService =
      GetIt.instance<DeviceInfoService>();
  final LoggerService _logProvider = GetIt.instance<LoggerService>();

  Future<UserLoginResponse> userLogin(String email, String password) async {
    try {
      var ipAddress = await _deviceInfoService.getIpAddress();
      var operatingSystem = await _deviceInfoService.getOperatingSystem();

      final responseData = await _httpController.sendRequest(
          HttpMethod.post,
          'User/Registration/UserLogin',
          {
            "UserInfo": {"Email": email, "Password": password},
            "ClientLogInfo": {
              "IpAddress": ipAddress,
              "OperatingSystem": operatingSystem
            },
          },
          false);
      return UserLoginResponse.fromJson(responseData);
    } catch (e, stackTrace) {
      _logProvider.logError('Login failed', e, stackTrace);
      throw Exception(e.toString());
    }
  }

  Future<UserSignupResponse> userSignup(String company, String firstName,
      String lastName, String email, String password) async {
    try {
      final responseData = await _httpController.sendRequest(
          HttpMethod.put,
          'User/Registration/SignUp',
          {
            "Company": company,
            "FirstName": firstName,
            "LastName": lastName,
            "Email": email,
            "Password": password,
          },
          false);
      return UserSignupResponse.fromJson(responseData);
    } catch (e, stackTrace) {
      _logProvider.logError('Signup failed', e, stackTrace);
      throw Exception(e.toString());
    }
  }

  Future<String> userLogout(String email) async {
    await _sendLogsToServer();

    try {
      final responseData = await _httpController.sendRequest(HttpMethod.post,
          'User/Registration/UserLogout', {"Email": email}, true);
      return responseData.toString();
    } catch (e, stackTrace) {
      _logProvider.logError('Logout failed', e, stackTrace);
      throw Exception(e.toString());
    }
  }

  Future<void> _sendLogsToServer() async {
    final logs = await _logProvider.getLogs();
    final response = await _httpController.sendRequest(
        HttpMethod.post,
        'utilities/log',
        {'logs': logs},
        true); // Assume that sending logs requires a token
    if (response['success']) {
      _logProvider.clearLogs(); // Clear logs on success
    } else {
      _logProvider.logWarning('Failed to send logs to backend');
    }
  }
}

class UserLoginResponse {
  final String? token;
  final String? errorMessage;

  UserLoginResponse({this.token, this.errorMessage});

  static UserLoginResponse fromJson(Map<String, dynamic> json) {
    return UserLoginResponse(
      token: json['item1'] as String?,
      errorMessage: json['item2'] as String?,
    );
  }
}

class UserSignupResponse {
  final String? token;
  final String? errorMessage;

  UserSignupResponse({this.token, this.errorMessage});

  static UserSignupResponse fromJson(Map<String, dynamic> json) {
    return UserSignupResponse(
      token: json['item1'] as String?,
      errorMessage: json['item2'] as String?,
    );
  }
}

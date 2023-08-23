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

  Future<Map<String, String?>> userLogin(String email, String password) async {
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
      return {'item1': responseData['item1'], 'item2': responseData['item2']};
    } catch (e, stackTrace) {
      _logProvider.logError('Login failed', e, stackTrace);
      throw Exception('Login failed');
    }
  }

  Future<Map<String, String?>> userSignup(String company, String firstName,
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
      return {'item1': responseData['item1'], 'item2': responseData['item2']};
    } catch (e, stackTrace) {
      _logProvider.logError('Signup failed', e, stackTrace);
      throw Exception('Signup failed');
    }
  }

  Future<String> userLogout(String email) async {
    try {
      // If there is internet connection, try sending logs
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult != ConnectivityResult.none) {
        await _sendLogsToServer();
      } else {
        return "No internet connection";
      }
    } catch (_) {
      // do nothing
    }

    try {
      final responseData = await _httpController.sendRequest(HttpMethod.post,
          'User/Registration/UserLogout', {"Email": email}, true);
      return responseData.toString();
    } catch (e, stackTrace) {
      _logProvider.logError('Logout failed', e, stackTrace);
      throw Exception('Logout failed');
    }
  }

  Future<void> _sendLogsToServer() async {
    try {
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
    } catch (e, stackTrace) {
      _logProvider.logError('Failed to send logs to backend', e, stackTrace);
    }
  }
}

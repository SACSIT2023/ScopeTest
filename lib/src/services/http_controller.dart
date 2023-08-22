import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;

import 'auth_tocken_service.dart';
import 'config_service.dart';
import 'device_info_service.dart';
import 'logger_service.dart';

enum HttpMethod { post, put }

class HttpController {
  final AuthTockenService authService = AuthTockenService();
  final DeviceInfoService deviceInfoService = DeviceInfoService();
  final LoggerService logProvider = LoggerService();
  final ConfigService configProvider = ConfigService();

  HttpController();

  String getBaseUrl() {
    return configProvider.baseUrl;
  }

  Future<Map<String, dynamic>> sendRequest(HttpMethod method, String url,
      Map<String, dynamic> body, bool requiresToken) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (requiresToken) {
      String? token = authService.token;
      if (token == null) throw Exception('No token found');
      headers['X-Api-Key'] = token;
    }

    final fullUrl = Uri.parse('${getBaseUrl()}$url');
    http.Response response;

    try {
      if (method == HttpMethod.post) {
        response =
            await http.post(fullUrl, headers: headers, body: json.encode(body));
      } else {
        response =
            await http.put(fullUrl, headers: headers, body: json.encode(body));
      }
      if (response.statusCode != 200) {
        throw Exception('Failed to communicate with server');
      }
      return json.decode(response.body);
    } catch (e, stackTrace) {
      logProvider.logError('An error occurred', e, stackTrace);
      throw Exception('Failed to complete request');
    }
  }

  Future<Map<String, String?>> userLogin(String email, String password) async {
    try {
      var ipAddress = await deviceInfoService.getIpAddress();
      var operatingSystem = await deviceInfoService.getOperatingSystem();

      final responseData = await sendRequest(
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
      logProvider.logError('Login failed', e, stackTrace);
      throw Exception('Login failed');
    }
  }

  Future<Map<String, String?>> userSignup(String company, String firstName,
      String lastName, String email, String password) async {
    try {
      final responseData = await sendRequest(
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
      logProvider.logError('Signup failed', e, stackTrace);
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
      final responseData = await sendRequest(HttpMethod.post,
          'User/Registration/UserLogout', {"Email": email}, true);
      return responseData.toString();
    } catch (e, stackTrace) {
      logProvider.logError('Logout failed', e, stackTrace);
      throw Exception('Logout failed');
    }
  }

  Future<void> _sendLogsToServer() async {
    try {
      final logs = await logProvider.getLogs();
      final response = await sendRequest(HttpMethod.post, 'utilities/log',
          {'logs': logs}, true); // Assume that sending logs requires a token
      if (response['success']) {
        logProvider.clearLogs(); // Clear logs on success
      } else {
        logProvider.logWarning('Failed to send logs to backend');
      }
    } catch (e, stackTrace) {
      logProvider.logError('Failed to send logs to backend', e, stackTrace);
    }
  }
}

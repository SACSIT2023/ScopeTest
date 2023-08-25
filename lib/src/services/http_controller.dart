import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'auth_tocken_service.dart';
import 'config_service.dart';
import 'logger_service.dart';

enum HttpMethod { get, post, put, delete }

class HttpController {
  final AuthTockenService authService = GetIt.instance<AuthTockenService>();
  final LoggerService logProvider = GetIt.instance<LoggerService>();
  final ConfigService configProvider = GetIt.instance<ConfigService>();

  HttpController();

  String getBaseUrl() {
    return configProvider.baseUrl;
  }

  Future<Map<String, dynamic>> sendRequest(HttpMethod method, String url,
      [Map<String, dynamic>? body, bool requiresToken = false]) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('No internet connection');
    }

    Map<String, String> headers = {'Content-Type': 'application/json'};
    if (requiresToken) {
      String? token = authService.token;
      if (token == null) throw Exception('No token found');
      headers['X-Api-Key'] = token;
    }

    final fullUrl = Uri.parse('${getBaseUrl()}$url');
    http.Response response;

    try {
      switch (method) {
        case HttpMethod.get:
          response = await http.get(fullUrl, headers: headers);
          break;
        case HttpMethod.post:
          response = await http.post(fullUrl,
              headers: headers, body: json.encode(body));
          break;
        case HttpMethod.put:
          response = await http.put(fullUrl,
              headers: headers, body: json.encode(body));
          break;
        case HttpMethod.delete:
          response = await http.delete(fullUrl, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method');
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
}

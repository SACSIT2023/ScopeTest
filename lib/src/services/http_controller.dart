import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'auth_tocken_service.dart';
import 'config_service.dart';
import 'logger_service.dart';

enum HttpMethod { post, put }

class HttpController {
  final AuthTockenService authService = GetIt.instance<AuthTockenService>();
  final LoggerService logProvider = GetIt.instance<LoggerService>();
  final ConfigService configProvider = GetIt.instance<ConfigService>();

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
}

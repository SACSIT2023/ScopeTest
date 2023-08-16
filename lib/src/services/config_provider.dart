import 'dart:convert';
import 'package:flutter/services.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._();
  late final bool modeDevelopment;
  late final String baseUrl;
  bool ready = false;

  factory ConfigService() {
    return _instance;
  }

  ConfigService._() {
    _fetchConfig();
  }

  Future<void> _fetchConfig() async {
    final config = await _getConfig();
    modeDevelopment = config['mode'] == 'development';
    final mode = config['mode'];
    final modeConfig = config[mode] as Map<String, dynamic>;
    baseUrl = modeConfig['baseUrl'];
    ready = true;
  }

  static Future<Map<String, dynamic>> _getConfig() async {
    final jsonString = await rootBundle.loadString('assets/config.json');
    return jsonDecode(jsonString);
  }
}

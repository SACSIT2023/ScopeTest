import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

class LoggerService {
  final Logger log = Logger('LogProvider');

  LoggerService() {
    log.onRecord.listen((record) async {
      await _storeLog(record);
    });
  }

  Future<void> _storeLog(LogRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> logs = prefs.getStringList('logs') ?? [];
    logs.add(jsonEncode({
      'message': record.message,
      'level': record.level.name,
      'error': record.error.toString(),
      'stackTrace': record.stackTrace.toString(),
    }));
    prefs.setStringList('logs', logs);
  }

  Future<List<String>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('logs') ?? [];
  }

  void logError(String message, dynamic error, StackTrace stackTrace) {
    log.severe(message, error, stackTrace);
  }

  void logWarning(String message) {
    log.warning(message);
  }

  void clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('logs', []);
  }
}

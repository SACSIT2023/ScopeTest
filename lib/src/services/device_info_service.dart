import 'dart:io' show Platform;
import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

class DeviceInfoService {
  final DeviceInfoPlugin deviceInfoPlugin = GetIt.instance<DeviceInfoPlugin>();

  Future<String> getOperatingSystem() async {
    if (kIsWeb) {
      return 'web';
    } else {
      String osName = Platform.operatingSystem;
      switch (osName) {
        case 'android':
          var androidInfo = await deviceInfoPlugin.androidInfo;
          return 'android${androidInfo.version.release}';
        case 'ios':
          var iosInfo = await deviceInfoPlugin.iosInfo;
          return 'IOS${iosInfo.systemVersion}';
        case 'fuchsia':
          return 'Fuchsia';
        case 'macOS':
          return 'MacOS${Platform.operatingSystemVersion}';
        case 'linux':
          return 'Linux${Platform.operatingSystemVersion}';
        case 'windows':
          return 'Windows${Platform.operatingSystemVersion}';
        default:
          throw Exception('Unsupported platform');
      }
    }
  }

  Future<String?> getIpAddress() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return json['ip']; // Extract the IP address from the JSON
      } else {
        return "no internet";
      }
    } catch (e) {
      return "unknown";
    }
  }
}

import 'package:get_it/get_it.dart';

import '../../main_data.dart';
import '../services/http_controller.dart';
import '../services/logger_service.dart';
import 'notification_model.dart';

class NotificationsProvider {
  final HttpController _httpController = GetIt.instance<HttpController>();
  final LoggerService _loggerService = GetIt.instance<LoggerService>();
  final MainData _mainData = GetIt.instance<MainData>();

  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      Map<String, dynamic> response = await _httpController.sendRequest(
        HttpMethod.get,
        'notifications/{$_mainData.userEmail}/Listing',
        null,
        true,
      );

      NotificationsResponse parsedResponse =
          NotificationsResponse.fromJson(response);
      if (parsedResponse.errorMessage != null) {
        throw Exception(parsedResponse.errorMessage);
      }

      return parsedResponse.notifications ?? [];
    } catch (e, stacktrace) {
      _loggerService.logError(
          'Failed to fetch notifications listing', e, stacktrace);
      throw Exception('Failed to fetch notifications.');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _httpController.sendRequest(
        HttpMethod.put,
        'notifications/${_mainData.userEmail}/MarkRead',
        {'id': notificationId},
        true,
      );
    } catch (e, stacktrace) {
      _loggerService.logError(
          'Failed to mark the notification as read', e, stacktrace);
      throw Exception('Failed to mark notification as read.');
    }
  }

  Future<void> dismissNotification(String notificationId) async {
    try {
      await _httpController.sendRequest(
        HttpMethod.put,
        'notifications/${_mainData.userEmail}/MarkAsDismiss',
        {'id': notificationId},
        true,
      );
    } catch (e, stacktrace) {
      _loggerService.logError(
          'Failed to dismiss the notification', e, stacktrace);
      throw Exception('Failed to dismiss the notification.');
    }
  }
}

class NotificationsResponse {
  final List<NotificationModel>? notifications;
  final String? errorMessage;

  NotificationsResponse({this.notifications, this.errorMessage});

  static NotificationsResponse fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      notifications: (json['item1'] as List?)
          ?.map((item) => NotificationModel.fromJson(item))
          .toList(),
      errorMessage: json['item2'] as String?,
    );
  }
}

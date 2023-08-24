import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

import 'notification_model.dart';
import 'notifications_provider.dart';

enum NotificationListState { initial, loading, loaded, error }

class NotificationsBloc {
  final _notificationsProvider = GetIt.instance<NotificationsProvider>();

  final _notificationsController = BehaviorSubject<List<NotificationModel>>();
  final _stateController = BehaviorSubject<NotificationListState>();
  final _errorController = PublishSubject<String>();

  Stream<List<NotificationModel>> get notifications =>
      _notificationsController.stream;
  Stream<NotificationListState> get state => _stateController.stream;
  Stream<String> get errors => _errorController.stream;

  fetchNotifications() async {
    _stateController.sink.add(NotificationListState.loading);
    try {
      List<NotificationModel> fetchedNotifications =
          await _notificationsProvider.fetchNotifications();

      if (fetchedNotifications.isEmpty) {
        throw Exception('No notifications found or returned value is null.');
      }

      _notificationsController.sink.add(fetchedNotifications);
      _stateController.sink.add(NotificationListState.loaded);
    } catch (e) {
      _stateController.sink.add(NotificationListState.error);
      _errorController.sink.add(e.toString());
    }
  }

  void markNotificationAsRead(String notificationId) async {
    try {
      await _notificationsProvider.markNotificationAsRead(notificationId);

      // Update the notification in the local list
      List<NotificationModel> updatedNotifications =
          _notificationsController.value.map((notif) {
        if (notif.id == notificationId) {
          return NotificationModel(
            title: notif.title,
            message: notif.message,
            timeStamp: notif.timeStamp,
            priority: notif.priority,
            expirationDate: notif.expirationDate,
            isRead: true, // Marking the notification as read
          );
        }
        return notif;
      }).toList();

      _notificationsController.sink.add(updatedNotifications);
    } catch (e) {
      _errorController.sink.add(e.toString());
    }
  }

  void dismissNotification(String notificationId) async {
    try {
      await _notificationsProvider.dismissNotification(notificationId);

      // Remove the notification from the local list
      List<NotificationModel> updatedNotifications =
          _notificationsController.value.where((notif) {
        return notif.id != notificationId;
      }).toList();

      _notificationsController.sink.add(updatedNotifications);
    } catch (e) {
      _errorController.sink.add(e.toString());
    }
  }

  dispose() {
    _notificationsController.close();
    _stateController.close();
    _errorController.close();
  }
}

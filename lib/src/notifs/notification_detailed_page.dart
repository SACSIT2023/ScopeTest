import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../services/navigation_service.dart';
import 'notification_model.dart';
import 'notifications_bloc.dart';

class NotificationDetailedPage extends StatelessWidget {
  final NotificationModel notification;

  NotificationDetailedPage({super.key, required this.notification});

  static const routeName = '/NotificationDetailedPage';

  final _navigationService = GetIt.instance<NavigationService>();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NotificationsBloc>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("Notification Detail")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildTitle(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: _buildMessage(),
              ),
            ),
            const SizedBox(height: 32),
            _buildActionButtons(context, bloc),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      notification.title,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMessage() {
    return Text(
      notification.message,
      style: const TextStyle(fontSize: 18),
    );
  }

  Widget _buildActionButtons(BuildContext context, NotificationsBloc bloc) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceEvenly, // Center the action buttons
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text("Mark as Read"),
          onPressed: () {
            bloc.markNotificationAsRead(notification.id);
            _navigationService.goBack();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.delete_outline),
          label: const Text("Dismiss"),
          onPressed: () {
            bloc.dismissNotification(notification.id);
            _navigationService.goBack();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}

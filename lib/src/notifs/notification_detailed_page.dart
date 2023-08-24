import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'notification_model.dart';
import 'notifications_bloc.dart';

class NotificationDetailedPage extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailedPage({super.key, required this.notification});

  static const routeName = '/NotificationDetailedPage';

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NotificationsBloc>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Notification Detail")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              notification.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              notification.message,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 32),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    bloc.markNotificationAsRead(notification.id);
                    Navigator.pop(context); // Close the detail view
                  },
                  child: Text("Mark as Read"),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    bloc.dismissNotification(notification.id);
                    Navigator.pop(context); // Close the detail view
                  },
                  child: Text("Dismiss"),
                ),
              ],
            ),
            // ... Any other details or options you want to display
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notification_model.dart';
import 'notification_widget.dart';
import 'notifications_bloc.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  static const routeName = '/NotificationListPage';

  @override
  NotificationListPageState createState() => NotificationListPageState();
}

class NotificationListPageState extends State<NotificationListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(context));
  }

  Future<void> _loadData(BuildContext context) async {
    final bloc = Provider.of<NotificationsBloc>(context, listen: false);
    await bloc.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<NotificationsBloc>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: _buildBody(bloc),
    );
  }

  Widget _buildBody(NotificationsBloc bloc) {
    return StreamBuilder<NotificationListState>(
      stream: bloc.state,
      builder: (context, stateSnapshot) {
        if (stateSnapshot.data == NotificationListState.loading) {
          return const CircularProgressIndicator();
        } else if (stateSnapshot.data == NotificationListState.error) {
          return const Text("An error occurred!");
        } else {
          return _buildNotificationList(bloc);
        }
      },
    );
  }

  Widget _buildNotificationList(NotificationsBloc bloc) {
    return StreamBuilder<List<NotificationModel>>(
      stream: bloc.notifications,
      builder: (context, notificationSnapshot) {
        if (!notificationSnapshot.hasData ||
            notificationSnapshot.data?.isEmpty == true) {
          return const Text("No notifications available");
        }
        return ListView.builder(
          itemCount: notificationSnapshot.data?.length ?? 0,
          itemBuilder: (context, index) {
            final notification = notificationSnapshot.data![index];
            return NotificationWidget(
              notificationDetails: notification,
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../services/navigation_service.dart';
import 'notification_detailed_page.dart';
import 'notification_model.dart';
import 'notifications_bloc.dart';

class NotificationWidget extends StatefulWidget {
  final NotificationModel notificationDetails;

  const NotificationWidget({
    Key? key,
    required this.notificationDetails,
  }) : super(key: key);

  @override
  NotificationWidgetState createState() => NotificationWidgetState();
}

class NotificationWidgetState extends State<NotificationWidget> {
  final _navigationService = GetIt.instance<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleDetailsTap(context),
      child: _notificationView(),
    );
  }

  void _handleDetailsTap(BuildContext context) {
    final bloc = Provider.of<NotificationsBloc>(context, listen: false);
    bloc.markNotificationAsRead(widget.notificationDetails.id);
    _navigationService.navigateTo(NotificationDetailedPage.routeName,
        arguments: widget.notificationDetails);
  }

  Widget _notificationView() {
    return Card(
      elevation: 5.0,
      child: ListTile(
        leading: Icon(
          widget.notificationDetails.isRead
              ? Icons.check
              : Icons.check_circle_outline,
          color: widget.notificationDetails.isRead ? Colors.green : Colors.grey,
        ),
        title: Text(widget.notificationDetails.title),
        subtitle: Text(widget.notificationDetails.message),
      ),
    );
  }
}

class NotificationModel {
  final String title;
  final String message;
  final DateTime timeStamp;
  final String priority;
  final DateTime expirationDate;
  final bool isRead;

  String get id => '${timeStamp.millisecondsSinceEpoch}_$title';

  NotificationModel({
    required this.title,
    required this.message,
    required this.timeStamp,
    required this.priority,
    required this.expirationDate,
    required this.isRead,
  });

  // For converting JSON data from API to our Model
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'],
      message: json['message'],
      timeStamp: DateTime.parse(json['timeStamp']),
      priority: json['priority'],
      expirationDate: DateTime.parse(json['expirationDate']),
      isRead: bool.parse(json['isRead']),
    );
  }
}

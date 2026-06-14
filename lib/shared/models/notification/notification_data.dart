import 'package:timer/common_libs.dart';
import 'package:timer/shared/controllers/notification_controller.dart';

class NotificationData {
  final NotificationType type;
  final String title;
  final String body;
  final String? imageUrl;
  final String? date;
  final int? unreadCount;
  final String? chatId;
  final String? notificationId;

  const NotificationData({
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    this.date,
    this.unreadCount,
    this.chatId,
    this.notificationId,
  });

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      type: map['type'] == 'chat'
          ? NotificationType.chat
          : NotificationType.normal,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      imageUrl: map['imageUrl'],
      date: map['date'],
      unreadCount: map['unreadCount'] != null
          ? int.tryParse(map['unreadCount'].toString())
          : null,
      chatId: map['chatId'],
      notificationId: map['notificationId'],
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type == NotificationType.chat ? 'chat' : 'normal',
    'title': title,
    'body': body,
    'imageUrl': imageUrl,
    'date': date,
    'unreadCount': unreadCount?.toString(),
    'chatId': chatId,
    'notificationId': notificationId,
  };
}

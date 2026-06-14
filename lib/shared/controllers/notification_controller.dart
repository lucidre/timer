import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timer/common_libs.dart';
import 'package:timer/shared/models/notification/notification_data.dart';

// ─── Notification Type ────────────────────────────────────────────────────────

enum NotificationType { normal, chat }

// ─── Controller ───────────────────────────────────────────────────────────────

class AppNotificationController extends GetxController {
  // ─── Logging ─────────────────────────────────────────────────────────────────

  void _log(Object? value) => $log('Notifications', value);

  // ─── Channels ───────────────────────────────────────────────────────────────

  static const _normalChannel = AndroidNotificationChannel(
    'normal_notifications',
    'Normal Notifications',
    description: 'General app notifications',
    importance: Importance.high,
  );

  static const _chatChannel = AndroidNotificationChannel(
    'chat_notifications',
    'Chat Notifications',
    description: 'Chat messages and updates',
    importance: Importance.max,
    enableVibration: true,
    playSound: true,
  );

  // ─── Plugin ─────────────────────────────────────────────────────────────────

  final _plugin = FlutterLocalNotificationsPlugin();

  // ─── Init ────────────────────────────────────────────────────────────────────

  Future<void> initNotifications() async {
    try {
      await _requestPermissions();
      await _initializePlugin();
      await _createAndroidChannels();
    } catch (e) {
      _log('Init error: $e');
    }
  }

  // ─── Permissions ─────────────────────────────────────────────────────────────

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      final impl = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      final granted = await impl?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      _log('iOS permission granted: $granted');
    } else if (Platform.isAndroid) {
      final version = int.tryParse(Platform.version.split('.').first) ?? 0;
      if (version >= 13) {
        final impl = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final granted = await impl?.requestNotificationsPermission();
        _log('Android permission granted: $granted');
      }
    }
  }

  // ─── Plugin Init ─────────────────────────────────────────────────────────────

  Future<void> _initializePlugin() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: (r) =>
          _handleNotificationTap(r.payload),
    );
  }

  // ─── Android Channels ────────────────────────────────────────────────────────

  Future<void> _createAndroidChannels() async {
    if (!Platform.isAndroid) return;

    final impl = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await Future.wait([
      impl?.createNotificationChannel(_normalChannel) ?? Future.value(),
      impl?.createNotificationChannel(_chatChannel) ?? Future.value(),
    ]);

    _log('Android channels created');
  }

  // ─── FCM Setup ───────────────────────────────────────────────────────────────

  // ─── Message Handlers
  void _handleNotificationTap(String? payload) {
    if (payload == null) return;
    try {
      _navigate(NotificationData.fromMap(jsonDecode(payload)));
    } catch (e) {
      _log('Tap handler error: $e');
    }
  }

  // ─── Show Notification ───────────────────────────────────────────────────────

  Future<void> showNormalNotification(
    NotificationData data,
    String title,
    String body,
  ) async {
    await _plugin.show(
      id: _notificationId(data.notificationId),
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _normalChannel.id,
          _normalChannel.name,
          channelDescription: _normalChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            summaryText: data.date,
          ),
        ),
        iOS: const DarwinNotificationDetails(threadIdentifier: 'normal'),
      ),
      payload: jsonEncode(data.toMap()),
    );
  }

  // ─── Navigation ──────────────────────────────────────────────────────────────

  void _navigate(NotificationData data) {
    switch (data.type) {
      case NotificationType.chat:
        _log('Navigate to chat: ${data.chatId}');

      case NotificationType.normal:
        _log('Navigate to notification: ${data.notificationId}');
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  int _notificationId(String? id) =>
      (id?.hashCode ?? DateTime.now().millisecondsSinceEpoch) & 0x7FFFFFFF;

  // ─── Cancel ──────────────────────────────────────────────────────────────────

  Future<void> cancelNotification(int id) => _plugin.cancel(id: id);
  Future<void> cancelAllNotifications() => _plugin.cancelAll();
}

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

/// Top-level background handler (must be top-level function).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized in main.dart before this runs.
}

/// Manages FCM + local notifications for foreground display.
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  Function(String? route)? onNotificationTap;

  static const _channel = AndroidNotificationChannel(
    'cms2026_channel', 'CMS2026 Notifications',
    description: 'Push notifications from CMS2026',
    importance: Importance.high,
  );

  Future<String?> init() async {
    // Request permission
    final settings = await _fcm.requestPermission(alert: true, badge: true, sound: true);
    if (settings.authorizationStatus != AuthorizationStatus.authorized) return null;

    // Setup local notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);
    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      await _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }

    // Foreground messages → show local notification
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // Background tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // App opened from terminated state via notification
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _handleMessageTap(initial);

    // Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    return await _fcm.getToken();
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id, _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      ),
      payload: message.data['route'],
    );
  }

  void _handleMessageTap(RemoteMessage message) {
    final route = message.data['route'];
    if (route != null) onNotificationTap?.call(route);
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) onNotificationTap?.call(response.payload);
  }

  Future<void> subscribeToTopic(String topic) => _fcm.subscribeToTopic(topic);
  Future<void> unsubscribeFromTopic(String topic) => _fcm.unsubscribeFromTopic(topic);
}

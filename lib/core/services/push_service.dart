import 'package:firebase_messaging/firebase_messaging.dart';
import '../config/app_config.dart';

/// Firebase Cloud Messaging service.
class PushService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FeatureFlags features;

  PushService(this.features);

  Future<String?> init() async {
    if (!features.pushNotifications) return null;

    final settings = await _messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) return null;

    final token = await _messaging.getToken();

    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background tap handler
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // Check if app opened from terminated state via notification
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleMessageTap(initial);

    return token;
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification or in-app banner
    // Implementation depends on flutter_local_notifications package
  }

  void _handleMessageTap(RemoteMessage message) {
    // Navigate to content based on message data
    final data = message.data;
    final route = data['route'];
    if (route != null) {
      // GoRouter navigation will be handled by the app shell
    }
  }

  Future<void> subscribeToTopic(String topic) => _messaging.subscribeToTopic(topic);
  Future<void> unsubscribeFromTopic(String topic) => _messaging.unsubscribeFromTopic(topic);
}

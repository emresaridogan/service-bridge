import 'package:service_bridge/src/contracts/base_service_provider.dart';
import 'package:service_bridge/src/models/notification_message.dart';

/// Contract for push notification providers.
///
/// Implementations: FirebasePushProvider, HuaweiPushProvider,
/// InsiderPushProvider
abstract class PushNotificationProvider extends BaseServiceProvider {
  /// Get the current push notification token.
  Future<String?> getToken();

  /// Stream of token refreshes.
  Stream<String> get onTokenRefresh;

  /// Stream of messages received while the app is in foreground.
  Stream<NotificationMessage> get onMessageReceived;

  /// Stream of messages that caused the app to open from background/terminated.
  Stream<NotificationMessage> get onMessageOpenedApp;

  /// Subscribe to a topic for topic-based messaging.
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribe from a topic.
  Future<void> unsubscribeFromTopic(String topic);

  /// Request push notification permission from the user.
  Future<bool> requestPermission();
}

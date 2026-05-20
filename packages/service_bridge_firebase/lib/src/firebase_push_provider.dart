import 'package:service_bridge/service_bridge.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Firebase Cloud Messaging implementation of [PushNotificationProvider].
class FirebasePushProvider implements PushNotificationProvider {
  /// Creates a [FirebasePushProvider].
  FirebasePushProvider({FirebaseMessaging? messaging}) : _messaging = messaging;

  FirebaseMessaging? _messaging;
  bool _initialized = false;

  @override
  String get providerId => 'firebase';

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    _messaging ??= FirebaseMessaging.instance;
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }

  @override
  Future<String?> getToken() async {
    return _messaging!.getToken();
  }

  @override
  Stream<String> get onTokenRefresh => _messaging!.onTokenRefresh;

  @override
  Stream<NotificationMessage> get onMessageReceived {
    return FirebaseMessaging.onMessage.map(_remoteMessageToNotification);
  }

  @override
  Stream<NotificationMessage> get onMessageOpenedApp {
    return FirebaseMessaging.onMessageOpenedApp.map(_remoteMessageToNotification);
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    await _messaging!.subscribeToTopic(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging!.unsubscribeFromTopic(topic);
  }

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging!.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  NotificationMessage _remoteMessageToNotification(RemoteMessage message) {
    return NotificationMessage(
      title: message.notification?.title,
      body: message.notification?.body,
      data: message.data,
      imageUrl: message.notification?.android?.imageUrl ?? message.notification?.apple?.imageUrl,
      messageId: message.messageId,
    );
  }
}

import 'dart:async';

import 'package:service_bridge/service_bridge.dart';

/// Insider implementation of [PushNotificationProvider].
///
/// Uses the Insider SDK for push notification management.
/// Replace placeholder calls with actual Insider SDK methods.
class InsiderPushProvider implements PushNotificationProvider {
  /// Creates an [InsiderPushProvider].
  InsiderPushProvider();

  bool _initialized = false;
  final StreamController<String> _tokenController = StreamController<String>.broadcast();
  final StreamController<NotificationMessage> _messageController = StreamController<NotificationMessage>.broadcast();
  final StreamController<NotificationMessage> _messageOpenedController = StreamController<NotificationMessage>.broadcast();

  @override
  String get providerId => 'insider';

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    // TODO: Set up Insider push notification listeners
    // Insider.Instance.registerPushToken(token);
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    await _tokenController.close();
    await _messageController.close();
    await _messageOpenedController.close();
    _initialized = false;
  }

  @override
  Future<String?> getToken() async {
    // TODO: Return Insider-managed push token
    return null;
  }

  @override
  Stream<String> get onTokenRefresh => _tokenController.stream;

  @override
  Stream<NotificationMessage> get onMessageReceived => _messageController.stream;

  @override
  Stream<NotificationMessage> get onMessageOpenedApp => _messageOpenedController.stream;

  @override
  Future<void> subscribeToTopic(String topic) async {
    // Insider uses segments rather than topics.
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    // Insider uses segments rather than topics.
  }

  @override
  Future<bool> requestPermission() async {
    // TODO: Insider.Instance.enablePushNotifications();
    return true;
  }
}

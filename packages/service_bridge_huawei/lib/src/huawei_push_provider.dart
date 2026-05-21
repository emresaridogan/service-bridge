import 'dart:async';

import 'package:service_bridge_core/service_bridge_core.dart';

/// Huawei Push Kit implementation of [PushNotificationProvider].
///
/// Used on Huawei/Honor devices without GMS as a replacement for FCM.
/// Replace placeholder calls with actual Huawei Push Kit SDK methods.
class HuaweiPushProvider implements PushNotificationProvider {
  /// Creates a [HuaweiPushProvider].
  HuaweiPushProvider();

  bool _initialized = false;
  final StreamController<String> _tokenController = StreamController<String>.broadcast();
  final StreamController<NotificationMessage> _messageController = StreamController<NotificationMessage>.broadcast();
  final StreamController<NotificationMessage> _messageOpenedController = StreamController<NotificationMessage>.broadcast();

  @override
  String get providerId => SBProvider.huawei.id;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    // TODO: Initialize Huawei Push Kit
    // Push.getTokenStream.listen((token) => _tokenController.add(token));
    // Push.onMessageReceivedStream.listen((msg) => _messageController.add(...));
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
    // TODO: return Push.getToken('');
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
    // TODO: Push.subscribe(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    // TODO: Push.unsubscribe(topic);
  }

  @override
  Future<bool> requestPermission() async {
    // Huawei Push Kit does not require runtime permission on most devices.
    return true;
  }
}

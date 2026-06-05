import 'dart:async';

import 'package:service_bridge_core/src/contracts/push_notification_provider.dart';
import 'package:service_bridge_core/src/core/enums.dart';
import 'package:service_bridge_core/src/core/provider_resolver.dart';
import 'package:service_bridge_core/src/models/notification_message.dart';

/// Manages multiple [PushNotificationProvider] providers.
class PushNotificationManager {
  /// Creates a [PushNotificationManager].
  PushNotificationManager({required List<PushNotificationProvider> providers, Set<SBProvider> defaultProviders = const {}})
    : _providers = providers,
      _defaultProviders = defaultProviders;

  final List<PushNotificationProvider> _providers;
  final Set<SBProvider> _defaultProviders;

  /// All registered push notification providers.
  List<PushNotificationProvider> get providers => List.unmodifiable(_providers);

  /// Get the push token from the first active default provider.
  Future<String?> getToken({SBProvider? provider}) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviders: _defaultProviders, only: provider != null ? {provider} : null);
    if (targets.isEmpty) return null;
    return targets.first.getToken();
  }

  /// Merged stream of token refreshes from all active providers.
  Stream<String> get onTokenRefresh {
    final targets = ProviderResolver.resolve(_providers, defaultProviders: _defaultProviders);
    return StreamGroup.merge(targets.map((p) => p.onTokenRefresh));
  }

  /// Merged stream of foreground messages from all active providers.
  Stream<NotificationMessage> get onMessageReceived {
    final targets = ProviderResolver.resolve(_providers, defaultProviders: _defaultProviders);
    return StreamGroup.merge(targets.map((p) => p.onMessageReceived));
  }

  /// Merged stream of messages that opened the app.
  Stream<NotificationMessage> get onMessageOpenedApp {
    final targets = ProviderResolver.resolve(_providers, defaultProviders: _defaultProviders);
    return StreamGroup.merge(targets.map((p) => p.onMessageOpenedApp));
  }

  /// Subscribe to a topic on all active providers.
  Future<void> subscribeToTopic(String topic, {Set<SBProvider>? only, Set<SBProvider>? exclude}) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviders: _defaultProviders, only: only, exclude: exclude);
    await Future.wait(targets.map((p) => p.subscribeToTopic(topic)));
  }

  /// Unsubscribe from a topic on all active providers.
  Future<void> unsubscribeFromTopic(String topic, {Set<SBProvider>? only, Set<SBProvider>? exclude}) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviders: _defaultProviders, only: only, exclude: exclude);
    await Future.wait(targets.map((p) => p.unsubscribeFromTopic(topic)));
  }

  /// Request notification permission from all active providers.
  /// Returns `true` if at least one provider granted permission.
  Future<bool> requestPermission({Set<SBProvider>? only, Set<SBProvider>? exclude}) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviders: _defaultProviders, only: only, exclude: exclude);
    final results = await Future.wait(targets.map((p) => p.requestPermission()));
    return results.any((granted) => granted);
  }
}

/// Utility to merge multiple streams into one.
class StreamGroup {
  StreamGroup._();

  /// Merge multiple streams into a single stream.
  static Stream<T> merge<T>(Iterable<Stream<T>> streams) {
    final controller = StreamController<T>.broadcast();
    final subscriptions = <StreamSubscription<T>>[];

    for (final stream in streams) {
      subscriptions.add(stream.listen(controller.add, onError: controller.addError));
    }

    controller.onCancel = () async {
      for (final sub in subscriptions) {
        await sub.cancel();
      }
    };

    return controller.stream;
  }
}

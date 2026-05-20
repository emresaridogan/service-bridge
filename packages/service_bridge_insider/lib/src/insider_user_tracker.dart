import 'package:service_bridge/service_bridge.dart';

/// Insider implementation of [UserTracker].
///
/// Uses the Insider SDK for user identification and tracking.
/// Replace placeholder calls with actual Insider SDK methods.
class InsiderUserTracker implements UserTracker {
  /// Creates an [InsiderUserTracker].
  InsiderUserTracker();

  bool _initialized = false;

  @override
  String get providerId => 'insider';

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }

  @override
  Future<void> identifyUser(String userId, {Map<String, dynamic>? attributes}) async {
    // TODO: final user = Insider.Instance.getCurrentUser();
    // user?.setIdentifier(userId);
    // if (attributes != null) {
    //   for (final entry in attributes.entries) {
    //     user?.setCustomAttribute(entry.key, entry.value);
    //   }
    // }
  }

  @override
  Future<void> setUserAttribute(String key, dynamic value) async {
    // TODO: Insider.Instance.getCurrentUser()?.setCustomAttribute(key, value);
  }

  @override
  Future<void> trackEvent(String event, {Map<String, dynamic>? parameters}) async {
    // TODO: Insider.Instance.tagEvent(event)
    //         .addParameters(parameters ?? {}).build();
  }

  @override
  Future<void> logout() async {
    // TODO: Insider.Instance.getCurrentUser()?.logout();
  }
}

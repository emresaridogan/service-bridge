import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:service_bridge/service_bridge.dart';

/// AppsFlyer implementation of [UserTracker].
///
/// Requires [AppsflyerSdk] to be initialized (typically via
/// [AppsFlyerAnalyticsProvider]).
class AppsFlyerUserTracker implements UserTracker {
  /// Creates an [AppsFlyerUserTracker].
  ///
  /// [sdk] should be the same instance used by [AppsFlyerAnalyticsProvider].
  AppsFlyerUserTracker({required AppsflyerSdk sdk}) : _sdk = sdk;

  final AppsflyerSdk _sdk;
  bool _initialized = false;

  @override
  String get providerId => 'appsflyer';

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
  Future<void> identifyUser(
    String userId, {
    Map<String, dynamic>? attributes,
  }) async {
    _sdk.setCustomerUserId(userId);
    if (attributes != null) {
      _sdk.setAdditionalData(attributes);
    }
  }

  @override
  Future<void> setUserAttribute(String key, dynamic value) async {
    _sdk.setAdditionalData({key: value});
  }

  @override
  Future<void> trackEvent(
    String event, {
    Map<String, dynamic>? parameters,
  }) async {
    await _sdk.logEvent(event, parameters ?? {});
  }

  @override
  Future<void> logout() async {
    // AppsFlyer does not have a logout concept.
    // Reset customer user ID if needed.
  }
}

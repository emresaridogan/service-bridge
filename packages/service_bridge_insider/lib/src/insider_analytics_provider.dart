import 'package:service_bridge/service_bridge.dart';

/// Insider implementation of [AnalyticsProvider].
///
/// Uses the Insider SDK to log events and track user behavior.
/// Replace placeholder calls with actual Insider SDK methods.
class InsiderAnalyticsProvider implements AnalyticsProvider {
  /// Creates an [InsiderAnalyticsProvider].
  InsiderAnalyticsProvider();

  bool _initialized = false;

  @override
  String get providerId => 'insider';

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    // TODO: Initialize Insider SDK
    // Insider.init(partnerName: '...', appGroup: '...');
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    // TODO: Insider.Instance.tagEvent(name).addParameters(parameters).build();
  }

  @override
  Future<void> setUserId(String userId) async {
    // TODO: Insider.Instance.getCurrentUser()?.setIdentifier(userId);
  }

  @override
  Future<void> setUserProperty({required String name, required String value}) async {
    // TODO: Insider.Instance.getCurrentUser()?.setCustomAttribute(name, value);
  }

  @override
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    // TODO: Insider.Instance.tagEvent('screen_view')
    //         .addParameter('screen_name', screenName).build();
  }

  @override
  Future<void> resetAnalyticsData() async {
    // Insider manages user data lifecycle separately.
  }
}

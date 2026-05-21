import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:service_bridge_core/service_bridge_core.dart';

/// AppsFlyer implementation of [AnalyticsProvider].
class AppsFlyerAnalyticsProvider implements AnalyticsProvider {
  /// Creates an [AppsFlyerAnalyticsProvider].
  ///
  /// [appsFlyerOptions] configures the AppsFlyer SDK.
  /// If [appsFlyerSdk] is provided, [appsFlyerOptions] is ignored.
  AppsFlyerAnalyticsProvider({AppsFlyerOptions? appsFlyerOptions, AppsflyerSdk? appsFlyerSdk})
    : _options = appsFlyerOptions,
      _sdk = appsFlyerSdk;

  final AppsFlyerOptions? _options;
  AppsflyerSdk? _sdk;
  bool _initialized = false;

  /// The underlying AppsFlyer SDK instance.
  AppsflyerSdk? get sdk => _sdk;

  @override
  String get providerId => SBProvider.appsflyer.id;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (_sdk == null && _options != null) {
      _sdk = AppsflyerSdk(_options);
    }
    await _sdk?.initSdk();
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    await _sdk?.logEvent(name, parameters ?? {});
  }

  @override
  Future<void> setUserId(String userId) async {
    _sdk?.setCustomerUserId(userId);
  }

  @override
  Future<void> setUserProperty({required String name, required String value}) async {
    // AppsFlyer uses additionalData for custom properties.
    _sdk?.setAdditionalData({name: value});
  }

  @override
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    await _sdk?.logEvent('screen_view', {'screen_name': screenName, if (screenClass != null) 'screen_class': screenClass});
  }

  @override
  Future<void> resetAnalyticsData() async {
    // AppsFlyer does not support resetting analytics data.
  }
}

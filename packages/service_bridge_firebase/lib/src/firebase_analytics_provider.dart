import 'package:service_bridge/service_bridge.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Firebase Analytics implementation of [AnalyticsProvider].
class FirebaseAnalyticsProvider implements AnalyticsProvider {
  /// Creates a [FirebaseAnalyticsProvider].
  FirebaseAnalyticsProvider({FirebaseAnalytics? analytics}) : _analytics = analytics;

  FirebaseAnalytics? _analytics;
  bool _initialized = false;

  /// The underlying [FirebaseAnalytics] instance.
  /// Useful for creating [FirebaseAnalyticsObserver].
  FirebaseAnalytics? get analyticsInstance => _analytics;

  @override
  String get providerId => SBProvider.firebase.id;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    _analytics ??= FirebaseAnalytics.instance;
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    await _analytics!.logEvent(name: name, parameters: parameters?.map((key, value) => MapEntry(key, value as Object)));
  }

  @override
  Future<void> setUserId(String userId) async {
    await _analytics!.setUserId(id: userId);
  }

  @override
  Future<void> setUserProperty({required String name, required String value}) async {
    await _analytics!.setUserProperty(name: name, value: value);
  }

  @override
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    await _analytics!.logScreenView(screenName: screenName, screenClass: screenClass);
  }

  @override
  Future<void> resetAnalyticsData() async {
    await _analytics!.resetAnalyticsData();
  }
}

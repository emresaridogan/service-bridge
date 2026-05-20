import 'package:service_bridge/src/contracts/base_service_provider.dart';

/// Contract for analytics providers.
///
/// Implementations: FirebaseAnalyticsProvider, AppsFlyerAnalyticsProvider,
/// InsiderAnalyticsProvider
abstract class AnalyticsProvider extends BaseServiceProvider {
  /// Log a custom analytics event.
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters});

  /// Associate a user ID with analytics events.
  Future<void> setUserId(String userId);

  /// Set a user property for segmentation.
  Future<void> setUserProperty({required String name, required String value});

  /// Log a screen view event.
  Future<void> logScreenView(String screenName, {String? screenClass});

  /// Clear all analytics data for the current user.
  Future<void> resetAnalyticsData();
}

import 'package:service_bridge_core/src/contracts/base_service_provider.dart';

/// Contract for user tracking / attribution providers.
///
/// Implementations: InsiderUserTracker, AppsFlyerUserTracker
abstract class UserTracker extends BaseServiceProvider {
  /// Identify a user and optionally set attributes.
  Future<void> identifyUser(String userId, {Map<String, dynamic>? attributes});

  /// Set a single user attribute.
  Future<void> setUserAttribute(String key, dynamic value);

  /// Track a custom user event.
  Future<void> trackEvent(String event, {Map<String, dynamic>? parameters});

  /// Clear the current user identity (logout).
  Future<void> logout();
}

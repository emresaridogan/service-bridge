import 'package:service_bridge_core/src/contracts/user_tracker.dart';
import 'package:service_bridge_core/src/core/provider_resolver.dart';

/// Manages multiple [UserTracker] providers and dispatches calls.
class UserTrackingManager {
  /// Creates a [UserTrackingManager].
  UserTrackingManager({required List<UserTracker> providers, Set<String> defaultProviderIds = const {}})
    : _providers = providers,
      _defaultProviderIds = defaultProviderIds;

  final List<UserTracker> _providers;
  final Set<String> _defaultProviderIds;

  /// All registered user tracking providers.
  List<UserTracker> get providers => List.unmodifiable(_providers);

  /// Identify a user on all active providers.
  Future<void> identifyUser(String userId, {Map<String, dynamic>? attributes, Set<String>? only, Set<String>? exclude}) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviderIds: _defaultProviderIds, only: only, exclude: exclude);
    await Future.wait(targets.map((p) => p.identifyUser(userId, attributes: attributes)));
  }

  /// Set a user attribute on all active providers.
  Future<void> setUserAttribute(String key, dynamic value, {Set<String>? only, Set<String>? exclude}) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviderIds: _defaultProviderIds, only: only, exclude: exclude);
    await Future.wait(targets.map((p) => p.setUserAttribute(key, value)));
  }

  /// Track a user event on all active providers.
  Future<void> trackEvent(String event, {Map<String, dynamic>? parameters, Set<String>? only, Set<String>? exclude}) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviderIds: _defaultProviderIds, only: only, exclude: exclude);
    await Future.wait(targets.map((p) => p.trackEvent(event, parameters: parameters)));
  }

  /// Logout / clear user identity on all active providers.
  Future<void> logout({Set<String>? only, Set<String>? exclude}) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviderIds: _defaultProviderIds, only: only, exclude: exclude);
    await Future.wait(targets.map((p) => p.logout()));
  }
}

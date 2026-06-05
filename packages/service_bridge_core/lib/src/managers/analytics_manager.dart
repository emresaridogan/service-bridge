import 'package:service_bridge_core/src/contracts/analytics_provider.dart';
import 'package:service_bridge_core/src/core/enums.dart';
import 'package:service_bridge_core/src/core/provider_resolver.dart';

/// Manages multiple [AnalyticsProvider] providers and dispatches calls.
class AnalyticsManager {
  /// Creates an [AnalyticsManager].
  AnalyticsManager({required List<AnalyticsProvider> providers, Set<SBProvider> defaultProviders = const {}})
    : _providers = providers,
      _defaultProviders = defaultProviders;

  final List<AnalyticsProvider> _providers;
  final Set<SBProvider> _defaultProviders;

  /// All registered analytics providers.
  List<AnalyticsProvider> get providers => List.unmodifiable(_providers);

  /// Log an event to active analytics providers.
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters, Set<SBProvider>? only, Set<SBProvider>? exclude}) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviders: _defaultProviders, only: only, exclude: exclude);
    await Future.wait(targets.map((p) => p.logEvent(name, parameters: parameters)));
  }

  /// Set user ID on all active analytics providers.
  Future<void> setUserId(String userId, {Set<SBProvider>? only, Set<SBProvider>? exclude}) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviders: _defaultProviders, only: only, exclude: exclude);
    await Future.wait(targets.map((p) => p.setUserId(userId)));
  }

  /// Set a user property on all active analytics providers.
  Future<void> setUserProperty({required String name, required String value, Set<SBProvider>? only, Set<SBProvider>? exclude}) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviders: _defaultProviders, only: only, exclude: exclude);
    await Future.wait(targets.map((p) => p.setUserProperty(name: name, value: value)));
  }

  /// Log a screen view to all active analytics providers.
  Future<void> logScreenView(String screenName, {String? screenClass, Set<SBProvider>? only, Set<SBProvider>? exclude}) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviders: _defaultProviders, only: only, exclude: exclude);
    await Future.wait(targets.map((p) => p.logScreenView(screenName, screenClass: screenClass)));
  }

  /// Reset analytics data on all active providers.
  Future<void> resetAnalyticsData({Set<SBProvider>? only, Set<SBProvider>? exclude}) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviders: _defaultProviders, only: only, exclude: exclude);
    await Future.wait(targets.map((p) => p.resetAnalyticsData()));
  }
}

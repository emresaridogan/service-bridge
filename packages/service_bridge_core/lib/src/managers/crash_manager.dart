import 'package:service_bridge_core/src/contracts/crash_reporter.dart';
import 'package:service_bridge_core/src/core/enums.dart';
import 'package:service_bridge_core/src/core/provider_resolver.dart';

/// Manages multiple [CrashReporter] providers and dispatches calls.
class CrashManager {
  /// Creates a [CrashManager].
  CrashManager({required List<CrashReporter> providers, Set<String> defaultProviderIds = const {}})
    : _providers = providers,
      _defaultProviderIds = defaultProviderIds;

  final List<CrashReporter> _providers;
  final Set<String> _defaultProviderIds;

  /// All registered crash reporter providers.
  List<CrashReporter> get providers => List.unmodifiable(_providers);

  /// Report an error to active crash reporters.
  Future<void> reportError(
    Object error,
    StackTrace stackTrace, {
    Map<String, dynamic>? extras,
    SeverityLevel? level,
    Set<String>? only,
    Set<String>? exclude,
  }) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviderIds: _defaultProviderIds, only: only, exclude: exclude);
    await Future.wait(targets.map((p) => p.reportError(error, stackTrace, extras: extras, level: level)));
  }

  /// Report a message to active crash reporters.
  Future<void> reportMessage(
    String message, {
    SeverityLevel level = SeverityLevel.info,
    Map<String, dynamic>? extras,
    Set<String>? only,
    Set<String>? exclude,
  }) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviderIds: _defaultProviderIds, only: only, exclude: exclude);
    await Future.wait(targets.map((p) => p.reportMessage(message, level: level, extras: extras)));
  }

  /// Set user ID on all active crash reporters.
  Future<void> setUserId(String userId, {Set<String>? only, Set<String>? exclude}) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviderIds: _defaultProviderIds, only: only, exclude: exclude);
    await Future.wait(targets.map((p) => p.setUserId(userId)));
  }

  /// Set a custom key on all active crash reporters.
  Future<void> setCustomKey(String key, dynamic value, {Set<String>? only, Set<String>? exclude}) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviderIds: _defaultProviderIds, only: only, exclude: exclude);
    await Future.wait(targets.map((p) => p.setCustomKey(key, value)));
  }

  /// Record a breadcrumb on all active crash reporters.
  Future<void> recordBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
    Set<String>? only,
    Set<String>? exclude,
  }) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviderIds: _defaultProviderIds, only: only, exclude: exclude);
    await Future.wait(targets.map((p) => p.recordBreadcrumb(message, category: category, data: data)));
  }
}

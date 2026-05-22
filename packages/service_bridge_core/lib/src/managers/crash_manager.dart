import 'package:service_bridge_core/src/contracts/crash_reporter.dart';
import 'package:service_bridge_core/src/core/crash_context_collector.dart';
import 'package:service_bridge_core/src/core/enums.dart';
import 'package:service_bridge_core/src/core/provider_resolver.dart';
import 'package:service_bridge_core/src/core/sb_logger.dart';

/// Manages multiple [CrashReporter] providers and dispatches calls.
///
/// Automatically enriches every error report with device, connectivity,
/// and app context via [CrashContextCollector]. Callers can pass additional
/// [extras] which are merged on top of the auto-collected context.
class CrashManager {
  /// Creates a [CrashManager].
  ///
  /// [contextCollector] defaults to [CrashContextCollector.instance].
  CrashManager({required List<CrashReporter> providers, Set<String> defaultProviderIds = const {}, CrashContextCollector? contextCollector})
    : _providers = providers,
      _defaultProviderIds = defaultProviderIds,
      _contextCollector = contextCollector ?? CrashContextCollector.instance;

  final List<CrashReporter> _providers;
  final Set<String> _defaultProviderIds;
  final CrashContextCollector _contextCollector;

  /// All registered crash reporter providers.
  List<CrashReporter> get providers => List.unmodifiable(_providers);

  /// Report an error to active crash reporters.
  ///
  /// Automatically collects device, connectivity, and app context.
  /// Any [extras] provided are merged on top (caller values win).
  Future<void> reportError(
    Object error,
    StackTrace stackTrace, {
    Map<String, dynamic>? extras,
    SeverityLevel? level,
    Set<String>? only,
    Set<String>? exclude,
  }) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviderIds: _defaultProviderIds, only: only, exclude: exclude);
    final enrichedExtras = await _enrichExtras(extras);
    await Future.wait(targets.map((p) => _safeReport(p, error, stackTrace, enrichedExtras, level)));
  }

  Future<void> _safeReport(
    CrashReporter provider,
    Object error,
    StackTrace stackTrace,
    Map<String, dynamic> extras,
    SeverityLevel? level,
  ) async {
    try {
      await provider.reportError(error, stackTrace, extras: extras, level: level);
    } on Exception catch (e) {
      SBLogger.error('Failed to report error to ${provider.providerId}', e);
    }
  }

  /// Merges auto-collected context with caller-provided extras.
  /// Caller values take precedence over auto-collected values.
  Future<Map<String, dynamic>> _enrichExtras(Map<String, dynamic>? extras) async {
    try {
      final context = await _contextCollector.collect();
      if (extras != null) context.addAll(extras);
      return context;
    } on Exception catch (e) {
      SBLogger.warning('Failed to collect crash context: $e');
      return extras ?? {};
    }
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

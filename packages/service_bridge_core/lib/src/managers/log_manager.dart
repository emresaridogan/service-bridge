import 'package:service_bridge_core/src/contracts/logger_provider.dart';
import 'package:service_bridge_core/src/core/enums.dart';
import 'package:service_bridge_core/src/core/provider_resolver.dart';

/// Manages multiple [LoggerProvider] providers and dispatches log calls.
class LogManager {
  /// Creates a [LogManager].
  LogManager({required List<LoggerProvider> providers, Set<SBProvider> defaultProviders = const {}})
    : _providers = providers,
      _defaultProviders = defaultProviders;

  final List<LoggerProvider> _providers;
  final Set<SBProvider> _defaultProviders;

  /// All registered logger providers.
  List<LoggerProvider> get providers => List.unmodifiable(_providers);

  /// Log a message at the specified level.
  Future<void> log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? extras,
    Object? error,
    StackTrace? stackTrace,
    Set<SBProvider>? only,
    Set<SBProvider>? exclude,
  }) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviders: _defaultProviders, only: only, exclude: exclude);
    await Future.wait(targets.map((p) => p.log(level, message, extras: extras, error: error, stackTrace: stackTrace)));
  }

  /// Log a debug message.
  Future<void> debug(String message, {Map<String, dynamic>? extras, Set<SBProvider>? only, Set<SBProvider>? exclude}) =>
      log(LogLevel.debug, message, extras: extras, only: only, exclude: exclude);

  /// Log an info message.
  Future<void> info(String message, {Map<String, dynamic>? extras, Set<SBProvider>? only, Set<SBProvider>? exclude}) =>
      log(LogLevel.info, message, extras: extras, only: only, exclude: exclude);

  /// Log a warning message.
  Future<void> warning(String message, {Map<String, dynamic>? extras, Set<SBProvider>? only, Set<SBProvider>? exclude}) =>
      log(LogLevel.warning, message, extras: extras, only: only, exclude: exclude);

  /// Log an error message.
  Future<void> error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
    Set<SBProvider>? only,
    Set<SBProvider>? exclude,
  }) => log(LogLevel.error, message, extras: extras, error: error, stackTrace: stackTrace, only: only, exclude: exclude);
}

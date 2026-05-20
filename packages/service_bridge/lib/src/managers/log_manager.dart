import 'package:service_bridge/src/contracts/logger_provider.dart';
import 'package:service_bridge/src/core/enums.dart';
import 'package:service_bridge/src/core/provider_resolver.dart';

/// Manages multiple [LoggerProvider] providers and dispatches log calls.
class LogManager {
  /// Creates a [LogManager].
  LogManager({required List<LoggerProvider> providers, Set<String> defaultProviderIds = const {}})
    : _providers = providers,
      _defaultProviderIds = defaultProviderIds;

  final List<LoggerProvider> _providers;
  final Set<String> _defaultProviderIds;

  /// All registered logger providers.
  List<LoggerProvider> get providers => List.unmodifiable(_providers);

  /// Log a message at the specified level.
  Future<void> log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? extras,
    Object? error,
    StackTrace? stackTrace,
    Set<String>? only,
    Set<String>? exclude,
  }) async {
    final targets = ProviderResolver.resolve(_providers, defaultProviderIds: _defaultProviderIds, only: only, exclude: exclude);
    await Future.wait(targets.map((p) => p.log(level, message, extras: extras, error: error, stackTrace: stackTrace)));
  }

  /// Log a debug message.
  Future<void> debug(String message, {Map<String, dynamic>? extras, Set<String>? only, Set<String>? exclude}) =>
      log(LogLevel.debug, message, extras: extras, only: only, exclude: exclude);

  /// Log an info message.
  Future<void> info(String message, {Map<String, dynamic>? extras, Set<String>? only, Set<String>? exclude}) =>
      log(LogLevel.info, message, extras: extras, only: only, exclude: exclude);

  /// Log a warning message.
  Future<void> warning(String message, {Map<String, dynamic>? extras, Set<String>? only, Set<String>? exclude}) =>
      log(LogLevel.warning, message, extras: extras, only: only, exclude: exclude);

  /// Log an error message.
  Future<void> error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
    Set<String>? only,
    Set<String>? exclude,
  }) => log(LogLevel.error, message, extras: extras, error: error, stackTrace: stackTrace, only: only, exclude: exclude);
}

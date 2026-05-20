import 'package:service_bridge/service_bridge.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Sentry-based implementation of [LoggerProvider].
///
/// Logs are sent as Sentry breadcrumbs. Error-level logs are also
/// captured as Sentry events.
class SentryLoggerProvider implements LoggerProvider {
  /// Creates a [SentryLoggerProvider].
  SentryLoggerProvider();

  bool _initialized = false;

  @override
  String get providerId => 'sentry_logger';

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }

  @override
  Future<void> log(LogLevel level, String message, {Map<String, dynamic>? extras, Object? error, StackTrace? stackTrace}) async {
    if (error != null && stackTrace != null) {
      if (kDebugMode) {
        debugPrint('Capturing error in Sentry: $error\n$stackTrace');
      }

      await Sentry.addBreadcrumb(Breadcrumb(message: message, level: _mapLevel(level), category: 'log', data: extras));

      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: extras != null
            ? (scope) {
                for (final entry in extras.entries) {
                  scope.setContexts(entry.key, entry.value);
                }
              }
            : null,
      );
    }
  }

  @override
  Future<void> debug(String message, {Map<String, dynamic>? extras}) => log(LogLevel.debug, message, extras: extras);

  @override
  Future<void> info(String message, {Map<String, dynamic>? extras}) => log(LogLevel.info, message, extras: extras);

  @override
  Future<void> warning(String message, {Map<String, dynamic>? extras}) => log(LogLevel.warning, message, extras: extras);

  @override
  Future<void> error(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extras}) =>
      log(LogLevel.error, message, extras: extras, error: error, stackTrace: stackTrace);

  SentryLevel _mapLevel(LogLevel level) {
    return switch (level) {
      LogLevel.verbose || LogLevel.debug => SentryLevel.debug,
      LogLevel.info => SentryLevel.info,
      LogLevel.warning => SentryLevel.warning,
      LogLevel.error => SentryLevel.error,
      LogLevel.fatal => SentryLevel.fatal,
    };
  }
}

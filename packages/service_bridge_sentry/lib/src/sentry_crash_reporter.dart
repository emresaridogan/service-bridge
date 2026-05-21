import 'package:service_bridge/service_bridge.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Sentry implementation of [CrashReporter].
///
/// **Important**: Sentry requires its own initialization via
/// `SentryFlutter.init()` in the host project's `main.dart`.
/// This provider assumes Sentry is already initialized.
///
/// ```dart
/// Future<void> main() async {
///   await SentryFlutter.init(
///     (options) => options
///       ..dsn = 'YOUR_DSN'
///       ..tracesSampleRate = 1.0,
///     appRunner: () async {
///       // Initialize ServiceBridge here
///       await ServiceBridge.initialize(config);
///       runApp(MyApp());
///     },
///   );
/// }
/// ```
class SentryCrashReporter implements CrashReporter {
  /// Creates a [SentryCrashReporter].
  SentryCrashReporter();

  bool _initialized = false;

  @override
  String get providerId => SBProvider.sentry.id;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    // Sentry is initialized via SentryFlutter.init() in host project.
    // We just mark ourselves as ready.
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }

  @override
  Future<void> reportError(Object error, StackTrace stackTrace, {Map<String, dynamic>? extras, SeverityLevel? level}) async {
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: extras != null
          ? (scope) {
              for (final entry in extras.entries) {
                scope.setContexts(entry.key, entry.value);
              }
              if (level != null) {
                scope.level = _mapSeverity(level);
              }
            }
          : null,
    );
  }

  @override
  Future<void> reportMessage(String message, {SeverityLevel level = SeverityLevel.info, Map<String, dynamic>? extras}) async {
    await Sentry.captureMessage(
      message,
      level: _mapSeverity(level),
      withScope: extras != null
          ? (scope) {
              for (final entry in extras.entries) {
                scope.setContexts(entry.key, entry.value);
              }
            }
          : null,
    );
  }

  @override
  Future<void> setUserId(String userId) async {
    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: userId));
    });
  }

  @override
  Future<void> setCustomKey(String key, dynamic value) async {
    Sentry.configureScope((scope) {
      scope.setContexts(key, value);
    });
  }

  @override
  Future<void> recordBreadcrumb(String message, {String? category, Map<String, dynamic>? data}) async {
    await Sentry.addBreadcrumb(Breadcrumb(message: message, category: category, data: data));
  }

  SentryLevel _mapSeverity(SeverityLevel level) {
    return switch (level) {
      SeverityLevel.debug => SentryLevel.debug,
      SeverityLevel.info => SentryLevel.info,
      SeverityLevel.warning => SentryLevel.warning,
      SeverityLevel.error => SentryLevel.error,
      SeverityLevel.fatal => SentryLevel.fatal,
    };
  }
}

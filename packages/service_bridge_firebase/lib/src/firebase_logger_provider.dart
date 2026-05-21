import 'package:service_bridge/service_bridge.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Firebase Crashlytics-based implementation of [LoggerProvider].
///
/// Logs are attached to crash reports as breadcrumbs.
class FirebaseLoggerProvider implements LoggerProvider {
  /// Creates a [FirebaseLoggerProvider].
  FirebaseLoggerProvider({FirebaseCrashlytics? crashlytics}) : _crashlytics = crashlytics;

  FirebaseCrashlytics? _crashlytics;
  bool _initialized = false;

  @override
  String get providerId => SBProvider.firebaseLogger.id;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    _crashlytics ??= FirebaseCrashlytics.instance;
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }

  @override
  Future<void> log(LogLevel level, String message, {Map<String, dynamic>? extras, Object? error, StackTrace? stackTrace}) async {
    final logMessage = '[${level.name.toUpperCase()}] $message';
    await _crashlytics!.log(logMessage);

    if (error != null && stackTrace != null) {
      await _crashlytics!.recordError(error, stackTrace, fatal: level == LogLevel.fatal);
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
}

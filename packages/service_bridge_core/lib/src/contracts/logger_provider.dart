import 'package:service_bridge_core/src/contracts/base_service_provider.dart';
import 'package:service_bridge_core/src/core/enums.dart';

/// Contract for logging providers.
///
/// Implementations: FirebaseLoggerProvider, SentryLoggerProvider,
/// ConsoleLoggerProvider
abstract class LoggerProvider extends BaseServiceProvider {
  /// Log a message at the given level.
  Future<void> log(LogLevel level, String message, {Map<String, dynamic>? extras, Object? error, StackTrace? stackTrace});

  /// Log a debug-level message.
  Future<void> debug(String message, {Map<String, dynamic>? extras});

  /// Log an info-level message.
  Future<void> info(String message, {Map<String, dynamic>? extras});

  /// Log a warning-level message.
  Future<void> warning(String message, {Map<String, dynamic>? extras});

  /// Log an error-level message.
  Future<void> error(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extras});
}

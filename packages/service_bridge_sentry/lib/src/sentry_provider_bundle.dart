import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:service_bridge_sentry/src/sentry_crash_reporter.dart';
import 'package:service_bridge_sentry/src/sentry_logger_provider.dart';

/// Convenience class that creates all Sentry provider instances at once.
///
/// Use [SentryProviderBundle.initialize] to initialize the Sentry SDK
/// and create all providers in one step:
///
/// ```dart
/// final bundle = await SentryProviderBundle.initialize(dsn: 'YOUR_DSN');
///
/// await ServiceBridge.initialize(
///   ServiceBridgeConfig(
///     crashReporters: [bundle.crashReporter],
///     loggerProviders: [bundle.loggerProvider],
///   ),
/// );
/// ```
class SentryProviderBundle {
  /// Creates a [SentryProviderBundle] with all Sentry providers.
  ///
  /// Assumes [SentryFlutter.init] has already been called.
  /// Prefer [SentryProviderBundle.initialize] which handles this
  /// automatically.
  SentryProviderBundle()
    : crashReporter = SentryCrashReporter(),
      loggerProvider = SentryLoggerProvider();

  /// Initializes the Sentry SDK and creates all Sentry providers.
  ///
  /// [dsn] is required — obtain it from your Sentry project settings.
  ///
  /// **Note**: Do NOT use `SentryFlutter.init`'s `appRunner` parameter
  /// when using ServiceBridge. ServiceBridge manages error routing
  /// via its own global error handlers.
  static Future<SentryProviderBundle> initialize({
    required String dsn,
    double tracesSampleRate = 1.0,
  }) async {
    if (kDebugMode) debugPrint('[ServiceBridge] Initializing Sentry...');
    await SentryFlutter.init((options) {
      options
        ..dsn = dsn
        ..tracesSampleRate = tracesSampleRate;
    });
    if (kDebugMode) debugPrint('[ServiceBridge] Sentry initialized');

    return SentryProviderBundle();
  }

  /// Sentry crash reporter.
  final SentryCrashReporter crashReporter;

  /// Sentry breadcrumb/event logger.
  final SentryLoggerProvider loggerProvider;
}

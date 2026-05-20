import 'package:service_bridge_firebase/src/firebase_analytics_provider.dart';
import 'package:service_bridge_firebase/src/firebase_crash_reporter.dart';
import 'package:service_bridge_firebase/src/firebase_logger_provider.dart';
import 'package:service_bridge_firebase/src/firebase_push_provider.dart';
import 'package:service_bridge_firebase/src/firebase_remote_config_provider.dart';

/// Convenience class that creates all Firebase provider instances at once.
///
/// ```dart
/// final bundle = FirebaseProviderBundle(
///   remoteConfigDefaults: {'feature_x': false},
/// );
///
/// await ServiceManager.initialize(
///   ServiceManagerConfig(
///     crashReporters: [bundle.crashReporter],
///     analyticsProviders: [bundle.analyticsProvider],
///     gmsRemoteConfig: bundle.remoteConfigProvider,
///     pushProviders: [bundle.pushProvider],
///     loggerProviders: [bundle.loggerProvider],
///   ),
/// );
/// ```
class FirebaseProviderBundle {
  /// Creates a [FirebaseProviderBundle] with all Firebase providers.
  FirebaseProviderBundle({
    Map<String, dynamic>? remoteConfigDefaults,
    Duration remoteConfigFetchTimeout = const Duration(seconds: 10),
    Duration remoteConfigMinimumFetchInterval = const Duration(hours: 1),
  }) : crashReporter = FirebaseCrashReporter(),
       analyticsProvider = FirebaseAnalyticsProvider(),
       remoteConfigProvider = FirebaseRemoteConfigProvider(
         defaults: remoteConfigDefaults,
         fetchTimeout: remoteConfigFetchTimeout,
         minimumFetchInterval: remoteConfigMinimumFetchInterval,
       ),
       pushProvider = FirebasePushProvider(),
       loggerProvider = FirebaseLoggerProvider();

  /// Firebase Crashlytics crash reporter.
  final FirebaseCrashReporter crashReporter;

  /// Firebase Analytics provider.
  final FirebaseAnalyticsProvider analyticsProvider;

  /// Firebase Remote Config provider.
  final FirebaseRemoteConfigProvider remoteConfigProvider;

  /// Firebase Cloud Messaging push provider.
  final FirebasePushProvider pushProvider;

  /// Firebase Crashlytics-based logger.
  final FirebaseLoggerProvider loggerProvider;
}

import 'package:service_bridge/src/contracts/base_service_provider.dart';
import 'package:service_bridge/src/core/platform_detector.dart';
import 'package:service_bridge/src/core/service_manager_config.dart';
import 'package:service_bridge/src/managers/analytics_manager.dart';
import 'package:service_bridge/src/managers/crash_manager.dart';
import 'package:service_bridge/src/managers/deep_link_manager.dart';
import 'package:service_bridge/src/managers/log_manager.dart';
import 'package:service_bridge/src/managers/push_notification_manager.dart';
import 'package:service_bridge/src/managers/remote_config_manager.dart';
import 'package:service_bridge/src/managers/user_tracking_manager.dart';

/// Central orchestrator for all third-party service providers.
///
/// Provides unified access to crash reporting, analytics, remote config,
/// push notifications, logging, deep linking, and user tracking through
/// category-specific managers.
///
/// ```dart
/// // Initialize once at app startup
/// await ServiceManager.initialize(
///   ServiceManagerConfig(
///     crashReporters: [
///       FirebaseCrashReporter(),
///       SentryCrashReporter(dsn: '...'),
///     ],
///     defaultCrashProviders: {'firebase', 'sentry'},
///     // ...
///   ),
/// );
///
/// // Use throughout the app
/// ServiceManager.instance.crash.reportError(error, stackTrace);
/// ServiceManager.instance.analytics.logEvent('purchase');
/// ```
class ServiceManager {
  ServiceManager._({
    required this.crash,
    required this.analytics,
    required this.remoteConfig,
    required this.pushNotification,
    required this.log,
    required this.deepLink,
    required this.userTracking,
    required this.platform,
  });

  static ServiceManager? _instance;

  /// The singleton instance. Throws if [initialize] has not been called.
  static ServiceManager get instance {
    if (_instance == null) {
      throw StateError(
        'ServiceManager has not been initialized. '
        'Call ServiceManager.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Whether the service manager has been initialized.
  static bool get isInitialized => _instance != null;

  /// Crash reporting manager.
  final CrashManager crash;

  /// Analytics manager.
  final AnalyticsManager analytics;

  /// Remote config manager with automatic GMS/HMS routing.
  final RemoteConfigManager remoteConfig;

  /// Push notification manager.
  final PushNotificationManager pushNotification;

  /// Logging manager.
  final LogManager log;

  /// Deep link manager.
  final DeepLinkManager deepLink;

  /// User tracking / attribution manager.
  final UserTrackingManager userTracking;

  /// Platform detector for GMS/HMS differentiation.
  final PlatformDetector platform;

  /// Initialize the service manager with the given configuration.
  ///
  /// This will:
  /// 1. Create the [PlatformDetector] and detect the platform
  /// 2. Initialize all registered providers
  /// 3. Create category managers
  /// 4. Set up the singleton instance
  ///
  /// Should be called once at app startup, before any service calls.
  static Future<void> initialize(ServiceManagerConfig config) async {
    if (_instance != null) {
      throw StateError(
        'ServiceManager has already been initialized. '
        'Call dispose() before re-initializing.',
      );
    }

    // 1. Platform detection
    final platformDetector = PlatformDetector(platformOverride: config.platformOverride);
    await platformDetector.detect();

    // 2. Collect all unique providers and initialize them
    final allProviders = <BaseServiceProvider>{
      ...config.crashReporters,
      ...config.analyticsProviders,
      if (config.gmsRemoteConfig != null) config.gmsRemoteConfig!,
      if (config.hmsRemoteConfig != null) config.hmsRemoteConfig!,
      ...config.pushProviders,
      ...config.loggerProviders,
      ...config.deepLinkProviders,
      ...config.userTrackers,
    };

    await Future.wait(allProviders.map((p) => p.initialize()));

    // 3. Create managers
    _instance = ServiceManager._(
      crash: CrashManager(providers: config.crashReporters, defaultProviderIds: config.defaultCrashProviders),
      analytics: AnalyticsManager(providers: config.analyticsProviders, defaultProviderIds: config.defaultAnalyticsProviders),
      remoteConfig: RemoteConfigManager(
        platformDetector: platformDetector,
        gmsProvider: config.gmsRemoteConfig,
        hmsProvider: config.hmsRemoteConfig,
      ),
      pushNotification: PushNotificationManager(providers: config.pushProviders, defaultProviderIds: config.defaultPushProviders),
      log: LogManager(providers: config.loggerProviders, defaultProviderIds: config.defaultLogProviders),
      deepLink: DeepLinkManager(providers: config.deepLinkProviders, defaultProviderIds: config.defaultDeepLinkProviders),
      userTracking: UserTrackingManager(providers: config.userTrackers, defaultProviderIds: config.defaultUserTrackingProviders),
      platform: platformDetector,
    );
  }

  /// Dispose all providers and reset the singleton.
  static Future<void> dispose() async {
    if (_instance == null) return;

    final allProviders = <BaseServiceProvider>{
      ..._instance!.crash.providers,
      ..._instance!.analytics.providers,
      if (_instance!.remoteConfig.gmsProvider != null) _instance!.remoteConfig.gmsProvider!,
      if (_instance!.remoteConfig.hmsProvider != null) _instance!.remoteConfig.hmsProvider!,
      ..._instance!.pushNotification.providers,
      ..._instance!.log.providers,
      ..._instance!.deepLink.providers,
      ..._instance!.userTracking.providers,
    };

    await Future.wait(allProviders.map((p) => p.dispose()));

    _instance = null;
  }
}

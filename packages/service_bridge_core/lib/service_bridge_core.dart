/// A modular service management package that orchestrates third-party tools
/// through unified contracts.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:service_bridge/service_bridge.dart';
///
/// await ServiceBridge.initialize(
///   ServiceBridgeConfig(
///     crashReporters: [/* your providers */],
///     defaultCrashProviders: {SBProvider.firebase, SBProvider.sentry},
///   ),
/// );
///
/// // Report errors to all default providers
/// ServiceBridge.instance.crash.reportError(error, stackTrace);
///
/// // Log events to specific providers
/// ServiceBridge.instance.analytics.logEvent('purchase', only: {SBProvider.firebase});
/// ```
library;

// Contracts
export 'src/contracts/analytics_provider.dart';
export 'src/contracts/base_service_provider.dart';
export 'src/contracts/crash_reporter.dart';
export 'src/contracts/deep_link_provider.dart';
export 'src/contracts/logger_provider.dart';
export 'src/contracts/push_notification_provider.dart';
export 'src/contracts/remote_config_provider.dart';
export 'src/contracts/user_tracker.dart';
// Core
export 'src/core/crash_context_collector.dart';
export 'src/core/enums.dart';
export 'src/core/platform_detector.dart';
export 'src/core/provider_resolver.dart';
export 'src/core/service_bridge.dart';
export 'src/core/service_bridge_config.dart';
export 'src/core/service_bridge_error_handler.dart';
// Managers
export 'src/managers/analytics_manager.dart';
export 'src/managers/crash_manager.dart';
export 'src/managers/deep_link_manager.dart';
export 'src/managers/log_manager.dart';
export 'src/managers/push_notification_manager.dart';
export 'src/managers/remote_config_manager.dart';
export 'src/managers/user_tracking_manager.dart';
// Models
export 'src/models/deep_link_params.dart';
export 'src/models/notification_message.dart';
// Observers
export 'src/observers/service_bridge_navigator_observer.dart';

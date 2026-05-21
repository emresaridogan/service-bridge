/// Umbrella package that re-exports all service_bridge sub-packages.
///
/// ```dart
/// import 'package:service_bridge/service_bridge.dart';
/// ```
///
/// This single import gives you access to all service_bridge_core contracts,
/// managers, models, and all provider implementations (AppsFlyer, Firebase,
/// Huawei, Insider, Sentry).
library;

export 'package:service_bridge_core/service_bridge_core.dart';
export 'package:service_bridge_appsflyer/service_bridge_appsflyer.dart';
export 'package:service_bridge_firebase/service_bridge_firebase.dart';
export 'package:service_bridge_huawei/service_bridge_huawei.dart';
export 'package:service_bridge_insider/service_bridge_insider.dart';
export 'package:service_bridge_sentry/service_bridge_sentry.dart';

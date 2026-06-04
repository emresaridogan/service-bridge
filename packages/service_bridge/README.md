# service_bridge

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/emresaridogan/service_bridge/blob/main/LICENSE)

Umbrella package that re-exports [service_bridge_core](https://pub.dev/packages/service_bridge_core) and all provider sub-packages for convenient single-import usage.

> **Note:** This package is intended for monorepo/workspace usage. For pub.dev, depend on `service_bridge_core` and the specific provider packages you need instead.

## What's Included

This package re-exports everything from:

| Package | Description |
|---|---|
| [`service_bridge_core`](https://pub.dev/packages/service_bridge_core) | Core contracts, managers, models, and platform detection |
| [`service_bridge_firebase`](https://pub.dev/packages/service_bridge_firebase) | Firebase (Analytics, Crashlytics, Remote Config, Cloud Messaging, Logging) |
| [`service_bridge_appsflyer`](https://pub.dev/packages/service_bridge_appsflyer) | AppsFlyer (Analytics, Deep Links, User Tracking) |
| [`service_bridge_sentry`](https://pub.dev/packages/service_bridge_sentry) | Sentry (Crash Reporting, Logging) |
| [`service_bridge_insider`](https://pub.dev/packages/service_bridge_insider) | Insider (Analytics, Push Notifications, User Tracking) |
| [`service_bridge_huawei`](https://pub.dev/packages/service_bridge_huawei) | Huawei HMS (Push Notifications, Remote Config) |

## Usage

```dart
// Single import gives you everything
import 'package:service_bridge/service_bridge.dart';
```

## Full Integration Example

```dart
import 'package:service_bridge/service_bridge.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) => options
      ..dsn = 'https://your-dsn@sentry.io/project'
      ..tracesSampleRate = 1.0,
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase first
      final firebase = await FirebaseProviderBundle.initialize(
        remoteConfigDefaults: {'feature_flag': false},
      );

      // Create AppsFlyer provider
      final appsFlyerAnalytics = AppsFlyerAnalyticsProvider(
        appsFlyerOptions: AppsFlyerOptions(
          afDevKey: 'YOUR_DEV_KEY',
          appId: 'YOUR_APP_ID',
        ),
      );

      await ServiceBridge.initialize(
        ServiceBridgeConfig(
          // Crash — Firebase + Sentry
          crashReporters: [firebase.crashReporter, SentryCrashReporter()],
          defaultCrashProviders: {SBProvider.firebase.id, SBProvider.sentry.id},

          // Analytics — Firebase + AppsFlyer
          analyticsProviders: [firebase.analyticsProvider, appsFlyerAnalytics],
          defaultAnalyticsProviders: {SBProvider.firebase.id, SBProvider.appsflyer.id},

          // Remote Config — GMS/HMS routing
          gmsRemoteConfig: firebase.remoteConfigProvider,
          hmsRemoteConfig: HuaweiRemoteConfigProvider(),

          // Push — Firebase
          pushProviders: [firebase.pushProvider],
          defaultPushProviders: {SBProvider.firebase.id},

          // Logging — Firebase + Sentry
          loggerProviders: [firebase.loggerProvider, SentryLoggerProvider()],
          defaultLogProviders: {SBProvider.firebaseLogger.id, SBProvider.sentryLogger.id},
        ),
      );

      ServiceBridgeErrorHandler.runGuarded(() {
        runApp(const MyApp());
      });
    },
  );
}
```

## Additional Information

- **Repository:** [github.com/emresaridogan/service_bridge](https://github.com/emresaridogan/service_bridge)
- **Issues:** [GitHub Issues](https://github.com/emresaridogan/service_bridge/issues)
- **License:** MIT

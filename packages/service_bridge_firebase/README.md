# service_bridge_firebase

[![Pub Version](https://img.shields.io/pub/v/service_bridge_firebase.svg)](https://pub.dev/packages/service_bridge_firebase)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/emresaridogan/service_bridge/blob/main/LICENSE)

Firebase provider implementations for the [Service Bridge](https://pub.dev/packages/service_bridge_core) ecosystem. Provides ready-to-use integrations for Firebase Analytics, Crashlytics, Remote Config, Cloud Messaging, and logging through Crashlytics.

## Features

- **FirebaseAnalyticsProvider** — Event tracking, screen views, user properties via Firebase Analytics
- **FirebaseCrashReporter** — Error reporting, custom keys, breadcrumbs via Firebase Crashlytics
- **FirebaseRemoteConfigProvider** — Remote configuration with configurable fetch intervals and defaults
- **FirebasePushProvider** — Push notifications with token management, topic subscriptions, and permission handling via Firebase Cloud Messaging
- **FirebaseLoggerProvider** — Structured logging that writes to Crashlytics logs
- **FirebaseProviderBundle** — Convenience class that initializes Firebase Core and creates all Firebase providers in one call

## Installation

```yaml
dependencies:
  service_bridge_firebase: ^1.0.0
```

```bash
dart pub add service_bridge_firebase
```

## Platform Setup

Before using this package, complete the standard Firebase setup for your Flutter project:

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Install the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) and run `flutterfire configure`
3. Add the generated `firebase_options.dart` to your project

For detailed instructions, see the [official FlutterFire documentation](https://firebase.flutter.dev/docs/overview).

## Usage

### Quick Setup with FirebaseProviderBundle

The easiest way to get started is with `FirebaseProviderBundle`, which initializes Firebase Core and creates all providers:

```dart
import 'package:service_bridge_firebase/service_bridge_firebase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and create all providers in one call
  final firebase = await FirebaseProviderBundle.initialize(
    options: DefaultFirebaseOptions.currentPlatform,
    remoteConfigDefaults: {'feature_flag': false, 'banner_text': 'Welcome'},
    remoteConfigMinimumFetchInterval: const Duration(minutes: 5),
  );

  // Use providers in ServiceBridge configuration
  await ServiceBridge.initialize(
    ServiceBridgeConfig(
      crashReporters: [firebase.crashReporter],
      defaultCrashProviders: {SBProvider.firebase.id},

      analyticsProviders: [firebase.analyticsProvider],
      defaultAnalyticsProviders: {SBProvider.firebase.id},

      gmsRemoteConfig: firebase.remoteConfigProvider,

      pushProviders: [firebase.pushProvider],
      defaultPushProviders: {SBProvider.firebase.id},

      loggerProviders: [firebase.loggerProvider],
      defaultLogProviders: {SBProvider.firebaseLogger.id},
    ),
  );

  runApp(const MyApp());
}
```

### Individual Provider Setup

You can also create providers individually for more control:

```dart
// Analytics
final analytics = FirebaseAnalyticsProvider();

// Crash reporting
final crashReporter = FirebaseCrashReporter();

// Remote config with custom settings
final remoteConfig = FirebaseRemoteConfigProvider(
  defaults: {'feature_x': true, 'max_retries': 3},
  fetchTimeout: const Duration(seconds: 15),
  minimumFetchInterval: const Duration(hours: 1),
);

// Push notifications
final push = FirebasePushProvider();

// Logger (writes to Crashlytics logs)
final logger = FirebaseLoggerProvider();
```

### Using the Providers

Once initialized through `ServiceBridge`, use them via the manager API:

```dart
final sb = ServiceBridge.instance;

// Analytics
await sb.analytics.logEvent('purchase', parameters: {'item_id': 'sku_001'});
await sb.analytics.logScreenView('ProductDetail');

// Crash reporting
await sb.crash.reportError(error, stackTrace);
await sb.crash.setCustomKey('user_tier', 'premium');
await sb.crash.recordBreadcrumb('Added item to cart', category: 'commerce');

// Remote config
await sb.remoteConfig.fetchAndActivate();
final enabled = sb.remoteConfig.getBool('feature_flag');
final text = sb.remoteConfig.getString('banner_text');

// Push notifications
final token = await sb.pushNotification.getToken();
await sb.pushNotification.subscribeToTopic('promotions');
final granted = await sb.pushNotification.requestPermission();

sb.pushNotification.onMessageReceived.listen((msg) {
  print('Received: ${msg.title} — ${msg.body}');
});

// Logging (via Crashlytics)
await sb.log.info('User signed in');
await sb.log.error('Payment failed', error: e, stackTrace: st);
```

## Providers

### FirebaseAnalyticsProvider

| Method | Description |
|---|---|
| `logEvent(name, parameters)` | Log a custom analytics event |
| `logScreenView(screenName, screenClass)` | Log a screen view |
| `setUserId(userId)` | Set the user ID for analytics |
| `setUserProperty(name, value)` | Set a user property |
| `resetAnalyticsData()` | Reset all analytics data |

**Provider ID:** `firebase`

### FirebaseCrashReporter

| Method | Description |
|---|---|
| `reportError(error, stackTrace, extras, level)` | Report an error (fatal if `level == SeverityLevel.fatal`) |
| `reportMessage(message, level, extras)` | Log a message to Crashlytics |
| `setUserId(userId)` | Set user identifier |
| `setCustomKey(key, value)` | Set a custom key-value pair |
| `recordBreadcrumb(message, category, data)` | Record a breadcrumb log |

**Provider ID:** `firebase`

### FirebaseRemoteConfigProvider

| Method | Description |
|---|---|
| `fetchAndActivate()` | Fetch and activate remote config values |
| `getString(key, defaultValue)` | Get a string value |
| `getBool(key, defaultValue)` | Get a boolean value |
| `getInt(key, defaultValue)` | Get an integer value |
| `getDouble(key, defaultValue)` | Get a double value |
| `getAll()` | Get all config values as a map |
| `setMinimumFetchInterval(interval)` | Update the minimum fetch interval |

**Provider ID:** `firebase`

### FirebasePushProvider

| Method / Property | Description |
|---|---|
| `getToken()` | Get the current FCM token |
| `onTokenRefresh` | Stream of token refreshes |
| `onMessageReceived` | Stream of foreground messages |
| `onMessageOpenedApp` | Stream of messages that opened the app |
| `subscribeToTopic(topic)` | Subscribe to a topic |
| `unsubscribeFromTopic(topic)` | Unsubscribe from a topic |
| `requestPermission()` | Request notification permissions |

**Provider ID:** `firebase`

### FirebaseLoggerProvider

| Method | Description |
|---|---|
| `log(level, message, extras, error, stackTrace)` | Log with a specific level |
| `debug(message, extras)` | Log a debug message |
| `info(message, extras)` | Log an info message |
| `warning(message, extras)` | Log a warning message |
| `error(message, error, stackTrace, extras)` | Log an error (recorded to Crashlytics if error + stackTrace provided) |

**Provider ID:** `firebase_logger`

### FirebaseProviderBundle

Convenience class for initializing all Firebase providers at once:

```dart
final bundle = await FirebaseProviderBundle.initialize(
  options: DefaultFirebaseOptions.currentPlatform,
  remoteConfigDefaults: {'key': 'value'},
  remoteConfigFetchTimeout: const Duration(seconds: 10),
  remoteConfigMinimumFetchInterval: const Duration(seconds: 10),
);

// Access individual providers:
bundle.crashReporter;
bundle.analyticsProvider;
bundle.remoteConfigProvider;
bundle.pushProvider;
bundle.loggerProvider;
```

## Dependencies

This package depends on the following Firebase packages:

| Package | Version |
|---|---|
| `firebase_core` | 4.9.0 |
| `firebase_analytics` | 12.4.1 |
| `firebase_crashlytics` | 5.2.2 |
| `firebase_messaging` | 16.2.2 |
| `firebase_remote_config` | 6.5.1 |

## Additional Information

- **Repository:** [github.com/emresaridogan/service_bridge](https://github.com/emresaridogan/service_bridge)
- **Issues:** [GitHub Issues](https://github.com/emresaridogan/service_bridge/issues)
- **License:** MIT

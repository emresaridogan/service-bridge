# service_bridge

A modular, multi-provider service management layer for Flutter applications. It orchestrates third-party SDKs (Firebase, Sentry, AppsFlyer, Insider, Huawei HMS) through unified contracts, allowing you to swap or combine providers without changing application code.

---

## Table of Contents

- [Overview](#overview)
- [Packages](#packages)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Managers](#managers)
  - [CrashManager](#crashmanager)
  - [AnalyticsManager](#analyticsmanager)
  - [RemoteConfigManager](#remoteconfigmanager)
  - [PushNotificationManager](#pushnotificationmanager)
  - [LogManager](#logmanager)
  - [DeepLinkManager](#deeplinkmanager)
  - [UserTrackingManager](#usertrackingmanager)
- [Provider Routing](#provider-routing)
- [GMS / HMS Detection](#gms--hms-detection)
- [Writing a Custom Provider](#writing-a-custom-provider)
- [Monorepo Setup](#monorepo-setup)
- [Running Tests](#running-tests)

---

## Overview

`service_bridge` introduces a thin abstraction layer between your Flutter app and its third-party service dependencies. Each service category (crash reporting, analytics, push notifications, etc.) is represented by a **contract** (abstract class). Concrete implementations live in separate packages, so you only include the SDKs your project actually uses.

Key characteristics:

- **Multi-provider fan-out** — most managers broadcast calls to all active providers in parallel.
- **Per-call targeting** — every manager method accepts `only` (whitelist) and `exclude` (blacklist) sets so individual calls can be scoped to specific providers.
- **Automatic GMS/HMS routing** — `RemoteConfigManager` detects the device platform at runtime and routes to the correct provider (Firebase for GMS devices, Huawei for HMS devices).
- **Lazy initialization** — all providers are initialised once during `ServiceManager.initialize()` and their lifecycle is managed centrally.

---

## Packages

| Package | Description |
|---|---|
| [`service_bridge`](packages/service_bridge) | Core contracts, managers, `ServiceManager`, and `PlatformDetector` |
| [`service_bridge_firebase`](packages/service_bridge_firebase) | Firebase implementations (Analytics, Crashlytics, Remote Config, Cloud Messaging, Performance Logging) |
| [`service_bridge_appsflyer`](packages/service_bridge_appsflyer) | AppsFlyer implementations (Analytics, Deep Links, User Tracking) |
| [`service_bridge_sentry`](packages/service_bridge_sentry) | Sentry implementations (Crash Reporting, Logging) |
| [`service_bridge_insider`](packages/service_bridge_insider) | Insider implementations (Analytics, Push Notifications, User Tracking) |
| [`service_bridge_huawei`](packages/service_bridge_huawei) | Huawei HMS implementations (Push Notifications, Remote Config) |

---

## Architecture

```
ServiceManager  (singleton)
│
├── CrashManager            ─► CrashReporter[]        (Firebase, Sentry, …)
├── AnalyticsManager        ─► AnalyticsProvider[]    (Firebase, AppsFlyer, Insider, …)
├── RemoteConfigManager     ─► RemoteConfigProvider   (GMS → Firebase | HMS → Huawei)
├── PushNotificationManager ─► PushNotificationProvider[] (Firebase, Huawei, Insider, …)
├── LogManager              ─► LoggerProvider[]       (Firebase, Sentry, …)
├── DeepLinkManager         ─► DeepLinkProvider[]     (AppsFlyer, Firebase, …)
├── UserTrackingManager     ─► UserTracker[]          (Insider, AppsFlyer, …)
└── PlatformDetector                                  (GMS vs HMS)
```

Each manager holds a list of providers and uses `ProviderResolver` to filter them based on initialization status and the `only`/`exclude`/`defaultProviders` rules before dispatching any call.

---

## Getting Started

### 1. Add dependencies

In your app's `pubspec.yaml`, add the core package and whichever integration packages you need:

```yaml
dependencies:
  service_bridge:
    path: packages/service_bridge

  # Include only the integrations you use
  service_bridge_firebase:
    path: packages/service_bridge_firebase

  service_bridge_sentry:
    path: packages/service_bridge_sentry

  service_bridge_appsflyer:
    path: packages/service_bridge_appsflyer
```

### 2. Initialize at app startup

Call `ServiceManager.initialize()` before `runApp()` (or inside `main()` after `WidgetsFlutterBinding.ensureInitialized()`):

```dart
import 'package:service_bridge/service_bridge.dart';
import 'package:service_bridge_firebase/service_bridge_firebase.dart';
import 'package:service_bridge_sentry/service_bridge_sentry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ServiceManager.initialize(
    ServiceManagerConfig(
      // Crash reporting
      crashReporters: [
        FirebaseCrashReporter(),
        SentryCrashReporter(dsn: 'https://your-dsn@sentry.io/project'),
      ],
      defaultCrashProviders: {'firebase', 'sentry'},

      // Analytics
      analyticsProviders: [
        FirebaseAnalyticsProvider(),
        AppsFlyerAnalyticsProvider(devKey: 'YOUR_KEY'),
      ],
      defaultAnalyticsProviders: {'firebase', 'appsflyer'},

      // Remote config (GMS/HMS routing)
      gmsRemoteConfig: FirebaseRemoteConfigProvider(),
      hmsRemoteConfig: HuaweiRemoteConfigProvider(),

      // Push notifications
      pushProviders: [FirebasePushProvider()],
      defaultPushProviders: {'firebase'},

      // Logging
      loggerProviders: [FirebaseLoggerProvider(), SentryLoggerProvider()],
      defaultLogProviders: {'firebase'},
    ),
  );

  runApp(const MyApp());
}
```

### 3. Use throughout the app

```dart
final sm = ServiceManager.instance;

// Crash reporting
await sm.crash.reportError(error, stackTrace);

// Analytics
await sm.analytics.logEvent('purchase', parameters: {'item_id': 'sku_001'});

// Log a screen view
await sm.analytics.logScreenView('HomeScreen');

// Remote config
await sm.remoteConfig.fetchAndActivate();
final featureEnabled = await sm.remoteConfig.getBool('new_feature');

// Push notifications
final token = await sm.pushNotification.getToken();
sm.pushNotification.onMessageReceived.listen((msg) { /* … */ });

// Logging
await sm.log.warning('Cache miss', extras: {'key': 'user_profile'});

// Deep links
final initialLink = await sm.deepLink.getInitialLink();
sm.deepLink.onDeepLink.listen((uri) { /* … */ });

// User tracking
await sm.userTracking.identifyUser('user_123', attributes: {'plan': 'premium'});
```

---

## Configuration

`ServiceManagerConfig` accepts the following parameters:

| Parameter | Type | Description |
|---|---|---|
| `crashReporters` | `List<CrashReporter>` | All crash reporting providers |
| `defaultCrashProviders` | `Set<String>` | Provider IDs active by default |
| `analyticsProviders` | `List<AnalyticsProvider>` | All analytics providers |
| `defaultAnalyticsProviders` | `Set<String>` | Provider IDs active by default |
| `gmsRemoteConfig` | `RemoteConfigProvider?` | Remote config for GMS (Google) devices |
| `hmsRemoteConfig` | `RemoteConfigProvider?` | Remote config for HMS (Huawei) devices |
| `pushProviders` | `List<PushNotificationProvider>` | All push notification providers |
| `defaultPushProviders` | `Set<String>` | Provider IDs active by default |
| `loggerProviders` | `List<LoggerProvider>` | All logging providers |
| `defaultLogProviders` | `Set<String>` | Provider IDs active by default |
| `deepLinkProviders` | `List<DeepLinkProvider>` | All deep link providers |
| `defaultDeepLinkProviders` | `Set<String>` | Provider IDs active by default |
| `userTrackers` | `List<UserTracker>` | All user tracking providers |
| `defaultUserTrackingProviders` | `Set<String>` | Provider IDs active by default |
| `platformOverride` | `PlatformType?` | Force `gms` or `hms` instead of runtime detection |

---

## Managers

### CrashManager

Broadcasts crash reports and messages to all active crash reporters.

```dart
// Report to all default providers
await sm.crash.reportError(error, stackTrace);

// Report only to Sentry
await sm.crash.reportError(error, stackTrace, only: {'sentry'});

// Report to all except Firebase
await sm.crash.reportError(error, stackTrace, exclude: {'firebase'});

// Non-fatal message
await sm.crash.reportMessage('Payment failed', level: SeverityLevel.warning);

// Add context
await sm.crash.setUserId('user_123');
await sm.crash.setCustomKey('screen', 'checkout');
await sm.crash.recordBreadcrumb('tapped checkout button', category: 'ui');
```

### AnalyticsManager

Fans out analytics events to all active analytics providers.

```dart
await sm.analytics.logEvent('add_to_cart', parameters: {'item': 'sku_001'});
await sm.analytics.logScreenView('ProductDetail', screenClass: 'ProductDetailPage');
await sm.analytics.setUserId('user_123');
await sm.analytics.setUserProperty(name: 'subscription', value: 'premium');
await sm.analytics.resetAnalyticsData();
```

### RemoteConfigManager

Routes to a single provider based on device platform (GMS or HMS). Falls back to the alternate provider if the primary one fails.

```dart
await sm.remoteConfig.fetchAndActivate();

final title       = await sm.remoteConfig.getString('home_banner_title');
final isEnabled   = await sm.remoteConfig.getBool('dark_mode_enabled');
final maxRetries  = await sm.remoteConfig.getInt('max_retry_count');
final threshold   = await sm.remoteConfig.getDouble('score_threshold');
```

### PushNotificationManager

Manages tokens and message streams across multiple push providers.

```dart
final token = await sm.pushNotification.getToken();

sm.pushNotification.onMessageReceived.listen((msg) {
  print('Foreground message: ${msg.title}');
});

sm.pushNotification.onMessageOpenedApp.listen((msg) {
  // Navigate based on message payload
});

await sm.pushNotification.subscribeToTopic('promotions');
final granted = await sm.pushNotification.requestPermission();
```

### LogManager

Dispatches structured log entries to all active logger providers.

```dart
await sm.log.debug('Cache populated');
await sm.log.info('User signed in', extras: {'userId': 'user_123'});
await sm.log.warning('Low memory warning');
await sm.log.error('Request failed', error: e, stackTrace: st);
```

Log levels (from `LogLevel` enum): `verbose`, `debug`, `info`, `warning`, `error`, `fatal`.

### DeepLinkManager

Aggregates deep link streams and delegates link creation to a specific provider.

```dart
// Cold-start link
final uri = await sm.deepLink.getInitialLink();

// Live stream (merged from all active providers)
sm.deepLink.onDeepLink.listen((uri) { /* handle */ });

// Generate a link using a specific provider
final link = await sm.deepLink.createDeepLink(
  DeepLinkParams(path: '/product/42'),
  providerId: 'appsflyer',
);
```

### UserTrackingManager

Broadcasts user identity and events to all active tracking providers.

```dart
await sm.userTracking.identifyUser('user_123', attributes: {'plan': 'pro'});
await sm.userTracking.setUserAttribute('last_seen', DateTime.now().toIso8601String());
await sm.userTracking.trackEvent('viewed_offer', parameters: {'offer_id': '99'});
await sm.userTracking.logout();
```

---

## Provider Routing

Every manager method accepts two optional parameters that control which providers receive the call:

| Parameter | Type | Behaviour |
|---|---|---|
| `only` | `Set<String>?` | Call **only** the listed provider IDs, ignoring the defaults |
| `exclude` | `Set<String>?` | Call all default providers **except** the listed ones |
| _(neither)_ | — | Call all providers in `defaultProviders` |

Providers that have not been successfully initialised (`isInitialized == false`) are always excluded.

```dart
// Only Firebase
await sm.analytics.logEvent('debug_event', only: {'firebase'});

// All defaults except Insider
await sm.analytics.logEvent('purchase', exclude: {'insider'});
```

---

## GMS / HMS Detection

`PlatformDetector` determines whether the device uses **Google Mobile Services (GMS)** or **Huawei Mobile Services (HMS)** using the following priority:

1. Cached result from a previous `detect()` call.
2. Build-time `platformOverride` (set in `ServiceManagerConfig`).
3. Runtime detection via `device_info_plus` — checks `brand` and `manufacturer` for `huawei`/`honor`.
4. Defaults to `PlatformType.gms` on all non-Android platforms and on detection failures.

To force a platform in CI or flavored builds:

```dart
ServiceManagerConfig(
  platformOverride: PlatformType.hms,
  // …
)
```

---

## Writing a Custom Provider

1. Implement the relevant contract from `service_bridge`.
2. Set a unique `providerId` string.
3. Manage your SDK lifecycle in `initialize()` and `dispose()`.

```dart
class MyCustomAnalyticsProvider extends AnalyticsProvider {
  @override
  String get providerId => 'my_custom_analytics';

  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    // set up your SDK
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    // forward to your SDK
  }

  // … implement remaining abstract methods
}
```

Then register it in the config:

```dart
ServiceManagerConfig(
  analyticsProviders: [MyCustomAnalyticsProvider()],
  defaultAnalyticsProviders: {'my_custom_analytics'},
)
```

---

## Monorepo Setup

The workspace is managed with [Melos](https://melos.invertase.io/) and uses [FVM](https://fvm.app/) for Flutter version management.

```bash
# Install Melos
dart pub global activate melos

# Bootstrap all packages (resolves dependencies with pubspec overrides)
melos bootstrap

# Run static analysis across all packages
melos analyze

# Run all tests
melos test

# Check formatting
melos format
```

The active Flutter SDK version is managed by FVM and is stored in `.fvm/flutter_sdk`.

---

## Running Tests

```bash
# Run tests for the core package only
cd packages/service_bridge
dart test

# Run all package tests via Melos
melos test
```

---

*Created By: Emre Sarıdoğan*

# service_bridge_core

[![Pub Version](https://img.shields.io/pub/v/service_bridge_core.svg)](https://pub.dev/packages/service_bridge_core)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/emresaridogan/service_bridge/blob/main/LICENSE)

Core contracts, managers, models, and utilities for the **Service Bridge** ecosystem — a modular, multi-provider service management layer for Flutter applications.

This package defines the abstractions that all provider packages implement. You typically depend on this package directly only when building a custom provider; application code usually depends on a specific provider package (e.g. `service_bridge_firebase`) which re-exports this package automatically.

## Features

- **7 service contracts** — `AnalyticsProvider`, `CrashReporter`, `LoggerProvider`, `PushNotificationProvider`, `DeepLinkProvider`, `RemoteConfigProvider`, `UserTracker`
- **7 managers** — Orchestrate multiple providers per service category with parallel fan-out
- **Provider routing** — Per-call `only`/`exclude` filtering with automatic exclusion of uninitialized providers
- **GMS/HMS detection** — Runtime platform detection with build-time override support
- **Error handler** — Catches Flutter errors, platform dispatcher errors, and zone-level errors with deduplication
- **Navigator observer** — Automatic screen view logging for analytics
- **Testing utilities** — Ready-to-use mock providers for all contracts

## Installation

```yaml
dependencies:
  service_bridge_core: ^1.0.0
```

```bash
dart pub add service_bridge_core
```

## Contracts

All contracts extend `BaseServiceProvider` which defines the provider lifecycle:

```dart
abstract class BaseServiceProvider {
  String get providerId;
  bool get isInitialized;
  Future<void> initialize();
  Future<void> dispose();
}
```

| Contract | Purpose | Key Methods |
|---|---|---|
| `AnalyticsProvider` | Event tracking & screen views | `logEvent()`, `logScreenView()`, `setUserId()`, `setUserProperty()`, `resetAnalyticsData()` |
| `CrashReporter` | Error & crash reporting | `reportError()`, `reportMessage()`, `setUserId()`, `setCustomKey()`, `recordBreadcrumb()` |
| `LoggerProvider` | Structured logging | `log()`, `debug()`, `info()`, `warning()`, `error()` |
| `PushNotificationProvider` | Push notification management | `getToken()`, `onTokenRefresh`, `onMessageReceived`, `onMessageOpenedApp`, `subscribeToTopic()`, `requestPermission()` |
| `DeepLinkProvider` | Deep link handling | `getInitialLink()`, `onDeepLink`, `createDeepLink()` |
| `RemoteConfigProvider` | Remote configuration | `fetchAndActivate()`, `getString()`, `getBool()`, `getInt()`, `getDouble()`, `getAll()` |
| `UserTracker` | User identity & event tracking | `identifyUser()`, `setUserAttribute()`, `trackEvent()`, `logout()` |

## Managers

Each manager orchestrates a list of providers. Most broadcast calls to **all active providers** in parallel. `RemoteConfigManager` is the exception — it routes to a single provider based on platform (GMS or HMS).

### CrashManager

```dart
// Report to all default providers
await sb.crash.reportError(error, stackTrace);

// Report only to Sentry
await sb.crash.reportError(error, stackTrace, only: {SBProvider.sentry.id});

// Exclude Firebase
await sb.crash.reportError(error, stackTrace, exclude: {SBProvider.firebase.id});

// Breadcrumbs & context
await sb.crash.setUserId('user_123');
await sb.crash.setCustomKey('screen', 'checkout');
await sb.crash.recordBreadcrumb('tapped buy', category: 'ui');
```

### AnalyticsManager

```dart
await sb.analytics.logEvent('purchase', parameters: {'item_id': 'sku_001'});
await sb.analytics.logScreenView('HomeScreen');
await sb.analytics.setUserId('user_123');
await sb.analytics.setUserProperty(name: 'plan', value: 'premium');
```

### RemoteConfigManager

Routes to a single provider based on device platform (GMS → Firebase, HMS → Huawei). Falls back to the alternate provider if the primary one fails.

```dart
await sb.remoteConfig.fetchAndActivate();
final enabled = sb.remoteConfig.getBool('feature_flag');
final title = sb.remoteConfig.getString('banner_title');
```

### PushNotificationManager

Merges streams from multiple push providers.

```dart
final token = await sb.pushNotification.getToken();
sb.pushNotification.onMessageReceived.listen((msg) => print(msg.title));
await sb.pushNotification.subscribeToTopic('news');
await sb.pushNotification.requestPermission();
```

### LogManager

```dart
await sb.log.debug('Cache populated');
await sb.log.info('User signed in', extras: {'method': 'google'});
await sb.log.warning('Slow query detected');
await sb.log.error('API failed', error: e, stackTrace: st);
```

### DeepLinkManager

```dart
final initialLink = await sb.deepLink.getInitialLink();
sb.deepLink.onDeepLink.listen((uri) => navigateTo(uri));
```

### UserTrackingManager

```dart
await sb.userTracking.identifyUser('user_123', attributes: {'plan': 'pro'});
await sb.userTracking.trackEvent('viewed_offer', parameters: {'id': '99'});
await sb.userTracking.logout();
```

## Provider Routing

Every manager method accepts two optional parameters:

| Parameter | Type | Behavior |
|---|---|---|
| `only` | `Set<String>?` | Call **only** the listed provider IDs |
| `exclude` | `Set<String>?` | Call all defaults **except** the listed ones |
| _(neither)_ | — | Call all providers in `defaultProviders` |

Providers where `isInitialized == false` are always excluded automatically.

## Platform Detection

`PlatformDetector` determines GMS vs HMS using this priority:

1. Cached result from a previous `detect()` call
2. Build-time `platformOverride` (from `ServiceBridgeConfig`)
3. Runtime detection via `device_info_plus` (checks brand/manufacturer for `huawei`/`honor`)
4. Defaults to `PlatformType.gms` on non-Android platforms and on detection failures

```dart
ServiceBridgeConfig(
  platformOverride: PlatformType.hms, // Force HMS in CI or flavored builds
)
```

## Error Handling

`ServiceBridgeErrorHandler` sets up comprehensive error capture:

```dart
ServiceBridgeErrorHandler.runGuarded(() {
  runApp(const MyApp());
});
```

This catches:
- `FlutterError.onError` (framework errors)
- `PlatformDispatcher.instance.onError` (platform errors)
- Zone-level uncaught errors
- Automatic deduplication (same error within 500ms is reported once)

## Navigator Observer

Automatically logs screen views to your analytics providers:

```dart
MaterialApp(
  navigatorObservers: [
    ServiceBridgeNavigatorObserver(
      analyticsManager: ServiceBridge.instance.analytics,
      nameExtractor: (settings) => settings.name, // customize route name extraction
      routeFilter: (route) => route is PageRoute,  // filter which routes to track
    ),
  ],
)
```

## Testing

The `testing.dart` library provides mock implementations for all contracts:

```dart
import 'package:service_bridge_core/testing.dart';

// Available mocks:
// MockCrashReporter    — tracks reports, breadcrumbs
// MockAnalyticsProvider — tracks events, screen views
// MockRemoteConfigProvider — configurable values map
// MockLoggerProvider   — tracks log entries
// MockPushNotificationProvider — controllable streams
// MockDeepLinkProvider — controllable streams
// MockUserTracker      — tracks events, userId

void main() {
  test('logs purchase event', () async {
    final analytics = MockAnalyticsProvider();
    await analytics.initialize();

    await analytics.logEvent('purchase', parameters: {'item': 'sku_001'});

    expect(analytics.events, hasLength(1));
    expect(analytics.events.first.name, 'purchase');
  });
}
```

## Models

| Model | Fields |
|---|---|
| `NotificationMessage` | `title`, `body`, `data`, `imageUrl`, `messageId` |
| `DeepLinkParams` | `link`, `domainUriPrefix`, `title`, `description`, `imageUrl`, `customParameters` |

## Enums

| Enum | Values |
|---|---|
| `SeverityLevel` | `debug`, `info`, `warning`, `error`, `fatal` |
| `LogLevel` | `verbose`, `debug`, `info`, `warning`, `error`, `fatal` |
| `PlatformType` | `gms`, `hms` |
| `SBProvider` | `firebase`, `firebaseLogger`, `sentry`, `sentryLogger`, `appsflyer`, `insider`, `huawei` |

## Writing a Custom Provider

1. Implement the relevant contract
2. Set a unique `providerId`
3. Manage SDK lifecycle in `initialize()` and `dispose()`

```dart
class MyAnalyticsProvider implements AnalyticsProvider {
  @override
  String get providerId => 'my_analytics';

  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    // Initialize your SDK
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    // Forward to your SDK
  }

  // ... implement remaining methods
}
```

## Additional Information

- **Repository:** [github.com/emresaridogan/service_bridge](https://github.com/emresaridogan/service_bridge)
- **Issues:** [GitHub Issues](https://github.com/emresaridogan/service_bridge/issues)
- **License:** MIT

# service_bridge_insider

[![Pub Version](https://img.shields.io/pub/v/service_bridge_insider.svg)](https://pub.dev/packages/service_bridge_insider)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/emresaridogan/service_bridge/blob/main/LICENSE)

> **⚠️ Experimental:** This package contains stub implementations. The Insider Flutter SDK integration is not yet fully wired. Method bodies are placeholders awaiting the official Insider SDK dependency.

Insider provider implementations for the [Service Bridge](https://pub.dev/packages/service_bridge_core) ecosystem. Provides analytics, push notification, and user tracking integrations via the Insider SDK.

## Features

- **InsiderAnalyticsProvider** — Event tracking, screen views, and user properties via Insider
- **InsiderPushProvider** — Push notification management via Insider (uses segments instead of topics)
- **InsiderUserTracker** — User identification, attributes, and event tracking via Insider

## Installation

```yaml
dependencies:
  service_bridge_insider: ^1.0.0
```

```bash
dart pub add service_bridge_insider
```

## Setup

> **Note:** The Insider Flutter SDK is typically provided through Insider's documentation portal. Once the SDK is available, add it to this package's dependencies.

```dart
import 'package:service_bridge_insider/service_bridge_insider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ServiceBridge.initialize(
    ServiceBridgeConfig(
      analyticsProviders: [InsiderAnalyticsProvider()],
      defaultAnalyticsProviders: {SBProvider.insider.id},

      pushProviders: [InsiderPushProvider()],
      defaultPushProviders: {SBProvider.insider.id},

      userTrackers: [InsiderUserTracker()],
      defaultUserTrackingProviders: {SBProvider.insider.id},
    ),
  );

  runApp(const MyApp());
}
```

## Usage

```dart
final sb = ServiceBridge.instance;

// Analytics
await sb.analytics.logEvent('product_viewed', parameters: {'product_id': '123'});
await sb.analytics.logScreenView('ProductDetail');

// Push notifications
sb.pushNotification.onMessageReceived.listen((msg) {
  print('Received: ${msg.title}');
});

// User tracking
await sb.userTracking.identifyUser('user_123', attributes: {
  'plan': 'premium',
  'segment': 'high_value',
});
await sb.userTracking.trackEvent('purchase', parameters: {'amount': 99.99});
await sb.userTracking.logout();
```

## Providers

### InsiderAnalyticsProvider

| Method | Description |
|---|---|
| `logEvent(name, parameters)` | Tag an in-app event *(stub)* |
| `logScreenView(screenName, screenClass)` | Log screen view as event *(stub)* |
| `setUserId(userId)` | Set user identifier *(stub)* |
| `setUserProperty(name, value)` | Set custom user attribute *(stub)* |
| `resetAnalyticsData()` | Not supported (Insider manages data lifecycle separately) |

**Provider ID:** `insider`

### InsiderPushProvider

| Method / Property | Description |
|---|---|
| `getToken()` | Get Insider-managed push token *(stub)* |
| `onTokenRefresh` | Stream of token refreshes |
| `onMessageReceived` | Stream of received messages |
| `onMessageOpenedApp` | Stream of messages that opened the app |
| `subscribeToTopic(topic)` | Insider uses segments instead of topics |
| `unsubscribeFromTopic(topic)` | Insider uses segments instead of topics |
| `requestPermission()` | Enable push notifications *(stub)* |

**Provider ID:** `insider`

### InsiderUserTracker

| Method | Description |
|---|---|
| `identifyUser(userId, attributes)` | Set user identifier and custom attributes *(stub)* |
| `setUserAttribute(key, value)` | Set a custom user attribute *(stub)* |
| `trackEvent(event, parameters)` | Tag an event *(stub)* |
| `logout()` | Log out user *(stub)* |

**Provider ID:** `insider`

## Additional Information

- **Repository:** [github.com/emresaridogan/service_bridge](https://github.com/emresaridogan/service_bridge)
- **Issues:** [GitHub Issues](https://github.com/emresaridogan/service_bridge/issues)
- **License:** MIT

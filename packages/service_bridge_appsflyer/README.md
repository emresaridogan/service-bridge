# service_bridge_appsflyer

[![Pub Version](https://img.shields.io/pub/v/service_bridge_appsflyer.svg)](https://pub.dev/packages/service_bridge_appsflyer)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/emresaridogan/service_bridge/blob/main/LICENSE)

AppsFlyer provider implementations for the [Service Bridge](https://pub.dev/packages/service_bridge_core) ecosystem. Provides analytics, deep link handling, and user tracking integrations via the AppsFlyer SDK.

## Features

- **AppsFlyerAnalyticsProvider** — Event tracking, screen views, and user properties via AppsFlyer
- **AppsFlyerDeepLinkProvider** — Deep link reception through AppsFlyer's Unified Deep Linking
- **AppsFlyerUserTracker** — User identification and event tracking via AppsFlyer

## Installation

```yaml
dependencies:
  service_bridge_appsflyer: ^1.0.0
```

```bash
dart pub add service_bridge_appsflyer
```

## Platform Setup

1. Create an AppsFlyer account at [appsflyer.com](https://www.appsflyer.com/)
2. Register your app and obtain your **Dev Key**
3. Follow the [AppsFlyer Flutter SDK setup guide](https://dev.appsflyer.com/hc/docs/flutter-sdk) for platform-specific configuration (iOS: add `AppsFlyerDevKey` to Info.plist, Android: add the SDK to your build)

## Usage

### Setting Up Providers

```dart
import 'package:service_bridge_appsflyer/service_bridge_appsflyer.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create the AppsFlyer analytics provider with SDK options
  final appsFlyerAnalytics = AppsFlyerAnalyticsProvider(
    appsFlyerOptions: AppsFlyerOptions(
      afDevKey: 'YOUR_DEV_KEY',
      appId: 'YOUR_APP_ID',
      showDebug: true,
    ),
  );

  // For deep links and user tracking, pass the SDK instance
  // after the analytics provider has been initialized
  await appsFlyerAnalytics.initialize();
  final sdk = appsFlyerAnalytics.sdk!;

  final appsFlyerDeepLink = AppsFlyerDeepLinkProvider(sdk: sdk);
  final appsFlyerUserTracker = AppsFlyerUserTracker(sdk: sdk);

  await ServiceBridge.initialize(
    ServiceBridgeConfig(
      analyticsProviders: [appsFlyerAnalytics],
      defaultAnalyticsProviders: {SBProvider.appsflyer.id},

      deepLinkProviders: [appsFlyerDeepLink],
      defaultDeepLinkProviders: {SBProvider.appsflyer.id},

      userTrackers: [appsFlyerUserTracker],
      defaultUserTrackingProviders: {SBProvider.appsflyer.id},
    ),
  );

  runApp(const MyApp());
}
```

### Using the Providers

```dart
final sb = ServiceBridge.instance;

// Analytics
await sb.analytics.logEvent('purchase', parameters: {
  'revenue': 29.99,
  'currency': 'USD',
  'item_id': 'sku_001',
});
await sb.analytics.logScreenView('ProductDetail');
await sb.analytics.setUserId('user_123');

// Deep links
final initialLink = await sb.deepLink.getInitialLink();
sb.deepLink.onDeepLink.listen((uri) {
  // Handle deep link navigation
  print('Deep link received: $uri');
});

// User tracking
await sb.userTracking.identifyUser('user_123', attributes: {
  'plan': 'premium',
  'signup_date': '2024-01-15',
});
await sb.userTracking.trackEvent('viewed_offer', parameters: {'offer_id': '99'});
```

## Providers

### AppsFlyerAnalyticsProvider

| Method | Description |
|---|---|
| `logEvent(name, parameters)` | Log an in-app event |
| `logScreenView(screenName, screenClass)` | Log a screen view (as a `screen_view` event) |
| `setUserId(userId)` | Set the customer user ID |
| `setUserProperty(name, value)` | Set additional data |
| `resetAnalyticsData()` | Not supported by AppsFlyer (no-op) |

**Provider ID:** `appsflyer`

### AppsFlyerDeepLinkProvider

| Method / Property | Description |
|---|---|
| `getInitialLink()` | Returns `null` (AppsFlyer handles initial links via callback) |
| `onDeepLink` | Stream of deep link URIs received via Unified Deep Linking |
| `createDeepLink(params)` | Returns the input link (OneLink creation is done via dashboard) |

**Provider ID:** `appsflyer`

### AppsFlyerUserTracker

| Method | Description |
|---|---|
| `identifyUser(userId, attributes)` | Set customer user ID and additional data |
| `setUserAttribute(key, value)` | Set additional user data |
| `trackEvent(event, parameters)` | Log an in-app event |
| `logout()` | Not supported by AppsFlyer (no-op) |

**Provider ID:** `appsflyer`

## Additional Information

- **Repository:** [github.com/emresaridogan/service_bridge](https://github.com/emresaridogan/service_bridge)
- **Issues:** [GitHub Issues](https://github.com/emresaridogan/service_bridge/issues)
- **License:** MIT

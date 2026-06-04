# service_bridge_huawei

[![Pub Version](https://img.shields.io/pub/v/service_bridge_huawei.svg)](https://pub.dev/packages/service_bridge_huawei)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/emresaridogan/service_bridge/blob/main/LICENSE)

> **⚠️ Experimental:** This package contains stub implementations. The Huawei HMS SDK dependencies are commented out. Method bodies are placeholders awaiting the HMS SDK integration.

Huawei HMS provider implementations for the [Service Bridge](https://pub.dev/packages/service_bridge_core) ecosystem. Provides push notification and remote configuration integrations for Huawei Mobile Services (HMS) devices.

## Features

- **HuaweiPushProvider** — Push notification management via Huawei Push Kit (token management, message streams)
- **HuaweiRemoteConfigProvider** — Remote configuration via Huawei AGConnect Remote Config

## Installation

```yaml
dependencies:
  service_bridge_huawei: ^1.0.0
```

```bash
dart pub add service_bridge_huawei
```

## Platform Setup

> **Note:** HMS SDK packages (`huawei_push`, `huawei_agconnect_remote_config`) are currently commented out in this package's dependencies. Enable them when integrating with HMS.

1. Create a Huawei developer account at [developer.huawei.com](https://developer.huawei.com)
2. Register your app in AppGallery Connect
3. Download `agconnect-services.json` and add it to your Android project
4. Follow the [HMS Flutter plugin setup guide](https://developer.huawei.com/consumer/en/doc/HMS-Plugin-Guides/prepareenv-0000001050155774-V1)

## Usage

### Setting Up with ServiceBridge

```dart
import 'package:service_bridge_huawei/service_bridge_huawei.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ServiceBridge.initialize(
    ServiceBridgeConfig(
      // Huawei remote config is used on HMS devices
      hmsRemoteConfig: HuaweiRemoteConfigProvider(
        defaults: {'feature_flag': false, 'banner_text': 'Welcome'},
      ),

      pushProviders: [HuaweiPushProvider()],
      defaultPushProviders: {SBProvider.huawei.id},
    ),
  );

  runApp(const MyApp());
}
```

### GMS/HMS Automatic Routing

When used with `service_bridge_firebase`, `RemoteConfigManager` automatically routes to the correct provider:

```dart
await ServiceBridge.initialize(
  ServiceBridgeConfig(
    gmsRemoteConfig: FirebaseRemoteConfigProvider(), // GMS devices
    hmsRemoteConfig: HuaweiRemoteConfigProvider(),   // HMS devices
  ),
);

// This automatically uses the correct provider based on device
await sb.remoteConfig.fetchAndActivate();
final value = sb.remoteConfig.getString('key');
```

### Using the Providers

```dart
final sb = ServiceBridge.instance;

// Remote config (automatically routed on HMS devices)
await sb.remoteConfig.fetchAndActivate();
final enabled = sb.remoteConfig.getBool('feature_flag');
final text = sb.remoteConfig.getString('banner_text');

// Push notifications
final token = await sb.pushNotification.getToken();
sb.pushNotification.onMessageReceived.listen((msg) {
  print('Received: ${msg.title}');
});
await sb.pushNotification.subscribeToTopic('news');
```

## Providers

### HuaweiPushProvider

| Method / Property | Description |
|---|---|
| `getToken()` | Get Huawei Push Kit token *(stub)* |
| `onTokenRefresh` | Stream of token refreshes |
| `onMessageReceived` | Stream of received messages |
| `onMessageOpenedApp` | Stream of messages that opened the app |
| `subscribeToTopic(topic)` | Subscribe to a topic *(stub)* |
| `unsubscribeFromTopic(topic)` | Unsubscribe from a topic *(stub)* |
| `requestPermission()` | Returns `true` (HMS Push Kit does not require runtime permission on most devices) |

**Provider ID:** `huawei`

### HuaweiRemoteConfigProvider

| Method | Description |
|---|---|
| `fetchAndActivate()` | Fetch and activate remote config values *(stub)* |
| `getString(key, defaultValue)` | Get a string value |
| `getBool(key, defaultValue)` | Get a boolean value |
| `getInt(key, defaultValue)` | Get an integer value |
| `getDouble(key, defaultValue)` | Get a double value |
| `getAll()` | Get all config values as a map |
| `setMinimumFetchInterval(interval)` | Set minimum fetch interval *(stub)* |

**Provider ID:** `huawei`

## Additional Information

- **Repository:** [github.com/emresaridogan/service_bridge](https://github.com/emresaridogan/service_bridge)
- **Issues:** [GitHub Issues](https://github.com/emresaridogan/service_bridge/issues)
- **License:** MIT

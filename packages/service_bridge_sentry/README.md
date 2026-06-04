# service_bridge_sentry

[![Pub Version](https://img.shields.io/pub/v/service_bridge_sentry.svg)](https://pub.dev/packages/service_bridge_sentry)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/emresaridogan/service_bridge/blob/main/LICENSE)

Sentry provider implementations for the [Service Bridge](https://pub.dev/packages/service_bridge_core) ecosystem. Provides crash reporting and structured logging via the Sentry SDK.

## Features

- **SentryCrashReporter** — Error reporting, breadcrumbs, custom context, and user identification via Sentry
- **SentryLoggerProvider** — Structured logging that sends breadcrumbs and captures error-level logs as Sentry events
- **SentryProviderBundle** — Convenience class that groups all Sentry providers

## Installation

```yaml
dependencies:
  service_bridge_sentry: ^1.0.0
```

```bash
dart pub add service_bridge_sentry
```

## Setup

**Important:** Sentry requires its own initialization via `SentryFlutter.init()` before using these providers. Wrap your app startup with Sentry's initializer:

```dart
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:service_bridge_sentry/service_bridge_sentry.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) => options
      ..dsn = 'https://your-dsn@sentry.io/project'
      ..tracesSampleRate = 1.0,
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();

      await ServiceBridge.initialize(
        ServiceBridgeConfig(
          crashReporters: [SentryCrashReporter()],
          defaultCrashProviders: {SBProvider.sentry.id},

          loggerProviders: [SentryLoggerProvider()],
          defaultLogProviders: {SBProvider.sentryLogger.id},
        ),
      );

      runApp(const MyApp());
    },
  );
}
```

## Usage

```dart
final sb = ServiceBridge.instance;

// Crash reporting
try {
  // risky operation
} catch (e, st) {
  await sb.crash.reportError(e, st, extras: {'screen': 'checkout'});
}

// Non-fatal message
await sb.crash.reportMessage('Payment retry', level: SeverityLevel.warning);

// User identification (sent to Sentry as SentryUser)
await sb.crash.setUserId('user_123');

// Custom context
await sb.crash.setCustomKey('subscription', 'premium');

// Breadcrumbs
await sb.crash.recordBreadcrumb(
  'Added item to cart',
  category: 'commerce',
  data: {'item_id': 'sku_001'},
);

// Logging — error-level logs are also captured as Sentry events
await sb.log.info('User signed in');
await sb.log.warning('Slow API response');
await sb.log.error('Payment failed', error: e, stackTrace: st);
```

## Providers

### SentryCrashReporter

| Method | Description |
|---|---|
| `reportError(error, stackTrace, extras, level)` | Capture an exception in Sentry with optional context and severity |
| `reportMessage(message, level, extras)` | Capture a message event |
| `setUserId(userId)` | Set the Sentry user (as `SentryUser`) |
| `setCustomKey(key, value)` | Set scope context data |
| `recordBreadcrumb(message, category, data)` | Add a Sentry breadcrumb |

**Provider ID:** `sentry`

### SentryLoggerProvider

Logs are sent as Sentry breadcrumbs. When an error and stack trace are provided, they are additionally captured as Sentry events.

| Method | Description |
|---|---|
| `log(level, message, extras, error, stackTrace)` | Log with a specific level |
| `debug(message, extras)` | Log a debug breadcrumb |
| `info(message, extras)` | Log an info breadcrumb |
| `warning(message, extras)` | Log a warning breadcrumb |
| `error(message, error, stackTrace, extras)` | Log and capture error as Sentry event |

**Provider ID:** `sentry_logger`

## Severity Mapping

| ServiceBridge `SeverityLevel` | Sentry `SentryLevel` |
|---|---|
| `debug` | `SentryLevel.debug` |
| `info` | `SentryLevel.info` |
| `warning` | `SentryLevel.warning` |
| `error` | `SentryLevel.error` |
| `fatal` | `SentryLevel.fatal` |

## Additional Information

- **Repository:** [github.com/emresaridogan/service_bridge](https://github.com/emresaridogan/service_bridge)
- **Issues:** [GitHub Issues](https://github.com/emresaridogan/service_bridge/issues)
- **License:** MIT

## Unreleased

- `AnalyticsProvider.setUserId` / `AnalyticsManager.setUserId` now accept `null` to clear the user ID (e.g. on logout). Custom `AnalyticsProvider` implementations must update the parameter type to `String?`.

## 1.0.0

- Initial release
- Core contracts: `AnalyticsProvider`, `CrashReporter`, `LoggerProvider`, `PushNotificationProvider`, `DeepLinkProvider`, `RemoteConfigProvider`, `UserTracker`
- 7 managers with multi-provider fan-out and per-call routing (`only`/`exclude`)
- `PlatformDetector` for automatic GMS/HMS detection
- `ServiceBridgeErrorHandler` for comprehensive error capture with deduplication
- `ServiceBridgeNavigatorObserver` for automatic screen view logging
- Testing utilities with mock providers for all contracts
- Models: `NotificationMessage`, `DeepLinkParams`

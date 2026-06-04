# service_bridge

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/emresaridogan/service_bridge/blob/main/LICENSE)

[service_bridge_core](https://pub.dev/packages/service_bridge_core) ve tüm sağlayıcı alt paketlerini tek import ile kullanım kolaylığı için dışa aktaran şemsiye paket.

> **Not:** Bu paket monorepo/workspace kullanımı için tasarlanmıştır. pub.dev üzerinden kullanım için `service_bridge_core` ve ihtiyacınız olan belirli sağlayıcı paketlerine ayrı ayrı bağımlılık ekleyin.

## İçerik

Bu paket aşağıdakilerin tamamını dışa aktarır:

| Paket | Açıklama |
|---|---|
| [`service_bridge_core`](https://pub.dev/packages/service_bridge_core) | Temel sözleşmeler, manager'lar, modeller ve platform tespiti |
| [`service_bridge_firebase`](https://pub.dev/packages/service_bridge_firebase) | Firebase (Analytics, Crashlytics, Remote Config, Cloud Messaging, Loglama) |
| [`service_bridge_appsflyer`](https://pub.dev/packages/service_bridge_appsflyer) | AppsFlyer (Analytics, Deep Link, Kullanıcı Takibi) |
| [`service_bridge_sentry`](https://pub.dev/packages/service_bridge_sentry) | Sentry (Hata Raporlama, Loglama) |
| [`service_bridge_insider`](https://pub.dev/packages/service_bridge_insider) | Insider (Analytics, Push Bildirimleri, Kullanıcı Takibi) |
| [`service_bridge_huawei`](https://pub.dev/packages/service_bridge_huawei) | Huawei HMS (Push Bildirimleri, Remote Config) |

## Kullanım

```dart
// Tek import ile her şeye erişin
import 'package:service_bridge/service_bridge.dart';
```

## Tam Entegrasyon Örneği

```dart
import 'package:service_bridge/service_bridge.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) => options
      ..dsn = 'https://dsn-adresiniz@sentry.io/proje'
      ..tracesSampleRate = 1.0,
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Önce Firebase'i başlat
      final firebase = await FirebaseProviderBundle.initialize(
        remoteConfigDefaults: {'ozellik_bayragi': false},
      );

      // AppsFlyer sağlayıcısını oluştur
      final appsFlyerAnalytics = AppsFlyerAnalyticsProvider(
        appsFlyerOptions: AppsFlyerOptions(
          afDevKey: 'DEV_KEY_INIZ',
          appId: 'APP_ID_NIZ',
        ),
      );

      await ServiceBridge.initialize(
        ServiceBridgeConfig(
          // Hata — Firebase + Sentry
          crashReporters: [firebase.crashReporter, SentryCrashReporter()],
          defaultCrashProviders: {SBProvider.firebase.id, SBProvider.sentry.id},

          // Analitik — Firebase + AppsFlyer
          analyticsProviders: [firebase.analyticsProvider, appsFlyerAnalytics],
          defaultAnalyticsProviders: {SBProvider.firebase.id, SBProvider.appsflyer.id},

          // Remote Config — GMS/HMS yönlendirme
          gmsRemoteConfig: firebase.remoteConfigProvider,
          hmsRemoteConfig: HuaweiRemoteConfigProvider(),

          // Push — Firebase
          pushProviders: [firebase.pushProvider],
          defaultPushProviders: {SBProvider.firebase.id},

          // Loglama — Firebase + Sentry
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

## Ek Bilgiler

- **Repository:** [github.com/emresaridogan/service_bridge](https://github.com/emresaridogan/service_bridge)
- **Sorunlar:** [GitHub Issues](https://github.com/emresaridogan/service_bridge/issues)
- **Lisans:** MIT

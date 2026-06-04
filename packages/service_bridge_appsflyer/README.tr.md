# service_bridge_appsflyer

[![Pub Version](https://img.shields.io/pub/v/service_bridge_appsflyer.svg)](https://pub.dev/packages/service_bridge_appsflyer)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/emresaridogan/service_bridge/blob/main/LICENSE)

[Service Bridge](https://pub.dev/packages/service_bridge_core) ekosistemi için AppsFlyer sağlayıcı uygulamaları. AppsFlyer SDK aracılığıyla analitik, deep link yönetimi ve kullanıcı takibi entegrasyonları sağlar.

## Özellikler

- **AppsFlyerAnalyticsProvider** — AppsFlyer ile etkinlik takibi, ekran görüntüleme ve kullanıcı özellikleri
- **AppsFlyerDeepLinkProvider** — AppsFlyer Unified Deep Linking ile deep link alımı
- **AppsFlyerUserTracker** — AppsFlyer ile kullanıcı tanımlama ve etkinlik takibi

## Kurulum

```yaml
dependencies:
  service_bridge_appsflyer: ^1.0.0
```

```bash
dart pub add service_bridge_appsflyer
```

## Platform Kurulumu

1. [appsflyer.com](https://www.appsflyer.com/) adresinden bir AppsFlyer hesabı oluşturun
2. Uygulamanızı kaydedin ve **Dev Key**'inizi alın
3. Platforma özel yapılandırma için [AppsFlyer Flutter SDK kurulum kılavuzunu](https://dev.appsflyer.com/hc/docs/flutter-sdk) takip edin

## Kullanım

### Sağlayıcıları Kurma

```dart
import 'package:service_bridge_appsflyer/service_bridge_appsflyer.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SDK seçenekleriyle AppsFlyer analitik sağlayıcısını oluştur
  final appsFlyerAnalytics = AppsFlyerAnalyticsProvider(
    appsFlyerOptions: AppsFlyerOptions(
      afDevKey: 'DEV_KEY_INIZ',
      appId: 'APP_ID_NIZ',
      showDebug: true,
    ),
  );

  // Deep link ve kullanıcı takibi için SDK instance'ını kullan
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

### Sağlayıcıları Kullanma

```dart
final sb = ServiceBridge.instance;

// Analitik
await sb.analytics.logEvent('satin_alma', parameters: {
  'gelir': 29.99,
  'para_birimi': 'TRY',
  'urun_id': 'sku_001',
});
await sb.analytics.logScreenView('UrunDetay');
await sb.analytics.setUserId('user_123');

// Deep link'ler
final ilkLink = await sb.deepLink.getInitialLink();
sb.deepLink.onDeepLink.listen((uri) {
  print('Deep link alındı: $uri');
});

// Kullanıcı takibi
await sb.userTracking.identifyUser('user_123', attributes: {
  'plan': 'premium',
  'kayit_tarihi': '2024-01-15',
});
await sb.userTracking.trackEvent('teklif_goruntulendi', parameters: {'teklif_id': '99'});
```

## Sağlayıcılar

### AppsFlyerAnalyticsProvider

| Metot | Açıklama |
|---|---|
| `logEvent(name, parameters)` | Uygulama içi etkinlik logla |
| `logScreenView(screenName, screenClass)` | Ekran görüntüleme logla (`screen_view` etkinliği olarak) |
| `setUserId(userId)` | Müşteri kullanıcı ID'si belirle |
| `setUserProperty(name, value)` | Ek veri belirle |
| `resetAnalyticsData()` | AppsFlyer tarafından desteklenmez (işlem yok) |

**Sağlayıcı ID'si:** `appsflyer`

### AppsFlyerDeepLinkProvider

| Metot / Özellik | Açıklama |
|---|---|
| `getInitialLink()` | `null` döner (AppsFlyer ilk linkleri callback ile yönetir) |
| `onDeepLink` | Unified Deep Linking ile alınan deep link URI akışı |
| `createDeepLink(params)` | Giriş linkini döner (OneLink oluşturma dashboard üzerinden yapılır) |

**Sağlayıcı ID'si:** `appsflyer`

### AppsFlyerUserTracker

| Metot | Açıklama |
|---|---|
| `identifyUser(userId, attributes)` | Müşteri kullanıcı ID'si ve ek veri belirle |
| `setUserAttribute(key, value)` | Ek kullanıcı verisi belirle |
| `trackEvent(event, parameters)` | Uygulama içi etkinlik logla |
| `logout()` | AppsFlyer tarafından desteklenmez (işlem yok) |

**Sağlayıcı ID'si:** `appsflyer`

## Ek Bilgiler

- **Repository:** [github.com/emresaridogan/service_bridge](https://github.com/emresaridogan/service_bridge)
- **Sorunlar:** [GitHub Issues](https://github.com/emresaridogan/service_bridge/issues)
- **Lisans:** MIT

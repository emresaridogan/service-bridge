# service_bridge_insider

[![Pub Version](https://img.shields.io/pub/v/service_bridge_insider.svg)](https://pub.dev/packages/service_bridge_insider)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/emresaridogan/service_bridge/blob/main/LICENSE)

> **⚠️ Deneysel:** Bu paket stub uygulamaları içerir. Insider Flutter SDK entegrasyonu henüz tam olarak bağlanmamıştır. Metot gövdeleri, resmi Insider SDK bağımlılığını bekleyen yer tutuculardır.

[Service Bridge](https://pub.dev/packages/service_bridge_core) ekosistemi için Insider sağlayıcı uygulamaları. Insider SDK aracılığıyla analitik, push bildirim ve kullanıcı takibi entegrasyonları sağlar.

## Özellikler

- **InsiderAnalyticsProvider** — Insider ile etkinlik takibi, ekran görüntüleme ve kullanıcı özellikleri
- **InsiderPushProvider** — Insider ile push bildirim yönetimi (konu yerine segment kullanır)
- **InsiderUserTracker** — Insider ile kullanıcı tanımlama, özellikler ve etkinlik takibi

## Kurulum

```yaml
dependencies:
  service_bridge_insider: ^1.0.0
```

```bash
dart pub add service_bridge_insider
```

## Yapılandırma

> **Not:** Insider Flutter SDK'sı genellikle Insider'ın dokümantasyon portalı üzerinden sağlanır. SDK kullanılabilir olduğunda, bu paketin bağımlılıklarına ekleyin.

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

## Kullanım

```dart
final sb = ServiceBridge.instance;

// Analitik
await sb.analytics.logEvent('urun_goruntulendi', parameters: {'urun_id': '123'});
await sb.analytics.logScreenView('UrunDetay');

// Push bildirimleri
sb.pushNotification.onMessageReceived.listen((msg) {
  print('Alındı: ${msg.title}');
});

// Kullanıcı takibi
await sb.userTracking.identifyUser('user_123', attributes: {
  'plan': 'premium',
  'segment': 'yuksek_deger',
});
await sb.userTracking.trackEvent('satin_alma', parameters: {'tutar': 99.99});
await sb.userTracking.logout();
```

## Sağlayıcılar

### InsiderAnalyticsProvider

| Metot | Açıklama |
|---|---|
| `logEvent(name, parameters)` | Uygulama içi etkinlik etiketle *(stub)* |
| `logScreenView(screenName, screenClass)` | Ekran görüntülemeyi etkinlik olarak logla *(stub)* |
| `setUserId(userId)` | Kullanıcı tanımlayıcı belirle *(stub)* |
| `setUserProperty(name, value)` | Özel kullanıcı özelliği belirle *(stub)* |
| `resetAnalyticsData()` | Desteklenmiyor (Insider veri yaşam döngüsünü ayrı yönetir) |

**Sağlayıcı ID'si:** `insider`

### InsiderPushProvider

| Metot / Özellik | Açıklama |
|---|---|
| `getToken()` | Insider tarafından yönetilen push token'ını al *(stub)* |
| `onTokenRefresh` | Token yenilenme akışı |
| `onMessageReceived` | Alınan mesaj akışı |
| `onMessageOpenedApp` | Uygulamayı açan mesaj akışı |
| `subscribeToTopic(topic)` | Insider konu yerine segment kullanır |
| `unsubscribeFromTopic(topic)` | Insider konu yerine segment kullanır |
| `requestPermission()` | Push bildirimlerini etkinleştir *(stub)* |

**Sağlayıcı ID'si:** `insider`

### InsiderUserTracker

| Metot | Açıklama |
|---|---|
| `identifyUser(userId, attributes)` | Kullanıcı tanımlayıcı ve özel özellikler belirle *(stub)* |
| `setUserAttribute(key, value)` | Özel kullanıcı özelliği belirle *(stub)* |
| `trackEvent(event, parameters)` | Etkinlik etiketle *(stub)* |
| `logout()` | Kullanıcı çıkışı *(stub)* |

**Sağlayıcı ID'si:** `insider`

## Ek Bilgiler

- **Repository:** [github.com/emresaridogan/service_bridge](https://github.com/emresaridogan/service_bridge)
- **Sorunlar:** [GitHub Issues](https://github.com/emresaridogan/service_bridge/issues)
- **Lisans:** MIT

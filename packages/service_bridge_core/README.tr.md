# service_bridge_core

[![Pub Version](https://img.shields.io/pub/v/service_bridge_core.svg)](https://pub.dev/packages/service_bridge_core)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/emresaridogan/service_bridge/blob/main/LICENSE)

**Service Bridge** ekosistemi için temel sözleşmeler (contracts), manager'lar, modeller ve yardımcı araçlar — Flutter uygulamaları için modüler, çok sağlayıcılı bir servis yönetim katmanı.

Bu paket, tüm sağlayıcı paketlerinin uyguladığı soyutlamaları tanımlar. Doğrudan bu pakete bağımlılık eklemeniz genellikle yalnızca özel sağlayıcı geliştirirken gereklidir; uygulama kodu tipik olarak belirli bir sağlayıcı paketine (ör. `service_bridge_firebase`) bağımlıdır ve bu paket otomatik olarak bu paketi dışa aktarır.

## Özellikler

- **7 servis sözleşmesi** — `AnalyticsProvider`, `CrashReporter`, `LoggerProvider`, `PushNotificationProvider`, `DeepLinkProvider`, `RemoteConfigProvider`, `UserTracker`
- **7 manager** — Her servis kategorisinde birden fazla sağlayıcıyı paralel yayınla (fan-out) yönetir
- **Sağlayıcı yönlendirme** — Çağrı bazlı `only`/`exclude` filtreleme, başlatılmamış sağlayıcıların otomatik hariç tutulması
- **GMS/HMS tespiti** — Çalışma zamanı platform tespiti ve derleme zamanı geçersiz kılma desteği
- **Hata yöneticisi** — Flutter hatalarını, platform dağıtıcı hatalarını ve zone seviyesi hataları tekrarlama önleme ile yakalar
- **Navigator gözlemcisi** — Analitik için otomatik ekran görüntüleme kaydı
- **Test araçları** — Tüm sözleşmeler için kullanıma hazır mock sağlayıcılar

## Kurulum

```yaml
dependencies:
  service_bridge_core: ^1.0.0
```

```bash
dart pub add service_bridge_core
```

## Sözleşmeler (Contracts)

Tüm sözleşmeler, sağlayıcı yaşam döngüsünü tanımlayan `BaseServiceProvider` sınıfını genişletir:

```dart
abstract class BaseServiceProvider {
  String get providerId;
  bool get isInitialized;
  Future<void> initialize();
  Future<void> dispose();
}
```

| Sözleşme | Amaç | Temel Metotlar |
|---|---|---|
| `AnalyticsProvider` | Etkinlik takibi ve ekran görüntüleme | `logEvent()`, `logScreenView()`, `setUserId()`, `setUserProperty()`, `resetAnalyticsData()` |
| `CrashReporter` | Hata ve çökme raporlama | `reportError()`, `reportMessage()`, `setUserId()`, `setCustomKey()`, `recordBreadcrumb()` |
| `LoggerProvider` | Yapılandırılmış loglama | `log()`, `debug()`, `info()`, `warning()`, `error()` |
| `PushNotificationProvider` | Push bildirim yönetimi | `getToken()`, `onTokenRefresh`, `onMessageReceived`, `onMessageOpenedApp`, `subscribeToTopic()`, `requestPermission()` |
| `DeepLinkProvider` | Deep link yönetimi | `getInitialLink()`, `onDeepLink`, `createDeepLink()` |
| `RemoteConfigProvider` | Uzak yapılandırma | `fetchAndActivate()`, `getString()`, `getBool()`, `getInt()`, `getDouble()`, `getAll()` |
| `UserTracker` | Kullanıcı kimliği ve etkinlik takibi | `identifyUser()`, `setUserAttribute()`, `trackEvent()`, `logout()` |

## Manager'lar

Her manager bir sağlayıcı listesini yönetir. Çoğu, çağrıları tüm aktif sağlayıcılara paralel olarak yayar. `RemoteConfigManager` istisnadır — platforma göre (GMS veya HMS) tek bir sağlayıcıya yönlendirir.

### CrashManager

```dart
// Tüm varsayılan sağlayıcılara raporla
await sb.crash.reportError(error, stackTrace);

// Yalnızca Sentry'ye raporla
await sb.crash.reportError(error, stackTrace, only: {SBProvider.sentry.id});

// Firebase hariç tümüne
await sb.crash.reportError(error, stackTrace, exclude: {SBProvider.firebase.id});

// Breadcrumb ve bağlam bilgisi
await sb.crash.setUserId('user_123');
await sb.crash.setCustomKey('ekran', 'odeme');
await sb.crash.recordBreadcrumb('satın al butonuna tıklandı', category: 'ui');
```

### AnalyticsManager

```dart
await sb.analytics.logEvent('satin_alma', parameters: {'urun_id': 'sku_001'});
await sb.analytics.logScreenView('AnaSayfa');
await sb.analytics.setUserId('user_123');
await sb.analytics.setUserProperty(name: 'plan', value: 'premium');
```

### RemoteConfigManager

Cihaz platformuna göre tek bir sağlayıcıya yönlendirir (GMS → Firebase, HMS → Huawei). Birincil başarısız olursa alternatife geri döner.

```dart
await sb.remoteConfig.fetchAndActivate();
final aktifMi = sb.remoteConfig.getBool('ozellik_bayragi');
final baslik = sb.remoteConfig.getString('banner_baslik');
```

### PushNotificationManager

Birden fazla push sağlayıcısından gelen akışları birleştirir.

```dart
final token = await sb.pushNotification.getToken();
sb.pushNotification.onMessageReceived.listen((msg) => print(msg.title));
await sb.pushNotification.subscribeToTopic('haberler');
await sb.pushNotification.requestPermission();
```

### LogManager

```dart
await sb.log.debug('Önbellek dolduruldu');
await sb.log.info('Kullanıcı giriş yaptı', extras: {'yontem': 'google'});
await sb.log.warning('Yavaş sorgu tespit edildi');
await sb.log.error('API başarısız', error: e, stackTrace: st);
```

### DeepLinkManager

```dart
final ilkLink = await sb.deepLink.getInitialLink();
sb.deepLink.onDeepLink.listen((uri) => yonlendir(uri));
```

### UserTrackingManager

```dart
await sb.userTracking.identifyUser('user_123', attributes: {'plan': 'pro'});
await sb.userTracking.trackEvent('teklif_goruntulendi', parameters: {'id': '99'});
await sb.userTracking.logout();
```

## Sağlayıcı Yönlendirme

Her manager metodu iki isteğe bağlı parametre kabul eder:

| Parametre | Tür | Davranış |
|---|---|---|
| `only` | `Set<String>?` | **Yalnızca** listelenen sağlayıcı ID'lerini çağırır |
| `exclude` | `Set<String>?` | Varsayılanların **hepsini**, listelenenler **hariç** çağırır |
| _(hiçbiri)_ | — | `defaultProviders` içindeki tüm sağlayıcıları çağırır |

`isInitialized == false` olan sağlayıcılar her zaman otomatik olarak hariç tutulur.

## Platform Tespiti

`PlatformDetector`, GMS ve HMS ayrımını şu öncelik sırasına göre belirler:

1. Önceki `detect()` çağrısından gelen önbelleğe alınmış sonuç
2. Derleme zamanında `platformOverride` (`ServiceBridgeConfig` içinde)
3. `device_info_plus` ile çalışma zamanı tespiti (`brand`/`manufacturer` alanlarında `huawei`/`honor` aranır)
4. Android dışı tüm platformlarda ve tespit hatalarında `PlatformType.gms` döner

```dart
ServiceBridgeConfig(
  platformOverride: PlatformType.hms, // CI veya flavored derlemelerde HMS zorla
)
```

## Hata Yönetimi

`ServiceBridgeErrorHandler` kapsamlı hata yakalama kurar:

```dart
ServiceBridgeErrorHandler.runGuarded(() {
  runApp(const MyApp());
});
```

Yakalanan hatalar:
- `FlutterError.onError` (framework hataları)
- `PlatformDispatcher.instance.onError` (platform hataları)
- Zone seviyesi yakalanmamış hatalar
- Otomatik tekrarlama önleme (aynı hata 500ms içinde yalnızca bir kez raporlanır)

## Navigator Gözlemcisi

Analitik sağlayıcılarınıza otomatik ekran görüntüleme kaydı yapar:

```dart
MaterialApp(
  navigatorObservers: [
    ServiceBridgeNavigatorObserver(
      analyticsManager: ServiceBridge.instance.analytics,
      nameExtractor: (settings) => settings.name, // rota adı çıkarımını özelleştirin
      routeFilter: (route) => route is PageRoute,  // hangi rotaların izleneceğini filtreleyin
    ),
  ],
)
```

## Test

`testing.dart` kütüphanesi tüm sözleşmeler için mock uygulamaları sağlar:

```dart
import 'package:service_bridge_core/testing.dart';

// Kullanılabilir mock'lar:
// MockCrashReporter    — raporları ve breadcrumb'ları takip eder
// MockAnalyticsProvider — etkinlikleri ve ekran görüntülemelerini takip eder
// MockRemoteConfigProvider — yapılandırılabilir değerler haritası
// MockLoggerProvider   — log kayıtlarını takip eder
// MockPushNotificationProvider — kontrol edilebilir akışlar
// MockDeepLinkProvider — kontrol edilebilir akışlar
// MockUserTracker      — etkinlikleri ve userId'yi takip eder

void main() {
  test('satın alma etkinliğini loglar', () async {
    final analytics = MockAnalyticsProvider();
    await analytics.initialize();

    await analytics.logEvent('satin_alma', parameters: {'urun': 'sku_001'});

    expect(analytics.events, hasLength(1));
    expect(analytics.events.first.name, 'satin_alma');
  });
}
```

## Modeller

| Model | Alanlar |
|---|---|
| `NotificationMessage` | `title`, `body`, `data`, `imageUrl`, `messageId` |
| `DeepLinkParams` | `link`, `domainUriPrefix`, `title`, `description`, `imageUrl`, `customParameters` |

## Enum'lar

| Enum | Değerler |
|---|---|
| `SeverityLevel` | `debug`, `info`, `warning`, `error`, `fatal` |
| `LogLevel` | `verbose`, `debug`, `info`, `warning`, `error`, `fatal` |
| `PlatformType` | `gms`, `hms` |
| `SBProvider` | `firebase`, `firebaseLogger`, `sentry`, `sentryLogger`, `appsflyer`, `insider`, `huawei` |

## Özel Sağlayıcı Yazma

1. İlgili sözleşmeyi uygulayın
2. Benzersiz bir `providerId` belirleyin
3. SDK yaşam döngüsünü `initialize()` ve `dispose()` içinde yönetin

```dart
class OzelAnalitiSaglayici implements AnalyticsProvider {
  @override
  String get providerId => 'ozel_analitik';

  bool _baslatildi = false;

  @override
  bool get isInitialized => _baslatildi;

  @override
  Future<void> initialize() async {
    // SDK'nızı başlatın
    _baslatildi = true;
  }

  @override
  Future<void> dispose() async {
    _baslatildi = false;
  }

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    // SDK'nıza iletin
  }

  // ... diğer metotları uygulayın
}
```

## Ek Bilgiler

- **Repository:** [github.com/emresaridogan/service_bridge](https://github.com/emresaridogan/service_bridge)
- **Sorunlar:** [GitHub Issues](https://github.com/emresaridogan/service_bridge/issues)
- **Lisans:** MIT

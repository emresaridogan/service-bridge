# Service Bridge

[![Pub Version](https://img.shields.io/pub/v/service_bridge_core.svg)](https://pub.dev/packages/service_bridge_core)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Flutter uygulamaları için modüler, çok sağlayıcılı bir servis yönetim katmanı. Firebase, Sentry, AppsFlyer, Insider ve Huawei HMS gibi üçüncü taraf SDK'ları birleşik sözleşmeler (contract) aracılığıyla yönetir; böylece uygulama kodunu değiştirmeden sağlayıcıları değiştirebilir ya da birleştirebilirsiniz.

> **For English documentation:** [README.md](README.md)

---

## İçindekiler

- [Genel Bakış](#genel-bakış)
- [Paketler](#paketler)
- [Mimari](#mimari)
- [Başlarken](#başlarken)
- [Yapılandırma](#yapılandırma)
- [Manager'lar](#managerlar)
  - [CrashManager](#crashmanager)
  - [AnalyticsManager](#analyticsmanager)
  - [RemoteConfigManager](#remoteconfigmanager)
  - [PushNotificationManager](#pushnotificationmanager)
  - [LogManager](#logmanager)
  - [DeepLinkManager](#deeplinkmanager)
  - [UserTrackingManager](#usertrackingmanager)
- [Sağlayıcı Yönlendirme](#sağlayıcı-yönlendirme)
- [GMS / HMS Tespiti](#gms--hms-tespiti)
- [Özel Sağlayıcı Yazma](#özel-sağlayıcı-yazma)
- [Monorepo Kurulumu](#monorepo-kurulumu)
- [Testleri Çalıştırma](#testleri-çalıştırma)

---

## Genel Bakış

`service_bridge`, Flutter uygulamanız ile üçüncü taraf servis bağımlılıkları arasına ince bir soyutlama katmanı ekler. Her servis kategorisi (hata raporlama, analitik, push bildirimleri vb.) bir **sözleşme** (abstract class) ile temsil edilir. Somut uygulamalar ayrı paketlerde yer alır; bu sayede yalnızca projenizin gerçekten kullandığı SDK'ları dahil edersiniz.

Temel özellikler:

- **Çok sağlayıcıya yayın** — çoğu manager, çağrıları tüm aktif sağlayıcılara paralel olarak iletir.
- **Çağrı bazlı hedefleme** — her manager metodu, bireysel çağrıların belirli sağlayıcılarla sınırlandırılması için `only` (beyaz liste) ve `exclude` (kara liste) parametrelerini kabul eder.
- **Otomatik GMS/HMS yönlendirme** — `RemoteConfigManager`, çalışma zamanında cihaz platformunu tespit eder ve doğru sağlayıcıya yönlendirir (GMS cihazları için Firebase, HMS cihazları için Huawei).
- **Merkezi yaşam döngüsü** — tüm sağlayıcılar `ServiceManager.initialize()` sırasında bir kez başlatılır ve yaşam döngüleri merkezi olarak yönetilir.

---

## Paketler

| Paket | pub.dev | Açıklama |
|---|---|---|
| [`service_bridge_core`](packages/service_bridge_core) | [![Pub](https://img.shields.io/pub/v/service_bridge_core.svg)](https://pub.dev/packages/service_bridge_core) | Temel sözleşmeler, manager'lar, modeller ve platform tespiti |
| [`service_bridge_firebase`](packages/service_bridge_firebase) | [![Pub](https://img.shields.io/pub/v/service_bridge_firebase.svg)](https://pub.dev/packages/service_bridge_firebase) | Firebase (Analytics, Crashlytics, Remote Config, Cloud Messaging, Loglama) |
| [`service_bridge_appsflyer`](packages/service_bridge_appsflyer) | [![Pub](https://img.shields.io/pub/v/service_bridge_appsflyer.svg)](https://pub.dev/packages/service_bridge_appsflyer) | AppsFlyer (Analytics, Deep Link, Kullanıcı Takibi) |
| [`service_bridge_sentry`](packages/service_bridge_sentry) | [![Pub](https://img.shields.io/pub/v/service_bridge_sentry.svg)](https://pub.dev/packages/service_bridge_sentry) | Sentry (Hata Raporlama, Loglama) |
| [`service_bridge_insider`](packages/service_bridge_insider) | [![Pub](https://img.shields.io/pub/v/service_bridge_insider.svg)](https://pub.dev/packages/service_bridge_insider) | Insider (Analytics, Push Bildirimleri, Kullanıcı Takibi) |
| [`service_bridge_huawei`](packages/service_bridge_huawei) | [![Pub](https://img.shields.io/pub/v/service_bridge_huawei.svg)](https://pub.dev/packages/service_bridge_huawei) | Huawei HMS (Push Bildirimleri, Remote Config) |

---

## Mimari

```
ServiceManager  (singleton)
│
├── CrashManager            ─► CrashReporter[]              (Firebase, Sentry, …)
├── AnalyticsManager        ─► AnalyticsProvider[]          (Firebase, AppsFlyer, Insider, …)
├── RemoteConfigManager     ─► RemoteConfigProvider         (GMS → Firebase | HMS → Huawei)
├── PushNotificationManager ─► PushNotificationProvider[]  (Firebase, Huawei, Insider, …)
├── LogManager              ─► LoggerProvider[]             (Firebase, Sentry, …)
├── DeepLinkManager         ─► DeepLinkProvider[]          (AppsFlyer, Firebase, …)
├── UserTrackingManager     ─► UserTracker[]               (Insider, AppsFlyer, …)
└── PlatformDetector                                        (GMS ve HMS ayrımı)
```

Her manager bir sağlayıcı listesi tutar ve herhangi bir çağrıyı iletmeden önce `ProviderResolver` aracılığıyla başlatılma durumuna, `only`/`exclude`/`defaultProviders` kurallarına göre filtreleme yapar.

---

## Başlarken

### 1. Bağımlılıkları ekle

Uygulamanızın `pubspec.yaml` dosyasına temel paketi ve ihtiyaç duyduğunuz entegrasyon paketlerini ekleyin:

```yaml
dependencies:
  service_bridge_core: ^1.0.0

  # Yalnızca kullandığınız entegrasyonları ekleyin
  service_bridge_firebase: ^1.0.0
  service_bridge_sentry: ^1.0.0
  service_bridge_appsflyer: ^1.0.0
```

### 2. Uygulama başlangıcında başlat

`runApp()` öncesinde (ya da `WidgetsFlutterBinding.ensureInitialized()` çağrısından sonra `main()` içinde) `ServiceManager.initialize()` çağırın:

```dart
import 'package:service_bridge/service_bridge.dart';
import 'package:service_bridge_firebase/service_bridge_firebase.dart';
import 'package:service_bridge_sentry/service_bridge_sentry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ServiceManager.initialize(
    ServiceManagerConfig(
      // Hata raporlama
      crashReporters: [
        FirebaseCrashReporter(),
        SentryCrashReporter(dsn: 'https://your-dsn@sentry.io/project'),
      ],
      defaultCrashProviders: {'firebase', 'sentry'},

      // Analitik
      analyticsProviders: [
        FirebaseAnalyticsProvider(),
        AppsFlyerAnalyticsProvider(devKey: 'YOUR_KEY'),
      ],
      defaultAnalyticsProviders: {'firebase', 'appsflyer'},

      // Remote Config (GMS/HMS yönlendirme)
      gmsRemoteConfig: FirebaseRemoteConfigProvider(),
      hmsRemoteConfig: HuaweiRemoteConfigProvider(),

      // Push bildirimleri
      pushProviders: [FirebasePushProvider()],
      defaultPushProviders: {'firebase'},

      // Loglama
      loggerProviders: [FirebaseLoggerProvider(), SentryLoggerProvider()],
      defaultLogProviders: {'firebase'},
    ),
  );

  runApp(const MyApp());
}
```

### 3. Uygulama genelinde kullan

```dart
final sm = ServiceManager.instance;

// Hata raporlama
await sm.crash.reportError(error, stackTrace);

// Analitik etkinliği
await sm.analytics.logEvent('purchase', parameters: {'item_id': 'sku_001'});

// Ekran görünümü kaydı
await sm.analytics.logScreenView('HomeScreen');

// Remote Config
await sm.remoteConfig.fetchAndActivate();
final ozellikAktif = await sm.remoteConfig.getBool('new_feature');

// Push bildirimleri
final token = await sm.pushNotification.getToken();
sm.pushNotification.onMessageReceived.listen((msg) { /* … */ });

// Loglama
await sm.log.warning('Önbellek isabetsizliği', extras: {'key': 'user_profile'});

// Deep Link
final ilkLink = await sm.deepLink.getInitialLink();
sm.deepLink.onDeepLink.listen((uri) { /* … */ });

// Kullanıcı takibi
await sm.userTracking.identifyUser('user_123', attributes: {'plan': 'premium'});
```

---

## Yapılandırma

`ServiceManagerConfig` aşağıdaki parametreleri kabul eder:

| Parametre | Tür | Açıklama |
|---|---|---|
| `crashReporters` | `List<CrashReporter>` | Tüm hata raporlama sağlayıcıları |
| `defaultCrashProviders` | `Set<String>` | Varsayılan olarak aktif sağlayıcı ID'leri |
| `analyticsProviders` | `List<AnalyticsProvider>` | Tüm analitik sağlayıcıları |
| `defaultAnalyticsProviders` | `Set<String>` | Varsayılan olarak aktif sağlayıcı ID'leri |
| `gmsRemoteConfig` | `RemoteConfigProvider?` | GMS (Google) cihazlar için Remote Config |
| `hmsRemoteConfig` | `RemoteConfigProvider?` | HMS (Huawei) cihazlar için Remote Config |
| `pushProviders` | `List<PushNotificationProvider>` | Tüm push bildirim sağlayıcıları |
| `defaultPushProviders` | `Set<String>` | Varsayılan olarak aktif sağlayıcı ID'leri |
| `loggerProviders` | `List<LoggerProvider>` | Tüm loglama sağlayıcıları |
| `defaultLogProviders` | `Set<String>` | Varsayılan olarak aktif sağlayıcı ID'leri |
| `deepLinkProviders` | `List<DeepLinkProvider>` | Tüm deep link sağlayıcıları |
| `defaultDeepLinkProviders` | `Set<String>` | Varsayılan olarak aktif sağlayıcı ID'leri |
| `userTrackers` | `List<UserTracker>` | Tüm kullanıcı takip sağlayıcıları |
| `defaultUserTrackingProviders` | `Set<String>` | Varsayılan olarak aktif sağlayıcı ID'leri |
| `platformOverride` | `PlatformType?` | Çalışma zamanı tespiti yerine `gms` veya `hms` zorla |

---

## Manager'lar

### CrashManager

Hata raporlarını ve mesajlarını tüm aktif sağlayıcılara yayar.

```dart
// Varsayılan tüm sağlayıcılara raporla
await sm.crash.reportError(error, stackTrace);

// Yalnızca Sentry'ye raporla
await sm.crash.reportError(error, stackTrace, only: {'sentry'});

// Firebase hariç tümüne raporla
await sm.crash.reportError(error, stackTrace, exclude: {'firebase'});

// Kritik olmayan mesaj
await sm.crash.reportMessage('Ödeme başarısız', level: SeverityLevel.warning);

// Bağlam bilgisi ekle
await sm.crash.setUserId('user_123');
await sm.crash.setCustomKey('ekran', 'odeme');
await sm.crash.recordBreadcrumb('ödeme butonuna tıklandı', category: 'ui');
```

### AnalyticsManager

Analitik etkinliklerini tüm aktif sağlayıcılara dağıtır.

```dart
await sm.analytics.logEvent('sepete_ekle', parameters: {'urun': 'sku_001'});
await sm.analytics.logScreenView('UrunDetay', screenClass: 'UrunDetayPage');
await sm.analytics.setUserId('user_123');
await sm.analytics.setUserProperty(name: 'abonelik', value: 'premium');
await sm.analytics.resetAnalyticsData();
```

### RemoteConfigManager

Cihaz platformuna göre (GMS veya HMS) tek bir sağlayıcıya yönlendirir. Birincil sağlayıcı başarısız olursa diğerine geri döner.

```dart
await sm.remoteConfig.fetchAndActivate();

final baslik       = await sm.remoteConfig.getString('ana_sayfa_banner_baslik');
final aktifMi      = await sm.remoteConfig.getBool('karanlik_mod_aktif');
final maxDeneme    = await sm.remoteConfig.getInt('max_deneme_sayisi');
final esikDeger    = await sm.remoteConfig.getDouble('puan_esik_degeri');
```

### PushNotificationManager

Token ve mesaj akışlarını birden fazla push sağlayıcısında yönetir.

```dart
final token = await sm.pushNotification.getToken();

sm.pushNotification.onMessageReceived.listen((msg) {
  print('Ön plan mesajı: ${msg.title}');
});

sm.pushNotification.onMessageOpenedApp.listen((msg) {
  // Mesaj içeriğine göre yönlendirme yap
});

await sm.pushNotification.subscribeToTopic('kampanyalar');
final izinVerildi = await sm.pushNotification.requestPermission();
```

### LogManager

Yapılandırılmış log kayıtlarını tüm aktif loglama sağlayıcılarına iletir.

```dart
await sm.log.debug('Önbellek dolduruldu');
await sm.log.info('Kullanıcı giriş yaptı', extras: {'userId': 'user_123'});
await sm.log.warning('Düşük bellek uyarısı');
await sm.log.error('İstek başarısız', error: e, stackTrace: st);
```

Log seviyeleri (`LogLevel` enum'undan): `verbose`, `debug`, `info`, `warning`, `error`, `fatal`.

### DeepLinkManager

Deep link akışlarını birleştirir ve belirli bir sağlayıcıya link oluşturmayı devreder.

```dart
// Soğuk başlatma linki
final uri = await sm.deepLink.getInitialLink();

// Canlı akış (tüm aktif sağlayıcılardan birleştirilmiş)
sm.deepLink.onDeepLink.listen((uri) { /* işle */ });

// Belirli bir sağlayıcı ile link oluştur
final link = await sm.deepLink.createDeepLink(
  DeepLinkParams(path: '/urun/42'),
  providerId: 'appsflyer',
);
```

### UserTrackingManager

Kullanıcı kimliğini ve etkinliklerini tüm aktif takip sağlayıcılarına yayar.

```dart
await sm.userTracking.identifyUser('user_123', attributes: {'plan': 'pro'});
await sm.userTracking.setUserAttribute('son_gorulen', DateTime.now().toIso8601String());
await sm.userTracking.trackEvent('teklif_goruntulendi', parameters: {'teklif_id': '99'});
await sm.userTracking.logout();
```

---

## Sağlayıcı Yönlendirme

Her manager metodu, hangi sağlayıcıların çağrıyı alacağını kontrol eden iki isteğe bağlı parametre kabul eder:

| Parametre | Tür | Davranış |
|---|---|---|
| `only` | `Set<String>?` | **Yalnızca** listelenen sağlayıcı ID'lerini çağırır, varsayılanları yok sayar |
| `exclude` | `Set<String>?` | Varsayılan sağlayıcıların **hepsini** listede olanlar **dışında** çağırır |
| _(hiçbiri)_ | — | `defaultProviders` içindeki tüm sağlayıcıları çağırır |

Başarılı şekilde başlatılmamış sağlayıcılar (`isInitialized == false`) her zaman dışarıda bırakılır.

```dart
// Yalnızca Firebase
await sm.analytics.logEvent('debug_etkinligi', only: {'firebase'});

// Insider hariç tüm varsayılanlar
await sm.analytics.logEvent('satin_alma', exclude: {'insider'});
```

---

## GMS / HMS Tespiti

`PlatformDetector`, cihazın **Google Mobile Services (GMS)** mi yoksa **Huawei Mobile Services (HMS)** mi kullandığını aşağıdaki öncelik sırasına göre belirler:

1. Önceki `detect()` çağrısından gelen önbelleğe alınmış sonuç.
2. Derleme zamanında ayarlanan `platformOverride` (`ServiceManagerConfig` içinde).
3. `device_info_plus` ile çalışma zamanı tespiti — `brand` ve `manufacturer` alanlarında `huawei`/`honor` aranır.
4. Android dışı tüm platformlarda ve tespit hatalarında `PlatformType.gms` döner.

CI ortamında veya flavorlı derlemelerde platformu zorlamak için:

```dart
ServiceManagerConfig(
  platformOverride: PlatformType.hms,
  // …
)
```

---

## Özel Sağlayıcı Yazma

1. `service_bridge` paketinden ilgili sözleşmeyi uygulayın.
2. Benzersiz bir `providerId` string değeri belirleyin.
3. SDK yaşam döngüsünü `initialize()` ve `dispose()` içinde yönetin.

```dart
class OzelAnalitiSaglayici extends AnalyticsProvider {
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

  // … diğer soyut metotları uygulayın
}
```

Ardından yapılandırmaya kaydedin:

```dart
ServiceManagerConfig(
  analyticsProviders: [OzelAnalitiSaglayici()],
  defaultAnalyticsProviders: {'ozel_analitik'},
)
```

---

## Monorepo Kurulumu

Çalışma alanı [Melos](https://melos.invertase.io/) ile yönetilmekte, Flutter sürümü ise [FVM](https://fvm.app/) ile belirlenmektedir.

```bash
# Melos'u yükle
dart pub global activate melos

# Tüm paketleri bootstrap et (pubspec override'larıyla bağımlılıkları çöz)
melos bootstrap

# Tüm paketlerde statik analiz çalıştır
melos analyze

# Tüm testleri çalıştır
melos test

# Kod formatını kontrol et
melos format
```

Aktif Flutter SDK sürümü FVM tarafından yönetilir ve `.fvm/flutter_sdk` konumunda saklanır.

---

## Testleri Çalıştırma

```bash
# Yalnızca temel paket testleri
cd packages/service_bridge
dart test

# Melos aracılığıyla tüm paket testleri
melos test
```

## Katkıda Bulunma

Katkılarınızı bekliyoruz! Pakete özel detaylar için ilgili paketin README dosyasına bakınız.

1. Repoyu fork edin
2. Feature branch oluşturun (`git checkout -b feature/harika-ozellik`)
3. Testleri (`melos test`) ve analizi (`melos analyze`) çalıştırın
4. Değişikliklerinizi commit edin (`git commit -m 'Harika özellik ekle'`)
5. Branch'i push edin (`git push origin feature/harika-ozellik`)
6. Pull Request açın

## Lisans

Bu proje MIT Lisansı altında lisanslanmıştır — detaylar için [LICENSE](LICENSE) dosyasına bakınız.

---

*Hazırlayan: Emre Sarıdoğan*

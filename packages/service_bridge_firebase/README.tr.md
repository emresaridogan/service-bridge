# service_bridge_firebase

[![Pub Version](https://img.shields.io/pub/v/service_bridge_firebase.svg)](https://pub.dev/packages/service_bridge_firebase)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/emresaridogan/service_bridge/blob/main/LICENSE)

[Service Bridge](https://pub.dev/packages/service_bridge_core) ekosistemi için Firebase sağlayıcı uygulamaları. Firebase Analytics, Crashlytics, Remote Config, Cloud Messaging ve Crashlytics üzerinden loglama için kullanıma hazır entegrasyonlar sağlar.

## Özellikler

- **FirebaseAnalyticsProvider** — Firebase Analytics ile etkinlik takibi, ekran görüntüleme, kullanıcı özellikleri
- **FirebaseCrashReporter** — Firebase Crashlytics ile hata raporlama, özel anahtarlar, breadcrumb'lar
- **FirebaseRemoteConfigProvider** — Yapılandırılabilir getirme aralıkları ve varsayılan değerlerle uzak yapılandırma
- **FirebasePushProvider** — Firebase Cloud Messaging ile token yönetimi, konu abonelikleri ve izin yönetimi
- **FirebaseLoggerProvider** — Crashlytics loglarına yazan yapılandırılmış loglama
- **FirebaseProviderBundle** — Firebase Core'u başlatan ve tüm Firebase sağlayıcılarını tek çağrıda oluşturan kolaylık sınıfı

## Kurulum

```yaml
dependencies:
  service_bridge_firebase: ^1.0.0
```

```bash
dart pub add service_bridge_firebase
```

## Platform Kurulumu

Bu paketi kullanmadan önce Flutter projeniz için standart Firebase kurulumunu tamamlayın:

1. [console.firebase.google.com](https://console.firebase.google.com) adresinden bir Firebase projesi oluşturun
2. [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) kurun ve `flutterfire configure` komutunu çalıştırın
3. Oluşturulan `firebase_options.dart` dosyasını projenize ekleyin

Detaylı talimatlar için [resmi FlutterFire dokümantasyonuna](https://firebase.flutter.dev/docs/overview) bakınız.

## Kullanım

### FirebaseProviderBundle ile Hızlı Kurulum

Başlamanın en kolay yolu, Firebase Core'u başlatan ve tüm sağlayıcıları oluşturan `FirebaseProviderBundle` kullanmaktır:

```dart
import 'package:service_bridge_firebase/service_bridge_firebase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat ve tüm sağlayıcıları tek çağrıda oluştur
  final firebase = await FirebaseProviderBundle.initialize(
    options: DefaultFirebaseOptions.currentPlatform,
    remoteConfigDefaults: {'ozellik_bayragi': false, 'banner_metni': 'Hoşgeldiniz'},
    remoteConfigMinimumFetchInterval: const Duration(minutes: 5),
  );

  // Sağlayıcıları ServiceBridge yapılandırmasında kullan
  await ServiceBridge.initialize(
    ServiceBridgeConfig(
      crashReporters: [firebase.crashReporter],
      defaultCrashProviders: {SBProvider.firebase.id},

      analyticsProviders: [firebase.analyticsProvider],
      defaultAnalyticsProviders: {SBProvider.firebase.id},

      gmsRemoteConfig: firebase.remoteConfigProvider,

      pushProviders: [firebase.pushProvider],
      defaultPushProviders: {SBProvider.firebase.id},

      loggerProviders: [firebase.loggerProvider],
      defaultLogProviders: {SBProvider.firebaseLogger.id},
    ),
  );

  runApp(const MyApp());
}
```

### Bireysel Sağlayıcı Kurulumu

Daha fazla kontrol için sağlayıcıları ayrı ayrı da oluşturabilirsiniz:

```dart
// Analitik
final analytics = FirebaseAnalyticsProvider();

// Hata raporlama
final crashReporter = FirebaseCrashReporter();

// Özel ayarlarla Remote Config
final remoteConfig = FirebaseRemoteConfigProvider(
  defaults: {'ozellik_x': true, 'max_deneme': 3},
  fetchTimeout: const Duration(seconds: 15),
  minimumFetchInterval: const Duration(hours: 1),
);

// Push bildirimleri
final push = FirebasePushProvider();

// Logger (Crashlytics loglarına yazar)
final logger = FirebaseLoggerProvider();
```

### Sağlayıcıları Kullanma

`ServiceBridge` aracılığıyla başlatıldıktan sonra manager API'si ile kullanın:

```dart
final sb = ServiceBridge.instance;

// Analitik
await sb.analytics.logEvent('satin_alma', parameters: {'urun_id': 'sku_001'});
await sb.analytics.logScreenView('UrunDetay');

// Hata raporlama
await sb.crash.reportError(error, stackTrace);
await sb.crash.setCustomKey('kullanici_tipi', 'premium');
await sb.crash.recordBreadcrumb('Sepete ürün eklendi', category: 'ticaret');

// Remote Config
await sb.remoteConfig.fetchAndActivate();
final aktifMi = sb.remoteConfig.getBool('ozellik_bayragi');
final metin = sb.remoteConfig.getString('banner_metni');

// Push bildirimleri
final token = await sb.pushNotification.getToken();
await sb.pushNotification.subscribeToTopic('kampanyalar');
final izinVerildi = await sb.pushNotification.requestPermission();

sb.pushNotification.onMessageReceived.listen((msg) {
  print('Alındı: ${msg.title} — ${msg.body}');
});

// Loglama (Crashlytics üzerinden)
await sb.log.info('Kullanıcı giriş yaptı');
await sb.log.error('Ödeme başarısız', error: e, stackTrace: st);
```

## Sağlayıcılar

### FirebaseAnalyticsProvider

| Metot | Açıklama |
|---|---|
| `logEvent(name, parameters)` | Özel analitik etkinliği logla |
| `logScreenView(screenName, screenClass)` | Ekran görüntüleme logla |
| `setUserId(userId)` | Analitik için kullanıcı ID'si belirle |
| `setUserProperty(name, value)` | Kullanıcı özelliği belirle |
| `resetAnalyticsData()` | Tüm analitik verilerini sıfırla |

**Sağlayıcı ID'si:** `firebase`

### FirebaseCrashReporter

| Metot | Açıklama |
|---|---|
| `reportError(error, stackTrace, extras, level)` | Hata raporla (`level == SeverityLevel.fatal` ise ölümcül) |
| `reportMessage(message, level, extras)` | Crashlytics'e mesaj logla |
| `setUserId(userId)` | Kullanıcı tanımlayıcı belirle |
| `setCustomKey(key, value)` | Özel anahtar-değer çifti belirle |
| `recordBreadcrumb(message, category, data)` | Breadcrumb logu kaydet |

**Sağlayıcı ID'si:** `firebase`

### FirebaseRemoteConfigProvider

| Metot | Açıklama |
|---|---|
| `fetchAndActivate()` | Remote config değerlerini getir ve etkinleştir |
| `getString(key, defaultValue)` | String değer al |
| `getBool(key, defaultValue)` | Boolean değer al |
| `getInt(key, defaultValue)` | Integer değer al |
| `getDouble(key, defaultValue)` | Double değer al |
| `getAll()` | Tüm config değerlerini map olarak al |
| `setMinimumFetchInterval(interval)` | Minimum getirme aralığını güncelle |

**Sağlayıcı ID'si:** `firebase`

### FirebasePushProvider

| Metot / Özellik | Açıklama |
|---|---|
| `getToken()` | Mevcut FCM token'ını al |
| `onTokenRefresh` | Token yenilenme akışı |
| `onMessageReceived` | Ön plan mesaj akışı |
| `onMessageOpenedApp` | Uygulamayı açan mesaj akışı |
| `subscribeToTopic(topic)` | Konuya abone ol |
| `unsubscribeFromTopic(topic)` | Konu aboneliğini iptal et |
| `requestPermission()` | Bildirim izni iste |

**Sağlayıcı ID'si:** `firebase`

### FirebaseLoggerProvider

| Metot | Açıklama |
|---|---|
| `log(level, message, extras, error, stackTrace)` | Belirli bir seviyeyle logla |
| `debug(message, extras)` | Debug mesajı logla |
| `info(message, extras)` | Bilgi mesajı logla |
| `warning(message, extras)` | Uyarı mesajı logla |
| `error(message, error, stackTrace, extras)` | Hata logla (error + stackTrace varsa Crashlytics'e kaydedilir) |

**Sağlayıcı ID'si:** `firebase_logger`

### FirebaseProviderBundle

Tüm Firebase sağlayıcılarını tek seferde başlatma kolaylık sınıfı:

```dart
final bundle = await FirebaseProviderBundle.initialize(
  options: DefaultFirebaseOptions.currentPlatform,
  remoteConfigDefaults: {'anahtar': 'deger'},
  remoteConfigFetchTimeout: const Duration(seconds: 10),
  remoteConfigMinimumFetchInterval: const Duration(seconds: 10),
);

// Bireysel sağlayıcılara erişim:
bundle.crashReporter;
bundle.analyticsProvider;
bundle.remoteConfigProvider;
bundle.pushProvider;
bundle.loggerProvider;
```

## Bağımlılıklar

Bu paket aşağıdaki Firebase paketlerine bağımlıdır:

| Paket | Versiyon |
|---|---|
| `firebase_core` | 4.9.0 |
| `firebase_analytics` | 12.4.1 |
| `firebase_crashlytics` | 5.2.2 |
| `firebase_messaging` | 16.2.2 |
| `firebase_remote_config` | 6.5.1 |

## Ek Bilgiler

- **Repository:** [github.com/emresaridogan/service_bridge](https://github.com/emresaridogan/service_bridge)
- **Sorunlar:** [GitHub Issues](https://github.com/emresaridogan/service_bridge/issues)
- **Lisans:** MIT

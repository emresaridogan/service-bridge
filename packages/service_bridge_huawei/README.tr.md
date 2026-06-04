# service_bridge_huawei

[![Pub Version](https://img.shields.io/pub/v/service_bridge_huawei.svg)](https://pub.dev/packages/service_bridge_huawei)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/emresaridogan/service_bridge/blob/main/LICENSE)

> **⚠️ Deneysel:** Bu paket stub uygulamaları içerir. Huawei HMS SDK bağımlılıkları yorum satırına alınmıştır. Metot gövdeleri, HMS SDK entegrasyonunu bekleyen yer tutuculardır.

[Service Bridge](https://pub.dev/packages/service_bridge_core) ekosistemi için Huawei HMS sağlayıcı uygulamaları. Huawei Mobile Services (HMS) cihazları için push bildirim ve uzak yapılandırma entegrasyonları sağlar.

## Özellikler

- **HuaweiPushProvider** — Huawei Push Kit ile push bildirim yönetimi (token yönetimi, mesaj akışları)
- **HuaweiRemoteConfigProvider** — Huawei AGConnect Remote Config ile uzak yapılandırma

## Kurulum

```yaml
dependencies:
  service_bridge_huawei: ^1.0.0
```

```bash
dart pub add service_bridge_huawei
```

## Platform Kurulumu

> **Not:** HMS SDK paketleri (`huawei_push`, `huawei_agconnect_remote_config`) şu anda bu paketin bağımlılıklarında yorum satırına alınmıştır. HMS ile entegrasyon yaparken etkinleştirin.

1. [developer.huawei.com](https://developer.huawei.com) adresinden bir Huawei geliştirici hesabı oluşturun
2. Uygulamanızı AppGallery Connect'te kaydedin
3. `agconnect-services.json` dosyasını indirin ve Android projenize ekleyin
4. [HMS Flutter eklenti kurulum kılavuzunu](https://developer.huawei.com/consumer/en/doc/HMS-Plugin-Guides/prepareenv-0000001050155774-V1) takip edin

## Kullanım

### ServiceBridge ile Kurulum

```dart
import 'package:service_bridge_huawei/service_bridge_huawei.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ServiceBridge.initialize(
    ServiceBridgeConfig(
      // HMS cihazlarda Huawei Remote Config kullanılır
      hmsRemoteConfig: HuaweiRemoteConfigProvider(
        defaults: {'ozellik_bayragi': false, 'banner_metni': 'Hoşgeldiniz'},
      ),

      pushProviders: [HuaweiPushProvider()],
      defaultPushProviders: {SBProvider.huawei.id},
    ),
  );

  runApp(const MyApp());
}
```

### GMS/HMS Otomatik Yönlendirme

`service_bridge_firebase` ile birlikte kullanıldığında, `RemoteConfigManager` otomatik olarak doğru sağlayıcıya yönlendirir:

```dart
await ServiceBridge.initialize(
  ServiceBridgeConfig(
    gmsRemoteConfig: FirebaseRemoteConfigProvider(), // GMS cihazlar
    hmsRemoteConfig: HuaweiRemoteConfigProvider(),   // HMS cihazlar
  ),
);

// Bu otomatik olarak cihaza göre doğru sağlayıcıyı kullanır
await sb.remoteConfig.fetchAndActivate();
final deger = sb.remoteConfig.getString('anahtar');
```

### Sağlayıcıları Kullanma

```dart
final sb = ServiceBridge.instance;

// Remote config (HMS cihazlarda otomatik yönlendirilir)
await sb.remoteConfig.fetchAndActivate();
final aktifMi = sb.remoteConfig.getBool('ozellik_bayragi');
final metin = sb.remoteConfig.getString('banner_metni');

// Push bildirimleri
final token = await sb.pushNotification.getToken();
sb.pushNotification.onMessageReceived.listen((msg) {
  print('Alındı: ${msg.title}');
});
await sb.pushNotification.subscribeToTopic('haberler');
```

## Sağlayıcılar

### HuaweiPushProvider

| Metot / Özellik | Açıklama |
|---|---|
| `getToken()` | Huawei Push Kit token'ını al *(stub)* |
| `onTokenRefresh` | Token yenilenme akışı |
| `onMessageReceived` | Alınan mesaj akışı |
| `onMessageOpenedApp` | Uygulamayı açan mesaj akışı |
| `subscribeToTopic(topic)` | Konuya abone ol *(stub)* |
| `unsubscribeFromTopic(topic)` | Konu aboneliğini iptal et *(stub)* |
| `requestPermission()` | `true` döner (HMS Push Kit çoğu cihazda çalışma zamanı izni gerektirmez) |

**Sağlayıcı ID'si:** `huawei`

### HuaweiRemoteConfigProvider

| Metot | Açıklama |
|---|---|
| `fetchAndActivate()` | Remote config değerlerini getir ve etkinleştir *(stub)* |
| `getString(key, defaultValue)` | String değer al |
| `getBool(key, defaultValue)` | Boolean değer al |
| `getInt(key, defaultValue)` | Integer değer al |
| `getDouble(key, defaultValue)` | Double değer al |
| `getAll()` | Tüm config değerlerini map olarak al |
| `setMinimumFetchInterval(interval)` | Minimum getirme aralığını belirle *(stub)* |

**Sağlayıcı ID'si:** `huawei`

## Ek Bilgiler

- **Repository:** [github.com/emresaridogan/service_bridge](https://github.com/emresaridogan/service_bridge)
- **Sorunlar:** [GitHub Issues](https://github.com/emresaridogan/service_bridge/issues)
- **Lisans:** MIT

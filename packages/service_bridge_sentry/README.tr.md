# service_bridge_sentry

[![Pub Version](https://img.shields.io/pub/v/service_bridge_sentry.svg)](https://pub.dev/packages/service_bridge_sentry)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/emresaridogan/service_bridge/blob/main/LICENSE)

[Service Bridge](https://pub.dev/packages/service_bridge_core) ekosistemi için Sentry sağlayıcı uygulamaları. Sentry SDK aracılığıyla hata raporlama ve yapılandırılmış loglama sağlar.

## Özellikler

- **SentryCrashReporter** — Sentry ile hata raporlama, breadcrumb'lar, özel bağlam ve kullanıcı tanımlama
- **SentryLoggerProvider** — Breadcrumb gönderen ve hata seviyesi logları Sentry etkinlikleri olarak yakalayan yapılandırılmış loglama
- **SentryProviderBundle** — Tüm Sentry sağlayıcılarını gruplandıran kolaylık sınıfı

## Kurulum

```yaml
dependencies:
  service_bridge_sentry: ^1.0.0
```

```bash
dart pub add service_bridge_sentry
```

## Kurulum

**Önemli:** Sentry, bu sağlayıcıları kullanmadan önce `SentryFlutter.init()` ile kendi başlatılmasını gerektirir. Uygulama başlangıcınızı Sentry'nin başlatıcısıyla sarın:

```dart
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:service_bridge_sentry/service_bridge_sentry.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) => options
      ..dsn = 'https://dsn-adresiniz@sentry.io/proje'
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

## Kullanım

```dart
final sb = ServiceBridge.instance;

// Hata raporlama
try {
  // riskli işlem
} catch (e, st) {
  await sb.crash.reportError(e, st, extras: {'ekran': 'odeme'});
}

// Kritik olmayan mesaj
await sb.crash.reportMessage('Ödeme tekrar deneniyor', level: SeverityLevel.warning);

// Kullanıcı tanımlama (Sentry'ye SentryUser olarak gönderilir)
await sb.crash.setUserId('user_123');

// Özel bağlam
await sb.crash.setCustomKey('abonelik', 'premium');

// Breadcrumb'lar
await sb.crash.recordBreadcrumb(
  'Sepete ürün eklendi',
  category: 'ticaret',
  data: {'urun_id': 'sku_001'},
);

// Loglama — hata seviyesi loglar ayrıca Sentry etkinlikleri olarak yakalanır
await sb.log.info('Kullanıcı giriş yaptı');
await sb.log.warning('Yavaş API yanıtı');
await sb.log.error('Ödeme başarısız', error: e, stackTrace: st);
```

## Sağlayıcılar

### SentryCrashReporter

| Metot | Açıklama |
|---|---|
| `reportError(error, stackTrace, extras, level)` | İsteğe bağlı bağlam ve önem derecesiyle Sentry'de istisna yakala |
| `reportMessage(message, level, extras)` | Mesaj etkinliği yakala |
| `setUserId(userId)` | Sentry kullanıcısını belirle (`SentryUser` olarak) |
| `setCustomKey(key, value)` | Kapsam bağlam verisi belirle |
| `recordBreadcrumb(message, category, data)` | Sentry breadcrumb'ı ekle |

**Sağlayıcı ID'si:** `sentry`

### SentryLoggerProvider

Loglar Sentry breadcrumb'ları olarak gönderilir. Hata ve stack trace sağlandığında, ayrıca Sentry etkinlikleri olarak yakalanır.

| Metot | Açıklama |
|---|---|
| `log(level, message, extras, error, stackTrace)` | Belirli bir seviyeyle logla |
| `debug(message, extras)` | Debug breadcrumb'ı logla |
| `info(message, extras)` | Bilgi breadcrumb'ı logla |
| `warning(message, extras)` | Uyarı breadcrumb'ı logla |
| `error(message, error, stackTrace, extras)` | Logla ve hata olarak Sentry etkinliği yakala |

**Sağlayıcı ID'si:** `sentry_logger`

## Önem Derecesi Eşlemesi

| ServiceBridge `SeverityLevel` | Sentry `SentryLevel` |
|---|---|
| `debug` | `SentryLevel.debug` |
| `info` | `SentryLevel.info` |
| `warning` | `SentryLevel.warning` |
| `error` | `SentryLevel.error` |
| `fatal` | `SentryLevel.fatal` |

## Ek Bilgiler

- **Repository:** [github.com/emresaridogan/service_bridge](https://github.com/emresaridogan/service_bridge)
- **Sorunlar:** [GitHub Issues](https://github.com/emresaridogan/service_bridge/issues)
- **Lisans:** MIT

/// Sentry provider implementations for service_bridge.
library service_bridge_sentry;

export 'package:sentry_flutter/sentry_flutter.dart' show SentryWidgetsFlutterBinding;
export 'package:service_bridge_core/service_bridge_core.dart';

export 'src/sentry_crash_reporter.dart';
export 'src/sentry_logger_provider.dart';
export 'src/sentry_provider_bundle.dart';

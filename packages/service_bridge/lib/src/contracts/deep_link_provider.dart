import 'package:service_bridge/src/contracts/base_service_provider.dart';
import 'package:service_bridge/src/models/deep_link_params.dart';

/// Contract for deep link providers.
///
/// Implementations: AppsFlyerDeepLinkProvider, FirebaseDeepLinkProvider
abstract class DeepLinkProvider extends BaseServiceProvider {
  /// Get the deep link that launched the app (cold start).
  Future<Uri?> getInitialLink();

  /// Stream of deep links received while the app is running.
  Stream<Uri> get onDeepLink;

  /// Create a new deep link with the given parameters.
  Future<Uri> createDeepLink(DeepLinkParams params);
}

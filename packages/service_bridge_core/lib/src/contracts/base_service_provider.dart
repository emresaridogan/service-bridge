/// Base contract for all service providers.
///
/// Every third-party provider (Firebase, Sentry, AppsFlyer, etc.)
/// must implement this contract for lifecycle management.
abstract class BaseServiceProvider {
  /// Unique identifier for this provider (e.g., 'firebase', 'sentry').
  String get providerId;

  /// Whether this provider has been successfully initialized.
  bool get isInitialized;

  /// Initialize the provider. Called once during app startup.
  Future<void> initialize();

  /// Dispose of the provider's resources.
  Future<void> dispose();
}

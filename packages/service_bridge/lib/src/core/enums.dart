/// Severity level for crash reports and logs.
enum SeverityLevel {
  /// Debug-level severity.
  debug,

  /// Informational severity.
  info,

  /// Warning-level severity.
  warning,

  /// Error-level severity.
  error,

  /// Fatal/critical severity.
  fatal,
}

/// Log level for logger providers.
enum LogLevel {
  /// Verbose/trace level.
  verbose,

  /// Debug level.
  debug,

  /// Informational level.
  info,

  /// Warning level.
  warning,

  /// Error level.
  error,

  /// Fatal level — app cannot continue.
  fatal,
}

/// Platform type for GMS/HMS differentiation.
enum PlatformType {
  /// Google Mobile Services (default for most Android devices and iOS).
  gms,

  /// Huawei Mobile Services (for Huawei/Honor devices without GMS).
  hms,
}

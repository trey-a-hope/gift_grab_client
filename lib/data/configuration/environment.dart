import 'package:flutter/foundation.dart';
import 'package:gift_grab_client/core/logging.dart';

/// Provides configuration flags based on the current execution environment.
class Environment {
  /// Resolves the current environment string.
  /// Defaults to 'production' in release mode, and 'development' otherwise.
  static String get _env {
    const env = kReleaseMode ? 'production' : 'development';
    logger.d('Using env: $env');
    return env;
  }

  /// Returns true if the application is running in the production environment.
  static bool get isProd => _env == 'production';
}

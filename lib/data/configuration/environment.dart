import 'package:flutter/foundation.dart';
import 'package:gift_grab_client/core/logging.dart';

class Environment {
  static String get _env {
    const env = kReleaseMode ? 'production' : 'development';
    logger.d('Using env: $env');
    return env;
  }

  static bool get isProd => _env == 'production';
}

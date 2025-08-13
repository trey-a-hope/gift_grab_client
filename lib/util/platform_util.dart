import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class PlatformUtil {
  static bool get isWeb => kIsWeb;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isMobile => isIOS || isAndroid;
  static bool get isDesktop => !kIsWeb && !isMobile;
}

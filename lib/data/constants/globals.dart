import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:gift_grab_client/data/configuration/environment.dart';

class Globals {
  Globals._();

  // Limits
  static const int recordListLimit = 10;
  static const int friendListLimit = 15;
  static const int groupListLimit = 10;

  // Asset paths
  static const String giftAsset = 'assets/images/gift-sprite.png';

  // Clerk
  static final clerkAuthConfig = ClerkAuthConfig(
    publishableKey: Environment.isProd
        ? 'pk_live_Y2xlcmsuZ2lmdC1ncmFiLXNlcnZlci5hcHAk'
        : 'pk_test_Y29taWMtc2hpbmVyLTE3LmNsZXJrLmFjY291bnRzLmRldiQ',
  );

  // Nakama
  static String nakamaClientHost = Environment.isProd
      ? 'gift-grab-server.app'
      : '127.0.0.1';
  static const String nakamaClientServerKey = 'defaultkey';
  static const int nakamaClientHttpPort = 443;

  // Google Signin
  static const String googleClientIdWeb =
      '955072082839-j2utdj2h98rj5q54pev8o8mrmfot8qab.apps.googleusercontent.com';
  static const String googleClientIdAndroid =
      '955072082839-vgl36rk1ca2dvqpji22ifs1pobometg7.apps.googleusercontent.com';
  static const String googleClientIdIos =
      '955072082839-oo9gainsq9d4scss7kjuttqt5u54vshj.apps.googleusercontent.com';
}

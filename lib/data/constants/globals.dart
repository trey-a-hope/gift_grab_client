class Globals {
  Globals._();

  // Limits
  static const paginationLimit = 20;

  // Image Paths
  static const String emptyProfile =
      'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';

  static const String giftAsset = 'assets/images/gift-sprite.png';

  static const bool isProd = true;

  static const String nakamaClientHost =
      isProd ? 'gift-grab-server.app' : '127.0.0.1';
  static const String nakamaClientServerKey = 'defaultkey';
  static const int nakamaClientHttpPort = 443;

  static const String googleClientIdWeb =
      '955072082839-j2utdj2h98rj5q54pev8o8mrmfot8qab.apps.googleusercontent.com';
  static const String googleClientIdAndroid =
      '955072082839-vgl36rk1ca2dvqpji22ifs1pobometg7.apps.googleusercontent.com';
  static const String googleClientIdIos =
      '955072082839-oo9gainsq9d4scss7kjuttqt5u54vshj.apps.googleusercontent.com';
}

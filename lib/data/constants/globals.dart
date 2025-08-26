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
}

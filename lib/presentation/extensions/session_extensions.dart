import 'package:nakama/nakama.dart';

extension SessionExtensions on Session {
  String print() =>
      'userid:$userId, expiresAt:$expiresAt, refreshExpiresAt:$refreshExpiresAt';
}

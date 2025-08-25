import 'package:flutter/rendering.dart';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:nakama/nakama.dart';

extension UserExtensions on User {
  NetworkImage getAvatar() {
    final hasValidAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;
    return NetworkImage(hasValidAvatar ? avatarUrl! : Globals.emptyProfile);
  }
}

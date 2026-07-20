import 'package:gift_grab_client/core/logging.dart';
import 'package:nakama/nakama.dart';

extension ListGroupUser on List<GroupUser> {
  void log({required String authenticatedUserId}) {
    final members = map((groupUser) {
      final isMe = groupUser.user.id == authenticatedUserId;
      return '${groupUser.user.username} (${groupUser.state.name})${isMe ? ' (me)' : ''}';
    }).join(', ');
    logger.i('MEMBERS: $members');
  }
}

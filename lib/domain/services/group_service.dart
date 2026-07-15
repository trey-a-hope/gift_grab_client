import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:nakama/nakama.dart';

class GroupService {
  final SessionService sessionService;
  final NakamaBaseClient client;

  GroupService(this.sessionService, this.client);

  Future<List<GroupUser>> getMembersOfGroup(String groupId) async {
    try {
      final session = await sessionService.getSession();

      final result = await client.listGroupUsers(
        session: session,
        groupId: groupId,
      );

      return result.groupUsers;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> kickMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      final session = await sessionService.getSession();

      return client.kickGroupUsers(
        session: session,
        groupId: groupId,
        userIds: [userId],
      );
    } catch (e) {
      rethrow;
    }
  }
}

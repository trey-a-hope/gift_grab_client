import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:nakama/nakama.dart';
import 'package:result_dart/result_dart.dart';

class GroupService {
  final SessionService sessionService;
  final NakamaBaseClient client;

  GroupService(this.sessionService, this.client);

  Future<List<GroupUser>> getMembersOfGroup(String groupId) async =>
      (await client.listGroupUsers(
        session: await sessionService.getSession(),
        groupId: groupId,
      )).groupUsers;

  Future<void> kickMember({
    required String groupId,
    required String userId,
  }) async => client.kickGroupUsers(
    session: await sessionService.getSession(),
    groupId: groupId,
    userIds: [userId],
  );

  Future<void> banMember({
    required String groupId,
    required String userId,
  }) async => client.banGroupUsers(
    session: await sessionService.getSession(),
    groupId: groupId,
    userIds: [userId],
  );

  Future<Result<Unit>> promoteMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      final session = await sessionService.getSession();
      await client.promoteGroupUsers(
        session: session,
        groupId: groupId,
        userIds: [userId],
      );
      return const Success(unit);
    } catch (e) {
      return Failure(e is Exception ? e : Exception(e.toString()));
    }
  }

  Future<void> demoteMember({
    required String groupId,
    required String userId,
  }) async => client.demoteGroupUsers(
    session: await sessionService.getSession(),
    groupId: groupId,
    userIds: [userId],
  );

  Future<void> addMember({
    required String groupId,
    required String userId,
  }) async => client.addGroupUsers(
    session: await sessionService.getSession(),
    groupId: groupId,
    userIds: [userId],
  );
}

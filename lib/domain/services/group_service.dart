import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:nakama/nakama.dart';
import 'package:result_dart/result_dart.dart';

class GroupService {
  final SessionService sessionService;
  final NakamaBaseClient client;

  GroupService(this.sessionService, this.client);

  Future<Result<List<GroupUser>>> getMembersOfGroup(String groupId) async {
    try {
      final session = (await sessionService.getSession()).fold(
        (success) => success,
        (error) => throw error,
      );

      final result = await client.listGroupUsers(
        session: session,
        groupId: groupId,
      );

      return Success(result.groupUsers);
    } catch (e) {
      return Failure(e is Exception ? e : Exception(e.toString()));
    }
  }

  Future<Result<Unit>> kickMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      final session = (await sessionService.getSession()).fold(
        (success) => success,
        (error) => throw error,
      );

      await client.kickGroupUsers(
        session: session,
        groupId: groupId,
        userIds: [userId],
      );

      return const Success(unit);
    } catch (e) {
      return Failure(e is Exception ? e : Exception(e.toString()));
    }
  }

  Future<Result<Unit>> banMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      final session = (await sessionService.getSession()).fold(
        (success) => success,
        (error) => throw error,
      );

      await client.banGroupUsers(
        session: session,
        groupId: groupId,
        userIds: [userId],
      );

      return const Success(unit);
    } catch (e) {
      return Failure(e is Exception ? e : Exception(e.toString()));
    }
  }

  Future<Result<Unit>> promoteMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      final session = (await sessionService.getSession()).fold(
        (success) => success,
        (error) => throw error,
      );

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

  Future<Result<Unit>> demoteMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      final session = (await sessionService.getSession()).fold(
        (success) => success,
        (error) => throw error,
      );

      await client.demoteGroupUsers(
        session: session,
        groupId: groupId,
        userIds: [userId],
      );

      return const Success(unit);
    } catch (e) {
      return Failure(e is Exception ? e : Exception(e.toString()));
    }
  }

  Future<Result<Unit>> addMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      final session = (await sessionService.getSession()).fold(
        (success) => success,
        (error) => throw error,
      );

      await client.addGroupUsers(
        session: session,
        groupId: groupId,
        userIds: [userId],
      );

      return const Success(unit);
    } catch (e) {
      return Failure(e is Exception ? e : Exception(e.toString()));
    }
  }
}

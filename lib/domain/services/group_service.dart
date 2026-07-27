import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:nakama/nakama.dart';
import 'package:result_dart/result_dart.dart';

/// Service class for interacting with Nakama's group management features.
class GroupService {
  /// Service used to retrieve the active user session.
  final SessionService sessionService;

  /// The Nakama client interface.
  final NakamaBaseClient client;

  GroupService(this.sessionService, this.client);

  /// Retrieves the list of members belonging to a specific group.
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

  /// Kicks a member out of a specific group.
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

  /// Bans a member from a specific group.
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

  /// Promotes a member's role status (e.g. member to admin) in a group.
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

  /// Demotes a member's role status (e.g. admin to member) in a group.
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

  /// Adds a user as a member to a specific group.
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

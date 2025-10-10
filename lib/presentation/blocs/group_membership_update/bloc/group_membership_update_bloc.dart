import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/main.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:nakama/nakama.dart';

part 'group_membership_update_event.dart';
part 'group_membership_update_state.dart';

class GroupMembershipUpdateBloc
    extends Bloc<GroupMembershipUpdateEvent, GroupMembershipUpdateState> {
  final NakamaBaseClient client;
  final SessionService sessionService;

  GroupMembershipUpdateBloc(
    String groupId,
    this.client,
    this.sessionService,
  ) : super(GroupMembershipUpdateState(groupId)) {
    on<JoinGroup>(_onJoinGroup);
    on<LeaveGroup>(_onLeaveGroup);
    on<CancelRequest>(_onCancelRequest);
    on<AddGroupUser>(_onAddGroupUser);
    on<KickGroupUser>(_onKickGroupUser);
    on<DenyRequest>(_onDenyRequest);
  }

  Future<void> _onJoinGroup(
    JoinGroup event,
    Emitter<GroupMembershipUpdateState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          await client.joinGroup(
            session: session,
            groupId: state.groupId,
          );

          emit(state.copyWith(success: 'Group joined'));
        },
        emit: emit,
        state: state,
      );

  Future<void> _onLeaveGroup(
    LeaveGroup event,
    Emitter<GroupMembershipUpdateState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          await client.leaveGroup(
            session: session,
            groupId: state.groupId,
          );

          emit(state.copyWith(success: 'Group left'));
        },
        emit: emit,
        state: state,
      );

  Future<void> _onCancelRequest(
    CancelRequest event,
    Emitter<GroupMembershipUpdateState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          await client.leaveGroup(
            session: session,
            groupId: state.groupId,
          );

          emit(state.copyWith(success: 'Request canceled'));
        },
        emit: emit,
        state: state,
      );

  Future<void> _onAddGroupUser(
    AddGroupUser event,
    Emitter<GroupMembershipUpdateState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          await client.addGroupUsers(
            session: session,
            groupId: state.groupId,
            userIds: [event.uid],
          );

          emit(state.copyWith(success: 'User added to group'));
        },
        emit: emit,
        state: state,
      );

  Future<void> _onKickGroupUser(
    KickGroupUser event,
    Emitter<GroupMembershipUpdateState> emit,
  ) async =>
      await _action(
        'User kicked from group',
        (session) async {
          logger.i('User ${session.userId} kicked ${event.uid}');
          await client.kickGroupUsers(
            session: session,
            groupId: state.groupId,
            userIds: [event.uid],
          );
        },
        emit,
      );

  Future<void> _onDenyRequest(
    DenyRequest event,
    Emitter<GroupMembershipUpdateState> emit,
  ) async =>
      await _action(
        'User request denied',
        (session) async {
          logger.i('User ${session.userId} denied ${event.uid} request');
          await client.kickGroupUsers(
            session: session,
            groupId: state.groupId,
            userIds: [event.uid],
          );
        },
        emit,
      );

  Future<void> _action(
    String successMessage,
    Future<void> Function(Session session) clientAction,
    Emitter<GroupMembershipUpdateState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          await clientAction(session);

          emit(state.copyWith(success: successMessage));
        },
        emit: emit,
        state: state,
      );
}

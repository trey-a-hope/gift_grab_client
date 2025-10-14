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
    on<AcceptRequest>(_onAcceptRequest);
    on<KickUser>(_onKickUser);
    on<DenyRequest>(_onDenyRequest);
    on<PromoteUser>(_onPromoteUser);
    on<DemoteUser>(_onDemoteUser);
    on<BanUser>(_onBanUser);
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

  Future<void> _onAcceptRequest(
    AcceptRequest event,
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

  Future<void> _onKickUser(
    KickUser event,
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

  Future<void> _onPromoteUser(
    PromoteUser event,
    Emitter<GroupMembershipUpdateState> emit,
  ) async =>
      await _action(
        'User promoted',
        (session) async {
          logger.i('User ${session.userId} promoted user ${event.uid}');
          await client.promoteGroupUsers(
            session: session,
            groupId: state.groupId,
            userIds: [event.uid],
          );
        },
        emit,
      );

  Future<void> _onDemoteUser(
    DemoteUser event,
    Emitter<GroupMembershipUpdateState> emit,
  ) async =>
      await _action(
        'User demoted',
        (session) async {
          logger.i('User ${session.userId} demoted user ${event.uid}');
          await client.demoteGroupUsers(
            session: session,
            groupId: state.groupId,
            userIds: [event.uid],
          );
        },
        emit,
      );

  Future<void> _onBanUser(
    BanUser event,
    Emitter<GroupMembershipUpdateState> emit,
  ) async =>
      await _action(
        'User banned',
        (session) async {
          logger.i('User ${session.userId} banned user ${event.uid}');
          await client.banGroupUsers(
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

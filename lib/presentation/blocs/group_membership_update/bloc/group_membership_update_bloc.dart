import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
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
}

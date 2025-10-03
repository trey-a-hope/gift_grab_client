import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/data/enums/rpc_functions.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:nakama/nakama.dart';

part 'group_membership_read_event.dart';
part 'group_membership_read_state.dart';

class GroupMembershipReadBloc
    extends Bloc<GroupMembershipReadEvent, GroupMembershipReadState> {
  final NakamaBaseClient client;
  final SessionService sessionService;

  GroupMembershipReadBloc(
    String groupId,
    this.client,
    this.sessionService,
  ) : super(GroupMembershipReadState(groupId)) {
    on<ReadGroupMembershipState>(_onReadGroupMembershipState);
  }

  Future<void> _onReadGroupMembershipState(
    ReadGroupMembershipState event,
    Emitter<GroupMembershipReadState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          final groupMembershipState =
              await _getGroupMembershipState(session, groupId: state.groupId);

          emit(state.copyWith(
              groupMembershipState: groupMembershipState,
              clearGroupMembershipState: groupMembershipState == null));
        },
        emit: emit,
        state: state,
      );

  Future<GroupMembershipState?> _getGroupMembershipState(Session session,
      {String? groupId}) async {
    if (groupId == null) return null;

    final _ = await client.rpc(
      session: session,
      id: RpcFunctions.GET_GROUP_MEMBERSHIP_STATE.id,
      payload: jsonEncode(
        {"group_id": groupId},
      ),
    );

    switch (_) {
      case "0":
        return GroupMembershipState.superadmin;
      case "1":
        return GroupMembershipState.admin;
      case "2":
        return GroupMembershipState.member;
      case "3":
        return GroupMembershipState.joinRequest;
      default:
        return null;
    }
  }
}

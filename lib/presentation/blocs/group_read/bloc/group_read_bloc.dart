import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/data/enums/rpc_functions.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:nakama/nakama.dart';

part 'group_read_event.dart';
part 'group_read_state.dart';

class GroupReadBloc extends Bloc<GroupReadEvent, GroupReadState> {
  final String groupId;
  final NakamaBaseClient client;
  final SessionService sessionService;

  GroupReadBloc(
    this.groupId,
    this.client,
    this.sessionService,
  ) : super(const GroupReadState()) {
    on<ReadGroup>(_onReadGroup);
  }

  Future<void> _onReadGroup(
    ReadGroup event,
    Emitter<GroupReadState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          final group = await _getGroupById(session, groupId);

          if (group == null) throw Exception('Group not found');

          emit(state.copyWith(group: group));
        },
        emit: emit,
        state: state,
      );

  Future<Group?> _getGroupById(Session session, String groupId) async {
    final res = await client.rpc(
      session: session,
      id: RpcFunctions.GET_GROUP_BY_ID.id,
      payload: jsonEncode(
        {'group_id': groupId},
      ),
    );

    if (res == null) return null;

    return Group.fromJson(jsonDecode(res));
  }
}

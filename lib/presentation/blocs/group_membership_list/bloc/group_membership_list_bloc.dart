import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:nakama/nakama.dart';

part 'group_membership_list_event.dart';
part 'group_membership_list_state.dart';

class GroupMembershipListBloc
    extends Bloc<GroupMembershipListEvent, GroupMembershipListState> {
  final String uid;
  final String groupId;
  final NakamaBaseClient client;
  final SessionService sessionService;

  GroupMembershipListBloc(
    this.uid,
    this.groupId,
    this.client,
    this.sessionService,
  ) : super(const GroupMembershipListState()) {
    on<FetchUsers>(_onFetchUsers);
  }

  Future<void> _onFetchUsers(
    FetchUsers event,
    Emitter<GroupMembershipListState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          final groupUserList = await client.listGroupUsers(
            session: session,
            groupId: groupId,
          );

          final groupUsers = groupUserList.groupUsers;

          emit(state.copyWith(groupUsers: groupUsers));
        },
        emit: emit,
        state: state,
      );
}

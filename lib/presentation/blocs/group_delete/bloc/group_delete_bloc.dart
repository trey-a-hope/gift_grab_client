import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:nakama/nakama.dart';

part 'group_delete_event.dart';
part 'group_delete_state.dart';

class GroupDeleteBloc extends Bloc<GroupDeleteEvent, GroupDeleteState> {
  final String groupId;
  final NakamaBaseClient client;
  final SessionService sessionService;

  GroupDeleteBloc(
    this.groupId,
    this.client,
    this.sessionService,
  ) : super(const GroupDeleteState()) {
    on<DeleteGroup>(_onDeleteGroup);
  }

  Future<void> _onDeleteGroup(
    DeleteGroup event,
    Emitter<GroupDeleteState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          await client.deleteGroup(session: session, groupId: groupId);

          emit(state.copyWith(success: 'Group deleted successfully'));
        },
        emit: emit,
        state: state,
      );
}

import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/data/enums/leaderboards.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:nakama/nakama.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';

part 'record_delete_event.dart';
part 'record_delete_state.dart';

class RecordDeleteBloc extends Bloc<RecordDeleteEvent, RecordDeleteState> {
  final NakamaBaseClient client;
  final SessionService sessionService;

  RecordDeleteBloc(
    this.client,
    this.sessionService,
  ) : super(const RecordDeleteState()) {
    on<DeleteRecord>(_onDeleteRecord);
  }

  Future<void> _onDeleteRecord(
    DeleteRecord event,
    Emitter<RecordDeleteState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));
          final session = await sessionService.getSession();

          await client.deleteLeaderboardRecord(
            session: session,
            leaderboardName: Leaderboards.MONTHLY.id,
          );

          emit(state.copyWith(success: 'Record deleted successfully'));
        },
        emit: emit,
        state: state,
      );
}

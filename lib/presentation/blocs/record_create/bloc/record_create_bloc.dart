import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/data/enums/leaderboards.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:nakama/nakama.dart';

part 'record_create_event.dart';
part 'record_create_state.dart';

class RecordCreateBloc extends Bloc<RecordCreateEvent, RecordCreateState> {
  final NakamaBaseClient client;
  final SessionService sessionService;

  RecordCreateBloc(
    this.client,
    this.sessionService,
  ) : super(const RecordCreateState()) {
    on<SubmitRecord>(_onSubmitRecord);
  }

  Future<void> _onSubmitRecord(
    SubmitRecord event,
    Emitter<RecordCreateState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          await client.writeLeaderboardRecord(
            session: session,
            leaderboardName: Leaderboards.MONTHLY.id,
            score: event.score,
          );

          emit(state.copyWith());
        },
        emit: emit,
        state: state,
      );
}

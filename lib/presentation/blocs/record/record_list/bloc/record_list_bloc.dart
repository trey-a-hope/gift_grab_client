import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/data/enums/leaderboards.dart';
import 'package:gift_grab_client/domain/entities/leaderboard_entry.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:nakama/nakama.dart';

part 'record_list_event.dart';
part 'record_list_state.dart';

class RecordListBloc extends Bloc<RecordListEvent, RecordListState> {
  final SessionService sessionService;
  final NakamaBaseClient client;
  RecordListBloc(
    this.sessionService,
    this.client,
  ) : super(const RecordListState()) {
    on<FetchRecords>(_onFetchRecords);
  }

  Future<void> _onFetchRecords(
    FetchRecords event,
    Emitter<RecordListState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          if (event.reset) {
            emit(
              state.copyWith(
                isLoading: true,
                clearCursor: true,
              ),
            );
          }

          final session = await sessionService.getSession();

          final leaderboardRecordList = await client.listLeaderboardRecords(
            session: session,
            leaderboardName: Leaderboards.MONTHLY.id,
            cursor: state.cursor,
            limit: 1,
          );

          if (leaderboardRecordList.records == null) {
            return;
          }

          final records = leaderboardRecordList.records!;

          final entries = await _createLeaderboardEntries(session, records);

          emit(state.copyWith(
            entries: [...state.entries, ...entries],
            cursor: leaderboardRecordList.nextCursor,
          ));
        },
        emit: emit,
        state: state,
      );

  Future<List<LeaderboardEntry>> _createLeaderboardEntries(
    Session session,
    List<LeaderboardRecord> records,
  ) async {
    final validRecords = records.where((r) => r.ownerId != null).toList();
    final ownerIds = validRecords.map((r) => r.ownerId!).toList();

    final users = await client.getUsers(session: session, ids: ownerIds);

    return validRecords.map((record) {
      final user = users.firstWhere((u) => u.id == record.ownerId);
      return LeaderboardEntry(record: record, user: user);
    }).toList();
  }
}

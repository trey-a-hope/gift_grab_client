import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/data/enums/leaderboards.dart';
import 'package:gift_grab_client/domain/entities/leaderboard_entry.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/extensions/string_extensions.dart';
import 'package:nakama/nakama.dart';

part 'record_list_event.dart';
part 'record_list_state.dart';

class RecordListBloc extends Bloc<RecordListEvent, RecordListState> {
  final NakamaBaseClient client;
  final SessionService sessionService;

  RecordListBloc(
    this.client,
    this.sessionService,
  ) : super(const RecordListState()) {
    on<InitialFetch>(_onInitialFetch);
    on<FetchMore>(_onFetchMore);
    on<FetchRecords>(_onFetchRecords);
  }

  Future<void> _onInitialFetch(
    InitialFetch event,
    Emitter<RecordListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, cursor: null, entries: []));
    add(const FetchRecords());
  }

  Future<void> _onFetchMore(
    FetchMore event,
    Emitter<RecordListState> emit,
  ) async =>
      add(const FetchRecords());

  Future<void> _onFetchRecords(
    FetchRecords event,
    Emitter<RecordListState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          final session = await sessionService.getSession();

          final leaderboardRecordList = await client.listLeaderboardRecords(
            session: session,
            leaderboardName: Leaderboards.MONTHLY.id,
            cursor: state.cursor,
            limit: Globals.recordListLimit,
          );

          if (leaderboardRecordList.records == null) {
            emit(state.copyWith());
            return;
          }

          final records = leaderboardRecordList.records!;

          final entries = await _createLeaderboardEntries(session, records);

          emit(state.copyWith(
            entries: [...state.entries, ...entries],
            cursor: leaderboardRecordList.nextCursor.nullIfEmpty,
          ));
        },
        emit: emit,
        state: state,
      );

  Future<List<LeaderboardEntry>> _createLeaderboardEntries(
      Session session, List<LeaderboardRecord> records) async {
    final validRecords = records.where((r) => r.ownerId != null);
    final ownerIds = validRecords.map((r) => r.ownerId!).toList();
    final users = await client.getUsers(session: session, ids: ownerIds);

    final userMap = {for (final user in users) user.id: user};

    return validRecords
        .map((record) =>
            LeaderboardEntry(record: record, user: userMap[record.ownerId]!))
        .toList();
  }
}

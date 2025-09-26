import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:gift_grab_client/presentation/extensions/string_extensions.dart';
import 'package:nakama/nakama.dart';

part 'group_list_event.dart';
part 'group_list_state.dart';

class GroupListBloc extends Bloc<GroupListEvent, GroupListState> {
  final String? uid;
  final NakamaBaseClient client;
  final SessionService sessionService;

  GroupListBloc(
    this.uid,
    this.client,
    this.sessionService,
  ) : super(const GroupListState()) {
    on<InitialFetch>(_onInitialFetch);
    on<FetchMore>(_onFetchMore);
    on<FetchGroups>(_onFetchGroups);
    on<SearchGroup>(_onSearchGroup);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onInitialFetch(
    InitialFetch event,
    Emitter<GroupListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, groups: []));
    add(const FetchGroups());
  }

  Future<void> _onFetchMore(
    FetchMore event,
    Emitter<GroupListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, cursor: state.cursor));
    add(const FetchGroups());
  }

  Future<void> _onFetchGroups(
    FetchGroups event,
    Emitter<GroupListState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          final session = await sessionService.getSession();

          late List<Group> groups;
          late String? cursor;

          if (uid == null) {
            final groupList = await client.listGroups(
              session: session,
              cursor: state.cursor,
              name: state.query,
              limit: Globals.groupListLimit,
            );

            groups = groupList.groups ?? [];
            cursor = groupList.cursor.nullIfEmpty;
          } else {
            final groupList = await client.listUserGroups(
                session: session,
                cursor: state.cursor,
                limit: Globals.groupListLimit,
                userId: uid!);

            groups = groupList.userGroups?.map((ug) => ug.group).toList() ??
                <Group>[];
            cursor = groupList.cursor.nullIfEmpty;
          }

          if (groups.isEmpty) {
            emit(state.copyWith());
            return;
          }

          emit(
            state.copyWith(
              groups: [...state.groups, ...groups],
              cursor: cursor,
              clearCursor: cursor.nullIfEmpty == null,
            ),
          );
        },
        emit: emit,
        state: state,
      );

  Future<void> _onSearchGroup(
    SearchGroup event,
    Emitter<GroupListState> emit,
  ) async {
    final name = event.name;
    emit(state.copyWith(query: name.nullIfEmpty == null ? '' : '$name%'));
    add(const InitialFetch());
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<GroupListState> emit,
  ) async =>
      emit(
        state.copyWith(
          query: '',
          groups: [],
        ),
      );
}

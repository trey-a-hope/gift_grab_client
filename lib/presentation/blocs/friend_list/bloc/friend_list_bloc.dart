import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/extensions/string_extensions.dart';
import 'package:nakama/nakama.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';

part 'friend_list_event.dart';
part 'friend_list_state.dart';

class FriendListBloc extends Bloc<FriendListEvent, FriendListState> {
  final FriendshipState friendshipState;
  final NakamaBaseClient client;
  final SessionService sessionService;

  FriendListBloc(this.friendshipState, this.client, this.sessionService)
      : super(FriendListState(friendshipState)) {
    on<InitialFetch>(_onInitialFetch);
    on<FetchMore>(_onFetchMore);
    on<FetchFriends>(_onFetchFriends);
  }

  Future<void> _onInitialFetch(
    InitialFetch event,
    Emitter<FriendListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, friends: []));
    add(const FetchFriends());
  }

  Future<void> _onFetchMore(
    FetchMore event,
    Emitter<FriendListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, cursor: state.cursor));
    add(const FetchFriends());
  }

  Future<void> _onFetchFriends(
    FetchFriends event,
    Emitter<FriendListState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          final session = await sessionService.getSession();

          final friendList = await client.listFriends(
            session: session,
            friendshipState: friendshipState,
            cursor: state.cursor,
            limit: Globals.friendListLimit,
          );

          if (friendList.friends == null) {
            emit(state.copyWith());
            return;
          }

          final friends = friendList.friends!;

          emit(
            state.copyWith(
              friends: [...state.friends, ...friends],
              cursor: friendList.cursor.nullIfEmpty,
            ),
          );
        },
        emit: emit,
        state: state,
      );
}

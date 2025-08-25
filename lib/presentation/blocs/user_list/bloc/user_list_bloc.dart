import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:nakama/nakama.dart';

part 'user_list_event.dart';
part 'user_list_state.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final NakamaBaseClient client;
  final SessionService sessionService;
  UserListBloc(
    this.client,
    this.sessionService,
  ) : super(const UserListState()) {
    on<SearchUser>(_onSearchUser);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchUser(
    SearchUser event,
    Emitter<UserListState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          final users = await client.getUsers(
            session: session,
            ids: [],
            usernames: [
              event.username,
            ],
          );

          emit(state.copyWith(query: event.username, users: users));
        },
        emit: emit,
        state: state,
      );

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<UserListState> emit,
  ) async =>
      emit(
        state.copyWith(
          query: '',
          users: [],
        ),
      );
}

import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:nakama/nakama.dart';

part 'user_read_event.dart';
part 'user_read_state.dart';

class UserReadBloc extends Bloc<UserReadEvent, UserReadState> {
  final String uid;
  final NakamaBaseClient client;
  final SessionService sessionService;

  UserReadBloc(
    this.uid,
    this.client,
    this.sessionService,
  ) : super(const UserReadState()) {
    on<ReadUser>(_onReadUser);
  }

  Future<void> _onReadUser(
    ReadUser event,
    Emitter<UserReadState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          final users = await client.getUsers(
            session: session,
            ids: [uid],
          );

          if (users.isEmpty) {
            throw Exception('no users found');
          }

          final user = users.first;

          final isMyProfile = session.userId == user.id;

          emit(
            state.copyWith(user: user, isMyProfile: isMyProfile),
          );
        },
        emit: emit,
        state: state,
      );
}

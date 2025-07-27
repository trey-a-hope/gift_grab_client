import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:nakama/nakama.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final NakamaBaseClient client;
  final SessionService sessionService;

  AuthCubit(
    this.client,
    this.sessionService,
  ) : super(const AuthState());

  Future<void> loginEmail(String email, String password) async {
    try {
      final session = await client.authenticateEmail(
        email: email,
        password: password,
      );

      await sessionService.saveSession(session);

      emit(state.copyWith(authenticated: true));
    } catch (e) {
      emit(state.copyWith(
        authenticated: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> logout() async {
    try {
      await sessionService.logout();
      emit(state.copyWith(authenticated: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final session = await sessionService.getSession();

      if (sessionService.shouldRefreshSession(session)) {
        await sessionService.refreshSession(session);
      }
      emit(state.copyWith(authenticated: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> signup(
    String email,
    String password,
    String username,
  ) async {
    try {
      final session = await client.authenticateEmail(
        email: email,
        password: password,
        username: username,
        create: true,
      );
      await sessionService.saveSession(session);

      emit(state.copyWith(authenticated: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}

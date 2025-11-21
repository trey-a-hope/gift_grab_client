import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fluo/fluo.dart';
import 'package:gift_grab_client/data/enums/login_error_exclusions.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/main.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:nakama/nakama.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final NakamaBaseClient client;
  final SessionService sessionService;

  AuthCubit(this.client, this.sessionService) : super(const AuthState());

  Future<void> loginCustom({
    required String id,
    required String username,
  }) async {
    try {
      emit(state.copyWith(isLoading: true));

      final session = await client.authenticateCustom(
        id: id,
        create: true,
        username: username,
      );

      await sessionService.saveSession(session);
      logger.d('loginEmail: id - $id, username - $username');
      emit(state.copyWith(authenticated: true));
    } catch (e) {
      logger.e(e.toString());
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<String?> loginEmail(String email, String password) async {
    try {
      emit(state.copyWith(isLoading: true));

      final session = await client.authenticateEmail(
        password: password,
        email: email,
        create: false,
      );

      await sessionService.saveSession(session);

      emit(state.copyWith(authenticated: true));

      logger.d('loginEmail: email - $email, password - $password');

      return null;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return e.toString();
    }
  }

  Future<void> logout() async {
    try {
      emit(state.copyWith(isLoading: true));
      await sessionService.logout();
      await Fluo.instance.clearSession();
      emit(state.copyWith(authenticated: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      emit(state.copyWith(isLoading: true));

      final session = await sessionService.getSession();

      if (sessionService.shouldRefreshSession(session)) {
        await sessionService.refreshSession(session);
      }

      emit(state.copyWith(authenticated: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<String?> signup(String email, String password, String username) async {
    try {
      emit(state.copyWith(isLoading: true));

      final session = await client.authenticateEmail(
        password: password,
        email: email,
        username: username,
        create: true,
      );

      await sessionService.saveSession(session);

      emit(state.copyWith(authenticated: true));

      return null;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return e.toString();
    }
  }

  Future<String?> loginGoogle() async {
    try {
      emit(state.copyWith(isLoading: true));

      const idToken = null;

      if (idToken == null) {
        emit(state.copyWith());
        return LoginErrorExclusions.CANCELED.id;
      }

      final session = await client.authenticateGoogle(token: idToken);
      await sessionService.saveSession(session);

      emit(state.copyWith(authenticated: true));
      return null;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return e.toString();
    }
  }

  Future<String?> loginApple() async {
    try {
      emit(state.copyWith(isLoading: true));

      const idToken = null;

      if (idToken == null) {
        emit(state.copyWith());
        return LoginErrorExclusions.CANCELED.id;
      }

      final session = await client.authenticateApple(token: idToken);
      await sessionService.saveSession(session);

      emit(state.copyWith(authenticated: true));
      return null;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return e.toString();
    }
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fluo/fluo.dart';
import 'package:gift_grab_client/data/enums/login_error_exclusions.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:nakama/nakama.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:gift_grab_client/core/logging.dart';

part 'auth_state.dart';

// TODO (Trey) - Replace AuthCubit with AuthController
class AuthCubit extends Cubit<AuthState> {
  final NakamaBaseClient client;
  final SessionService sessionService;
  final ClerkAuthState clerkAuth;

  AuthCubit(this.client, this.sessionService, this.clerkAuth)
    : super(const AuthState()) {
    clerkAuth.addListener(_onClerkAuthChanged);
  }

  void _onClerkAuthChanged() {
    if (clerkAuth.isSignedIn) {
      final user = clerkAuth.user;
      if (user != null) {
        if (!state.authenticated && !state.isLoading) {
          final id = user.id;
          final username = user.email ?? user.username ?? 'NOUSERNAME';
          loginCustom(id: id, username: username);
        }
      }
    } else {
      if (state.authenticated && !state.isLoading) {
        logout();
      }
    }
  }

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
      if (e.toString().contains('ALREADY_EXISTS') ||
          e.toString().contains('Username is already in use')) {
        try {
          // Retry without username so Nakama auto-generates a unique one
          final session = await client.authenticateCustom(id: id, create: true);
          await sessionService.saveSession(session);
          logger.d('loginEmail (fallback unique username): id - $id');
          emit(state.copyWith(authenticated: true));
          return;
        } catch (retryException) {
          logger.e(retryException.toString());
          emit(state.copyWith(error: retryException.toString()));
          return;
        }
      }
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
      await clerkAuth.signOut();
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
      if (e.toString().contains('No session stored')) {
        emit(state.copyWith(authenticated: false, isLoading: false));
      } else {
        emit(state.copyWith(error: e.toString()));
      }
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

  @override
  Future<void> close() {
    clerkAuth.removeListener(_onClerkAuthChanged);
    return super.close();
  }
}

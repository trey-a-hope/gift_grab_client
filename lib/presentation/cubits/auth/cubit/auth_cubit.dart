import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/data/enums/login_error_exclusions.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/domain/services/social_auth_service.dart';
import 'package:gift_grab_client/main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nakama/nakama.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final NakamaBaseClient client;
  final SessionService sessionService;
  final SocialAuthService socialAuthService;

  StreamSubscription<GoogleSignInAuthenticationEvent>? _googleAuthSubscription;

  AuthCubit(
    this.client,
    this.sessionService,
    this.socialAuthService,
  ) : super(const AuthState()) {
    _initializeGoogleAuth();
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

  Future<String?> signup(
    String email,
    String password,
    String username,
  ) async {
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

      final idToken = await socialAuthService.getGoogleToken();

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

      final idToken = await socialAuthService.getAppleToken();

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
    _googleAuthSubscription?.cancel();
    return super.close();
  }

  // Note: For web only
  void _initializeGoogleAuth() {
    _googleAuthSubscription = socialAuthService
        .googleSignIn.authenticationEvents
        .listen(_handleAuthenticationEvent)
      ..onError(_handleAuthenticationError);
  }

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    final idToken = user?.authentication.idToken;

    if (idToken == null) return;

    final session = await client.authenticateGoogle(token: idToken);
    await sessionService.saveSession(session);

    emit(state.copyWith(authenticated: true));
  }

  Future<void> _handleAuthenticationError(Object e) async {
    final errorMessage = e is GoogleSignInException
        ? _errorMessageFromSignInException(e)
        : 'Unknown error: $e';

    emit(state.copyWith(error: errorMessage));
  }

  String _errorMessageFromSignInException(GoogleSignInException e) {
    return switch (e.code) {
      GoogleSignInExceptionCode.canceled => 'Sign in canceled',
      _ => 'GoogleSignInException ${e.code}: ${e.description}',
    };
  }
}

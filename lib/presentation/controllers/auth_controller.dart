import 'dart:async';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:gift_grab_client/core/logging.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:nakama/nakama.dart';
import 'package:signals/signals_hooks.dart';
import 'package:clerk_auth/clerk_auth.dart';

class AuthController {
  final NakamaBaseClient _client;
  final SessionService _sessionService;
  final ClerkAuthState _clerkAuth;

  final AsyncSignal<bool> isAuthenticated = AsyncSignal(const AsyncData(false));

  AuthController({
    required this._client,
    required this._sessionService,
    required this._clerkAuth,
  }) {
    _clerkAuth.sessionTokenStream.listen(_onClerkSessionToken);
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      if (_clerkAuth.isSignedIn) {
        isAuthenticated.value = const AsyncLoading();
        final token = await _clerkAuth.sessionToken();
        await _onClerkSessionToken(token);
      }
    } catch (e) {
      isAuthenticated.value = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> _onClerkSessionToken(SessionToken token) async {
    try {
      if (_clerkAuth.client.signUp != null) {
        // This session came from the widget silently signing someone
        // up — not a real login. Reject it.
        logger.d('Blocking auto-provisioned Clerk sign-up');
        await _clerkAuth.signOut();
        isAuthenticated.value = AsyncError(
          'No account found for this email',
          StackTrace.current,
        );
        return;
      }

      logger.d('Running "_onClerkSessionToken"...');
      final session = await _client.authenticateCustom(id: token.jwt);
      await _sessionService.saveSession(session);
      isAuthenticated.value = const AsyncData(true);
      logger.d('"_onClerkSessionToken" complete, user is authenticated');
    } catch (e) {
      logger.e('Error in _onClerkSessionToken: $e');
      isAuthenticated.value = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> logout() async {
    try {
      isAuthenticated.value = const AsyncLoading();
      await _sessionService.logout();
      await _clerkAuth.signOut();
      isAuthenticated.value = const AsyncData(false);
    } catch (e) {
      isAuthenticated.value = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      isAuthenticated.value = const AsyncLoading();

      final session = (await _sessionService.getSession()).fold(
        (success) => success,
        (error) => throw error,
      );

      if (_sessionService.shouldRefreshSession(session)) {
        await _sessionService.refreshSession(session);
      }

      isAuthenticated.value = const AsyncData(true);
    } catch (e) {
      isAuthenticated.value = AsyncError(e, StackTrace.current);
    }
  }
}

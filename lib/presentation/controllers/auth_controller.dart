import 'dart:async';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:nakama/nakama.dart';
import 'package:gift_grab_client/core/logging.dart';
import 'package:signals/signals_hooks.dart';
import 'package:clerk_auth/clerk_auth.dart' as clerk;

class AuthController {
  final NakamaBaseClient _client;
  final SessionService _sessionService;
  final clerk.Auth _clerkAuth;

  final AsyncSignal<bool> isAuthenticated = AsyncSignal(const AsyncData(false));

  AuthController({
    required this._client,
    required this._sessionService,
    required this._clerkAuth,
  });

  Future<void> loginCustom({
    required String id,
    required String username,
  }) async {
    try {
      isAuthenticated.value = const AsyncLoading();

      if (!_clerkAuth.isSignedIn) {
        return;
      }

      final session = await _client.authenticateCustom(
        id: id,
        create: false,
        username: username,
      );

      await _sessionService.saveSession(session);
      logger.d('loginEmail: id - $id, username - $username');
      isAuthenticated.value = const AsyncData(true);
    } catch (e) {
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

      final session = await _sessionService.getSession();

      if (_sessionService.shouldRefreshSession(session)) {
        await _sessionService.refreshSession(session);
      }

      isAuthenticated.value = const AsyncData(true);
    } catch (e) {
      isAuthenticated.value = AsyncError(e, StackTrace.current);
    }
  }
}

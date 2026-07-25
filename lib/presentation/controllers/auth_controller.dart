import 'dart:async';
import 'dart:ui';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:gift_grab_client/core/logging.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:nakama/nakama.dart';
import 'package:signals/signals_hooks.dart';

/// Controller responsible for managing the authentication flow.
/// It bridges Clerk authentication with Nakama server authentication.
class AuthController {
  final NakamaBaseClient _client;
  final SessionService _sessionService;
  final ClerkAuthState _clerkAuth;

  /// Signal to track changes to the Clerk session ID.
  late final Signal<String?> _clerkSessionId;

  /// Cleanup function for the reactive effect tracking authentication.
  late final EffectCleanup _disposeEffect;

  /// Callback to listen for Clerk auth changes and update [_clerkSessionId].
  late final VoidCallback _clerkListener;

  /// Async signal representing the user's current authentication state.
  final AsyncSignal<bool> isAuthenticated = AsyncSignal(
    const AsyncData(false),
    options: const SignalOptions(name: 'AuthController.isAuthenticated'),
  );

  /// Initializes the AuthController and sets up listeners and effects
  /// to automatically sync Clerk auth state changes with Nakama.
  AuthController({
    required this._client,
    required this._sessionService,
    required this._clerkAuth,
  }) {
    _clerkSessionId = signal(_clerkAuth.session?.id);

    _clerkListener = () {
      _clerkSessionId.value = _clerkAuth.session?.id;
    };
    _clerkAuth.addListener(_clerkListener);

    // Watch the clerk session id and process nakama authentication
    // accordingly.
    _disposeEffect = effect(() {
      final sessionId = _clerkSessionId.value;

      if (sessionId != null) {
        // Unawaited fires the async _processAuthentication() in the background
        // without blocking the synchronous effect callback or triggering
        // unawaited future linter warnings.
        unawaited(_processAuthentication());
      } else {
        isAuthenticated.value = const AsyncData(false);
      }
    });
  }

  /// Processes authentication against Nakama using the user's Clerk session JWT token.
  /// Determines if a signup or login flow should be used based on account creation time.
  Future<void> _processAuthentication() async {
    try {
      isAuthenticated.value = const AsyncLoading();

      final token = await _clerkAuth.sessionToken();
      final user = _clerkAuth.user;

      if (user == null) return;

      final isSignUp =
          user.lastSignInAt.difference(user.createdAt).abs().inSeconds < 2;

      logger.d(
        isSignUp
            ? 'Clerk user ${user.id} signed UP'
            : 'Clerk user ${user.id} signed IN',
      );

      final session = await _client.authenticateCustom(
        id: token.jwt,
        username: user.username,
        create: isSignUp,
      );

      await _sessionService.saveSession(session);
      isAuthenticated.value = const AsyncData(true);
    } catch (e) {
      logger.e('Error in authentication: $e');
      isAuthenticated.value = AsyncError(e, StackTrace.current);
    }
  }

  /// Logs out the current user, clearing the Nakama session and signing out from Clerk.
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

  /// Checks the local storage for an active Nakama session, refreshes it if needed,
  /// and marks the authentication status as true if a valid session exists.
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

  /// Cleans up listeners and effect timers when the controller is disposed.
  void dispose() {
    _clerkAuth.removeListener(_clerkListener);
    _disposeEffect();
  }
}

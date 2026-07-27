import 'package:gift_grab_client/core/logging.dart';
import 'package:gift_grab_client/domain/repositories/i_session_repository.dart';
import 'package:nakama/nakama.dart';
import 'package:result_dart/result_dart.dart';

/// Service class for managing user sessions, including retrieval, refresh, and logout.
class SessionService {
  /// Session expiration threshold buffer to trigger a proactive refresh.
  static const _hasExpiredDuration = Duration(minutes: 5);

  /// Callback executed when the session is found to be unauthenticated or invalid.
  void Function()? _onUnauthenticated;

  /// Repository for low-level session storage and API operations.
  final ISessionRepository _iSessionRepository;

  SessionService(this._iSessionRepository);

  /// Persists the provided Nakama session.
  Future<void> saveSession(Session session) async {
    await _iSessionRepository.saveSession(session);
  }

  /// Determines whether the session has expired or is nearing expiration.
  bool shouldRefreshSession(Session session) =>
      session.isExpired ||
      session.hasExpired(DateTime.now().add(_hasExpiredDuration));

  /// Requests a fresh session from the backend using the current session details.
  Future<Session> refreshSession(Session session) async {
    try {
      final newSession = await _iSessionRepository.refreshSession(session);
      await _iSessionRepository.saveSession(newSession);
      return newSession;
    } catch (e) {
      _iSessionRepository.clearSession();
      throw Exception('Failed to refresh session: $e');
    }
  }

  /// Retrieves the stored session, refreshing it first if necessary.
  Future<Result<Session>> getSession() async {
    try {
      final session = await _iSessionRepository.getStoredSession();

      if (session == null) {
        _onUnauthenticated?.call();
        throw Exception('No session stored');
      }

      if (shouldRefreshSession(session)) {
        final freshSession = await refreshSession(session);
        return Success(freshSession);
      }

      return Success(session);
    } catch (e) {
      _iSessionRepository.clearSession();
      return Failure(e is Exception ? e : Exception(e.toString()));
    }
  }

  /// Logs the user out by invalidating their session on the backend and clearing local storage.
  Future<bool> logout() async {
    try {
      final session = await _iSessionRepository.getStoredSession();

      if (session != null) {
        await _iSessionRepository.logoutSession(session);
      }

      await _iSessionRepository.clearSession();

      logger.i('Logged out, see you later!');

      return true;
    } catch (e) {
      return false;
    }
  }
}

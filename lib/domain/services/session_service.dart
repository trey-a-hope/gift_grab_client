import 'package:gift_grab_client/core/logging.dart';
import 'package:gift_grab_client/domain/repositories/i_session_repository.dart';
import 'package:gift_grab_client/presentation/extensions/session_extensions.dart';
import 'package:nakama/nakama.dart';
import 'package:result_dart/result_dart.dart';

class SessionService {
  static const _hasExpiredDuration = Duration(minutes: 5);

  void Function()? _onUnauthenticated;

  final ISessionRepository _iSessionRepository;

  SessionService(this._iSessionRepository);

  Future<void> saveSession(Session session) async {
    logger.d('saveSession:${session.print()}');
    await _iSessionRepository.saveSession(session);
  }

  bool shouldRefreshSession(Session session) =>
      session.isExpired ||
      session.hasExpired(DateTime.now().add(_hasExpiredDuration));

  Future<Session> refreshSession(Session session) async {
    try {
      final newSession = await _iSessionRepository.refreshSession(session);
      await _iSessionRepository.saveSession(newSession);
      logger.d('refreshSession:${session.print()}');
      return newSession;
    } catch (e) {
      _iSessionRepository.clearSession();
      throw Exception('Failed to refresh session: $e');
    }
  }

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

      logger.d('getSession:${session.print()}');

      return Success(session);
    } catch (e) {
      _iSessionRepository.clearSession();
      return Failure(e is Exception ? e : Exception(e.toString()));
    }
  }

  Future<bool> logout() async {
    try {
      final session = await _iSessionRepository.getStoredSession();

      if (session != null) {
        await _iSessionRepository.logoutSession(session);
      }

      await _iSessionRepository.clearSession();

      logger.d('logged out, see you later!');

      return true;
    } catch (e) {
      return false;
    }
  }

  void setUnauthenticatedCallback(void Function() callback) =>
      _onUnauthenticated = callback;
}

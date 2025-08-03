import 'package:nakama/nakama.dart';

abstract class ISessionRepository {
  Future<Session?> getStoredSession();
  Future<void> saveSession(Session session);
  Future<void> clearSession();
  Future<Session> refreshSession(Session session);
  Future<void> logoutSession(Session session);
}

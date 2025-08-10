import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gift_grab_client/domain/repositories/i_session_repository.dart';
import 'package:nakama/nakama.dart';

class SessionRepository implements ISessionRepository {
  static const _tokenKey = 'nakama_token';
  static const _refreshTokenKey = 'nakama_refresh_token';

  final FlutterSecureStorage storage;
  final NakamaBaseClient client;

  SessionRepository(this.storage, this.client);

  @override
  Future<void> clearSession() async {
    try {
      await storage.delete(key: _tokenKey);
      await storage.delete(key: _refreshTokenKey);
    } catch (e) {
      throw Exception('Failed to clear tokens: $e');
    }
  }

  @override
  Future<Session?> getStoredSession() async {
    final token = await storage.read(key: _tokenKey);
    final refreshToken = await storage.read(key: _refreshTokenKey);

    if (token == null || refreshToken == null) return null;

    return Session.restore(
      token: token,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<void> logoutSession(Session session) async {
    try {
      await client.sessionLogout(session: session);
    } catch (e) {
      throw Exception('Failed to logout session: $e');
    }
  }

  @override
  Future<Session> refreshSession(Session session) async {
    try {
      return await client.sessionRefresh(session: session);
    } catch (e) {
      throw Exception('Failed to refresh session: $e');
    }
  }

  @override
  Future<void> saveSession(Session session) async {
    await storage.write(key: _tokenKey, value: session.token);
    await storage.write(key: _refreshTokenKey, value: session.refreshToken);
  }
}

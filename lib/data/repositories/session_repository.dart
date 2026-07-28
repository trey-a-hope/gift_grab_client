import 'package:hive/hive.dart';
import 'package:gift_grab_client/domain/repositories/i_session_repository.dart';
import 'package:nakama/nakama.dart';

class SessionRepository implements ISessionRepository {
  static const _boxName = 'session_box';
  static const _tokenKey = 'nakama_token';
  static const _refreshTokenKey = 'nakama_refresh_token';

  final NakamaBaseClient _client;

  late final Box _box;

  SessionRepository(this._client) {
    init();
  }

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  @override
  Future<void> clearSession() async {
    await _box.deleteAll([_tokenKey, _refreshTokenKey]);
  }

  @override
  Future<Session?> getStoredSession() async {
    final token = _box.get(_tokenKey);
    final refreshToken = _box.get(_refreshTokenKey);
    if (token == null || refreshToken == null) return null;
    return Session.restore(token: token, refreshToken: refreshToken);
  }

  @override
  Future<void> logoutSession(Session session) async {
    await _client.sessionLogout(session: session);
  }

  @override
  Future<Session> refreshSession(Session session) async {
    return await _client.sessionRefresh(session: session);
  }

  @override
  Future<void> saveSession(Session session) async {
    await _box.put(_tokenKey, session.token);
    await _box.put(_refreshTokenKey, session.refreshToken);
  }
}

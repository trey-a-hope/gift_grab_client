import 'package:gift_grab_client/domain/repositories/i_social_repository.dart';

class SocialAuthService {
  final ISocialAuthRepository _socialAuthRepository;
  SocialAuthService(this._socialAuthRepository);

  Future<String?> getGoogleToken() async {
    try {
      return await _socialAuthRepository.getGoogleToken();
    } catch (e) {
      throw Exception('Google authentication failed: $e');
    }
  }

  Future<String?> getAppleToken() async {
    try {
      return await _socialAuthRepository.getAppleToken();
    } catch (e) {
      throw Exception('Apple authentication failed: $e');
    }
  }
}

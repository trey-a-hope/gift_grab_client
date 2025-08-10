import 'package:gift_grab_client/domain/repositories/i_social_auth_repository.dart';

class SocialAuthService {
  final ISocialAuthRepository _iSocialAuthRepository;
  SocialAuthService(this._iSocialAuthRepository);

  Future<String?> getGoogleToken() async {
    try {
      return await _iSocialAuthRepository.getGoogleToken();
    } catch (e) {
      throw Exception('Google authentication failed: $e');
    }
  }

  Future<String?> getAppleToken() async {
    try {
      return await _iSocialAuthRepository.getAppleToken();
    } catch (e) {
      throw Exception('Apple authentication failed: $e');
    }
  }
}

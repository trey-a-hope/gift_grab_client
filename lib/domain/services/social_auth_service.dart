import 'dart:async';
import 'package:gift_grab_client/domain/repositories/i_social_auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialAuthService {
  final ISocialAuthRepository _iSocialAuthRepository;

  final GoogleSignIn _googleSignIn;
  GoogleSignIn get googleSignIn => _googleSignIn;

  SocialAuthService(this._iSocialAuthRepository, this._googleSignIn) {}

  Future<String?> getGoogleToken() async {
    try {
      return await _iSocialAuthRepository.getGoogleToken(_googleSignIn);
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

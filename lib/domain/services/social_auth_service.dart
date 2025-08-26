import 'dart:async';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/domain/repositories/i_social_auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialAuthService {
  final ISocialAuthRepository _iSocialAuthRepository;

  final _googleSignIn = GoogleSignIn.instance;

  SocialAuthService(this._iSocialAuthRepository) {
    _googleSignIn.initialize(clientId: Globals.googleClientIdWeb);
  }

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

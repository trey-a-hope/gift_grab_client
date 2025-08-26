import 'dart:async';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/domain/repositories/i_social_auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:universal_platform/universal_platform.dart';

class SocialAuthService {
  final ISocialAuthRepository _iSocialAuthRepository;

  final GoogleSignIn _googleSignIn;
  GoogleSignIn get googleSignIn => _googleSignIn;

  SocialAuthService(this._iSocialAuthRepository, this._googleSignIn) {
    final clientId = UniversalPlatform.isAndroid
        ? Globals.googleClientIdAndroid
        : (UniversalPlatform.isIOS || UniversalPlatform.isMacOS)
            ? Globals.googleClientIdIos
            : UniversalPlatform.isWeb
                ? Globals.googleClientIdWeb
                : null;

    // ServerClientId not needed for web
    final serverClientId =
        UniversalPlatform.isWeb ? null : Globals.googleClientIdWeb;

    unawaited(
      _googleSignIn
          .initialize(clientId: clientId, serverClientId: serverClientId)
          .then((_) {}),
    );
  }

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

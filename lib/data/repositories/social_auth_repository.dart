import 'package:gift_grab_client/domain/repositories/i_social_auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialAuthRepository implements ISocialAuthRepository {
  @override
  Future<String?> getGoogleToken() async {
    try {
      final googleSignInAccount = await GoogleSignIn.instance.authenticate(
        scopeHint: [
          'email',
          'https://www.googleapis.com/auth/contacts.readonly',
        ],
      );

      return googleSignInAccount.authentication.idToken;
    } on GoogleSignInException catch (e) {
      switch (e.code) {
        case GoogleSignInExceptionCode.unknownError:
        case GoogleSignInExceptionCode.interrupted:
        case GoogleSignInExceptionCode.clientConfigurationError:
        case GoogleSignInExceptionCode.providerConfigurationError:
        case GoogleSignInExceptionCode.uiUnavailable:
        case GoogleSignInExceptionCode.userMismatch:
          rethrow;
        case GoogleSignInExceptionCode.canceled:
          return null;
      }
    }
  }

  @override
  Future<String?> getAppleToken() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      return credential.identityToken;
    } on SignInWithAppleException catch (e) {
      if (e.toString().contains('canceled')) {
        return null;
      }

      rethrow;
    }
  }
}

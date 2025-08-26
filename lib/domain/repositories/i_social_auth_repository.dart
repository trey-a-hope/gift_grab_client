import 'package:google_sign_in/google_sign_in.dart';

abstract class ISocialAuthRepository {
  Future<String?> getGoogleToken(GoogleSignIn gsi);
  Future<String?> getAppleToken();
}

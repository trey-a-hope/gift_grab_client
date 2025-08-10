abstract class ISocialAuthRepository {
  Future<String?> getGoogleToken();
  Future<String?> getAppleToken();
}

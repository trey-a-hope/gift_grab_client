import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/domain/services/social_auth_service.dart';
import 'package:gift_grab_client/presentation/blocs/account_update/account_update.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nakama/nakama.dart';

class MockNakamaBaseClient extends Mock implements NakamaBaseClient {}

class MockSessionService extends Mock implements SessionService {}

class MockSocialAuthService extends Mock implements SocialAuthService {}

class MockSession extends Mock implements Session {}

class MockAccount extends Mock implements Account {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    AccountUpdateBloc,
    () {
      late MockSessionService mockSessionService;
      late MockNakamaBaseClient mockNakamaBaseClient;
      late MockSocialAuthService mockSocialAuthService;
      late MockAccount mockAccount;

      final mockSession = Session(
        token: 'session_token',
        refreshToken: 'refresh_token',
        created: true,
        vars: {},
        userId: 'user_123',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        refreshExpiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      setUp(() {
        mockSessionService = MockSessionService();
        mockNakamaBaseClient = MockNakamaBaseClient();
        mockSocialAuthService = MockSocialAuthService();
        mockAccount = MockAccount();

        FlutterSecureStorage.setMockInitialValues({});
      });

      group('UpdateAccount', () {
        blocTest<AccountUpdateBloc, AccountUpdateState>(
          'emits loading state then success state when updating account',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenAnswer((_) async => mockSession);

            when(() => mockNakamaBaseClient.updateAccount(
                  session: mockSession,
                  username: 'newUsername',
                )).thenAnswer((_) async {});
          },
          build: () => AccountUpdateBloc(
            mockAccount,
            mockSessionService,
            mockNakamaBaseClient,
            mockSocialAuthService,
          ),
          seed: () => const AccountUpdateState(),
          act: (bloc) => bloc.add(const UpdateAccount('newUsername')),
          expect: () => [
            const AccountUpdateState(
              isLoading: true,
            ),
            const AccountUpdateState(
              success: 'Account updated successfully',
              isLoading: false,
              error: null,
            ),
          ],
        );
      });

      group('LinkEmail', () {
        blocTest<AccountUpdateBloc, AccountUpdateState>(
          'emits loading state then success state when linking email',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenAnswer((_) async => mockSession);

            when(() => mockNakamaBaseClient.linkEmail(
                  session: mockSession,
                  email: 'test@example.com',
                  password: 'password123',
                )).thenAnswer((_) async {});
          },
          build: () => AccountUpdateBloc(
            mockAccount,
            mockSessionService,
            mockNakamaBaseClient,
            mockSocialAuthService,
          ),
          seed: () => const AccountUpdateState(),
          act: (bloc) => bloc.add(const LinkEmail(
            'test@example.com',
            'password123',
          )),
          expect: () => [
            const AccountUpdateState(
              isLoading: true,
            ),
            const AccountUpdateState(
              success: 'Email linked successfully',
              isLoading: false,
              error: null,
            ),
          ],
        );
      });

      group('UnlinkEmail', () {
        blocTest<AccountUpdateBloc, AccountUpdateState>(
          'emits loading state then success state when unlinking email',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenAnswer((_) async => mockSession);

            when(() => mockAccount.email).thenReturn('test@example.com');

            when(() => mockNakamaBaseClient.unlinkEmail(
                  session: mockSession,
                  email: 'test@example.com',
                  password: '',
                )).thenAnswer((_) async {});
          },
          build: () => AccountUpdateBloc(
            mockAccount,
            mockSessionService,
            mockNakamaBaseClient,
            mockSocialAuthService,
          ),
          seed: () => const AccountUpdateState(),
          act: (bloc) => bloc.add(const UnlinkEmail()),
          expect: () => [
            const AccountUpdateState(
              isLoading: true,
            ),
            const AccountUpdateState(
              success: 'Email unlinked successfully',
              isLoading: false,
              error: null,
            ),
          ],
        );

        blocTest<AccountUpdateBloc, AccountUpdateState>(
          'throws exception when account email is null',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenAnswer((_) async => mockSession);

            when(() => mockAccount.email).thenReturn(null);
          },
          build: () => AccountUpdateBloc(
            mockAccount,
            mockSessionService,
            mockNakamaBaseClient,
            mockSocialAuthService,
          ),
          seed: () => const AccountUpdateState(),
          act: (bloc) => bloc.add(const UnlinkEmail()),
          expect: () => [
            const AccountUpdateState(
              isLoading: true,
            ),
            // The error will be handled by runWithErrorHandling
            const AccountUpdateState(
              error: 'Unexpected error: Exception: Account email is null',
              isLoading: false,
            ),
          ],
        );
      });

      group('LinkGoogle', () {
        blocTest<AccountUpdateBloc, AccountUpdateState>(
          'emits loading state then success state when linking Google',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenAnswer((_) async => mockSession);

            when(() => mockSocialAuthService.getGoogleToken())
                .thenAnswer((_) async => 'google_token');

            when(() => mockNakamaBaseClient.linkGoogle(
                  session: mockSession,
                  token: 'google_token',
                )).thenAnswer((_) async {});
          },
          build: () => AccountUpdateBloc(
            mockAccount,
            mockSessionService,
            mockNakamaBaseClient,
            mockSocialAuthService,
          ),
          seed: () => const AccountUpdateState(),
          act: (bloc) => bloc.add(const LinkGoogle()),
          expect: () => [
            const AccountUpdateState(
              isLoading: true,
            ),
            const AccountUpdateState(
              success: 'Google account linked successfully',
              isLoading: false,
              error: null,
            ),
          ],
        );

        blocTest<AccountUpdateBloc, AccountUpdateState>(
          'emits loading state then resets when Google token is null',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenAnswer((_) async => mockSession);

            when(() => mockSocialAuthService.getGoogleToken())
                .thenAnswer((_) async => null);
          },
          build: () => AccountUpdateBloc(
            mockAccount,
            mockSessionService,
            mockNakamaBaseClient,
            mockSocialAuthService,
          ),
          seed: () => const AccountUpdateState(),
          act: (bloc) => bloc.add(const LinkGoogle()),
          expect: () => [
            const AccountUpdateState(
              isLoading: true,
            ),
            const AccountUpdateState(
              isLoading: false,
              error: null,
            ),
          ],
        );
      });

      group('UnlinkGoogle', () {
        blocTest<AccountUpdateBloc, AccountUpdateState>(
          'emits loading state then success state when unlinking Google',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenAnswer((_) async => mockSession);

            when(() => mockSocialAuthService.getGoogleToken())
                .thenAnswer((_) async => 'google_token');

            when(() => mockNakamaBaseClient.unlinkGoogle(
                  session: mockSession,
                  token: 'google_token',
                )).thenAnswer((_) async {});
          },
          build: () => AccountUpdateBloc(
            mockAccount,
            mockSessionService,
            mockNakamaBaseClient,
            mockSocialAuthService,
          ),
          seed: () => const AccountUpdateState(),
          act: (bloc) => bloc.add(const UnlinkGoogle()),
          expect: () => [
            const AccountUpdateState(
              isLoading: true,
            ),
            const AccountUpdateState(
              success: 'Google account unlinked successfully',
              isLoading: false,
              error: null,
            ),
          ],
        );

        blocTest<AccountUpdateBloc, AccountUpdateState>(
          'emits loading state then resets when Google token is null',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenAnswer((_) async => mockSession);

            when(() => mockSocialAuthService.getGoogleToken())
                .thenAnswer((_) async => null);
          },
          build: () => AccountUpdateBloc(
            mockAccount,
            mockSessionService,
            mockNakamaBaseClient,
            mockSocialAuthService,
          ),
          seed: () => const AccountUpdateState(),
          act: (bloc) => bloc.add(const UnlinkGoogle()),
          expect: () => [
            const AccountUpdateState(
              isLoading: true,
            ),
            const AccountUpdateState(
              isLoading: false,
              error: null,
            ),
          ],
        );
      });

      group('LinkApple', () {
        blocTest<AccountUpdateBloc, AccountUpdateState>(
          'emits loading state then success state when linking Apple',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenAnswer((_) async => mockSession);

            when(() => mockSocialAuthService.getAppleToken())
                .thenAnswer((_) async => 'apple_token');

            when(() => mockNakamaBaseClient.linkApple(
                  session: mockSession,
                  token: 'apple_token',
                )).thenAnswer((_) async {});
          },
          build: () => AccountUpdateBloc(
            mockAccount,
            mockSessionService,
            mockNakamaBaseClient,
            mockSocialAuthService,
          ),
          seed: () => const AccountUpdateState(),
          act: (bloc) => bloc.add(const LinkApple()),
          expect: () => [
            const AccountUpdateState(
              isLoading: true,
            ),
            const AccountUpdateState(
              success: 'Apple account linked successfully',
              isLoading: false,
              error: null,
            ),
          ],
        );

        blocTest<AccountUpdateBloc, AccountUpdateState>(
          'emits loading state then resets when Apple token is null',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenAnswer((_) async => mockSession);

            when(() => mockSocialAuthService.getAppleToken())
                .thenAnswer((_) async => null);
          },
          build: () => AccountUpdateBloc(
            mockAccount,
            mockSessionService,
            mockNakamaBaseClient,
            mockSocialAuthService,
          ),
          seed: () => const AccountUpdateState(),
          act: (bloc) => bloc.add(const LinkApple()),
          expect: () => [
            const AccountUpdateState(
              isLoading: true,
            ),
            const AccountUpdateState(
              isLoading: false,
              error: null,
            ),
          ],
        );
      });

      group('UnlinkApple', () {
        blocTest<AccountUpdateBloc, AccountUpdateState>(
          'emits loading state then success state when unlinking Apple',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenAnswer((_) async => mockSession);

            when(() => mockSocialAuthService.getAppleToken())
                .thenAnswer((_) async => 'apple_token');

            when(() => mockNakamaBaseClient.unlinkApple(
                  session: mockSession,
                  token: 'apple_token',
                )).thenAnswer((_) async {});
          },
          build: () => AccountUpdateBloc(
            mockAccount,
            mockSessionService,
            mockNakamaBaseClient,
            mockSocialAuthService,
          ),
          seed: () => const AccountUpdateState(),
          act: (bloc) => bloc.add(const UnlinkApple()),
          expect: () => [
            const AccountUpdateState(
              isLoading: true,
            ),
            const AccountUpdateState(
              success: 'Apple account unlinked successfully',
              isLoading: false,
              error: null,
            ),
          ],
        );

        blocTest<AccountUpdateBloc, AccountUpdateState>(
          'emits loading state then resets when Apple token is null',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenAnswer((_) async => mockSession);

            when(() => mockSocialAuthService.getAppleToken())
                .thenAnswer((_) async => null);
          },
          build: () => AccountUpdateBloc(
            mockAccount,
            mockSessionService,
            mockNakamaBaseClient,
            mockSocialAuthService,
          ),
          seed: () => const AccountUpdateState(),
          act: (bloc) => bloc.add(const UnlinkApple()),
          expect: () => [
            const AccountUpdateState(
              isLoading: true,
            ),
            const AccountUpdateState(
              isLoading: false,
              error: null,
            ),
          ],
        );
      });
    },
  );
}

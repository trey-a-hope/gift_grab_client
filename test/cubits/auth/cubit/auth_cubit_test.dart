import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/enums/login_error_exclusions.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/domain/services/social_auth_service.dart';
import 'package:gift_grab_client/presentation/cubits/auth/auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nakama/nakama.dart';

class MockNakamaBaseClient extends Mock implements NakamaBaseClient {}

class MockSessionService extends Mock implements SessionService {}

class MockSocialAuthService extends Mock implements SocialAuthService {}

class MockSession extends Mock implements Session {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(AuthCubit, () {
    late MockNakamaBaseClient mockNakamaBaseClient;
    late MockSessionService mockSessionService;
    late MockSocialAuthService mockSocialAuthService;
    late MockGoogleSignIn mockGoogleSignIn;
    late StreamController<GoogleSignInAuthenticationEvent> authEventsController;

    const mockEmail = 'johndoe@gmail.com';
    const mockPassword = 'password';
    const mockUsername = 'johndoe';
    const mockGoogleToken = 'google_token_123';
    const mockAppleToken = 'apple_token_123';

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
      FlutterSecureStorage.setMockInitialValues({});

      mockNakamaBaseClient = MockNakamaBaseClient();
      mockSessionService = MockSessionService();
      mockSocialAuthService = MockSocialAuthService();
      mockGoogleSignIn = MockGoogleSignIn();

      authEventsController =
          StreamController<GoogleSignInAuthenticationEvent>();

      when(() => mockSocialAuthService.googleSignIn)
          .thenReturn(mockGoogleSignIn);

      when(() => mockGoogleSignIn.authenticationEvents)
          .thenAnswer((_) => authEventsController.stream);

      when(() => mockGoogleSignIn.initialize(
            clientId: any(named: 'clientId'),
            serverClientId: any(named: 'serverClientId'),
          )).thenAnswer((_) async => {});

      registerFallbackValue(mockSession);
    });

    group('logout', () {
      blocTest<AuthCubit, AuthState>(
        'should emit authenticated false when logout succeeds',
        setUp: () {
          when(() => mockSocialAuthService.googleSignIn)
              .thenReturn(mockGoogleSignIn);

          when(() => mockGoogleSignIn.authenticationEvents)
              .thenAnswer((_) => authEventsController.stream);

          when(() => mockGoogleSignIn.initialize(
                clientId: any(named: 'clientId'),
                serverClientId: any(named: 'serverClientId'),
              )).thenAnswer((_) async => {});

          when(() => mockSessionService.logout()).thenAnswer((_) async => true);
        },
        build: () => AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        ),
        seed: () => const AuthState(
          authenticated: true,
          isLoading: false,
          error: null,
        ),
        act: (cubit) => cubit.logout(),
        expect: () => [
          const AuthState(
            authenticated: true,
            isLoading: true,
            error: null,
          ),
          const AuthState(
            authenticated: false,
            isLoading: false,
            error: null,
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'should emit error when logout fails',
        setUp: () {
          when(() => mockSessionService.logout())
              .thenThrow(Exception('Logout failed'));
        },
        build: () => AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        ),
        seed: () => const AuthState(
          authenticated: true,
          isLoading: false,
          error: null,
        ),
        act: (cubit) => cubit.logout(),
        expect: () => [
          const AuthState(
            authenticated: true,
            isLoading: true,
            error: null,
          ),
          const AuthState(
            authenticated: true,
            isLoading: false,
            error: 'Exception: Logout failed',
          ),
        ],
      );
    });

    group('login email', () {
      blocTest<AuthCubit, AuthState>(
        'should emit authenticated true when login succeeds',
        setUp: () {
          when(() => mockNakamaBaseClient.authenticateEmail(
                password: mockPassword,
                email: mockEmail,
              )).thenAnswer((_) async => mockSession);

          when(() => mockSessionService.saveSession(mockSession))
              .thenAnswer((_) async => null);
        },
        build: () => AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        ),
        seed: () => const AuthState(
          authenticated: false,
          isLoading: false,
          error: null,
        ),
        act: (cubit) => cubit.loginEmail(mockEmail, mockPassword),
        expect: () => [
          const AuthState(
            authenticated: false,
            isLoading: true,
            error: null,
          ),
          const AuthState(
            authenticated: true,
            isLoading: false,
            error: null,
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'should emit error when authentication fails',
        setUp: () {
          when(() => mockNakamaBaseClient.authenticateEmail(
                password: mockPassword,
                email: mockEmail,
              )).thenThrow(Exception('Invalid credentials'));
        },
        build: () => AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        ),
        seed: () => const AuthState(
          authenticated: false,
          isLoading: false,
          error: null,
        ),
        act: (cubit) => cubit.loginEmail(mockEmail, mockPassword),
        expect: () => [
          const AuthState(
            authenticated: false,
            isLoading: true,
            error: null,
          ),
          const AuthState(
            authenticated: false,
            isLoading: false,
            error: 'Exception: Invalid credentials',
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'should emit error when session save fails',
        setUp: () {
          when(() => mockNakamaBaseClient.authenticateEmail(
                password: mockPassword,
                email: mockEmail,
              )).thenAnswer((_) async => mockSession);

          when(() => mockSessionService.saveSession(mockSession))
              .thenThrow(Exception('Failed to save session'));
        },
        build: () => AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        ),
        seed: () => const AuthState(
          authenticated: false,
          isLoading: false,
          error: null,
        ),
        act: (cubit) => cubit.loginEmail(mockEmail, mockPassword),
        expect: () => [
          const AuthState(
            authenticated: false,
            isLoading: true,
            error: null,
          ),
          const AuthState(
            authenticated: false,
            isLoading: false,
            error: 'Exception: Failed to save session',
          ),
        ],
      );
    });

    group('signup', () {
      blocTest<AuthCubit, AuthState>(
        'should emit authenticated true when signup succeeds',
        setUp: () {
          when(() => mockNakamaBaseClient.authenticateEmail(
                password: mockPassword,
                email: mockEmail,
                username: mockUsername,
                create: true,
              )).thenAnswer((_) async => mockSession);

          when(() => mockSessionService.saveSession(mockSession))
              .thenAnswer((_) async => null);
        },
        build: () => AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        ),
        seed: () => const AuthState(
          authenticated: false,
          isLoading: false,
          error: null,
        ),
        act: (cubit) => cubit.signup(mockEmail, mockPassword, mockUsername),
        expect: () => [
          const AuthState(
            authenticated: false,
            isLoading: true,
            error: null,
          ),
          const AuthState(
            authenticated: true,
            isLoading: false,
            error: null,
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'should emit error when signup fails',
        setUp: () {
          when(() => mockNakamaBaseClient.authenticateEmail(
                password: mockPassword,
                email: mockEmail,
                username: mockUsername,
                create: true,
              )).thenThrow(Exception('User already exists'));
        },
        build: () => AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        ),
        seed: () => const AuthState(
          authenticated: false,
          isLoading: false,
          error: null,
        ),
        act: (cubit) => cubit.signup(mockEmail, mockPassword, mockUsername),
        expect: () => [
          const AuthState(
            authenticated: false,
            isLoading: true,
            error: null,
          ),
          const AuthState(
            authenticated: false,
            isLoading: false,
            error: 'Exception: User already exists',
          ),
        ],
      );
    });

    group('checkAuthStatus', () {
      blocTest<AuthCubit, AuthState>(
        'should emit authenticated true when session is valid and does not need refresh',
        setUp: () {
          when(() => mockSessionService.getSession())
              .thenAnswer((_) async => mockSession);

          when(() => mockSessionService.shouldRefreshSession(mockSession))
              .thenReturn(false);
        },
        build: () => AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        ),
        seed: () => const AuthState(
          authenticated: false,
          isLoading: false,
          error: null,
        ),
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          const AuthState(
            authenticated: false,
            isLoading: true,
            error: null,
          ),
          const AuthState(
            authenticated: true,
            isLoading: false,
            error: null,
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'should emit authenticated true when session needs refresh and refresh succeeds',
        setUp: () {
          when(() => mockSessionService.getSession())
              .thenAnswer((_) async => mockSession);

          when(() => mockSessionService.shouldRefreshSession(mockSession))
              .thenReturn(true);

          when(() => mockSessionService.refreshSession(mockSession))
              .thenAnswer((_) async => mockSession);
        },
        build: () => AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        ),
        seed: () => const AuthState(
          authenticated: false,
          isLoading: false,
          error: null,
        ),
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          const AuthState(
            authenticated: false,
            isLoading: true,
            error: null,
          ),
          const AuthState(
            authenticated: true,
            isLoading: false,
            error: null,
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'should emit error when getSession fails',
        setUp: () {
          when(() => mockSessionService.getSession())
              .thenThrow(Exception('No session found'));
        },
        build: () => AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        ),
        seed: () => const AuthState(
          authenticated: false,
          isLoading: false,
          error: null,
        ),
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          const AuthState(
            authenticated: false,
            isLoading: true,
            error: null,
          ),
          const AuthState(
            authenticated: false,
            isLoading: false,
            error: 'Exception: No session found',
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'should emit error when refreshSession fails',
        setUp: () {
          when(() => mockSessionService.getSession())
              .thenAnswer((_) async => mockSession);

          when(() => mockSessionService.shouldRefreshSession(mockSession))
              .thenReturn(true);

          when(() => mockSessionService.refreshSession(mockSession))
              .thenThrow(Exception('Refresh failed'));
        },
        build: () => AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        ),
        seed: () => const AuthState(
          authenticated: false,
          isLoading: false,
          error: null,
        ),
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          const AuthState(
            authenticated: false,
            isLoading: true,
            error: null,
          ),
          const AuthState(
            authenticated: false,
            isLoading: false,
            error: 'Exception: Refresh failed',
          ),
        ],
      );
    });

    group('loginGoogle', () {
      blocTest<AuthCubit, AuthState>(
        'should emit authenticated true when Google login succeeds',
        setUp: () {
          when(() => mockSocialAuthService.getGoogleToken())
              .thenAnswer((_) async => mockGoogleToken);

          when(() => mockNakamaBaseClient.authenticateGoogle(
              token: mockGoogleToken)).thenAnswer((_) async => mockSession);

          when(() => mockSessionService.saveSession(mockSession))
              .thenAnswer((_) async => null);
        },
        build: () => AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        ),
        seed: () => const AuthState(
          authenticated: false,
          isLoading: false,
          error: null,
        ),
        act: (cubit) => cubit.loginGoogle(),
        expect: () => [
          const AuthState(
            authenticated: false,
            isLoading: true,
            error: null,
          ),
          const AuthState(
            authenticated: true,
            isLoading: false,
            error: null,
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'should emit default state when Google login is canceled',
        setUp: () {
          when(() => mockSocialAuthService.getGoogleToken())
              .thenAnswer((_) async => null);
        },
        build: () => AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        ),
        seed: () => const AuthState(
          authenticated: false,
          isLoading: false,
          error: null,
        ),
        act: (cubit) => cubit.loginGoogle(),
        expect: () => [
          const AuthState(
            authenticated: false,
            isLoading: true,
            error: null,
          ),
          const AuthState(
            authenticated: false,
            isLoading: false,
            error: null,
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'should emit error when Google authentication fails',
        setUp: () {
          when(() => mockSocialAuthService.getGoogleToken())
              .thenAnswer((_) async => mockGoogleToken);

          when(() => mockNakamaBaseClient.authenticateGoogle(
                  token: mockGoogleToken))
              .thenThrow(Exception('Google auth failed'));
        },
        build: () => AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        ),
        seed: () => const AuthState(
          authenticated: false,
          isLoading: false,
          error: null,
        ),
        act: (cubit) => cubit.loginGoogle(),
        expect: () => [
          const AuthState(
            authenticated: false,
            isLoading: true,
            error: null,
          ),
          const AuthState(
            authenticated: false,
            isLoading: false,
            error: 'Exception: Google auth failed',
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'should emit error when getGoogleToken throws exception',
        setUp: () {
          when(() => mockSocialAuthService.getGoogleToken())
              .thenThrow(Exception('Google sign in failed'));
        },
        build: () => AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        ),
        seed: () => const AuthState(
          authenticated: false,
          isLoading: false,
          error: null,
        ),
        act: (cubit) => cubit.loginGoogle(),
        expect: () => [
          const AuthState(
            authenticated: false,
            isLoading: true,
            error: null,
          ),
          const AuthState(
            authenticated: false,
            isLoading: false,
            error: 'Exception: Google sign in failed',
          ),
        ],
      );
    });

    group('loginApple', () {
      blocTest<AuthCubit, AuthState>(
        'should emit authenticated true when Apple login succeeds',
        setUp: () {
          when(() => mockSocialAuthService.getAppleToken())
              .thenAnswer((_) async => mockAppleToken);

          when(() =>
                  mockNakamaBaseClient.authenticateApple(token: mockAppleToken))
              .thenAnswer((_) async => mockSession);

          when(() => mockSessionService.saveSession(mockSession))
              .thenAnswer((_) async => null);
        },
        build: () => AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        ),
        seed: () => const AuthState(
          authenticated: false,
          isLoading: false,
          error: null,
        ),
        act: (cubit) => cubit.loginApple(),
        expect: () => [
          const AuthState(
            authenticated: false,
            isLoading: true,
            error: null,
          ),
          const AuthState(
            authenticated: true,
            isLoading: false,
            error: null,
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'should emit default state when Apple login is canceled',
        setUp: () {
          when(() => mockSocialAuthService.getAppleToken())
              .thenAnswer((_) async => null);
        },
        build: () => AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        ),
        seed: () => const AuthState(
          authenticated: false,
          isLoading: false,
          error: null,
        ),
        act: (cubit) => cubit.loginApple(),
        expect: () => [
          const AuthState(
            authenticated: false,
            isLoading: true,
            error: null,
          ),
          const AuthState(
            authenticated: false,
            isLoading: false,
            error: null,
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'should emit error when Apple authentication fails',
        setUp: () {
          when(() => mockSocialAuthService.getAppleToken())
              .thenAnswer((_) async => mockAppleToken);

          when(() =>
                  mockNakamaBaseClient.authenticateApple(token: mockAppleToken))
              .thenThrow(Exception('Apple auth failed'));
        },
        build: () => AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        ),
        seed: () => const AuthState(
          authenticated: false,
          isLoading: false,
          error: null,
        ),
        act: (cubit) => cubit.loginApple(),
        expect: () => [
          const AuthState(
            authenticated: false,
            isLoading: true,
            error: null,
          ),
          const AuthState(
            authenticated: false,
            isLoading: false,
            error: 'Exception: Apple auth failed',
          ),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'should emit error when getAppleToken throws exception',
        setUp: () {
          when(() => mockSocialAuthService.getAppleToken())
              .thenThrow(Exception('Apple sign in failed'));
        },
        build: () => AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        ),
        seed: () => const AuthState(
          authenticated: false,
          isLoading: false,
          error: null,
        ),
        act: (cubit) => cubit.loginApple(),
        expect: () => [
          const AuthState(
            authenticated: false,
            isLoading: true,
            error: null,
          ),
          const AuthState(
            authenticated: false,
            isLoading: false,
            error: 'Exception: Apple sign in failed',
          ),
        ],
      );
    });

    group('return values', () {
      test('loginEmail should return null on success', () async {
        // Setup
        when(() => mockNakamaBaseClient.authenticateEmail(
              password: mockPassword,
              email: mockEmail,
            )).thenAnswer((_) async => mockSession);

        when(() => mockSessionService.saveSession(mockSession))
            .thenAnswer((_) async => null);

        final cubit = AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        );

        // Act
        final result = await cubit.loginEmail(mockEmail, mockPassword);

        // Assert
        expect(result, isNull);
      });

      test('loginEmail should return error string on failure', () async {
        // Setup
        when(() => mockNakamaBaseClient.authenticateEmail(
              password: mockPassword,
              email: mockEmail,
            )).thenThrow(Exception('Login failed'));

        final cubit = AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        );

        // Act
        final result = await cubit.loginEmail(mockEmail, mockPassword);

        // Assert
        expect(result, equals('Exception: Login failed'));
      });

      test('signup should return null on success', () async {
        // Setup
        when(() => mockNakamaBaseClient.authenticateEmail(
              password: mockPassword,
              email: mockEmail,
              username: mockUsername,
              create: true,
            )).thenAnswer((_) async => mockSession);

        when(() => mockSessionService.saveSession(mockSession))
            .thenAnswer((_) async => null);

        final cubit = AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        );

        // Act
        final result =
            await cubit.signup(mockEmail, mockPassword, mockUsername);

        // Assert
        expect(result, isNull);
      });

      test('signup should return error string on failure', () async {
        // Setup
        when(() => mockNakamaBaseClient.authenticateEmail(
              password: mockPassword,
              email: mockEmail,
              username: mockUsername,
              create: true,
            )).thenThrow(Exception('Signup failed'));

        final cubit = AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        );

        // Act
        final result =
            await cubit.signup(mockEmail, mockPassword, mockUsername);

        // Assert
        expect(result, equals('Exception: Signup failed'));
      });

      test('loginGoogle should return null on success', () async {
        // Setup
        when(() => mockSocialAuthService.getGoogleToken())
            .thenAnswer((_) async => mockGoogleToken);

        when(() =>
                mockNakamaBaseClient.authenticateGoogle(token: mockGoogleToken))
            .thenAnswer((_) async => mockSession);

        when(() => mockSessionService.saveSession(mockSession))
            .thenAnswer((_) async => null);

        final cubit = AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        );

        // Act
        final result = await cubit.loginGoogle();

        // Assert
        expect(result, isNull);
      });

      test('loginGoogle should return CANCELED when token is null', () async {
        // Setup
        when(() => mockSocialAuthService.getGoogleToken())
            .thenAnswer((_) async => null);

        final cubit = AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        );

        // Act
        final result = await cubit.loginGoogle();

        // Assert
        expect(result, equals(LoginErrorExclusions.CANCELED.id));
      });

      test('loginApple should return null on success', () async {
        // Setup
        when(() => mockSocialAuthService.getAppleToken())
            .thenAnswer((_) async => mockAppleToken);

        when(() =>
                mockNakamaBaseClient.authenticateApple(token: mockAppleToken))
            .thenAnswer((_) async => mockSession);

        when(() => mockSessionService.saveSession(mockSession))
            .thenAnswer((_) async => null);

        final cubit = AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        );

        // Act
        final result = await cubit.loginApple();

        // Assert
        expect(result, isNull);
      });

      test('loginApple should return CANCELED when token is null', () async {
        // Setup
        when(() => mockSocialAuthService.getAppleToken())
            .thenAnswer((_) async => null);

        final cubit = AuthCubit(
          mockNakamaBaseClient,
          mockSessionService,
          mockSocialAuthService,
        );

        // Act
        final result = await cubit.loginApple();

        // Assert
        expect(result, equals(LoginErrorExclusions.CANCELED.id));
      });
    });
  });
}

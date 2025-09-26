import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/feedback_messages.dart';
import 'package:gift_grab_client/data/enums/rpc_functions.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/domain/services/social_auth_service.dart';
import 'package:gift_grab_client/presentation/blocs/account_delete/account_delete.dart';
import 'package:gift_grab_client/presentation/cubits/auth/auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nakama/nakama.dart';

class MockNakamaBaseClient extends Mock implements NakamaBaseClient {}

class MockSessionService extends Mock implements SessionService {}

class MockSocialAuthService extends Mock implements SocialAuthService {}

class MockSession extends Mock implements Session {}

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    AccountDeleteBloc,
    () {
      late MockAuthCubit mockAuthCubit;
      late MockSessionService mockSessionService;
      late MockNakamaBaseClient mockNakamaBaseClient;

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
        mockAuthCubit = MockAuthCubit();
        mockSessionService = MockSessionService();
        mockNakamaBaseClient = MockNakamaBaseClient();

        FlutterSecureStorage.setMockInitialValues({});
      });

      group(const DeleteAccount(), () {
        blocTest<AccountDeleteBloc, AccountDeleteState>(
          '',
          setUp: () {
            when(() => mockNakamaBaseClient.rpc(
                  session: mockSession,
                  id: RpcFunctions.ACCOUNT_DELETE.id,
                )).thenAnswer((_) async => null);

            when(() => mockSessionService.getSession())
                .thenAnswer((_) async => mockSession);

            when(() => mockAuthCubit.logout()).thenAnswer((_) async {});
          },
          build: () => AccountDeleteBloc(
            mockAuthCubit,
            mockSessionService,
            mockNakamaBaseClient,
          ),
          seed: () => const AccountDeleteState(
            isLoading: true,
          ),
          act: (bloc) => bloc.add(const DeleteAccount()),
          expect: () => [
            const AccountDeleteState(
              success: FeedbackMessages.accountDeleteSuccess,
              isLoading: false,
              error: null,
            ),
          ],
        );
      });
    },
  );
}

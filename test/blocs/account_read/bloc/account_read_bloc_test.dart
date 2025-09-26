import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/account_read/account_read.dart';
import 'package:gift_grab_client/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nakama/nakama.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

class MockNakamaBaseClient extends Mock implements NakamaBaseClient {}

class MockSessionService extends Mock implements SessionService {}

class MockSession extends Mock implements Session {}

class MockAccount extends Mock implements Account {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    AccountReadBloc,
    () {
      late MockSessionService mockSessionService;
      late MockNakamaBaseClient mockNakamaBaseClient;
      late MockAuthCubit mockAuthCubit;

      final mockSession = Session(
        token: 'session_token',
        refreshToken: 'refresh_token',
        created: true,
        vars: {},
        userId: 'user_123',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        refreshExpiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      final mockAccount = MockAccount();

      setUp(() {
        mockSessionService = MockSessionService();
        mockNakamaBaseClient = MockNakamaBaseClient();
        mockAuthCubit = MockAuthCubit();

        FlutterSecureStorage.setMockInitialValues({});
      });

      group(const ReadAccount(), () {
        blocTest<AccountReadBloc, AccountReadState>(
          'emits loading state then success state with account',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenAnswer((_) async => mockSession);

            when(() => mockNakamaBaseClient.getAccount(mockSession))
                .thenAnswer((_) async => mockAccount);
          },
          build: () => AccountReadBloc(
            mockAuthCubit,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          seed: () => const AccountReadState(),
          act: (bloc) => bloc.add(const ReadAccount()),
          expect: () => [
            const AccountReadState(
              isLoading: true,
            ),
            AccountReadState(
              account: mockAccount,
              isLoading: false,
              error: null,
            ),
          ],
        );
      });
    },
  );
}

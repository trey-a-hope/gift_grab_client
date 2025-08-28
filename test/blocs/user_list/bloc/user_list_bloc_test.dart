import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/user_list/user_list.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nakama/nakama.dart';

class MockNakamaBaseClient extends Mock implements NakamaBaseClient {}

class MockSessionService extends Mock implements SessionService {}

class MockSession extends Mock implements Session {}

class MockUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    UserListBloc,
    () {
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

      final mockUser = MockUser();
      final mockUsers = [mockUser];

      setUp(() {
        mockSessionService = MockSessionService();
        mockNakamaBaseClient = MockNakamaBaseClient();

        FlutterSecureStorage.setMockInitialValues({});
      });

      group(SearchUser, () {
        blocTest<UserListBloc, UserListState>(
          'emits loading state then success state with users when searching',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenAnswer((_) async => mockSession);

            when(() => mockNakamaBaseClient.getUsers(
                  session: mockSession,
                  ids: [],
                  usernames: ['testUser'],
                )).thenAnswer((_) async => mockUsers);
          },
          build: () => UserListBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          seed: () => const UserListState(),
          act: (bloc) => bloc.add(const SearchUser('testUser')),
          expect: () => [
            const UserListState(
              isLoading: true,
            ),
            UserListState(
              query: 'testUser',
              users: mockUsers,
              isLoading: false,
              error: null,
            ),
          ],
        );
      });

      group(ClearSearch, () {
        blocTest<UserListBloc, UserListState>(
          'clears query and users when clearing search',
          build: () => UserListBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          seed: () => UserListState(
            query: 'previousQuery',
            users: mockUsers,
            isLoading: false,
            error: null,
          ),
          act: (bloc) => bloc.add(const ClearSearch()),
          expect: () => [
            const UserListState(
              query: '',
              users: [],
              isLoading: false,
              error: null,
            ),
          ],
        );
      });
    },
  );
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/user_read/user_read.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nakama/nakama.dart';

class MockNakamaBaseClient extends Mock implements NakamaBaseClient {}

class MockSessionService extends Mock implements SessionService {}

class MockSession extends Mock implements Session {}

class MockUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    UserReadBloc,
    () {
      late MockSessionService mockSessionService;
      late MockNakamaBaseClient mockNakamaBaseClient;

      const testUid = 'user_123';

      final mockSession = Session(
        token: 'session_token',
        refreshToken: 'refresh_token',
        created: true,
        vars: {},
        userId: 'current_user_123',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        refreshExpiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      final mockUser = MockUser();

      setUp(() {
        mockSessionService = MockSessionService();
        mockNakamaBaseClient = MockNakamaBaseClient();

        FlutterSecureStorage.setMockInitialValues({});
      });

      group('ReadUser', () {
        blocTest<UserReadBloc, UserReadState>(
          'emits loading state then success state with user when reading user (not my profile)',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenAnswer((_) async => mockSession);

            when(() => mockNakamaBaseClient.getUsers(
                  session: mockSession,
                  ids: [testUid],
                )).thenAnswer((_) async => [mockUser]);

            when(() => mockUser.id).thenReturn(testUid);
          },
          build: () => UserReadBloc(
            testUid,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          seed: () => const UserReadState(),
          act: (bloc) => bloc.add(const ReadUser()),
          expect: () => [
            const UserReadState(
              isLoading: true,
            ),
            UserReadState(
              user: mockUser,
              isMyProfile: false, // session.userId != user.id
              isLoading: false,
              error: null,
            ),
          ],
        );

        blocTest<UserReadBloc, UserReadState>(
          'emits loading state then success state with user when reading user (is my profile)',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenAnswer((_) async => mockSession);

            when(() => mockNakamaBaseClient.getUsers(
                  session: mockSession,
                  ids: [testUid],
                )).thenAnswer((_) async => [mockUser]);

            when(() => mockUser.id)
                .thenReturn('current_user_123'); // Same as session.userId
          },
          build: () => UserReadBloc(
            testUid,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          seed: () => const UserReadState(),
          act: (bloc) => bloc.add(const ReadUser()),
          expect: () => [
            const UserReadState(
              isLoading: true,
            ),
            UserReadState(
              user: mockUser,
              isMyProfile: true, // session.userId == user.id
              isLoading: false,
              error: null,
            ),
          ],
        );

        blocTest<UserReadBloc, UserReadState>(
          'throws exception when no users found',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenAnswer((_) async => mockSession);

            when(() => mockNakamaBaseClient.getUsers(
                  session: mockSession,
                  ids: [testUid],
                )).thenAnswer((_) async => []); // Empty list
          },
          build: () => UserReadBloc(
            testUid,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          seed: () => const UserReadState(),
          act: (bloc) => bloc.add(const ReadUser()),
          expect: () => [
            const UserReadState(
              isLoading: true,
            ),
            // The error will be handled by runWithErrorHandling
            const UserReadState(
              error: 'Exception: no users found',
              isLoading: false,
            ),
          ],
        );
      });
    },
  );
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/friend_list/friend_list.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nakama/nakama.dart';

class MockNakamaBaseClient extends Mock implements NakamaBaseClient {}

class MockSessionService extends Mock implements SessionService {}

class MockFriendsList extends Mock implements FriendsList {}

class MockFriend extends Mock implements Friend {}

class MockUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    FriendListBloc,
    () {
      late MockSessionService mockSessionService;
      late MockNakamaBaseClient mockNakamaBaseClient;
      late MockFriendsList mockFriendsList;
      late MockFriend mockFriend;
      late MockUser mockUser;

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
        mockFriendsList = MockFriendsList();
        mockFriend = MockFriend();
        mockUser = MockUser();

        FlutterSecureStorage.setMockInitialValues({});

        // Default mock setup
        when(() => mockSessionService.getSession())
            .thenAnswer((_) async => mockSession);

        when(() => mockUser.id).thenReturn('friend_123');
        when(() => mockUser.username).thenReturn('friend_user');
        when(() => mockFriend.user).thenReturn(mockUser);
        when(() => mockFriend.state).thenReturn(FriendshipState.mutual);
      });

      group('InitialFetch', () {
        blocTest<FriendListBloc, FriendListState>(
          'emits loading state, clears friends and cursor, then triggers FetchFriends',
          setUp: () {
            when(() => mockFriendsList.friends).thenReturn([mockFriend]);
            when(() => mockFriendsList.cursor).thenReturn('');

            when(() => mockNakamaBaseClient.listFriends(
                  session: mockSession,
                  friendshipState: any(named: 'friendshipState'),
                  cursor: any(named: 'cursor'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => mockFriendsList);
          },
          build: () => FriendListBloc(
            FriendshipState.mutual,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const InitialFetch()),
          expect: () => [
            const FriendListState(
              FriendshipState.mutual,
              isLoading: true,
              friends: [],
            ),
            FriendListState(
              FriendshipState.mutual,
              friends: [mockFriend],
              cursor: null,
              isLoading: false,
            ),
          ],
        );
      });

      group('FetchMore', () {
        blocTest<FriendListBloc, FriendListState>(
          'triggers FetchFriends when FetchMore is called',
          setUp: () {
            when(() => mockFriendsList.friends).thenReturn([mockFriend]);
            when(() => mockFriendsList.cursor).thenReturn('next_cursor');

            when(() => mockNakamaBaseClient.listFriends(
                  session: mockSession,
                  friendshipState: any(named: 'friendshipState'),
                  cursor: any(named: 'cursor'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => mockFriendsList);
          },
          build: () => FriendListBloc(
            FriendshipState.mutual,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const FetchMore()),
          expect: () => [
            const FriendListState(
              FriendshipState.mutual,
              isLoading: true,
              friends: [],
            ),
            FriendListState(
              FriendshipState.mutual,
              friends: [mockFriend],
              cursor: 'next_cursor',
              isLoading: false,
            ),
          ],
        );
      });

      group('FetchFriends', () {
        blocTest<FriendListBloc, FriendListState>(
          'successfully fetches friends and updates state with new friends',
          setUp: () {
            when(() => mockFriendsList.friends).thenReturn([mockFriend]);
            when(() => mockFriendsList.cursor).thenReturn('next_cursor');

            when(() => mockNakamaBaseClient.listFriends(
                  session: mockSession,
                  friendshipState: any(named: 'friendshipState'),
                  cursor: any(named: 'cursor'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => mockFriendsList);
          },
          build: () => FriendListBloc(
            FriendshipState.mutual,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const FetchFriends()),
          expect: () => [
            FriendListState(
              FriendshipState.mutual,
              friends: [mockFriend],
              cursor: 'next_cursor',
              isLoading: false,
            ),
          ],
        );

        blocTest<FriendListBloc, FriendListState>(
          'handles null friends gracefully',
          setUp: () {
            when(() => mockFriendsList.friends).thenReturn(null);
            when(() => mockFriendsList.cursor).thenReturn('');

            when(() => mockNakamaBaseClient.listFriends(
                  session: mockSession,
                  friendshipState: any(named: 'friendshipState'),
                  cursor: any(named: 'cursor'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => mockFriendsList);
          },
          build: () => FriendListBloc(
            FriendshipState.mutual,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const FetchFriends()),
          expect: () => [
            const FriendListState(
              FriendshipState.mutual,
              friends: [],
              cursor: null,
              isLoading: false,
            ),
          ],
        );

        blocTest<FriendListBloc, FriendListState>(
          'appends new friends to existing friends',
          setUp: () {
            final mockFriend2 = MockFriend();
            final mockUser2 = MockUser();
            when(() => mockUser2.id).thenReturn('friend_456');
            when(() => mockUser2.username).thenReturn('friend_user2');
            when(() => mockFriend2.user).thenReturn(mockUser2);
            when(() => mockFriend2.state).thenReturn(FriendshipState.mutual);

            when(() => mockFriendsList.friends).thenReturn([mockFriend2]);
            when(() => mockFriendsList.cursor).thenReturn('next_cursor');

            when(() => mockNakamaBaseClient.listFriends(
                  session: mockSession,
                  friendshipState: any(named: 'friendshipState'),
                  cursor: any(named: 'cursor'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => mockFriendsList);
          },
          build: () => FriendListBloc(
            FriendshipState.mutual,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          seed: () => FriendListState(
            FriendshipState.mutual,
            friends: [mockFriend],
            cursor: 'existing_cursor',
            isLoading: false,
          ),
          act: (bloc) => bloc.add(const FetchFriends()),
          verify: (bloc) {
            expect(bloc.state.friends.length, 2);
            expect(bloc.state.cursor, 'next_cursor');
            expect(bloc.state.isLoading, false);
          },
        );

        blocTest<FriendListBloc, FriendListState>(
          'handles empty cursor correctly',
          setUp: () {
            when(() => mockFriendsList.friends).thenReturn([mockFriend]);
            when(() => mockFriendsList.cursor).thenReturn('');

            when(() => mockNakamaBaseClient.listFriends(
                  session: mockSession,
                  friendshipState: any(named: 'friendshipState'),
                  cursor: any(named: 'cursor'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => mockFriendsList);
          },
          build: () => FriendListBloc(
            FriendshipState.mutual,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const FetchFriends()),
          expect: () => [
            FriendListState(
              FriendshipState.mutual,
              friends: [mockFriend],
              cursor: null,
              isLoading: false,
            ),
          ],
        );

        blocTest<FriendListBloc, FriendListState>(
          'uses correct friendshipState parameter',
          setUp: () {
            when(() => mockFriendsList.friends).thenReturn([mockFriend]);
            when(() => mockFriendsList.cursor).thenReturn('next_cursor');

            when(() => mockNakamaBaseClient.listFriends(
                  session: mockSession,
                  friendshipState: any(named: 'friendshipState'),
                  cursor: any(named: 'cursor'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => mockFriendsList);
          },
          build: () => FriendListBloc(
            FriendshipState.outgoingRequest,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const FetchFriends()),
          verify: (bloc) {
            verify(() => mockNakamaBaseClient.listFriends(
                  session: mockSession,
                  friendshipState: FriendshipState.outgoingRequest,
                  cursor: any(named: 'cursor'),
                  limit: any(named: 'limit'),
                )).called(1);
          },
        );

        blocTest<FriendListBloc, FriendListState>(
          'uses correct limit from Globals',
          setUp: () {
            when(() => mockFriendsList.friends).thenReturn([mockFriend]);
            when(() => mockFriendsList.cursor).thenReturn('next_cursor');

            when(() => mockNakamaBaseClient.listFriends(
                  session: mockSession,
                  friendshipState: any(named: 'friendshipState'),
                  cursor: any(named: 'cursor'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => mockFriendsList);
          },
          build: () => FriendListBloc(
            FriendshipState.mutual,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const FetchFriends()),
          verify: (bloc) {
            verify(() => mockNakamaBaseClient.listFriends(
                  session: mockSession,
                  friendshipState: any(named: 'friendshipState'),
                  cursor: any(named: 'cursor'),
                  limit: 15, // Globals.friendListLimit
                )).called(1);
          },
        );
      });
    },
  );
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/group_list/group_list.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nakama/nakama.dart';

class MockNakamaBaseClient extends Mock implements NakamaBaseClient {}

class MockSessionService extends Mock implements SessionService {}

class FakeSession extends Fake implements Session {}

class FakeGroup extends Fake implements Group {}

class FakeGroupList extends Fake implements GroupList {}

class FakeUserGroup extends Fake implements UserGroup {}

class FakeUserGroupList extends Fake implements UserGroupList {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeSession());
    registerFallbackValue(FakeGroup());
  });

  group(
    'GroupListBloc',
    () {
      late MockNakamaBaseClient mockNakamaBaseClient;
      late MockSessionService mockSessionService;

      final mockSession = Session(
        token: 'session_token',
        refreshToken: 'refresh_token',
        created: true,
        vars: {},
        userId: 'user_123',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        refreshExpiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      final mockGroup1 = Group(
        id: 'group_1',
        creatorId: 'creator_1',
        name: 'Test Group 1',
        description: 'Description 1',
        avatarUrl: '',
        langTag: 'en',
        metadata: '',
        open: true,
        edgeCount: 5,
        maxCount: 10,
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
      );

      final mockGroup2 = Group(
        id: 'group_2',
        creatorId: 'creator_2',
        name: 'Test Group 2',
        description: 'Description 2',
        avatarUrl: '',
        langTag: 'en',
        metadata: '',
        open: false,
        edgeCount: 3,
        maxCount: 8,
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
      );

      setUp(() {
        mockNakamaBaseClient = MockNakamaBaseClient();
        mockSessionService = MockSessionService();

        FlutterSecureStorage.setMockInitialValues({});

        // Default mock setup
        when(() => mockSessionService.getSession())
            .thenAnswer((_) async => mockSession);
      });

      group('initial state', () {
        test('has correct initial state without uid', () {
          final bloc = GroupListBloc(
            null,
            mockNakamaBaseClient,
            mockSessionService,
          );

          expect(
            bloc.state,
            const GroupListState(),
          );
        });

        test('has correct initial state with uid', () {
          final bloc = GroupListBloc(
            'user_123',
            mockNakamaBaseClient,
            mockSessionService,
          );

          expect(
            bloc.state,
            const GroupListState(),
          );
          expect(bloc.uid, 'user_123');
        });
      });

      group('InitialFetch', () {
        blocTest<GroupListBloc, GroupListState>(
          'sets loading and clears groups, then triggers FetchGroups',
          setUp: () {
            when(() => mockNakamaBaseClient.listGroups(
                  session: any(named: 'session'),
                  cursor: any(named: 'cursor'),
                  name: any(named: 'name'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => GroupList(
                  groups: [mockGroup1],
                  cursor: 'next_cursor',
                ));
          },
          build: () => GroupListBloc(
            null,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          seed: () => GroupListState(groups: [mockGroup1, mockGroup2]),
          act: (bloc) => bloc.add(const InitialFetch()),
          expect: () => [
            const GroupListState(isLoading: true, groups: []),
            GroupListState(
              isLoading: false,
              groups: [mockGroup1],
              cursor: 'next_cursor',
            ),
          ],
        );
      });

      group('FetchMore', () {
        blocTest<GroupListBloc, GroupListState>(
          'preserves cursor and sets loading, then triggers FetchGroups',
          setUp: () {
            when(() => mockNakamaBaseClient.listGroups(
                  session: any(named: 'session'),
                  cursor: any(named: 'cursor'),
                  name: any(named: 'name'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => GroupList(
                  groups: [mockGroup2],
                  cursor: 'final_cursor',
                ));
          },
          build: () => GroupListBloc(
            null,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          seed: () => GroupListState(
            groups: [mockGroup1],
            cursor: 'existing_cursor',
          ),
          act: (bloc) => bloc.add(const FetchMore()),
          expect: () => [
            GroupListState(
              groups: [mockGroup1],
              cursor: 'existing_cursor',
              isLoading: true,
            ),
            GroupListState(
              groups: [mockGroup1, mockGroup2],
              cursor: 'final_cursor',
              isLoading: false,
            ),
          ],
        );
      });

      group('FetchGroups - listGroups (uid is null)', () {
        blocTest<GroupListBloc, GroupListState>(
          'successfully fetches groups using listGroups',
          setUp: () {
            when(() => mockNakamaBaseClient.listGroups(
                  session: any(named: 'session'),
                  cursor: any(named: 'cursor'),
                  name: any(named: 'name'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => GroupList(
                  groups: [mockGroup1, mockGroup2],
                  cursor: 'test_cursor',
                ));
          },
          build: () => GroupListBloc(
            null,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const FetchGroups()),
          expect: () => [
            GroupListState(
              groups: [mockGroup1, mockGroup2],
              cursor: 'test_cursor',
              isLoading: false,
            ),
          ],
          verify: (bloc) {
            verify(() => mockNakamaBaseClient.listGroups(
                  session: mockSession,
                  cursor: null,
                  name: '',
                  limit: Globals.groupListLimit,
                )).called(1);
          },
        );

        blocTest<GroupListBloc, GroupListState>(
          'appends new groups to existing groups',
          setUp: () {
            when(() => mockNakamaBaseClient.listGroups(
                  session: any(named: 'session'),
                  cursor: any(named: 'cursor'),
                  name: any(named: 'name'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => GroupList(
                  groups: [mockGroup2],
                  cursor: 'new_cursor',
                ));
          },
          build: () => GroupListBloc(
            null,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          seed: () => GroupListState(groups: [mockGroup1]),
          act: (bloc) => bloc.add(const FetchGroups()),
          expect: () => [
            GroupListState(
              groups: [mockGroup1, mockGroup2],
              cursor: 'new_cursor',
              isLoading: false,
            ),
          ],
        );

        blocTest<GroupListBloc, GroupListState>(
          'handles empty cursor (end of pagination)',
          setUp: () {
            when(() => mockNakamaBaseClient.listGroups(
                  session: any(named: 'session'),
                  cursor: any(named: 'cursor'),
                  name: any(named: 'name'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => GroupList(
                  groups: [mockGroup1],
                  cursor: '',
                ));
          },
          build: () => GroupListBloc(
            null,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const FetchGroups()),
          expect: () => [
            GroupListState(
              groups: [mockGroup1],
              cursor: null,
              isLoading: false,
            ),
          ],
        );

        blocTest<GroupListBloc, GroupListState>(
          'uses query parameter for search',
          setUp: () {
            when(() => mockNakamaBaseClient.listGroups(
                  session: any(named: 'session'),
                  cursor: any(named: 'cursor'),
                  name: any(named: 'name'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => GroupList(
                  groups: [mockGroup1],
                  cursor: null,
                ));
          },
          build: () => GroupListBloc(
            null,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          seed: () => const GroupListState(query: 'search_term%'),
          act: (bloc) => bloc.add(const FetchGroups()),
          verify: (bloc) {
            verify(() => mockNakamaBaseClient.listGroups(
                  session: mockSession,
                  cursor: null,
                  name: 'search_term%',
                  limit: Globals.groupListLimit,
                )).called(1);
          },
        );
      });

      group('FetchGroups - listUserGroups (uid is not null)', () {
        final mockUserGroup1 = UserGroup(
          group: mockGroup1,
          state: GroupMembershipState.member,
        );

        final mockUserGroup2 = UserGroup(
          group: mockGroup2,
          state: GroupMembershipState.admin,
        );

        blocTest<GroupListBloc, GroupListState>(
          'successfully fetches user groups using listUserGroups',
          setUp: () {
            when(() => mockNakamaBaseClient.listUserGroups(
                  session: any(named: 'session'),
                  cursor: any(named: 'cursor'),
                  limit: any(named: 'limit'),
                  userId: any(named: 'userId'),
                )).thenAnswer((_) async => UserGroupList(
                  userGroups: [mockUserGroup1, mockUserGroup2],
                  cursor: 'user_cursor',
                ));
          },
          build: () => GroupListBloc(
            'user_123',
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const FetchGroups()),
          expect: () => [
            GroupListState(
              groups: [mockGroup1, mockGroup2],
              cursor: 'user_cursor',
              isLoading: false,
            ),
          ],
          verify: (bloc) {
            verify(() => mockNakamaBaseClient.listUserGroups(
                  session: mockSession,
                  cursor: null,
                  limit: Globals.groupListLimit,
                  userId: 'user_123',
                )).called(1);
          },
        );

        blocTest<GroupListBloc, GroupListState>(
          'handles null userGroups list',
          setUp: () {
            when(() => mockNakamaBaseClient.listUserGroups(
                  session: any(named: 'session'),
                  cursor: any(named: 'cursor'),
                  limit: any(named: 'limit'),
                  userId: any(named: 'userId'),
                )).thenAnswer((_) async => const UserGroupList(
                  userGroups: null,
                  cursor: 'cursor',
                ));
          },
          build: () => GroupListBloc(
            'user_123',
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const FetchGroups()),
          expect: () => [
            const GroupListState(
              groups: [],
              isLoading: false,
            ),
          ],
        );

        blocTest<GroupListBloc, GroupListState>(
          'handles empty userGroups list',
          setUp: () {
            when(() => mockNakamaBaseClient.listUserGroups(
                  session: any(named: 'session'),
                  cursor: any(named: 'cursor'),
                  limit: any(named: 'limit'),
                  userId: any(named: 'userId'),
                )).thenAnswer((_) async => const UserGroupList(
                  userGroups: [],
                  cursor: 'cursor',
                ));
          },
          build: () => GroupListBloc(
            'user_123',
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const FetchGroups()),
          expect: () => [
            const GroupListState(
              groups: [],
              isLoading: false,
            ),
          ],
        );
      });

      group('FetchGroups - Error Handling', () {
        blocTest<GroupListBloc, GroupListState>(
          'handles session service error',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenThrow(Exception('Session failed'));
          },
          build: () => GroupListBloc(
            null,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const FetchGroups()),
          expect: () => [
            const GroupListState(
              isLoading: false,
              error: 'Unexpected error: Exception: Session failed',
            ),
          ],
        );

        blocTest<GroupListBloc, GroupListState>(
          'handles listGroups error',
          setUp: () {
            when(() => mockNakamaBaseClient.listGroups(
                  session: any(named: 'session'),
                  cursor: any(named: 'cursor'),
                  name: any(named: 'name'),
                  limit: any(named: 'limit'),
                )).thenThrow(Exception('Network error'));
          },
          build: () => GroupListBloc(
            null,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const FetchGroups()),
          expect: () => [
            const GroupListState(
              isLoading: false,
              error: 'Unexpected error: Exception: Network error',
            ),
          ],
        );

        blocTest<GroupListBloc, GroupListState>(
          'handles listUserGroups error',
          setUp: () {
            when(() => mockNakamaBaseClient.listUserGroups(
                  session: any(named: 'session'),
                  cursor: any(named: 'cursor'),
                  limit: any(named: 'limit'),
                  userId: any(named: 'userId'),
                )).thenThrow(Exception('User groups error'));
          },
          build: () => GroupListBloc(
            'user_123',
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const FetchGroups()),
          expect: () => [
            const GroupListState(
              isLoading: false,
              error: 'Unexpected error: Exception: User groups error',
            ),
          ],
        );
      });

      group('SearchGroup', () {
        blocTest<GroupListBloc, GroupListState>(
          'sets query with % suffix and triggers InitialFetch',
          setUp: () {
            when(() => mockNakamaBaseClient.listGroups(
                  session: any(named: 'session'),
                  cursor: any(named: 'cursor'),
                  name: any(named: 'name'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => GroupList(
                  groups: [mockGroup1],
                  cursor: null,
                ));
          },
          build: () => GroupListBloc(
            null,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const SearchGroup('test')),
          expect: () => [
            const GroupListState(query: 'test%'),
            const GroupListState(query: 'test%', isLoading: true, groups: []),
            GroupListState(
              query: 'test%',
              groups: [mockGroup1],
              isLoading: false,
            ),
          ],
        );
      });

      group('ClearSearch', () {
        blocTest<GroupListBloc, GroupListState>(
          'clears query and groups',
          build: () => GroupListBloc(
            null,
            mockNakamaBaseClient,
            mockSessionService,
          ),
          seed: () => GroupListState(
            query: 'search_term%',
            groups: [mockGroup1, mockGroup2],
          ),
          act: (bloc) => bloc.add(const ClearSearch()),
          expect: () => [
            const GroupListState(
              query: '',
              groups: [],
            ),
          ],
        );
      });

      group('copyWith', () {
        test('can clear cursor with clearCursor flag', () {
          final state = GroupListState(
            cursor: 'existing_cursor',
            groups: [mockGroup1],
          );

          final newState = state.copyWith(clearCursor: true);

          expect(newState.cursor, isNull);
          expect(newState.groups, state.groups);
        });

        test('preserves cursor when clearCursor is false', () {
          final state = GroupListState(
            cursor: 'existing_cursor',
            groups: [mockGroup1],
          );

          final newState = state.copyWith(
            clearCursor: false,
            cursor: 'new_cursor',
          );

          expect(newState.cursor, 'new_cursor');
        });
      });

      group('props', () {
        test('includes all properties', () {
          final state = GroupListState(
            uid: 'user_123',
            query: 'test',
            groups: [mockGroup1],
            cursor: 'cursor',
            isLoading: true,
            error: 'error',
          );

          expect(
            state.props,
            [
              'user_123',
              'test',
              [mockGroup1],
              'cursor',
              true,
              'error'
            ],
          );
        });

        test('equality works correctly', () {
          final state1 = GroupListState(
            uid: 'user_123',
            query: 'test',
            groups: [mockGroup1],
            cursor: 'cursor',
            isLoading: true,
            error: 'error',
          );

          final state2 = GroupListState(
            uid: 'user_123',
            query: 'test',
            groups: [mockGroup1],
            cursor: 'cursor',
            isLoading: true,
            error: 'error',
          );

          final state3 = GroupListState(
            uid: 'different',
            query: 'test',
            groups: [mockGroup1],
            cursor: 'cursor',
            isLoading: true,
            error: 'error',
          );

          expect(state1, equals(state2));
          expect(state1, isNot(equals(state3)));
        });
      });
    },
  );
}

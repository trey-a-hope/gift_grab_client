import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/domain/entities/leaderboard_entry.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/record_list/record_list.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nakama/nakama.dart';

class MockNakamaBaseClient extends Mock implements NakamaBaseClient {}

class MockSessionService extends Mock implements SessionService {}

class MockLeaderboardRecordList extends Mock implements LeaderboardRecordList {}

class MockLeaderboardRecord extends Mock implements LeaderboardRecord {}

class MockUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    RecordListBloc,
    () {
      late MockSessionService mockSessionService;
      late MockNakamaBaseClient mockNakamaBaseClient;
      late MockLeaderboardRecordList mockLeaderboardRecordList;
      late MockLeaderboardRecord mockLeaderboardRecord;
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
        mockLeaderboardRecordList = MockLeaderboardRecordList();
        mockLeaderboardRecord = MockLeaderboardRecord();
        mockUser = MockUser();

        FlutterSecureStorage.setMockInitialValues({});

        // Default mock setup
        when(() => mockSessionService.getSession())
            .thenAnswer((_) async => mockSession);

        when(() => mockLeaderboardRecord.ownerId).thenReturn('owner_123');
        when(() => mockUser.id).thenReturn('owner_123');
      });

      group('InitialFetch', () {
        blocTest<RecordListBloc, RecordListState>(
          'emits loading state, clears entries and cursor, then triggers FetchRecords',
          setUp: () {
            when(() => mockLeaderboardRecordList.records)
                .thenReturn([mockLeaderboardRecord]);
            when(() => mockLeaderboardRecordList.nextCursor).thenReturn('');

            when(() => mockNakamaBaseClient.listLeaderboardRecords(
                  session: mockSession,
                  leaderboardName: any(named: 'leaderboardName'),
                  cursor: any(named: 'cursor'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => mockLeaderboardRecordList);

            when(() => mockNakamaBaseClient.getUsers(
                  session: mockSession,
                  ids: any(named: 'ids'),
                )).thenAnswer((_) async => [mockUser]);
          },
          build: () => RecordListBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const InitialFetch()),
          expect: () => [
            const RecordListState(
              isLoading: true,
              entries: [],
            ),
            RecordListState(
              entries: [
                LeaderboardEntry(record: mockLeaderboardRecord, user: mockUser)
              ],
              cursor: null,
              isLoading: false,
            ),
          ],
        );
      });

      group('FetchMore', () {
        blocTest<RecordListBloc, RecordListState>(
          'triggers FetchRecords when FetchMore is called',
          setUp: () {
            when(() => mockLeaderboardRecordList.records)
                .thenReturn([mockLeaderboardRecord]);
            when(() => mockLeaderboardRecordList.nextCursor)
                .thenReturn('next_cursor');

            when(() => mockNakamaBaseClient.listLeaderboardRecords(
                  session: mockSession,
                  leaderboardName: any(named: 'leaderboardName'),
                  cursor: any(named: 'cursor'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => mockLeaderboardRecordList);

            when(() => mockNakamaBaseClient.getUsers(
                  session: mockSession,
                  ids: any(named: 'ids'),
                )).thenAnswer((_) async => [mockUser]);
          },
          build: () => RecordListBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const FetchMore()),
          expect: () => [
            const RecordListState(
              isLoading: true,
              entries: [],
            ),
            RecordListState(
              entries: [
                LeaderboardEntry(record: mockLeaderboardRecord, user: mockUser)
              ],
              cursor: 'next_cursor',
              isLoading: false,
            ),
          ],
        );
      });

      group('FetchRecords', () {
        blocTest<RecordListBloc, RecordListState>(
          'successfully fetches records and updates state with new entries',
          setUp: () {
            when(() => mockLeaderboardRecordList.records)
                .thenReturn([mockLeaderboardRecord]);
            when(() => mockLeaderboardRecordList.nextCursor)
                .thenReturn('next_cursor');

            when(() => mockNakamaBaseClient.listLeaderboardRecords(
                  session: mockSession,
                  leaderboardName: any(named: 'leaderboardName'),
                  cursor: any(named: 'cursor'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => mockLeaderboardRecordList);

            when(() => mockNakamaBaseClient.getUsers(
                  session: mockSession,
                  ids: any(named: 'ids'),
                )).thenAnswer((_) async => [mockUser]);
          },
          build: () => RecordListBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const FetchRecords()),
          expect: () => [
            RecordListState(
              entries: [
                LeaderboardEntry(record: mockLeaderboardRecord, user: mockUser)
              ],
              cursor: 'next_cursor',
              isLoading: false,
            ),
          ],
        );

        blocTest<RecordListBloc, RecordListState>(
          'handles null records gracefully',
          setUp: () {
            when(() => mockLeaderboardRecordList.records).thenReturn(null);
            when(() => mockLeaderboardRecordList.nextCursor).thenReturn('');

            when(() => mockNakamaBaseClient.listLeaderboardRecords(
                  session: mockSession,
                  leaderboardName: any(named: 'leaderboardName'),
                  cursor: any(named: 'cursor'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => mockLeaderboardRecordList);
          },
          build: () => RecordListBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const FetchRecords()),
          expect: () => [
            const RecordListState(
              entries: [],
              cursor: null,
              isLoading: false,
            ),
          ],
        );

        blocTest<RecordListBloc, RecordListState>(
          'appends new entries to existing entries',
          setUp: () {
            final mockLeaderboardRecord2 = MockLeaderboardRecord();
            final mockUser2 = MockUser();

            when(() => mockLeaderboardRecord2.ownerId).thenReturn('owner_456');
            when(() => mockUser2.id).thenReturn('owner_456');

            when(() => mockLeaderboardRecordList.records)
                .thenReturn([mockLeaderboardRecord2]);
            when(() => mockLeaderboardRecordList.nextCursor)
                .thenReturn('next_cursor');

            when(() => mockNakamaBaseClient.listLeaderboardRecords(
                  session: mockSession,
                  leaderboardName: any(named: 'leaderboardName'),
                  cursor: any(named: 'cursor'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => mockLeaderboardRecordList);

            when(() => mockNakamaBaseClient.getUsers(
                  session: mockSession,
                  ids: any(named: 'ids'),
                )).thenAnswer((_) async => [mockUser2]);
          },
          build: () => RecordListBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          seed: () => RecordListState(
            entries: [
              LeaderboardEntry(record: mockLeaderboardRecord, user: mockUser)
            ],
            cursor: 'existing_cursor',
            isLoading: false,
          ),
          act: (bloc) => bloc.add(const FetchRecords()),
          verify: (bloc) {
            expect(bloc.state.entries.length, 2);
            expect(bloc.state.cursor, 'next_cursor');
            expect(bloc.state.isLoading, false);
          },
        );

        blocTest<RecordListBloc, RecordListState>(
          'filters out records with null ownerId',
          setUp: () {
            final mockLeaderboardRecordWithNullOwner = MockLeaderboardRecord();
            when(() => mockLeaderboardRecordWithNullOwner.ownerId)
                .thenReturn(null);

            when(() => mockLeaderboardRecordList.records).thenReturn(
                [mockLeaderboardRecord, mockLeaderboardRecordWithNullOwner]);
            when(() => mockLeaderboardRecordList.nextCursor)
                .thenReturn('next_cursor');

            when(() => mockNakamaBaseClient.listLeaderboardRecords(
                  session: mockSession,
                  leaderboardName: any(named: 'leaderboardName'),
                  cursor: any(named: 'cursor'),
                  limit: any(named: 'limit'),
                )).thenAnswer((_) async => mockLeaderboardRecordList);

            when(() => mockNakamaBaseClient.getUsers(
                  session: mockSession,
                  ids: any(named: 'ids'),
                )).thenAnswer((_) async => [mockUser]);
          },
          build: () => RecordListBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const FetchRecords()),
          expect: () => [
            RecordListState(
              entries: [
                LeaderboardEntry(record: mockLeaderboardRecord, user: mockUser)
              ],
              cursor: 'next_cursor',
              isLoading: false,
            ),
          ],
          verify: (bloc) {
            expect(bloc.state.entries.length, 1);
          },
        );
      });
    },
  );
}

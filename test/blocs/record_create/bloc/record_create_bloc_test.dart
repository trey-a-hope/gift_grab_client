import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/record_create/record_create.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nakama/nakama.dart';

class MockNakamaBaseClient extends Mock implements NakamaBaseClient {}

class MockSessionService extends Mock implements SessionService {}

class FakeSession extends Fake implements Session {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeSession());
  });

  group(
    RecordCreateBloc,
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

      setUp(() {
        mockSessionService = MockSessionService();
        mockNakamaBaseClient = MockNakamaBaseClient();

        FlutterSecureStorage.setMockInitialValues({});

        // Default mock setup
        when(() => mockSessionService.getSession())
            .thenAnswer((_) async => mockSession);
      });

      group('SubmitRecord', () {
        blocTest<RecordCreateBloc, RecordCreateState>(
          'successfully submits record with given score',
          setUp: () {
            when(() => mockNakamaBaseClient.writeLeaderboardRecord(
                  session: any(named: 'session'),
                  leaderboardName: any(named: 'leaderboardName'),
                  score: any(named: 'score'),
                )).thenAnswer((_) async => const LeaderboardRecord());
          },
          build: () => RecordCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const SubmitRecord(1500)),
          verify: (bloc) {
            expect(bloc.state.isLoading, false);
            expect(bloc.state.error, isNull);
          },
        );

        blocTest<RecordCreateBloc, RecordCreateState>(
          'verifies correct parameters are passed to writeLeaderboardRecord',
          setUp: () {
            when(() => mockNakamaBaseClient.writeLeaderboardRecord(
                  session: any(named: 'session'),
                  leaderboardName: any(named: 'leaderboardName'),
                  score: any(named: 'score'),
                )).thenAnswer((_) async => const LeaderboardRecord());
          },
          build: () => RecordCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const SubmitRecord(2500)),
          verify: (bloc) {
            verify(() => mockSessionService.getSession()).called(1);
            verify(() => mockNakamaBaseClient.writeLeaderboardRecord(
                  session: mockSession,
                  leaderboardName: any(named: 'leaderboardName'),
                  score: 2500,
                )).called(1);
          },
        );

        blocTest<RecordCreateBloc, RecordCreateState>(
          'handles different score values correctly',
          setUp: () {
            when(() => mockNakamaBaseClient.writeLeaderboardRecord(
                  session: any(named: 'session'),
                  leaderboardName: any(named: 'leaderboardName'),
                  score: any(named: 'score'),
                )).thenAnswer((_) async => const LeaderboardRecord());
          },
          build: () => RecordCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const SubmitRecord(0)),
          verify: (bloc) {
            verify(() => mockNakamaBaseClient.writeLeaderboardRecord(
                  session: any(named: 'session'),
                  leaderboardName: any(named: 'leaderboardName'),
                  score: 0,
                )).called(1);
          },
        );

        blocTest<RecordCreateBloc, RecordCreateState>(
          'handles large score values correctly',
          setUp: () {
            when(() => mockNakamaBaseClient.writeLeaderboardRecord(
                  session: any(named: 'session'),
                  leaderboardName: any(named: 'leaderboardName'),
                  score: any(named: 'score'),
                )).thenAnswer((_) async => const LeaderboardRecord());
          },
          build: () => RecordCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const SubmitRecord(999999)),
          verify: (bloc) {
            verify(() => mockNakamaBaseClient.writeLeaderboardRecord(
                  session: any(named: 'session'),
                  leaderboardName: any(named: 'leaderboardName'),
                  score: 999999,
                )).called(1);
          },
        );

        blocTest<RecordCreateBloc, RecordCreateState>(
          'handles error when session service fails',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenThrow(Exception('Session failed'));
          },
          build: () => RecordCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const SubmitRecord(1000)),
          verify: (bloc) {
            expect(bloc.state.error, isNotNull);
            expect(bloc.state.isLoading, false);
          },
        );

        blocTest<RecordCreateBloc, RecordCreateState>(
          'handles error when write leaderboard record fails',
          setUp: () {
            when(() => mockNakamaBaseClient.writeLeaderboardRecord(
                  session: any(named: 'session'),
                  leaderboardName: any(named: 'leaderboardName'),
                  score: any(named: 'score'),
                )).thenThrow(Exception('Write failed'));
          },
          build: () => RecordCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const SubmitRecord(1000)),
          verify: (bloc) {
            expect(bloc.state.error, isNotNull);
            expect(bloc.state.isLoading, false);
          },
        );

        blocTest<RecordCreateBloc, RecordCreateState>(
          'resets state when starting a new submit operation',
          build: () => RecordCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          seed: () => const RecordCreateState(
            error: 'Previous error message',
            isLoading: false,
          ),
          setUp: () {
            when(() => mockNakamaBaseClient.writeLeaderboardRecord(
                  session: any(named: 'session'),
                  leaderboardName: any(named: 'leaderboardName'),
                  score: any(named: 'score'),
                )).thenAnswer((_) async => const LeaderboardRecord());
          },
          act: (bloc) => bloc.add(const SubmitRecord(750)),
          verify: (bloc) {
            expect(bloc.state.error, isNull);
            expect(bloc.state.isLoading, false);
          },
        );

        blocTest<RecordCreateBloc, RecordCreateState>(
          'handles negative score values correctly',
          setUp: () {
            when(() => mockNakamaBaseClient.writeLeaderboardRecord(
                  session: any(named: 'session'),
                  leaderboardName: any(named: 'leaderboardName'),
                  score: any(named: 'score'),
                )).thenAnswer((_) async => const LeaderboardRecord());
          },
          build: () => RecordCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const SubmitRecord(-100)),
          verify: (bloc) {
            verify(() => mockNakamaBaseClient.writeLeaderboardRecord(
                  session: any(named: 'session'),
                  leaderboardName: any(named: 'leaderboardName'),
                  score: -100,
                )).called(1);
          },
        );
      });
    },
  );
}

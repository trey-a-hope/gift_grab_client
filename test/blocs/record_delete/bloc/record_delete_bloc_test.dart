import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/record_delete/record_delete.dart';
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
    RecordDeleteBloc,
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

      group('DeleteRecord', () {
        blocTest<RecordDeleteBloc, RecordDeleteState>(
          'emits loading state then success state when deleting record successfully',
          setUp: () {
            when(() => mockNakamaBaseClient.deleteLeaderboardRecord(
                  session: mockSession,
                  leaderboardName: any(named: 'leaderboardName'),
                )).thenAnswer((_) async {});
          },
          build: () => RecordDeleteBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const DeleteRecord()),
          verify: (bloc) {
            expect(bloc.state.success, 'Record deleted successfully');
            expect(bloc.state.isLoading, false);
            expect(bloc.state.error, isNull);
          },
        );

        blocTest<RecordDeleteBloc, RecordDeleteState>(
          'verifies correct parameters are passed to deleteLeaderboardRecord',
          setUp: () {
            when(() => mockNakamaBaseClient.deleteLeaderboardRecord(
                  session: any(named: 'session'),
                  leaderboardName: any(named: 'leaderboardName'),
                )).thenAnswer((_) async {});
          },
          build: () => RecordDeleteBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const DeleteRecord()),
          verify: (bloc) {
            verify(() => mockSessionService.getSession()).called(1);
            verify(() => mockNakamaBaseClient.deleteLeaderboardRecord(
                  session: mockSession,
                  leaderboardName: any(named: 'leaderboardName'),
                )).called(1);
          },
        );

        blocTest<RecordDeleteBloc, RecordDeleteState>(
          'handles error when session service fails',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenThrow(Exception('Session failed'));
          },
          build: () => RecordDeleteBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const DeleteRecord()),
          verify: (bloc) {
            expect(bloc.state.error, isNotNull);
            expect(bloc.state.success, isNull);
            expect(bloc.state.isLoading, false);
          },
        );

        blocTest<RecordDeleteBloc, RecordDeleteState>(
          'handles error when delete leaderboard record fails',
          setUp: () {
            when(() => mockNakamaBaseClient.deleteLeaderboardRecord(
                  session: mockSession,
                  leaderboardName: any(named: 'leaderboardName'),
                )).thenThrow(Exception('Delete failed'));
          },
          build: () => RecordDeleteBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const DeleteRecord()),
          verify: (bloc) {
            expect(bloc.state.error, isNotNull);
            expect(bloc.state.success, isNull);
            expect(bloc.state.isLoading, false);
          },
        );

        blocTest<RecordDeleteBloc, RecordDeleteState>(
          'resets state when starting a new delete operation',
          build: () => RecordDeleteBloc(
            mockNakamaBaseClient,
            mockSessionService,
          ),
          seed: () => const RecordDeleteState(
            success: 'Previous success message',
            error: 'Previous error message',
            isLoading: false,
          ),
          setUp: () {
            when(() => mockNakamaBaseClient.deleteLeaderboardRecord(
                  session: mockSession,
                  leaderboardName: any(named: 'leaderboardName'),
                )).thenAnswer((_) async {});
          },
          act: (bloc) => bloc.add(const DeleteRecord()),
          verify: (bloc) {
            expect(bloc.state.success, 'Record deleted successfully');
            expect(bloc.state.error, isNull);
            expect(bloc.state.isLoading, false);
          },
        );
      });
    },
  );
}

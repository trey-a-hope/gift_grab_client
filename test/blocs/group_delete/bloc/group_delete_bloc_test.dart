import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/group_delete/group_delete.dart';
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
    'GroupDeleteBloc',
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

      setUp(() {
        mockNakamaBaseClient = MockNakamaBaseClient();
        mockSessionService = MockSessionService();

        FlutterSecureStorage.setMockInitialValues({});

        // Default mock setup
        when(() => mockSessionService.getSession())
            .thenAnswer((_) async => mockSession);
      });

      group('initial state', () {
        test('has correct initial state', () {
          final bloc = GroupDeleteBloc(
            'group_id_123',
            mockNakamaBaseClient,
            mockSessionService,
          );

          expect(
            bloc.state,
            const GroupDeleteState(),
          );
        });
      });

      group('DeleteGroup', () {
        blocTest<GroupDeleteBloc, GroupDeleteState>(
          'successfully deletes group',
          setUp: () {
            when(() => mockNakamaBaseClient.deleteGroup(
                  session: any(named: 'session'),
                  groupId: any(named: 'groupId'),
                )).thenAnswer((_) async {});
          },
          build: () => GroupDeleteBloc(
            'group_id_123',
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const DeleteGroup()),
          expect: () => [
            const GroupDeleteState(isLoading: true),
            const GroupDeleteState(
              isLoading: false,
              success: 'Group deleted successfully',
            ),
          ],
        );

        blocTest<GroupDeleteBloc, GroupDeleteState>(
          'verifies correct parameters are passed to deleteGroup',
          setUp: () {
            when(() => mockNakamaBaseClient.deleteGroup(
                  session: any(named: 'session'),
                  groupId: any(named: 'groupId'),
                )).thenAnswer((_) async {});
          },
          build: () => GroupDeleteBloc(
            'test_group_id',
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const DeleteGroup()),
          verify: (bloc) {
            verify(() => mockSessionService.getSession()).called(1);
            verify(() => mockNakamaBaseClient.deleteGroup(
                  session: mockSession,
                  groupId: 'test_group_id',
                )).called(1);
          },
        );

        blocTest<GroupDeleteBloc, GroupDeleteState>(
          'handles error when session service fails',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenThrow(Exception('Session failed'));
          },
          build: () => GroupDeleteBloc(
            'group_id_123',
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const DeleteGroup()),
          expect: () => [
            const GroupDeleteState(isLoading: true),
            const GroupDeleteState(
              isLoading: false,
              error: 'Unexpected error: Exception: Session failed',
            ),
          ],
          verify: (bloc) {
            verifyNever(() => mockNakamaBaseClient.deleteGroup(
                  session: any(named: 'session'),
                  groupId: any(named: 'groupId'),
                ));
          },
        );

        blocTest<GroupDeleteBloc, GroupDeleteState>(
          'handles error when deleteGroup fails',
          setUp: () {
            when(() => mockNakamaBaseClient.deleteGroup(
                  session: any(named: 'session'),
                  groupId: any(named: 'groupId'),
                )).thenThrow(Exception('Delete failed'));
          },
          build: () => GroupDeleteBloc(
            'group_id_123',
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const DeleteGroup()),
          expect: () => [
            const GroupDeleteState(isLoading: true),
            const GroupDeleteState(
              isLoading: false,
              error: 'Unexpected error: Exception: Delete failed',
            ),
          ],
        );

        blocTest<GroupDeleteBloc, GroupDeleteState>(
          'resets error state when starting a new delete operation',
          setUp: () {
            when(() => mockNakamaBaseClient.deleteGroup(
                  session: any(named: 'session'),
                  groupId: any(named: 'groupId'),
                )).thenAnswer((_) async {});
          },
          build: () => GroupDeleteBloc(
            'group_id_123',
            mockNakamaBaseClient,
            mockSessionService,
          ),
          seed: () => const GroupDeleteState(
            error: 'Previous error',
          ),
          act: (bloc) => bloc.add(const DeleteGroup()),
          expect: () => [
            const GroupDeleteState(isLoading: true),
            const GroupDeleteState(
              isLoading: false,
              success: 'Group deleted successfully',
            ),
          ],
        );

        blocTest<GroupDeleteBloc, GroupDeleteState>(
          'resets success state when starting a new delete operation',
          setUp: () {
            when(() => mockNakamaBaseClient.deleteGroup(
                  session: any(named: 'session'),
                  groupId: any(named: 'groupId'),
                )).thenAnswer((_) async {});
          },
          build: () => GroupDeleteBloc(
            'group_id_123',
            mockNakamaBaseClient,
            mockSessionService,
          ),
          seed: () => const GroupDeleteState(
            success: 'Previous success',
          ),
          act: (bloc) => bloc.add(const DeleteGroup()),
          expect: () => [
            const GroupDeleteState(isLoading: true),
            const GroupDeleteState(
              isLoading: false,
              success: 'Group deleted successfully',
            ),
          ],
        );

        blocTest<GroupDeleteBloc, GroupDeleteState>(
          'preserves groupId parameter across operations',
          setUp: () {
            when(() => mockNakamaBaseClient.deleteGroup(
                  session: any(named: 'session'),
                  groupId: any(named: 'groupId'),
                )).thenAnswer((_) async {});
          },
          build: () => GroupDeleteBloc(
            'specific_group_id',
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const DeleteGroup()),
          verify: (bloc) {
            expect(bloc.groupId, 'specific_group_id');
            verify(() => mockNakamaBaseClient.deleteGroup(
                  session: mockSession,
                  groupId: 'specific_group_id',
                )).called(1);
          },
        );
      });

      group('copyWith', () {
        test('returns object with updated values', () {
          const state = GroupDeleteState(
            success: 'old success',
            isLoading: false,
            error: 'old error',
          );

          final newState = state.copyWith(
            success: 'new success',
            isLoading: true,
            error: 'new error',
          );

          expect(newState.success, 'new success');
          expect(newState.isLoading, true);
          expect(newState.error, 'new error');
        });

        test('can set values to null', () {
          const state = GroupDeleteState(
            success: 'test success',
            isLoading: true,
            error: 'test error',
          );

          final newState = state.copyWith(
            success: null,
            isLoading: false,
            error: null,
          );

          expect(newState.success, isNull);
          expect(newState.isLoading, false);
          expect(newState.error, isNull);
        });
      });

      group('props', () {
        test('includes all properties', () {
          const state = GroupDeleteState(
            success: 'test success',
            isLoading: true,
            error: 'test error',
          );

          expect(
            state.props,
            ['test success', true, 'test error'],
          );
        });

        test('equality works correctly', () {
          const state1 = GroupDeleteState(
            success: 'test',
            isLoading: true,
            error: 'error',
          );

          const state2 = GroupDeleteState(
            success: 'test',
            isLoading: true,
            error: 'error',
          );

          const state3 = GroupDeleteState(
            success: 'different',
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

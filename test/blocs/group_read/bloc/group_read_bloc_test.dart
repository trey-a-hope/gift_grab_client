import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_grab_client/data/enums/rpc_functions.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/group_read/group_read.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nakama/nakama.dart';

class MockNakamaBaseClient extends Mock implements NakamaBaseClient {}

class MockSessionService extends Mock implements SessionService {}

class FakeSession extends Fake implements Session {}

class FakeGroup extends Fake implements Group {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeSession());
    registerFallbackValue(FakeGroup());
  });

  group(
    'GroupReadBloc',
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

      final mockGroup = Group(
        id: 'group_123',
        creatorId: 'creator_123',
        name: 'Test Group',
        description: 'Test Description',
        avatarUrl: 'https://example.com/avatar.jpg',
        langTag: 'en',
        metadata: '{"key": "value"}',
        open: true,
        edgeCount: 5,
        maxCount: 10,
        createTime: DateTime.now(),
        updateTime: DateTime.now(),
      );

      final mockGroupJson = {
        'id': 'group_123',
        'creator_id': 'creator_123',
        'name': 'Test Group',
        'description': 'Test Description',
        'avatar_url': 'https://example.com/avatar.jpg',
        'lang_tag': 'en',
        'metadata': '{"key": "value"}',
        'open': true,
        'edge_count': 5,
        'max_count': 10,
        'create_time': DateTime.now().toIso8601String(),
        'update_time': DateTime.now().toIso8601String(),
      };

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
          final bloc = GroupReadBloc(
            'group_123',
            mockNakamaBaseClient,
            mockSessionService,
          );

          expect(
            bloc.state,
            const GroupReadState(),
          );
          expect(bloc.groupId, 'group_123');
        });
      });

      group('ReadGroup', () {
        blocTest<GroupReadBloc, GroupReadState>(
          'verifies correct RPC parameters are passed',
          setUp: () {
            when(() => mockNakamaBaseClient.rpc(
                  session: any(named: 'session'),
                  id: any(named: 'id'),
                  payload: any(named: 'payload'),
                )).thenAnswer((_) async => jsonEncode(mockGroupJson));
          },
          build: () => GroupReadBloc(
            'test_group_id',
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const ReadGroup()),
          verify: (bloc) {
            verify(() => mockSessionService.getSession()).called(1);
            verify(() => mockNakamaBaseClient.rpc(
                  session: mockSession,
                  id: RpcFunctions.GET_GROUP_BY_ID.id,
                  payload: jsonEncode({'group_id': 'test_group_id'}),
                )).called(1);
          },
        );

        blocTest<GroupReadBloc, GroupReadState>(
          'handles null RPC response (group not found)',
          setUp: () {
            when(() => mockNakamaBaseClient.rpc(
                  session: any(named: 'session'),
                  id: any(named: 'id'),
                  payload: any(named: 'payload'),
                )).thenAnswer((_) async => null);
          },
          build: () => GroupReadBloc(
            'nonexistent_group',
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const ReadGroup()),
          expect: () => [
            const GroupReadState(isLoading: true),
            const GroupReadState(
              isLoading: false,
              error: 'Unexpected error: Exception: Group not found',
            ),
          ],
        );

        blocTest<GroupReadBloc, GroupReadState>(
          'handles session service error',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenThrow(Exception('Session failed'));
          },
          build: () => GroupReadBloc(
            'group_123',
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const ReadGroup()),
          expect: () => [
            const GroupReadState(isLoading: true),
            const GroupReadState(
              isLoading: false,
              error: 'Unexpected error: Exception: Session failed',
            ),
          ],
          verify: (bloc) {
            verifyNever(() => mockNakamaBaseClient.rpc(
                  session: any(named: 'session'),
                  id: any(named: 'id'),
                  payload: any(named: 'payload'),
                ));
          },
        );

        blocTest<GroupReadBloc, GroupReadState>(
          'handles RPC call error',
          setUp: () {
            when(() => mockNakamaBaseClient.rpc(
                  session: any(named: 'session'),
                  id: any(named: 'id'),
                  payload: any(named: 'payload'),
                )).thenThrow(Exception('RPC failed'));
          },
          build: () => GroupReadBloc(
            'group_123',
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const ReadGroup()),
          expect: () => [
            const GroupReadState(isLoading: true),
            const GroupReadState(
              isLoading: false,
              error: 'Unexpected error: Exception: RPC failed',
            ),
          ],
        );

        blocTest<GroupReadBloc, GroupReadState>(
          'preserves groupId parameter across operations',
          setUp: () {
            when(() => mockNakamaBaseClient.rpc(
                  session: any(named: 'session'),
                  id: any(named: 'id'),
                  payload: any(named: 'payload'),
                )).thenAnswer((_) async => jsonEncode(mockGroupJson));
          },
          build: () => GroupReadBloc(
            'specific_group_id',
            mockNakamaBaseClient,
            mockSessionService,
          ),
          act: (bloc) => bloc.add(const ReadGroup()),
          verify: (bloc) {
            expect(bloc.groupId, 'specific_group_id');
            verify(() => mockNakamaBaseClient.rpc(
                  session: mockSession,
                  id: RpcFunctions.GET_GROUP_BY_ID.id,
                  payload: jsonEncode({'group_id': 'specific_group_id'}),
                )).called(1);
          },
        );
      });

      group('copyWith', () {
        test('returns object with updated values', () {
          const state = GroupReadState(
            group: null,
            isLoading: false,
            error: 'old error',
          );

          final newState = state.copyWith(
            group: mockGroup,
            isLoading: true,
            error: 'new error',
          );

          expect(newState.group, mockGroup);
          expect(newState.isLoading, true);
          expect(newState.error, 'new error');
        });
      });

      group('props', () {
        test('includes all properties', () {
          final state = GroupReadState(
            group: mockGroup,
            isLoading: true,
            error: 'test error',
          );

          expect(
            state.props,
            [mockGroup, true, 'test error'],
          );
        });

        test('equality works correctly', () {
          final state1 = GroupReadState(
            group: mockGroup,
            isLoading: true,
            error: 'error',
          );

          final state2 = GroupReadState(
            group: mockGroup,
            isLoading: true,
            error: 'error',
          );

          const state3 = GroupReadState(
            group: null,
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

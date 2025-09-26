import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:gift_grab_client/data/constants/feedback_messages.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/group_update/group_update.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nakama/nakama.dart';
import 'package:profanity_api/models/profanity_api_response/profanity_api_response.dart';
import 'package:profanity_api/profanity_api.dart';

class MockNakamaBaseClient extends Mock implements NakamaBaseClient {}

class MockSessionService extends Mock implements SessionService {}

class MockProfanityApi extends Mock implements ProfanityApi {}

class FakeSession extends Fake implements Session {}

class FakeGroup extends Fake implements Group {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeSession());
    registerFallbackValue(FakeGroup());
  });

  group(
    'GroupUpdateBloc',
    () {
      late MockNakamaBaseClient mockNakamaBaseClient;
      late MockSessionService mockSessionService;
      late MockProfanityApi mockProfanityApi;

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

      const cleanProfanityApiResponse =
          ProfanityApiResponse(isProfanity: false, score: 15);
      const profaneProfanityApiResponse =
          ProfanityApiResponse(isProfanity: true, score: 85);

      setUp(() {
        mockNakamaBaseClient = MockNakamaBaseClient();
        mockSessionService = MockSessionService();
        mockProfanityApi = MockProfanityApi();

        FlutterSecureStorage.setMockInitialValues({});

        // Default mock setup
        when(() => mockSessionService.getSession())
            .thenAnswer((_) async => mockSession);
      });

      group('initial state', () {
        test('has correct initial state', () {
          final bloc = GroupUpdateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          );

          expect(
            bloc.state,
            const GroupUpdateState(),
          );
        });
      });

      group('InitForm', () {
        blocTest<GroupUpdateBloc, GroupUpdateState>(
          'initializes form with group data',
          build: () => GroupUpdateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          act: (bloc) => bloc.add(InitForm(mockGroup)),
          expect: () => [
            const GroupUpdateState(
              name: ShortText.dirty('Test Group'),
              description: LongText.dirty('Test Description'),
              open: Toggle.dirty(true),
            ),
          ],
        );

        blocTest<GroupUpdateBloc, GroupUpdateState>(
          'handles null name and description',
          build: () => GroupUpdateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          act: (bloc) => bloc.add(InitForm(Group(
            id: 'group_123',
            creatorId: 'creator_123',
            name: null,
            description: null,
            avatarUrl: '',
            langTag: 'en',
            metadata: '',
            open: null,
            edgeCount: 0,
            maxCount: 10,
            createTime: DateTime.now(),
            updateTime: DateTime.now(),
          ))),
          expect: () => [
            const GroupUpdateState(
              name: ShortText.dirty(''),
              description: LongText.dirty(''),
              open: Toggle.dirty(false),
            ),
          ],
        );

        blocTest<GroupUpdateBloc, GroupUpdateState>(
          'overwrites previous form state',
          build: () => GroupUpdateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          seed: () => const GroupUpdateState(
            name: ShortText.dirty('Previous Name'),
            description: LongText.dirty('Previous Description'),
            open: Toggle.dirty(false),
          ),
          act: (bloc) => bloc.add(InitForm(mockGroup)),
          expect: () => [
            const GroupUpdateState(
              name: ShortText.dirty('Test Group'),
              description: LongText.dirty('Test Description'),
              open: Toggle.dirty(true),
            ),
          ],
        );
      });

      group('NameChanged', () {
        blocTest<GroupUpdateBloc, GroupUpdateState>(
          'updates name field with dirty value',
          build: () => GroupUpdateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          act: (bloc) => bloc.add(const NameChanged('Updated Name')),
          expect: () => [
            const GroupUpdateState(
              name: ShortText.dirty('Updated Name'),
            ),
          ],
        );

        blocTest<GroupUpdateBloc, GroupUpdateState>(
          'updates name field multiple times',
          build: () => GroupUpdateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          act: (bloc) => bloc
            ..add(const NameChanged('First Name'))
            ..add(const NameChanged('Second Name')),
          expect: () => [
            const GroupUpdateState(
              name: ShortText.dirty('First Name'),
            ),
            const GroupUpdateState(
              name: ShortText.dirty('Second Name'),
            ),
          ],
        );
      });

      group('DescriptionChanged', () {
        blocTest<GroupUpdateBloc, GroupUpdateState>(
          'updates description field with dirty value',
          build: () => GroupUpdateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          act: (bloc) =>
              bloc.add(const DescriptionChanged('Updated Description')),
          expect: () => [
            const GroupUpdateState(
              description: LongText.dirty('Updated Description'),
            ),
          ],
        );
      });

      group('OpenChanged', () {
        blocTest<GroupUpdateBloc, GroupUpdateState>(
          'updates open field with dirty value',
          build: () => GroupUpdateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          act: (bloc) => bloc.add(const OpenChanged(false)),
          expect: () => [
            const GroupUpdateState(
              open: Toggle.dirty(false),
            ),
          ],
        );
      });

      group('SaveForm', () {
        blocTest<GroupUpdateBloc, GroupUpdateState>(
          'successfully updates group with valid input',
          setUp: () {
            when(() => mockProfanityApi.scan(any()))
                .thenAnswer((_) async => cleanProfanityApiResponse);

            when(() => mockNakamaBaseClient.updateGroup(
                  groupId: any(named: 'groupId'),
                  session: any(named: 'session'),
                  name: any(named: 'name'),
                  description: any(named: 'description'),
                  open: any(named: 'open'),
                  langTag: any(named: 'langTag'),
                )).thenAnswer((_) async {});
          },
          build: () => GroupUpdateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          seed: () => const GroupUpdateState(
            name: ShortText.dirty('Clean Name'),
            description: LongText.dirty('Clean Description'),
            open: Toggle.dirty(true),
          ),
          act: (bloc) => bloc.add(const SaveForm('group_123')),
          expect: () => [
            const GroupUpdateState(
              name: ShortText.dirty('Clean Name'),
              description: LongText.dirty('Clean Description'),
              open: Toggle.dirty(true),
              status: FormzSubmissionStatus.inProgress,
            ),
            const GroupUpdateState(
              name: ShortText.dirty('Clean Name'),
              description: LongText.dirty('Clean Description'),
              open: Toggle.dirty(true),
              status: FormzSubmissionStatus.success,
              success: 'Group updated',
            ),
          ],
        );

        blocTest<GroupUpdateBloc, GroupUpdateState>(
          'verifies correct parameters are passed to updateGroup',
          setUp: () {
            when(() => mockProfanityApi.scan(any()))
                .thenAnswer((_) async => cleanProfanityApiResponse);

            when(() => mockNakamaBaseClient.updateGroup(
                  groupId: any(named: 'groupId'),
                  session: any(named: 'session'),
                  name: any(named: 'name'),
                  description: any(named: 'description'),
                  open: any(named: 'open'),
                  langTag: any(named: 'langTag'),
                )).thenAnswer((_) async {});
          },
          build: () => GroupUpdateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          seed: () => const GroupUpdateState(
            name: ShortText.dirty('Test Group'),
            description: LongText.dirty('Test Description'),
            open: Toggle.dirty(false),
          ),
          act: (bloc) => bloc.add(const SaveForm('test_group_id')),
          verify: (bloc) {
            verify(() => mockSessionService.getSession()).called(1);
            verify(() => mockProfanityApi.scan('Test Group')).called(1);
            verify(() => mockProfanityApi.scan('Test Description')).called(1);
            verify(() => mockNakamaBaseClient.updateGroup(
                  groupId: 'test_group_id',
                  session: mockSession,
                  name: 'Test Group',
                  description: 'Test Description',
                  open: false,
                  langTag: 'en',
                )).called(1);
          },
        );

        blocTest<GroupUpdateBloc, GroupUpdateState>(
          'handles profanity in name',
          setUp: () {
            when(() => mockProfanityApi.scan('Profane Name'))
                .thenAnswer((_) async => profaneProfanityApiResponse);
            when(() => mockProfanityApi.scan('Clean Description'))
                .thenAnswer((_) async => cleanProfanityApiResponse);
          },
          build: () => GroupUpdateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          seed: () => const GroupUpdateState(
            name: ShortText.dirty('Profane Name'),
            description: LongText.dirty('Clean Description'),
            open: Toggle.dirty(true),
          ),
          act: (bloc) => bloc.add(const SaveForm('group_123')),
          expect: () => [
            const GroupUpdateState(
              name: ShortText.dirty('Profane Name'),
              description: LongText.dirty('Clean Description'),
              open: Toggle.dirty(true),
              status: FormzSubmissionStatus.inProgress,
            ),
            const GroupUpdateState(
              name: ShortText.dirty('Profane Name'),
              description: LongText.dirty('Clean Description'),
              open: Toggle.dirty(true),
              status: FormzSubmissionStatus.initial,
              error:
                  'Unexpected error: Exception: ${FeedbackMessages.profanity}',
            ),
          ],
          verify: (bloc) {
            verifyNever(() => mockNakamaBaseClient.updateGroup(
                  groupId: any(named: 'groupId'),
                  session: any(named: 'session'),
                  name: any(named: 'name'),
                  description: any(named: 'description'),
                  open: any(named: 'open'),
                  langTag: any(named: 'langTag'),
                ));
          },
        );

        blocTest<GroupUpdateBloc, GroupUpdateState>(
          'handles profanity in description',
          setUp: () {
            when(() => mockProfanityApi.scan('Clean Name'))
                .thenAnswer((_) async => cleanProfanityApiResponse);
            when(() => mockProfanityApi.scan('Profane Description'))
                .thenAnswer((_) async => profaneProfanityApiResponse);
          },
          build: () => GroupUpdateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          seed: () => const GroupUpdateState(
            name: ShortText.dirty('Clean Name'),
            description: LongText.dirty('Profane Description'),
            open: Toggle.dirty(true),
          ),
          act: (bloc) => bloc.add(const SaveForm('group_123')),
          expect: () => [
            const GroupUpdateState(
              name: ShortText.dirty('Clean Name'),
              description: LongText.dirty('Profane Description'),
              open: Toggle.dirty(true),
              status: FormzSubmissionStatus.inProgress,
            ),
            const GroupUpdateState(
              name: ShortText.dirty('Clean Name'),
              description: LongText.dirty('Profane Description'),
              open: Toggle.dirty(true),
              status: FormzSubmissionStatus.initial,
              error:
                  'Unexpected error: Exception: ${FeedbackMessages.profanity}',
            ),
          ],
        );

        blocTest<GroupUpdateBloc, GroupUpdateState>(
          'handles error when session service fails',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenThrow(Exception('Session failed'));
          },
          build: () => GroupUpdateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          seed: () => const GroupUpdateState(
            name: ShortText.dirty('Test Name'),
            description: LongText.dirty('Test Description'),
          ),
          act: (bloc) => bloc.add(const SaveForm('group_123')),
          expect: () => [
            const GroupUpdateState(
              name: ShortText.dirty('Test Name'),
              description: LongText.dirty('Test Description'),
              status: FormzSubmissionStatus.inProgress,
            ),
            const GroupUpdateState(
              name: ShortText.dirty('Test Name'),
              description: LongText.dirty('Test Description'),
              status: FormzSubmissionStatus.initial,
              error: 'Unexpected error: Exception: Session failed',
            ),
          ],
        );

        blocTest<GroupUpdateBloc, GroupUpdateState>(
          'handles error when profanity API fails',
          setUp: () {
            when(() => mockProfanityApi.scan(any()))
                .thenThrow(Exception('API failed'));
          },
          build: () => GroupUpdateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          seed: () => const GroupUpdateState(
            name: ShortText.dirty('Test Name'),
            description: LongText.dirty('Test Description'),
          ),
          act: (bloc) => bloc.add(const SaveForm('group_123')),
          expect: () => [
            const GroupUpdateState(
              name: ShortText.dirty('Test Name'),
              description: LongText.dirty('Test Description'),
              status: FormzSubmissionStatus.inProgress,
            ),
            const GroupUpdateState(
              name: ShortText.dirty('Test Name'),
              description: LongText.dirty('Test Description'),
              status: FormzSubmissionStatus.initial,
              error: 'Unexpected error: Exception: API failed',
            ),
          ],
        );

        blocTest<GroupUpdateBloc, GroupUpdateState>(
          'handles error when updateGroup fails',
          setUp: () {
            when(() => mockProfanityApi.scan(any()))
                .thenAnswer((_) async => cleanProfanityApiResponse);

            when(() => mockNakamaBaseClient.updateGroup(
                  groupId: any(named: 'groupId'),
                  session: any(named: 'session'),
                  name: any(named: 'name'),
                  description: any(named: 'description'),
                  open: any(named: 'open'),
                  langTag: any(named: 'langTag'),
                )).thenThrow(Exception('Update group failed'));
          },
          build: () => GroupUpdateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          seed: () => const GroupUpdateState(
            name: ShortText.dirty('Test Name'),
            description: LongText.dirty('Test Description'),
          ),
          act: (bloc) => bloc.add(const SaveForm('group_123')),
          expect: () => [
            const GroupUpdateState(
              name: ShortText.dirty('Test Name'),
              description: LongText.dirty('Test Description'),
              status: FormzSubmissionStatus.inProgress,
            ),
            const GroupUpdateState(
              name: ShortText.dirty('Test Name'),
              description: LongText.dirty('Test Description'),
              status: FormzSubmissionStatus.initial,
              error: 'Unexpected error: Exception: Update group failed',
            ),
          ],
        );

        blocTest<GroupUpdateBloc, GroupUpdateState>(
          'handles empty form values correctly',
          setUp: () {
            when(() => mockProfanityApi.scan(any()))
                .thenAnswer((_) async => cleanProfanityApiResponse);

            when(() => mockNakamaBaseClient.updateGroup(
                  groupId: any(named: 'groupId'),
                  session: any(named: 'session'),
                  name: any(named: 'name'),
                  description: any(named: 'description'),
                  open: any(named: 'open'),
                  langTag: any(named: 'langTag'),
                )).thenAnswer((_) async {});
          },
          build: () => GroupUpdateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          seed: () => const GroupUpdateState(
            name: ShortText.dirty(''),
            description: LongText.dirty(''),
            open: Toggle.dirty(false),
          ),
          act: (bloc) => bloc.add(const SaveForm('group_123')),
          verify: (bloc) {
            verify(() => mockProfanityApi.scan('')).called(2);
            verify(() => mockNakamaBaseClient.updateGroup(
                  groupId: 'group_123',
                  session: mockSession,
                  name: '',
                  description: '',
                  open: false,
                  langTag: 'en',
                )).called(1);
          },
        );
      });

      group('FormzMixin', () {
        test('isValid returns true when all inputs are valid', () {
          const state = GroupUpdateState(
            name: ShortText.dirty('Valid Name'),
            description: LongText.dirty('Valid Description'),
            open: Toggle.dirty(true),
          );

          expect(state.isValid, true);
        });

        test('inputs includes name and description', () {
          const state = GroupUpdateState(
            name: ShortText.dirty('Test Name'),
            description: LongText.dirty('Test Description'),
          );

          expect(state.inputs, [state.name, state.description]);
        });
      });

      group('copyWith', () {
        test('returns object with updated values', () {
          const state = GroupUpdateState(
            name: ShortText.dirty('old name'),
            description: LongText.dirty('old description'),
            open: Toggle.dirty(false),
            status: FormzSubmissionStatus.initial,
            success: 'old success',
            isLoading: false,
            error: 'old error',
          );

          final newState = state.copyWith(
            name: const ShortText.dirty('new name'),
            description: const LongText.dirty('new description'),
            open: const Toggle.dirty(true),
            status: FormzSubmissionStatus.success,
            success: 'new success',
            isLoading: true,
            error: 'new error',
          );

          expect(newState.name, const ShortText.dirty('new name'));
          expect(newState.description, const LongText.dirty('new description'));
          expect(newState.open, const Toggle.dirty(true));
          expect(newState.status, FormzSubmissionStatus.success);
          expect(newState.success, 'new success');
          expect(newState.isLoading, true);
          expect(newState.error, 'new error');
        });
      });

      group('props', () {
        test('includes all properties', () {
          const state = GroupUpdateState(
            name: ShortText.dirty('test name'),
            description: LongText.dirty('test description'),
            open: Toggle.dirty(true),
            status: FormzSubmissionStatus.success,
            success: 'test success',
            isLoading: true,
            error: 'test error',
          );

          expect(
            state.props,
            [
              const ShortText.dirty('test name'),
              const LongText.dirty('test description'),
              const Toggle.dirty(true),
              FormzSubmissionStatus.success,
              'test success',
              true,
              'test error',
            ],
          );
        });

        test('equality works correctly', () {
          const state1 = GroupUpdateState(
            name: ShortText.dirty('test'),
            description: LongText.dirty('test'),
            open: Toggle.dirty(true),
            status: FormzSubmissionStatus.success,
            success: 'success',
            isLoading: true,
            error: 'error',
          );

          const state2 = GroupUpdateState(
            name: ShortText.dirty('test'),
            description: LongText.dirty('test'),
            open: Toggle.dirty(true),
            status: FormzSubmissionStatus.success,
            success: 'success',
            isLoading: true,
            error: 'error',
          );

          const state3 = GroupUpdateState(
            name: ShortText.dirty('different'),
            description: LongText.dirty('test'),
            open: Toggle.dirty(true),
            status: FormzSubmissionStatus.success,
            success: 'success',
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

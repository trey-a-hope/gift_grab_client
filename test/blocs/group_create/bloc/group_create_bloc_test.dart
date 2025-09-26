import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:gift_grab_client/data/constants/feedback_messages.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/group_create/group_create.dart';
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
    GroupCreateBloc,
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

      group('NameChanged', () {
        blocTest<GroupCreateBloc, GroupCreateState>(
          'updates name field with dirty value',
          build: () => GroupCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          act: (bloc) => bloc.add(const NameChanged('Test Group')),
          expect: () => [
            const GroupCreateState(
              name: ShortText.dirty('Test Group'),
            ),
          ],
        );

        blocTest<GroupCreateBloc, GroupCreateState>(
          'updates name field multiple times',
          build: () => GroupCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          act: (bloc) => bloc
            ..add(const NameChanged('First Name'))
            ..add(const NameChanged('Second Name')),
          expect: () => [
            const GroupCreateState(
              name: ShortText.dirty('First Name'),
            ),
            const GroupCreateState(
              name: ShortText.dirty('Second Name'),
            ),
          ],
        );
      });

      group('DescriptionChanged', () {
        blocTest<GroupCreateBloc, GroupCreateState>(
          'updates description field with dirty value',
          build: () => GroupCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          act: (bloc) => bloc.add(const DescriptionChanged('Test Description')),
          expect: () => [
            const GroupCreateState(
              description: LongText.dirty('Test Description'),
            ),
          ],
        );
      });

      group('MaxCountChanged', () {
        blocTest<GroupCreateBloc, GroupCreateState>(
          'updates maxCount field with dirty value',
          build: () => GroupCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          act: (bloc) => bloc.add(const MaxCountChanged(10)),
          expect: () => [
            const GroupCreateState(
              maxCount: Range.dirty(10),
            ),
          ],
        );
      });

      group('OpenChanged', () {
        blocTest<GroupCreateBloc, GroupCreateState>(
          'updates open field with dirty value',
          build: () => GroupCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          act: (bloc) => bloc.add(const OpenChanged(true)),
          expect: () => [
            const GroupCreateState(
              open: Toggle.dirty(true),
            ),
          ],
        );
      });

      group('SaveForm', () {
        blocTest<GroupCreateBloc, GroupCreateState>(
          'successfully creates group with valid input',
          setUp: () {
            when(() => mockProfanityApi.scan(any()))
                .thenAnswer((_) async => cleanProfanityApiResponse);

            when(() => mockNakamaBaseClient.createGroup(
                  session: any(named: 'session'),
                  name: any(named: 'name'),
                  description: any(named: 'description'),
                  maxCount: any(named: 'maxCount'),
                  open: any(named: 'open'),
                )).thenAnswer((_) async => FakeGroup());
          },
          build: () => GroupCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          seed: () => const GroupCreateState(
            name: ShortText.dirty('Clean Name'),
            description: LongText.dirty('Clean Description'),
            maxCount: Range.dirty(5),
            open: Toggle.dirty(true),
          ),
          act: (bloc) => bloc.add(const SaveForm()),
          expect: () => [
            const GroupCreateState(
              name: ShortText.dirty('Clean Name'),
              description: LongText.dirty('Clean Description'),
              maxCount: Range.dirty(5),
              open: Toggle.dirty(true),
              status: FormzSubmissionStatus.inProgress,
            ),
            const GroupCreateState(
              name: ShortText.dirty('Clean Name'),
              description: LongText.dirty('Clean Description'),
              maxCount: Range.dirty(5),
              open: Toggle.dirty(true),
              status: FormzSubmissionStatus.success,
              success: FeedbackMessages.groupCreateSuccess,
            ),
          ],
        );

        blocTest<GroupCreateBloc, GroupCreateState>(
          'verifies correct parameters are passed to createGroup',
          setUp: () {
            when(() => mockProfanityApi.scan(any()))
                .thenAnswer((_) async => cleanProfanityApiResponse);

            when(() => mockNakamaBaseClient.createGroup(
                  session: any(named: 'session'),
                  name: any(named: 'name'),
                  description: any(named: 'description'),
                  maxCount: any(named: 'maxCount'),
                  open: any(named: 'open'),
                )).thenAnswer((_) async => FakeGroup());
          },
          build: () => GroupCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          seed: () => const GroupCreateState(
            name: ShortText.dirty('Test Group'),
            description: LongText.dirty('Test Description'),
            maxCount: Range.dirty(8),
            open: Toggle.dirty(false),
          ),
          act: (bloc) => bloc.add(const SaveForm()),
          verify: (bloc) {
            verify(() => mockSessionService.getSession()).called(1);
            verify(() => mockProfanityApi.scan('Test Group')).called(1);
            verify(() => mockProfanityApi.scan('Test Description')).called(1);
            verify(() => mockNakamaBaseClient.createGroup(
                  session: mockSession,
                  name: 'Test Group',
                  description: 'Test Description',
                  maxCount: 8,
                  open: false,
                )).called(1);
          },
        );

        blocTest<GroupCreateBloc, GroupCreateState>(
          'handles profanity in name',
          setUp: () {
            when(() => mockProfanityApi.scan('Profane Name'))
                .thenAnswer((_) async => profaneProfanityApiResponse);
            when(() => mockProfanityApi.scan('Clean Description'))
                .thenAnswer((_) async => cleanProfanityApiResponse);
          },
          build: () => GroupCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          seed: () => const GroupCreateState(
            name: ShortText.dirty('Profane Name'),
            description: LongText.dirty('Clean Description'),
            maxCount: Range.dirty(5),
            open: Toggle.dirty(true),
          ),
          act: (bloc) => bloc.add(const SaveForm()),
          verify: (bloc) {
            expect(bloc.state.error, isNotNull);
            expect(bloc.state.status, FormzSubmissionStatus.initial);
            verifyNever(() => mockNakamaBaseClient.createGroup(
                  session: any(named: 'session'),
                  name: any(named: 'name'),
                  description: any(named: 'description'),
                  maxCount: any(named: 'maxCount'),
                  open: any(named: 'open'),
                ));
          },
        );

        blocTest<GroupCreateBloc, GroupCreateState>(
          'handles profanity in description',
          setUp: () {
            when(() => mockProfanityApi.scan('Clean Name'))
                .thenAnswer((_) async => cleanProfanityApiResponse);
            when(() => mockProfanityApi.scan('Profane Description'))
                .thenAnswer((_) async => profaneProfanityApiResponse);
          },
          build: () => GroupCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          seed: () => const GroupCreateState(
            name: ShortText.dirty('Clean Name'),
            description: LongText.dirty('Profane Description'),
            maxCount: Range.dirty(5),
            open: Toggle.dirty(true),
          ),
          act: (bloc) => bloc.add(const SaveForm()),
          verify: (bloc) {
            expect(bloc.state.error, isNotNull);
            expect(bloc.state.status, FormzSubmissionStatus.initial);
          },
        );

        blocTest<GroupCreateBloc, GroupCreateState>(
          'handles error when session service fails',
          setUp: () {
            when(() => mockSessionService.getSession())
                .thenThrow(Exception('Session failed'));
          },
          build: () => GroupCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          seed: () => const GroupCreateState(
            name: ShortText.dirty('Test Name'),
            description: LongText.dirty('Test Description'),
          ),
          act: (bloc) => bloc.add(const SaveForm()),
          verify: (bloc) {
            expect(bloc.state.error, isNotNull);
            expect(bloc.state.status, FormzSubmissionStatus.initial);
          },
        );

        blocTest<GroupCreateBloc, GroupCreateState>(
          'handles error when profanity API fails',
          setUp: () {
            when(() => mockProfanityApi.scan(any()))
                .thenThrow(Exception('API failed'));
          },
          build: () => GroupCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          seed: () => const GroupCreateState(
            name: ShortText.dirty('Test Name'),
            description: LongText.dirty('Test Description'),
          ),
          act: (bloc) => bloc.add(const SaveForm()),
          verify: (bloc) {
            expect(bloc.state.error, isNotNull);
            expect(bloc.state.status, FormzSubmissionStatus.initial);
          },
        );

        blocTest<GroupCreateBloc, GroupCreateState>(
          'handles error when createGroup fails',
          setUp: () {
            when(() => mockProfanityApi.scan(any()))
                .thenAnswer((_) async => cleanProfanityApiResponse);

            when(() => mockNakamaBaseClient.createGroup(
                  session: any(named: 'session'),
                  name: any(named: 'name'),
                  description: any(named: 'description'),
                  maxCount: any(named: 'maxCount'),
                  open: any(named: 'open'),
                )).thenThrow(Exception('Create group failed'));
          },
          build: () => GroupCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          seed: () => const GroupCreateState(
            name: ShortText.dirty('Test Name'),
            description: LongText.dirty('Test Description'),
          ),
          act: (bloc) => bloc.add(const SaveForm()),
          verify: (bloc) {
            expect(bloc.state.error, isNotNull);
            expect(bloc.state.status, FormzSubmissionStatus.initial);
          },
        );

        blocTest<GroupCreateBloc, GroupCreateState>(
          'resets state when starting a new save operation',
          setUp: () {
            when(() => mockProfanityApi.scan(any()))
                .thenAnswer((_) async => cleanProfanityApiResponse);

            when(() => mockNakamaBaseClient.createGroup(
                  session: any(named: 'session'),
                  name: any(named: 'name'),
                  description: any(named: 'description'),
                  maxCount: any(named: 'maxCount'),
                  open: any(named: 'open'),
                )).thenAnswer((_) async => FakeGroup());
          },
          build: () => GroupCreateBloc(
            mockNakamaBaseClient,
            mockSessionService,
            mockProfanityApi,
          ),
          seed: () => const GroupCreateState(
            name: ShortText.dirty('Test Name'),
            description: LongText.dirty('Test Description'),
            error: 'Previous error',
            status: FormzSubmissionStatus.failure,
          ),
          act: (bloc) => bloc.add(const SaveForm()),
          verify: (bloc) {
            expect(bloc.state.error, isNull);
            expect(bloc.state.status, FormzSubmissionStatus.success);
            expect(bloc.state.success, FeedbackMessages.groupCreateSuccess);
          },
        );
      });
    },
  );
}

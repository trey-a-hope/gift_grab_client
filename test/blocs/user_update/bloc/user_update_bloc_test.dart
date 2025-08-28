import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/user_update/user_update.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nakama/nakama.dart';

class MockSessionService extends Mock implements SessionService {}

class MockAccount extends Mock implements Account {}

class MockUser extends Mock implements User {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    UserUpdateBloc,
    () {
      late MockSessionService mockSessionService;
      late MockAccount mockAccount;
      late MockUser mockUser;

      setUp(() {
        mockSessionService = MockSessionService();
        mockAccount = MockAccount();
        mockUser = MockUser();

        FlutterSecureStorage.setMockInitialValues({});
      });

      group(Init, () {
        blocTest<UserUpdateBloc, UserUpdateState>(
          'emits state with username from account when username exists',
          setUp: () {
            when(() => mockAccount.user).thenReturn(mockUser);
            when(() => mockUser.username).thenReturn('testUser');
          },
          build: () => UserUpdateBloc(
            mockAccount,
            mockSessionService,
          ),
          seed: () => const UserUpdateState(),
          act: (bloc) => bloc.add(const Init()),
          expect: () => [
            const UserUpdateState(
              username: ShortText.dirty('testUser'),
              status: FormzSubmissionStatus.initial,
            ),
          ],
        );

        blocTest<UserUpdateBloc, UserUpdateState>(
          'emits state with empty username when account username is null',
          setUp: () {
            when(() => mockAccount.user).thenReturn(mockUser);
            when(() => mockUser.username).thenReturn(null);
          },
          build: () => UserUpdateBloc(
            mockAccount,
            mockSessionService,
          ),
          seed: () => const UserUpdateState(),
          act: (bloc) => bloc.add(const Init()),
          expect: () => [
            const UserUpdateState(
              username: ShortText.dirty(''),
              status: FormzSubmissionStatus.initial,
            ),
          ],
        );
      });

      group(UsernameChange, () {
        blocTest<UserUpdateBloc, UserUpdateState>(
          'emits state with updated username',
          build: () => UserUpdateBloc(
            mockAccount,
            mockSessionService,
          ),
          seed: () => const UserUpdateState(),
          act: (bloc) => bloc.add(const UsernameChange('newUsername')),
          expect: () => [
            const UserUpdateState(
              username: ShortText.dirty('newUsername'),
            ),
          ],
        );

        blocTest<UserUpdateBloc, UserUpdateState>(
          'emits state with empty username when username is empty',
          build: () => UserUpdateBloc(
            mockAccount,
            mockSessionService,
          ),
          seed: () => const UserUpdateState(),
          act: (bloc) => bloc.add(const UsernameChange('')),
          expect: () => [
            const UserUpdateState(
              username: ShortText.dirty(''),
            ),
          ],
        );
      });

      group(SaveForm, () {
        blocTest<UserUpdateBloc, UserUpdateState>(
          'emits state with inProgress status',
          build: () => UserUpdateBloc(
            mockAccount,
            mockSessionService,
          ),
          seed: () => const UserUpdateState(),
          act: (bloc) => bloc.add(const SaveForm()),
          expect: () => [
            const UserUpdateState(
              status: FormzSubmissionStatus.inProgress,
            ),
          ],
        );

        blocTest<UserUpdateBloc, UserUpdateState>(
          'emits state with inProgress status from existing state',
          build: () => UserUpdateBloc(
            mockAccount,
            mockSessionService,
          ),
          seed: () => const UserUpdateState(
            username: ShortText.dirty('existingUser'),
            status: FormzSubmissionStatus.initial,
          ),
          act: (bloc) => bloc.add(const SaveForm()),
          expect: () => [
            const UserUpdateState(
              username: ShortText.dirty('existingUser'),
              status: FormzSubmissionStatus.inProgress,
            ),
          ],
        );
      });
    },
  );
}

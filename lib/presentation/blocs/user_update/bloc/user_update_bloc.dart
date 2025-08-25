import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:nakama/nakama.dart';

part 'user_update_event.dart';
part 'user_update_state.dart';

class UserUpdateBloc extends Bloc<UserUpdateEvent, UserUpdateState> {
  final Account account;
  final SessionService sessionService;

  UserUpdateBloc(
    this.account,
    this.sessionService,
  ) : super(const UserUpdateState()) {
    on<Init>(_onInit);
    on<UsernameChange>(_onUsernameChange);
    on<SaveForm>(_onSaveForm);
  }

  Future<void> _onInit(
    Init event,
    Emitter<UserUpdateState> emit,
  ) async =>
      emit(
        state.copyWith(
          username: ShortText.dirty(
            account.user.username ?? '',
          ),
          status: FormzSubmissionStatus.initial,
        ),
      );

  Future<void> _onUsernameChange(
    UsernameChange event,
    Emitter<UserUpdateState> emit,
  ) async =>
      emit(
        state.copyWith(
          username: ShortText.dirty(event.username),
        ),
      );

  Future<void> _onSaveForm(
    SaveForm event,
    Emitter<UserUpdateState> emit,
  ) async =>
      emit(
        state.copyWith(status: FormzSubmissionStatus.inProgress),
      );
}

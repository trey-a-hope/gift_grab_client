import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:nakama/nakama.dart';
import 'package:profanity_api/profanity_api.dart';

part 'group_create_event.dart';
part 'group_create_state.dart';

class GroupCreateBloc extends Bloc<GroupCreateEvent, GroupCreateState> {
  final NakamaBaseClient client;
  final SessionService sessionService;
  final ProfanityApi profanityApi;

  GroupCreateBloc(
    this.client,
    this.sessionService,
    this.profanityApi,
  ) : super(const GroupCreateState()) {
    on<NameChanged>(_onNameChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<MaxCountChanged>(_onMaxCountChanged);
    on<OpenChanged>(_onOpenChanged);
    on<SaveForm>(_onSaveForm);
  }

  Future<void> _onNameChanged(
    NameChanged event,
    Emitter<GroupCreateState> emit,
  ) async =>
      emit(state.copyWith(name: ShortText.dirty(event.val)));

  Future<void> _onDescriptionChanged(
    DescriptionChanged event,
    Emitter<GroupCreateState> emit,
  ) async =>
      emit(state.copyWith(description: LongText.dirty(event.val)));

  Future<void> _onMaxCountChanged(
    MaxCountChanged event,
    Emitter<GroupCreateState> emit,
  ) async =>
      emit(state.copyWith(maxCount: Range.dirty(event.val)));

  Future<void> _onOpenChanged(
    OpenChanged event,
    Emitter<GroupCreateState> emit,
  ) async =>
      emit(state.copyWith(open: Toggle.dirty(event.val)));

  Future<void> _onSaveForm(
    SaveForm event,
    Emitter<GroupCreateState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

          final session = await sessionService.getSession();

          final nameRes = await profanityApi.scan(state.name.value);
          final descriptionRes =
              await profanityApi.scan(state.description.value);

          if (nameRes.isProfanity || descriptionRes.isProfanity) {
            throw Exception('Profanity and bad words are not welcomed here');
          }

          final newGroup = await client.createGroup(
            session: session,
            name: state.name.value,
            description: state.description.value,
            maxCount: state.maxCount.value,
            open: state.open.value,
          );

          emit(
            state.copyWith(
              success: 'Group ${newGroup.name ?? ''} created',
              status: FormzSubmissionStatus.success,
            ),
          );
        },
        emit: emit,
        state: state,
      );
}

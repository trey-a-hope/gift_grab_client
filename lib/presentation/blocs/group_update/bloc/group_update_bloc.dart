import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:gift_grab_client/data/constants/feedback_messages.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:nakama/nakama.dart';
import 'package:profanity_api/profanity_api.dart';

part 'group_update_event.dart';
part 'group_update_state.dart';

class GroupUpdateBloc extends Bloc<GroupUpdateEvent, GroupUpdateState> {
  final NakamaBaseClient client;
  final SessionService sessionService;
  final ProfanityApi profanityApi;

  GroupUpdateBloc(
    this.client,
    this.sessionService,
    this.profanityApi,
  ) : super(const GroupUpdateState()) {
    on<InitForm>(_onInitForm);
    on<NameChanged>(_onNameChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<OpenChanged>(_onOpenChanged);
    on<SaveForm>(_onSaveForm);
  }

  Future<void> _onInitForm(
    InitForm event,
    Emitter<GroupUpdateState> emit,
  ) async =>
      emit(
        state.copyWith(
          name: ShortText.dirty(event.group.name ?? ''),
          description: LongText.dirty(event.group.description ?? ''),
          open: Toggle.dirty(event.group.open.falseIfNull()),
        ),
      );

  Future<void> _onNameChanged(
    NameChanged event,
    Emitter<GroupUpdateState> emit,
  ) async =>
      emit(state.copyWith(name: ShortText.dirty(event.val)));

  Future<void> _onDescriptionChanged(
    DescriptionChanged event,
    Emitter<GroupUpdateState> emit,
  ) async =>
      emit(state.copyWith(description: LongText.dirty(event.val)));

  Future<void> _onOpenChanged(
    OpenChanged event,
    Emitter<GroupUpdateState> emit,
  ) async =>
      emit(state.copyWith(open: Toggle.dirty(event.val)));

  Future<void> _onSaveForm(
    SaveForm event,
    Emitter<GroupUpdateState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

          final session = await sessionService.getSession();

          final nameRes = await profanityApi.scan(state.name.value);
          final descriptionRes =
              await profanityApi.scan(state.description.value);

          if (nameRes.isProfanity || descriptionRes.isProfanity) {
            throw Exception(FeedbackMessages.profanity);
          }

          await client.updateGroup(
            groupId: event.groupId,
            session: session,
            name: state.name.value,
            description: state.description.value,
            open: state.open.value,
            langTag: 'en',
          );

          emit(
            state.copyWith(
              success: 'Group updated',
              status: FormzSubmissionStatus.success,
            ),
          );
        },
        emit: emit,
        state: state,
      );
}

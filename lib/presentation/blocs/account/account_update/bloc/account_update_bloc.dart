import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/domain/services/social_auth_service.dart';
import 'package:nakama/nakama.dart';

part 'account_update_event.dart';
part 'account_update_state.dart';

class AccountUpdateBloc extends Bloc<AccountUpdateEvent, AccountUpdateState> {
  final Account account;
  final SessionService sessionService;
  final NakamaBaseClient client;
  final SocialAuthService socialAuthService;

  AccountUpdateBloc(
    this.account,
    this.sessionService,
    this.client,
    this.socialAuthService,
  ) : super(const AccountUpdateState()) {
    on<UpdateAccount>(_onUpdateAccount);
    on<LinkEmail>(_onLinkEmail);
    on<UnlinkEmail>(_onUnlinkEmail);
    on<LinkGoogle>(_onLinkGoogle);
    on<UnlinkGoogle>(_onUnlinkGoogle);
    on<LinkApple>(_onLinkApple);
    on<UnlinkApple>(_onUnlinkApple);
  }

  Future<void> _onUpdateAccount(
    UpdateAccount event,
    Emitter<AccountUpdateState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          await client.updateAccount(
            session: session,
            username: event.username,
          );

          emit(state.copyWith(
            success: Globals.feedbackMessages.accountUpdateSuccess,
          ));
        },
        emit: emit,
        state: state,
      );

  Future<void> _onLinkEmail(
    LinkEmail event,
    Emitter<AccountUpdateState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          await client.linkEmail(
            session: session,
            email: event.email,
            password: event.password,
          );

          emit(
            state.copyWith(
              success: Globals.feedbackMessages.accountLinkEmailSuccess,
            ),
          );
        },
        emit: emit,
        state: state,
      );

  Future<void> _onUnlinkEmail(
    UnlinkEmail event,
    Emitter<AccountUpdateState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          final email = account.email;

          if (email == null) {
            throw Exception(
              Globals.feedbackMessages.accountEmailNull,
            );
          }

          await client.unlinkEmail(
            session: session,
            email: email,
            password: '', //Note, password is required but can be empty
          );

          emit(state.copyWith(
              success: Globals.feedbackMessages.accountUnlinkEmailSuccess));
        },
        emit: emit,
        state: state,
      );

  Future<void> _onLinkGoogle(
    LinkGoogle event,
    Emitter<AccountUpdateState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          final idToken = await socialAuthService.getGoogleToken();

          if (idToken == null) {
            emit(state.copyWith());
            return;
          }

          await client.linkGoogle(session: session, token: idToken);

          emit(
            state.copyWith(
              success: Globals.feedbackMessages.accountLinkGoogle,
            ),
          );
        },
        emit: emit,
        state: state,
      );

  Future<void> _onUnlinkGoogle(
    UnlinkGoogle event,
    Emitter<AccountUpdateState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          final idToken = await socialAuthService.getGoogleToken();

          if (idToken == null) {
            emit(state.copyWith());
            return;
          }

          await client.unlinkGoogle(session: session, token: idToken);

          emit(
            state.copyWith(
              success: Globals.feedbackMessages.accountUnlinkGoogle,
            ),
          );
        },
        emit: emit,
        state: state,
      );

  Future<void> _onLinkApple(
    LinkApple event,
    Emitter<AccountUpdateState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          final idToken = await socialAuthService.getAppleToken();

          if (idToken == null) {
            emit(state.copyWith());
            return;
          }

          await client.linkApple(session: session, token: idToken);

          emit(state.copyWith(
            success: Globals.feedbackMessages.accountLinkApple,
          ));
        },
        emit: emit,
        state: state,
      );

  Future<void> _onUnlinkApple(
    UnlinkApple event,
    Emitter<AccountUpdateState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          final idToken = await socialAuthService.getAppleToken();

          if (idToken == null) {
            emit(state.copyWith());
            return;
          }

          await client.unlinkApple(session: session, token: idToken);

          emit(state.copyWith(
            success: Globals.feedbackMessages.accountUnlinkApple,
          ));
        },
        emit: emit,
        state: state,
      );
}

import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/data/constants/feedback_messages.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/domain/services/social_auth_service.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:nakama/nakama.dart';
import 'package:profanity_api/profanity_api.dart';

part 'account_update_event.dart';
part 'account_update_state.dart';

class AccountUpdateBloc extends Bloc<AccountUpdateEvent, AccountUpdateState> {
  final Account account;
  final SessionService sessionService;
  final NakamaBaseClient client;
  final SocialAuthService socialAuthService;
  final ProfanityApi profanityApi;

  AccountUpdateBloc(
    this.account,
    this.sessionService,
    this.client,
    this.socialAuthService,
    this.profanityApi,
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

          final profanityResponse = await profanityApi.scan(event.username);

          if (profanityResponse.isProfanity) {
            throw Exception(FeedbackMessages.profanity);
          }

          await client.updateAccount(
            session: session,
            username: event.username,
          );

          emit(state.copyWith(success: 'Account updated successfully'));
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
            state.copyWith(success: 'Email linked successfully'),
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
            throw Exception('Account email is null');
          }

          await client.unlinkEmail(
            session: session,
            email: email,
            password: '',
          );

          emit(
            state.copyWith(success: 'Email unlinked successfully'),
          );
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

          emit(state.copyWith(success: 'Google account linked successfully'));
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

          emit(state.copyWith(success: 'Google account unlinked successfully'));
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

          emit(state.copyWith(success: 'Apple account linked successfully'));
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

          emit(state.copyWith(success: 'Apple account unlinked successfully'));
        },
        emit: emit,
        state: state,
      );
}

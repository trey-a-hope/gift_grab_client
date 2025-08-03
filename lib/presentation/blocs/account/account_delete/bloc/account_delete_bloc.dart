import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/data/enums/rpc_functions.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:nakama/nakama.dart';

part 'account_delete_event.dart';
part 'account_delete_state.dart';

class AccountDeleteBloc extends Bloc<AccountDeleteEvent, AccountDeleteState> {
  final NakamaBaseClient client;
  final SessionService sessionService;
  final AuthCubit authCubit;

  AccountDeleteBloc(
    this.client,
    this.sessionService,
    this.authCubit,
  ) : super(const AccountDeleteState()) {
    on<DeleteAccount>(_onDeleteAccount);
  }

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<AccountDeleteState> emit,
  ) async =>
      await runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          await client.rpc(
            session: session,
            id: RPCFunction.ACCOUNT_DELETE.id,
          );

          await authCubit.logout();

          emit(
            state.copyWith(
              success: Globals.feedbackMessages.accountDeleteSuccess,
            ),
          );
        },
        emit: emit,
        state: state,
      );
}

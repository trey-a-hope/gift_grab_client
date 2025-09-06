import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:nakama/nakama.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';

part 'account_read_event.dart';
part 'account_read_state.dart';

class AccountReadBloc extends Bloc<AccountReadEvent, AccountReadState> {
  final NakamaBaseClient client;
  final SessionService sessionService;

  AccountReadBloc(
    this.client,
    this.sessionService,
  ) : super(const AccountReadState()) {
    on<ReadAccount>(_onReadAccount);
  }

  Future<void> _onReadAccount(
      ReadAccount event, Emitter<AccountReadState> emit) async {
    await runWithErrorHandling(
      action: () async {
        emit(state.copyWith(isLoading: true));

        final session = await sessionService.getSession();

        final account = await client.getAccount(session);

        emit(state.copyWith(account: account));
      },
      emit: emit,
      state: state,
    );
  }
}

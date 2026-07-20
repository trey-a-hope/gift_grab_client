import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:nakama/nakama.dart';
import 'package:signals/signals_flutter.dart';

class AccountReadController {
  final NakamaBaseClient client;
  final SessionService sessionService;

  late final FutureSignal<Account> accountSignal;

  // TODO: (Need to refresh this when user changes)
  AccountReadController(this.client, this.sessionService) {
    accountSignal = futureSignal<Account>(() async {
      final session = await sessionService.getSession();
      final account = await client.getAccount(session);
      return account;
    });
  }
}

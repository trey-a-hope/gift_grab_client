import 'package:gift_grab_client/core/logging.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:nakama/nakama.dart';
import 'package:signals/signals_flutter.dart';

class AccountReadController {
  final NakamaBaseClient client;
  final SessionService sessionService;

  late final FutureSignal<Account> accountSignal;

  // TODO (Trey) - Have this signal listen to changes on the AuthController.
  AccountReadController(this.client, this.sessionService) {
    accountSignal = futureSignal<Account>(() async {
      final session = (await sessionService.getSession()).fold(
        (success) => success,
        (error) => throw error,
      );
      final account = await client.getAccount(session);
      logger.i('Welcome back, ${account.user.username}!');
      return account;
    });
  }
}

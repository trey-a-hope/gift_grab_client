import 'package:gift_grab_client/core/logging.dart';
import 'package:gift_grab_client/domain/services/post_hog_service.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/controllers/auth_controller.dart';
import 'package:nakama/nakama.dart';
import 'package:signals/signals_flutter.dart';

/// Controller responsible for fetching and managing the Nakama Account data.
/// It reactive-ly refreshes the account data when the user signs in.
class AccountReadController {
  final NakamaBaseClient _client;
  final SessionService _sessionService;
  final AuthController _authController;
  final PostHogService _postHogService;

  /// FutureSignal that loads and holds the user's Nakama Account data.
  late final FutureSignal<Account> accountSignal;

  /// Cleanup function for the authentication listener effect.
  late final EffectCleanup _disposeEffect;

  /// Initializes the AccountReadController and hooks into the [AuthController]
  /// authentication state to auto-refresh the account data.
  AccountReadController(
    this._client,
    this._sessionService,
    this._authController,
    this._postHogService,
  ) {
    accountSignal = futureSignal<Account>(
      _fetchAccount,
      options: const AsyncSignalOptions(
        name: 'AccountReadController.accountSignal',
      ),
    );

    // Watch the authentication status and refresh the account information
    // whenever the user successfully signs in.
    _disposeEffect = effect(() {
      final authState = _authController.isAuthenticated.value;

      if (authState case AsyncData(value: true)) {
        logger.d('Auth state changed to authenticated, refreshing account');
        accountSignal.refresh();
      } else if (authState case AsyncData(value: false)) {
        logger.d('User logged out');
      }
    });
  }

  /// Fetches the user's account from Nakama using the saved session.
  Future<Account> _fetchAccount() async {
    final sessionResult = await _sessionService.getSession();

    return sessionResult.fold(
      (session) async {
        final account = await _client.getAccount(session);
        logger.i('Welcome back, ${account.user.username}!');
        return account;
      },
      (error) {
        logger.e('Error getting session: $error');
        _postHogService.errors.error(error, StackTrace.current, null);
        throw error;
      },
    );
  }

  /// Cleans up the authentication state listener effect.
  void dispose() {
    _disposeEffect();
  }
}

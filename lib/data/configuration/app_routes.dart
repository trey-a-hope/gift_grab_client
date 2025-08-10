import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/data/enums/go_routes.dart';
import 'package:gift_grab_client/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:gift_grab_client/presentation/pages/login_page.dart';
import 'package:gift_grab_client/presentation/pages/main_menu_page.dart';
import 'package:gift_grab_client/presentation/pages/settings_page.dart';
import 'package:gift_grab_game/game/gift_grab_game_widget.dart';
import 'package:go_router/go_router.dart';

GoRouter appRouter(BuildContext context) {
  final authCubit = context.read<AuthCubit>();

  return GoRouter(
    initialLocation: '/${GoRoutes.LOGIN.name}',
    refreshListenable: _GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final isAuthenticated = authCubit.state.authenticated;

      if (!isAuthenticated &&
          !state.matchedLocation.contains('/${GoRoutes.LOGIN.name}')) {
        return '/${GoRoutes.LOGIN.name}';
      }

      if (isAuthenticated &&
          state.matchedLocation == '/${GoRoutes.LOGIN.name}') {
        return '/${GoRoutes.MAIN.name}';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/${GoRoutes.LOGIN.name}',
        name: GoRoutes.LOGIN.name,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/${GoRoutes.MAIN.name}',
        name: GoRoutes.MAIN.name,
        builder: (context, state) => const MainMenuPage(),
        routes: [
          GoRoute(
            path: GoRoutes.GAME.name,
            name: GoRoutes.GAME.name,
            builder: (context, state) => GiftGrabGameWidget(
              onEndGame: (score) {
                debugPrint('Score: $score');
              },
            ),
          ),
          GoRoute(
            path: GoRoutes.SETTINGS.name,
            name: GoRoutes.SETTINGS.name,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}

class _GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AuthState?> _subscription;

  _GoRouterRefreshStream(Stream<AuthState?> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

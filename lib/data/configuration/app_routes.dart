import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:gift_grab_client/presentation/cubits/auth/view/login_page.dart';
import 'package:gift_grab_client/presentation/pages/game_page.dart';
import 'package:gift_grab_client/presentation/pages/main_menu_page.dart';
import 'package:gift_grab_client/presentation/pages/settings_page.dart';
import 'package:gift_grab_client/util/stream_to_listenable.dart';
import 'package:go_router/go_router.dart';

GoRouter appRouter(BuildContext context) {
  final authCubit = context.read<AuthCubit>();

  return GoRouter(
    initialLocation: '/${Globals.routes.main}',
    refreshListenable: StreamToListenable([authCubit.stream]),
    redirect: (context, state) {
      final isAuthenticated = authCubit.state.authenticated;

      if (!isAuthenticated && !state.matchedLocation.contains('/login')) {
        return '/login';
      }

      if (isAuthenticated && state.matchedLocation == '/login') {
        return '/main';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/${Globals.routes.login}',
        name: Globals.routes.login,
        builder: (context, state) => LoginPage(authCubit),
      ),
      GoRoute(
        path: '/${Globals.routes.main}',
        name: Globals.routes.main,
        builder: (context, state) => const MainMenuPage(),
        routes: [
          GoRoute(
            path: Globals.routes.game,
            name: Globals.routes.game,
            builder: (context, state) => const GamePage(),
          ),
          GoRoute(
            path: Globals.routes.settings,
            name: Globals.routes.settings,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}

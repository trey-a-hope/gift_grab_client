import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/core/di_container.dart';
import 'package:gift_grab_client/data/enums/go_routes.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/friend_list/view/friends_page.dart';
import 'package:gift_grab_client/presentation/blocs/user_read/view/profile_page.dart';
import 'package:gift_grab_client/presentation/controllers/auth_controller.dart';
import 'package:gift_grab_client/presentation/pages/group/create_group_page.dart';
import 'package:gift_grab_client/presentation/pages/group/groups_page.dart';
import 'package:gift_grab_client/presentation/pages/group/search_groups_page.dart';
import 'package:gift_grab_client/presentation/pages/group/group_details_page.dart';
import 'package:gift_grab_client/presentation/pages/group/edit_group_page.dart';
import 'package:gift_grab_client/presentation/blocs/record_create/bloc/record_create_bloc.dart';
import 'package:gift_grab_client/presentation/blocs/record_list/view/leaderboard_page.dart';
import 'package:gift_grab_client/presentation/blocs/user_list/view/search_users_page.dart';
import 'package:gift_grab_client/presentation/blocs/user_update/view/edit_profile_page.dart';
import 'package:gift_grab_client/presentation/pages/login_page.dart';
import 'package:gift_grab_client/presentation/pages/main_menu_page.dart';
import 'package:gift_grab_client/presentation/pages/settings_page.dart';
import 'package:gift_grab_game/game/gift_grab_game_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:nakama/nakama.dart';
import 'package:signals/signals_flutter.dart';

GoRouter appRouter(BuildContext context) {
  // final clerkAuth = ClerkAuth.of(context, listen: false);
  final _authController = di<AuthController>();
  // final authCubit = context.read<AuthCubit>();
  return GoRouter(
    initialLocation: '/${GoRoutes.LOGIN.name}',
    refreshListenable: Listenable.merge([
      SignalListenable(_authController.isAuthenticated),
    ]),
    redirect: (context, state) {
      // Check both Clerk's and Nakama's authentication status
      final isAuthenticated =
          _authController.isAuthenticated.value.value ?? false;

      final isLoggingIn = state.matchedLocation.contains(
        '/${GoRoutes.LOGIN.name}',
      );

      // 1. Unauthenticated users trying to navigate protected routes -> /login
      if (!isAuthenticated && !isLoggingIn) {
        return '/${GoRoutes.LOGIN.name}';
      }

      // 2. Authenticated users sitting on /login -> /main
      if (isAuthenticated && isLoggingIn) {
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
            builder: (context, state) {
              final recordCreateBloc = RecordCreateBloc(
                getNakamaClient(),
                di<SessionService>(),
              );

              return BlocProvider<RecordCreateBloc>(
                create: (context) => recordCreateBloc,
                child: GiftGrabGameWidget(
                  onEndGame: (score) =>
                      recordCreateBloc.add(SubmitRecord(score)),
                ),
              );
            },
          ),
          GoRoute(
            path: GoRoutes.SETTINGS.name,
            name: GoRoutes.SETTINGS.name,
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '${GoRoutes.PROFILE.name}/:uid',
            name: GoRoutes.PROFILE.name,
            builder: (context, state) {
              final uid = state.pathParameters['uid'];
              if (uid == null) throw Exception('Profile UID null');
              return ProfilePage(uid);
            },
            routes: [
              GoRoute(
                path: GoRoutes.EDIT_PROFILE.name,
                name: GoRoutes.EDIT_PROFILE.name,
                builder: (context, state) => const EditProfilePage(),
              ),
            ],
          ),
          GoRoute(
            path: GoRoutes.SEARCH_USERS.name,
            name: GoRoutes.SEARCH_USERS.name,
            builder: (context, state) => const SearchUsersPage(),
          ),
          GoRoute(
            path: GoRoutes.LEADERBOARD.name,
            name: GoRoutes.LEADERBOARD.name,
            builder: (context, state) => const LeaderboardPage(),
          ),
          GoRoute(
            path: GoRoutes.FRIENDS.name,
            name: GoRoutes.FRIENDS.name,
            builder: (context, state) => const FriendsPage(),
          ),
          GoRoute(
            path: GoRoutes.GROUPS.name,
            name: GoRoutes.GROUPS.name,
            builder: (context, state) => const GroupsPage(),
            routes: [
              GoRoute(
                path: GoRoutes.CREATE_GROUP.name,
                name: GoRoutes.CREATE_GROUP.name,
                builder: (context, state) => const CreateGroupPage(),
              ),
              GoRoute(
                path: '${GoRoutes.GROUP_DETAILS.name}/:group_id',
                name: GoRoutes.GROUP_DETAILS.name,
                builder: (context, state) {
                  final groupId = state.pathParameters['group_id'];
                  if (groupId == null) throw Exception('Group ID null');
                  return GroupDetailsPage(groupId);
                },
                routes: [
                  GoRoute(
                    path: GoRoutes.EDIT_GROUP.name,
                    name: GoRoutes.EDIT_GROUP.name,
                    builder: (context, state) {
                      final group = state.extra as Group;
                      return EditGroupPage(group);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: GoRoutes.SEARCH_GROUPS.name,
                name: GoRoutes.SEARCH_GROUPS.name,
                builder: (context, state) => const SearchGroupsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// class _AuthListenable extends ChangeNotifier {
//   final Listenable listenable;
//   final Stream stream;
//   late final StreamSubscription _subscription;

//   _AuthListenable(this.listenable, this.stream) {
//     listenable.addListener(notifyListeners);
//     _subscription = stream.listen((_) => notifyListeners());
//   }

//   @override
//   void dispose() {
//     listenable.removeListener(notifyListeners);
//     _subscription.cancel();
//     super.dispose();
//   }
// }

class SignalListenable extends ChangeNotifier {
  late final void Function() _dispose;

  SignalListenable(ReadonlySignal signal) {
    // subscribe fires immediately and on every change; returns a disposer
    _dispose = signal.subscribe((_) => notifyListeners());
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }
}

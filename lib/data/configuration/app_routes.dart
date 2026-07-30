import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/core/di_container.dart';
import 'package:gift_grab_client/data/enums/go_routes.dart';
import 'package:gift_grab_client/domain/services/post_hog_service.dart';
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
import 'package:gift_grab_client/presentation/services/modal_service.dart';
import 'package:gift_grab_game/game/gift_grab_game_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:nakama/nakama.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:signals/signals_flutter.dart';

import '../../core/logging.dart';

/// Configures the application router and its navigation hierarchy.
GoRouter appRouter(BuildContext context) {
  final _authController = di<AuthController>();

  return GoRouter(
    // Add PostHog observer to track navigation events.
    observers: [PosthogObserver()],

    // Default to login page.
    initialLocation: '/${GoRoutes.LOGIN.name}',

    // Listens to authentication state changes to trigger router redirects.
    refreshListenable: Listenable.merge([
      SignalListenable(_authController.isAuthenticated),
    ]),

    // Handles authentication-based redirection rules.
    redirect: (context, state) {
      final isAuthenticated =
          _authController.isAuthenticated.value.value ?? false;

      final isLoggingIn = state.matchedLocation.contains(
        '/${GoRoutes.LOGIN.name}',
      );

      // Unauthenticated users trying to navigate protected routes are redirected to login.
      if (!isAuthenticated && !isLoggingIn) {
        return '/${GoRoutes.LOGIN.name}';
      }

      // Authenticated users on the login page are redirected to the main menu.
      if (isAuthenticated && isLoggingIn) {
        return '/${GoRoutes.MAIN.name}';
      }

      return null;
    },

    routes: [
      // ShellRoute provides a global error boundary for Clerk authentication errors.
      ShellRoute(
        builder: (context, state, child) => ClerkErrorListener(
          handler: (context, error) {
            logger.e(error.toString());
            di<ModalService>().shadToastDestructive(
              context,
              title: const Text('ERROR'),
              description: Text(error.argument ?? 'Unknown error'),
            );
          },
          child: child,
        ),
        routes: [
          // Login screen route.
          GoRoute(
            path: '/${GoRoutes.LOGIN.name}',
            name: GoRoutes.LOGIN.name,
            builder: (context, state) => const LoginPage(),
          ),

          // Main authenticated section containing nested features.
          GoRoute(
            path: '/${GoRoutes.MAIN.name}',
            name: GoRoutes.MAIN.name,
            builder: (context, state) => const MainMenuPage(),
            routes: [
              // Gameplay route with its own RecordCreateBloc provider.
              GoRoute(
                path: GoRoutes.GAME.name,
                name: GoRoutes.GAME.name,
                builder: (context, state) {
                  final recordCreateBloc = RecordCreateBloc(
                    getNakamaClient(),
                    di<SessionService>(),
                    di<PostHogService>(),
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

              // Settings page.
              GoRoute(
                path: GoRoutes.SETTINGS.name,
                name: GoRoutes.SETTINGS.name,
                builder: (context, state) => const SettingsPage(),
              ),

              // User Profile details route.
              GoRoute(
                path: '${GoRoutes.PROFILE.name}/:uid',
                name: GoRoutes.PROFILE.name,
                builder: (context, state) {
                  final uid = state.pathParameters['uid'];
                  if (uid == null) throw Exception('Profile UID null');
                  return ProfilePage(uid);
                },
                routes: [
                  // Edit profile details route.
                  GoRoute(
                    path: GoRoutes.EDIT_PROFILE.name,
                    name: GoRoutes.EDIT_PROFILE.name,
                    builder: (context, state) => const EditProfilePage(),
                  ),
                ],
              ),

              // Search users route.
              GoRoute(
                path: GoRoutes.SEARCH_USERS.name,
                name: GoRoutes.SEARCH_USERS.name,
                builder: (context, state) => const SearchUsersPage(),
              ),

              // Leaderboard / global record lists.
              GoRoute(
                path: GoRoutes.LEADERBOARD.name,
                name: GoRoutes.LEADERBOARD.name,
                builder: (context, state) => const LeaderboardPage(),
              ),

              // Friend list page.
              GoRoute(
                path: GoRoutes.FRIENDS.name,
                name: GoRoutes.FRIENDS.name,
                builder: (context, state) => const FriendsPage(),
              ),

              // Group management and exploration sections.
              GoRoute(
                path: GoRoutes.GROUPS.name,
                name: GoRoutes.GROUPS.name,
                builder: (context, state) => const GroupsPage(),
                routes: [
                  // Create group page.
                  GoRoute(
                    path: GoRoutes.CREATE_GROUP.name,
                    name: GoRoutes.CREATE_GROUP.name,
                    builder: (context, state) => const CreateGroupPage(),
                  ),

                  // Specific group details and sub-routes.
                  GoRoute(
                    path: '${GoRoutes.GROUP_DETAILS.name}/:group_id',
                    name: GoRoutes.GROUP_DETAILS.name,
                    builder: (context, state) {
                      final groupId = state.pathParameters['group_id'];
                      if (groupId == null) throw Exception('Group ID null');
                      return GroupDetailsPage(groupId);
                    },
                    routes: [
                      // Edit group page.
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

                  // Search groups page.
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
      ),
    ],
  );
}

/// A helper class that adapts a read-only Signal to a ChangeNotifier.
/// This allows signals to be used directly as refresh listenables in GoRouter.
class SignalListenable extends ChangeNotifier {
  late final void Function() _dispose;

  SignalListenable(ReadonlySignal signal) {
    // Subscribe fires immediately and on every change; returns a disposer.
    _dispose = signal.subscribe((_) => notifyListeners());
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }
}

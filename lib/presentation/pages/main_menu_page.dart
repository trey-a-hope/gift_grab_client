import 'package:flutter/material.dart';
import 'package:gift_grab_client/core/di_container.dart';
import 'package:gift_grab_client/data/configuration/gap_sizes.dart';
import 'package:gift_grab_client/data/enums/go_routes.dart';
import 'package:gift_grab_client/presentation/controllers/account_read_controller.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:go_router/go_router.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accountReadController = di<AccountReadController>();
    accountReadController.accountSignal.reset();
    return const MainMenuView();
  }
}

class MainMenuView extends StatelessWidget {
  const MainMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountReadController = di<AccountReadController>();

    final user = accountReadController.accountSignal.value.value?.user;

    return GGScaffoldWidget(
      title: 'Gift Grab',
      canPop: false,
      actions: [
        IconButton.filledTonal(
          onPressed: () => context.pushNamed(GoRoutes.SEARCH_USERS.name),
          icon: const Icon(Icons.search),
        ),
        GapSizes.smallGap,
        IconButton.filledTonal(
          onPressed: () => context.pushNamed(GoRoutes.SETTINGS.name),
          icon: const Icon(Icons.settings),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Text(
              'Welcome Back, ${user?.username ?? 'No name'}',
              style: theme.textTheme.displaySmall!,
            ),
            Expanded(
              child: FlexGridviewWidget(
                children: [
                  MenuButtonWidget(
                    menuButton: MenuButton.play,
                    onTap: () => context.pushNamed(GoRoutes.GAME.name),
                  ),
                  MenuButtonWidget(
                    menuButton: MenuButton.profile,
                    onTap: () => context.pushNamed(
                      GoRoutes.PROFILE.name,
                      pathParameters: {'uid': user?.id ?? ''},
                    ),
                  ),
                  MenuButtonWidget(
                    menuButton: MenuButton.leaderboard,
                    onTap: () => context.pushNamed(GoRoutes.LEADERBOARD.name),
                  ),
                  MenuButtonWidget(
                    menuButton: MenuButton.friends,
                    onTap: () => context.pushNamed(GoRoutes.FRIENDS.name),
                  ),
                  MenuButtonWidget(
                    menuButton: MenuButton.groups,
                    onTap: () => context.pushNamed(GoRoutes.GROUPS.name),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

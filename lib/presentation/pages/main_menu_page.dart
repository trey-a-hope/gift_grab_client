import 'package:flutter/material.dart';
import 'package:gift_grab_client/data/enums/go_routes.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:go_router/go_router.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainMenuView();
  }
}

class MainMenuView extends StatelessWidget {
  const MainMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return GGScaffoldWidget(
      title: 'Gift Grab',
      canPop: false,
      actions: [
        IconButton.filledTonal(
          onPressed: () => context.pushNamed(
            GoRoutes.SETTINGS.name,
          ),
          icon: const Icon(
            Icons.settings,
          ),
        )
      ],
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: FlexGridviewWidget(
          children: [
            MenuButtonWidget(
              menuButton: MenuButton.play,
              onTap: () => context.pushNamed(GoRoutes.GAME.name),
            )
          ],
        ),
      ),
    );
  }
}

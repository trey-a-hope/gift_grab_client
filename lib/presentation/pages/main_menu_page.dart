import 'package:flutter/material.dart';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/presentation/widgets/flex_gridview_widget.dart';
import 'package:gift_grab_client/presentation/widgets/menu_button/menu_button_widget.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:go_router/go_router.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GGScaffoldWidget(
      title: 'Gift Grab',
      canPop: false,
      actions: [
        IconButton.filledTonal(
          onPressed: () => context.pushNamed(
            Globals.routes.settings,
          ),
          icon: const Icon(Icons.settings),
        ),
      ],
      child: Padding(
        padding: const EdgeInsetsGeometry.all(32),
        child: FlexGridviewWidget(
          children: [
            MenuButtonWidget(
              menuButton: MenuButton.play,
              onTap: () => context.pushNamed(Globals.routes.game),
            )
          ],
        ),
      ),
    );
  }
}

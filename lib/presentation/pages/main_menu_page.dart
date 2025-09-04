import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:gift_grab_client/data/enums/go_routes.dart';
import 'package:gift_grab_client/presentation/blocs/account_read/account_read.dart';
import 'package:gift_grab_client/presentation/extensions/build_context_extensions.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_util/modal_util.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AccountReadBloc>().add(const ReadAccount());
    return const MainMenuView();
  }
}

class MainMenuView extends StatelessWidget {
  const MainMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AccountReadBloc, AccountReadState>(
      builder: (context, state) {
        final user = state.account?.user;

        return GGScaffoldWidget(
          title: 'Gift Grab',
          canPop: false,
          actions: [
            IconButton.filledTonal(
              onPressed: () => context.pushNamed(GoRoutes.SEARCH_USERS.name),
              icon: const Icon(Icons.search),
            ),
            const Gap(8),
            IconButton.filledTonal(
              onPressed: () => context.pushNamed(GoRoutes.SETTINGS.name),
              icon: const Icon(Icons.settings),
            )
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
                        onTap: () => context
                            .pushNamed(GoRoutes.PROFILE.name, pathParameters: {
                          'uid': state.account!.user.id,
                        }),
                      ),
                      MenuButtonWidget(
                        menuButton: MenuButton.leaderboard,
                        onTap: () => context.pushNamed(
                          GoRoutes.LEADERBOARD.name,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
      listener: (context, state) {
        if (state.error != null) {
          ModalUtil.showError(context, title: state.error!);
        }
      },
      listenWhen: (prev, curr) => context.isOnPage(GoRoutes.MAIN.name),
    );
  }
}

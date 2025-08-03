import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/data/enums/go_routes.dart';
import 'package:gift_grab_client/presentation/blocs/account/account_read/bloc/account_read_bloc.dart';
import 'package:gift_grab_client/presentation/extensions/build_context_extensions.dart';
import 'package:gift_grab_ui/widgets/flex_gridview_widget.dart';
import 'package:gift_grab_ui/widgets/gg_scaffold_widget.dart';
import 'package:gift_grab_ui/widgets/menu_button_widget.dart';
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

    return GGScaffoldWidget(
      title: 'Gift Grab',
      canPop: false,
      actions: [
        IconButton.filledTonal(
          onPressed: () => context.pushNamed(
            GoRoutes.SETTINGS.name,
          ),
          icon: const Icon(Icons.settings),
        ),
      ],
      child: BlocConsumer<AccountReadBloc, AccountReadState>(
        builder: (context, state) {
          return state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsetsGeometry.all(32),
                  child: Column(
                    children: [
                      Text(
                        'Welcome Back, ${state.account!.user.username}',
                        style: theme.textTheme.displaySmall!.copyWith(),
                      ),
                      Expanded(
                        child: FlexGridviewWidget(
                          children: [
                            MenuButtonWidget(
                              menuButton: MenuButton.play,
                              onTap: () =>
                                  context.pushNamed(GoRoutes.GAME.name),
                            ),
                            MenuButtonWidget(
                              menuButton: MenuButton.profile,
                              onTap: () => context.pushNamed(
                                GoRoutes.PROFILE.name,
                                pathParameters: {
                                  'uid': state.account!.user.id,
                                },
                              ),
                            ),
                            MenuButtonWidget(
                              menuButton: MenuButton.searchUsers,
                              onTap: () => context.pushNamed(
                                GoRoutes.SEARCH_USERS.name,
                              ),
                            ),
                            MenuButtonWidget(
                              menuButton: MenuButton.leaderboard,
                              onTap: () => context.pushNamed(
                                GoRoutes.LEADERBOARD.name,
                                pathParameters: {
                                  'uid': state.account!.user.id,
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
        },
        listenWhen: (previous, current) => context.isOnPage(GoRoutes.MAIN.name),
        listener: (context, state) {
          if (state.error != null) {
            ModalUtil.showError(context, title: state.error!);
          }
        },
      ),
    );
  }
}

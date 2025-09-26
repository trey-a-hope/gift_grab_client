import 'package:animated_search_bar/animated_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/widgets/user_list_tile.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:modal_util/modal_util.dart';
import 'package:nakama/nakama.dart';

import '../user_list.dart';

class SearchUsersPage extends StatelessWidget {
  const SearchUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserListBloc>(
      create: (context) => UserListBloc(
        getNakamaClient(),
        context.read<SessionService>(),
      ),
      child: const SearchUsersView(),
    );
  }
}

class SearchUsersView extends StatelessWidget {
  const SearchUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = TextEditingController();
    final userListBloc = context.read<UserListBloc>();

    return GGScaffoldWidget(
      title: 'Search Users',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsGeometry.all(32),
            child: AnimatedSearchBar(
              autoFocus: true,
              controller: controller,
              label: 'Enter username',
              labelStyle: theme.textTheme.headlineSmall!,
              searchStyle: theme.textTheme.headlineSmall!,
              onFieldSubmitted: (query) => userListBloc.add(
                SearchUser(query),
              ),
              onChanged: (query) {
                if (query.isEmpty) userListBloc.add(const ClearSearch());
              },
              onClose: () => userListBloc.add(const ClearSearch()),
            ),
          ),
          Expanded(
            child: BlocConsumer<UserListBloc, UserListState>(
              builder: (context, state) {
                final users = state.users;

                return state.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : state.query.isEmpty
                        ? const SizedBox.shrink()
                        : users.isEmpty
                            ? const NoResultsWidget(NoResultsEnum.users)
                            : ListView.builder(
                                itemCount: users.length,
                                itemBuilder: (_, index) => UserListTile(
                                  users[index],
                                ),
                              );
              },
              listener: (context, state) {
                if (state.error != null) {
                  ModalUtil.showError(context, title: state.error!);
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

import 'package:animated_search_bar/animated_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/group_list/group_list.dart';
import 'package:gift_grab_client/presentation/widgets/group_list_tile.dart';
import 'package:gift_grab_client/presentation/widgets/user_list_tile.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:modal_util/modal_util.dart';
import 'package:nakama/nakama.dart';

class SearchGroupsPage extends StatelessWidget {
  const SearchGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GroupListBloc>(
      create: (context) => GroupListBloc(
        null,
        getNakamaClient(),
        context.read<SessionService>(),
      ),
      child: const SearchGroupsView(),
    );
  }
}

class SearchGroupsView extends StatelessWidget {
  const SearchGroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = TextEditingController();
    final groupListBloc = context.read<GroupListBloc>();

    return GGScaffoldWidget(
      title: 'Search Groups',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsGeometry.all(32),
            child: AnimatedSearchBar(
              autoFocus: true,
              controller: controller,
              label: 'Enter name',
              labelStyle: theme.textTheme.headlineSmall!,
              searchStyle: theme.textTheme.headlineSmall!,
              onFieldSubmitted: (query) => groupListBloc.add(
                SearchGroup(query),
              ),
              onChanged: (query) {
                if (query.isEmpty) groupListBloc.add(const ClearSearch());
              },
              onClose: () => groupListBloc.add(const ClearSearch()),
            ),
          ),
          Expanded(
            child: BlocConsumer<GroupListBloc, GroupListState>(
              builder: (context, state) {
                final groups = state.groups;

                return state.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : state.query.isEmpty
                        ? const SizedBox.shrink()
                        : groups.isEmpty
                            ? const NoResultsWidget(NoResultsEnum.myGroups)
                            : ListView.builder(
                                itemCount: groups.length,
                                itemBuilder: (_, index) =>
                                    GroupListTile(groups[index]));
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

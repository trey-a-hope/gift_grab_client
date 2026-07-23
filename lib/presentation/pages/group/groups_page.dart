import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/core/di_container.dart';
import 'package:gift_grab_client/data/configuration/gap_sizes.dart';
import 'package:gift_grab_client/data/enums/go_routes.dart';
import 'package:gift_grab_client/presentation/controllers/account_read_controller.dart';
import 'package:gift_grab_client/presentation/cubits/group_refresh/cubit/group_refresh_cubit.dart';
import 'package:gift_grab_ui/widgets/gg_scaffold_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/extensions/string_extensions.dart';
import 'package:gift_grab_client/presentation/widgets/group_list_tile.dart';
import 'package:gift_grab_ui/widgets/no_results_widget.dart';
import 'package:nakama/nakama.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../blocs/group_list/group_list.dart';

part 'groups_list.dart';

class GroupsPage extends StatelessWidget {
  static const _tabs = ['All Groups', 'My Groups'];

  List<GroupsList> get _tabsContent => [
    GroupsList(key: UniqueKey(), all: true),
    GroupsList(key: UniqueKey(), all: false),
  ];

  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<GroupRefreshCubit, DateTime>(
      builder: (context, state) {
        return GGScaffoldWidget(
          title: 'Groups',
          actions: [
            IconButton.filledTonal(
              onPressed: () => context.pushNamed(GoRoutes.CREATE_GROUP.name),
              icon: const Icon(Icons.add),
            ),
            GapSizes.smallGap,
            IconButton.filledTonal(
              onPressed: () => context.pushNamed(GoRoutes.SEARCH_GROUPS.name),
              icon: const Icon(Icons.search),
            ),
          ],
          child: DefaultTabController(
            length: _tabs.length,
            child: Column(
              children: [
                TabBar(
                  padding: const EdgeInsets.all(8),
                  labelColor: Colors.white,
                  labelStyle: theme.textTheme.displaySmall,
                  indicatorColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  tabs: _tabs
                      .map(
                        (tab) => Text(tab, style: theme.textTheme.titleLarge),
                      )
                      .toList(),
                ),
                Expanded(child: TabBarView(children: _tabsContent)),
              ],
            ),
          ),
        );
      },
    );
  }
}

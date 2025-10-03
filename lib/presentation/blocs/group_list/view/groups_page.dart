import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/data/configuration/gap_sizes.dart';
import 'package:gift_grab_client/data/enums/go_routes.dart';
import 'package:gift_grab_client/presentation/blocs/group_list/view/view.dart';
import 'package:gift_grab_client/presentation/cubits/group_refresh/cubit/group_refresh_cubit.dart';
import 'package:gift_grab_ui/widgets/gg_scaffold_widget.dart';
import 'package:go_router/go_router.dart';

class GroupsPage extends StatelessWidget {
  static const _tabs = [
    'All Groups',
    'My Groups',
  ];

  List<GroupListPage> get _tabsContent => [
        GroupListPage(key: UniqueKey(), all: true),
        GroupListPage(key: UniqueKey(), all: false),
      ];

  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<GroupRefreshCubit, DateTime>(builder: (context, state) {
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
                    .map((tab) => Text(
                          tab,
                          style: theme.textTheme.titleLarge,
                        ))
                    .toList(),
              ),
              Expanded(
                child: TabBarView(
                  children: _tabsContent,
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}

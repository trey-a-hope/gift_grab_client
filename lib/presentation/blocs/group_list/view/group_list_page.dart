import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/account_read/bloc/account_read_bloc.dart';
import 'package:gift_grab_client/presentation/extensions/string_extensions.dart';
import 'package:gift_grab_client/presentation/widgets/group_list_tile.dart';
import 'package:gift_grab_ui/widgets/no_results_widget.dart';
import 'package:nakama/nakama.dart';

import '../group_list.dart';

class GroupListPage extends StatelessWidget {
  final bool all;

  const GroupListPage({required this.all, super.key});

  @override
  Widget build(BuildContext context) {
    final accountReadBloc = context.read<AccountReadBloc>();
    final account = accountReadBloc.state.account!;

    return BlocProvider(
      create: (_) => GroupListBloc(
        all ? null : account.user.id,
        getNakamaClient(),
        context.read<SessionService>(),
      )..add(const InitialFetch()),
      child: const GroupListView(),
    );
  }
}

class GroupListView extends StatelessWidget {
  const GroupListView({super.key});

  @override
  Widget build(BuildContext context) {
    final groupListBloc = context.read<GroupListBloc>();

    return BlocBuilder<GroupListBloc, GroupListState>(
      builder: (context, state) {
        final groups = state.groups;
        final isLoading = state.isLoading;
        final cursor = state.cursor;

        final displayEmpty = isLoading && groups.isEmpty;
        final displayNoResults = !isLoading && groups.isEmpty;
        final displayMoreButton = !isLoading && cursor.nullIfEmpty != null;

        return Column(
          children: [
            Expanded(
              child: displayEmpty
                  ? const SizedBox.shrink()
                  : displayNoResults
                      ? const NoResultsWidget(NoResultsEnum.allGroups)
                      : ListView.builder(
                          itemCount: groups.length,
                          itemBuilder: (context, index) => GroupListTile(
                            groups[index],
                          ),
                        ),
            ),
            if (displayMoreButton) ...[
              Padding(
                padding: const EdgeInsetsGeometry.all(16),
                child: ElevatedButton(
                  onPressed: () => groupListBloc.add(const FetchMore()),
                  child: const Text('More'),
                ),
              )
            ]
          ],
        );
      },
    );
  }
}

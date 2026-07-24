part of 'groups_page.dart';

class GroupsList extends StatelessWidget {
  final bool all;

  const GroupsList({required this.all, super.key});

  @override
  Widget build(BuildContext context) {
    final accountReadController = di<AccountReadController>();
    final account = accountReadController.accountSignal.value.value!;

    return BlocProvider(
      create: (_) => GroupListBloc(
        all ? null : account.user.id,
        getNakamaClient(),
        di<SessionService>(),
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
                      itemBuilder: (context, index) =>
                          GroupListTile(groups[index]),
                    ),
            ),
            if (displayMoreButton) ...[
              Padding(
                padding: const EdgeInsetsGeometry.all(16),
                child: ShadButton(
                  onPressed: () => groupListBloc.add(const FetchMore()),
                  child: const Text('More'),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/account_read/account_read.dart';
import 'package:gift_grab_client/presentation/blocs/record_delete/bloc/record_delete_bloc.dart';
import 'package:gift_grab_client/presentation/blocs/record_list/view/record_list_tile.dart';
import 'package:gift_grab_client/presentation/extensions/date_time_extensions.dart';
import 'package:gift_grab_client/presentation/extensions/string_extensions.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:modal_util/modal_util.dart';
import 'package:nakama/nakama.dart';

import '../record_list.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => RecordListBloc(
            getNakamaClient(),
            context.read<SessionService>(),
          )..add(const InitialFetch()),
        ),
        BlocProvider(
          create: (_) => RecordDeleteBloc(
            getNakamaClient(),
            context.read<SessionService>(),
          ),
        )
      ],
      child: const LeaderboardView(),
    );
  }
}

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recordListBloc = context.read<RecordListBloc>();
    final accountReadBloc = context.read<AccountReadBloc>();
    final account = accountReadBloc.state.account!;

    return BlocListener<RecordDeleteBloc, RecordDeleteState>(
      listener: (context, state) {
        if (state.success != null) {
          ModalUtil.showSuccess(context, title: state.success!);
          recordListBloc.add(const InitialFetch());
        }
      },
      child: BlocBuilder<RecordListBloc, RecordListState>(
        builder: (context, state) {
          final entries = state.entries;

          final displayEmpty = state.isLoading && entries.isEmpty;
          final displayNoResults = !state.isLoading && entries.isEmpty;
          final displayMoreButton =
              state.cursor.nullIfEmpty != null && !state.isLoading;

          return GGScaffoldWidget(
            title: 'Leaderboard',
            child: SafeArea(
              child: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsetsGeometry.all(32),
                      child: Text(
                        'Records for ${DateTime.now().getMonthsDayRange()}',
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                    Expanded(
                      child: displayEmpty
                          ? const SizedBox.shrink()
                          : displayNoResults
                              ? const NoResultsWidget(NoResultsEnum.leaderboard)
                              : ListView.builder(
                                  itemCount: entries.length,
                                  itemBuilder: (context, index) =>
                                      RecordListTile(
                                    account.user.id,
                                    entries[index],
                                  ),
                                ),
                    ),
                    if (displayMoreButton) ...[
                      Padding(
                        padding: const EdgeInsetsGeometry.all(16),
                        child: ElevatedButton(
                          onPressed: () =>
                              recordListBloc.add(const FetchMore()),
                          child: const Text('More'),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

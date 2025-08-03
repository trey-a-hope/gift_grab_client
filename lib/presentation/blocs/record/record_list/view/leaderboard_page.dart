import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/record/record_delete/record_delete.dart';
import 'package:gift_grab_client/presentation/blocs/record/record_list/view/record_list_tile.dart';
import 'package:gift_grab_client/presentation/extensions/date_time_extensions.dart';
import 'package:gift_grab_ui/widgets/gg_scaffold_widget.dart';
import 'package:gift_grab_ui/widgets/no_results_widget.dart';
import 'package:modal_util/modal_util.dart';
import 'package:nakama/nakama.dart';

import '../record_list.dart';

class LeaderboardPage extends StatelessWidget {
  final String uid;
  const LeaderboardPage(this.uid, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => RecordListBloc(
            context.read<SessionService>(),
            getNakamaClient(),
          )..add(const FetchRecords(reset: true)),
        ),
        BlocProvider(
          create: (context) => RecordDeleteBloc(
            context.read<SessionService>(),
            getNakamaClient(),
          ),
        )
      ],
      child: LeaderboardView(uid),
    );
  }
}

class LeaderboardView extends StatelessWidget {
  final String uid;
  const LeaderboardView(this.uid, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recordListBloc = context.read<RecordListBloc>();

    return BlocListener<RecordDeleteBloc, RecordDeleteState>(
      listener: (context, state) {
        if (state.deleted) {
          recordListBloc.add(const FetchRecords(reset: true));
        }
      },
      child: BlocConsumer<RecordListBloc, RecordListState>(
        listener: (context, state) {
          if (state.error != null) {
            ModalUtil.showError(context, title: state.error!);
          }
        },
        builder: (context, state) {
          final entries = state.entries;

          return GGScaffoldWidget(
              title: 'Leaderboard',
              child: SafeArea(
                child: Center(
                  child: state.isLoading
                      ? const CircularProgressIndicator()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Text(
                                'Records for ${DateTime.now().getMonthsDayRange()}',
                                style: theme.textTheme.headlineMedium,
                              ),
                            ),
                            Expanded(
                              child: entries.isEmpty
                                  ? const NoResultsWidget(
                                      NoResultsEnum.leaderboard)
                                  : ListView.builder(
                                      itemCount: entries.length,
                                      itemBuilder: ((context, index) =>
                                          RecordListTile(
                                            uid,
                                            entries[index],
                                          )),
                                    ),
                            ),
                            if (state.cursor != '') ...[
                              ElevatedButton(
                                onPressed: () => recordListBloc.add(
                                  const FetchRecords(reset: false),
                                ),
                                child: const Text(
                                  'More',
                                ),
                              )
                            ]
                          ],
                        ),
                ),
              ));
        },
      ),
    );
  }
}

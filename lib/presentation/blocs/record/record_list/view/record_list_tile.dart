import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:gift_grab_client/domain/entities/leaderboard_entry.dart';
import 'package:gift_grab_client/presentation/blocs/record/record_delete/bloc/record_delete_bloc.dart';
import 'package:gift_grab_client/presentation/extensions/string_extensions.dart';
import 'package:gift_grab_client/presentation/widgets/user_list_tile.dart';
import 'package:modal_util/modal_util.dart';

class RecordListTile extends StatelessWidget {
  final String uid;
  final LeaderboardEntry entry;

  const RecordListTile(this.uid, this.entry, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recordDeleteBloc = context.read<RecordDeleteBloc>();

    return Padding(
      padding: const EdgeInsetsGeometry.all(8),
      child: Row(
        children: [
          Expanded(child: UserListTile(entry.user)),
          if (uid == entry.user.id) ...[
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.red,
              child: Center(
                child: Padding(
                  padding: const EdgeInsetsGeometry.all(4),
                  child: IconButton(
                    onPressed: () async {
                      final confirm = await ModalUtil.showConfirmation(
                        context,
                        title: 'Delete Record',
                        message: 'Are you sure?',
                      );

                      if (confirm != true) {
                        return;
                      }

                      if (!context.mounted) return;

                      recordDeleteBloc.add(const DeleteRecord());
                    },
                    icon: const Icon(
                      Icons.delete,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
            const Gap(16),
          ],
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue,
            child: Center(
              child: Padding(
                padding: const EdgeInsetsGeometry.all(4),
                child: Text(
                  '${entry.record.rank?.ordinal}',
                  style: theme.textTheme.headlineLarge,
                ),
              ),
            ),
          ),
          const Gap(16),
          Card(
            child: Padding(
              padding: const EdgeInsetsGeometry.all(16),
              child: Text(
                '${entry.record.score} gifts',
                style: theme.textTheme.headlineLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

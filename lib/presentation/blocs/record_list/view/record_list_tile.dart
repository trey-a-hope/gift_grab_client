import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/data/configuration/gap_sizes.dart';
import 'package:gift_grab_client/data/constants/label_text.dart';
import 'package:gift_grab_client/domain/entities/leaderboard_entry.dart';
import 'package:gift_grab_client/domain/services/modal_service.dart';
import 'package:gift_grab_client/presentation/blocs/record_delete/record_delete.dart';
import 'package:gift_grab_client/presentation/extensions/string_extensions.dart';
import 'package:gift_grab_client/presentation/widgets/user_list_tile.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';

class RecordListTile extends StatelessWidget {
  final String uid;
  final LeaderboardEntry entry;

  const RecordListTile(this.uid, this.entry, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recordDeleteBloc = context.read<RecordDeleteBloc>();
    final modalService = context.read<ModalService>();

    return Padding(
      padding: const EdgeInsetsGeometry.all(8),
      child: Row(
        children: [
          Expanded(
            child: UserListTile(entry.user),
          ),
          if (uid == entry.user.id) ...[
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.red,
              child: Center(
                child: Padding(
                  padding: const EdgeInsetsGeometry.all(4),
                  child: IconButton(
                    onPressed: () async {
                      final confirm = await modalService.shadConfirmationDialog(
                        context,
                        title: const Text('Delete record'),
                        description: const Text(LabelText.confirm),
                      );

                      if (!confirm.falseIfNull()) return;

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
            GapSizes.mediumGap,
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
          GapSizes.mediumGap,
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

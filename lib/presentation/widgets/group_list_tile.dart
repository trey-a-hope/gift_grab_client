import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:gift_grab_client/data/enums/go_routes.dart';
import 'package:gift_grab_client/presentation/widgets/network_circle_avatar.dart';
import 'package:go_router/go_router.dart';
import 'package:nakama/nakama.dart';

class GroupListTile extends StatelessWidget {
  final Group group;

  const GroupListTile(this.group, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsetsGeometry.all(8),
      child: GestureDetector(
        onTap: () => context.goNamed(
          GoRoutes.GROUP_DETAILS.name,
          pathParameters: {
            'group_id': group.id,
          },
        ),
        child: Row(
          children: [
            NetworkCircleAvatar(
              imgUrl: group.avatarUrl,
              radius: 25,
            ),
            const Gap(16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name ?? 'No Name',
                  style: theme.textTheme.headlineMedium,
                ),
                Text(
                  '(${group.open != null && group.open! ? 'Public' : 'Private'} Group)',
                  style: theme.textTheme.bodyLarge!.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Gap(16),
            CircleAvatar(
              child: Text(
                '${group.edgeCount}/${group.maxCount}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

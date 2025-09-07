import 'package:flutter/material.dart';
import 'package:gift_grab_client/data/enums/go_routes.dart';
import 'package:gift_grab_client/presentation/extensions/user_extensions.dart';
import 'package:go_router/go_router.dart';
import 'package:nakama/nakama.dart';

class UserListTile extends StatelessWidget {
  final User user;

  const UserListTile(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      title: Text(
        user.username ?? 'No name',
        style: theme.textTheme.titleLarge,
      ),
      onTap: () => context.pushNamed(GoRoutes.PROFILE.name, pathParameters: {
        'uid': user.id,
      }),
      leading: user.getCircleAvatar(radius: 25),
    );
  }
}

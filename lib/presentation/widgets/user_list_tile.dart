import 'package:flutter/material.dart';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/data/enums/go_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:nakama/nakama.dart';

class UserListTile extends StatelessWidget {
  final User user;

  const UserListTile(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: () => context.pushNamed(
        GoRoutes.PROFILE.name,
        pathParameters: {
          'uid': user.id,
        },
      ),
      leading: CircleAvatar(
        backgroundImage: Image.network(
          user.avatarUrl?.isEmpty ?? true
              ? Globals.emptyProfile
              : user.avatarUrl!,
        ).image,
      ),
      title: Text(
        user.username ?? 'No Name',
        style: theme.textTheme.titleLarge,
      ),
    );
  }
}

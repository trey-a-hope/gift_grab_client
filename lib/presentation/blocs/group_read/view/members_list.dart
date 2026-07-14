import 'package:flutter/material.dart';
import 'package:gift_grab_client/core/di_container.dart';
import 'package:gift_grab_client/core/logging.dart';
import 'package:gift_grab_client/data/configuration/gap_sizes.dart';
import 'package:gift_grab_client/presentation/controllers/account_read_controller.dart';
import 'package:gift_grab_client/presentation/controllers/group_users_controller.dart';
import 'package:gift_grab_client/presentation/services/modal_service.dart';
import 'package:gift_grab_client/presentation/widgets/network_circle_avatar.dart';
import 'package:nakama/nakama.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

class MembersList extends SignalStatefulWidget {
  final GroupUsersController groupUsersController;

  const MembersList(this.groupUsersController, {super.key});

  @override
  State<MembersList> createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  EffectCleanup? _errorToastListener;
  late final ModalService _modalService;
  late final AccountReadController _accountReadController;

  @override
  void initState() {
    _modalService = di<ModalService>();
    _accountReadController = di<AccountReadController>();

    _errorToastListener = effect(() {
      final error = widget.groupUsersController.groupUsersSignal.value.error;
      if (error != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _modalService.shadToastDestructive(
              context,
              title: Text(error.toString()),
            );
          }
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final uid = _accountReadController.accountSignal.value.value?.user.id;

    if (uid == null) throw Exception();

    return widget.groupUsersController.groupUsersSignal.value.map(
      data: (groupUsers) => Column(
        children: [
          const Text('Members'),
          Expanded(
            child: ListView.builder(
              itemCount: groupUsers.length,
              itemBuilder: (context, index) => _GroupUserListTile(
                me: groupUsers.firstWhere((element) => element.user.id == uid),
                them: groupUsers[index],
              ),
            ),
          ),
        ],
      ),
      error: (e, s) => Center(child: Text('Error loading group members: $e')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _errorToastListener?.call();
    super.dispose();
  }
}

class _GroupUserListTile extends StatelessWidget {
  final GroupUser me;
  final GroupUser them;

  const _GroupUserListTile({required this.me, required this.them});

  @override
  Widget build(BuildContext context) {
    logger.i('Me: ${me.user.username}');
    logger.i('Them: ${them.user.username}');

    final textTheme = ShadTheme.of(context).textTheme;

    return ListTile(
      title: Text(them.user.username ?? 'No name', style: textTheme.h4),
      subtitle: Text(them.state.name, style: textTheme.p),
      leading: NetworkCircleAvatar(imgUrl: them.user.avatarUrl, radius: 50),
      trailing: MembershipPermissions.canKick(me, them)
          ? IconButton(
              onPressed: () => _showOptions(context, them),
              icon: const Icon(Icons.more_horiz),
            )
          : null,
    );
  }

  void _showOptions(BuildContext context, final GroupUser them) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final textTheme = ShadTheme.of(context).textTheme;
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          child: Column(
            children: [
              Text('What would you like to do?', style: textTheme.h4),
              GapSizes.smallGap,
              ListTile(
                leading: const Icon(Icons.delete),
                title: Text('Kick "${them.user.username}"'),
                subtitle: const Text(
                  'Removes the user from the group; they can join again later.',
                ),
                onTap: () {
                  // TODO: Implement kick
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.block),
                title: Text('Ban "${them.user.username}"'),
                subtitle: const Text(
                  'Bans the user from the group; they cannot join again.',
                ),
                onTap: () {
                  // TODO: Implement ban
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.upgrade),
                title: Text('Promote "${them.user.username}"'),
                subtitle: const Text('Promotes the user to admin.'),
                onTap: () {
                  // TODO: Implement promote
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class MembershipPermissions {
  static bool canKick(GroupUser gu1, GroupUser gu2) {
    if (gu1.user.id == gu2.user.id) {
      return false;
    }

    switch (gu1.state) {
      case GroupMembershipState.superadmin:
        return gu2.state != GroupMembershipState.superadmin;
      case GroupMembershipState.admin:
        return gu2.state != GroupMembershipState.superadmin &&
            gu2.state != GroupMembershipState.admin;
      case GroupMembershipState.member:
        return false;
      case GroupMembershipState.joinRequest:
        return false;
    }
  }

  bool canPromote(GroupUser gu1, GroupUser gu2) {
    switch (gu1.state) {
      case GroupMembershipState.superadmin:
        return gu2.state != GroupMembershipState.superadmin;
      case GroupMembershipState.admin:
        return gu2.state != GroupMembershipState.superadmin &&
            gu2.state != GroupMembershipState.admin;
      case GroupMembershipState.member:
        return false;
      case GroupMembershipState.joinRequest:
        return false;
    }
  }

  bool canRemove(GroupUser gu1, GroupUser gu2) {
    return canKick(gu1, gu2);
  }
}

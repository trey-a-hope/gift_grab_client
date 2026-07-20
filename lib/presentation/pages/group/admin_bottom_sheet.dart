part of 'group_details_page.dart';

class AdminBottomSheet extends SignalStatefulWidget {
  final GroupUser _me;
  final GroupUser _them;
  final GroupMembersUpdateController _groupMembersUpdateController;
  final GroupMembersListController _groupMembersListController;

  const AdminBottomSheet({
    required this._me,
    required this._them,
    required this._groupMembersUpdateController,
    required this._groupMembersListController,
    super.key,
  });

  @override
  State<AdminBottomSheet> createState() => _AdminBottomSheet();
}

class _AdminBottomSheet extends State<AdminBottomSheet> {
  EffectCleanup? _listener;
  late final ModalService _modalService;

  @override
  void initState() {
    _modalService = di<ModalService>();
    _listener = effect(_listen);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = ShadTheme.of(context).textTheme;
    final height = MediaQuery.of(context).size.height * 0.5;

    return Container(
      padding: const EdgeInsets.all(16),
      height: height,
      child: Column(
        children: [
          Text('What would you like to do?', style: textTheme.h4),
          GapSizes.smallGap,
          if (MembershipPermissions.canKick(widget._me, widget._them)) ...[
            ListTile(
              leading: const Icon(Icons.delete),
              title: Text('Kick "${widget._them.user.username}"'),
              subtitle: const Text(
                'Removes the user from the group; they can join again later.',
              ),
              onTap: () async {
                await widget._groupMembersUpdateController.kickMember(
                  userId: widget._them.user.id,
                );
                if (!context.mounted) return;
                context.pop();
              },
            ),
          ],

          if (MembershipPermissions.canBan(widget._me, widget._them)) ...[
            ListTile(
              leading: const Icon(Icons.block),
              title: Text('Ban "${widget._them.user.username}"'),
              subtitle: const Text(
                'Bans the user from the group; they cannot join again.',
              ),
              onTap: () async {
                await widget._groupMembersUpdateController.banMember(
                  userId: widget._them.user.id,
                );
                if (!context.mounted) return;
                context.pop();
              },
            ),
          ],

          if (MembershipPermissions.canPromote(widget._me, widget._them)) ...[
            ListTile(
              leading: const Icon(Icons.upgrade),
              title: Text('Promote "${widget._them.user.username}"'),
              subtitle: const Text('Promotes the user.'),
              onTap: () async {
                await widget._groupMembersUpdateController.promoteMember(
                  userId: widget._them.user.id,
                );
                if (!context.mounted) return;
                context.pop();
              },
            ),
          ],

          if (MembershipPermissions.canDemote(widget._me, widget._them)) ...[
            ListTile(
              leading: const Icon(Icons.keyboard_double_arrow_down_sharp),
              title: Text('Demote "${widget._them.user.username}"'),
              subtitle: const Text('Demomotes the user.'),
              onTap: () async {
                await widget._groupMembersUpdateController.demoteMember(
                  userId: widget._them.user.id,
                );
                if (!context.mounted) return;
                context.pop();
              },
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _listener?.call();
    super.dispose();
  }

  void _listen() {
    {
      final kickMemberSignal =
          widget._groupMembersUpdateController.kickMemberSignal;

      final kickMemberState = kickMemberSignal.value;

      final isRefreshing = kickMemberState.isRefreshing;
      logger.d('isRefreshing: $isRefreshing');

      final isReloading = kickMemberState.isReloading;
      logger.d('isReloading: $isReloading');

      final error = kickMemberState.error;
      logger.e('error: $error');

      final success = kickMemberState.value;
      logger.d('SUCCESS: $success');

      if (success != null) {
        widget._groupMembersListController.groupUsersSignal.refresh();
        _modalService.shadToast(context, title: Text(success));
        kickMemberSignal.reset();
      }

      if (error != null) {
        _modalService.shadToastDestructive(
          context,
          title: Text(error.toString()),
        );
        kickMemberSignal.reset();
      }
    }
  }
}

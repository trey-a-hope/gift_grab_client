part of 'group_membership_list_page.dart';

class AdminButtons extends StatelessWidget {
  final String theirUid;
  final String groupid;

  const AdminButtons({
    required this.theirUid,
    required this.groupid,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = ShadTheme.of(context).textTheme;

    final groupMembershipUpdateBloc = context.read<GroupMembershipUpdateBloc>();
    final modalService = context.read<ModalService>();
    final uid = context.read<AccountReadBloc>().state.account!.user.id;

    return BlocBuilder<GroupMembershipListBloc, GroupMembershipListState>(
      builder: (context, state) {
        final groupUsers = state.groupUsers;

        final me = groupUsers.firstWhere((gu) => gu.user.id == uid);
        final them = groupUsers.firstWhere((gu) => gu.user.id == theirUid);

        // User cannot do anything to themselves
        if (me.user.id == them.user.id) return const SizedBox.shrink();// TODO: Delete this

        if (me.canKick(them)) {
          if (them.state == GroupMembershipState.joinRequest) {
            ShadButton.secondary(
              onPressed: () async {
                final confirm = await modalService.shadConfirmationDialog(
                  context,
                  title: Text(
                    'Deny request',
                    style: textTheme.p,
                  ),
                  description: Text(
                    'Press continue to confirm',
                    style: textTheme.p,
                  ),
                );

                if (!confirm.falseIfNull()) {
                  return;
                }

                groupMembershipUpdateBloc.add(DenyRequest(them.user.id));
              },
              child: const Text('Deny'),
            );
          } else {
            ShadButton.secondary(
              onPressed: () async {
                final confirm = await modalService.shadConfirmationDialog(
                  context,
                  title: Text(
                    'Kick user',
                    style: textTheme.p,
                  ),
                  description: Text(
                    'Press continue to confirm',
                    style: textTheme.p,
                  ),
                );

                if (!confirm.falseIfNull()) {
                  return;
                }

                groupMembershipUpdateBloc.add(KickGroupUser(them.user.id));
              },
              child: const Text('Deny'),
            );
          }
        }

        if (me.state == GroupMembershipState.superadmin) {
          if (them.state == GroupMembershipState.joinRequest) {
            return Row(
              children: [
                ShadButton.secondary(
                  onPressed: () async {
                    final confirm = await modalService.shadConfirmationDialog(
                      context,
                      title: Text(
                        'Accept request?',
                        style: textTheme.p,
                      ),
                      description: Text(
                        'Press continue to confirm',
                        style: textTheme.p,
                      ),
                    );

                    if (!confirm.falseIfNull()) {
                      return;
                    }

                    groupMembershipUpdateBloc.add(AddGroupUser(them.user.id));
                  },
                  child: const Text('Approve'),
                ),
                GapSizes.smallGap,
                ShadButton.secondary(
                  onPressed: () async {
                    final confirm = await modalService.shadConfirmationDialog(
                      context,
                      title: Text(
                        'Deny request?',
                        style: textTheme.p,
                      ),
                      description: Text(
                        'Press continue to confirm',
                        style: textTheme.p,
                      ),
                    );

                    if (!confirm.falseIfNull()) {
                      return;
                    }

                    groupMembershipUpdateBloc.add(DenyRequest(them.user.id));
                  },
                  child: const Text('Deny'),
                )
              ],
            );
          }

          return ShadButton.secondary(
            onPressed: () async {
              final confirm = await modalService.shadConfirmationDialog(
                context,
                title: Text(
                  'Kick user',
                  style: textTheme.p,
                ),
                description: Text(
                  'Press continue to confirm',
                  style: textTheme.p,
                ),
              );

              if (!confirm.falseIfNull()) {
                return;
              }

              groupMembershipUpdateBloc.add(KickGroupUser(them.user.id));
            },
            child: const Text('Kick user'),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

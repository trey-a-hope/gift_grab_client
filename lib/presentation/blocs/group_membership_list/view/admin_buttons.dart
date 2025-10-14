part of 'group_membership_list_page.dart';

class AdminButtons extends StatelessWidget {
  final GroupUser? me;
  final GroupUser them;

  const AdminButtons({
    required this.me,
    required this.them,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = ShadTheme.of(context).textTheme;

    final groupMembershipUpdateBloc = context.read<GroupMembershipUpdateBloc>();
    final modalService = context.read<ModalService>();

    if (me == null || !me!.canPerformAdmin(them))
      return const SizedBox.shrink();

    if (them.state == GroupMembershipState.joinRequest) {
      final joinReqButtons = [
        ShadButton.secondary(
          onPressed: () async {
            final confirm = await modalService.shadConfirmationDialog(
              context,
              title: Text(
                'Accept request',
                style: textTheme.p,
              ),
              description: Text(
                LabelText.confirm,
                style: textTheme.p,
              ),
            );

            if (!confirm.falseIfNull()) {
              return;
            }

            groupMembershipUpdateBloc.add(AcceptRequest(them.user.id));
          },
          child: const Text('Approve'),
        ),
        ShadButton.secondary(
          onPressed: () async {
            final confirm = await modalService.shadConfirmationDialog(
              context,
              title: Text(
                'Deny request',
                style: textTheme.p,
              ),
              description: Text(
                LabelText.confirm,
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
      ];

      return Row(children: joinReqButtons.separatedBy(GapSizes.smallGap));
    }

    final nonJoinReqButtons = [
      ShadButton.secondary(
        onPressed: () async {
          final confirm = await modalService.shadConfirmationDialog(
            context,
            title: Text(
              'Ban user',
              style: textTheme.p,
            ),
            description: Text(
              LabelText.confirm,
              style: textTheme.p,
            ),
          );

          if (!confirm.falseIfNull()) {
            return;
          }

          groupMembershipUpdateBloc.add(BanUser(them.user.id));
        },
        child: const Text('Ban'),
      ),
      ShadButton.secondary(
        onPressed: () async {
          final confirm = await modalService.shadConfirmationDialog(
            context,
            title: Text(
              'Kick user',
              style: textTheme.p,
            ),
            description: Text(
              LabelText.confirm,
              style: textTheme.p,
            ),
          );

          if (!confirm.falseIfNull()) {
            return;
          }

          groupMembershipUpdateBloc.add(KickUser(them.user.id));
        },
        child: const Text('Kick'),
      ),
      if (them.state != GroupMembershipState.superadmin) ...[
        ShadButton.secondary(
          onPressed: () async {
            final confirm = await modalService.shadConfirmationDialog(
              context,
              title: Text(
                'Promote user',
                style: textTheme.p,
              ),
              description: Text(
                LabelText.confirm,
                style: textTheme.p,
              ),
            );

            if (!confirm.falseIfNull()) {
              return;
            }

            groupMembershipUpdateBloc.add(PromoteUser(them.user.id));
          },
          child: const Text('Promote'),
        )
      ],
      if (them.state != GroupMembershipState.member) ...[
        ShadButton.secondary(
          onPressed: () async {
            final confirm = await modalService.shadConfirmationDialog(
              context,
              title: Text(
                'Demote user',
                style: textTheme.p,
              ),
              description: Text(
                LabelText.confirm,
                style: textTheme.p,
              ),
            );

            if (!confirm.falseIfNull()) {
              return;
            }

            groupMembershipUpdateBloc.add(DemoteUser(them.user.id));
          },
          child: const Text('Demote'),
        )
      ],
    ];

    return Row(children: nonJoinReqButtons.separatedBy(GapSizes.smallGap));
  }
}

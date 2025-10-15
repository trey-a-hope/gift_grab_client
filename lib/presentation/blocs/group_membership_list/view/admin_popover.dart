part of 'group_membership_list_page.dart';

class AdminPopover extends StatefulWidget {
  final GroupUser? me;
  final GroupUser them;

  const AdminPopover({
    required this.me,
    required this.them,
    super.key,
  });

  @override
  State<AdminPopover> createState() => _AdminPopoverState();
}

class _AdminPopoverState extends State<AdminPopover> {
  final popoverController = ShadPopoverController();

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = ShadTheme.of(context).textTheme;

    final groupMembershipUpdateBloc = context.read<GroupMembershipUpdateBloc>();
    final modalService = context.read<ModalService>();

    if (widget.me == null || !widget.me!.canPerformAdmin(widget.them))
      return const SizedBox.shrink();

    late final List<ShadButton> buttons;

    if (widget.them.state == GroupMembershipState.joinRequest) {
      buttons = [
        ShadButton.secondary(
          width: double.infinity,
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

            groupMembershipUpdateBloc.add(AcceptRequest(widget.them.user.id));
          },
          child: const Text('Approve'),
        ),
        ShadButton.secondary(
          width: double.infinity,
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

            groupMembershipUpdateBloc.add(DenyRequest(widget.them.user.id));
          },
          child: const Text('Deny'),
        )
      ];
    } else {
      buttons = [
        ShadButton.secondary(
          width: double.infinity,
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

            groupMembershipUpdateBloc.add(BanUser(widget.them.user.id));
          },
          child: const Text('Ban'),
        ),
        ShadButton.secondary(
          width: double.infinity,
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

            groupMembershipUpdateBloc.add(KickUser(widget.them.user.id));
          },
          child: const Text('Kick'),
        ),
        if (widget.them.state != GroupMembershipState.superadmin) ...[
          ShadButton.secondary(
            width: double.infinity,
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

              groupMembershipUpdateBloc.add(PromoteUser(widget.them.user.id));
            },
            child: const Text('Promote'),
          )
        ],
        if (widget.them.state != GroupMembershipState.member) ...[
          ShadButton.secondary(
            width: double.infinity,
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

              groupMembershipUpdateBloc.add(DemoteUser(widget.them.user.id));
            },
            child: const Text('Demote'),
          )
        ],
      ];
    }

    return ShadPopover(
      controller: popoverController,
      popover: (context) => SizedBox(
        width: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: buttons.separatedBy(GapSizes.smallGap),
        ),
      ),
      child: ShadButton.secondary(
        onPressed: popoverController.toggle,
        child: const Icon(LucideIcons.ellipsis),
      ),
    );
  }
}

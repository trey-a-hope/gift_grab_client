part of 'group_details_page.dart';

class GroupMembershipStateButton extends StatelessWidget {
  final String groupId;
  final GroupMembersListController groupMembersListController;

  const GroupMembershipStateButton({
    required this.groupId,
    required this.groupMembersListController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sessionService = context.read<SessionService>();

    final groupMembersListController = di<GroupMembersListController>(
      param1: groupId,
    );

    return MultiBlocListener(
      listeners: [
        BlocProvider<GroupMembershipUpdateBloc>(
          create: (context) => GroupMembershipUpdateBloc(
            groupId,
            getNakamaClient(),
            sessionService,
          ),
        ),
        BlocProvider<GroupMembershipReadBloc>(
          create: (context) => GroupMembershipReadBloc(
            groupId,
            getNakamaClient(),
            sessionService,
          )..add(const ReadGroupMembershipState()),
        ),
      ],
      child: GroupMembershipStateButtonView(groupMembersListController),
    );
  }
}

class GroupMembershipStateButtonView extends StatelessWidget {
  final GroupMembersListController groupMembersListController;

  const GroupMembershipStateButtonView(
    this.groupMembersListController, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final groupMembershipReadBloc = context.read<GroupMembershipReadBloc>();
    final groupMembershipUpdateBloc = context.read<GroupMembershipUpdateBloc>();
    final modalService = context.read<ModalService>();

    return BlocListener<GroupMembershipUpdateBloc, GroupMembershipUpdateState>(
      listener: (context, state) {
        if (state.success != null) {
          modalService.shadToast(context, title: Text(state.success!));
          groupMembershipReadBloc.add(const ReadGroupMembershipState());
          groupMembersListController.groupUsersSignal.reload();
        }

        if (state.error != null) {
          modalService.shadToastDestructive(context, title: Text(state.error!));
        }
      },
      child: BlocBuilder<GroupMembershipReadBloc, GroupMembershipReadState>(
        builder: (context, state) {
          final groupMembershipState = state.groupMembershipState;

          switch (groupMembershipState) {
            case null:
              return ShadButton(
                child: const Text('Join group'),
                onPressed: () {
                  groupMembershipUpdateBloc.add(const JoinGroup());
                },
              );
            case GroupMembershipState.joinRequest:
              return ShadButton.secondary(
                child: const Text('Cancel request'),
                onPressed: () {
                  groupMembershipUpdateBloc.add(const CancelRequest());
                },
              );
            case GroupMembershipState.superadmin:
            case GroupMembershipState.admin:
            case GroupMembershipState.member:
              return ShadButton.secondary(
                child: const Text('Leave group'),
                onPressed: () =>
                    groupMembershipUpdateBloc.add(const LeaveGroup()),
              );
          }
        },
      ),
    );
  }
}

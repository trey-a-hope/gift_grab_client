import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/group_membership_read/group_membership_read.dart';
import 'package:gift_grab_client/presentation/blocs/group_membership_update/bloc/group_membership_update_bloc.dart';
import 'package:nakama/nakama.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class GroupMembershipStateButton extends StatelessWidget {
  final String groupId;
  const GroupMembershipStateButton({required this.groupId, super.key});

  @override
  Widget build(BuildContext context) {
    final sessionService = context.read<SessionService>();

    return MultiBlocListener(
      listeners: [
        BlocProvider<GroupMembershipUpdateBloc>(
          create: (context) => GroupMembershipUpdateBloc(
              groupId, getNakamaClient(), sessionService),
        ),
        BlocProvider<GroupMembershipReadBloc>(
            create: (context) => GroupMembershipReadBloc(
                groupId, getNakamaClient(), sessionService)
              ..add(const ReadGroupMembershipState())),
      ],
      child: const GroupMembershipStateButtonView(),
    );
  }
}

class GroupMembershipStateButtonView extends StatelessWidget {
  const GroupMembershipStateButtonView({super.key});

  @override
  Widget build(BuildContext context) {
    final groupMembershipReadBloc = context.read<GroupMembershipReadBloc>();
    final groupMembershipUpdateBloc = context.read<GroupMembershipUpdateBloc>();

    return BlocListener<GroupMembershipUpdateBloc, GroupMembershipUpdateState>(
      listener: (context, state) {
        if (state.success != null) {
          groupMembershipReadBloc.add(const ReadGroupMembershipState());
        }
      },
      child: BlocBuilder<GroupMembershipReadBloc, GroupMembershipReadState>(
        builder: (context, state) {
          final groupMembershipState = state.groupMembershipState;

          switch (groupMembershipState) {
            case null:
              return ShadButton(
                child: const Text('Join group'),
                onPressed: () =>
                    groupMembershipUpdateBloc.add(const JoinGroup()),
              );
            case GroupMembershipState.superadmin:
              return const SizedBox.shrink();
            case GroupMembershipState.admin:
              return const SizedBox.shrink();

            case GroupMembershipState.member:
              return ShadButton(
                child: const Text('Leave group'),
                onPressed: () =>
                    groupMembershipUpdateBloc.add(const LeaveGroup()),
              );
            case GroupMembershipState.joinRequest:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

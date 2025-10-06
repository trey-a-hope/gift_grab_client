import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/data/configuration/gap_sizes.dart';
import 'package:gift_grab_client/presentation/widgets/user_list_tile.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../group_membership_list.dart';

class GroupMembershipListPage extends StatelessWidget {
  final String groupId;

  const GroupMembershipListPage(this.groupId, {super.key});

  @override
  Widget build(BuildContext context) => const GroupMembershipListView();
}

class GroupMembershipListView extends StatelessWidget {
  const GroupMembershipListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupMembershipListBloc, GroupMembershipListState>(
      builder: (context, state) {
        final isLoading = state.isLoading;
        final groupUsers = state.groupUsers;

        return isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: groupUsers.length,
                itemBuilder: (context, index) {
                  final groupUser = groupUsers[index];

                  return Padding(
                    padding: EdgeInsetsGeometry.only(
                        top: GapSizes.mediumGap.mainAxisExtent),
                    child: Row(
                      children: [
                        Expanded(
                          child: UserListTile(groupUser.user),
                        ),
                        ShadBadge(
                          child: Text(groupUser.state.name),
                        )
                      ],
                    ),
                  );
                },
              );
      },
    );
  }
}

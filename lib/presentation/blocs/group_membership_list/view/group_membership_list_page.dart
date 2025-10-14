import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/data/configuration/gap_sizes.dart';
import 'package:gift_grab_client/data/constants/label_text.dart';
import 'package:gift_grab_client/domain/services/modal_service.dart';
import 'package:gift_grab_client/presentation/blocs/account_read/account_read.dart';
import 'package:gift_grab_client/presentation/blocs/group_membership_update/bloc/group_membership_update_bloc.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:gift_grab_client/presentation/extensions/group_membership_state_extensions.dart';
import 'package:gift_grab_client/presentation/widgets/user_list_tile.dart';
import 'package:nakama/nakama.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:collection/collection.dart';

import '../group_membership_list.dart';

part 'admin_buttons.dart';

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
    final uid = context.read<AccountReadBloc>().state.account!.user.id;

    return BlocBuilder<GroupMembershipListBloc, GroupMembershipListState>(
      builder: (context, state) {
        final isLoading = state.isLoading;
        final groupUsers = state.groupUsers;

        final me = groupUsers.firstWhereOrNull(
          (groupUser) => groupUser.user.id == uid,
        );

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
                          child: Text(groupUser.state.title),
                        ),
                        GapSizes.smallGap,
                        AdminButtons(
                          me: me,
                          them: groupUser,
                        ),
                      ],
                    ),
                  );
                },
              );
      },
    );
  }
}

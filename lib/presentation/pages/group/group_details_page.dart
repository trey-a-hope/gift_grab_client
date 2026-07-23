import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/core/logging.dart';
import 'package:gift_grab_client/data/configuration/gap_sizes.dart';
import 'package:gift_grab_client/data/constants/label_text.dart';
import 'package:gift_grab_client/data/enums/go_routes.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/group_delete/bloc/group_delete_bloc.dart';
import 'package:gift_grab_client/presentation/cubits/group_refresh/group_refresh.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:gift_grab_client/presentation/extensions/date_time_extensions.dart';
import 'package:gift_grab_client/presentation/services/modal_service.dart';
import 'package:gift_grab_client/presentation/widgets/network_circle_avatar.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:go_router/go_router.dart';
import 'package:nakama/nakama.dart';
import 'package:collection/collection.dart';
import 'package:gift_grab_client/core/di_container.dart';
import 'package:gift_grab_client/presentation/controllers/account_read_controller.dart';
import 'package:gift_grab_client/presentation/controllers/group_members_list_controller.dart';
import 'package:gift_grab_client/presentation/controllers/group_members_update_controller.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';
import '../../blocs/group_read/group_read.dart';
import 'package:gift_grab_client/presentation/blocs/group_membership_read/group_membership_read.dart';
import 'package:gift_grab_client/presentation/blocs/group_membership_update/bloc/group_membership_update_bloc.dart';

part 'members_list.dart';
part 'group_membership_state_button.dart';
part 'admin_bottom_sheet.dart';
part 'membership_permissions.dart';

class GroupDetailsPage extends StatelessWidget {
  final String groupId;

  const GroupDetailsPage(this.groupId, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GroupReadBloc>(
          create: (context) => GroupReadBloc(
            groupId,
            getNakamaClient(),
            context.read<SessionService>(),
          )..add(const ReadGroup()),
        ),
        BlocProvider<GroupDeleteBloc>(
          create: (context) => GroupDeleteBloc(
            groupId,
            getNakamaClient(),
            context.read<SessionService>(),
          ),
        ),
      ],
      child: GroupDetailsView(groupId),
    );
  }
}

class GroupDetailsView extends SignalStatefulWidget {
  final String groupId;

  const GroupDetailsView(this.groupId, {super.key});

  @override
  State<GroupDetailsView> createState() => _GroupDetailsViewState();
}

class _GroupDetailsViewState extends State<GroupDetailsView> {
  late final GroupMembersListController _groupMembersListController;

  @override
  void initState() {
    super.initState();

    _groupMembersListController = di<GroupMembersListController>(
      param1: widget.groupId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final accountReadController = di<AccountReadController>();
    final account = accountReadController.accountSignal.value.value!;
    final groupReadBloc = context.read<GroupReadBloc>();
    final groupRefreshCubit = context.read<GroupRefreshCubit>();
    final groupDeleteBloc = context.read<GroupDeleteBloc>();
    final modalService = context.read<ModalService>();

    return BlocListener<GroupDeleteBloc, GroupDeleteState>(
      listener: (context, state) {
        if (state.error != null) {
          modalService.shadToastDestructive(context, title: Text(state.error!));
        }

        if (state.success != null) {
          modalService.shadToast(context, title: Text(state.success!));
          groupRefreshCubit.triggerRefresh();
          context.pop();
        }
      },
      child: BlocBuilder<GroupReadBloc, GroupReadState>(
        builder: (context, state) {
          final group = state.group;
          final isLoading = state.isLoading;

          return GGScaffoldWidget(
            title: group?.name ?? '',
            actions: [
              if (account.user.id == group?.creatorId) ...[
                IconButton.filledTonal(
                  onPressed: () async {
                    final shouldUpdate = await context.pushNamed<bool>(
                      GoRoutes.EDIT_GROUP.name,
                      pathParameters: {'group_id': group!.id},
                      extra: group,
                    );

                    if (!shouldUpdate.falseIfNull()) return;

                    groupReadBloc.add(const ReadGroup());
                  },
                  icon: const Icon(Icons.edit),
                ),
                GapSizes.smallGap,
                IconButton.filledTonal(
                  onPressed: () async {
                    final confirm = await modalService.shadConfirmationDialog(
                      context,
                      title: const Text('Delete group'),
                      description: const Text(LabelText.confirm),
                    );

                    if (!confirm.falseIfNull()) return;

                    groupDeleteBloc.add(const DeleteGroup());
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ],
            child: SafeArea(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : group == null
                  ? const NoResultsWidget(NoResultsEnum.allGroups)
                  : Padding(
                      padding: const EdgeInsetsGeometry.all(32),
                      child: Column(
                        crossAxisAlignment: .center,
                        children: [
                          NetworkCircleAvatar(
                            imgUrl: group.avatarUrl,
                            radius: 100,
                          ),
                          GapSizes.largeGap,
                          GroupMembershipStateButton(
                            groupId: group.id,
                            groupMembersListController:
                                _groupMembersListController,
                          ),
                          GapSizes.largeGap,
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsetsGeometry.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          title: Text(
                                            'Description',
                                            style: theme.textTheme.bodyLarge!
                                                .copyWith(color: Colors.white),
                                          ),
                                          subtitle: Text(
                                            group.description ?? 'N/A',
                                            style:
                                                theme.textTheme.headlineSmall,
                                          ),
                                        ),
                                        ListTile(
                                          title: Text(
                                            'Join Type',
                                            style: theme.textTheme.bodyLarge!
                                                .copyWith(color: Colors.white),
                                          ),
                                          subtitle: Text(
                                            group.open.falseIfNull()
                                                ? 'Public'
                                                : 'Private',
                                            style:
                                                theme.textTheme.headlineSmall,
                                          ),
                                        ),
                                        ListTile(
                                          title: Text(
                                            'Group Created',
                                            style: theme.textTheme.bodyLarge!
                                                .copyWith(color: Colors.white),
                                          ),
                                          subtitle: Text(
                                            group.createTime?.MMM_d_y() ??
                                                'N/A',
                                            style:
                                                theme.textTheme.headlineSmall,
                                          ),
                                        ),
                                        ListTile(
                                          title: Text(
                                            'Last Updated',
                                            style: theme.textTheme.bodyLarge!
                                                .copyWith(color: Colors.white),
                                          ),
                                          subtitle: Text(
                                            group.updateTime?.MMM_d_y() ??
                                                'N/A',
                                            style:
                                                theme.textTheme.headlineSmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: MembersList(
                                    groupId: widget.groupId,
                                    groupMembersListController:
                                        _groupMembersListController,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

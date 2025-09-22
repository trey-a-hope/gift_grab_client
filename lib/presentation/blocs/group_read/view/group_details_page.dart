import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:gift_grab_client/data/enums/go_routes.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/account_read/bloc/account_read_bloc.dart';
import 'package:gift_grab_client/presentation/blocs/group_delete/bloc/group_delete_bloc.dart';
import 'package:gift_grab_client/presentation/cubits/group_refresh/group_refresh.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:gift_grab_client/presentation/widgets/network_circle_avatar.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_util/modal_util.dart';
import 'package:nakama/nakama.dart';

import '../group_read.dart';

class GroupDetailsPage extends StatelessWidget {
  final String groupId;
  const GroupDetailsPage(this.groupId, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
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
      )
    ], child: const GroupDetailsView());
  }
}

class GroupDetailsView extends StatelessWidget {
  const GroupDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final accountReadBloc = context.read<AccountReadBloc>();
    final account = accountReadBloc.state.account!;
    final groupReadBloc = context.read<GroupReadBloc>();
    final groupRefreshCubit = context.read<GroupRefreshCubit>();
    final groupDeleteBloc = context.read<GroupDeleteBloc>();

    return BlocListener<GroupDeleteBloc, GroupDeleteState>(
      listener: (context, state) {
        if (state.error != null) {
          ModalUtil.showError(context, title: state.error!);
        }

        if (state.success != null) {
          ModalUtil.showSuccess(context, title: state.success!);
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
                const Gap(8),
                IconButton.filledTonal(
                  onPressed: () async {
                    final confirm = await ModalUtil.showConfirmation(context,
                        title: 'Delete Group', message: 'Press yes to confirm');

                    if (!confirm.falseIfNull()) return;

                    groupDeleteBloc.add(const DeleteGroup());
                  },
                  icon: const Icon(Icons.delete),
                ),
              ]
            ],
            child: SafeArea(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : group == null
                      ? const NoResultsWidget(NoResultsEnum.allGroups)
                      : Padding(
                          padding: const EdgeInsetsGeometry.all(32),
                          child: Column(
                            children: [
                              NetworkCircleAvatar(
                                imgUrl: group.avatarUrl,
                                radius: 100,
                              ),
                              const Gap(8),
                              const Expanded(
                                  child: Row(
                                children: [
                                  Expanded(
                                      child: Placeholder(
                                    color: Colors.purple,
                                  )),
                                  Expanded(
                                      child: Placeholder(
                                    color: Colors.green,
                                  ))
                                ],
                              ))
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

import 'package:flutter/material.dart';
import 'package:gift_grab_client/core/di_container.dart';
import 'package:gift_grab_client/presentation/controllers/group_users_controller.dart';
import 'package:gift_grab_client/presentation/services/modal_service.dart';
import 'package:gift_grab_client/presentation/widgets/network_circle_avatar.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:nakama/nakama.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

class MembersList extends SignalStatefulWidget {
  final GroupUsersController groupUsersController;

  const MembersList(this.groupUsersController, {super.key});

  @override
  State<MembersList> createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  EffectCleanup? _errorToastListener;
  late final _modalService;

  @override
  void initState() {
    _modalService = di<ModalService>();

    _errorToastListener = effect(() {
      final error = widget.groupUsersController.groupUsersSignal.value.error;
      if (error != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _modalService.shadToastDestructive(
              context,
              title: Text(error.toString()),
            );
          }
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      widget.groupUsersController.groupUsersSignal.value.map(
        data: (groupUsers) => groupUsers.isEmpty
            ? const NoResultsWidget(NoResultsEnum.users)
            : ListView.builder(
                itemCount: groupUsers.length,
                itemBuilder: (context, index) =>
                    _GroupUserListTile(groupUsers[index]),
              ),
        error: (e, s) => Center(child: Text('Error loading group members: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      );

  @override
  void dispose() {
    _errorToastListener?.call();
    super.dispose();
  }
}

class _GroupUserListTile extends StatelessWidget {
  final GroupUser groupUser;

  const _GroupUserListTile(this.groupUser);

  @override
  Widget build(BuildContext context) {
    final textTheme = ShadTheme.of(context).textTheme;

    return ListTile(
      title: Text(groupUser.user.username ?? 'No name', style: textTheme.h4),
      subtitle: Text(groupUser.state.name, style: textTheme.p),
      leading: NetworkCircleAvatar(
        imgUrl: groupUser.user.avatarUrl,
        radius: 50,
      ),
    );
  }
}

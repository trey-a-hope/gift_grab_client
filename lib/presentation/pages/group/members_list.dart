part of 'group_details_page.dart';

class MembersList extends SignalStatefulWidget {
  final String groupId;
  final GroupMembersListController groupMembersListController;

  const MembersList({
    required this.groupId,
    required this.groupMembersListController,
    super.key,
  });

  @override
  State<MembersList> createState() => _MembersListState();
}

class _MembersListState extends State<MembersList> {
  EffectCleanup? _errorToastListener;
  late final ModalService _modalService;

  late final AccountReadController _accountReadController;

  @override
  void initState() {
    _modalService = di<ModalService>();
    _accountReadController = di<AccountReadController>();

    _errorToastListener = effect(() {
      final error =
          widget.groupMembersListController.groupUsersSignal.value.error;
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
  Widget build(BuildContext context) {
    final uid = _accountReadController.accountSignal.value.value?.user.id;

    if (uid == null) throw Exception('User ID cannot be null.');

    return widget.groupMembersListController.groupUsersSignal.value.map(
      data: (groupUsers) {
        groupUsers.log(authenticatedUserId: uid);

        return Column(
          children: [
            const Text('Members'),
            Expanded(
              child: ListView.builder(
                itemCount: groupUsers.length,
                itemBuilder: (context, index) => _GroupUserListTile(
                  groupId: widget.groupId,
                  me: groupUsers.firstWhereOrNull((gu) => gu.user.id == uid),
                  them: groupUsers[index],
                  groupMembersListController: widget.groupMembersListController,
                ),
              ),
            ),
          ],
        );
      },
      error: (e, s) => Center(child: Text('Error loading group members: $e')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _errorToastListener?.call();
    super.dispose();
  }
}

class _GroupUserListTile extends StatelessWidget {
  final String groupId;
  final GroupUser? me;
  final GroupUser them;
  final GroupMembersListController groupMembersListController;

  const _GroupUserListTile({
    required this.groupId,
    this.me,
    required this.them,
    required this.groupMembersListController,
  });

  @override
  Widget build(BuildContext context) {
    final groupMembersUpdateController = di<GroupMembersUpdateController>(
      param1: groupId,
    );

    final textTheme = ShadTheme.of(context).textTheme;

    return ListTile(
      title: Text(them.user.username ?? 'No name', style: textTheme.h4),
      subtitle: Text(them.state.name, style: textTheme.p),
      leading: NetworkCircleAvatar(imgUrl: them.user.avatarUrl, radius: 50),
      trailing:
          me?.state == GroupMembershipState.superadmin &&
              me?.user.id != them.user.id
          ? IconButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                builder: (context) => AdminBottomSheet(
                  me: me!,
                  them: them,
                  groupMembersUpdateController: groupMembersUpdateController,
                  groupMembersListController: groupMembersListController,
                ),
              ),
              icon: const Icon(Icons.more_horiz),
            )
          : null,
    );
  }
}

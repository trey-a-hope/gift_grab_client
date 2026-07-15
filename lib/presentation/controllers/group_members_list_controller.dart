import 'package:gift_grab_client/domain/services/group_service.dart';
import 'package:nakama/nakama.dart';
import 'package:signals/signals_flutter.dart';

class GroupMembersListController {
  final String _groupId;
  final GroupService _groupService;

  late final FutureSignal<List<GroupUser>> groupUsersSignal;

  GroupMembersListController(this._groupId, this._groupService) {
    groupUsersSignal = futureSignal<List<GroupUser>>(
      () => _groupService.getMembersOfGroup(_groupId),
      options: const AsyncSignalOptions(
        name: 'GroupMembersListController.groupUsersSignal',
      ),
    );
  }
}

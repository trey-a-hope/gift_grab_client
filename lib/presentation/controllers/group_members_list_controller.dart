import 'package:gift_grab_client/domain/services/group_service.dart';
import 'package:gift_grab_client/presentation/controllers/account_read_controller.dart';
import 'package:gift_grab_client/presentation/extensions/model_log_extensions.dart';
import 'package:nakama/nakama.dart';
import 'package:signals/signals_flutter.dart';

class GroupMembersListController {
  final String _groupId;
  final AccountReadController _accountReadController;
  final GroupService _groupService;

  late final FutureSignal<List<GroupUser>> groupUsersSignal;

  GroupMembersListController(
    this._groupId,
    this._accountReadController,
    this._groupService,
  ) {
    groupUsersSignal = futureSignal<List<GroupUser>>(
      () async {
        final result = await _groupService.getMembersOfGroup(_groupId);
        return result.fold(
          (success) {
            success.log(
              authenticatedUserId:
                  _accountReadController.accountSignal.value.value?.user.id ??
                  'uid unknown',
            );
            return success;
          },
          (error) => throw error,
        );
      },
      options: const AsyncSignalOptions(
        name: 'GroupMembersListController.groupUsersSignal',
      ),
    );
  }
}

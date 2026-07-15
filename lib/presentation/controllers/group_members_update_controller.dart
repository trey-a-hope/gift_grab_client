import 'package:gift_grab_client/domain/services/group_service.dart';
import 'package:signals/signals_flutter.dart';

class GroupMembersUpdateController {
  final String _groupId;
  final GroupService _groupService;

  final kickMemberSignal = AsyncSignal<void>(const AsyncData(null));

  GroupMembersUpdateController(this._groupId, this._groupService);

  Future<void> kickMember({required String userId}) async {
    try {
      kickMemberSignal.value = const AsyncLoading();
      await _groupService.kickMember(groupId: _groupId, userId: userId);
      kickMemberSignal.value = const AsyncData(null);
    } catch (e, st) {
      kickMemberSignal.value = AsyncError(e, st);
    }
  }
}

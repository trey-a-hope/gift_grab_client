import 'package:gift_grab_client/domain/services/group_service.dart';
import 'package:signals/signals_flutter.dart';

class GroupMembersUpdateController {
  final String _groupId;
  final GroupService _groupService;

  final kickMemberSignal = AsyncSignal<String?>(const AsyncData(null));

  GroupMembersUpdateController(this._groupId, this._groupService);

  Future<void> kickMember({required String userId}) async {
    try {
      kickMemberSignal.value = const AsyncLoading();
      await _groupService.kickMember(groupId: _groupId, userId: userId);
      kickMemberSignal.value = const AsyncData('User kicked successfully');
    } catch (e, st) {
      kickMemberSignal.value = AsyncError(e, st);
    }
  }

  Future<void> banMember({required String userId}) async {
    try {
      kickMemberSignal.value = const AsyncLoading();
      await _groupService.banMember(groupId: _groupId, userId: userId);
      kickMemberSignal.value = const AsyncData('User banned successfully');
    } catch (e, st) {
      kickMemberSignal.value = AsyncError(e, st);
    }
  }

  Future<void> promoteMember({required String userId}) async {
    try {
      kickMemberSignal.value = const AsyncLoading();
      await _groupService.promoteMember(groupId: _groupId, userId: userId);
      kickMemberSignal.value = const AsyncData('User promoted successfully');
    } catch (e, st) {
      kickMemberSignal.value = AsyncError(e, st);
    }
  }

  Future<void> demoteMember({required String userId}) async {
    try {
      kickMemberSignal.value = const AsyncLoading();
      await _groupService.demoteMember(groupId: _groupId, userId: userId);
      kickMemberSignal.value = const AsyncData('User demoted successfully');
    } catch (e, st) {
      kickMemberSignal.value = AsyncError(e, st);
    }
  }

  Future<void> addMember({required String userId}) async {
    try {
      kickMemberSignal.value = const AsyncLoading();
      await _groupService.addMember(groupId: _groupId, userId: userId);
      kickMemberSignal.value = const AsyncData('User added successfully');
    } catch (e, st) {
      kickMemberSignal.value = AsyncError(e, st);
    }
  }
}

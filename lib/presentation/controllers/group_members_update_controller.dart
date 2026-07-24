import 'package:gift_grab_client/domain/services/group_service.dart';
import 'package:signals/signals_flutter.dart';

class GroupMembersUpdateController {
  final String _groupId;
  final GroupService _groupService;

  final kickMemberSignal = AsyncSignal<String?>(const AsyncData(null));

  GroupMembersUpdateController(this._groupId, this._groupService);

  Future<void> kickMember({required String userId}) async {
    kickMemberSignal.value = const AsyncLoading();

    final result = await _groupService.kickMember(
      groupId: _groupId,
      userId: userId,
    );

    result.fold(
      (success) => kickMemberSignal.value = const AsyncData(
        'User kicked successfully',
      ),
      (error) => kickMemberSignal.value = AsyncError(error, StackTrace.current),
    );
  }

  Future<void> banMember({required String userId}) async {
    kickMemberSignal.value = const AsyncLoading();

    final result = await _groupService.banMember(
      groupId: _groupId,
      userId: userId,
    );

    result.fold(
      (success) => kickMemberSignal.value = const AsyncData(
        'User banned successfully',
      ),
      (error) => kickMemberSignal.value = AsyncError(error, StackTrace.current),
    );
  }

  Future<void> promoteMember({required String userId}) async {
    kickMemberSignal.value = const AsyncLoading();

    final result = await _groupService.promoteMember(
      groupId: _groupId,
      userId: userId,
    );

    result.fold(
      (success) => kickMemberSignal.value = const AsyncData(
        'User promoted successfully',
      ),
      (error) => kickMemberSignal.value = AsyncError(error, StackTrace.current),
    );
  }

  Future<void> demoteMember({required String userId}) async {
    kickMemberSignal.value = const AsyncLoading();

    final result = await _groupService.demoteMember(
      groupId: _groupId,
      userId: userId,
    );

    result.fold(
      (success) => kickMemberSignal.value = const AsyncData(
        'User demoted successfully',
      ),
      (error) => kickMemberSignal.value = AsyncError(error, StackTrace.current),
    );
  }

  Future<void> addMember({required String userId}) async {
    kickMemberSignal.value = const AsyncLoading();

    final result = await _groupService.addMember(
      groupId: _groupId,
      userId: userId,
    );

    result.fold(
      (success) => kickMemberSignal.value = const AsyncData(
        'User added successfully',
      ),
      (error) => kickMemberSignal.value = AsyncError(error, StackTrace.current),
    );
  }
}

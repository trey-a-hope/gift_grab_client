import 'package:nakama/nakama.dart';

extension GroupMembershipStateExtensions on GroupMembershipState {
  String get title {
    switch (this) {
      case GroupMembershipState.joinRequest:
        return 'Waiting for approval';
      case GroupMembershipState.superadmin:
        return 'Super admin';
      case GroupMembershipState.admin:
        return 'Admin';
      case GroupMembershipState.member:
        return 'Member';
    }
  }
}

extension GroupUserExtensions on GroupUser {
  bool canKick(GroupUser target) {
    if (user.id == target.user.id) return false;

    switch (state) {
      case GroupMembershipState.superadmin:
        return true;
      case GroupMembershipState.admin:
        return target.state != GroupMembershipState.superadmin;
      case GroupMembershipState.member:
      case GroupMembershipState.joinRequest:
        return false;
    }
  }

  bool canAccept(GroupUser target) {
    if (user.id == target.user.id) return false;

    switch (state) {
      case GroupMembershipState.superadmin:
        return true;
      case GroupMembershipState.admin:
        return target.state != GroupMembershipState.superadmin;
      case GroupMembershipState.member:
      case GroupMembershipState.joinRequest:
        return false;
    }
  }
}

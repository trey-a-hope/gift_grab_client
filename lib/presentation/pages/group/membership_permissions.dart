part of 'group_details_page.dart';

class MembershipPermissions {
  static bool canKick(GroupUser gu1, GroupUser gu2) {
    if (gu1.user.id == gu2.user.id) {
      return false;
    }

    switch (gu1.state) {
      case GroupMembershipState.superadmin:
        return gu2.state != GroupMembershipState.superadmin;
      case GroupMembershipState.admin:
        return gu2.state != GroupMembershipState.superadmin &&
            gu2.state != GroupMembershipState.admin;
      case GroupMembershipState.member:
        return false;
      case GroupMembershipState.joinRequest:
        return false;
    }
  }

  static bool canPromote(GroupUser gu1, GroupUser gu2) {
    switch (gu1.state) {
      case GroupMembershipState.superadmin:
        return gu2.state != GroupMembershipState.superadmin;
      case GroupMembershipState.admin:
        return gu2.state != GroupMembershipState.superadmin &&
            gu2.state != GroupMembershipState.admin;
      case GroupMembershipState.member:
        return false;
      case GroupMembershipState.joinRequest:
        return false;
    }
  }

  static bool canDemote(GroupUser gu1, GroupUser gu2) {
    switch (gu1.state) {
      case GroupMembershipState.superadmin:
        return gu2.state != GroupMembershipState.member;
      case GroupMembershipState.admin:
        return false;
      case GroupMembershipState.member:
        return false;
      case GroupMembershipState.joinRequest:
        return false;
    }
  }

  static bool canBan(GroupUser gu1, GroupUser gu2) {
    return canKick(gu1, gu2);
  }
}

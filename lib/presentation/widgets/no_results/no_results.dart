part of 'no_results_widget.dart';

enum NoResultsEnum {
  // Chat
  chatRooms('No chat rooms', Lotties.chat),
  // Friends
  blocked('No blocks', Lotties.friends),
  mutual('No friends', Lotties.friends),
  incomingRequest('No invites', Lotties.friends),
  outgoingRequest('No requests', Lotties.friends),
  // Groups
  allGroups('No groups', Lotties.groups),
  myGroups('No groups you belong to', Lotties.groups),
  // Tournament
  tournaments('No tournaments', Lotties.tournament),
  tournament('No records', Lotties.tournament),
  // Notifications
  notifications('No notifications', Lotties.notifications),
  // Leaderboard
  leaderboard('No records for this week', Lotties.leaderboard),
  // Users
  users('No users found', Lotties.searchUsers);

  final String lottieUrl;
  final String name;

  const NoResultsEnum(
    this.name,
    this.lottieUrl,
  );
}

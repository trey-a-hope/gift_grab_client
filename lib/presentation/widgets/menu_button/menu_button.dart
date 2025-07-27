part of 'menu_button_widget.dart';

enum MenuButton {
  chatRooms(
    'Chat Rooms',
    Lotties.chat,
  ),
  deleteAccount(
    'Delete Account',
    Lotties.deleteAccount,
  ),
  friends(
    'Friends',
    Lotties.friends,
  ),
  editProfile(
    'Edit Profile',
    Lotties.editProfile,
  ),
  groups(
    'Groups',
    Lotties.groups,
  ),
  leaderboard(
    'Leaderboard',
    Lotties.leaderboard,
  ),
  licenses(
    'View Licenses',
    Lotties.licenses,
  ),
  linkedAccounts(
    'Linked Accounts',
    Lotties.linkedAccounts,
  ),
  logout(
    'Logout',
    Lotties.logout,
  ),
  notifications(
    'Notifications',
    Lotties.notifications,
  ),
  play(
    'Play',
    Lotties.play,
  ),
  profile(
    'Profile',
    Lotties.profile,
  ),
  searchUsers(
    'Search Users',
    Lotties.searchUsers,
  ),
  signOut(
    'Sign Out',
    Lotties.signOut,
  ),
  tournaments(
    'Tournaments',
    Lotties.tournament,
  ),
  ;

  final String name;
  final String lottieUrl;

  const MenuButton(
    this.name,
    this.lottieUrl,
  );
}

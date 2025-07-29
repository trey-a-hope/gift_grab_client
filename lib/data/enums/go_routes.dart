part of '../constants/globals.dart';

enum GoRoutes {
  CHAT_ROOM('chat_room'),
  CHAT_ROOMS('chat_rooms'),
  CREATE_CHAT_ROOM('create_chat_room'),
  DIRECT_CHATS('direct_chats'),
  FRIENDS('friends'),
  GAME('game'),
  GROUP_CREATE('group_create'),
  GROUP_DETAILS('group_details'),
  GROUP_EDIT('group_edit'),
  GROUPS('groups'),
  LEADERBOARD('leaderboard'),
  LOGIN('login'),
  MAIN('main'),
  NOTIFICATIONS('notifications'),
  PROFILE('profile'),
  PROFILE_EDIT('profile_edit'),
  SEARCH_USERS('search_users'),
  SETTINGS('settings'),
  TOURNAMENT('tournament'),
  TOURNAMENTS('tournaments'),
  ;

  const GoRoutes(this.name);

  final String name;
}

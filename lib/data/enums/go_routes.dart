enum GoRoutes {
  EDIT_PROFILE('edit_profile'),
  FRIENDS('friends'),
  GAME('game'),
  LEADERBOARD('leaderboard'),
  LOGIN('login'),
  MAIN('main'),
  PROFILE('profile'),
  SEARCH_USERS('search_users'),
  SETTINGS('settings'),
  CREATE_GROUP('create_group'),
  GROUPS('groups'),
  GROUP_DETAILS('group_details'),
  EDIT_GROUP('edit_group'),
  SEARCH_GROUPS('search_groups'),
  ;

  const GoRoutes(this.name);

  final String name;
}

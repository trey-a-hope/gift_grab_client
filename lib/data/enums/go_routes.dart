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
  ;

  const GoRoutes(this.name);

  final String name;
}

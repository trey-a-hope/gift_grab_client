enum GoRoutes {
  GAME('game'),
  LEADERBOARD('leaderboard'),
  LOGIN('login'),
  MAIN('main'),
  PROFILE('profile'),
  PROFILE_EDIT('profile_edit'),
  SEARCH_USERS('search_users'),
  SETTINGS('settings'),
  ;

  const GoRoutes(this.name);

  final String name;
}

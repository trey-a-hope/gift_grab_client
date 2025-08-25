enum GoRoutes {
  GAME('game'),
  LOGIN('login'),
  MAIN('main'),
  PROFILE('profile'),
  EDIT_PROFILE('edit_profile'),
  SETTINGS('settings'),
  SEARCH_USERS('search_users'),
  ;

  const GoRoutes(this.name);

  final String name;
}

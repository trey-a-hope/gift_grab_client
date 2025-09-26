enum RpcFunctions {
  ACCOUNT_DELETE('account_delete_id'),
  GET_FRIENDSHIP_STATE('get_friendship_state'),
  GET_GROUP_BY_ID('get_group_by_id'),
  ;

  const RpcFunctions(this.id);

  final String id;
}

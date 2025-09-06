enum RpcFunctions {
  ACCOUNT_DELETE('account_delete_id'),
  GET_FRIENDSHIP_STATE('get_friendship_state'),
  ;

  const RpcFunctions(this.id);

  final String id;
}

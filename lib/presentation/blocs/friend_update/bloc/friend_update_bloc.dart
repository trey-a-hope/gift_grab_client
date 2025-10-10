import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/main.dart';
import 'package:nakama/nakama.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';

part 'friend_update_event.dart';
part 'friend_update_state.dart';

class FriendUpdateBloc extends Bloc<FriendUpdateEvent, FriendUpdateState> {
  final NakamaBaseClient client;
  final SessionService sessionService;

  FriendUpdateBloc(
    this.client,
    this.sessionService,
  ) : super(const FriendUpdateState()) {
    on<SendRequest>(_onSendRequest);
    on<CancelRequest>(_onCancelRequest);
    on<RejectRequest>(_onRejectRequest);
    on<AcceptRequest>(_onAcceptRequest);
    on<DeleteFriend>(_onDeleteFriend);
    on<BlockFriend>(_onBlockFriend);
    on<UnblockFriend>(_onUnblockFriend);
  }

  Future<void> _onSendRequest(
    SendRequest event,
    Emitter<FriendUpdateState> emit,
  ) async =>
      await _performFriendAction(
        'Friend request sent',
        (session) async {
          logger.i(
              'User ${session.userId} sent a friend request to ${event.uid}');
          await client.addFriends(
            session: session,
            ids: [event.uid],
          );
        },
        emit,
      );

  Future<void> _onCancelRequest(
    CancelRequest event,
    Emitter<FriendUpdateState> emit,
  ) async =>
      await _performFriendAction(
        'Friend request canceled',
        (session) async {
          logger.i(
              'User ${session.userId} canceled a friend request from ${event.uid}');
          await client.deleteFriends(
            session: session,
            ids: [event.uid],
          );
        },
        emit,
      );

  Future<void> _onRejectRequest(
    RejectRequest event,
    Emitter<FriendUpdateState> emit,
  ) async =>
      await _performFriendAction(
        'Friend request rejected',
        (session) async {
          logger.i(
              'User ${session.userId} rejected a friend request from ${event.uid}');
          await client.deleteFriends(
            session: session,
            ids: [event.uid],
          );
        },
        emit,
      );

  Future<void> _onAcceptRequest(
    AcceptRequest event,
    Emitter<FriendUpdateState> emit,
  ) async =>
      await _performFriendAction(
        'Friend request accepted',
        (session) async {
          logger.i(
              'User ${session.userId} accepted a friend request from ${event.uid}');
          await client.addFriends(
            session: session,
            ids: [event.uid],
          );
        },
        emit,
      );

  Future<void> _onDeleteFriend(
    DeleteFriend event,
    Emitter<FriendUpdateState> emit,
  ) async =>
      await _performFriendAction(
        'Friend deleted',
        (session) async {
          logger.i('User ${session.userId} deleted ${event.uid} as a friend');
          await client.deleteFriends(
            session: session,
            ids: [event.uid],
          );
        },
        emit,
      );

  Future<void> _onBlockFriend(
    BlockFriend event,
    Emitter<FriendUpdateState> emit,
  ) async =>
      await _performFriendAction(
        'User blocked',
        (session) async {
          logger.i('User ${session.userId} blocked ${event.uid}');
          await client.blockFriends(
            session: session,
            ids: [event.uid],
          );
        },
        emit,
      );

  Future<void> _onUnblockFriend(
    UnblockFriend event,
    Emitter<FriendUpdateState> emit,
  ) async =>
      await _performFriendAction(
        'User unblocked',
        (session) async {
          logger.i('User ${session.userId} unblocked ${event.uid}');
          await client.deleteFriends(
            session: session,
            ids: [event.uid],
          );
        },
        emit,
      );

  Future<void> _performFriendAction(
    String successMessage,
    Future<void> Function(Session session) clientAction,
    Emitter<FriendUpdateState> emit,
  ) async =>
      runWithErrorHandling(
        action: () async {
          emit(state.copyWith(isLoading: true));

          final session = await sessionService.getSession();

          await clientAction(session);

          emit(state.copyWith(success: successMessage));
        },
        emit: emit,
        state: state,
      );
}

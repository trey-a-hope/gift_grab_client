import 'package:bloc/bloc.dart';
import 'package:bloc_error_handler/bloc_error_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:nakama/nakama.dart';

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
        (session) => client.addFriends(
          session: session,
          ids: [event.uid],
        ),
        emit,
      );

  Future<void> _onCancelRequest(
    CancelRequest event,
    Emitter<FriendUpdateState> emit,
  ) async =>
      await _performFriendAction(
        'Friend request canceled',
        (session) => client.deleteFriends(
          session: session,
          ids: [event.uid],
        ),
        emit,
      );

  Future<void> _onRejectRequest(
    RejectRequest event,
    Emitter<FriendUpdateState> emit,
  ) async =>
      await _performFriendAction(
        'Friend request rejected',
        (session) => client.deleteFriends(
          session: session,
          ids: [event.uid],
        ),
        emit,
      );

  Future<void> _onAcceptRequest(
    AcceptRequest event,
    Emitter<FriendUpdateState> emit,
  ) async =>
      await _performFriendAction(
        'Friend request accepted',
        (session) => client.addFriends(
          session: session,
          ids: [event.uid],
        ),
        emit,
      );

  Future<void> _onDeleteFriend(
    DeleteFriend event,
    Emitter<FriendUpdateState> emit,
  ) async =>
      await _performFriendAction(
        'Friend deleted',
        (session) => client.deleteFriends(
          session: session,
          ids: [event.uid],
        ),
        emit,
      );

  Future<void> _onBlockFriend(
    BlockFriend event,
    Emitter<FriendUpdateState> emit,
  ) async =>
      await _performFriendAction(
        'User blocked',
        (session) => client.blockFriends(
          session: session,
          ids: [event.uid],
        ),
        emit,
      );

  Future<void> _onUnblockFriend(
    UnblockFriend event,
    Emitter<FriendUpdateState> emit,
  ) async =>
      await _performFriendAction(
        'User unblocked',
        (session) => client.deleteFriends(
          session: session,
          ids: [event.uid],
        ),
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

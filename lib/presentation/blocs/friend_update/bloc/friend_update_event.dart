part of 'friend_update_bloc.dart';

sealed class FriendUpdateEvent extends Equatable {
  const FriendUpdateEvent();
}

class SendRequest extends FriendUpdateEvent {
  final String uid;

  const SendRequest(this.uid);

  @override
  List<Object?> get props => [uid];
}

class CancelRequest extends FriendUpdateEvent {
  final String uid;

  const CancelRequest(this.uid);

  @override
  List<Object?> get props => [uid];
}

class RejectRequest extends FriendUpdateEvent {
  final String uid;

  const RejectRequest(this.uid);

  @override
  List<Object?> get props => [uid];
}

class AcceptRequest extends FriendUpdateEvent {
  final String uid;

  const AcceptRequest(this.uid);

  @override
  List<Object?> get props => [uid];
}

class DeleteFriend extends FriendUpdateEvent {
  final String uid;

  const DeleteFriend(this.uid);

  @override
  List<Object?> get props => [uid];
}

class BlockFriend extends FriendUpdateEvent {
  final String uid;

  const BlockFriend(this.uid);

  @override
  List<Object?> get props => [uid];
}

class UnblockFriend extends FriendUpdateEvent {
  final String uid;

  const UnblockFriend(this.uid);

  @override
  List<Object?> get props => [uid];
}

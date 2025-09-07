import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:gift_grab_client/data/constants/label_text.dart';
import 'package:gift_grab_client/presentation/blocs/account_read/bloc/account_read_bloc.dart';
import 'package:gift_grab_client/presentation/blocs/friend_update/bloc/friend_update_bloc.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:modal_util/modal_util.dart';
import 'package:nakama/nakama.dart';

class FriendshipStateButton extends StatelessWidget {
  final String uid;
  final FriendshipState? friendshipState;

  const FriendshipStateButton(this.uid, this.friendshipState, {super.key});

  @override
  Widget build(BuildContext context) {
    final friendUpdateBloc = context.read<FriendUpdateBloc>();
    final accountReadBloc = context.read<AccountReadBloc>();

    final account = accountReadBloc.state.account!;
    final isMyProfile = uid == account.user.id;

    switch (friendshipState) {
      case null:
        return isMyProfile
            ? const SizedBox.shrink()
            : ElevatedButton(
                onPressed: () => friendUpdateBloc.add(SendRequest(uid)),
                child: const Text('Send Request'),
              );
      case FriendshipState.mutual:
        return ElevatedButton(
          onPressed: () async {
            final confirm = await ModalUtil.showConfirmation(
              context,
              title: 'Delete Friend',
              message: LabelText.confirm,
            );

            if (!confirm.falseIfNull()) return;

            friendUpdateBloc.add(DeleteFriend(uid));
          },
          child: const Text('Delete Friend'),
        );
      case FriendshipState.outgoingRequest:
        return ElevatedButton(
          onPressed: () => friendUpdateBloc.add(CancelRequest(uid)),
          child: const Text('Cancel Request'),
        );
      case FriendshipState.incomingRequest:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final confirm = await ModalUtil.showConfirmation(
                  context,
                  title: 'Accept Request',
                  message: LabelText.confirm,
                );

                if (!confirm.falseIfNull()) return;

                friendUpdateBloc.add(AcceptRequest(uid));
              },
              child: const Text('Accept Request'),
            ),
            const Gap(8),
            ElevatedButton(
              onPressed: () async {
                final confirm = await ModalUtil.showConfirmation(
                  context,
                  title: 'Reject Request',
                  message: LabelText.confirm,
                );

                if (!confirm.falseIfNull()) return;

                friendUpdateBloc.add(RejectRequest(uid));
              },
              child: const Text('Reject Request'),
            )
          ],
        );
      case FriendshipState.blocked:
        return const SizedBox.shrink();
    }
  }
}

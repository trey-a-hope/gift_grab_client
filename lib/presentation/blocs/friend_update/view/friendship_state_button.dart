import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/data/configuration/gap_sizes.dart';
import 'package:gift_grab_client/data/constants/label_text.dart';
import 'package:gift_grab_client/domain/services/modal_service.dart';
import 'package:gift_grab_client/presentation/blocs/account_read/bloc/account_read_bloc.dart';
import 'package:gift_grab_client/presentation/blocs/friend_update/bloc/friend_update_bloc.dart';
import 'package:gift_grab_client/presentation/extensions/bool_extensions.dart';
import 'package:nakama/nakama.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FriendshipStateButton extends StatelessWidget {
  final String uid;
  final FriendshipState? friendshipState;

  const FriendshipStateButton(this.uid, this.friendshipState, {super.key});

  @override
  Widget build(BuildContext context) {
    final friendUpdateBloc = context.read<FriendUpdateBloc>();
    final accountReadBloc = context.read<AccountReadBloc>();
    final modalService = context.read<ModalService>();

    final account = accountReadBloc.state.account!;
    final isMyProfile = uid == account.user.id;

    switch (friendshipState) {
      case null:
        return isMyProfile
            ? const SizedBox.shrink()
            : ShadButton(
                child: const Text('Send Request'),
                onPressed: () => friendUpdateBloc.add(SendRequest(uid)),
              );

      case FriendshipState.mutual:
        return ShadButton(
          child: const Text('Delete friend'),
          onPressed: () async {
            final confirm = await modalService.shadConfirmationDialog(
              context,
              title: const Text('Delete friend'),
              description: const Text(LabelText.confirm),
            );

            if (!confirm.falseIfNull()) return;

            friendUpdateBloc.add(DeleteFriend(uid));
          },
        );

      case FriendshipState.outgoingRequest:
        return ShadButton(
          child: const Text('Cancel request'),
          onPressed: () => friendUpdateBloc.add(CancelRequest(uid)),
        );

      case FriendshipState.incomingRequest:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShadButton(
              child: const Text('Accept request'),
              onPressed: () async {
                final confirm = await modalService.shadConfirmationDialog(
                  context,
                  title: const Text('Accept request'),
                  description: const Text(LabelText.confirm),
                );

                if (!confirm.falseIfNull()) return;

                friendUpdateBloc.add(AcceptRequest(uid));
              },
            ),
            GapSizes.smallGap,
            ShadButton(
              child: const Text('Reject request'),
              onPressed: () async {
                final confirm = await modalService.shadConfirmationDialog(
                  context,
                  title: const Text('Reject request'),
                  description: const Text(LabelText.confirm),
                );

                if (!confirm.falseIfNull()) return;

                friendUpdateBloc.add(RejectRequest(uid));
              },
            ),
          ],
        );
      case FriendshipState.blocked:
        return const SizedBox.shrink();
    }
  }
}

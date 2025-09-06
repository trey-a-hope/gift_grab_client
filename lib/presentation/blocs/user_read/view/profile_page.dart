import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:gift_grab_client/data/constants/label_text.dart';
import 'package:gift_grab_client/data/enums/go_routes.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/account_read/bloc/account_read_bloc.dart';
import 'package:gift_grab_client/presentation/blocs/friend_update/bloc/friend_update_bloc.dart';
import 'package:gift_grab_client/presentation/blocs/friend_update/view/friendship_state_button.dart';
import 'package:gift_grab_client/presentation/extensions/user_extensions.dart';
import 'package:gift_grab_ui/widgets/gg_scaffold_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_util/modal_util.dart';
import 'package:nakama/nakama.dart';

import '../user_read.dart';

part 'blocked_content.dart';
part 'unblocked_content.dart';

class ProfilePage extends StatelessWidget {
  final String uid;

  const ProfilePage(this.uid, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserReadBloc>(
          create: (context) => UserReadBloc(
            uid,
            getNakamaClient(),
            context.read<SessionService>(),
          )..add(const ReadUser()),
        ),
        BlocProvider<FriendUpdateBloc>(
          create: (context) => FriendUpdateBloc(
            getNakamaClient(),
            context.read<SessionService>(),
          ),
        )
      ],
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final userReadBloc = context.read<UserReadBloc>();
    final friendUpdateBloc = context.read<FriendUpdateBloc>();

    return BlocListener<FriendUpdateBloc, FriendUpdateState>(
      listener: (context, state) {
        if (state.success != null) {
          ModalUtil.showSuccess(context, title: state.success!);
          userReadBloc.add(const ReadUser());
        }
      },
      child: BlocBuilder<UserReadBloc, UserReadState>(
        builder: (context, state) {
          final user = state.user;

          final isBlocked = state.friendshipState == FriendshipState.blocked;

          return GGScaffoldWidget(
            title: user?.username ?? '',
            actions: [
              if (state.isMyProfile) ...[
                IconButton.filledTonal(
                    onPressed: () async {
                      final success = await context.pushNamed<bool>(
                        GoRoutes.EDIT_PROFILE.name,
                        pathParameters: {'uid': user!.id},
                      );

                      if (success == true) {
                        context.read<UserReadBloc>().add(const ReadUser());
                        context
                            .read<AccountReadBloc>()
                            .add(const ReadAccount());
                      }
                    },
                    icon: const Icon(Icons.edit))
              ],
              if (!state.isMyProfile && user != null) ...[
                IconButton.filledTonal(
                  onPressed: () async {
                    final confirm = await ModalUtil.showConfirmation(
                      context,
                      title: '${isBlocked ? 'Unblock' : 'Block'}',
                      message: LabelText.confirm,
                    );

                    if (confirm != true) return;

                    friendUpdateBloc.add(isBlocked
                        ? UnblockFriend(user.id)
                        : BlockFriend(user.id));
                  },
                  icon: Icon(
                    isBlocked ? MdiIcons.accountLockOpen : MdiIcons.accountLock,
                  ),
                )
              ]
            ],
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: const EdgeInsetsGeometry.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CircleAvatar(
                          radius: 100,
                          backgroundImage: user?.getAvatar(),
                        ),
                        if (isBlocked) ...[const BlockedContent()],
                        if (!isBlocked) ...[
                          UnblockedContent(user, state.friendshipState)
                        ]
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}

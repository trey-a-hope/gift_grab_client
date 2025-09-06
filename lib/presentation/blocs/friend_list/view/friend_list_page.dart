import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/friend_update/friend_update.dart';
import 'package:gift_grab_client/presentation/extensions/string_extensions.dart';
import 'package:gift_grab_client/presentation/widgets/user_list_tile.dart';
import 'package:gift_grab_ui/widgets/no_results_widget.dart';
import 'package:modal_util/modal_util.dart';
import 'package:nakama/nakama.dart';

import '../friend_list.dart';

class FriendListPage extends StatelessWidget {
  final FriendshipState friendshipState;

  const FriendListPage(this.friendshipState, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FriendListBloc>(
          create: (_) => FriendListBloc(
            friendshipState,
            getNakamaClient(),
            context.read<SessionService>(),
          )..add(const InitialFetch()),
        ),
        BlocProvider<FriendUpdateBloc>(
          create: (context) => FriendUpdateBloc(
            getNakamaClient(),
            context.read<SessionService>(),
          ),
        )
      ],
      child: const FriendListView(),
    );
  }
}

class FriendListView extends StatelessWidget {
  const FriendListView({super.key});

  @override
  Widget build(BuildContext context) {
    final friendListBloc = context.read<FriendListBloc>();

    return BlocListener<FriendUpdateBloc, FriendUpdateState>(
      listener: (context, state) {
        if (state.success != null) {
          ModalUtil.showSuccess(context, title: state.success!);
          friendListBloc.add(const InitialFetch());
        }

        if (state.error != null) {
          ModalUtil.showError(context, title: state.error!);
        }
      },
      child: BlocBuilder<FriendListBloc, FriendListState>(
        builder: (context, state) {
          final friends = state.friends;

          final displayEmpty = state.isLoading && friends.isEmpty;
          final displayNoResults = !state.isLoading && friends.isEmpty;
          final displayMoreButton =
              !state.isLoading && state.cursor.nullIfEmpty != null;

          return Column(
            children: [
              Expanded(
                child: displayEmpty
                    ? const SizedBox.shrink()
                    : displayNoResults
                        ? _buildNoResults(state.friendshipState)
                        : ListView.builder(
                            itemCount: friends.length,
                            itemBuilder: (context, index) {
                              final friend = friends[index];
                              return Padding(
                                padding: const EdgeInsetsGeometry.fromLTRB(
                                  8,
                                  8,
                                  8,
                                  16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: UserListTile(friend.user)),
                                    FriendshipStateButton(
                                      friend.user.id,
                                      friend.state,
                                    ),
                                  ],
                                ),
                              );
                            }),
              ),
              if (displayMoreButton) ...[
                Padding(
                  padding: const EdgeInsetsGeometry.all(16),
                  child: ElevatedButton(
                    onPressed: () => friendListBloc.add(const FetchMore()),
                    child: const Text('More'),
                  ),
                )
              ]
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoResults(FriendshipState state) => switch (state) {
        FriendshipState.mutual => const NoResultsWidget(NoResultsEnum.mutual),
        FriendshipState.outgoingRequest =>
          const NoResultsWidget(NoResultsEnum.outgoingRequest),
        FriendshipState.incomingRequest =>
          const NoResultsWidget(NoResultsEnum.incomingRequest),
        FriendshipState.blocked => const NoResultsWidget(NoResultsEnum.blocked),
      };
}

import 'package:flutter/material.dart';
import 'package:gift_grab_client/presentation/blocs/friend_list/view/view.dart';
import 'package:gift_grab_ui/widgets/gg_scaffold_widget.dart';
import 'package:nakama/nakama.dart';

class FriendsPage extends StatelessWidget {
  static const _tabs = [
    'Friends',
    'Invites',
    'Requests',
    'Blocked',
  ];

  static const _tabsContent = [
    FriendListPage(FriendshipState.mutual),
    FriendListPage(FriendshipState.incomingRequest),
    FriendListPage(FriendshipState.outgoingRequest),
    FriendListPage(FriendshipState.blocked),
  ];

  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GGScaffoldWidget(
      title: 'Friends',
      child: DefaultTabController(
        length: _tabs.length,
        child: Column(
          children: [
            TabBar(
              padding: const EdgeInsets.all(8),
              labelColor: Colors.white,
              labelStyle: theme.textTheme.displaySmall,
              indicatorColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: _tabs
                  .map((tab) => Text(
                        tab,
                        style: theme.textTheme.titleLarge,
                      ))
                  .toList(),
            ),
            const Expanded(
              child: TabBarView(
                children: _tabsContent,
              ),
            )
          ],
        ),
      ),
    );
  }
}

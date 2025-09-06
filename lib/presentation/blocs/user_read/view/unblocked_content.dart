part of 'profile_page.dart';

class UnblockedContent extends StatelessWidget {
  final User? user;
  final FriendshipState? friendshipState;

  const UnblockedContent(this.user, this.friendshipState, {super.key});

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();

    return Align(
        child: user != null
            ? Column(
                children: [
                  const Gap(32),
                  FriendshipStateButton(
                    user!.id,
                    friendshipState,
                  )
                ],
              )
            : null);
  }
}

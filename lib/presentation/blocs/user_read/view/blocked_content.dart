part of 'profile_page.dart';

class BlockedContent extends StatelessWidget {
  const BlockedContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Center(
        child: Text(
          'You have this user blocked',
          style: theme.textTheme.headlineLarge,
        ),
      ),
    );
  }
}

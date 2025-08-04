import 'package:flutter/material.dart';
import 'package:gift_grab_game/game/gift_grab_game_widget.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

Future<String?> getAppleToken() async {
  try {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    return credential.identityToken;
  } on SignInWithAppleException catch (e) {
    if (e.toString().contains('canceled')) {
      return null;
    }
    rethrow;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final token = await getAppleToken();

  runApp(const MyAppPage());
}

class MyAppPage extends StatelessWidget {
  const MyAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyAppView();
  }
}

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: GiftGrabTheme.lightTheme,
      darkTheme: GiftGrabTheme.darkTheme,
      themeMode: ThemeMode.dark,
      title: 'Gift Grab',
      home: GiftGrabGameWidget(
        onEndGame: (score) => debugPrint('Score: $score'),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gift_grab_client/presentation/pages/game_page.dart';
import 'package:gift_grab_ui/ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      home: const GamePage(),
    );
  }
}

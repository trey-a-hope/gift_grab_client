import 'package:flutter/material.dart';
import 'package:gift_grab_game/game/gift_grab_game_widget.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _maximizeWindow();

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

Future<void> _maximizeWindow() async {
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  windowManager.waitUntilReadyToShow(
    windowOptions,
    () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.maximize();
    },
  );
}

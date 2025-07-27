import 'package:flutter/material.dart';
import 'package:flutter_app_info/flutter_app_info.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gift_grab_client/data/configuration/app_routes.dart';
import 'package:gift_grab_client/data/repositories/session_repository.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/cubits/auth/auth.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:nakama/nakama.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  getNakamaClient(
    host: '24.144.85.68',
    ssl: false,
    serverKey: 'defaultkey',
  );

  runApp(
    AppInfo(
      data: await AppInfoData.get(),
      child: const MyAppPage(),
    ),
  );
}

class MyAppPage extends StatelessWidget {
  const MyAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SessionService>(create: (context) {
          return SessionService(
            SessionRepository(
              const FlutterSecureStorage(),
              getNakamaClient(),
            ),
          );
        })
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) {
              final sessionService = context.read<SessionService>();

              final authCubit = AuthCubit(
                getNakamaClient(),
                sessionService,
              );

              sessionService.setUnauthenticatedCallback(
                () => authCubit.logout(),
              );

              authCubit.checkAuthStatus();

              return authCubit;
            },
          )
        ],
        child: const MyAppView(),
      ),
    );
  }
}

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    final router = appRouter(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: GiftGrabTheme.lightTheme,
      darkTheme: GiftGrabTheme.darkTheme,
      themeMode: ThemeMode.dark,
      title: 'Gift Grab',
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}

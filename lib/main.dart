import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gift_grab_client/data/configuration/app_routes.dart';
import 'package:gift_grab_client/data/repositories/session_repository.dart';
import 'package:gift_grab_client/data/repositories/social_auth_repository.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/domain/services/social_auth_service.dart';
import 'package:gift_grab_client/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:gift_grab_client/util/utils.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:nakama/nakama.dart';
import 'package:package_info_plus/package_info_plus.dart';

late PackageInfo packageInfo;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  packageInfo = await PackageInfo.fromPlatform();

  if (!PlatformUtil.isWeb) {
    await WindowManagerUtil.maximizeWindow();
  }

  final _ = getNakamaClient(
    host: '24.144.85.68',
    serverKey: 'defaultkey',
    httpPort: PlatformUtil.isWeb ? 443 : 7351, // HTTPS for web, HTTP for mobile
    ssl: PlatformUtil.isWeb,
  );

  runApp(const MyAppPage());
}

class MyAppPage extends StatelessWidget {
  const MyAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SessionService>(
          create: (context) => SessionService(
            SessionRepository(
              const FlutterSecureStorage(),
              getNakamaClient(),
            ),
          ),
        ),
        RepositoryProvider<SocialAuthService>(
          create: (context) => SocialAuthService(
            SocialAuthRepository(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(create: (context) {
            final sessionService = context.read<SessionService>();
            final socialAuthService = context.read<SocialAuthService>();

            final authCubit = AuthCubit(
              getNakamaClient(),
              sessionService,
              socialAuthService,
            );

            sessionService.setUnauthenticatedCallback(
              () => authCubit.logout(),
            );

            authCubit.checkAuthStatus();

            return authCubit;
          })
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
      routeInformationProvider: router.routeInformationProvider,
      routerDelegate: router.routerDelegate,
    );
  }
}

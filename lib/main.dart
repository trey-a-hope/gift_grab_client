import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gift_grab_client/data/configuration/app_routes.dart';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/data/repositories/session_repository.dart';
import 'package:gift_grab_client/data/repositories/social_auth_repository.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/domain/services/social_auth_service.dart';
import 'package:gift_grab_client/presentation/blocs/account_read/bloc/account_read_bloc.dart';
import 'package:gift_grab_client/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:gift_grab_client/util/utils.dart';
import 'package:gift_grab_ui/ui.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nakama/nakama.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:universal_platform/universal_platform.dart';

late PackageInfo packageInfo;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  packageInfo = await PackageInfo.fromPlatform();

  await WindowManagerUtil.maximizeWindow();

  final _ = getNakamaClient(
    host: Globals.nakamaClientHost,
    serverKey: Globals.nakamaClientServerKey,
    httpPort: Globals.nakamaClientHttpPort,
    ssl: UniversalPlatform.isWeb,
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
            GoogleSignIn.instance,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) {
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
            },
          ),
          BlocProvider<AccountReadBloc>(
            create: (context) => AccountReadBloc(
              getNakamaClient(),
              context.read<SessionService>(),
            ),
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
      routeInformationProvider: router.routeInformationProvider,
      routerDelegate: router.routerDelegate,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gift_grab_client/data/configuration/app_routes.dart';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/data/repositories/session_repository.dart';
import 'package:gift_grab_client/data/repositories/social_auth_repository.dart';
import 'package:gift_grab_client/domain/services/launch_service.dart';
import 'package:gift_grab_client/domain/services/modal_service.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/domain/services/social_auth_service.dart';
import 'package:gift_grab_client/presentation/blocs/account_read/bloc/account_read_bloc.dart';
import 'package:gift_grab_client/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:gift_grab_client/presentation/cubits/group_refresh/group_refresh.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:nakama/nakama.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:window_pain/window_pain.dart';

late PackageInfo packageInfo;
late Logger logger;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  packageInfo = await PackageInfo.fromPlatform();

  logger = Logger(
    printer: PrefixPrinter(
      PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        noBoxingByDefault: false,
      ),
    ),
    output: null,
  );

  await WindowPain.maximizeWindow();

  final _ = getNakamaClient(
    host: Globals.nakamaClientHost,
    serverKey: Globals.nakamaClientServerKey,
    httpPort: Globals.nakamaClientHttpPort,
    ssl: UniversalPlatform.isWeb,
  );

  runApp(const MyAppPage());
}

class MyAppPage extends StatefulWidget {
  const MyAppPage({super.key});

  @override
  State<MyAppPage> createState() => _MyAppPageState();
}

class _MyAppPageState extends State<MyAppPage> {
  final _sessionService = SessionService(
    SessionRepository(
      const FlutterSecureStorage(),
      getNakamaClient(),
    ),
  );

  final _socialAuthService = SocialAuthService(
    SocialAuthRepository(),
    GoogleSignIn.instance,
  );

  final _modalService = ModalService();

  final _launchService = LaunchService();

  AuthCubit? authCubit;
  GoRouter? router;

  @override
  void initState() {
    super.initState();

    authCubit = AuthCubit(
      getNakamaClient(),
      _sessionService,
      _socialAuthService,
    );

    _sessionService.setUnauthenticatedCallback(
      () => authCubit!.logout(),
    );

    authCubit!.checkAuthStatus();

    // Create router with the authCubit
    router = appRouter(authCubit!);
  }

  @override
  void dispose() {
    authCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Guard clause: return loading widget if router isn't ready yet
    // In practice, this should never show because initState runs before build
    if (router == null || authCubit == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Now we can safely use ! operator because we checked above
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SessionService>.value(value: _sessionService),
        RepositoryProvider<SocialAuthService>.value(value: _socialAuthService),
        RepositoryProvider<ModalService>.value(value: _modalService),
        RepositoryProvider<LaunchService>.value(value: _launchService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit!),
          BlocProvider<AccountReadBloc>(
            create: (context) => AccountReadBloc(
              authCubit!,
              getNakamaClient(),
              _sessionService,
            ),
          ),
          BlocProvider<GroupRefreshCubit>(
            create: (context) => GroupRefreshCubit(),
          ),
        ],
        child: MyAppView(router!),
      ),
    );
  }
}

class MyAppView extends StatelessWidget {
  final GoRouter router;

  const MyAppView(this.router, {super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.router(
      debugShowCheckedModeBanner: false,
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadSlateColorScheme.light(),
        textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.dmSerifText),
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadSlateColorScheme.dark(),
        textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.dmSerifText),
      ),
      themeMode: ThemeMode.dark,
      title: 'Gift Grab',
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      routerDelegate: router.routerDelegate,
    );
  }
}

import 'dart:convert';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/core/di_container.dart';
import 'package:gift_grab_client/data/configuration/app_routes.dart';
import 'package:gift_grab_client/data/configuration/gap_sizes.dart';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/presentation/controllers/auth_controller.dart';
import 'package:gift_grab_client/presentation/cubits/group_refresh/group_refresh.dart';
import 'package:gift_grab_client/presentation/services/modal_service.dart';
import 'package:gift_grab_client/util/window_manager_util.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nakama/nakama.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:universal_platform/universal_platform.dart';

late PackageInfo packageInfo;

void main() async {
  // debugPaintSizeEnabled = true;

  WidgetsFlutterBinding.ensureInitialized();
  packageInfo = await PackageInfo.fromPlatform();
  await WindowManagerUtil.init();
  // Initialze Nakama Module Client
  final _ = getNakamaClient(
    host: Globals.nakamaClientHost,
    serverKey: Globals.nakamaClientServerKey,
    httpPort: Globals.nakamaClientHttpPort,
    ssl: UniversalPlatform.isWeb,
  );
  await configureDependencies();

  runApp(
    ClerkAuth(config: Globals.clerkAuthConfig, child: const AppInitializer()),
  );
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      if (!di.isRegistered<ClerkAuthState>()) {
        final authState = ClerkAuth.of(context, listen: false);
        di.registerSingleton<ClerkAuthState>(authState);
      }

      await _initEnvVars();
      // await _initFluo();

      // await di<AuthController>().logout();

      setState(() => _isInitialized = true);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsetsGeometry.all(GapSizes.xlGap.mainAxisExtent),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Lottie.network(
                'https://lottie.host/a470a89f-73ab-4c17-9c93-f41cba57289c/Cs3tJzRAcQ.json',
              ),
            ),
          ),
        ),
      );
    }

    return const MyAppPage();
  }
}

class MyAppPage extends StatelessWidget {
  const MyAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // RepositoryProvider<SessionService>(
        //   create: (context) => SessionService(
        //     SessionRepository(const FlutterSecureStorage(), getNakamaClient()),
        //   ),
        // ),
        RepositoryProvider<ModalService>(create: (context) => ModalService()),
      ],
      child: MultiBlocProvider(
        providers: [
          // BlocProvider<AuthCubit>(
          //   create: (context) {
          //     final sessionService = context.read<SessionService>();
          //     final clerkAuth = ClerkAuth.of(context, listen: false);

          //     final authCubit = AuthCubit(
          //       getNakamaClient(),
          //       sessionService,
          //       clerkAuth,
          //     );

          //     sessionService.setUnauthenticatedCallback(
          //       () => authCubit.logout(),
          //     );

          //     authCubit.checkAuthStatus();

          //     return authCubit;
          //   },
          // ),
          // BlocProvider<AccountReadBloc>(
          //   create: (context) => AccountReadBloc(
          //     di<AuthController>(),
          //     getNakamaClient(),
          //     context.read<SessionService>(),
          //   ),
          // ),
          BlocProvider<GroupRefreshCubit>(
            create: (context) => GroupRefreshCubit(),
          ),
        ],
        child: const MyAppView(),
      ),
    );
  }
}

class MyAppView extends StatelessWidget {
  final _font = GoogleFonts.aBeeZee;

  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    final router = appRouter(context);

    return ClerkErrorListener(
      child: ShadApp.router(
        // localizationsDelegates: const [
        //   ...FluoLocalizations.localizationsDelegates,
        // ],
        // supportedLocales: FluoLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        theme: ShadThemeData(
          brightness: Brightness.light,
          colorScheme: const ShadNeutralColorScheme.light(),
          textTheme: ShadTextTheme.fromGoogleFont(_font),
        ),
        darkTheme: ShadThemeData(
          brightness: Brightness.dark,
          colorScheme: const ShadNeutralColorScheme.dark(),
          textTheme: ShadTextTheme.fromGoogleFont(_font),
        ),
        themeMode: ThemeMode.dark,
        title: 'Gift Grab',
        routerConfig: router,
      ),
    );
  }
}

Future<void> _initEnvVars() async {
  const fluoApiKeyEncoded = String.fromEnvironment('FLUO_API_KEY');
  if (fluoApiKeyEncoded.isEmpty) {
    throw Exception('Fluo api key is empty');
  }
  final fluoApiKey = utf8.decode(base64.decode(fluoApiKeyEncoded));

  Globals.FLUO_API_KEY = fluoApiKey;
}

// Future<void> _initFluo() async {
//   try {
//     await Fluo.initWithApiKey(Globals.FLUO_API_KEY);
//     await Fluo.instance.loadAppConfig();
//     logger.d('Fluo initialized successfully (key: ${Globals.FLUO_API_KEY})');
//   } catch (e) {
//     const flutterSecureStorage = FlutterSecureStorage();
//     await flutterSecureStorage.deleteAll();
//     throw Exception(
//       'Could not initialize Fluo\n\napikey: ${Globals.FLUO_API_KEY}\n\n${e.toString()}\n\nPlease try relaunching the app',
//     );
//   }
// }

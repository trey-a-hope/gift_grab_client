import 'dart:convert';

import 'package:fluo/fluo.dart';
import 'package:fluo/l10n/fluo_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gift_grab_client/data/configuration/app_routes.dart';
import 'package:gift_grab_client/data/configuration/gap_sizes.dart';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/data/repositories/session_repository.dart';
import 'package:gift_grab_client/domain/services/session_service.dart';
import 'package:gift_grab_client/presentation/blocs/account_read/bloc/account_read_bloc.dart';
import 'package:gift_grab_client/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:gift_grab_client/presentation/cubits/group_refresh/group_refresh.dart';
import 'package:gift_grab_client/presentation/services/modal_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
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

  runApp(const AppInitializer());
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
      await _initEnvVars();
      await _initFluo();

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
        RepositoryProvider<SessionService>(
          create: (context) => SessionService(
            SessionRepository(const FlutterSecureStorage(), getNakamaClient()),
          ),
        ),
        RepositoryProvider<ModalService>(create: (context) => ModalService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) {
              final sessionService = context.read<SessionService>();

              final authCubit = AuthCubit(getNakamaClient(), sessionService);

              sessionService.setUnauthenticatedCallback(
                () => authCubit.logout(),
              );

              authCubit.checkAuthStatus();

              return authCubit;
            },
          ),
          BlocProvider<AccountReadBloc>(
            create: (context) => AccountReadBloc(
              context.read<AuthCubit>(),
              getNakamaClient(),
              context.read<SessionService>(),
            ),
          ),
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

    return ShadApp.router(
      localizationsDelegates: FluoLocalizations.localizationsDelegates,
      supportedLocales: FluoLocalizations.supportedLocales,
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
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      routerDelegate: router.routerDelegate,
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

Future<void> _initFluo() async {
  try {
    await Fluo.init(Globals.FLUO_API_KEY);
    logger.d('Fluo initialized successfully (key: ${Globals.FLUO_API_KEY})');
  } catch (e) {
    const flutterSecureStorage = FlutterSecureStorage();
    await flutterSecureStorage.deleteAll();
    throw Exception(
      'Could not initialize Fluo\n\napikey: ${Globals.FLUO_API_KEY}\n\n${e.toString()}\n\nPlease try relaunching the app',
    );
  }
}

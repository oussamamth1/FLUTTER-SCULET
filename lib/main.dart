import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart' as pro;
import 'package:zenifytrip_guide/env.dart';
import 'package:zenifytrip_guide/features/ChatModulev2/SocketManagment.dart';
import 'package:zenifytrip_guide/features/auth/presentation/providers/auth_provider.dart';
import 'package:zenifytrip_guide/features/task/TaskService.dart';
import 'package:zenifytrip_guide/features/task/task.dart';
import 'package:zenifytrip_guide/map.dart';
import 'package:zenifytrip_guide/pages/home.dart';
import 'package:zenifytrip_guide/project/routes/app_rout_config.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:zenifytrip_guide/provider/location_provider.dart';
import 'package:zenifytrip_guide/provider/mapSecreen..dart';
import 'package:zenifytrip_guide/service_locator.dart';
import 'package:zenifytrip_guide/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:zenify_auth/zenify_auth.dart' as zenifyAuth;
import 'package:network_layer/network_layer.dart' as layer;
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

String? initialToken;
String? initialCookie;
// service_locator.dart (better approach)
Future<void> initServices() async {
  // 1. Register and initialize storage
  final authStorage = zenifyAuth.AuthStorage();
  await authStorage.init();
  sl.registerSingleton<zenifyAuth.AuthStorage>(authStorage);

  // 2. Create repository first (needed for notifier)
  // Note: We need to initialize ZenifyAuth first to create the repo
  await zenifyAuth.ZenifyAuth.initialize(
    baseUrl: "https://api.staging.zenifytrip.com",
    fromJson: (json) => zenifyAuth.User.fromJson(json),
    storage: sl<zenifyAuth.AuthStorage>(),
    autoRestore: false, // We'll do it manually with notifier below
  );

  // 3. Register auth repository
  sl.registerLazySingleton<zenifyAuth.AuthRepository<zenifyAuth.User>>(
    () => zenifyAuth.ZenifyAuth.authRepo,
  );

  // 4. Create and register notifier
  final authNotifier = zenifyAuth.AuthNotifier<zenifyAuth.User>(
    sl<zenifyAuth.AuthRepository<zenifyAuth.User>>(),
  );
  sl.registerSingleton<zenifyAuth.AuthNotifier<zenifyAuth.User>>(authNotifier);

  // 5. Now manually restore session with the notifier
  final storage = sl<zenifyAuth.AuthStorage>();
  // if (storage.isLoggedIn()) {
  final token = storage.getToken();
  final cookie = storage.getCookie();
  final userData = storage.getUserJson();
  print('✅ Session restored $token');
  print('✅ Session restored $cookie');
  print('✅ Session restored $userData');
  print('✅ Session user $userData');
  print('✅ Session user ${userData?.firstName}');

  if (token != null && cookie != null) {
    try {
      authNotifier.setAuthState(
        zenifyAuth.AuthState<zenifyAuth.User>(
          status: zenifyAuth.AuthStatus.authenticated,
          user: userData,
          token: token,
          cookie: cookie,
        ),
      );
      print('✅ Session restored successfully');
    } catch (e) {
      print('❌ Failed to restore session: $e');
      await storage.clear();
    }
  }
  // }
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await initServices();

  await Hive.initFlutter();
  await Hive.openBox('authBox');
  //Hive.registerAdapter(UserAdapter()); // <-- important

  // await Hive.openBox<zenifyAuth.User>('users');
  usePathUrlStrategy(); // ✅ No hash in URLs
  // Register the Task adapter
  Hive.registerAdapter(TaskAdapter());
  AppEnvironment.setupEnv(Environment.tunisie);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Create your environment config (base url, etc.)
  final config = layer.EnvironmentConfig(
    environment: layer.Environment.staging,
    baseUrl: "https://api.staging.zenifytrip.com",
    apiVersion: "api",
    connectTimeout: 5000,
    receiveTimeout: 5000,
    sendTimeout: 5000,
    enableLogging: true,
    enableSSLPinning: false,
    allowedSSLFingerprints: null,
  );

  final tokenService = layer.TokenService();
  // final connectivityService = layer.ConnectivityService();
  final connectivity = Connectivity();
  //final connectivityService = ConnectivityService(connectivity: connectivity);
  final connectivityService = layer.ConnectivityService(
    connectivity: connectivity,
  );
  //connectivityService.initialize();

  connectivityService.initialize();
  final dioClient = layer.DioClient(
    config: config,
    tokenService: tokenService,
    connectivityService: connectivityService,
  );

  final container = ProviderContainer(
    // observers: [Logger()],
    overrides: [
      // isarProvider.overrideWithValue(isar),
      // secureStorageProvider.overrideWithValue(storage),
    ],
  );

  final token = await dioClient.refreshToken();
  print("token $token");
  // get tokens from secure storage
  await container.read(authProvider.notifier);

  final taskService = TaskService();
  await taskService.init();
  // runApp(
  //   MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     home: TestApiScreen(dioClient: dioClient),
  //   ),
  // );
  runApp(
    ProviderScope(
      // Riverpod root
      child: pro.MultiProvider(
        // Classic provider root
        providers: [
          pro.ChangeNotifierProvider(
            create: (context) => LocationProvider(),
            child: MyApp(),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}

//final authRepo = zenifyAuth.ZenifyAuth.authRepo; // ✅ correct usage
class TestApiScreen extends StatefulWidget {
  final layer.DioClient dioClient;
  const TestApiScreen({super.key, required this.dioClient});

  @override
  State<TestApiScreen> createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  String _result = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    print("🔍 Loading data...");
    try {
      final response = await widget.dioClient.dio.get("/users");
      setState(() => _result = response.data.toString());
      print("✅ Response: ${response.data}");
    } on DioException catch (dioError) {
      final networkError = layer.NetworkException.getDioException(dioError);
      final message = layer.NetworkException.getErrorMessage(networkError);
      print("❌ Error: $message $networkError");
      setState(() => _result = "Error: $message");
    } catch (e) {
      // Catch any other unexpected error
      print("❌ Unexpected: $e");
      setState(() => _result = "Unexpected error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test API")),
      body: Center(child: Text(_result)),
    );
  }
}

class MyApp extends ConsumerWidget {
  MyApp({super.key});
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  // This widget is the root of your application.

  Widget build(BuildContext context, WidgetRef ref) {
    final router = AppRoutConfig.returnRouter(ref);
    return MaterialApp.router(
      //  locale: const Locale('en'), // Add this line
      locale: const Locale('fr'),

      localizationsDelegates: [
        zenifyAuth.AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // ...GlobalMaterialLocalizations.delegates,
      ],

      supportedLocales: const [Locale('en'), Locale('ar'), Locale('fr')],

      // routerConfig: _router,
      //    locale: const Locale('en'),
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: AppEnvironment.lightTheme,
      title: 'ZenifyTrip Guide',
      //locale: const Locale('ar'),
      debugShowCheckedModeBanner: false,
      //restorationScopeId: null, // Disable restoration to avoid the error
      routerConfig: router, // 👈 This is enough! Remove parser/delegate
    );
  }
}
